-- compat.vulkan-runtime — host Vulkan ICD adapter for mcpp Linux applications.
--
-- The exact counterpart of `compat.glx-runtime`, for the same reason and in the
-- same shape. A PROPRIETARY driver cannot be a package: its userspace is in ABI
-- lockstep with a kernel module and its licence forbids redistribution, so the
-- GL runtime plan (.agents/docs/2026-06-03-gl-runtime-packages-plan.md) settled
-- on modelling that as a HOST CAPABILITY. An open driver is a payload --
-- `xim:mesa-lavapipe` for the CPU, `xim:mesa` for AMD hardware -- and a machine
-- using one needs nothing from this farm at all. Nothing is vendored here; this
-- is a symlink farm plus the metadata that makes it reachable, and since
-- 2026.09.05 every farmed library a published payload also provides is taken
-- from the payload when the payload's symbol set covers the host copy's, so the
-- host surface it records is proprietary userspace and packaging backlog only.
--
-- WHAT IT FIXES. `compat.vulkan` builds the Khronos loader, and the loader finds
-- every ICD manifest on the host correctly. It then fails to dlopen a single
-- driver:
--
--   DRIVER: Found the following files: /usr/share/vulkan/icd.d/lvp_icd.json …
--   ERROR: libvulkan_lvp.so: cannot open shared object file
--
-- The libraries are right there in /usr/lib/x86_64-linux-gnu. What cannot reach
-- them is the process: an mcpp-built binary runs under mcpp's OWN glibc
--
--   interp: …/xpkgs/xim-x-glibc/2.39/lib64/ld-linux-x86-64.so.2
--   rpath : …/xim-x-glibc/2.39/lib64:…/xim-x-gcc/…/lib64:$ORIGIN
--
-- so a bare-soname dlopen from inside the sandbox does not search the host's
-- library path at all. `runtime.library_dirs` below puts a package-owned
-- directory of symlinks on that path, which is precisely how `compat.glx-runtime`
-- makes host OpenGL work — and why the OpenGL backends already run while Vulkan
-- did not.
--
-- THE PATTERN LIST covers the ICDs plus their transitive dependencies, because
-- the whole chain has to resolve through the same directory. Mesa's software
-- rasterizer pulls LLVM; NVIDIA pulls its own family. `libstdc++` is in the list
-- and that is not an oversight: mcpp links libstdc++ STATICALLY (it is absent
-- from a built binary's NEEDED), so a dlopen'd C++ ICD like lavapipe has nothing
-- to resolve against unless the host copy is provided here.
--
-- NOTHING IS REQUIRED. Unlike `compat.glx-runtime`, which errors when libGL is
-- missing, a machine with no Vulkan driver at all is a legitimate configuration
-- — every CI runner in this repo is one. The farm is then simply empty and the
-- loader reports its own four extensions, which is what
-- `tests/examples/vulkan` asserts.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "vulkan-runtime",
    description = "Host Vulkan ICD runtime adapter for mcpp Linux applications",
    licenses    = {"Apache-2.0"},
    repo        = "https://github.com/KhronosGroup/Vulkan-Loader",
    type        = "package",

    xpm = {
        linux = {
            -- PLATFORM LEVEL, NOT PER VERSION. A `deps` inside a version entry
            -- parses and is then not applied; compat.glx-runtime records the
            -- measurement. The cost of that placement is that a consumer still
            -- pinned to 2026.07.29 or 2026.09.05 also installs these, which is
            -- a download it will not read and not a failure.
            --
            -- These are the packages whose sonames the farm substitutes for a
            -- host copy, and the PAYLOAD_PACKAGES table below is the reader
            -- that keeps the two lists honest: a soname it maps to a package
            -- that is not installed is reported as a declaration that did not
            -- take effect, rather than silently farmed from the host.
            --
            -- Floors, not pins. Every library here is ABI-stable at the soname
            -- this farm asks for, and a pin would make one patch bump an edit
            -- in this file.
            deps = {
                runtime = {
                    "xim:zlib@>=1.3", "xim:expat@>=2.6", "xim:libffi@>=3.4",
                    "xim:elfutils@>=0.19", "xim:libdrm@>=2.4",
                    "xim:libxcb@>=1.17", "xim:libX11@>=1.8",
                    "xim:libXau@>=1.0", "xim:libXdmcp@>=1.1",
                    "xim:libXext@>=1.3", "xim:libxshmfence@>=1.3",
                    "xim:wayland@>=1.23", "xim:gcc-runtime@>=15",
                    "xim:ncurses@>=6.5", "xim:zstd@>=1.5", "xim:xz@>=5.8",
                    "xim:libmd@>=1.2", "xim:libbsd@>=0.12",
                },
            },
            -- 2026.09.05: the farm is seeded from the ICD manifests, closes
            -- over what they need, prefers installed payloads over host copies
            -- they cover, and records the surface in HOST-SURFACE.txt. mcpp
            -- identifies an installed package by (name, version), so the new
            -- behaviour needs a new key; the anchor is the same file.
            ["latest"] = { ref = "2026.09.06" },
            -- 2026.09.06: the payload set is DECLARED here rather than
            -- discovered. Until this version the substitution pass took a
            -- payload only when some earlier, unrelated install had already
            -- put it in the store, so the same package produced a farm of
            -- twenty payload libraries on a developer machine and a farm of
            -- one in a fresh subos -- the environment decided, and the report
            -- read "no installed payload provides this soname" for sonames
            -- this index does publish. Measured 2026-09-05 in a fresh subos:
            -- 30 host entries against 8 on the machine that happened to have
            -- the stack installed.
            --
            -- WHAT IS NOT HERE AND WHY. `xim:icu` (78) and `xim:libedit` (0)
            -- carry different sonames than the ones a host Mesa built against
            -- Ubuntu 24.04 asks for (`libicuuc.so.74`, `libedit.so.2`); a
            -- different soname is a different ABI, so those two cannot
            -- substitute anything here and would only be a download. Same for
            -- `xim:libllvm` and `xim:libxml2`, whose payloads the symbol test
            -- rejects (12215 and 195 symbols short of the host copies).
            ["2026.09.06"] = {
                url    = "https://raw.githubusercontent.com/KhronosGroup/Vulkan-Loader/vulkan-sdk-1.4.357.0/README.md",
                sha256 = "21ec0987a05bd680ecd11f8be747e27744d7558f7318736f6cb8a5c5ec1b8ba8",
            },
            ["2026.09.05"] = {
                url    = "https://raw.githubusercontent.com/KhronosGroup/Vulkan-Loader/vulkan-sdk-1.4.357.0/README.md",
                sha256 = "21ec0987a05bd680ecd11f8be747e27744d7558f7318736f6cb8a5c5ec1b8ba8",
            },
            ["2026.07.29"] = {
                -- Nothing is downloaded that matters: the package's content is
                -- the symlink farm install() builds from the host. This is just
                -- a stable, tiny anchor so the xpm entry is well-formed, the
                -- same trick compat.glx-runtime uses with an OpenGL-Registry
                -- README.
                url    = "https://raw.githubusercontent.com/KhronosGroup/Vulkan-Loader/vulkan-sdk-1.4.357.0/README.md",
                sha256 = "21ec0987a05bd680ecd11f8be747e27744d7558f7318736f6cb8a5c5ec1b8ba8",
            },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        c_standard   = "c11",
        sources      = { "mcpp_generated/vulkan_runtime_empty.c" },
        targets      = { ["vulkan_runtime"] = { kind = "lib" } },
        deps         = {},
        runtime = {
            library_dirs = { "mcpp_generated/vulkan_runtime/lib" },
            capabilities = { "vulkan.icd.driver" },
            provides     = { "vulkan.icd.driver" },
        },
    },
}

import("xim.libxpkg.pkginfo")
import("xim.libxpkg.log")

local function sh_quote(value)
    return "'" .. tostring(value):gsub("'", "'\\''") .. "'"
end

local function split_paths(value)
    local out = {}
    if not value or value == "" then
        return out
    end
    for item in tostring(value):gmatch("[^:]+") do
        if item ~= "" then
            table.insert(out, item)
        end
    end
    return out
end

local function candidate_dirs()
    local out = {}
    local seen = {}
    local function add(dir)
        if dir and dir ~= "" and not seen[dir] and os.isdir(dir) then
            seen[dir] = true
            table.insert(out, dir)
        end
    end

    for _, dir in ipairs(split_paths(os.getenv("MCPP_HOST_VULKAN_LIBRARY_PATH"))) do
        add(dir)
    end
    add("/lib/x86_64-linux-gnu")
    add("/usr/lib/x86_64-linux-gnu")
    -- The same layout on the other Linux architecture this index builds for.
    -- Absent until 2026.09.06, which made the farm empty on a Debian-family
    -- aarch64 machine: every candidate directory was an x86_64 one and
    -- `os.isdir` skipped them all.
    add("/lib/aarch64-linux-gnu")
    add("/usr/lib/aarch64-linux-gnu")
    add("/lib64")
    add("/usr/lib64")
    add("/usr/lib")
    return out
end

-- WHAT IS FARMED BY PATTERN: PROPRIETARY VENDOR USERSPACE ONLY.
--
-- Until 2026.09.05 this list also named the X client stack, libdrm, LLVM,
-- zlib, zstd, expat, libxml2, libffi, libedit, ICU and libstdc++, and harvested
-- every host copy the candidate directories held -- five LLVM versions and the
-- driver's settings GUI among them. None of that belongs on a program's
-- runtime path: what an ICD needs is computed below by closing over the
-- manifests' libraries with `ldd`, and a library a published payload also
-- provides is then taken from the payload when it covers the host copy.
--
-- The vendor family stays a pattern because a proprietary driver dlopens
-- members of its own family by name at run time (`libnvidia-glvkspirv`,
-- `libnvidia-gpucomp`), which no `DT_NEEDED` walk can see. Its settings GUI
-- (`libnvidia-gtk*`) is excluded: it is not part of any driver and would put a
-- host GTK on the path of every consumer.
--
-- EVERY PATTERN IS VERSIONED (`lib*.so.*`), deliberately. mcpp puts
-- `runtime.library_dirs` on the LINK line as well as the runtime path, so a
-- bare `libxcb.so` here would shadow this index's own `compat.xcb` at link
-- time. Versioned sonames are invisible to the linker and are exactly what
-- dlopen asks for.
--
-- The host's own `libvulkan.so*` is deliberately NOT harvested: `compat.vulkan`
-- builds the loader itself, as a shared object with the canonical
-- `libvulkan.so.1` soname, and a second one on the path would be resolved by
-- SDL2's `dlopen` instead. One loader per process is the whole point.
local host_vulkan_patterns = {
    "libGLX_nvidia.so.*",
    "libnvidia*.so.*",
}
local never_farm_patterns = { "^libnvidia%-gtk" }

-- THE DECLARATION'S READER. `xpm.linux.deps` above names the packages whose
-- libraries this farm substitutes; this table says which soname each one is
-- declared for. When a soname it maps is still taken from the host, the report
-- says the declaration did not take effect -- which is the only way a drift
-- between the two lists becomes visible, since a missing dependency otherwise
-- looks exactly like a machine that has no payload for it.
local PAYLOAD_PACKAGES = {
    ["libz.so.1"]             = "xim:zlib",
    ["libexpat.so.1"]         = "xim:expat",
    ["libffi.so.8"]           = "xim:libffi",
    ["libelf.so.1"]           = "xim:elfutils",
    ["libdrm.so.2"]           = "xim:libdrm",
    ["libxcb.so.1"]           = "xim:libxcb",
    ["libxcb-dri2.so.0"]      = "xim:libxcb",
    ["libxcb-dri3.so.0"]      = "xim:libxcb",
    ["libxcb-present.so.0"]   = "xim:libxcb",
    ["libxcb-randr.so.0"]     = "xim:libxcb",
    ["libxcb-shm.so.0"]       = "xim:libxcb",
    ["libxcb-sync.so.1"]      = "xim:libxcb",
    ["libxcb-xfixes.so.0"]    = "xim:libxcb",
    ["libX11.so.6"]           = "xim:libX11",
    ["libX11-xcb.so.1"]       = "xim:libX11",
    ["libXau.so.6"]           = "xim:libXau",
    ["libXdmcp.so.6"]         = "xim:libXdmcp",
    ["libXext.so.6"]          = "xim:libXext",
    ["libxshmfence.so.1"]     = "xim:libxshmfence",
    ["libwayland-client.so.0"]= "xim:wayland",
    ["libstdc++.so.6"]        = "xim:gcc-runtime",
    ["libtinfo.so.6"]         = "xim:ncurses",
    ["libzstd.so.1"]          = "xim:zstd",
    ["liblzma.so.5"]          = "xim:xz",
    ["libmd.so.0"]            = "xim:libmd",
    ["libbsd.so.0"]           = "xim:libbsd",
}

local never_farm = {
    ["libc.so.6"] = true, ["libm.so.6"] = true, ["libdl.so.2"] = true,
    ["libpthread.so.0"] = true, ["librt.so.1"] = true, ["libresolv.so.2"] = true,
    ["ld-linux-x86-64.so.2"] = true, ["ld-linux-aarch64.so.1"] = true,
    ["libgcc_s.so.1"] = true, ["libvulkan.so.1"] = true,
}

-- THE PATTERN LIST NAMES WHAT IS DLOPENED; THIS CLOSES WHAT IT NEEDS.
--
-- A hand-written list of transitive dependencies is a list someone has to keep
-- correct against libraries nobody in this repository builds, and the comment
-- above already says incomplete is worse than absent. Measured 2026-09-05:
-- every pattern above matched, `libvulkan_lvp.so` and `libLLVM.so.20.1` were
-- both in the farm, and the loader still reported
--
--   ERROR: libicuuc.so.74: cannot open shared object file
--   ERROR | DRIVER: loader_icd_scan: Failed loading library associated with
--                   ICD JSON libvulkan_lvp.so. Ignoring this JSON
--
-- so a machine with a software rasterizer installed enumerated no CPU device at
-- all. LLVM 20 links ICU; nothing in the list said so, and nothing could have
-- without someone reading LLVM's dependencies by hand.
--
-- `ldd` is asked instead, and it answers TRANSITIVELY, which is the property a
-- list cannot have. Its output feeds only symlink creation, so the farm keeps
-- the property the pattern list was written for: what `ldd` reports is a
-- `DT_NEEDED` soname, always versioned, so nothing this pass adds can shadow a
-- `libfoo.so` the linker resolves.
--
-- THE SEED IS THE ICD SET, NOT THE FARM. Closing over every file the pattern
-- list matched pulled 64 libraries here, GTK 2 and GTK 3 among them, because
-- `libnvidia*.so.*` also matches the driver's settings GUI. Those libraries are
-- on the consuming binary's runtime path, where a host GTK can shadow an index
-- package's; a driver the loader will never dlopen has no business putting it
-- there. The manifests state exactly which libraries the loader loads, so they
-- are what gets closed over.
--
-- THE `ldd` ON `PATH` IS NOT NECESSARILY THE HOST'S. Under xlings it is the
-- payload's own, and a private loader's default search path is its build prefix
-- rather than the host's — measured on one machine, in one shell, seconds apart:
--
--   $ ldd /usr/lib/x86_64-linux-gnu/libvulkan_lvp.so
--   libLLVM.so.20.1 => not found
--   $ /usr/bin/ldd /usr/lib/x86_64-linux-gnu/libvulkan_lvp.so
--   libLLVM.so.20.1 => /lib/x86_64-linux-gnu/libLLVM.so.20.1
--
-- The first spelling is not an error the pass can detect: every line reads
-- `not found`, the `=> /path` pattern matches nothing, and the pass reports
-- closing over zero libraries — the same reading it gives on a machine that
-- genuinely needs nothing. So the search path is supplied explicitly rather
-- than inherited, which makes the answer independent of which `ldd` runs.
local function icd_manifest_dirs()
    local out, seen = {}, {}
    local function add(dir)
        if dir and dir ~= "" and not seen[dir] and os.isdir(dir) then
            seen[dir] = true
            table.insert(out, dir)
        end
    end
    -- The loader's own order. `VK_DRIVER_FILES` is deliberately not consulted:
    -- it overrides the machine's drivers for one run, and this farm is built
    -- once, at install time, for every run afterwards.
    local data_home = os.getenv("XDG_DATA_HOME")
    if data_home and data_home ~= "" then
        add(path.join(data_home, "vulkan", "icd.d"))
    elseif os.getenv("HOME") then
        add(path.join(os.getenv("HOME"), ".local", "share", "vulkan", "icd.d"))
    end
    for _, base in ipairs(split_paths(os.getenv("XDG_DATA_DIRS"))) do
        add(path.join(base, "vulkan", "icd.d"))
    end
    add("/usr/local/share/vulkan/icd.d")
    add("/usr/share/vulkan/icd.d")
    add("/etc/vulkan/icd.d")
    return out
end

-- Every `library_path` an ICD manifest names, resolved the way the loader
-- resolves it: a path with a separator is relative to the manifest, a bare
-- soname is searched for.
local function icd_seed_libraries(dirs)
    local mdirs = icd_manifest_dirs()
    if #mdirs == 0 then return {} end
    local args = {}
    for _, d in ipairs(mdirs) do table.insert(args, sh_quote(d)) end
    local f = io.popen(
        "for d in " .. table.concat(args, " ") .. "; do " ..
        "for j in \"$d\"/*.json; do [ -e \"$j\" ] || continue; " ..
        "sed -n 's/.*\"library_path\"[[:space:]]*:[[:space:]]*\"\\([^\"]*\\)\".*/\\1/p' \"$j\" " ..
        "| head -1 | while read -r v; do printf '%s\\t%s\\n' \"$d\" \"$v\"; done; " ..
        "done; done")
    if not f then return {} end
    local seeds, seen = {}, {}
    for line in f:lines() do
        local dir, value = line:match("^([^\t]*)\t(.*)$")
        if value and value ~= "" then
            local candidates = {}
            if value:sub(1, 1) == "/" then
                table.insert(candidates, value)
            elseif value:find("/") then
                table.insert(candidates, path.join(dir, value))
            else
                for _, libdir in ipairs(dirs) do
                    table.insert(candidates, path.join(libdir, value))
                end
            end
            for _, c in ipairs(candidates) do
                if not seen[c] and os.isfile(c) then
                    seen[c] = true
                    table.insert(seeds, c)
                end
            end
        end
    end
    f:close()
    return seeds
end

local host_prefixes = {"/usr/", "/lib/", "/lib64/", "/opt/"}

local function close_over_needed(outdir, dirs)
    local seeds = icd_seed_libraries(dirs)
    if #seeds == 0 then return 0 end

    local accept = {}
    for _, dir in ipairs(dirs) do accept[dir] = true end
    local function is_host_library(full)
        local dir = full:match("^(.*)/[^/]+$")
        if dir and accept[dir] then return true end
        for _, prefix in ipairs(host_prefixes) do
            if full:sub(1, #prefix) == prefix then return true end
        end
        -- Anything else is a payload: mcpp's own C library and toolchain live
        -- under the user's home, and a second copy of either on this path is
        -- the one failure worse than a missing driver.
        return false
    end

    local args = {}
    for _, seed in ipairs(seeds) do table.insert(args, sh_quote(seed)) end
    -- One pass suffices: `ldd` reports the whole transitive closure of a file,
    -- not just its direct `DT_NEEDED` entries.
    local f = io.popen(string.format(
        [[for lib in %s; do LD_LIBRARY_PATH=%s ldd "$lib" 2>/dev/null; done ]] ..
        [[| sed -n 's/.*=> \(\/[^ ]*\).*/\1/p' | sort -u]],
        table.concat(args, " "), sh_quote(table.concat(dirs, ":"))))
    if not f then return 0 end
    local wanted = {}
    for line in f:lines() do
        local full = line:gsub("[\r\n]+$", "")
        if full ~= "" then wanted[#wanted + 1] = full end
    end
    f:close()

    local added = 0
    for _, full in ipairs(wanted) do
        local base = full:match("([^/]+)$")
        if base and not never_farm[base] and is_host_library(full)
           and not os.isfile(path.join(outdir, base)) then
            os.exec(string.format([[ln -sf "%s" "%s"]], full, path.join(outdir, base)))
            added = added + 1
        end
    end
    return added
end

-- WHAT THE FARM STILL TAKES FROM THE HOST, WRITTEN DOWN.
--
-- This package exists because a GPU driver cannot be a package, and that is
-- true of the driver. It is not true of `libxcb`, `libz` or `libxml2`, which
-- this index publishes and which the pattern list nonetheless harvests from
-- /usr/lib. The distinction was never recorded anywhere, so "how much of the
-- host does a Vulkan program still touch" could only be answered by reading
-- the list and guessing.
--
-- Three classes, and only the first is irreducible:
--
--   * PROPRIETARY VENDOR USERSPACE -- `libGLX_nvidia.so.*`, `libnvidia*.so.*`,
--     and `libcuda.so.1` alongside them. In ABI lockstep with a kernel module
--     and not redistributable, which is why the ecosystem LINKS them
--     (`xim:nvidia-gl-host-link`, `xim:libcuda-host-link`) and never copies.
--   * THE HOST MESA AND WHAT IT WAS LINKED AGAINST -- `libvulkan_*.so` and the
--     `libLLVM.so.20.1` whose soname names that build. Neither is irreducible:
--     Mesa is open source, `xim:mesa` builds it in a subos, and a machine
--     using the PAYLOAD driver has neither entry. The soname cannot be
--     substituted, so the answer is not to substitute it -- it is to stop
--     loading the host's Mesa, which is what `xim:mesa-lavapipe` already does
--     for the software driver and what extending `xim:mesa`'s driver set does
--     for AMD and Intel.
--   * EVERYTHING ELSE -- the X protocol stack, zlib, expat, libxml2, libffi,
--     libdrm, and the C++ runtime. Every one of these is, or should be, an xim
--     package; `libstdc++`/`libgcc_s` in particular are redistributable and
--     `xim:gcc-runtime` publishes them.
--
-- THE SUBSTITUTION IS DIRECTIONAL, NOT FORBIDDEN. A host ICD was linked
-- against the host's copies of the third class, so an OLDER package copy fails
-- as a missing symbol version at dlopen time; a NEWER one is what a
-- distribution upgrade does every day. What this farm does today is the
-- monotone half -- fill only what the host cannot resolve at all -- because the
-- version comparison that would license the rest has no reader here yet. The
-- entries it leaves on the host are recorded rather than accepted.
--
-- What IS done: a name the host cannot resolve at all is filled from the
-- store, which can only add resolutions. A container with an NVIDIA driver and
-- no X stack is the case this covers, and it used to fail with `libX11.so.6:
-- cannot open shared object file` naming nothing that could be installed.
--
-- And the surface is written to `HOST-SURFACE.txt` inside the package, so the
-- next round of packaging reads a measurement instead of this comment.
local function xim_store_roots()
    local roots = {}
    local home = (os.getenv and os.getenv("XLINGS_HOME")) or ""
    if home == "" then home = ((os.getenv and os.getenv("HOME")) or "") .. "/.xlings" end
    roots[#roots + 1] = path.join(home, "data/xpkgs")
    local pfx = pkginfo.install_dir()
    if pfx then roots[#roots + 1] = path.directory(path.directory(pfx)) end
    return roots
end

-- The sonames the seeds still cannot resolve with the farm in place.
local function unresolved_names(outdir, seeds, dirs)
    if #seeds == 0 then return {} end
    local args = {}
    for _, seed in ipairs(seeds) do table.insert(args, sh_quote(seed)) end
    local search = table.concat(dirs, ":")
    if outdir ~= "" then search = outdir .. ":" .. search end
    local f = io.popen(string.format(
        [[for lib in %s; do LD_LIBRARY_PATH=%s ldd "$lib" 2>/dev/null; done ]] ..
        -- No POSIX character class here: `[[:space:]]` contains `]]`, which
        -- ends a Lua long-bracket string. The file parsed as far as this line
        -- and then reported `unexpected symbol near '\'` two lines later.
        [[| sed -n 's/^[ \t]*\([^ \t]*\) => not found.*/\1/p' | sort -u]],
        table.concat(args, " "), sh_quote(search)))
    if not f then return {} end
    local out = {}
    for line in f:lines() do
        local n = line:gsub("[\r\n]+$", "")
        if n ~= "" and not never_farm[n] then out[#out + 1] = n end
    end
    f:close()
    return out
end

-- One soname, looked for in the payloads this home already has.
local function find_in_store(soname)
    for _, root in ipairs(xim_store_roots()) do
        local f = io.popen(string.format(
            [[ls -1 "%s"/xim-x-*/*/lib/%s "%s"/xim-x-*/*/lib64/%s 2>/dev/null | sort -V | tail -1]],
            root, soname, root, soname))
        if f then
            local hit = (f:read("l") or ""):gsub("[\r\n]+$", "")
            f:close()
            if hit ~= "" then return hit end
        end
    end
    return nil
end

-- Proprietary vendor userspace: linked from the host by design and never
-- compared against a payload, because none exists or may exist.
local vendor_userspace = {
    "^libnvidia", "^libGLX_nvidia%.so", "^libEGL_nvidia%.so", "^libGLESv[12]_nvidia%.so",
    "^libcuda%.so", "^libnvcuvid%.so", "^libnvoptix%.so",
}
local function is_vendor_userspace(base)
    for _, pat in ipairs(vendor_userspace) do
        if base:match(pat) then return true end
    end
    return false
end

-- The host's own Mesa ICDs are the driver. A payload driver replaces them as
-- a whole through its own manifest; substituting one of their libraries would
-- mix two Mesa builds in one process.
local function is_host_driver(base)
    return base:match("^libvulkan_") ~= nil
end

local function is_store_path(p)
    for _, root in ipairs(xim_store_roots()) do
        if p:sub(1, #root) == root then return true end
    end
    return false
end

-- `nm` from an installed toolchain payload, else from PATH, else nothing. The
-- comparison below is skipped and recorded when there is none; a farm that
-- cannot compare keeps the host copy rather than guessing.
local function find_tool(name)
    for _, root in ipairs(xim_store_roots()) do
        local f = io.popen(string.format(
            [[ls -1 "%s"/xim-x-binutils/*/bin/%s "%s"/xim-x-gcc/*/bin/%s 2>/dev/null | sort -V | tail -1]],
            root, name, root, name))
        if f then
            local hit = (f:read("l") or ""):gsub("[\r\n]+$", "")
            f:close()
            if hit ~= "" then return hit end
        end
    end
    local f = io.popen(string.format([[command -v %s 2>/dev/null]], name))
    if f then
        local hit = (f:read("l") or ""):gsub("[\r\n]+$", "")
        f:close()
        if hit ~= "" then return hit end
    end
    return nil
end

-- THE MACHINE THE OBJECT WAS BUILT FOR, from the ELF header (`e_machine`,
-- two bytes at offset 18 on both little-endian classes this index targets).
-- The symbol test cannot see this: `nm` reads an x86_64 object on an aarch64
-- host perfectly well and reports a covering symbol set, so a store that holds
-- a foreign payload -- which is what an aarch64 machine gets today, since every
-- Linux payload in this index publishes one x86_64 artifact -- would otherwise
-- have that payload substituted into the farm and every dlopen would fail with
-- `wrong ELF class` at run time.
local function elf_machine(file)
    local f = io.popen(string.format(
        [[od -An -tu1 -j18 -N2 %s 2>/dev/null | tr -s " "]], sh_quote(file)))
    if not f then return nil end
    local line = (f:read("l") or ""):gsub("^%s+", ""):gsub("%s+$", "")
    f:close()
    local lo, hi = line:match("^(%d+) (%d+)$")
    if not lo then return nil end
    return tonumber(lo) + tonumber(hi) * 256
end

-- The versioned dynamic symbols a library defines, as a set. `name@@VERSION`
-- for a versioned symbol, so the GLIBCXX and CXXABI nodes of a C++ runtime
-- take part in the comparison exactly as the loader would apply them.
local function symbol_set(nm, lib)
    local f = io.popen(string.format(
        [[%s -D --defined-only --with-symbol-versions %s 2>/dev/null | awk '{print $NF}']],
        sh_quote(nm), sh_quote(lib)))
    if not f then return nil end
    local set, n = {}, 0
    for line in f:lines() do
        local sym = line:gsub("[\r\n]+$", "")
        if sym ~= "" then set[sym] = true; n = n + 1 end
    end
    f:close()
    if n == 0 then return nil end
    return set
end

-- PAYLOADS FIRST. Every farmed soname an installed payload also provides is
-- re-pointed at the payload when the payload's versioned symbol set covers the
-- host copy's. The direction matters and is what the symbol test decides: an
-- ICD linked against the host's libstdc++ needs every GLIBCXX node the host
-- copy has, which a NEWER payload provides and an older one does not. The
-- outcome is recorded per entry, so HOST-SURFACE.txt says why each library is
-- where it is rather than only where it points.
local function prefer_payloads(outdir)
    local classes = {}
    local nm = find_tool("nm")
    local lsf = io.popen(string.format([[ls -1 "%s" 2>/dev/null]], outdir))
    if not lsf then return classes end
    local names = {}
    for line in lsf:lines() do
        local base = line:gsub("[\r\n]+$", "")
        if base ~= "" then names[#names + 1] = base end
    end
    lsf:close()
    local moved = 0
    for _, base in ipairs(names) do
        local link = path.join(outdir, base)
        local rf = io.popen(string.format([[readlink -f "%s" 2>/dev/null]], link))
        local target = ""
        if rf then
            target = (rf:read("l") or ""):gsub("[\r\n]+$", "")
            rf:close()
        end
        local entry = { target = target, class = "" }
        if is_vendor_userspace(base) then
            entry.class = "vendor userspace; linked from the host by design"
        elseif is_host_driver(base) then
            entry.class = "host driver; a payload driver replaces it as a whole"
        elseif is_store_path(target) then
            entry.class = "payload"
        else
            local hit = find_in_store(base)
            local declared = PAYLOAD_PACKAGES[base]
            if not hit then
                entry.class = declared
                    and ("host; " .. declared .. " is declared for this soname "
                         .. "and is not installed, so the declaration did not "
                         .. "take effect")
                    or "host; no installed payload provides this soname"
            elseif elf_machine(hit) ~= elf_machine(target) then
                entry.class = string.format(
                    "host; the payload %s is built for another machine", hit)
            elseif not nm then
                entry.class = "host; no nm to compare against " .. hit
            else
                local host_syms = symbol_set(nm, target)
                local pay_syms  = symbol_set(nm, hit)
                if not host_syms or not pay_syms then
                    entry.class = "host; symbol tables unreadable, not compared against " .. hit
                else
                    local missing = 0
                    for sym in pairs(host_syms) do
                        if not pay_syms[sym] then missing = missing + 1 end
                    end
                    if missing == 0 then
                        os.exec(string.format([[ln -sf "%s" "%s"]], hit, link))
                        entry.target = hit
                        entry.class  = "payload; its symbol set covers the host copy " .. target
                        moved = moved + 1
                    else
                        entry.class = string.format(
                            "host; payload %s lacks %d symbol(s) the host copy defines", hit, missing)
                    end
                end
            end
        end
        classes[base] = entry
    end
    if moved > 0 then
        log.info("compat.vulkan-runtime: %d farmed libraries re-pointed at installed payloads", moved)
    end
    return classes
end

local function link_runtime_libs(outdir)
    os.mkdir(outdir)
    for _, dir in ipairs(candidate_dirs()) do
        for _, pattern in ipairs(host_vulkan_patterns) do
            os.exec(
                "for lib in " .. sh_quote(dir) .. "/" .. pattern ..
                "; do [ -e \"$lib\" ] || continue; " ..
                "ln -sf \"$lib\" " .. sh_quote(outdir) .. "/\"$(basename \"$lib\")\"; " ..
                "done"
            )
        end
    end
    for _, pat in ipairs(never_farm_patterns) do
        os.exec(string.format(
            [[for lib in "%s"/*; do case "$(basename "$lib")" in %s) rm -f "$lib";; esac; done]],
            outdir, "libnvidia-gtk*"))
    end
    local dirs = candidate_dirs()
    -- The ICD libraries themselves. A manifest names its driver by bare
    -- soname or by path; the loader dlopens the former by name, which only
    -- resolves through this directory, and the latter's dependencies still do.
    for _, seed in ipairs(icd_seed_libraries(dirs)) do
        local base = seed:match("([^/]+)$")
        if base and not os.isfile(path.join(outdir, base)) then
            os.exec(string.format([[ln -sf "%s" "%s"]], seed, path.join(outdir, base)))
        end
    end
    local n = close_over_needed(outdir, dirs)
    if n > 0 then
        log.info("compat.vulkan-runtime: %d transitive libraries closed over", n)
    end
    local classes = prefer_payloads(outdir)

    -- Gap-filling, then the record. Both read the same seed set the closure
    -- used, so what the report describes is what the loader will do.
    local seeds = icd_seed_libraries(dirs)
    local filled, missing = {}, {}
    for _, soname in ipairs(unresolved_names(outdir, seeds, dirs)) do
        local hit = find_in_store(soname)
        if hit then
            os.exec(string.format([[ln -sf "%s" "%s"]], hit, path.join(outdir, soname)))
            filled[#filled + 1] = soname .. "  <- " .. hit
        else
            missing[#missing + 1] = soname
        end
    end
    if #filled > 0 then
        log.info("compat.vulkan-runtime: %d libraries the host could not resolve "
                 .. "were filled from installed payloads", #filled)
    end
    if #missing > 0 then
        log.warn("compat.vulkan-runtime: %d libraries an ICD needs are on neither "
                 .. "the host nor in this home; that driver will not load. "
                 .. "See HOST-SURFACE.txt in the package.", #missing)
    end

    local report = {"# What this farm takes from the host, and what it could not find.",
                    "#",
                    "# Written by compat.vulkan-runtime at install time. The farm is a",
                    "# directory of symlinks; this file says where each one points and",
                    "# why: a payload, proprietary vendor userspace linked by design, or",
                    "# a host copy with the reason no payload replaced it.",
                    ""}
    local lsf = io.popen(string.format([[ls -1 "%s" 2>/dev/null]], outdir))
    if lsf then
        report[#report + 1] = "## farmed"
        for line in lsf:lines() do
            local base = line:gsub("[\r\n]+$", "")
            if base ~= "" then
                local entry = classes[base]
                local target, class = "", "filled from an installed payload"
                if entry then
                    target, class = entry.target, entry.class
                else
                    local rf = io.popen(string.format([[readlink -f "%s" 2>/dev/null]],
                                                      path.join(outdir, base)))
                    if rf then
                        target = (rf:read("l") or ""):gsub("[\r\n]+$", "")
                        rf:close()
                    end
                end
                report[#report + 1] = string.format("%-34s %s\n%-34s   -- %s", base, target, "", class)
            end
        end
        lsf:close()
    end
    if #filled > 0 then
        report[#report + 1] = ""
        report[#report + 1] = "## filled from an installed payload (the host had no copy)"
        for _, l in ipairs(filled) do report[#report + 1] = l end
    end
    if #missing > 0 then
        report[#report + 1] = ""
        report[#report + 1] = "## unresolved -- an ICD names these and nothing here provides them"
        for _, l in ipairs(missing) do report[#report + 1] = l end
    end
    io.writefile(path.join(path.directory(outdir), "HOST-SURFACE.txt"),
                 table.concat(report, "\n") .. "\n")
    return true
end

function install()
    os.tryrm(pkginfo.install_dir())
    os.mkdir(pkginfo.install_dir())

    local generated = path.join(pkginfo.install_dir(), "mcpp_generated")
    os.mkdir(generated)
    io.writefile(path.join(generated, "vulkan_runtime_empty.c"),
        "int mcpp_compat_vulkan_runtime_anchor(void) { return 0; }\n")

    return link_runtime_libs(path.join(generated, "vulkan_runtime", "lib"))
end
