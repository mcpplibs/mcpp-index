-- Immutable upstream-aligned mwrap source release (zlib-m mwrap-1.3.2);
-- GLOBAL and CN bytes are identical.
--
-- The wrapper is Apache-2.0; the library it links, compat.zlib (zlib 1.3.2), is
-- under the zlib license, linked statically: the package deploys zlib's README
-- and LICENSE beside programs (runtime.deploy).
--
-- 1.3.2.1 is a wrapper revision: its templates write the dependency selector
-- unquoted (`mcpplibs.mwrap.zlib = ...`); the quoted form is deprecated
-- since mcpp 2026.11.8.1 and removed in 2027.2.
package = {
    spec = "1",
    namespace = "mcpplibs.mwrap",
    name = "zlib",
    description = "zlib-m: zlib 1.3.2 (deflate, inflate, gzip files and checksums) as C++23 modules, with the constants of zlib.h as C++ constants",
    licenses = { "Apache-2.0" },
    repo = "https://github.com/mcpplibs/zlib-m",
    type = "package",
    extensions = {
        autoupdate = {
            tag = "mwrap-${version}",
            url = "https://github.com/mcpplibs/zlib-m/releases/download/${tag}/zlib-m-${version}.tar.gz",
        },
    },
    xpm = {
        linux = {
            ["1.3.2.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/zlib-m/releases/download/mwrap-1.3.2.1/zlib-m-1.3.2.1.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-zlib/releases/download/1.3.2.1/zlib-m-1.3.2.1.tar.gz",
                },
                sha256 = "246a4cfc9027b210ae783cb27a78101704decf30505b606e4f2ba0e1243e64c8",
            },
            ["1.3.2"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/zlib-m/releases/download/mwrap-1.3.2/zlib-m-1.3.2.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-zlib/releases/download/1.3.2/zlib-m-1.3.2.tar.gz",
                },
                sha256 = "93a855abd3688dcba1526e6de1a61121e51eaeddef31da263342be30e2818b4b",
            },
        },
        macosx = {
            ["1.3.2.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/zlib-m/releases/download/mwrap-1.3.2.1/zlib-m-1.3.2.1.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-zlib/releases/download/1.3.2.1/zlib-m-1.3.2.1.tar.gz",
                },
                sha256 = "246a4cfc9027b210ae783cb27a78101704decf30505b606e4f2ba0e1243e64c8",
            },
            ["1.3.2"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/zlib-m/releases/download/mwrap-1.3.2/zlib-m-1.3.2.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-zlib/releases/download/1.3.2/zlib-m-1.3.2.tar.gz",
                },
                sha256 = "93a855abd3688dcba1526e6de1a61121e51eaeddef31da263342be30e2818b4b",
            },
        },
        windows = {
            ["1.3.2.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/zlib-m/releases/download/mwrap-1.3.2.1/zlib-m-1.3.2.1.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-zlib/releases/download/1.3.2.1/zlib-m-1.3.2.1.tar.gz",
                },
                sha256 = "246a4cfc9027b210ae783cb27a78101704decf30505b606e4f2ba0e1243e64c8",
            },
            ["1.3.2"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/zlib-m/releases/download/mwrap-1.3.2/zlib-m-1.3.2.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-zlib/releases/download/1.3.2/zlib-m-1.3.2.tar.gz",
                },
                sha256 = "93a855abd3688dcba1526e6de1a61121e51eaeddef31da263342be30e2818b4b",
            },
        },
    },
}
