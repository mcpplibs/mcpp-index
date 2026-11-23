-- Immutable upstream-aligned mwrap source release (pocketpy-m mwrap-2.2.0).
-- The CN mirror is added by a maintainer with mcpp-res access; until then CN
-- users fall back to the GitHub release (docs/cn-mirror.md).
--
-- 2.2.0.1 is a wrapper revision: its templates write the dependency selector
-- unquoted (`mcpplibs.mwrap.pocketpy = ...`); the quoted form is deprecated
-- since mcpp 2026.11.8.1 and removed in 2027.2.
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
            ["2.2.0.1"] = {
                url = "https://github.com/mcpplibs/pocketpy-m/releases/download/mwrap-2.2.0.1/pocketpy-m-2.2.0.1.tar.gz",
                sha256 = "8b61df9f4b4802d6d4b4ce9d775ef4cb7af2029b28d9c57f0ad519e54fba2ddb",
            },
            ["2.2.0"] = {
                url = "https://github.com/mcpplibs/pocketpy-m/releases/download/mwrap-2.2.0/pocketpy-m-2.2.0.tar.gz",
                sha256 = "bcc3174ff442f9337652d14fdb8da19a6c406e36bc4ffbd3a5afc98035135024",
            },
        },
        macosx = {
            ["2.2.0.1"] = {
                url = "https://github.com/mcpplibs/pocketpy-m/releases/download/mwrap-2.2.0.1/pocketpy-m-2.2.0.1.tar.gz",
                sha256 = "8b61df9f4b4802d6d4b4ce9d775ef4cb7af2029b28d9c57f0ad519e54fba2ddb",
            },
            ["2.2.0"] = {
                url = "https://github.com/mcpplibs/pocketpy-m/releases/download/mwrap-2.2.0/pocketpy-m-2.2.0.tar.gz",
                sha256 = "bcc3174ff442f9337652d14fdb8da19a6c406e36bc4ffbd3a5afc98035135024",
            },
        },
        windows = {
            ["2.2.0.1"] = {
                url = "https://github.com/mcpplibs/pocketpy-m/releases/download/mwrap-2.2.0.1/pocketpy-m-2.2.0.1.tar.gz",
                sha256 = "8b61df9f4b4802d6d4b4ce9d775ef4cb7af2029b28d9c57f0ad519e54fba2ddb",
            },
            ["2.2.0"] = {
                url = "https://github.com/mcpplibs/pocketpy-m/releases/download/mwrap-2.2.0/pocketpy-m-2.2.0.tar.gz",
                sha256 = "bcc3174ff442f9337652d14fdb8da19a6c406e36bc4ffbd3a5afc98035135024",
            },
        },
    },
}
