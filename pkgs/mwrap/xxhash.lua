-- Immutable upstream-aligned mwrap source release (xxhash-m mwrap-0.8.3);
-- GLOBAL and CN bytes are identical.
--
-- The wrapper is Apache-2.0; the library it links, compat.xxhash (xxHash
-- 0.8.3), is BSD-2-Clause, linked statically: the package deploys its README
-- and LICENSE beside programs (runtime.deploy).
package = {
    spec = "1",
    namespace = "mcpplibs.mwrap",
    name = "xxhash",
    description = "xxhash-m: xxHash 0.8.3 (XXH32, XXH64, XXH3 64 and 128 bits, one-shot and streaming) as C++23 modules",
    licenses = { "Apache-2.0" },
    repo = "https://github.com/mcpplibs/xxhash-m",
    type = "package",
    extensions = {
        autoupdate = {
            tag = "mwrap-${version}",
            url = "https://github.com/mcpplibs/xxhash-m/releases/download/${tag}/xxhash-m-${version}.tar.gz",
        },
    },
    xpm = {
        linux = {
            ["0.8.3"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/xxhash-m/releases/download/mwrap-0.8.3/xxhash-m-0.8.3.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-xxhash/releases/download/0.8.3/xxhash-m-0.8.3.tar.gz",
                },
                sha256 = "4e389afbece2290b44c24c12b4ad1086c28f146e78de8cebf5c701f676dc36cc",
            },
        },
        macosx = {
            ["0.8.3"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/xxhash-m/releases/download/mwrap-0.8.3/xxhash-m-0.8.3.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-xxhash/releases/download/0.8.3/xxhash-m-0.8.3.tar.gz",
                },
                sha256 = "4e389afbece2290b44c24c12b4ad1086c28f146e78de8cebf5c701f676dc36cc",
            },
        },
        windows = {
            ["0.8.3"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/xxhash-m/releases/download/mwrap-0.8.3/xxhash-m-0.8.3.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-xxhash/releases/download/0.8.3/xxhash-m-0.8.3.tar.gz",
                },
                sha256 = "4e389afbece2290b44c24c12b4ad1086c28f146e78de8cebf5c701f676dc36cc",
            },
        },
    },
}
