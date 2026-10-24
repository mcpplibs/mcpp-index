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
-- Missing timing → a FIXED default (see DEFAULT_SECONDS), so a newly added
-- member is neither assumed free nor assumed huge. No table at all → every
-- member prices the same, which degenerates to round-robin: worse, never
-- wrong.
--
-- The table deliberately holds only the HEAVY members. They are where the
-- packing decisions actually get made — on linux the top 10 of 67 are 69% of
-- the total — and listing the other 57 buys a table that goes stale every
-- time someone adds a test. Verified equivalent: full table and top-10 table
-- both land the slowest linux shard at 74 minutes.
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
    for _, category in ipairs({"examples", "mwrap"}) do
        for name in toml:gmatch("tests/" .. category .. "/([A-Za-z0-9._%-]+)") do
            if name ~= "" and not seen[name] then
                local probe = io.open("tests/" .. category .. "/" .. name .. "/mcpp.toml", "r")
                if probe then probe:close(); seen[name] = true; members[#members + 1] = name end
            end
        end
    end
    table.sort(members)
end

-- ── measured times ────────────────────────────────────────────────────────
-- Format: <platform>\t<member>\t<seconds>
local times = {}
local tsv = read_file("tests/member-timings.tsv")
if tsv then
    for line in tsv:gmatch("[^\n]+") do
        if not line:match("^#") then
            local p, m, s = line:match("^(%S+)\t(%S+)\t(%d+)")
            if p == platform and m then times[m] = tonumber(s) end
        end
    end
end

-- Price for a member with no row. A FIXED constant, deliberately, and not the
-- median of whatever the table happens to hold.
--
-- The table only carries the HEAVY members now (see its header). Deriving the
-- default from those samples would take the median OF THE HEAVYWEIGHTS —
-- measured at 875s on the linux set — and charge every small member that,
-- which packs far worse than having no table at all. Simulated on the full
-- 67-member measurement, 4 linux shards, slowest shard:
--
--     full 67-row table                    74 min
--     top-10 table, median-derived default 90 min   <- at the job cap
--     top-10 table, fixed default          74 min
--
-- 86s is the mean of the 57 untimed linux members (median 24s); 90 rounds it.
-- The choice is not delicate: across defaults from 30s to 300s the slowest
-- shard stays between 72 and 84 minutes, all under the 90-minute cap. That
-- insensitivity is the point — it is what lets the table sit untouched while
-- small members come and go.
--
-- What it does NOT absorb is a new member that belongs in the heavy set.
-- `mysql-connector-cpp` (881s) priced at the default is 13 minutes of work
-- that the packer cannot see. Adding a heavy newcomer stays a real edit.
local DEFAULT_SECONDS = 90
local median = DEFAULT_SECONDS   -- name kept: read as "the price of unknown"

-- `<shard> <count>` of `0 0` prints this platform's TOTAL cost instead of a
-- shard's members.
--
-- The workflow's shards_for needs exactly that number to pick a shard count,
-- and it needs it computed the same way: same member enumeration, same price
-- for an untimed member. It used to sum the table's rows directly, which was
-- equivalent only while the table listed every member. It no longer does —
-- summing 10 heavy rows and calling it the workload asks for 3 linux shards
-- where the real work needs 4, and 3 lands the slowest shard at 107 minutes
-- against a 90-minute cap. Two copies of "how much work is there" drift; this
-- is the one copy.
if shardCount == 0 then
    local total = 0
    for _, m in ipairs(members) do total = total + (times[m] or DEFAULT_SECONDS) end
    print(total)
    return
end

-- ── run order: cheapest first ─────────────────────────────────────────────
--
-- Packing and ORDER are different questions. LPT has to consider members
-- descending or the bins come out lopsided, and that stays exactly as it was;
-- this only decides the sequence a shard hands to run_members.sh.
--
-- Cheapest first so that BREADTH is covered early, and a maintainer can act on
-- the run before it finishes.
--
-- That is the reason, and it is a deliberate one: occasionally a change is
-- worth merging once the core is demonstrably covered, without waiting out the
-- tail. A full linux run is 13427s of member wall-clock and four members are
-- 52% of it (grpc-codegen 3363s, grpc-module 1724s, opencv-module-dnn 1017s,
-- protobuf-protoc 945s). Ordered this way, ~55 members have reported before
-- the first heavyweight even starts — so "everything but the four known
-- expensive ones is green" is a state that exists, early, and can be judged.
-- With the expensive members leading, the run has no such intermediate state:
-- it is uninformative for an hour and then complete.
--
-- Read the consequence the same way. A shard that hits its timeout now loses
-- the expensive members rather than the cheap ones — which is the half a
-- maintainer would choose to skip anyway, few in number and named in
-- tests/member-timings.tsv.
local function cheapest_first(list)
    table.sort(list, function(a, b)
        local ta, tb = times[a] or median, times[b] or median
        if ta ~= tb then return ta < tb end
        return a < b                  -- deterministic across machines
    end)
    return list
end

if shardCount <= 1 then
    print(table.concat(cheapest_first(members), " "))
    return
end

-- ── dependency signature, for affinity ────────────────────────────────────
local function deps_of(member)
    local toml = read_file("tests/examples/" .. member .. "/mcpp.toml")
        or read_file("tests/mwrap/" .. member .. "/mcpp.toml")
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

print(table.concat(
    cheapest_first(shards[shardIndex] and shards[shardIndex].members or {}), " "))
