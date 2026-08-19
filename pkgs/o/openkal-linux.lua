-- openkal-linux --- the reference implementation.
--
-- No `deps`. The implementation uses the C library of the host, which mcpp
-- already supplies for a hosted target; nothing further is required.
--
-- The package is listed for every platform because a descriptor's platform
-- table describes availability rather than applicability. A project selects
-- this implementation with a conditional dependency on `cfg(os = "linux")`,
-- and a project that selects it elsewhere fails at compile time, which is the
-- correct place for that failure.
package = {
    spec        = "1",
    namespace   = "mcpplibs",
    name        = "openkal-linux",
    description = "The reference implementation of openkal for Linux, maintained as a worked example",
    licenses    = {"Apache-2.0"},
    repo        = "https://github.com/mcpplibs/openkal-linux",
    type        = "package",

    xpm = {
        linux = {
            ["0.4.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-linux/archive/refs/tags/0.4.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-linux/releases/download/0.4.0/openkal-linux-0.4.0.tar.gz",
                },
                sha256 = "6477c9b52931e0f14d243467ed5dcc0cece8095d0dbdd2bc8591a63e4025290e",
            },
        },
        macosx = {
            ["0.4.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-linux/archive/refs/tags/0.4.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-linux/releases/download/0.4.0/openkal-linux-0.4.0.tar.gz",
                },
                sha256 = "6477c9b52931e0f14d243467ed5dcc0cece8095d0dbdd2bc8591a63e4025290e",
            },
        },
        windows = {
            ["0.4.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-linux/archive/refs/tags/0.4.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-linux/releases/download/0.4.0/openkal-linux-0.4.0.tar.gz",
                },
                sha256 = "6477c9b52931e0f14d243467ed5dcc0cece8095d0dbdd2bc8591a63e4025290e",
            },
        },
    },

    -- The package's own manifest, inside the tarball's wrap directory.
    mcpp = "*/mcpp.toml",
}
