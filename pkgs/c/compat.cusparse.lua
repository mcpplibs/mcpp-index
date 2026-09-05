-- compat.cusparse — the CUDA cuSPARSE, as an ordinary mcpp dependency.
--
-- cuSPARSE: sparse linear algebra on the device. It is a redistributable component, so `xim:libcusparse` carries the
-- payload and this package only says how to build against it.
--
-- WHY THE FILES ARE LINKED RATHER THAN NAMED IN PLACE. mcpp resolves a
-- package's `include_dirs` and `-L` inside the package's own directory, and a
-- path that reaches out of it would make the package's identity depend on a
-- payload's location. install() therefore builds a directory of symlinks, the
-- same shape `compat.cudart` and `compat.cuda-driver` use.
--
-- WHAT A CONSUMER STILL NEEDS. This library calls the CUDA Runtime and, through
-- it, the driver, so `compat.cudart` is a dependency here and
-- `compat.cuda-driver` is what a consumer adds to reach the host's
-- `libcuda.so.1`. Declaring the three separately is what keeps each one
-- answerable to its own owner: the payload is the project's choice, the driver
-- is the machine's.
--
-- THE 12.x LINE IS WHAT THIS VERSION CARRIES, for the reason `compat.cudart`
-- states: a device runtime must not be newer than the driver it meets, and
-- `xpm.<platform>.deps` is read at the OS level rather than per version, so a
-- descriptor names one payload line.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "cusparse",
    description = "cuSPARSE: sparse linear algebra on the device (from the xim payload)",
    licenses    = {"CUDA Toolkit"},
    repo        = "https://developer.download.nvidia.com/compute/cuda/redist",
    type        = "package",

    xpm = {
        linux = {
            deps = { "xim:libcusparse@12.5.10.65" },
            ["12.5.10.65"] = {
                -- Nothing downloaded matters; the content is the symlink farm
                -- install() builds. A stable, tiny anchor keeps the xpm entry
                -- well-formed, the same trick compat.cuda-driver uses.
                url    = "https://raw.githubusercontent.com/NVIDIA/cuda-samples/v12.5/LICENSE",
                sha256 = "b3e40c5bfed1fca5c62d2c1f2208bf51f8d2c910219f94c443f657ace9001be3",
            },
            ["latest"] = { ref = "12.5.10.65" },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        c_standard   = "c11",
        sources      = { "mcpp_generated/cusparse_anchor.c" },
        targets      = { ["cusparse"] = { kind = "lib" } },
        include_dirs = { "mcpp_generated/cusparse/include" },
        deps         = { ["compat.cudart"] = "12.9.79" },
        linux = { ldflags = { "-Lmcpp_generated/cusparse/lib", "-lcusparse" } },
        runtime = {
            library_dirs = { "mcpp_generated/cusparse/lib" },
            capabilities = { "cuda.cusparse" },
            provides     = { "cuda.cusparse" },
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

-- Link every matching entry of a payload directory into one this package owns.
-- `ln -sfn` through the shell rather than `os.ln`, which the recipe sandbox
-- does not expose.
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
    io.writefile(path.join(generated, "cusparse_anchor.c"),
        "int mcpp_compat_cusparse_anchor(void) { return 0; }\n")

    local src = payload_dir("xim:libcusparse", "libcusparse", "12.5.10.65")
    if not src then
        error("compat.cusparse: xim:libcusparse@12.5.10.65 was not found; the payload edge in "
              .. "xpm.linux.deps should have installed it")
    end

    local root = path.join(generated, "cusparse")
    -- Headers: the whole set. Libraries: the shared objects only -- the static
    -- archives are in the payload for a project that wants a self-contained
    -- artifact, and reaching them is that project's decision to make on its own
    -- link line, not a farm entry that `-lcusparse` would silently prefer.
    local nh = farm(path.join(src, "include"), path.join(root, "include"), { "*" })
    local nl = farm(path.join(src, "lib"), path.join(root, "lib"), { "*.so", "*.so.*" })
    local ns = farm_libc_stubs(path.join(root, "lib"))
    if nh == 0 or nl == 0 then
        error(string.format("compat.cusparse: the payload at %s carries %d headers and %d "
                            .. "shared libraries; both must be non-zero", src, nh, nl))
    end
    log.info("compat.cusparse: %d headers, %d libraries, %d C-library stubs from %s",
             nh, nl, ns, src)
    return true
end
