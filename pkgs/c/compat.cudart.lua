-- compat.cudart — the CUDA Runtime library, as an ordinary mcpp dependency.
--
-- `libcudart` is the redistributable half of CUDA: the API a host program calls
-- (`cudaMalloc`, `cudaMemcpy`, kernel launches) and the layer every CUDA
-- library is built on. It is a PAYLOAD, so `xim:cuda-cudart` carries it and
-- this package only says how to build against it.
--
-- ⚠️ NOT `compat.cuda-driver`, and the distinction is the reason that package
-- was renamed. The driver's `libcuda.so.1` cannot be redistributed and must
-- match the kernel module on the machine; the runtime can be redistributed and
-- is chosen by the project. A CUDA program needs both, and gets them from two
-- packages because they answer to two different owners.
--
-- WHY THE FILES ARE LINKED RATHER THAN NAMED IN PLACE. mcpp resolves a
-- package's `include_dirs` and `-L` inside the package's own directory, and a
-- path that reaches out of it would make the package's identity depend on a
-- payload's location. install() therefore builds a directory of symlinks, the
-- same shape `compat.cuda-driver` uses for the driver: one copy on disk, and
-- every path this descriptor states is its own.
--
-- THE 12.x LINE IS WHAT THIS VERSION CARRIES. A CUDA runtime must not be newer
-- than the driver it will meet, and the 12.x line reaches every driver from
-- r525 onward. `xpm.<platform>.deps` is read at the OS level rather than per
-- version, so a descriptor names ONE payload line; the 13.x line is a second
-- descriptor when the ecosystem's drivers reach it.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "cudart",
    description = "CUDA Runtime (libcudart) from the xim payload, as an mcpp dependency",
    licenses    = {"CUDA Toolkit"},
    repo        = "https://developer.download.nvidia.com/compute/cuda/redist",
    type        = "package",

    xpm = {
        linux = {
            -- The install-time edge: materialised when THIS package installs,
            -- which is what makes the payload directory exist by the time
            -- install() below reads it.
            -- TWO payloads, and the second is upstream's doing. `cuda_runtime.h`
            -- opens with `#include "crt/host_config.h"`, and on the 12.x line
            -- `crt/` is not in `cuda_cudart` — it is inside `cuda_nvcc`, whose
            -- archive is the compiler. A host program that only calls the
            -- runtime API still needs that header, so the component that holds
            -- it is a dependency of this adapter rather than of its consumers.
            -- (The 13.x line moved `crt/` to its own `cuda_crt` component; a
            -- descriptor for that line names that instead.)
            deps = { "xim:cuda-cudart@12.9.79", "xim:cuda-nvcc@12.9.86" },
            ["12.9.79"] = {
                -- Nothing downloaded matters; the content is the symlink farm
                -- install() builds. A stable, tiny anchor keeps the xpm entry
                -- well-formed, the same trick compat.cuda-driver uses.
                url    = "https://raw.githubusercontent.com/NVIDIA/cuda-samples/v12.5/LICENSE",
                sha256 = "b3e40c5bfed1fca5c62d2c1f2208bf51f8d2c910219f94c443f657ace9001be3",
            },
            ["latest"] = { ref = "12.9.79" },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        c_standard   = "c11",
        sources      = { "mcpp_generated/cudart_anchor.c" },
        targets      = { ["cudart"] = { kind = "lib" } },
        include_dirs = { "mcpp_generated/cudart/include" },
        deps         = {},
        linux = { ldflags = { "-Lmcpp_generated/cudart/lib", "-lcudart" } },
        runtime = {
            library_dirs = { "mcpp_generated/cudart/lib" },
            capabilities = { "cuda.runtime" },
            provides     = { "cuda.runtime" },
        },
    },
}

import("xim.libxpkg.pkginfo")
import("xim.libxpkg.log")

