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
            ["0.6.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-linux/archive/refs/tags/0.6.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-linux/releases/download/0.6.0/openkal-linux-0.6.0.tar.gz",
                },
                sha256 = "d43b2be4d05e638e3b37e54c8c4c287d4141d1e72b68f79545dd50ea5705b739",
            },
            ["0.5.4"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-linux/archive/refs/tags/0.5.4.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-linux/releases/download/0.5.4/openkal-linux-0.5.4.tar.gz",
                },
                sha256 = "c03c174ea21c741b697cff653c352add6dcc109fcd5d58d4d9fd23348d7ba5f9",
            },
            ["0.5.3"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-linux/archive/refs/tags/0.5.3.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-linux/releases/download/0.5.3/openkal-linux-0.5.3.tar.gz",
                },
                sha256 = "03e66f5d744a3ed9740afafe44bdcf9293b571e085c31209812442ba23d2d147",
            },
            ["0.5.2"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-linux/archive/refs/tags/0.5.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-linux/releases/download/0.5.2/openkal-linux-0.5.2.tar.gz",
                },
                sha256 = "f8729db43107cadc371d64f557950769ed2fc75c00ea2009504d1ca084e7f8fb",
            },
            ["0.5.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-linux/archive/refs/tags/0.5.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-linux/releases/download/0.5.1/openkal-linux-0.5.1.tar.gz",
                },
                sha256 = "fa9dd5daff81666e80b38f213e9b9a073e8461946f0a58a911fc67a04f1d8415",
            },
            ["0.4.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-linux/archive/refs/tags/0.4.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-linux/releases/download/0.4.0/openkal-linux-0.4.0.tar.gz",
                },
                sha256 = "6477c9b52931e0f14d243467ed5dcc0cece8095d0dbdd2bc8591a63e4025290e",
            },
        },
        macosx = {
            ["0.6.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-linux/archive/refs/tags/0.6.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-linux/releases/download/0.6.0/openkal-linux-0.6.0.tar.gz",
                },
                sha256 = "d43b2be4d05e638e3b37e54c8c4c287d4141d1e72b68f79545dd50ea5705b739",
            },
            ["0.5.4"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-linux/archive/refs/tags/0.5.4.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-linux/releases/download/0.5.4/openkal-linux-0.5.4.tar.gz",
                },
                sha256 = "c03c174ea21c741b697cff653c352add6dcc109fcd5d58d4d9fd23348d7ba5f9",
            },
            ["0.5.3"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-linux/archive/refs/tags/0.5.3.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-linux/releases/download/0.5.3/openkal-linux-0.5.3.tar.gz",
                },
                sha256 = "03e66f5d744a3ed9740afafe44bdcf9293b571e085c31209812442ba23d2d147",
            },
            ["0.5.2"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-linux/archive/refs/tags/0.5.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-linux/releases/download/0.5.2/openkal-linux-0.5.2.tar.gz",
                },
                sha256 = "f8729db43107cadc371d64f557950769ed2fc75c00ea2009504d1ca084e7f8fb",
            },
            ["0.5.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-linux/archive/refs/tags/0.5.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-linux/releases/download/0.5.1/openkal-linux-0.5.1.tar.gz",
                },
                sha256 = "fa9dd5daff81666e80b38f213e9b9a073e8461946f0a58a911fc67a04f1d8415",
            },
            ["0.4.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-linux/archive/refs/tags/0.4.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-linux/releases/download/0.4.0/openkal-linux-0.4.0.tar.gz",
                },
                sha256 = "6477c9b52931e0f14d243467ed5dcc0cece8095d0dbdd2bc8591a63e4025290e",
            },
        },
        windows = {
            ["0.6.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-linux/archive/refs/tags/0.6.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-linux/releases/download/0.6.0/openkal-linux-0.6.0.tar.gz",
                },
                sha256 = "d43b2be4d05e638e3b37e54c8c4c287d4141d1e72b68f79545dd50ea5705b739",
            },
            ["0.5.4"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-linux/archive/refs/tags/0.5.4.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-linux/releases/download/0.5.4/openkal-linux-0.5.4.tar.gz",
                },
                sha256 = "c03c174ea21c741b697cff653c352add6dcc109fcd5d58d4d9fd23348d7ba5f9",
            },
            ["0.5.3"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-linux/archive/refs/tags/0.5.3.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-linux/releases/download/0.5.3/openkal-linux-0.5.3.tar.gz",
                },
                sha256 = "03e66f5d744a3ed9740afafe44bdcf9293b571e085c31209812442ba23d2d147",
            },
            ["0.5.2"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-linux/archive/refs/tags/0.5.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-linux/releases/download/0.5.2/openkal-linux-0.5.2.tar.gz",
                },
                sha256 = "f8729db43107cadc371d64f557950769ed2fc75c00ea2009504d1ca084e7f8fb",
            },
            ["0.5.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-linux/archive/refs/tags/0.5.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-linux/releases/download/0.5.1/openkal-linux-0.5.1.tar.gz",
                },
                sha256 = "fa9dd5daff81666e80b38f213e9b9a073e8461946f0a58a911fc67a04f1d8415",
            },
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
