-- Immutable upstream-aligned mwrap source release (md4c-m mwrap-0.5.3).
-- The CN mirror is added by a maintainer with mcpp-res access; until then CN
-- users fall back to the GitHub release (docs/cn-mirror.md).
package = {
    spec = "1",
    namespace = "mcpplibs.mwrap",
    name = "md4c",
    description = "md4c-m: MD4C (CommonMark / GFM Markdown parser and md4c-html renderer) as C++23 modules",
    licenses = { "Apache-2.0" },
    repo = "https://github.com/mcpplibs/md4c-m",
    type = "package",
    extensions = {
        autoupdate = {
            tag = "mwrap-${version}",
            url = "https://github.com/mcpplibs/md4c-m/releases/download/${tag}/md4c-m-${version}.tar.gz",
        },
    },
    xpm = {
        linux = {
            ["0.5.3"] = {
                url = "https://github.com/mcpplibs/md4c-m/releases/download/mwrap-0.5.3/md4c-m-0.5.3.tar.gz",
                sha256 = "10f7cdffab919bc97e2cf713c0a784e698568eca8a2331ab386515e5bf7743ac",
            },
        },
        macosx = {
            ["0.5.3"] = {
                url = "https://github.com/mcpplibs/md4c-m/releases/download/mwrap-0.5.3/md4c-m-0.5.3.tar.gz",
                sha256 = "10f7cdffab919bc97e2cf713c0a784e698568eca8a2331ab386515e5bf7743ac",
            },
        },
        windows = {
            ["0.5.3"] = {
                url = "https://github.com/mcpplibs/md4c-m/releases/download/mwrap-0.5.3/md4c-m-0.5.3.tar.gz",
                sha256 = "10f7cdffab919bc97e2cf713c0a784e698568eca8a2331ab386515e5bf7743ac",
            },
        },
    },
}
