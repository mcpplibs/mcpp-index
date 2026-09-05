-- compat.sycl-runtime -- put the SYCL runtime on an mcpp binary's runtime
-- search path.
--
-- WHAT IT FIXES. An mcpp-built program runs under mcpp's OWN loader, so a
-- soname that is not in its RPATH is not found at all: the host's /usr/lib is
-- never consulted. A program whose device half was compiled by the dpcpp
-- payload links `-lsycl`, which the rule package satisfies at LINK time from
-- the payload's own directory, and then fails the runtime closure check:
--
--   libsycl.so.9 not found on the search path this artifact will actually use.
--   Its PT_INTERP is a private loader, so the host's /usr/lib is NOT consulted
--
-- `runtime.library_dirs` below puts a package-owned directory on that path --
-- the same mechanism compat.cuda-runtime and compat.vulkan-runtime use for the
-- same reason, and for the same class of library: one a program reaches
-- through the loader rather than through a header.
--
-- WHY EVERY VERSIONED SONAME AND NOT JUST libsycl.
--
-- SYCL's device support is a chain of dlopens: `libsycl.so.9` loads
-- `libur_loader.so.0`, which loads one `libur_adapter_*.so.0` per back end,
-- and those need `libumf.so.1`. The loader finds an adapter by looking beside
-- ITSELF, and `$ORIGIN` resolves to the directory of the symlink rather than
-- of its target -- so a farm holding `libsycl.so.9` alone would load, then
-- enumerate no devices, which is the failure that looks like "this machine has
-- no GPU". Every versioned soname in the payload is linked, so the whole chain
-- resolves inside one directory.
--
-- ONLY VERSIONED SONAMES. mcpp puts `runtime.library_dirs` on the LINK line as
-- well as the runtime path, so an unversioned `libsycl.so` here would be found
-- by `-lsycl` and would bind the build to this farm instead of to the payload
-- the project declared. A versioned soname is invisible to the linker and is
-- exactly what dlopen asks for -- the reasoning compat.cuda-runtime records
-- for `libcuda.so.1`.
--
-- THE PROBE IS NOT REPEATED HERE. Where the SYCL runtime is, is a question the
-- `xim:dpcpp` payload already answers by existing; this package declares the
-- edge and reads the directory back. `xpm.<platform>.deps` rather than the
-- package's own `[xlings]`, because mcpp materialises `[xlings] deps` for the
-- ROOT project only and this must resolve when the package itself installs.
--
-- NOTHING IS REQUIRED. A machine with no GPU is a legitimate configuration --
-- every runner in this repository is one. The SYCL runtime still loads, still
-- enumerates whatever it finds, and a program that needs a device says so
-- itself.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "sycl-runtime",
    description = "SYCL runtime adapter for mcpp Linux applications (Intel DPC++ payload)",
    licenses    = {"Apache-2.0"},  -- the recipe; the payload is Apache-2.0 WITH LLVM-exception
    repo        = "https://github.com/mcpp-community/mcpp-index",
    type        = "package",

    xpm = {
        linux = {
            -- The install-time edge. Materialised when THIS package installs,
            -- which is what makes the payload's directory exist by the time
            -- install() below reads it.
            -- `xim:zlib` is not decoration. `libur_loader.so.0` needs
            -- `libz.so.1`, which the payload does not carry, and the farm's
            -- RUNPATH is the only place the loader looks for it. On a
            -- developer machine that had zlib installed for other reasons the
            -- omission was invisible; a fresh runner reported
            -- `FAIL libsycl.so.9: libz.so.1: cannot open shared object file`.
            deps = { "xim:dpcpp@7.1.0", "xim:zlib" },
            ["2026.09.06"] = {
                -- Nothing downloaded matters: the content is the set of
                -- symlinks install() creates. A stable, tiny anchor keeps the
                -- xpm entry well-formed, the same trick compat.cuda-runtime
                -- and compat.vulkan-runtime use.
                url    = "https://raw.githubusercontent.com/intel/llvm/v7.1.0/sycl/LICENSE.TXT",
                sha256 = "410f3a23b4bbacbd246310d8c014a20af18cfc8c0d740ddf0f673ea20894da9c",
            },
            ["latest"] = { ref = "2026.09.06" },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        c_standard   = "c11",
        sources      = { "mcpp_generated/sycl_runtime_empty.c" },
        targets      = { ["sycl_runtime"] = { kind = "lib" } },
        deps         = {},
        runtime = {
            library_dirs = { "mcpp_generated/sycl_runtime/lib" },
            capabilities = { "sycl.runtime" },
            provides     = { "sycl.runtime" },
        },
    },
}

