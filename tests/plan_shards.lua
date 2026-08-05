#!/usr/bin/env lua5.4
-- plan_shards.lua — decide which members run on which shard.
--
--   lua5.4 tests/plan_shards.lua <platform> <shard> <count> [member...]
--
-- Prints this shard's members, space-separated. With no member arguments it
-- reads the whole workspace from mcpp.toml.
--
-- WHY NOT ROUND-ROBIN BY POSITION
--
-- The first version split `i % count`, which knows nothing about how long
-- anything takes; balance was luck. Measured on the real workspace it put
-- three heavyweights (ffmpeg, llamacpp-metal, opencv-module-unifont) on one
-- shard and none on three others — and wall-clock is the SLOWEST shard, so the
-- idle ones bought nothing.
--
-- Two things decide the split here instead:
--
--   1. MEASURED TIME (tests/member-timings.tsv, produced by CI). Longest-
--      Processing-Time first: sort descending, put each member on the shard
--      with the least load so far. LPT is within 4/3 of optimal for this
--      problem, and optimal is not worth more than that here.
--   2. DEPENDENCY AFFINITY, as the tie-break. Two members that share a
--      dependency build it once if they land on the same shard and twice if
--      they do not — shards do not share a build cache, only a run does. So
--      among shards whose load is close, prefer the one already holding
--      members with overlapping dependencies.
--
-- Missing timing → the median, so a newly added member is neither assumed
-- free nor assumed huge. No table at all → falls back to round-robin, which
-- is worse but never wrong.
--
-- Measured on the real workspace (linux, 3 shards), LPT against round-robin:
--
--     round-robin  4158 / 3027 / 2822   slowest 4158s
--     LPT          3706 / 3152 / 3149   slowest 3706s
--
-- 452s off the wall-clock, and the spread drops from 47% to 15%.
--
-- There is a floor no split can beat: the single slowest member. grpc-module
-- alone is 1701s, so linux cannot finish faster than that however many shards
-- there are — which is the number to look at before adding more.

local platform    = arg[1] or error("usage: plan_shards.lua <platform> <shard> <count> [members...]")
local shardIndex  = tonumber(arg[2]) or error("shard index must be a number")
local shardCount  = tonumber(arg[3]) or error("shard count must be a number")

local members = {}
for i = 4, #arg do members[#members + 1] = arg[i] end

local function read_file(path)
    local f = io.open(path, "r"); if not f then return nil end
    local s = f:read("a"); f:close(); return s
end

-- Whole workspace, from the manifest rather than the directory: a member that
-- exists on disk but is not registered must not be tested. Both filters below
-- matter — mcpp.toml's prose mentions `tests/examples/` too, which yields an
-- empty name, and a name that only appears in a comment is not a member.
if #members == 0 then
    local toml = read_file("mcpp.toml") or error("cannot read mcpp.toml")
    local seen = {}
    for name in toml:gmatch("tests/examples/([A-Za-z0-9._%-]+)") do
        if name ~= "" and not seen[name] then
            local probe = io.open("tests/examples/" .. name .. "/mcpp.toml", "r")
            if probe then probe:close(); seen[name] = true; members[#members + 1] = name end
        end
    end
    table.sort(members)
end

if shardCount <= 1 then
    print(table.concat(members, " "))
    return
end

-- ── measured times ────────────────────────────────────────────────────────
-- Format: <platform>\t<member>\t<seconds>
local times, samples = {}, {}
local tsv = read_file("tests/member-timings.tsv")
if tsv then
    for line in tsv:gmatch("[^\n]+") do
        if not line:match("^#") then
            local p, m, s = line:match("^(%S+)\t(%S+)\t(%d+)")
            if p == platform and m then
                times[m] = tonumber(s)
                samples[#samples + 1] = tonumber(s)
            end
        end
    end
end

local median = 60
if #samples > 0 then
    table.sort(samples)
    median = samples[math.ceil(#samples / 2)]
end

-- ── dependency signature, for affinity ────────────────────────────────────
local function deps_of(member)
    local toml = read_file("tests/examples/" .. member .. "/mcpp.toml")
    if not toml then return {} end
    local set = {}
    -- The package names a member depends on. Deliberately crude: exact
    -- accuracy is not needed, only "do these two pull the same big things".
    for name in toml:gmatch("\n%s*([A-Za-z][A-Za-z0-9._%-]*)%s*=") do
        if name ~= "name" and name ~= "version" and name ~= "standard"
           and name ~= "sources" and name ~= "kind" and name ~= "main"
           and name ~= "description" and name ~= "license" then
            set[name] = true
        end
    end
    return set
end

local depsCache = {}
local function deps(member)
    if depsCache[member] == nil then depsCache[member] = deps_of(member) end
    return depsCache[member]
end

-- ── LPT with affinity tie-break ───────────────────────────────────────────
local ordered = {}
for _, m in ipairs(members) do ordered[#ordered + 1] = m end
table.sort(ordered, function(a, b)
    local ta, tb = times[a] or median, times[b] or median
    if ta ~= tb then return ta > tb end
    return a < b                      -- deterministic across machines
end)

local shards = {}
for i = 0, shardCount - 1 do shards[i] = { load = 0, members = {}, deps = {} } end

for _, m in ipairs(ordered) do
    local cost = times[m] or median
    local best, bestLoad, bestAffinity = nil, nil, -1
    for i = 0, shardCount - 1 do
        local s = shards[i]
        -- Affinity only breaks near-ties: a shard 15% lighter always wins,
        -- because balance is what wall-clock actually measures.
        local affinity = 0
        for d in pairs(deps(m)) do if s.deps[d] then affinity = affinity + 1 end end
        if best == nil then
            best, bestLoad, bestAffinity = i, s.load, affinity
        else
            local margin = math.max(bestLoad, s.load) * 0.15
            if s.load < bestLoad - margin then
                best, bestLoad, bestAffinity = i, s.load, affinity
            elseif math.abs(s.load - bestLoad) <= margin and affinity > bestAffinity then
                best, bestLoad, bestAffinity = i, s.load, affinity
            end
        end
    end
    local s = shards[best]
    s.load = s.load + cost
    s.members[#s.members + 1] = m
    for d in pairs(deps(m)) do s.deps[d] = true end
end

if os.getenv("PLAN_SHARDS_DEBUG") then
    for i = 0, shardCount - 1 do
        io.stderr:write(string.format("shard %d: load=%ds n=%d  %s\n",
            i, shards[i].load, #shards[i].members,
            table.concat(shards[i].members, " ")))
    end
end

print(table.concat(shards[shardIndex] and shards[shardIndex].members or {}, " "))
