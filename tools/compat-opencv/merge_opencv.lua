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
local PEROS = { "include_dirs", "cxxflags", "cflags", "flags", "sources", "generated_files" }
merged.mcpp = {
    language = base.mcpp.language,
    deps     = base.mcpp.deps,
    targets  = base.mcpp.targets,
    features = base.mcpp.features,   -- unifont (neutral) + dnn (x86; opencv-dnn stays linux-only)
}
for _, e in ipairs(INPUTS) do
    local p = load_pkg(e.path)
    local blk = {}
    for _, k in ipairs(PEROS) do blk[k] = p.mcpp[k] end
    -- ldflags: the single-OS descriptor carries them in its own mcpp.<os> sub-block
    local sub = p.mcpp[e.os]
    if sub and sub.ldflags then blk.ldflags = sub.ldflags end
    merged.mcpp[e.os] = blk
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
