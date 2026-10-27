-- Immutable upstream-aligned mwrap source release (lua-m mwrap-5.4.7).
-- The CN mirror is added by a maintainer with mcpp-res access; until then CN
-- users fall back to the GitHub release (docs/cn-mirror.md).
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
            ["5.4.7"] = {
                url = "https://github.com/mcpplibs/lua-m/releases/download/mwrap-5.4.7/lua-m-5.4.7.tar.gz",
                sha256 = "75716263adb28f79e01048c73e8a7193bae5fb68baf18d93d937706b9ca7c1d5",
            },
        },
        macosx = {
            ["5.4.7"] = {
                url = "https://github.com/mcpplibs/lua-m/releases/download/mwrap-5.4.7/lua-m-5.4.7.tar.gz",
                sha256 = "75716263adb28f79e01048c73e8a7193bae5fb68baf18d93d937706b9ca7c1d5",
            },
        },
        windows = {
            ["5.4.7"] = {
                url = "https://github.com/mcpplibs/lua-m/releases/download/mwrap-5.4.7/lua-m-5.4.7.tar.gz",
                sha256 = "75716263adb28f79e01048c73e8a7193bae5fb68baf18d93d937706b9ca7c1d5",
            },
        },
    },
}
