-- Form A descriptor: the upstream repo ships its own mcpp.toml from
-- 0.0.3 onwards, so we omit the `mcpp` field — mcpp default-look-up
-- finds <verdir>/lua-<tag>/mcpp.toml inside the GitHub tarball wrap.
package = {
    spec        = "1",
    namespace = "mcpplibs.capi",
    name        = "mcpplibs.capi.lua",
    description = "C++23 module wrapping the Lua 5.4 C API — `import mcpplibs.capi.lua;`",
    licenses    = {"Apache-2.0"},
    repo        = "https://github.com/mcpplibs/lua",
    type        = "package",

    xpm = {
        linux = {
            ["0.0.3"] = {
                url    = "https://github.com/mcpplibs/lua/archive/refs/tags/0.0.3.tar.gz",
                sha256 = "f7f46c3cd193dc4527be5f3e5cfc29d7e322d5d3db56b9bdb060f289090088d6",
            },
        },
        macosx = {
            ["0.0.3"] = {
                url    = "https://github.com/mcpplibs/lua/archive/refs/tags/0.0.3.tar.gz",
                sha256 = "f7f46c3cd193dc4527be5f3e5cfc29d7e322d5d3db56b9bdb060f289090088d6",
            },
        },
        windows = {
            ["0.0.3"] = {
                url    = "https://github.com/mcpplibs/lua/archive/refs/tags/0.0.3.tar.gz",
                sha256 = "f7f46c3cd193dc4527be5f3e5cfc29d7e322d5d3db56b9bdb060f289090088d6",
            },
        },
    },
}