import("xim.libxpkg.pkginfo")
import("xim.libxpkg.log")

-- The payload's install directory.
--
-- `pkginfo.install_dir` scans only the member-local xpkgs roots; a dependency
-- installed into the shared registry cache is invisible to it and comes back
-- nil, so the known roots are tried before giving up. The same fallback
-- compat.cuda-runtime needs, for the same reason.
local function payload_dir()
    local dir = pkginfo.install_dir("xim:dpcpp", "7.1.0")
    if dir then return dir end
    local roots = {}
    local pfx = pkginfo.install_dir()
    if pfx then roots[#roots + 1] = path.directory(path.directory(pfx)) end
    local home = (os.getenv and os.getenv("XLINGS_HOME")) or ""
    if home == "" then home = ((os.getenv and os.getenv("HOME")) or "") .. "/.xlings" end
    roots[#roots + 1] = path.join(home, "data/xpkgs")
    for _, root in ipairs(roots) do
        for _, ns in ipairs({ "xim-x-dpcpp", "local-x-dpcpp" }) do
            local cand = path.join(root, ns, "7.1.0")
            if os.isdir(cand) then return cand end
        end
    end
    return nil
end

-- THE C LIBRARY'S COMPATIBILITY STUBS HAVE TO BE FARMED TOO.
--
-- The payload's shared objects carry `RUNPATH = $ORIGIN`, and a non-empty
-- RUNPATH on an intermediate library TURNS OFF the executable's inherited
-- DT_RPATH for that library's own dependencies (mcpp#460). So the artifact's
-- search path, which reaches mcpp's glibc payload, is not consulted when the
-- loader looks for what `libsycl.so.9` needs, and the program dies before
-- `main`:
--
--   error while loading shared libraries: libdl.so.2: cannot open shared
--   object file: No such file or directory
--
-- `$ORIGIN` is the SYMLINK's directory, not the target's, so linking the stubs
-- into this farm beside the payload's own symlinks is what makes a farm of
-- links sufficient and a copy of the payload unnecessary.
--
-- Only the libraries glibc 2.34 MERGED INTO libc are farmed. They are empty
-- compatibility stubs, so which payload version answers does not matter, and
-- nothing else is loading them: `libc.so.6`, `libm.so.6`, `libgcc_s.so.1` and
-- `libstdc++.so.6` are already loaded on the executable's own behalf by the
-- time `libsycl.so.9` asks, and are found by soname without a search. Farming
-- those would risk a second C library in one address space, which is the one
-- failure worse than this one.
--
-- This is the third copy of this helper in this index (compat.cudart and
-- compat.curand carry the other two) and it is duplicated rather than shared
-- for the reason those record: a recipe is loaded in a sandbox that has no
-- module of this index's own to import.
local function farm_libc_stubs(dst, payload)
    -- The three glibc 2.34 merged stubs, AND the two GCC runtime libraries.
    --
    -- compat.cudart farms the stubs alone and says why the C++ runtime is not
    -- among them: for a CUDA program `libstdc++.so.6` is already loaded on the
    -- executable's own behalf by the time the component asks. That reasoning
    -- does not carry here. `libsycl.so.9` needs libstdc++ itself, and an mcpp
    -- artifact links libc++ -- so unless the consumer happens to have named
    -- libstdc++ on its own link line, nothing has loaded it and the farm's
    -- RUNPATH is the only place the loader looks:
    --
    --   FAIL libsycl.so.9: libstdc++.so.6: cannot open shared object file
    --
    -- Farming it is safe for the reason farming libc would not be: there is
    -- exactly one libstdc++ in this ecosystem, `xim:gcc-runtime`'s, so a
    -- consumer that also links it resolves the same file under the same soname
    -- and it is loaded once.
    local roots = {}
    -- FIRST, THE STORE THE PAYLOAD ITSELF CAME FROM. The other roots below are
    -- derived from the environment, and this package installs into a
    -- PROJECT-LOCAL store while its payload is resolved from the shared
    -- registry -- so `install_dir`'s grandparent holds this package alone and
    -- $HOME may be remapped. Measured: with the environment-derived roots
    -- alone the stub search found nothing, and the program died on
    -- `libdl.so.2` with a farm that otherwise looked complete. The payload's
    -- own directory cannot be wrong: glibc is its sibling by construction.
    if payload then roots[#roots + 1] = path.directory(path.directory(payload)) end
    local pfx = pkginfo.install_dir()
    if pfx then roots[#roots + 1] = path.directory(path.directory(pfx)) end
    local home = (os.getenv and os.getenv("XLINGS_HOME")) or ""
    if home == "" then home = ((os.getenv and os.getenv("HOME")) or "") .. "/.xlings" end
    roots[#roots + 1] = path.join(home, "data/xpkgs")
    roots[#roots + 1] = path.join((os.getenv and os.getenv("HOME")) or "",
                                 ".mcpp/registry/data/xpkgs")
    local wanted = {
        { pkg = "xim-x-glibc",       names = { "librt.so.1", "libpthread.so.0", "libdl.so.2" } },
        { pkg = "xim-x-gcc-runtime", names = { "libstdc++.so.6", "libgcc_s.so.1" } },
        -- zlib ships under lib/ rather than lib64/, so the search below tries
        -- both rather than assuming one layout per package.
        { pkg = "xim-x-zlib",        names = { "libz.so.1" } },
    }
    local found = 0
    for _, group in ipairs(wanted) do
    for _, name in ipairs(group.names) do
        if not os.isfile(path.join(dst, name)) then
            for _, root in ipairs(roots) do
                local f = io.popen(string.format(
                    [[ls -1d "%s"/%s/*/lib64/%s "%s"/%s/*/lib/%s 2>/dev/null ]]
                    .. [[| sort -V | tail -1]],
                    root, group.pkg, name, root, group.pkg, name))
                local hit = f and (f:read("l") or "") or ""
                if f then f:close() end
                if hit ~= "" then
                    os.exec(string.format([[ln -sfn "%s" "%s"]], hit, path.join(dst, name)))
                    found = found + 1
                    break
                end
            end
        end
    end
    end
    return found
end

function install()
    os.tryrm(pkginfo.install_dir())
    os.mkdir(pkginfo.install_dir())

    local generated = path.join(pkginfo.install_dir(), "mcpp_generated")
    os.mkdir(generated)
    io.writefile(path.join(generated, "sycl_runtime_empty.c"),
        "int mcpp_compat_sycl_runtime_anchor(void) { return 0; }\n")

    local outdir = path.join(generated, "sycl_runtime", "lib")
    os.mkdir(outdir)

    local src = payload_dir()
    if not src then
        -- Reported, not fatal. The farm is empty, the link still succeeds
        -- because the rule package puts the payload's own directory on the
        -- link line, and the runtime closure check reports the missing soname
        -- by name -- which is a better message than this package could write.
        log.warn("compat.sycl-runtime: the xim:dpcpp payload was not found; "
                 .. "the runtime library directory will be empty")
        return true
    end

    -- `io.popen` rather than `os.files`: the latter is not available in the
    -- recipe sandbox (`attempt to call a nil value`), which the llvm and
    -- cuda-cccl recipes record the same way.
    local n = 0
    local p = io.popen("ls -1 " .. path.join(src, "lib") .. " 2>/dev/null")
    if p then
        for line in p:lines() do
            -- `libfoo.so.N` and `libfoo.so.N.M.P`, never a bare `libfoo.so`:
            -- see the header for why an unversioned name here would reach the
            -- linker.
            -- `libfoo.so.N`, `libfoo.so.N.M.P` and upstream's `.so.9.0.0-0`,
            -- but not the `-gdb.py` sidecars that sit beside them and match a
            -- looser test for a versioned soname.
            if line:match("%.so%.%d") and not line:match("%.py$") then
                os.exec("ln -sf " .. path.join(src, "lib", line) .. " "
                        .. path.join(outdir, line))
                n = n + 1
            end
        end
        p:close()
    end
    if n == 0 then
        log.warn("compat.sycl-runtime: the payload at %s has no versioned "
                 .. "library in lib/; the farm is empty", src)
        return true
    end

    local stubs = farm_libc_stubs(outdir, src)
    log.info("compat.sycl-runtime: %d versioned sonames from %s, %d C-library stubs",
             n, src, stubs)
    return true
end
