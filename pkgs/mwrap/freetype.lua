-- Immutable upstream-aligned mwrap source release (freetype-m mwrap-2.13.3).
-- The CN mirror is added by a maintainer with mcpp-res access; until then CN
-- users fall back to the GitHub release (docs/cn-mirror.md).
package = {
    spec = "1",
    namespace = "mcpplibs.mwrap",
    name = "freetype",
    description = "freetype-m: FreeType 2 (the portable font engine) as C++23 modules",
    licenses = { "Apache-2.0" },
    repo = "https://github.com/mcpplibs/freetype-m",
    type = "package",
    extensions = {
        autoupdate = {
            tag = "mwrap-${version}",
            url = "https://github.com/mcpplibs/freetype-m/releases/download/${tag}/freetype-m-${version}.tar.gz",
        },
    },
    xpm = {
        linux = {
            ["2.13.3"] = {
                url = "https://github.com/mcpplibs/freetype-m/releases/download/mwrap-2.13.3/freetype-m-2.13.3.tar.gz",
                sha256 = "a9c2d5dc03be08139ceb49d5487346b8130ed2702f5ff464e3584ef7aea16cca",
            },
        },
        macosx = {
            ["2.13.3"] = {
                url = "https://github.com/mcpplibs/freetype-m/releases/download/mwrap-2.13.3/freetype-m-2.13.3.tar.gz",
                sha256 = "a9c2d5dc03be08139ceb49d5487346b8130ed2702f5ff464e3584ef7aea16cca",
            },
        },
        windows = {
            ["2.13.3"] = {
                url = "https://github.com/mcpplibs/freetype-m/releases/download/mwrap-2.13.3/freetype-m-2.13.3.tar.gz",
                sha256 = "a9c2d5dc03be08139ceb49d5487346b8130ed2702f5ff464e3584ef7aea16cca",
            },
        },
    },
}
