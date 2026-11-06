-- Immutable upstream-aligned mwrap source release (xz-m mwrap-5.8.3);
-- GLOBAL and CN bytes are identical.
--
-- The wrapper is Apache-2.0; the library it links, compat.xz (liblzma of XZ
-- Utils 5.8.3), is 0BSD, linked statically: the package deploys its README and
-- licenses beside programs (runtime.deploy).
package = {
    spec = "1",
    namespace = "mcpplibs.mwrap",
    name = "xz",
    description = "xz-m: liblzma of XZ Utils 5.8.3 (.xz and .lzma streams, filters, blocks, indexes, checks) as C++23 modules, with the constants of lzma.h as C++ constants",
    licenses = { "Apache-2.0" },
    repo = "https://github.com/mcpplibs/xz-m",
    type = "package",
    extensions = {
        autoupdate = {
            tag = "mwrap-${version}",
            url = "https://github.com/mcpplibs/xz-m/releases/download/${tag}/xz-m-${version}.tar.gz",
        },
    },
    xpm = {
        linux = {
            ["5.8.3"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/xz-m/releases/download/mwrap-5.8.3/xz-m-5.8.3.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-xz/releases/download/5.8.3/xz-m-5.8.3.tar.gz",
                },
                sha256 = "6b3f720c05a66916ddb3e14ba98dfd65ace6018b66eda1400ce40adb05a3b957",
            },
        },
        macosx = {
            ["5.8.3"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/xz-m/releases/download/mwrap-5.8.3/xz-m-5.8.3.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-xz/releases/download/5.8.3/xz-m-5.8.3.tar.gz",
                },
                sha256 = "6b3f720c05a66916ddb3e14ba98dfd65ace6018b66eda1400ce40adb05a3b957",
            },
        },
        windows = {
            ["5.8.3"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/xz-m/releases/download/mwrap-5.8.3/xz-m-5.8.3.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-xz/releases/download/5.8.3/xz-m-5.8.3.tar.gz",
                },
                sha256 = "6b3f720c05a66916ddb3e14ba98dfd65ace6018b66eda1400ce40adb05a3b957",
            },
        },
    },
}
