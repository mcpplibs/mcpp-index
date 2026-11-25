-- Lint `package.namespace` against the build-plugin naming rule (mcpp#734;
-- mcpp SPEC-007 §9, "plugin names").
--
-- A build plugin names its modules `mcpp.<namespace>.*` after its own
-- package's namespace, and the second segments `core`, `plugins`, `deps`,
-- `rules`, `dist` and `tools` of `mcpp.` belong to the mcpp project: `mcpp.core`
-- is the engine's interface, the others are the families of mcpp-plugins. A
-- namespace spelled like one of them would make a third party's
-- `mcpp.<namespace>.*` indistinguishable from an official family, so the index
-- refuses such a namespace. The engine warns on the module names themselves;
-- the index can refuse, because it knows which namespaces are registered.
--
-- Usage: lua5.4 tests/check_reserved_namespace.lua <file.lua>

function import(...)
    return setmetatable({}, {__index = function() return function() end end})
end

local path = assert(arg[1], "usage: check_reserved_namespace.lua <file>")
package = nil
local chunk = assert(loadfile(path, "t"))
chunk()

local p = package
if type(p) ~= "table" then os.exit(0) end
local ns = p.namespace
if type(ns) ~= "string" then os.exit(0) end

local reserved = { core = true, plugins = true, deps = true, rules = true, dist = true, tools = true }
-- A build plugin `<owner>.mplugin.<name>` (docs/build-plugins.md) has its owner as the
-- first segment of its namespace. The owner is not `mcpp`, a name of the mcpp project's
-- (the reserved second segments, and its own packages: `platforms`) or a kind segment.
local owner = ns:match("^([^.]+)%.mplugin$")
if owner then
    local barred = { mcpp = true, platforms = true, mwrap = true, mplugin = true }
    if reserved[owner] or barred[owner] then
        io.stderr:write(string.format(
            "::error file=%s::owner '%s' of a build plugin is reserved (the mcpp project's names, or a kind segment); " ..
            "an owner is who maintains the package (docs/build-plugins.md)\n", path, owner))
        os.exit(1)
    end
end

local first = ns:match("^([^.]+)")
if first and reserved[first] then
    io.stderr:write(string.format(
        "::error file=%s::namespace '%s' is reserved: `mcpp.%s.*` names modules of the mcpp project " ..
        "(mcpp SPEC-007 §9), so a plugin of this namespace could not be told from an official one\n",
        path, ns, first))
    os.exit(1)
end
os.exit(0)
