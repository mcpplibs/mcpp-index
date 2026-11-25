-- Immutable upstream-aligned mwrap source release (lua-m mwrap-5.4.7).
-- The CN mirror is added by a maintainer with mcpp-res access; until then CN
-- users fall back to the GitHub release (docs/cn-mirror.md).
--
-- 5.4.7.1 is a wrapper revision: its templates write the dependency selector
-- unquoted (`mcpplibs.mwrap.lua = ...`); the quoted form is deprecated
-- since mcpp 2026.11.8.1 and removed in 2027.2.
package = {
    spec = "1",
    namespace = "mcpplibs.mwrap",
    name = "lua",
    description = "lua-m: Lua 5.4 (the embeddable scripting language) as C++23 modules",
    licenses = { "Apache-2.0" },
    repo = "https://github.com/mcpplibs/lua-m",
    type = "package",
    extensions = {
        autoupdate = {
            tag = "mwrap-${version}",
            url = "https://github.com/mcpplibs/lua-m/releases/download/${tag}/lua-m-${version}.tar.gz",
        },
    },
    xpm = {
        linux = {
            ["5.4.7.1"] = {
                url = "https://github.com/mcpplibs/lua-m/releases/download/mwrap-5.4.7.1/lua-m-5.4.7.1.tar.gz",
                sha256 = "1636a90c2bce110625a325b7633ddf3f85a850c03ad0c1be75e82d79709465ea",
            },
            ["5.4.7"] = {
                url = "https://github.com/mcpplibs/lua-m/releases/download/mwrap-5.4.7/lua-m-5.4.7.tar.gz",
                sha256 = "75716263adb28f79e01048c73e8a7193bae5fb68baf18d93d937706b9ca7c1d5",
            },
        },
        macosx = {
            ["5.4.7.1"] = {
                url = "https://github.com/mcpplibs/lua-m/releases/download/mwrap-5.4.7.1/lua-m-5.4.7.1.tar.gz",
                sha256 = "1636a90c2bce110625a325b7633ddf3f85a850c03ad0c1be75e82d79709465ea",
            },
            ["5.4.7"] = {
                url = "https://github.com/mcpplibs/lua-m/releases/download/mwrap-5.4.7/lua-m-5.4.7.tar.gz",
                sha256 = "75716263adb28f79e01048c73e8a7193bae5fb68baf18d93d937706b9ca7c1d5",
            },
        },
        windows = {
            ["5.4.7.1"] = {
                url = "https://github.com/mcpplibs/lua-m/releases/download/mwrap-5.4.7.1/lua-m-5.4.7.1.tar.gz",
                sha256 = "1636a90c2bce110625a325b7633ddf3f85a850c03ad0c1be75e82d79709465ea",
            },
            ["5.4.7"] = {
                url = "https://github.com/mcpplibs/lua-m/releases/download/mwrap-5.4.7/lua-m-5.4.7.tar.gz",
                sha256 = "75716263adb28f79e01048c73e8a7193bae5fb68baf18d93d937706b9ca7c1d5",
            },
        },
    },
}
