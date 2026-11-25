-- Immutable upstream-aligned mwrap source release (libpng-m mwrap-1.6.43).
-- The CN mirror is added by a maintainer with mcpp-res access; until then CN
-- users fall back to the GitHub release (docs/cn-mirror.md).
--
-- 1.6.43.1 is a wrapper revision: its templates write the dependency selector
-- unquoted (`mcpplibs.mwrap.libpng = ...`); the quoted form is deprecated
-- since mcpp 2026.11.8.1 and removed in 2027.2.
package = {
    spec = "1",
    namespace = "mcpplibs.mwrap",
    name = "libpng",
    description = "libpng-m: libpng (the PNG reference library) as C++23 modules",
    licenses = { "Apache-2.0" },
    repo = "https://github.com/mcpplibs/libpng-m",
    type = "package",
    extensions = {
        autoupdate = {
            tag = "mwrap-${version}",
            url = "https://github.com/mcpplibs/libpng-m/releases/download/${tag}/libpng-m-${version}.tar.gz",
        },
    },
    xpm = {
        linux = {
            ["1.6.43.1"] = {
                url = "https://github.com/mcpplibs/libpng-m/releases/download/mwrap-1.6.43.1/libpng-m-1.6.43.1.tar.gz",
                sha256 = "541f7102f7856c25cdbd84c153abafc4c7903fa46c2e3faeea1f82d437c434dd",
            },
            ["1.6.43"] = {
                url = "https://github.com/mcpplibs/libpng-m/releases/download/mwrap-1.6.43/libpng-m-1.6.43.tar.gz",
                sha256 = "44b62160e99e9febf908da87774447376c847f304674c4e3654c9bc2ab8aeb85",
            },
        },
        macosx = {
            ["1.6.43.1"] = {
                url = "https://github.com/mcpplibs/libpng-m/releases/download/mwrap-1.6.43.1/libpng-m-1.6.43.1.tar.gz",
                sha256 = "541f7102f7856c25cdbd84c153abafc4c7903fa46c2e3faeea1f82d437c434dd",
            },
            ["1.6.43"] = {
                url = "https://github.com/mcpplibs/libpng-m/releases/download/mwrap-1.6.43/libpng-m-1.6.43.tar.gz",
                sha256 = "44b62160e99e9febf908da87774447376c847f304674c4e3654c9bc2ab8aeb85",
            },
        },
        windows = {
            ["1.6.43.1"] = {
                url = "https://github.com/mcpplibs/libpng-m/releases/download/mwrap-1.6.43.1/libpng-m-1.6.43.1.tar.gz",
                sha256 = "541f7102f7856c25cdbd84c153abafc4c7903fa46c2e3faeea1f82d437c434dd",
            },
            ["1.6.43"] = {
                url = "https://github.com/mcpplibs/libpng-m/releases/download/mwrap-1.6.43/libpng-m-1.6.43.tar.gz",
                sha256 = "44b62160e99e9febf908da87774447376c847f304674c4e3654c9bc2ab8aeb85",
            },
        },
    },
}
