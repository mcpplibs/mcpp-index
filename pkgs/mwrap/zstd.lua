-- Immutable upstream-aligned mwrap source release (zstd-m mwrap-1.5.7);
-- GLOBAL and CN bytes are identical.
--
-- The wrapper is Apache-2.0; the library it links, compat.zstd (Zstandard
-- 1.5.7), is under the BSD license or the GPLv2, linked statically: the package
-- deploys its README and both licenses beside programs (runtime.deploy).
package = {
    spec = "1",
    namespace = "mcpplibs.mwrap",
    name = "zstd",
    description = "zstd-m: Zstandard 1.5.7 (one-shot, streaming, parameters, dictionaries, error codes) as C++23 modules, with the constants of zstd.h as C++ constants",
    licenses = { "Apache-2.0" },
    repo = "https://github.com/mcpplibs/zstd-m",
    type = "package",
    extensions = {
        autoupdate = {
            tag = "mwrap-${version}",
            url = "https://github.com/mcpplibs/zstd-m/releases/download/${tag}/zstd-m-${version}.tar.gz",
        },
    },
    xpm = {
        linux = {
            ["1.5.7"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/zstd-m/releases/download/mwrap-1.5.7/zstd-m-1.5.7.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-zstd/releases/download/1.5.7/zstd-m-1.5.7.tar.gz",
                },
                sha256 = "276a81e640f510db8d491e8ba038e9f68ddc4a64c4371b798c79807e508fc950",
            },
        },
        macosx = {
            ["1.5.7"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/zstd-m/releases/download/mwrap-1.5.7/zstd-m-1.5.7.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-zstd/releases/download/1.5.7/zstd-m-1.5.7.tar.gz",
                },
                sha256 = "276a81e640f510db8d491e8ba038e9f68ddc4a64c4371b798c79807e508fc950",
            },
        },
        windows = {
            ["1.5.7"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/zstd-m/releases/download/mwrap-1.5.7/zstd-m-1.5.7.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-zstd/releases/download/1.5.7/zstd-m-1.5.7.tar.gz",
                },
                sha256 = "276a81e640f510db8d491e8ba038e9f68ddc4a64c4371b798c79807e508fc950",
            },
        },
    },
}
