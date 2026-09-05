-- compat.vulkan-runtime — host Vulkan ICD adapter for mcpp Linux applications.
--
-- The exact counterpart of `compat.glx-runtime`, for the same reason and in the
-- same shape. A GPU driver cannot be a package: the ICD has to match the kernel
-- driver on the machine it runs on, so the GL runtime plan
-- (.agents/docs/2026-06-03-gl-runtime-packages-plan.md) settled on modelling it
-- as a HOST CAPABILITY rather than "silently pretending vendor drivers are
-- normal redistributable packages". Nothing is vendored here either — this is a
-- symlink farm plus the metadata that makes it reachable.
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
    add("/lib64")
    add("/usr/lib64")
    add("/usr/lib")
    return out
end

-- ICDs first, then the transitive set they pull in — the whole chain has to
-- resolve through this one directory. Verified against Mesa's lavapipe (LLVM,
-- drm, expat, xcb, wayland, zstd) and NVIDIA's ICD, which is libGLX_nvidia.so.0
-- and drags the libnvidia* family.
--
-- EVERY DEPENDENCY PATTERN IS VERSIONED (`lib*.so.*`), deliberately. mcpp puts
-- `runtime.library_dirs` on the LINK line as well as the runtime path, so a bare
-- `libxcb.so` harvested here would shadow this index's own `compat.xcb` and the
-- link fails with `undefined reference to XauDisposeAuth`. Versioned sonames are
-- invisible to the linker (it resolves `-lxcb` through `libxcb.so`/`libxcb.a`)
-- and are exactly what dlopen asks for, so the split is not a workaround so much
-- as the correct spelling. `compat.glx-runtime` never hit this only because the
-- GL family it harvests is not otherwise linked from the index.
--
-- The Mesa ICDs themselves are genuinely named `libvulkan_lvp.so` with no
-- version, which is safe: nothing links `-lvulkan_lvp`.
--
-- The host's own `libvulkan.so*` is deliberately NOT harvested: `compat.vulkan`
-- builds the loader itself, as a shared object with the canonical
-- `libvulkan.so.1` soname, and a second one on the path would be resolved by
-- SDL2's `dlopen` instead. One loader per process is the whole point.
local host_vulkan_patterns = {
    -- Mesa ICDs: lavapipe, intel, radeon, nouveau, virtio, asahi, gfxstream
    "libvulkan_*.so",
    -- NVIDIA's ICD and its family
    "libGLX_nvidia.so.*",
    "libnvidia*.so.*",
    -- transitive dependencies, versioned only
    "libLLVM*.so.*",
    "libdrm*.so.*",
    "libexpat.so.*",
    -- The X client stack, including its own auth dependencies. Incomplete is
    -- worse than absent here: a farm carrying libxcb.so.1 but not libXau.so.6
    -- shadows the host copy that would otherwise have resolved, and the
    -- executable fails to start.
    "libxcb*.so.*",
    "libX11-xcb.so.*",
    "libXau.so.*",
    "libXdmcp.so.*",
    "libbsd.so.*",
    "libmd.so.*",
    "libxshmfence.so.*",
    "libwayland-client.so.*",
    "libz.so.*",
    "libzstd.so.*",
    "libelf.so.*",
    "libffi.so.*",
    "libedit.so.*",
    "libtinfo.so.*",
    "libxml2.so.*",
    "libstdc++.so.*",
}

-- ⚠️⚠️ THE LIBRARIES THE C RUNTIME OWNS ARE NEVER FARMED FROM THE HOST.
--
-- An mcpp artifact runs under mcpp's own glibc, and a second C library reachable
-- on the same search path is the one failure worse than a missing driver. The
-- same holds for `libgcc_s`, which the toolchain payload provides, and for
-- `libvulkan.so.1`, where the whole point is one loader per process.
local never_farm = {
    ["libc.so.6"] = true, ["libm.so.6"] = true, ["libdl.so.2"] = true,
    ["libpthread.so.0"] = true, ["librt.so.1"] = true, ["libresolv.so.2"] = true,
    ["ld-linux-x86-64.so.2"] = true, ["ld-linux-aarch64.so.1"] = true,
    ["libgcc_s.so.1"] = true, ["libvulkan.so.1"] = true,
}

