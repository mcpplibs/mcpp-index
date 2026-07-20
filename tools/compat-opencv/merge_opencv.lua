#!/usr/bin/env lua5.4
-- merge_opencv.lua — combine per-OS single-OS compat.opencv descriptors into ONE
-- 3-platform descriptor (xpm.{os} + mcpp neutral-common + mcpp.{os} per-OS blocks).
-- Correctness rules (mcpp full-platform-support-plan §2):
--   * mcpp.<os> list keys APPEND onto top-level -> every platform-specific key
--     (include_dirs/cxxflags/cflags/flags/ldflags/sources/generated_files) lives
--     ONLY in the per-OS block; nothing platform-specific at top level.
--   * generated_files emplace-no-overwrite -> ZERO global generated_files.
--   * neutral top-level: language, deps, targets, features.
-- Usage: lua5.4 merge_opencv.lua out.lua os1=path1 os2=path2 [os3=path3 ...]

local args = {...}
local OUT = args[1]
local INPUTS = {}
for i = 2, #args do
    local os_, path = args[i]:match("^(%w+)=(.+)$")
    assert(os_ and path, "bad arg: " .. args[i])
    INPUTS[#INPUTS+1] = { os = os_, path = path }
end
assert(OUT and #INPUTS >= 1, "usage: merge_opencv.lua out.lua os=path ...")

local function load_pkg(path)
    local env = {}
    local f = assert(loadfile(path, "t", env))
    f()
    assert(env.package, "no `package` table in " .. path)
    return env.package
end

-- ---- lua value serializer (deterministic, long-bracket for multiline strings) ----
local function is_ident(s)
    return type(s) == "string" and s:match("^[%a_][%w_]*$") ~= nil
end

local function is_array(t)
    local n = 0
    for k in pairs(t) do
        if type(k) ~= "number" then return false end
        n = n + 1
    end
    for i = 1, n do if t[i] == nil then return false end end
    return true, n
end

local function quote_str(s)
    if s:find("[\n\r]") or #s > 200 then
        -- choose a long-bracket level whose close-sequence isn't in the content
        local eq = ""
        while s:find("%]" .. eq .. "%]", 1, false) do eq = eq .. "=" end
        -- leading newline after [==[ is swallowed by lua; add one so content is verbatim
        return "[" .. eq .. "[\n" .. s .. "]" .. eq .. "]"
    end
    return string.format("%q", s)
end

local ser  -- fwd
local function ser_kv(k, v, ind)
    local key
    if is_ident(k) then key = k else key = "[" .. quote_str(tostring(k)) .. "]" end
    return ind .. key .. " = " .. ser(v, ind)
end

ser = function(v, ind)
    local t = type(v)
    if t == "string" then return quote_str(v) end
    if t == "number" or t == "boolean" then return tostring(v) end
    if t == "table" then
        local arr, n = is_array(v)
        if arr then
            if n == 0 then return "{}" end
            -- short arrays of scalars on one line; else one per line
            local scalar = true
            for i = 1, n do local et = type(v[i]); if et == "table" then scalar = false break end end
            if scalar then
                local parts = {}
                for i = 1, n do parts[i] = ser(v[i], "") end
                local oneline = "{ " .. table.concat(parts, ", ") .. " }"
                if #oneline <= 110 then return oneline end
            end
            local ni = ind .. "    "
            local parts = {}
            for i = 1, n do parts[i] = ni .. ser(v[i], ni) end
            return "{\n" .. table.concat(parts, ",\n") .. ",\n" .. ind .. "}"
        else
            -- map: stable key order (strings sorted; keep a preferred order for known keys)
            local keys = {}
            for k in pairs(v) do keys[#keys+1] = k end
            table.sort(keys, function(a, b) return tostring(a) < tostring(b) end)
            if #keys == 0 then return "{}" end
            -- try one-line for tiny maps of scalars
            local scalar = true
            for _, k in ipairs(keys) do if type(v[k]) == "table" then scalar = false break end end
            if scalar and #keys <= 3 then
                local parts = {}
                for _, k in ipairs(keys) do
                    local kk = is_ident(k) and k or ("[" .. quote_str(tostring(k)) .. "]")
                    parts[#parts+1] = kk .. " = " .. ser(v[k], "")
                end
                local oneline = "{ " .. table.concat(parts, ", ") .. " }"
                if #oneline <= 110 then return oneline end
            end
            local ni = ind .. "    "
            local parts = {}
            for _, k in ipairs(keys) do parts[#parts+1] = ser_kv(k, v[k], ni) end
            return "{\n" .. table.concat(parts, ",\n") .. ",\n" .. ind .. "}"
        end
    end
    error("cannot serialize type " .. t)
end

-- ---- build merged package ----
local base = load_pkg(INPUTS[1].path)   -- linux is authoritative for neutral keys
local merged = {
    spec = base.spec, namespace = base.namespace, name = base.name,
    description = base.description, licenses = base.licenses,
    repo = base.repo, type = base.type,
}

-- xpm: one key per OS (each single-OS descriptor holds its own xpm.<os>)
merged.xpm = {}
for _, e in ipairs(INPUTS) do
    local p = load_pkg(e.path)
    assert(p.xpm[e.os], e.os .. " descriptor lacks xpm." .. e.os)
    merged.xpm[e.os] = p.xpm[e.os]
end

-- mcpp: neutral-common (from base) + per-OS blocks (each OS's platform-specific keys)
-- `deps` is PER-OS: linux/macosx carry compat.ffmpeg (videoio backend); a core-only
-- profile (no videoio) carries none, so it must not inherit a global dep.
-- `flags` is handled specially below (dnn-group flag-globs relocate into the feature).
local PEROS = { "include_dirs", "cxxflags", "cflags", "sources", "generated_files", "deps" }

-- ── per-OS `dnn` feature (mcpp#253 common/delta) ────────────────────────
-- The dnn feature's payload splits into a cross-platform COMMON part (dnn/protobuf/
-- mlas C++, mlas_hgemm_stub) and a per-arch SIMD DELTA (x86: mlas/lib/x86_64/*.S +
-- avx/avx2/avx512 kernels; arm: mlas/lib/aarch64/*.S + neon/neon_fp16 kernels).
-- mcpp 0.0.101 per-OS features append per sub-key, so COMMON rides neutral
-- features.dnn and each OS's DELTA rides mcpp.<os>.features.dnn. dnn-group flag-globs
-- (mlas/protobuf/mlasgemm + per-ISA) ride features.dnn.flags so the feature-off base
-- has no dead globs (mcpp 0.0.101 warning). Inputs are normalized whether they
-- carried those globs in base `flags` (pre-warnfix descriptors) or features.dnn.flags.
local function is_dnn_glob(g)
    if type(g) ~= "string" then return false end
    for _, m in ipairs({ "3rdparty/mlas", "3rdparty/protobuf", "modules/dnn", "tu/mlasgemm" }) do
        if g:find(m, 1, true) then return true end
    end
    return false
end
local function ser_id(v) return ser(v, "") end

-- dnn's Vulkan compute backend (modules/dnn/src/vkcom/**) is dead code without a
-- Vulkan SDK (WITH_VULKAN is OFF in every headless profile); its sources #include
-- <opencv2/dnn.hpp> from a nested dir and fail mcpp's dependency scan off-linux.
-- Drop them from the feature entirely — CPU dnn inference is unaffected.
local function is_vkcom(s) return type(s) == "string" and s:find("modules/dnn/src/vkcom", 1, true) ~= nil end
-- windows ships NO mlas at all: its x86 kernels are GAS/ELF .S (not COFF-assemblable
-- under clang-cl), so the windows snapshot skips mlas and DNN uses its built-in
-- fast_gemm. Every mlas flag-glob (the group defines, the platform.cpp `-include
-- unistd.h` curated exception — which would also fail, windows has no unistd.h) is
-- therefore dead on windows -> drop them all.
local function is_mlas_glob(f)
    return type(f) == "table" and type(f.glob) == "string"
       and f.glob:find("3rdparty/mlas", 1, true) ~= nil
end
-- any mlas SOURCE (incl the curated mcpp_generated/mlas_hgemm_stub.cpp, which
-- #includes "mlas.h") — dead on windows where mlas is skipped entirely.
local function is_mlas_src(s) return type(s) == "string" and s:find("mlas", 1, true) ~= nil end
-- clsrc/opencl_kernels_<m>.cpp are written INERT by build.mcpp (cl2cpp) but never
-- compiled (OpenCL OFF in this headless profile, not registered as sources), so
-- their per-file flag-globs match nothing -> a permanent "[build].flags glob …
-- matched no source file" warning. Drop them entirely.
local function is_dead_opencl_glob(f)
    return type(f) == "table" and type(f.glob) == "string"
       and f.glob:find("clsrc/opencl_kernels", 1, true) ~= nil
end
local pkgs, order = {}, {}
for _, e in ipairs(INPUTS) do pkgs[e.os] = load_pkg(e.path); order[#order+1] = e.os end
local dnn_src, dnn_flg, base_flg = {}, {}, {}
for _, os_ in ipairs(order) do
    local p = pkgs[os_]
    local feat = (p.mcpp.features and p.mcpp.features.dnn) or {}
    local srcs, flgs, cleaned = {}, {}, {}
    local drop_mlas = (os_ == "windows")                      -- windows uses fast_gemm, no mlas
    for _, s in ipairs(feat.sources or {}) do
        if not is_vkcom(s) and not (drop_mlas and is_mlas_src(s)) then srcs[#srcs+1] = s end
    end
    for _, f in ipairs(feat.flags or {}) do
        if not (drop_mlas and is_mlas_glob(f)) then flgs[#flgs+1] = f end
    end
    for _, f in ipairs(p.mcpp.flags or {}) do
        if is_dead_opencl_glob(f) then                       -- drop: inert, never compiled
        elseif type(f) == "table" and is_dnn_glob(f.glob) then
            if not (drop_mlas and is_mlas_glob(f)) then flgs[#flgs+1] = f end
        else cleaned[#cleaned+1] = f end
    end
    dnn_src[os_], dnn_flg[os_], base_flg[os_] = srcs, flgs, cleaned
end

-- active = OSes that actually carry a dnn payload; common is their intersection
local active = {}
for _, os_ in ipairs(order) do if #dnn_src[os_] > 0 then active[#active+1] = os_ end end
local function split_common(map)
    if #active == 0 then return {}, {} end
    local counts = {}
    for _, os_ in ipairs(active) do
        local seen = {}
        for _, v in ipairs(map[os_]) do
            local id = ser_id(v)
            if not seen[id] then seen[id] = true; counts[id] = (counts[id] or 0) + 1 end
        end
    end
    local common, cids = {}, {}
    for _, v in ipairs(map[active[1]]) do
        local id = ser_id(v)
        if counts[id] == #active and not cids[id] then cids[id] = true; common[#common+1] = v end
    end
    local delta = {}
    for _, os_ in ipairs(order) do
        local d = {}
        for _, v in ipairs(map[os_] or {}) do if not cids[ser_id(v)] then d[#d+1] = v end end
        delta[os_] = d
    end
    return common, delta
end
-- `dnn` is an OS-only feature (mcpp#253): it exists only on the platforms whose
-- snapshot actually built it. Each such platform carries the FULL payload under
-- mcpp.<os>.features.dnn — there is NO neutral dnn, so a platform without it
-- cannot half-enable the feature. Windows is intentionally excluded: mlas's x86
-- kernels are GAS/ELF `.S` (`.type …,@function`), which clang-cl cannot assemble
-- to Windows COFF (would need the MASM amd64 `.asm` variant or a C++-only mlas).
local neutral_features = {}
for fname, fdef in pairs(base.mcpp.features or {}) do
    if fname ~= "dnn" then neutral_features[fname] = fdef end
end
local base_dnn = base.mcpp.features and base.mcpp.features.dnn
local dnn_defines = (base_dnn and base_dnn.defines) or { "HAVE_OPENCV_DNN" }
-- an OS "ships dnn" only if it built the actual module — gen_descriptor always
-- seeds features.dnn.sources with mcpp_generated/mlas_hgemm_stub.cpp even for a
-- videoio-only (non-dnn) snapshot, so a non-empty list is NOT enough.
local function ships_dnn(os_)
    for _, s in ipairs(dnn_src[os_] or {}) do
        if type(s) == "string" and s:find("modules/dnn", 1, true) then return true end
    end
    return false
end

merged.mcpp = {
    language = base.mcpp.language,
    targets  = base.mcpp.targets,
    features = neutral_features,
}
for _, os_ in ipairs(order) do
    local p = pkgs[os_]
    local blk = {}
    for _, k in ipairs(PEROS) do blk[k] = p.mcpp[k] end
    blk.flags = base_flg[os_]                       -- dnn-group globs stripped
    local sub = p.mcpp[os_]
    if sub and sub.ldflags then blk.ldflags = sub.ldflags end
    if ships_dnn(os_) then                           -- this OS ships dnn -> full payload
        blk.features = { dnn = { defines = dnn_defines, sources = dnn_src[os_], flags = dnn_flg[os_] } }
    end
    merged.mcpp[os_] = blk
end

-- ---- emit ----
local hdr = ([[-- Auto-generated by tools/compat-opencv/merge_opencv.lua — do not edit by hand.
-- OpenCV 5.0.0, multi-platform source build (linux-x86_64 + macosx-arm64).
-- Each mcpp.<os> block carries that platform's full frozen snapshot (include_dirs,
-- SIMD flags, sources, and ALL generated_files — zero global generated_files, per
-- mcpp's emplace-no-overwrite rule). Neutral keys (language/deps/targets/features)
-- stay top-level. Headless highgui on every platform (BUILTIN_BACKEND=NONE).
-- Regenerate: capture per-OS snapshots (snapshot-*-opencv.yml) -> gen_descriptor.py
-- -> merge_opencv.lua.
]])
local body = "package = " .. ser(merged, "") .. "\n"
local fh = assert(io.open(OUT, "w"))
fh:write(hdr, body)
fh:close()
io.write("wrote " .. OUT .. "\n")
