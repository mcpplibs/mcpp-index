-- compat.opencl-runtime -- host OpenCL ICD adapter for mcpp Linux applications.
--
-- The counterpart of `compat.vulkan-runtime`, for the other device API, in the
-- same shape and for the same reason. `compat.opencl` builds the Khronos ICD
-- loader; the loader reads every manifest in `/etc/OpenCL/vendors` and then
-- fails to dlopen a single driver, because an mcpp-built binary runs under
-- mcpp's own glibc and a bare-soname dlopen from inside that sandbox does not
-- search the host's library path at all. `runtime.library_dirs` below puts a
-- package-owned directory of symlinks on that path.
--
-- WHAT IS FARMED. The libraries the host's manifests name (`nvidia.icd` says
-- `libnvidia-opencl.so.1`), the transitive set they need as `ldd` reports it,
-- and the proprietary vendor family, which a driver dlopens by name at run
-- time (`libnvidia-ptxjitcompiler`, `libnvidia-nvvm`) where no `DT_NEEDED`
-- walk can see it. Nothing else: a host library an installed payload also
-- provides is taken from the payload when the payload's versioned symbol set
-- covers the host copy's, and every entry is recorded in `HOST-SURFACE.txt`
-- with the reason it is where it is.
--
-- A PAYLOAD DRIVER NEEDS NONE OF THIS. `xim:pocl` runs OpenCL on the CPU from
-- a self-contained payload and announces itself through `OCL_ICD_FILENAMES`,
-- which the loader enumerates in addition to the vendors directory
-- (`khrIcdOsVendorsEnumerate`, loader/linux/icd_linux.c). Entries of that
-- variable that point into a payload are therefore not farmed; the farm is
-- for the machine's proprietary drivers only.
--
-- NOTHING IS REQUIRED. A machine with no OpenCL driver is a legitimate
-- configuration -- every CI runner in this repository is one -- and the farm
-- is then empty; the loader reports zero platforms, which `tests/examples/opencl`
-- asserts is not an error.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "opencl-runtime",
    description = "Host OpenCL ICD runtime adapter for mcpp Linux applications",
    licenses    = {"Apache-2.0"},
    repo        = "https://github.com/KhronosGroup/OpenCL-ICD-Loader",
    type        = "package",

    xpm = {
        linux = {
            -- PLATFORM LEVEL, NOT PER VERSION, matching compat.vulkan-runtime:
            -- a `deps` inside a version entry is not read.
            --
            -- The rule this package follows is that anything xlings or this
            -- index can supply comes from there, and the host is reached
            -- through a named sentinel rather than by this package itself.
            -- `xim:nvidia-video-host-link` owns "where is the host's
            -- `libnvcuvid.so.1`", which two farmed members need.
            --
            -- OpenSSL was declared here for one release and is gone with the
            -- member that asked for it: the PKCS#11 provider the name pattern
            -- swept in and no OpenCL entry point reaches.
            deps = {
                runtime = { "xim:nvidia-video-host-link" },
            },
            ["latest"] = { ref = "2026.09.11" },
            -- 2026.09.07: a soname carried by more than one installed payload
            -- is decided by symbol coverage rather than by which store path
            -- sorts last, and the ELF machine guard refuses a foreign payload.
            -- 2026.09.10: the farm answers for what its own members need,
            -- not only for what an ICD manifest names. A member the vendor
            -- pattern swept in is closed over too; only proprietary vendor
            -- userspace may be taken from the host for it, anything else is
            -- filled from an installed payload, and what nothing publishes is
            -- recorded as unserved rather than left absent. A new key because
            -- install() output is baked into the installed payload: without one
            -- a host that already holds the previous version keeps the open
            -- farm. The anchor is unchanged; only install() behaviour is.
            -- 2026.09.11: the farm carries only what this runtime can
            -- reach. `libnvidia-pkcs11*` is a PKCS#11 token module that matched
            -- the vendor name pattern and nothing else -- measured with
            -- LD_DEBUG on both examples, it is looked for zero times while a
            -- member the driver does reach appears six -- so it leaves, and the
            -- OpenSSL declaration it was the only reason for leaves with it.
            -- A new key because install() output is baked into the installed
            -- payload.
            ["2026.09.11"] = {
                url    = "https://raw.githubusercontent.com/KhronosGroup/OpenCL-ICD-Loader/v2026.05.29/README.md",
                sha256 = "b332515b9a0bc266ad94fe6e951f0ef7a988ccb9e933068faf0fd8ba3cfde805",
            },
            ["2026.09.10"] = {
                url    = "https://raw.githubusercontent.com/KhronosGroup/OpenCL-ICD-Loader/v2026.05.29/README.md",
                sha256 = "b332515b9a0bc266ad94fe6e951f0ef7a988ccb9e933068faf0fd8ba3cfde805",
            },
            ["2026.09.07"] = {
                url    = "https://raw.githubusercontent.com/KhronosGroup/OpenCL-ICD-Loader/v2026.05.29/README.md",
                sha256 = "b332515b9a0bc266ad94fe6e951f0ef7a988ccb9e933068faf0fd8ba3cfde805",
            },
            ["2026.09.05"] = {
                -- A stable, tiny anchor so the xpm entry is well-formed; the
                -- package's content is the farm install() builds from the host.
                url    = "https://raw.githubusercontent.com/KhronosGroup/OpenCL-ICD-Loader/v2026.05.29/README.md",
                sha256 = "b332515b9a0bc266ad94fe6e951f0ef7a988ccb9e933068faf0fd8ba3cfde805",
            },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        c_standard   = "c11",
        sources      = { "mcpp_generated/opencl_runtime_empty.c" },
        targets      = { ["opencl_runtime"] = { kind = "lib" } },
        deps         = {},
        runtime = {
            library_dirs = { "mcpp_generated/opencl_runtime/lib" },
            capabilities = { "opencl.icd.driver" },
            provides     = { "opencl.icd.driver" },
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
    if not value or value == "" then return out end
    for item in tostring(value):gmatch("[^:]+") do
        if item ~= "" then table.insert(out, item) end
    end
    return out
end

local function candidate_dirs()
    local out, seen = {}, {}
    local function add(dir)
        if dir and dir ~= "" and not seen[dir] and os.isdir(dir) then
            seen[dir] = true
            table.insert(out, dir)
        end
    end
    for _, dir in ipairs(split_paths(os.getenv("MCPP_HOST_OPENCL_LIBRARY_PATH"))) do add(dir) end
    add("/lib/x86_64-linux-gnu")
    add("/usr/lib/x86_64-linux-gnu")
    add("/lib/aarch64-linux-gnu")
    add("/usr/lib/aarch64-linux-gnu")
    add("/lib64")
    add("/usr/lib64")
    add("/usr/lib")
    return out
end

local function xim_store_roots()
    local roots = {}
    local home = (os.getenv and os.getenv("XLINGS_HOME")) or ""
    if home == "" then home = ((os.getenv and os.getenv("HOME")) or "") .. "/.xlings" end
    roots[#roots + 1] = path.join(home, "data/xpkgs")
    local pfx = pkginfo.install_dir()
    if pfx then roots[#roots + 1] = path.directory(path.directory(pfx)) end
    return roots
end

local function is_store_path(p)
    for _, root in ipairs(xim_store_roots()) do
        if p:sub(1, #root) == root then return true end
    end
    return false
end

-- Every ICD library the machine's manifests name, resolved the way the loader
-- resolves it: an absolute path as is, a bare soname searched for. Payload
-- entries of OCL_ICD_FILENAMES are skipped on purpose (see the header).
local function icd_seed_libraries(dirs)
    local seeds, seen = {}, {}
    local function consider(value)
        if not value or value == "" then return end
        local candidates = {}
        if value:sub(1, 1) == "/" then
            if not is_store_path(value) then table.insert(candidates, value) end
        else
            for _, libdir in ipairs(dirs) do table.insert(candidates, path.join(libdir, value)) end
        end
        for _, c in ipairs(candidates) do
            if os.isfile(c) then
                -- Deduplicated by the file, not the spelling: /lib and /usr/lib
                -- are one directory on a merged-usr distribution.
                local rf = io.popen(string.format([[readlink -f "%s" 2>/dev/null]], c))
                local real = c
                if rf then
                    real = (rf:read("l") or c):gsub("[\r\n]+$", "")
                    rf:close()
                end
                if not seen[real] then
                    seen[real] = true
                    table.insert(seeds, real)
                end
            end
        end
    end
    local vendors = os.getenv("OCL_ICD_VENDORS")
    if not vendors or vendors == "" then vendors = "/etc/OpenCL/vendors" end
    local f = io.popen(string.format(
        [[for i in "%s"/*.icd; do [ -e "$i" ] || continue; head -1 "$i" | tr -d '\r'; done]], vendors))
    if f then
        for line in f:lines() do consider((line:gsub("^%s+", ""):gsub("%s+$", ""))) end
        f:close()
    end
    for _, entry in ipairs(split_paths(os.getenv("OCL_ICD_FILENAMES"))) do consider(entry) end
    return seeds
end

local host_prefixes = {"/usr/", "/lib/", "/lib64/", "/opt/"}

local never_farm = {
    ["libc.so.6"] = true, ["libm.so.6"] = true, ["libdl.so.2"] = true,
    ["libpthread.so.0"] = true, ["librt.so.1"] = true, ["libresolv.so.2"] = true,
    ["ld-linux-x86-64.so.2"] = true, ["ld-linux-aarch64.so.1"] = true,
    ["libgcc_s.so.1"] = true, ["libOpenCL.so.1"] = true,
}

-- WHAT THE PATTERN SWEEPS IN THAT THIS RUNTIME CANNOT REACH.
--
-- `libnvidia-gtk*` is the driver's settings GUI. `libnvidia-pkcs11*` is its
-- PKCS#11 provider: a cryptographic token module, loaded by an application's
-- own PKCS#11 configuration and by nothing in a GPU driver's dispatch. Both
-- match `libnvidia*.so.*` by name alone.
--
-- MEASURED, WITH A CONTROL, before removing them. `LD_DEBUG=libs` on a run of
-- each example says which files the process actually looked for:
--
--   pkcs11                      0 occurrences   (Vulkan and SYCL/OpenCL alike)
--   libnvidia-glvkspirv         6 occurrences   (Vulkan)
--   libur_adapter_opencl / libOpenCL   23       (SYCL/OpenCL)
--
-- The last two are the control: this instrument does report a member the
-- driver reaches, so a zero for `pkcs11` is a reading rather than a silence.
-- An earlier attempt -- remove the member and see whether the example still
-- runs -- could NOT tell the two apart: removing `libnvidia-glvkspirv` left the
-- example working too, because the binary under test had been built against a
-- different farm than the one being edited.
--
-- They are also the only members that need `libcrypto` at all, so removing them
-- removes this package's reason to declare OpenSSL, and with it the
-- `libcrypto.so.1.1` that no ecosystem package can serve: OpenSSL 1.1 is
-- end-of-life upstream. A member that cannot be reached is not a capability
-- being dropped -- it is a file the name pattern collected.
-- Proprietary vendor userspace: linked from the host by design. `libnvidia-gtk*`
-- is the driver's settings GUI and is not part of any driver.
local host_opencl_patterns = { "libnvidia*.so.*" }
local vendor_userspace = {
    "^libnvidia", "^libcuda%.so", "^libnvcuvid%.so", "^libnvoptix%.so",
    "^libamdocl", "^libamdhip", "^libhsa%-runtime",
}
local function is_vendor_userspace(base)
    for _, pat in ipairs(vendor_userspace) do
        if base:match(pat) then return true end
    end
    return false
end

-- THE FARM IS ALSO A SEED SET, AND THE HOST SURFACE DOES NOT GROW FOR IT.
--
-- The pattern above exists because a proprietary driver dlopens members of its
-- own family by name, which no `DT_NEEDED` walk can see. Having said that, this
-- package has to treat those members as reachable everywhere else too -- and it
-- did not. The closure below takes the ICD manifests' libraries, so the half of
-- the farm that was never in doubt is the half that gets verified, and the half
-- the pattern exists for was never asked what it needs.
--
-- Measured on a host with an NVIDIA driver, by mcpp's own dlopen-surface check:
-- four members were unloadable from this directory --
-- `libnvidia-encode.so.1` and `libnvidia-opticalflow.so.1` need
-- `libnvcuvid.so.1`, and the two `libnvidia-pkcs11` providers need
-- `libcrypto.so.3` / `libcrypto.so.1.1`.
--
-- THE FARM REACHES THE HOST THROUGH A NAMED PACKAGE, NOT THROUGH
-- /usr/lib. What a farmed member needs is answered in this order:
--
--   * an installed payload publishes it -> link the payload's copy.
--     `xim:nvidia-video-host-link` covers `libnvcuvid.so.1`, which is
--     what the two encode/optical-flow members need. Both are declared
--     in `xpm.linux.deps` above, so the reach is visible in the
--     recipe rather than discovered at install time.
--   * nothing does, and nothing can -> named in UNSERVED with the
--     reason, and linked into a directory this package never creates.
--   * anything else -> a warning naming it.
--
-- There is no branch that harvests a file from /usr/lib for a farmed
-- member. A library that cannot be redistributed still comes from the
-- host, but it comes through a `*-host-link` sentinel that owns exactly
-- that question -- the shape `libcuda-host-link` and
-- `nvidia-gl-host-link` already have -- so each consumer declares the
-- host reach it actually has instead of inheriting an open one.
--
-- The ICD closure below is left exactly as it is: it is what makes a
-- driver load at all, and narrowing it is a separate question from
-- completing the members the vendor pattern swept in.
local function farm_members(outdir)
    local out = {}
    local f = io.popen(string.format([[ls -1 "%s" 2>/dev/null]], outdir))
    if not f then return out end
    for line in f:lines() do
        local base = line:gsub("[\r\n]+$", "")
        if base ~= "" then out[#out + 1] = path.join(outdir, base) end
    end
    f:close()
    return out
end

local function close_over_needed(outdir, seeds, dirs)
    if #seeds == 0 then return 0 end
    local accept = {}
    for _, dir in ipairs(dirs) do accept[dir] = true end
    local function is_host_library(full)
        local dir = full:match("^(.*)/[^/]+$")
        if dir and accept[dir] then return true end
        for _, prefix in ipairs(host_prefixes) do
            if full:sub(1, #prefix) == prefix then return true end
        end
        return false
    end
    local args = {}
    for _, seed in ipairs(seeds) do table.insert(args, sh_quote(seed)) end
    -- The search path is supplied rather than inherited: under xlings the
    -- `ldd` on PATH is the payload's own, whose default search path is its
    -- build prefix, and it answers `not found` for every host library.
    local f = io.popen(string.format(
        [[for lib in %s; do LD_LIBRARY_PATH=%s ldd "$lib" 2>/dev/null; done ]] ..
        [[| sed -n 's/.*=> \(\/[^ ]*\).*/\1/p' | sort -u]],
        table.concat(args, " "), sh_quote(table.concat(dirs, ":"))))
    if not f then return 0 end
    local added = 0
    for line in f:lines() do
        local full = line:gsub("[\r\n]+$", "")
        local base = full:match("([^/]+)$")
        if full ~= "" and base and not never_farm[base] and is_host_library(full)
           and not os.isfile(path.join(outdir, base)) then
            os.exec(string.format([[ln -sf "%s" "%s"]], full, path.join(outdir, base)))
            added = added + 1
        end
    end
    f:close()
    return added
end

local function find_in_store(soname)
    -- Every copy, not the last one sorted. A driver payload can carry its own
    -- copy of a library another package owns -- `xim:mesa-lavapipe` ships one
    -- of nearly everything beside its driver -- and picking by store-path
    -- order chose that copy over the dedicated package's. compat.vulkan-runtime
    -- carries the same lookup and the measurement behind it.
    local out, seen = {}, {}
    for _, root in ipairs(xim_store_roots()) do
        local f = io.popen(string.format(
            [[ls -1 "%s"/xim-x-*/*/lib/%s "%s"/xim-x-*/*/lib64/%s 2>/dev/null | sort -V]],
            root, soname, root, soname))
        if f then
            for line in f:lines() do
                local hit = line:gsub("[\r\n]+$", "")
                if hit ~= "" and not seen[hit] then
                    seen[hit] = true
                    out[#out + 1] = hit
                end
            end
            f:close()
        end
    end
    return out
end

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

-- The machine an object was built for, read from the ELF header. `nm` reads a
-- foreign object without complaint and reports a covering symbol set, so the
-- symbol test alone would substitute an x86_64 payload into an aarch64 farm --
-- which is the store every aarch64 machine has today, since the Linux payloads
-- in this index publish one x86_64 artifact. compat.vulkan-runtime carries the
-- same guard and the same reason.
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

-- Both answers are required before the guard fires. An unreadable header --
-- a dangling farm link, a file the reader cannot open -- is not evidence of a
-- foreign machine, and reporting it as one would put a wrong reason in the
-- record; the symbol test below then rejects it for the reason that applies.
local function machines_differ(a, b)
    local ma, mb = elf_machine(a), elf_machine(b)
    return ma ~= nil and mb ~= nil and ma ~= mb
end

-- Payloads first, with the same criterion compat.vulkan-runtime applies: the
-- payload's versioned symbol set must cover the host copy's.
-- WHAT A MEMBER NEEDS IS READ FROM THE MEMBER, NOT FROM A LOADER.
--
-- `ldd` answers "can this resolve HERE", and here includes the host's default
-- directories. A soname the host happens to carry therefore reads as resolved
-- and is never recorded -- while the consumer, whose search path is this farm
-- and not the host, cannot load it. Measured 2026-09-10: with `ldd` supplying
-- the host directories, the two `libnvidia-pkcs11` providers' `libcrypto`
-- needs were invisible to this pass and were reported by mcpp one layer up,
-- from the same directory.
--
-- `readelf -d` answers what the FILE says, and membership is decided against
-- this directory alone. That is the question mcpp asks, and asking a different
-- one is how a farm's own check passes while its consumer's does not.
local function unresolved_against_farm(outdir)
    local readelf = find_tool("readelf")
    -- A MISSING TOOL IS NOT AN EMPTY ANSWER.
    --
    -- Returning `{}` here would report "no member needs anything this farm
    -- lacks", which is the reading a fully closed farm produces -- so the one
    -- environment where this pass cannot run would be indistinguishable from
    -- the one where it ran and found nothing. That is the confusion this whole
    -- change exists to remove, one layer down, in the tool lookup.
    if not readelf then
        log.warn("compat.opencl-runtime: readelf was not found, so the farm's own members were "
                 .. "not checked. This is NOT the same as finding no gaps: "
                 .. "install xim:binutils, or read HOST-SURFACE.txt with the "
                 .. "knowledge that it is incomplete.")
        return {}
    end
    local have, members = {}, {}
    local lsf = io.popen(string.format([[ls -1 "%s" 2>/dev/null]], outdir))
    if not lsf then return {} end
    for line in lsf:lines() do
        local b = line:gsub("[\r\n]+$", "")
        if b ~= "" then have[b] = true; members[#members + 1] = b end
    end
    lsf:close()
    local out, seen = {}, {}
    for _, base in ipairs(members) do
        local f = io.popen(string.format(
            [[%s -d %s 2>/dev/null | sed -n 's/.*(NEEDED).*\[\(.*\)\]/\1/p']],
            sh_quote(readelf), sh_quote(path.join(outdir, base))))
        if f then
            for line in f:lines() do
                local n = line:gsub("[\r\n]+$", "")
                -- AN ABSOLUTE `DT_NEEDED` NEVER GOES THROUGH A SEARCH PATH.
                --
                -- The loader opens it directly, so this farm can neither serve
                -- it nor honestly record it as unserved -- and treating it as a
                -- soname produces a lookup for a name with slashes in it and,
                -- worse, an `unserved` link whose name is a path. Measured on
                -- this farm: four members -- the glvnd vendor entries
                -- `libEGL_nvidia`, `libGLESv1_CM_nvidia`, `libGLESv2_nvidia`
                -- and `libGLX_nvidia` -- name `/lib/x86_64-linux-gnu/...`
                -- outright. They are a host reach that bypasses everything this
                -- package arranges, which is worth knowing and is not this
                -- pass's to answer.
                if n:sub(1, 1) == "/" then
                    goto continue
                end
                if n ~= "" and not have[n] and not never_farm[n] and not seen[n] then
                    seen[n] = true
                    out[#out + 1] = n
                end
                ::continue::
            end
            f:close()
        end
    end
    return out
end

-- WHAT IS STILL UNRESOLVED GETS AN ENTRY: A PAYLOAD, OR A DECLARED NON-ANSWER.
--
-- mcpp reads this directory with a three-state rule -- a member's SONAME is
-- resolved, present-but-dangling (this machine has no such library), or absent
-- everywhere (the publisher did not carry it). Only the first two are benign,
-- and DANGLING IS ONLY EXPRESSIBLE IF THIS PACKAGE MADE A LINK. A soname simply
-- not here reads as a packaging gap on every machine, including the ones where
-- the truth is "the ecosystem does not publish this and the driver only needs
-- it for a back end nobody called".
--
-- Measured: the same farm produced four findings on a host with the full
-- desktop stack and eleven inside a sandbox without it, and seven of those
-- eleven were the sandbox's answer rather than this package's.
--
-- THE UNSERVED LINK POINTS INSIDE THIS PACKAGE, NOT AT /usr/lib. Pointing it at
-- the canonical host path would make it resolve on any machine that happens to
-- have the file, which is a host harvest wearing a different name. It points at
-- a directory this package never creates, so it states "considered, and not
-- served here" and stays that way until the ecosystem gains a package for it.
-- EVERY SONAME A FARMED MEMBER NEEDS HAS AN ANSWER, AND NONE OF THEM IS
-- SILENCE. Four classes, in the order they are tried:
--
--   * a package this ecosystem publishes -- declared in `xpm.linux.deps` and
--     taken from the installed payload.
--   * proprietary vendor userspace -- also a package, and deliberately so:
--     `xim:nvidia-video-host-link` owns the one question "where is the host's
--     `libnvcuvid.so.1`". The library still comes from the host, because it is
--     in ABI lockstep with a kernel module and is not redistributable, but the
--     reach is named and declared instead of open.
--   * neither, and it cannot become one -- named in UNSERVED below WITH THE
--     REASON, and recorded as a link into a directory this package never
--     creates, so the state reads as "considered and not served here" rather
--     than "never considered".
--   * anything else -- a warning naming it. There is deliberately no branch
--     that quietly absorbs an unknown soname: the answer to "what does this
--     farm take from outside the ecosystem" has to be a list somebody wrote,
--     not a residue.
-- Empty, and the table stays so that the day something lands here somebody has
-- to write down why it cannot be a package. The warning below is what makes
-- leaving it blank impossible to do by accident. `libcrypto.so.1.1` was the
-- only entry and left with the PKCS#11 member that asked for it.
local UNSERVED = {}

local function seal_unresolved(outdir)
    local filled, unserved, undeclared = {}, {}, {}
    local unserved_dir = path.join(path.directory(outdir), "unserved")
    -- ITERATED TO A FIXED POINT, because `readelf -d` reports DIRECT
    -- dependencies only.
    --
    -- The pass this replaced asked `ldd`, whose answer is the whole transitive
    -- closure, so one round was enough and the comment said so. `readelf` is
    -- the right instrument -- it answers what the FILE says instead of what
    -- this machine can resolve -- but it is not transitive, and a library
    -- filled in one round brings needs of its own. Measured on the first real
    -- install of this package: the farm went from 52 members to 77 and was
    -- still nine sonames short, `libLLVM.so.20.1` and `libstdc++.so.6` among
    -- them, every one of them reachable from something the same round had just
    -- added.
    --
    -- The bound is not a guess about depth; it is there so a cycle cannot spin.
    -- A round that adds nothing ends the loop, which is the normal exit.
    local seen = {}
    for _ = 1, 16 do
    local added = 0
    for _, soname in ipairs(unresolved_against_farm(outdir)) do
        if seen[soname] then goto next end
        seen[soname] = true
        added = added + 1
        local candidates = find_in_store(soname)
        local hit = candidates[#candidates]
        if hit then
            os.exec(string.format([[ln -sf "%s" "%s"]], hit, path.join(outdir, soname)))
            filled[#filled + 1] = soname
        else
            os.exec(string.format([[ln -sf "%s" "%s"]],
                                  path.join(unserved_dir, soname),
                                  path.join(outdir, soname)))
            unserved[#unserved + 1] = soname
            if not UNSERVED[soname] then undeclared[#undeclared + 1] = soname end
        end
        ::next::
    end
    if added == 0 then break end
    end
    return filled, unserved, undeclared
end

local function prefer_payloads(outdir, seeds)
    local classes = {}
    local seed_names = {}
    for _, s in ipairs(seeds) do seed_names[s:match("([^/]+)$") or s] = true end
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
        elseif seed_names[base] then
            entry.class = "host driver named by a manifest; a payload driver announces itself through OCL_ICD_FILENAMES instead"
        elseif is_store_path(target) then
            entry.class = "payload"
        else
            local candidates = find_in_store(base)
            if #candidates == 0 then
                entry.class = "host; no installed payload provides this soname"
            elseif not nm then
                entry.class = "host; no nm to compare against " .. candidates[1]
            else
                local host_syms = symbol_set(nm, target)
                local why = nil
                for _, hit in ipairs(candidates) do
                  if machines_differ(hit, target) then
                    why = string.format(
                        "host; the payload %s is built for another machine", hit)
                  else
                    local pay_syms  = symbol_set(nm, hit)
                    if not host_syms or not pay_syms then
                        why = "host; symbol tables unreadable, not compared against " .. hit
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
                            why = nil
                            break
                        end
                        why = string.format(
                            "host; payload %s lacks %d symbol(s) the host copy defines", hit, missing)
                    end
                  end
                end
                if why then entry.class = why end
            end
        end
        classes[base] = entry
    end
    if moved > 0 then
        log.info("compat.opencl-runtime: %d farmed libraries re-pointed at installed payloads", moved)
    end
    return classes
end

local function link_runtime_libs(outdir)
    os.mkdir(outdir)
    local dirs = candidate_dirs()
    for _, dir in ipairs(dirs) do
        for _, pattern in ipairs(host_opencl_patterns) do
            os.exec(
                "for lib in " .. sh_quote(dir) .. "/" .. pattern ..
                "; do [ -e \"$lib\" ] || continue; " ..
                "case \"$(basename \"$lib\")\" in libnvidia-gtk*|libnvidia-pkcs11*) continue;; esac; " ..
                "ln -sf \"$lib\" " .. sh_quote(outdir) .. "/\"$(basename \"$lib\")\"; " ..
                "done"
            )
        end
    end
    local seeds = icd_seed_libraries(dirs)
    for _, seed in ipairs(seeds) do
        local base = seed:match("([^/]+)$")
        if base and not os.isfile(path.join(outdir, base)) then
            os.exec(string.format([[ln -sf "%s" "%s"]], seed, path.join(outdir, base)))
        end
    end
    local n = close_over_needed(outdir, seeds, dirs)
    if n > 0 then
        log.info("compat.opencl-runtime: %d transitive libraries closed over", n)
    end
    local classes = prefer_payloads(outdir, seeds)
    local filled, unserved, undeclared = seal_unresolved(outdir)
    for _, soname in ipairs(filled) do
        classes[soname] = { target = "", class = "filled from an installed payload" }
    end
    for _, soname in ipairs(unserved) do
        classes[soname] = { target = "",
                            class = "unserved -- " .. (UNSERVED[soname]
                                    or "NOT DECLARED; see UNSERVED in this recipe") }
    end
    if #filled > 0 then
        log.info("compat.opencl-runtime: %d libraries a farmed member needs were "
                 .. "filled from installed payloads", #filled)
    end
    if #unserved > 0 then
        log.info("compat.opencl-runtime: %d sonames a farmed member needs are "
                 .. "recorded as unserved", #unserved)
    end
    -- The list has to be written, not discovered. A soname arriving here that
    -- nobody decided about is a gap in this recipe, and saying so at install
    -- time is the only moment anyone is looking.
    for _, soname in ipairs(undeclared) do
        log.warn("compat.opencl-runtime: %s is needed by a farmed member, is "
                 .. "published by no installed payload, and is not declared in "
                 .. "UNSERVED. Add the ecosystem package that provides it, or "
                 .. "record why it cannot be one.", soname)
    end

    local report = {"# What this farm takes from the host, and why.",
                    "#",
                    "# Written by compat.opencl-runtime at install time. The farm is a",
                    "# directory of symlinks; this file says where each one points and",
                    "# why: a payload, proprietary vendor userspace linked by design, or",
                    "# a host copy with the reason no payload replaced it. A machine with",
                    "# no OpenCL driver has an empty farm and an empty list.",
                    ""}
    report[#report + 1] = "## manifests"
    if #seeds == 0 then
        report[#report + 1] = "(none: no host ICD manifest names a library)"
    end
    for _, s in ipairs(seeds) do report[#report + 1] = s end
    report[#report + 1] = ""
    report[#report + 1] = "## farmed"
    local lsf = io.popen(string.format([[ls -1 "%s" 2>/dev/null]], outdir))
    if lsf then
        for line in lsf:lines() do
            local base = line:gsub("[\r\n]+$", "")
            if base ~= "" then
                local entry = classes[base] or { target = "", class = "" }
                report[#report + 1] = string.format("%-34s %s\n%-34s   -- %s",
                                                    base, entry.target, "", entry.class)
            end
        end
        lsf:close()
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
    io.writefile(path.join(generated, "opencl_runtime_empty.c"),
        "int mcpp_compat_opencl_runtime_anchor(void) { return 0; }\n")
    return link_runtime_libs(path.join(generated, "opencl_runtime", "lib"))
end
