-- Immutable upstream-aligned mwrap source release (pocketpy-m mwrap-2.2.0).
-- The CN mirror is added by a maintainer with mcpp-res access; until then CN
-- users fall back to the GitHub release (docs/cn-mirror.md).
package = {
    spec = "1",
    namespace = "mcpplibs.mwrap",
    name = "pocketpy",
    description = "pocketpy-m: PocketPy (the small embeddable Python 3 interpreter) as C++23 modules",
    licenses = { "Apache-2.0" },
    repo = "https://github.com/mcpplibs/pocketpy-m",
    type = "package",
    extensions = {
        autoupdate = {
            tag = "mwrap-${version}",
            url = "https://github.com/mcpplibs/pocketpy-m/releases/download/${tag}/pocketpy-m-${version}.tar.gz",
        },
    },
    xpm = {
        linux = {
            ["2.2.0"] = {
                url = "https://github.com/mcpplibs/pocketpy-m/releases/download/mwrap-2.2.0/pocketpy-m-2.2.0.tar.gz",
                sha256 = "bcc3174ff442f9337652d14fdb8da19a6c406e36bc4ffbd3a5afc98035135024",
            },
        },
        macosx = {
            ["2.2.0"] = {
                url = "https://github.com/mcpplibs/pocketpy-m/releases/download/mwrap-2.2.0/pocketpy-m-2.2.0.tar.gz",
                sha256 = "bcc3174ff442f9337652d14fdb8da19a6c406e36bc4ffbd3a5afc98035135024",
            },
        },
        windows = {
            ["2.2.0"] = {
                url = "https://github.com/mcpplibs/pocketpy-m/releases/download/mwrap-2.2.0/pocketpy-m-2.2.0.tar.gz",
                sha256 = "bcc3174ff442f9337652d14fdb8da19a6c406e36bc4ffbd3a5afc98035135024",
            },
        },
    },
}
