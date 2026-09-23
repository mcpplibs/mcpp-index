-- Lint the GLOBAL/CN mirror tables in a package descriptor.
--
-- Rules (only applied to `url` fields written in table form — plain-string
-- urls remain valid and are left to the author):
--   * a url table must define BOTH `GLOBAL` and `CN`
--   * both values must be non-empty strings
--   * `CN` must be a gitcode.com/<owner>/<repo>/releases/download/... URL.
--     The owner is usually the index's `mcpp-res` organization, and may be
--     the library's own maintainer, who then keeps that mirror in step with
--     the GLOBAL asset (same bytes, same sha256).
--   * `GLOBAL` must not itself point at the mcpp-res CN mirror
--
-- Usage: lua5.4 tests/check_mirror_urls.lua <file.lua>
-- Exit non-zero (and print ::error lines) on the first violation in the file.

function import(...)
    return setmetatable({}, {__index = function() return function() end end})
end

local path = assert(arg[1], "usage: check_mirror_urls.lua <file>")
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

local function check_url(ctx, u)
    if type(u) == "string" then return end          -- plain url: fine
    if type(u) ~= "table" then
        err(ctx .. ": url must be a string or { GLOBAL=..., CN=... } table")
        return
    end
    local g, c = u.GLOBAL, u.CN
    if type(g) ~= "string" or g == "" then
        err(ctx .. ": url table missing non-empty GLOBAL")
    end
    if type(c) ~= "string" or c == "" then
        err(ctx .. ": url table missing non-empty CN")
    end
    if type(c) == "string"
            and not c:match("^https://gitcode%.com/[^/]+/[^/]+/releases/download/[^/]+/[^/]+$") then
        err(ctx .. ": CN url must be a gitcode.com release asset, "
            .. "https://gitcode.com/<owner>/<repo>/releases/download/<tag>/<file> (got "
            .. tostring(c) .. ")")
    end
    if type(g) == "string" and g:match("^https://gitcode%.com/mcpp%-res/") then
        err(ctx .. ": GLOBAL url must not point at the CN mirror")
    end
end

local xpm = p.xpm or {}
for plat, vt in pairs(xpm) do
    if type(vt) == "table" then
        for ver, entry in pairs(vt) do
            if type(entry) == "table" and entry.url ~= nil then
                check_url(string.format("%s/%s/%s", p.name or "?", tostring(plat), tostring(ver)), entry.url)
            end
        end
    end
end

os.exit(fail)
