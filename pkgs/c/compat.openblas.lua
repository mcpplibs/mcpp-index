-- compat.openblas — OpenBLAS built from source as a portable, BLAS-only static
-- library that satisfies the `blas` capability for consumers (e.g. Eigen's
-- `use_blas` feature, which defines EIGEN_USE_BLAS and links the Fortran-ABI
-- BLAS symbols sgemm_/dgemm_/ddot_/…) AND is usable standalone via <cblas.h>.
--
-- OpenBLAS builds through its own GNU Make system (getarch config generation +
-- per-arch kernels), which does not fit mcpp's "list the .c files" model. The
-- xpkg install() hook runs that Make build (build-dep `xim:make`) and lays the
-- lib + headers under the install dir. Built BLAS-ONLY (NO_LAPACK — LAPACK
-- needs Fortran) with TARGET=GENERIC (portable C kernels), static (NO_SHARED).
--
-- How mcpp is made to run install(): mcpp runs an xpkg's install() hook when its
-- build needs a source that install() PRODUCES (the same way compat.xcb's
-- c_client.py generates xproto.c, which mcpp then compiles). So instead of a
-- mcpp `generated_files` anchor (which would make mcpp self-sufficient and skip
-- install()), install() WRITES the anchor TU itself. mcpp extracts the tarball,
-- finds the anchor missing, runs install() — which builds the lib, writes the
-- headers, and emits the anchor — then compiles the anchor and links the lib
-- (`-Llib -lopenblas`, with `-Llib` rewritten to <verdir>/lib).
--
-- Platforms: linux/macosx build from source via Make. Windows (no upstream Make
-- path; OpenBLAS ships prebuilt zips) is a follow-up.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "compat.openblas",
    description = "OpenBLAS — optimized BLAS, built from source (BLAS-only, no Fortran/LAPACK)",
    licenses    = {"BSD-3-Clause"},
    repo        = "https://github.com/OpenMathLib/OpenBLAS",
    type        = "package",

    xpm = {
        linux = {
            deps = { "xim:make@latest" },
            ["0.3.33"] = {
                url = {
                    GLOBAL = "https://github.com/OpenMathLib/OpenBLAS/releases/download/v0.3.33/OpenBLAS-0.3.33.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openblas/releases/download/0.3.33/OpenBLAS-0.3.33.tar.gz",
                },
                sha256 = "6761af1d9f5d353ab4f0b7497be2643313b36c8f31caec0144bfef198e71e6ab",
            },
        },
        macosx = {
            deps = { "xim:make@latest" },
            ["0.3.33"] = {
                url = {
                    GLOBAL = "https://github.com/OpenMathLib/OpenBLAS/releases/download/v0.3.33/OpenBLAS-0.3.33.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openblas/releases/download/0.3.33/OpenBLAS-0.3.33.tar.gz",
                },
                sha256 = "6761af1d9f5d353ab4f0b7497be2643313b36c8f31caec0144bfef198e71e6ab",
            },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        c_standard   = "c11",
        -- The anchor is NOT a generated_files entry: it is emitted by install()
        -- so mcpp must run install() (which also builds the lib) before it can
        -- compile this source. include/ + lib/ are produced by `make install`.
        sources      = { "mcpp_openblas_anchor.c" },
        targets      = { ["openblas"] = { kind = "lib" } },
        include_dirs = { "include" },
        ldflags      = { "-Llib", "-lopenblas" },
        provides     = { "blas" },
        deps         = { },
    },
}

import("xim.libxpkg.pkginfo")
import("xim.libxpkg.log")

local function sh_quote(value)
    return "'" .. tostring(value):gsub("'", "'\\''") .. "'"
end

local function resolve_make()
    local mk = pkginfo.build_dep("xim:make") or pkginfo.build_dep("make")
    if mk and mk.bin then
        local cand = path.join(mk.bin, "make")
        if os.isfile(cand) then return cand end
    end
    return "make"
end

-- The Make build runs inside the install dir and writes a log there (xim's
-- interface mode suppresses subprocess stdout, so an on-disk log is the only way
-- to inspect a failed compile after the fact).
local function _install_impl()
    -- The fetched tarball unpacks to OpenBLAS-<ver>/ beside the archive.
    local ifile   = pkginfo.install_file()
    local srcroot = ifile and tostring(ifile):replace(".tar.gz", "")
                            or ("OpenBLAS-" .. pkginfo.version())
    if not os.isdir(srcroot) then
        srcroot = "OpenBLAS-" .. pkginfo.version()
    end

    -- Move the unpacked source into the install dir and build in place (the
    -- compat.xcb pattern — the extracted srcroot is transient). `os.cd` is the
    -- only directory primitive xim's restricted Lua exposes here (no os.curdir
    -- / os.files / os.trymkdir), so paths are formed explicitly via path.join.
    local prefix = pkginfo.install_dir()
    os.tryrm(prefix)
    os.mv(srcroot, prefix)
    os.cd(prefix)

    -- BLAS-only, portable C kernels, static, single-threaded — no Fortran/LAPACK
    -- (those need a Fortran compiler). CC is pinned to gcc for a stable C ABI
    -- with the consumer's toolchain. The Make build-dep (`xim:make`) provides a
    -- musl-static GNU Make; fall back to PATH `make` if unresolved.
    local make  = resolve_make()
    local jobs  = (os.default_njob and os.default_njob()) or 4
    local flags = "TARGET=GENERIC NO_FORTRAN=1 NO_LAPACK=1 NO_SHARED=1 "
               .. "USE_THREAD=0 USE_OPENMP=0 CC=gcc"
    local logf  = path.join(prefix, "mcpp_openblas_build.log")
    os.exec(string.format("bash -c %s", sh_quote(string.format(
        "cd %s && %s -j%d %s libs > %s 2>&1",
        sh_quote(prefix), make, jobs, flags, sh_quote(logf)))))
    os.exec(string.format("bash -c %s", sh_quote(string.format(
        "cd %s && %s %s PREFIX=%s install >> %s 2>&1",
        sh_quote(prefix), make, flags, sh_quote(prefix), sh_quote(logf)))))

    -- Materialise lib/libopenblas.a. `make install` lays a versioned archive +
    -- a `libopenblas.a` symlink under lib/; if the symlink is absent, copy the
    -- (root- or lib-) built archive there. xim's Lua has no os.files glob, so
    -- the candidate names are enumerated explicitly.
    local libdir   = path.join(prefix, "lib")
    local target_a = path.join(libdir, "libopenblas.a")
    if not os.isfile(target_a) then
        local versioned = "libopenblas_generic-r" .. pkginfo.version() .. ".a"
        local candidates = {
            path.join(prefix, "libopenblas.a"),
            path.join(libdir, versioned),
            path.join(prefix, versioned),
        }
        local picked
        for _, c in ipairs(candidates) do
            if os.isfile(c) then picked = c; break end
        end
        if not picked then
            log.error("compat.openblas: build produced no libopenblas archive "
                   .. "(see %s)", logf)
            return false
        end
        os.cp(picked, target_a)
    end

    -- Emit the anchor TU mcpp compiles. Its absence after extraction is what
    -- makes mcpp run this install() before the build (same trigger as
    -- compat.xcb's generated xproto.c); building it here also produces the lib.
    io.writefile(path.join(prefix, "mcpp_openblas_anchor.c"),
                 "int mcpp_compat_openblas_anchor(void) { return 0; }\n")
    return true
end

function install()
    local ok, err = pcall(_install_impl)
    if not ok then
        log.error("compat.openblas install() failed: %s", tostring(err))
        return false
    end
    return true
end