-- The payload's install directory.
--
-- `pkginfo.install_dir` scans only the member-local xpkgs roots; a dependency
-- installed into the shared registry cache is invisible to it and comes back
-- nil, so the known roots are tried before giving up. This is the same fallback
-- compat.cuda-driver needs for the same reason.
local function payload_dir(coord, name, version)
    local dir = pkginfo.install_dir(coord, version)
    if dir then return dir end
    local roots = {}
    local pfx = pkginfo.install_dir()
    if pfx then roots[#roots + 1] = path.directory(path.directory(pfx)) end
    local home = (os.getenv and os.getenv("XLINGS_HOME")) or ""
    if home == "" then home = ((os.getenv and os.getenv("HOME")) or "") .. "/.xlings" end
    roots[#roots + 1] = path.join(home, "data/xpkgs")
    for _, root in ipairs(roots) do
        local cand = path.join(root, "xim-x-" .. name, version)
        if os.isdir(cand) then return cand end
    end
    return nil
end

-- Link every entry of the payload's `include/` and `lib/` into a directory this
-- package owns. `ln -sfn` through the shell rather than `os.ln`, which the
-- recipe sandbox does not expose.
local function farm(src, dst, patterns)
    os.mkdir(dst)
    local n = 0
    for _, pat in ipairs(patterns) do
        local f = io.popen(string.format([[find "%s" -maxdepth 1 -name '%s' 2>/dev/null]],
                                         src, pat))
        if f then
            for line in f:lines() do
                local full = line:gsub("[\r\n]+$", "")
                if full ~= "" then
                    os.exec(string.format([[ln -sfn "%s" "%s"]],
                                          full, path.join(dst, path.filename(full))))
                    n = n + 1
                end
            end
            f:close()
        end
    end
    return n
end

-- ⚠️⚠️ THE C LIBRARY'S COMPATIBILITY STUBS HAVE TO BE FARMED TOO.
--
-- NVIDIA's shared objects carry `RUNPATH = $ORIGIN`, and a non-empty RUNPATH on
-- an intermediate library TURNS OFF the executable's inherited DT_RPATH for
-- that library's own dependencies (mcpp#460). So the artifact's search path,
-- which reaches mcpp's glibc payload, is not consulted when the loader looks
-- for what `libcurand.so.10` needs, and the program dies before `main`:
--
--   error while loading shared libraries: librt.so.1: cannot open shared
--   object file: No such file or directory
--
-- ⭐ `$ORIGIN` IS THE SYMLINK'S DIRECTORY, NOT THE TARGET'S. Measured: linking
-- the three stubs into this farm beside the component's own symlinks makes the
-- program load and run. That is what makes a farm of links sufficient here and
-- a copy of the payload unnecessary.
--
-- Only the libraries glibc 2.34 MERGED INTO libc are farmed. They are empty
-- compatibility stubs, so which payload version answers does not matter, and
-- nothing else is loading them: `libc.so.6`, `libm.so.6` and `libstdc++.so.6`
-- are already loaded on the executable's own behalf by the time the component
-- asks, and are found by soname without a search. Farming those would risk a
-- second copy of the C library in one address space, which is the one failure
-- worse than this one.
local function farm_libc_stubs(dst)
    local names = { "librt.so.1", "libpthread.so.0", "libdl.so.2" }
    local roots = {}
    local pfx = pkginfo.install_dir()
    if pfx then roots[#roots + 1] = path.directory(path.directory(pfx)) end
    local home = (os.getenv and os.getenv("XLINGS_HOME")) or ""
    if home == "" then home = ((os.getenv and os.getenv("HOME")) or "") .. "/.xlings" end
    roots[#roots + 1] = path.join(home, "data/xpkgs")
    roots[#roots + 1] = path.join((os.getenv and os.getenv("HOME")) or "",
                                 ".mcpp/registry/data/xpkgs")
    local found = 0
    for _, name in ipairs(names) do
        if not os.isfile(path.join(dst, name)) then
            for _, root in ipairs(roots) do
                local f = io.popen(string.format(
                    [[ls -1d "%s"/xim-x-glibc/*/lib64/%s 2>/dev/null | sort -V | tail -1]],
                    root, name))
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
    return found
end

function install()
    os.tryrm(pkginfo.install_dir())
    os.mkdir(pkginfo.install_dir())

    local generated = path.join(pkginfo.install_dir(), "mcpp_generated")
    os.mkdir(generated)
    io.writefile(path.join(generated, "cudart_anchor.c"),
        "int mcpp_compat_cudart_anchor(void) { return 0; }\n")

    local src = payload_dir("xim:cuda-cudart", "cuda-cudart", "12.9.79")
    if not src then
        error("compat.cudart: xim:cuda-cudart@12.9.79 was not found; the payload "
              .. "edge in xpm.linux.deps should have installed it")
    end

    local root = path.join(generated, "cudart")
    -- Headers: the whole set, because cuda_runtime.h includes a dozen siblings.
    -- Libraries: the shared objects only. The static archives are in the
    -- payload for a project that wants a self-contained artifact, and reaching
    -- them is that project's decision to make on its own link line, not a farm
    -- entry that `-lcudart` would silently prefer.
    local nh = farm(path.join(src, "include"), path.join(root, "include"), { "*" })

    -- `crt/` from the compiler component, linked as a whole directory: it is a
    -- directory of headers that `cuda_runtime.h` addresses by relative path, so
    -- it has to appear under the same include root.
    local crtsrc = payload_dir("xim:cuda-nvcc", "cuda-nvcc", "12.9.86")
    if not crtsrc or not os.isdir(path.join(crtsrc, "include", "crt")) then
        error("compat.cudart: xim:cuda-nvcc@12.9.86 carries include/crt and it was not "
              .. "found; cuda_runtime.h cannot be included without it")
    end
    os.exec(string.format([[ln -sfn "%s" "%s"]],
                          path.join(crtsrc, "include", "crt"),
                          path.join(root, "include", "crt")))
    local nl = farm(path.join(src, "lib"), path.join(root, "lib"), { "*.so", "*.so.*" })
    local ns = farm_libc_stubs(path.join(root, "lib"))
    if nh == 0 or nl == 0 then
        error(string.format("compat.cudart: the payload at %s carries %d headers and "
                            .. "%d shared libraries; both must be non-zero", src, nh, nl))
    end
    log.info("compat.cudart: %d headers, %d libraries, %d C-library stubs from %s",
             nh, nl, ns, src)
    return true
end
