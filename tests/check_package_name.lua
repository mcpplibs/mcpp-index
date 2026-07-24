-- Lint `package.name` against `package.namespace`.
--
-- Rule: a namespaced descriptor MUST spell `name` as the fully-qualified
-- `<namespace>.<short>`. The split form (namespace = "chriskohlhoff",
-- name = "asio") parses fine and passes `mcpp xpkg parse` — mcpp's own
-- identity layer normalizes both spellings to the same package — but it is
-- NOT installable from an index:
--
--   * xlings/libxpkg keys the index on the literal `package.name`
--     (libxpkg build_index → entries[package.name]), so the entry lands
--     under `asio`;
--   * mcpp asks xlings for the FQN it reconstructs from the consumer's
--     `[dependencies.<ns>] <short>`, i.e. `chriskohlhoff.asio`
--     (mcpp src/build/prepare.cppm — "xlings resolves packages by the full
--     qualified name (ns.shortName) as it appears in the index's name field").
--
-- The two never meet → E_NOT_FOUND at install time, on every platform, after
-- the workspace job has already burned an hour. No consumer-side spelling can
-- work around it; the descriptor is the only place it can be fixed.
--
-- Upstream: mcpp-community/mcpp#278 (mcpp should either use the declared name
-- or reject the split form in `mcpp xpkg parse`). Until that lands, this lint
-- is the index's guard.
--
-- Zero-namespace packages (the public default-namespace module packages —
-- imgui / ffmpeg / opencv) are unaffected: their bare `name` IS the FQN.
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

if ns ~= "" then
    local prefix = ns .. "."
    if name:sub(1, #prefix) ~= prefix then
        err(string.format(
            "package.name must be the fully-qualified '<namespace>.<short>': " ..
            "namespace = %q but name = %q — write name = %q. " ..
            "The split form registers the index entry under %q, which no " ..
            "consumer request can ever resolve (E_NOT_FOUND at install). " ..
            "See mcpp-community/mcpp#278.",
            ns, name, prefix .. name, name))
    elseif #name == #prefix then
        err(string.format(
            "package.name = %q has an empty short name after the %q prefix",
            name, prefix))
    end
end

os.exit(fail)
