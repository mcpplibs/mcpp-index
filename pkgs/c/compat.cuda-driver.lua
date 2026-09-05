-- compat.cuda-driver — put the host NVIDIA driver on an mcpp binary's
-- runtime search path.
--
-- THE NAME IS THE CORRECTION. This package shipped once as
-- `compat.cuda-runtime`, and in NVIDIA's vocabulary "CUDA Runtime" is
-- `libcudart` — a redistributable library that a project links, and that
-- `xim:cuda-cudart` already delivers as a payload. What this package farms is
-- `libcuda.so.1`, the DRIVER's userspace library, which is neither
-- redistributable nor a payload. Its own `capabilities` and `provides` said
-- `cuda.driver` from the first version; only the package name disagreed.
--
-- `compat.cuda-runtime@2026.09.05` still resolves and still installs the same
-- farm, so nothing that already depends on it breaks. New versions appear only
-- here.
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
    name        = "cuda-driver",
    description = "Host NVIDIA driver adapter: reach libcuda.so.1 from an mcpp binary",
    licenses    = {"Apache-2.0"},  -- the recipe; libcuda.so.1 itself is NVIDIA's
    -- The upstream of the thing being ADAPTED, as the two sibling adapters do
    -- (compat.vulkan-runtime names Vulkan-Loader, compat.glx-runtime names
    -- OpenGL-Registry). The earlier value named `openxlings/xim-pkgindex`,
    -- which is where the sentinel package that finds the driver lives, not the
    -- driver. NVIDIA publishes no repository for the userspace driver; the
    -- kernel modules it is versioned in lockstep with are the closest upstream
    -- that exists and can be checked.
    repo        = "https://github.com/NVIDIA/open-gpu-kernel-modules",
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
        sources      = { "mcpp_generated/cuda_driver_empty.c" },
        targets      = { ["cuda_driver"] = { kind = "lib" } },
        deps         = {},
        runtime = {
            library_dirs = { "mcpp_generated/cuda_driver/lib" },
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
    io.writefile(path.join(generated, "cuda_driver_empty.c"),
        "int mcpp_compat_cuda_driver_anchor(void) { return 0; }\n")

    local outdir = path.join(generated, "cuda_driver", "lib")
    os.mkdir(outdir)

    local src = sentinel_dir()
    if not src then
        -- Reported, not fatal. The farm is empty, the link still succeeds, and
        -- a program that needs a device says so itself -- which is the same
        -- answer a machine with no driver gives.
        log.warn("compat.cuda-driver: libcuda-host-link not found; "
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
