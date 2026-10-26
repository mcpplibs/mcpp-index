-- Print what each descriptor declares about itself and about its neighbours:
--
--     <file> TAB <namespace> TAB <name> TAB <dependency>,... TAB <archive>#<manifest> ...
--
-- A dependency is a key of any `deps` table inside `package`, spelled as the
-- descriptor spells it (`compat.openssl`, `compat:openssl`, `zlib`); the
-- reader of this output (tests/select_members.py) resolves the spelling
-- against the identities printed here.
--
-- The last column is where the rest of the package's dependencies are stated
-- when the descriptor does not state them: a package whose `mcpp` is not an
-- inline table builds from the manifest inside its archive (`mcpp =
-- "*/ld/mcpp.toml"`, or `mcpp.toml` at the archive's root when the field is
-- absent). One entry per version: the archive's GLOBAL url, `#`, and the
-- manifest's path inside it, prefixed with `?` when the field is absent --
-- the archive may then hold no manifest at all (a package built by xpm, or
-- one whose install() writes it). A descriptor that does not load prints no line.
--
-- Usage: lua5.4 tests/descriptor_identities.lua pkgs/*/*.lua

function import(...)
    return setmetatable({}, {__index = function() return function() end end})
end

local function collect(t, out, seen)
    if seen[t] then return end
    seen[t] = true
    for k, v in pairs(t) do
        if k == "deps" and type(v) == "table" then
            for dk, dv in pairs(v) do
                if type(dk) == "string" then out[dk] = true
                elseif type(dv) == "string" then out[dv] = true end
            end
        end
        if type(v) == "table" then collect(v, out, seen) end
    end
end

for i = 1, #arg do
    package = nil
    local chunk = loadfile(arg[i], "t")
    if chunk then
        -- `package = { ... }` is the first statement, so it is populated even
        -- if a later top-level line fails under the stubbed `import`.
        pcall(chunk)
        local p = package
        if type(p) == "table" and type(p.name) == "string" then
            local deps = {}
            collect(p, deps, {})
            local list = {}
            for d in pairs(deps) do list[#list + 1] = d end
            table.sort(list)
            local manifests = {}
            if type(p.mcpp) ~= "table" then
                local inside = "?mcpp.toml"
                if type(p.mcpp) == "string" then inside = (p.mcpp:gsub("^%*/", "")) end
                local seen = {}
                for _, versions in pairs(type(p.xpm) == "table" and p.xpm or {}) do
                    for _, entry in pairs(type(versions) == "table" and versions or {}) do
                        local url = type(entry) == "table" and entry.url
                        if type(url) == "table" then url = url.GLOBAL end
                        if type(url) == "string" and not seen[url] then
                            seen[url] = true
                            manifests[#manifests + 1] = url .. "#" .. inside
                        end
                    end
                end
                table.sort(manifests)
            end
            print(table.concat({ arg[i],
                                 type(p.namespace) == "string" and p.namespace or "",
                                 p.name, table.concat(list, ","),
                                 table.concat(manifests, " ") }, "\t"))
        end
    end
end
