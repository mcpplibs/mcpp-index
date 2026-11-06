-- Immutable upstream-aligned mwrap source release (libc-m mwrap-17.0.0);
-- GLOBAL and CN bytes are identical.
--
-- The wrapper is Apache-2.0 and links nothing: the implementation is the
-- target's C library. The version names the standard, ISO/IEC 9899:2018 (C17).
package = {
    spec = "1",
    namespace = "mcpplibs.mwrap",
    name = "libc",
    description = "libc-m: the C standard library (ISO C17) for C++ modules: std.compat with the object-like macros of ISO C (stdout, errno, EOF, INT_MAX …) as C++ constants and functions",
    licenses = { "Apache-2.0" },
    repo = "https://github.com/mcpplibs/libc-m",
    type = "package",
    extensions = {
        autoupdate = {
            tag = "mwrap-${version}",
            url = "https://github.com/mcpplibs/libc-m/releases/download/${tag}/libc-m-${version}.tar.gz",
        },
    },
    xpm = {
        linux = {
            ["17.0.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/libc-m/releases/download/mwrap-17.0.0/libc-m-17.0.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-libc/releases/download/17.0.0/libc-m-17.0.0.tar.gz",
                },
                sha256 = "e601179504f0fc94bb4d2f002982b2f5b9cc4b95a50a13822bd9b272519a3a9c",
            },
        },
        macosx = {
            ["17.0.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/libc-m/releases/download/mwrap-17.0.0/libc-m-17.0.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-libc/releases/download/17.0.0/libc-m-17.0.0.tar.gz",
                },
                sha256 = "e601179504f0fc94bb4d2f002982b2f5b9cc4b95a50a13822bd9b272519a3a9c",
            },
        },
        windows = {
            ["17.0.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/libc-m/releases/download/mwrap-17.0.0/libc-m-17.0.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-libc/releases/download/17.0.0/libc-m-17.0.0.tar.gz",
                },
                sha256 = "e601179504f0fc94bb4d2f002982b2f5b9cc4b95a50a13822bd9b272519a3a9c",
            },
        },
    },
}
