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
-- ⭐ THE FARM MIRRORS THE SENTINEL; IT DOES NOT HOLD AN OPINION.
--
-- This package used to name `libcuda.so.1` and link that one file. It now
-- links every versioned soname the sentinel publishes, which is the same
-- delegation the paragraph above describes carried one step further: "where is
-- the driver" and "which driver libraries are there" are one question, and a
-- farm that answers the second one itself can disagree with the package that
-- answers the first. It did: the sentinel gained NVML for mcpp#596 and a
-- hand-written farm would not have noticed.
--
-- The negative result that used to live here has moved to the sentinel, where
-- it decides the set: a draft harvested libnvidia-ptxjitcompiler on the theory
-- that PTX JIT would otherwise fail, and measurement on driver 550.144.03
-- showed it unnecessary. That is a fact about which libraries a client needs,
-- so it belongs beside the list rather than beside one consumer of it.
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
            -- 0.0.2 is the version at which the sentinel answers for a SET of
            -- driver sonames rather than for `libcuda.so.1` alone. This pin is
            -- the only place that decides which of them a consumer gets: the
            -- farm below links whatever the pinned sentinel published.
            deps = { "xim:libcuda-host-link@0.0.2" },
            ["2026.09.10"] = {
                url    = "https://raw.githubusercontent.com/NVIDIA/cuda-samples/v12.5/LICENSE",
                sha256 = "b3e40c5bfed1fca5c62d2c1f2208bf51f8d2c910219f94c443f657ace9001be3",
            },
            ["2026.09.05"] = {
                -- Nothing downloaded matters: the content is the symlink this
                -- install() creates. A stable, tiny anchor keeps the xpm entry
                -- well-formed, the same trick compat.vulkan-runtime uses.
                url    = "https://raw.githubusercontent.com/NVIDIA/cuda-samples/v12.5/LICENSE",
                sha256 = "b3e40c5bfed1fca5c62d2c1f2208bf51f8d2c910219f94c443f657ace9001be3",
            },
            -- 2026.09.05 is kept so a consumer already pinning it keeps
            -- resolving. WHAT IS FROZEN IS THE ENTRY, NOT THE BEHAVIOUR: there
            -- is one install() here and it never reads pkginfo.version(), so an
            -- old pin installed today builds the current farm. The new key
            -- exists for the machine that already holds the directory and
            -- would otherwise never reinstall -- which is the whole of what a
            -- version buys for a package whose content is generated.
            ["latest"] = { ref = "2026.09.10" },
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
-- The version this package asks the sentinel for. One spelling, because the
-- xpm dependency edge and the directory read back must name the same thing or
-- the farm silently mirrors an older sentinel than the one that was installed.
local SENTINEL_VERSION = "0.0.2"

local function sentinel_dir()
    local dir = pkginfo.install_dir("xim:libcuda-host-link", SENTINEL_VERSION)
    if dir then return dir end
    local roots = {}
    local pfx = pkginfo.install_dir()
    if pfx then roots[#roots + 1] = path.directory(path.directory(pfx)) end
    local home = (os.getenv and os.getenv("XLINGS_HOME")) or ""
    if home == "" then home = ((os.getenv and os.getenv("HOME")) or "") .. "/.xlings" end
    roots[#roots + 1] = path.join(home, "data/xpkgs")
    roots[#roots + 1] = path.join((os.getenv and os.getenv("HOME")) or "",
                                  ".mcpp/registry/data/xpkgs")
    for _, root in ipairs(roots) do
        local cand = path.join(root, "xim-x-libcuda-host-link", SENTINEL_VERSION)
        if os.isdir(cand) then return cand end
    end
    return nil
end

-- Link every versioned soname the sentinel publishes into DST.
--
-- ENUMERATED, NOT NAMED, for the reason the header records. Returns the count,
-- which the caller logs: a farm of zero and a farm that was never built read
-- the same in a scrolled log otherwise.
--
-- ONLY VERSIONED SONAMES. mcpp puts runtime.library_dirs on the LINK line as
-- well as the runtime path, so an unversioned `libcuda.so` here would be found
-- by `-lcuda` and would bind the build to one machine's driver. A versioned
-- soname is invisible to the linker and is exactly what dlopen asks for. The
-- sentinel publishes only versioned names today; the filter states the
-- requirement rather than trusting that it stays true.
--
-- `io.popen` rather than `os.files`: the latter is not available in the recipe
-- sandbox, which the llvm and cuda-cccl recipes record the same way.
local function farm_sentinel(dst, src)
    local n = 0
    local p = io.popen(string.format([[ls -1 "%s" 2>/dev/null]],
                                     path.join(src, "lib")))
    if not p then return 0 end
    for line in p:lines() do
        local name = line:gsub("[\r\n]+$", "")
        if name:match("%.so%.%d") then
            os.exec(string.format([[ln -sfn "%s" "%s"]],
                                  path.join(src, "lib", name),
                                  path.join(dst, name)))
            n = n + 1
        end
    end
    p:close()
    return n
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

    local n = farm_sentinel(outdir, src)
    if n == 0 then
        log.warn("compat.cuda-driver: the sentinel at %s published no versioned "
                 .. "soname; the runtime library directory is empty", src)
        return true
    end
    log.info("compat.cuda-driver: %d driver soname(s) from %s", n, src)
    return true
end
