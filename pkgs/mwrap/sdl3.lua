-- Immutable upstream-aligned mwrap source release (sdl3-m mwrap-3.4.18).
-- The CN mirror is added by a maintainer with mcpp-res access; until then CN
-- users fall back to the GitHub release (docs/cn-mirror.md).
package = {
    spec = "1",
    namespace = "mcpplibs.mwrap",
    name = "sdl3",
    description = "sdl3-m: SDL 3 (window, input, audio, GPU and platform layer) as C++23 modules",
    licenses = { "Apache-2.0" },
    repo = "https://github.com/mcpplibs/sdl3-m",
    type = "package",
    extensions = {
        autoupdate = {
            tag = "mwrap-${version}",
            url = "https://github.com/mcpplibs/sdl3-m/releases/download/${tag}/sdl3-m-${version}.tar.gz",
        },
    },
    xpm = {
        linux = {
            ["3.4.18"] = {
                url = "https://github.com/mcpplibs/sdl3-m/releases/download/mwrap-3.4.18/sdl3-m-3.4.18.tar.gz",
                sha256 = "e056750efe3bdb9e03457cb202d7a17f9c942630637656f382ac0604d8a66d08",
            },
        },
        macosx = {
            ["3.4.18"] = {
                url = "https://github.com/mcpplibs/sdl3-m/releases/download/mwrap-3.4.18/sdl3-m-3.4.18.tar.gz",
                sha256 = "e056750efe3bdb9e03457cb202d7a17f9c942630637656f382ac0604d8a66d08",
            },
        },
        windows = {
            ["3.4.18"] = {
                url = "https://github.com/mcpplibs/sdl3-m/releases/download/mwrap-3.4.18/sdl3-m-3.4.18.tar.gz",
                sha256 = "e056750efe3bdb9e03457cb202d7a17f9c942630637656f382ac0604d8a66d08",
            },
        },
    },
}
