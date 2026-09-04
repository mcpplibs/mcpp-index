-- compat.cuda-runtime — put the host NVIDIA driver on an mcpp binary's
-- runtime search path.
--
-- WHAT IT FIXES. An mcpp-built program runs under mcpp's OWN glibc
--
--   interp: .../xpkgs/xim-x-glibc/2.44/lib64/ld-linux-x86-64.so.2
--   rpath : .../xim-x-glibc/2.44/lib64:.../xim-x-gcc/16.1.0/lib64:...
--
-- so a bare-soname dlopen from inside it does not search the host's library
-- path at all. A program that links the CUDA runtime statically therefore
-- carries every redistributable component and still cannot start: the runtime
-- cannot dlopen libcuda.so.1 and reports
--
--   cudaMalloc: CUDA driver version is insufficient for CUDA runtime version
--
-- which is a confusing way to say "not found". `runtime.library_dirs` below
-- puts a package-owned directory on that path, the same mechanism
-- compat.glx-runtime and compat.vulkan-runtime use for the same reason.
--
-- ⭐ THE PROBE IS NOT REPEATED HERE. xim's `libcuda-host-link` already owns the
-- question "where is the host's libcuda", and its own recipe states why that
-- must live in one place:
--
--   Single source of truth for "where is host libcuda" -> all GPU xpkgs read
--   from pkginfo.dep_install_dir("libcuda-host-link").."/lib/libcuda.so.1" and
--   don't reimplement ldconfig probing each.
--
-- An earlier draft of this package re-probed the host with its own candidate
-- directory list, which is exactly the drift that rule exists to prevent: xim's
-- hostlib module documents four such copies, three of which were wrong, and
-- each was the same reasonable-looking mistake of assuming a directory layout
-- that FHS, Debian multiarch and Arch each answer differently.
--
-- So the edge is declared instead. `xpm.<platform>.deps` rather than the
-- package's own `[xlings]`, because mcpp materialises `[xlings] deps` for the
-- ROOT project only and this must resolve when the package itself installs.
--
-- ⭐ ONLY libcuda.so.1 IS LINKED, and that is a measured claim rather than a
-- minimal-effort one. A draft also harvested libnvidia-ptxjitcompiler on the
-- theory that PTX JIT would otherwise fail. Measured on a machine with driver
-- 550.144.03: a binary built for `compute_80` alone, run with only this one
-- symlink reachable, JITs and produces the right answer on an sm_89 device.
-- The driver loads its own siblings through its own paths, which the private
-- loader does not interfere with. The extra patterns were unnecessary.
--
-- NOTHING IS REQUIRED. A machine with no NVIDIA driver is a legitimate
-- configuration -- every runner in this repository is one. The sentinel's
-- symlink is then dangling, the farm links a dead entry, and a program that
-- needs a device reports that itself.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "cuda-runtime",
    description = "Host NVIDIA driver runtime adapter for mcpp Linux applications",
    licenses    = {"Apache-2.0"},  -- the recipe; libcuda.so.1 itself is NVIDIA's
    repo        = "https://github.com/openxlings/xim-pkgindex",
    type        = "package",

    xpm = {
        linux = {
            -- The install-time edge. Materialised when THIS package installs,
            -- which is what makes the sentinel's directory exist by the time
            -- install() below reads it.
            deps = { "xim:libcuda-host-link@0.0.1" },
            ["2026.09.05"] = {
                -- Nothing downloaded matters: the content is the symlink this
                -- install() creates. A stable, tiny anchor keeps the xpm entry
                -- well-formed, the same trick compat.vulkan-runtime uses.
                url    = "https://raw.githubusercontent.com/NVIDIA/cuda-samples/v12.5/LICENSE",
                sha256 = "b3e40c5bfed1fca5c62d2c1f2208bf51f8d2c910219f94c443f657ace9001be3",
            },
            ["latest"] = { ref = "2026.09.05" },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        c_standard   = "c11",
        sources      = { "mcpp_generated/cuda_runtime_empty.c" },
        targets      = { ["cuda_runtime"] = { kind = "lib" } },
        deps         = {},
        runtime = {
            library_dirs = { "mcpp_generated/cuda_runtime/lib" },
            capabilities = { "cuda.driver" },
            provides     = { "cuda.driver" },
        },
    },
}

import("xim.libxpkg.pkginfo")
import("xim.libxpkg.log")

-- The sentinel's install directory.
--
-- `pkginfo.install_dir` scans only the member-local xpkgs roots; a dependency
-- installed into the shared registry cache is invisible to it and comes back
-- nil, so the known roots are tried before giving up. This is the same fallback
-- compat.mysql-connector-cpp needs for the same reason.
local function sentinel_dir()
    local dir = pkginfo.install_dir("xim:libcuda-host-link", "0.0.1")
    if dir then return dir end
    local roots = {}
    local pfx = pkginfo.install_dir()
    if pfx then roots[#roots + 1] = path.directory(path.directory(pfx)) end
    local home = (os.getenv and os.getenv("XLINGS_HOME")) or ""
    if home == "" then home = ((os.getenv and os.getenv("HOME")) or "") .. "/.xlings" end
    roots[#roots + 1] = path.join(home, "data/xpkgs")
    for _, root in ipairs(roots) do
        local cand = path.join(root, "xim-x-libcuda-host-link", "0.0.1")
        if os.isdir(cand) then return cand end
    end
    return nil
end

function install()
    os.tryrm(pkginfo.install_dir())
    os.mkdir(pkginfo.install_dir())

    local generated = path.join(pkginfo.install_dir(), "mcpp_generated")
    os.mkdir(generated)
    io.writefile(path.join(generated, "cuda_runtime_empty.c"),
        "int mcpp_compat_cuda_runtime_anchor(void) { return 0; }\n")

    local outdir = path.join(generated, "cuda_runtime", "lib")
    os.mkdir(outdir)

    local src = sentinel_dir()
    if not src then
        -- Reported, not fatal. The farm is empty, the link still succeeds, and
        -- a program that needs a device says so itself -- which is the same
        -- answer a machine with no driver gives.
        log.warn("compat.cuda-runtime: libcuda-host-link not found; "
                 .. "the runtime library directory will be empty")
        return true
    end

    -- Only the versioned soname. mcpp puts runtime.library_dirs on the LINK
    -- line as well as the runtime path, so an unversioned libcuda.so here would
    -- be picked up by -lcuda and bind a build to one machine's driver. A
    -- versioned soname is invisible to the linker and is exactly what dlopen
    -- asks for.
    os.exec("ln -sf " .. path.join(src, "lib", "libcuda.so.1") .. " "
            .. path.join(outdir, "libcuda.so.1"))
    return true
end
