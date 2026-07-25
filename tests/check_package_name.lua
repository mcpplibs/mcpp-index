-- Lint `package.name` against `package.namespace` (mcpp SPEC-001 §3.2).
--
-- Identity is the pair `(namespace, name)`: `namespace` is the dotted,
-- hierarchical path and `name` is a SINGLE ATOMIC SEGMENT. All depth belongs
-- in the namespace.
--
--     namespace = "chriskohlhoff", name = "asio"          -- ok
--     namespace = "mcpplibs.capi", name = "lua"           -- ok
--     namespace = "compat",        name = "compat.zlib"   -- ok (legacy form)
--     namespace = "mcpplibs",      name = "capi.lua"      -- REJECTED
--
-- Why the last one is rejected rather than reinterpreted: a `name` carrying
-- dots the namespace does not account for describes a package whose namespace
-- nobody declared. mcpp used to split such a name on its LAST dot and silently
-- invent `(mcpplibs.capi, lua)`. Since 0.0.106 it refuses to guess.
--
-- LEGACY FORM: descriptors published before SPEC-001 repeat the namespace
-- inside `name`. That prefix is stripped before judging, so they keep passing —
-- the wire key is the literal `name` either way, so they stay installable
-- unchanged.
--
-- HISTORY: mcpp 0.0.105 briefly required the OPPOSITE (name must be the
-- fully-qualified form). That was an encoding constraint, not a design rule: it
-- existed only because mcpp re-derived the wire name instead of using the
-- literal it had already read. See mcpp-community/mcpp#278 and mcpp
-- docs/spec/package-identity.md.
--
-- mcpp >= 0.0.106 enforces the same rule inside `mcpp xpkg parse`; this lint is
-- a cheaper, earlier second gate that runs before the pinned mcpp is fetched.
--
-- Usage: lua5.4 tests/check_package_name.lua <file.lua>

function import(...)
    return setmetatable({}, {__index = function() return function() end end})
end

local path = assert(arg[1], "usage: check_package_name.lua <file>")
package = nil
local chunk = assert(loadfile(path, "t"))
chunk()

local p = package
if type(p) ~= "table" then os.exit(0) end

local fail = 0
local function err(msg)
    io.stderr:write(string.format("::error file=%s::%s\n", path, msg))
    fail = 1
end

local name = p.name
local ns   = p.namespace or ""

if type(name) ~= "string" or name == "" then
    err("package.name must be a non-empty string")
    os.exit(fail)
end
if type(ns) ~= "string" then
    err("package.namespace must be a string")
    os.exit(fail)
end

local shortName = name
if ns ~= "" then
    local prefix = ns .. "."
    if name:sub(1, #prefix) == prefix then
        if #name == #prefix then
            err(string.format(
                "package.name = %q has an empty short name after the %q prefix",
                name, prefix))
            os.exit(fail)
        end
        -- Legacy fully-qualified spelling: judge what follows the prefix.
        shortName = name:sub(#prefix + 1)
    end
end

if shortName:find(".", 1, true) then
    local head = shortName:match("^(.*)%.[^.]*$")
    local tail = shortName:match("([^.]*)$")
    local suggestedNs = (ns ~= "") and (ns .. "." .. head) or head
    err(string.format(
        "package.name must be a single atomic segment — the hierarchy belongs " ..
        "in package.namespace. namespace = %q, name = %q leaves short name %q, " ..
        "which still contains a '.'. Identity is (namespace, name): `namespace` " ..
        "is the dotted path, `name` is ONE segment — so this names a namespace " ..
        "nobody declared. Write namespace = %q, name = %q. See mcpp " ..
        "docs/spec/package-identity.md §3.2.",
        ns, name, shortName, suggestedNs, tail))
end

os.exit(fail)
