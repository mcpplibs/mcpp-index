-- Lint the build-plugin layout (docs/build-plugins.md).
--
-- A descriptor whose namespace is `<owner>.mplugin` is a build plugin: it lives in
-- pkgs/mcpp/, and its owner and name are lower-case identifiers. The other way
-- round, a file in pkgs/mcpp/ is a package of the mcpp project (namespace `mcpp`)
-- or a build plugin. The directory is what mcpp itself loads, not what a package
-- is (mcpp.platforms is platform data), so the layout is the only thing checked
-- here; the reserved owners are tests/check_reserved_namespace.lua.
--
-- Usage: lua5.4 tests/check_mplugin_layout.lua <file.lua>

function import(...)
    return setmetatable({}, {__index = function() return function() end end})
end

local path = assert(arg[1], "usage: check_mplugin_layout.lua <file>")
package = nil
local chunk = assert(loadfile(path, "t"))
chunk()

local p = package
if type(p) ~= "table" or type(p.namespace) ~= "string" then os.exit(0) end
local ns, name = p.namespace, p.name

local dir = path:match("^(.*)/[^/]+$") or ""
local in_mcpp_dir = dir == "pkgs/mcpp" or dir:match("/pkgs/mcpp$") ~= nil
local owner = ns:match("^([^.]+)%.mplugin$")
local function fail(msg)
    io.stderr:write(string.format("::error file=%s::%s\n", path, msg))
    os.exit(1)
end

if owner then
    if not in_mcpp_dir then
        fail(string.format("a build plugin ('%s.%s') is a descriptor of pkgs/mcpp/ (docs/build-plugins.md)", ns, tostring(name)))
    end
    if not owner:match("^[a-z][a-z0-9_]*$") then
        fail(string.format("owner '%s' of a build plugin is a lower-case identifier [a-z][a-z0-9_]*", owner))
    end
    if type(name) ~= "string" or not name:match("^[a-z][a-z0-9_]*$") then
        fail(string.format("name '%s' of a build plugin is a lower-case identifier [a-z][a-z0-9_]* (use _, not -)", tostring(name)))
    end
elseif in_mcpp_dir then
    if ns ~= "mcpp" then
        fail(string.format("pkgs/mcpp/ holds packages of namespace 'mcpp' and build plugins '<owner>.mplugin', not '%s'", ns))
    end
end
os.exit(0)
