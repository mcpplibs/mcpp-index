-- Lint: a capability a package declares has a provider the package depends on.
--
-- A package says what its program needs from the machine at run time with
-- `runtime.capabilities` (`opengl.glx.driver`, `x11.display`, `vulkan.icd.driver`, ...).
-- A package that supplies one says so with `provides`, and the consumer lists it in `deps`
-- (compat.glfw depends on compat.glx-runtime, which provides the two GL ones). Nothing
-- connects the two spellings: a capability nobody provides, or one whose provider the package
-- does not depend on, is not an error anywhere. The program builds, and only on a machine
-- where the host does not happen to supply the thing does it fail, far from the cause.
-- compat.slint declared `display` and `opengl.egl.driver`, which no package provides, and
-- depended on no GL provider: on an NVIDIA X server GLX had no vendor and the program aborted
-- (.agents/docs/2026-11-22-host-driver-link-and-display-path-plan.md).
--
-- Two findings, per declared capability of a package P:
--   * nobody provides it, anywhere in the index;
--   * somebody does, but no package P depends on (directly or through other packages) does.
-- A package that provides a capability itself satisfies it.
--
-- A finding is a warning (exit 0); `--strict` makes any finding a failure.
--
-- Usage: lua5.4 tests/check_capability_providers.lua [--strict] pkgs/*/*.lua

function import(...)
    return setmetatable({}, {__index = function() return function() end end})
end

local strict, files = false, {}
for i = 1, #arg do
    if arg[i] == "--strict" then strict = true else files[#files + 1] = arg[i] end
end
if #files == 0 then
    io.stderr:write("usage: check_capability_providers.lua [--strict] <file.lua>...\n")
    os.exit(2)
end

-- Everything under `package.mcpp` (platform sections included): capabilities, provides, deps.
local function collect(node, acc)
    if type(node) ~= "table" then return end
    if type(node.capabilities) == "table" then
        for _, c in ipairs(node.capabilities) do if type(c) == "string" then acc.caps[c] = true end end
    end
    if type(node.provides) == "table" then
        for _, c in ipairs(node.provides) do if type(c) == "string" then acc.provides[c] = true end end
    end
    if type(node.deps) == "table" then
        for k, v in pairs(node.deps) do
            local spelled = type(k) == "string" and k or v
            if type(spelled) == "string" then acc.deps[(spelled:gsub("@.*$", ""))] = true end
        end
    end
    for k, v in pairs(node) do
        if type(v) == "table" and k ~= "capabilities" and k ~= "provides" and k ~= "deps" then collect(v, acc) end
    end
end

local packages = {}   -- [id] = {file=, caps=, provides=, deps=}
local providers = {}  -- [capability] = { [id] = true }
for _, f in ipairs(files) do
    package = nil
    local chunk = loadfile(f, "t")
    if chunk then
        pcall(chunk)
        local p = package
        if type(p) == "table" and type(p.name) == "string" and type(p.mcpp) == "table" then
            local id = (type(p.namespace) == "string" and p.namespace ~= "") and (p.namespace .. "." .. p.name) or p.name
            local acc = {file = f, caps = {}, provides = {}, deps = {}}
            collect(p.mcpp, acc)
            packages[id] = acc
            for c in pairs(acc.provides) do
                providers[c] = providers[c] or {}
                providers[c][id] = true
            end
        end
    end
end

-- Packages reachable from `id` through `deps` (not including `id`).
local function reachable(id)
    local seen, stack = {}, {id}
    while #stack > 0 do
        local cur = table.remove(stack)
        local pk = packages[cur]
        if pk then
            for dep in pairs(pk.deps) do
                if not seen[dep] then seen[dep] = true; stack[#stack + 1] = dep end
            end
        end
    end
    return seen
end

local findings = 0
local ids = {}
for id in pairs(packages) do ids[#ids + 1] = id end
table.sort(ids)
for _, id in ipairs(ids) do
    local pk = packages[id]
    local caps = {}
    for c in pairs(pk.caps) do caps[#caps + 1] = c end
    table.sort(caps)
    local reach
    for _, c in ipairs(caps) do
        local who = providers[c]
        if not who then
            findings = findings + 1
            print(string.format("::warning file=%s::%s declares the capability '%s' and no package in the index provides it", pk.file, id, c))
        elseif not pk.provides[c] then
            reach = reach or reachable(id)
            local ok = false
            for q in pairs(who) do if reach[q] then ok = true break end end
            if not ok then
                local names = {}
                for q in pairs(who) do names[#names + 1] = q end
                table.sort(names)
                findings = findings + 1
                print(string.format("::warning file=%s::%s declares the capability '%s' but depends on no package that provides it (%s does)", pk.file, id, c, table.concat(names, ", ")))
            end
        end
    end
end

if findings == 0 then print("Every declared capability has a provider the package depends on.") end
os.exit((strict and findings > 0) and 1 or 0)