-- ⭐⭐ THE PATTERN LIST NAMES WHAT IS DLOPENED; THIS CLOSES WHAT IT NEEDS.
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
-- ⭐ THE SEED IS THE ICD SET, NOT THE FARM. Closing over every file the pattern
-- list matched pulled 64 libraries here, GTK 2 and GTK 3 among them, because
-- `libnvidia*.so.*` also matches the driver's settings GUI. Those libraries are
-- on the consuming binary's runtime path, where a host GTK can shadow an index
-- package's; a driver the loader will never dlopen has no business putting it
-- there. The manifests state exactly which libraries the loader loads, so they
-- are what gets closed over.
--
-- ⚠️⚠️ THE `ldd` ON `PATH` IS NOT NECESSARILY THE HOST'S. Under xlings it is the
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

-- ⭐⭐ WHAT THE FARM STILL TAKES FROM THE HOST, WRITTEN DOWN.
--
-- This package exists because a GPU driver cannot be a package, and that is
-- true of the driver. It is not true of `libxcb`, `libz` or `libxml2`, which
-- this index publishes and which the pattern list nonetheless harvests from
-- /usr/lib. The distinction was never recorded anywhere, so "how much of the
-- host does a Vulkan program still touch" could only be answered by reading
-- the list and guessing.
--
-- Three classes, and only the third is reducible:
--
--   * THE DRIVER FAMILY -- `libvulkan_*.so`, `libGLX_nvidia.so.*`,
--     `libnvidia*.so.*`. Licence-restricted, in ABI lockstep with a kernel
--     module, meaningless off the machine they came from.
--   * VERSION-LOCKED TO THE DRIVER -- the host mesa's `libLLVM.so.20.1`, whose
--     soname names the build the driver was compiled against. This index
--     publishes LLVM 22; substituting it is `not found`, not an upgrade.
--   * EVERYTHING ELSE -- the X protocol stack, zlib, expat, libxml2, libffi,
--     libdrm. Every one of these is an xim package today.
--
-- The third class is NOT substituted when the host provides it, and that is a
-- deliberate limit rather than an oversight: the host ICD was linked against
-- the host's copies, a package copy may be OLDER, and the failure mode of an
-- older libstdc++ or libxml2 under a dlopen is a missing symbol version at run
-- time on some machines and not others. Replacing something that works with
-- something that might is not a reduction.
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
        -- ⚠️ No POSIX character class here: `[[:space:]]` contains `]]`, which
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
            [[ls -1 "%s"/xim-x-*/*/lib/%s "%s"/xim-x-*/*/lib64/%s 2>/dev/null | head -1]],
            root, soname, root, soname))
        if f then
            local hit = (f:read("l") or ""):gsub("[\r\n]+$", "")
            f:close()
            if hit ~= "" then return hit end
        end
    end
    return nil
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
    local dirs = candidate_dirs()
    local n = close_over_needed(outdir, dirs)
    if n > 0 then
        log.info("compat.vulkan-runtime: %d transitive libraries closed over", n)
    end

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
                    "# which of them could be a package instead.",
                    ""}
    local lsf = io.popen(string.format([[ls -1 "%s" 2>/dev/null]], outdir))
    if lsf then
        report[#report + 1] = "## farmed"
        for line in lsf:lines() do
            local base = line:gsub("[\r\n]+$", "")
            if base ~= "" then
                local rf = io.popen(string.format([[readlink -f "%s" 2>/dev/null]],
                                                  path.join(outdir, base)))
                local target = rf and (rf:read("l") or "") or ""
                if rf then rf:close() end
                report[#report + 1] = string.format("%-34s %s", base, target)
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
