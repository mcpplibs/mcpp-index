-- Lint cross-package references inside descriptor hooks.
--
-- An `install()` hook may address a SIBLING package to read its files:
--
--     pkginfo.install_dir("compat:xcb-proto", "1.17.0")
--     pkginfo.build_dep("xim:python")
--
-- The string is an ADDRESS, resolved as `<namespace>:<literal package.name>`.
-- Nothing type-checks it: a miss just returns nil, and the hook either bails
-- with a vague message or — worse — carries on with a path that was never
-- populated. Both happened for real. When SPEC-001 shortened every `name`
-- (`compat.xcb-proto` -> `xcb-proto`), two hooks kept addressing the old
-- spelling; `compat.xcb` failed to install, and `compat.x11` silently
-- generated empty keysym tables because it only checked for nil, not isdir.
-- CI saw it three levels downstream as `libX11.so: undefined reference to
-- xcb_connection_has_error`.
--
-- So: whenever a descriptor addresses a package THIS repository publishes,
-- at least one spelling must match a declared identity.
--
-- Two deliberate loosenings:
--
--   * Descriptors write a LADDER of spellings — the canonical one first, then
--     pre-SPEC-001 fallbacks so the file also resolves against an index that
--     has not migrated. Only the group as a whole must resolve, never each
--     literal, or every legacy fallback would be flagged.
--
--   * References into a namespace this repo does not publish (`xim:python`)
--     name a package in another index and cannot be checked here. If any
--     spelling in a group is foreign, the whole group is skipped — bare
--     `"python"` is a fallback for `"xim:python"`, not a local package.
--
-- Matching mirrors what xlings actually does, and is deliberately NOT lenient:
-- `"compat:compat.xcb-proto"` must match a descriptor whose `name` is
-- literally `compat.xcb-proto`. Normalising the dots away here would have
-- called the broken reference resolvable and missed the very bug this exists
-- to catch.
--
-- Usage: lua5.4 tests/check_cross_package_refs.lua pkgs/*/*.lua

function import(...)
    return setmetatable({}, {__index = function() return function() end end})
end

local files = {}
for i = 1, #arg do files[#files + 1] = arg[i] end
if #files == 0 then
    io.stderr:write("usage: check_cross_package_refs.lua <file.lua>...\n")
    os.exit(2)
end

-- ── Pass 1: every identity this repository declares ──────────────────
local declared = {}   -- ["<ns>:<literal name>"] = true
local byName   = {}   -- ["<literal name>"]      = true   (bare addressing)
local ownedNs  = {}   -- ["<ns>"]                = true

for _, f in ipairs(files) do
    package = nil
    local chunk = loadfile(f, "t")
    if chunk then
        -- `package = { ... }` is the first statement, so it is populated even
        -- if some later top-level line blows up under the stubbed `import`.
        pcall(chunk)
        local p = package
        if type(p) == "table" and type(p.name) == "string" then
            local ns = type(p.namespace) == "string" and p.namespace or ""
            declared[ns .. ":" .. p.name] = true
            byName[p.name] = true
            if ns ~= "" then ownedNs[ns] = true end
        end
    end
end

-- ── Pass 2: the references, grouped by the package they address ──────
local fail = 0
local function err(file, msg)
    io.stderr:write(string.format("::error file=%s::%s\n", file, msg))
    fail = 1
end

for _, f in ipairs(files) do
    local src = io.open(f, "r")
    if src then
        local text = src:read("a")
        src:close()

        -- group key -> { foreign = bool, resolved = bool, spellings = {...} }
        local groups, order = {}, {}
        for fn, ref in text:gmatch("pkginfo%.([%w_]+)%s*%(%s*[\"']([^\"']+)[\"']") do
            if fn == "install_dir" or fn == "build_dep" or fn == "dep_dir" then
                local ns, rest = ref:match("^([^:]+):(.+)$")
                local resolved, foreign
                if ns then
                    foreign  = not ownedNs[ns]
                    resolved = declared[ns .. ":" .. rest] == true
                else
                    -- Bare address: no namespace stated, so it can only be
                    -- matched against literal names.
                    foreign  = false
                    resolved = byName[ref] == true
                end

                -- The addressed package, independent of spelling: drop the
                -- namespace prefix and any legacy dotted lead-in.
                local key = (rest or ref):match("([^.]+)$")
                local g = groups[key]
                if not g then
                    g = { foreign = false, resolved = false, spellings = {} }
                    groups[key] = g
                    order[#order + 1] = key
                end
                g.foreign  = g.foreign or foreign
                g.resolved = g.resolved or resolved
                g.spellings[#g.spellings + 1] = ref
            end
        end

        for _, key in ipairs(order) do
            local g = groups[key]
            if not g.foreign and not g.resolved then
                err(f, string.format(
                    "cross-package reference to %q resolves to no declared " ..
                    "identity. Tried: %s. An address is `<namespace>:<literal " ..
                    "package.name>` — check the target descriptor's `name` " ..
                    "(SPEC-001 shortened these) and put the current spelling " ..
                    "first, keeping older ones as `or` fallbacks. See mcpp " ..
                    "docs/spec/package-identity.md §6.",
                    key, table.concat(g.spellings, ", ")))
            end
        end
    end
end

os.exit(fail)
