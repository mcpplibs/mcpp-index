-- Immutable upstream-aligned mwrap source release (wuffs-m mwrap-0.3.6);
-- GLOBAL and CN bytes are identical.
--
-- The wrapper is Apache-2.0, and so is the library it links, compat.wuffs
-- (Wuffs 0.3.6, release/c/wuffs-v0.3.c compiled as C++), linked statically:
-- the package deploys Wuffs' README, LICENSE and AUTHORS beside programs
-- (runtime.deploy).
package = {
    spec = "1",
    namespace = "mcpplibs.mwrap",
    name = "wuffs",
    description = "wuffs-m: Wuffs (memory-safe decoders for untrusted formats: PNG, GIF, BMP, DEFLATE, gzip, JSON …) as C++23 modules",
    licenses = { "Apache-2.0" },
    repo = "https://github.com/mcpplibs/wuffs-m",
    type = "package",
    extensions = {
        autoupdate = {
            tag = "mwrap-${version}",
            url = "https://github.com/mcpplibs/wuffs-m/releases/download/${tag}/wuffs-m-${version}.tar.gz",
        },
    },
    xpm = {
        linux = {
            ["0.3.6"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/wuffs-m/releases/download/mwrap-0.3.6/wuffs-m-0.3.6.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-wuffs/releases/download/0.3.6/wuffs-m-0.3.6.tar.gz",
                },
                sha256 = "fe71c84320c16afc8c45a301cd2de2c65d88a3c99909a1d24ce1acc831d0c248",
            },
        },
        macosx = {
            ["0.3.6"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/wuffs-m/releases/download/mwrap-0.3.6/wuffs-m-0.3.6.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-wuffs/releases/download/0.3.6/wuffs-m-0.3.6.tar.gz",
                },
                sha256 = "fe71c84320c16afc8c45a301cd2de2c65d88a3c99909a1d24ce1acc831d0c248",
            },
        },
        windows = {
            ["0.3.6"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/wuffs-m/releases/download/mwrap-0.3.6/wuffs-m-0.3.6.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-wuffs/releases/download/0.3.6/wuffs-m-0.3.6.tar.gz",
                },
                sha256 = "fe71c84320c16afc8c45a301cd2de2c65d88a3c99909a1d24ce1acc831d0c248",
            },
        },
    },
}
