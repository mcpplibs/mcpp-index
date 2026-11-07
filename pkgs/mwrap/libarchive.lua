-- Immutable upstream-aligned mwrap source release (libarchive-m mwrap-3.8.7);
-- GLOBAL and CN bytes are identical.
--
-- The wrapper is Apache-2.0; the library it links, compat.libarchive
-- (libarchive 3.8.7), is BSD-2-Clause with the exceptions its COPYING lists,
-- linked statically: the package deploys its README and COPYING beside
-- programs (runtime.deploy).
package = {
    spec = "1",
    namespace = "mcpplibs.mwrap",
    name = "libarchive",
    description = "libarchive-m: libarchive 3.8.7 (tar, cpio, zip, 7-Zip, ISO 9660 … with their compression filters, entries, disk access) as C++23 modules, with the constants of archive.h as C++ constants",
    licenses = { "Apache-2.0" },
    repo = "https://github.com/mcpplibs/libarchive-m",
    type = "package",
    extensions = {
        autoupdate = {
            tag = "mwrap-${version}",
            url = "https://github.com/mcpplibs/libarchive-m/releases/download/${tag}/libarchive-m-${version}.tar.gz",
        },
    },
    xpm = {
        linux = {
            ["3.8.7"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/libarchive-m/releases/download/mwrap-3.8.7/libarchive-m-3.8.7.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-libarchive/releases/download/3.8.7/libarchive-m-3.8.7.tar.gz",
                },
                sha256 = "b55c102f8743112d94bd57ab8e79b31cdfe49935c1bebaed846b1a4508e9c8f8",
            },
        },
        macosx = {
            ["3.8.7"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/libarchive-m/releases/download/mwrap-3.8.7/libarchive-m-3.8.7.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-libarchive/releases/download/3.8.7/libarchive-m-3.8.7.tar.gz",
                },
                sha256 = "b55c102f8743112d94bd57ab8e79b31cdfe49935c1bebaed846b1a4508e9c8f8",
            },
        },
        windows = {
            ["3.8.7"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/libarchive-m/releases/download/mwrap-3.8.7/libarchive-m-3.8.7.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-libarchive/releases/download/3.8.7/libarchive-m-3.8.7.tar.gz",
                },
                sha256 = "b55c102f8743112d94bd57ab8e79b31cdfe49935c1bebaed846b1a4508e9c8f8",
            },
        },
    },
}
