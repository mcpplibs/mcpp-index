-- openkal-musl --- musl 1.2.5 above openkal rather than above one kernel.
--
-- The version line continues rather than restarting. This repository was
-- `openkal-libc' up to 0.2.0, and those tags are still in it; a package that
-- restarted at 0.1.0 would give one tag two meanings, which is the one thing a
-- release chain cannot allow. The earlier name keeps its own descriptor so that
-- a project pinned to it continues to resolve, and nothing is added to it.
--
-- No `deps'. The package names the specification it is written against and the
-- implementation of openkal for the target being built, both in its own
-- manifest --- because a C library is the one consumer that knows the program
-- above it carries no other runtime, and that is what selects the
-- implementation's `standalone' feature.
--
-- The consequence for a program is that it names this package and nothing else.
package = {
    spec        = "1",
    namespace   = "mcpplibs",
    name        = "openkal-musl",
    description = "musl 1.2.5 redirected onto openkal: one C library, ported once, above every implementation of the specification rather than above one kernel",
    licenses    = {"Apache-2.0", "MIT"},
    repo        = "https://github.com/mcpplibs/openkal-musl",
    type        = "package",

    xpm = {
        linux = {
            ["0.4.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.4.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.4.0/openkal-musl-0.4.0.tar.gz",
                },
                sha256 = "aa29225b7a71fb9d81b3f356f4ac21d89ad0a87d9229a8e42b29f807208519c3",
            },
            ["0.3.5"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.3.5.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.3.5/openkal-musl-0.3.5.tar.gz",
                },
                sha256 = "0f8335633d230f0989db6083f5d5dff35a11d32fac940281dc886e3ba7bb6a55",
            },
            ["0.3.4"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.3.4.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.3.4/openkal-musl-0.3.4.tar.gz",
                },
                sha256 = "a2c17775bc17d2c981dca624bebe1661e6d1662844f2cecf7d465c2828a27249",
            },
            ["0.3.3"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.3.3.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.3.3/openkal-musl-0.3.3.tar.gz",
                },
                sha256 = "1a5ebc69bae296b98783719e2db242ae17a118e4ee35e73b1ad836bc94afedca",
            },
            ["0.3.2"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.3.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.3.2/openkal-musl-0.3.2.tar.gz",
                },
                sha256 = "35246bf4326e0f4c9b606ae1934b5f7752cfc10832a7039d71291f7c5707d886",
            },
            ["0.3.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.3.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.3.1/openkal-musl-0.3.1.tar.gz",
                },
                sha256 = "c09c6f4f29b9121be2dba69959043fef4effe52807215882c9f2e62644f9331b",
            },
            ["0.3.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.3.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.3.0/openkal-musl-0.3.0.tar.gz",
                },
                sha256 = "ec96bc1f68c42daf2b8db4815138b8fc548cebb910c13482dbefa4c4a8994f17",
            },
        },
        macosx = {
            ["0.4.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.4.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.4.0/openkal-musl-0.4.0.tar.gz",
                },
                sha256 = "aa29225b7a71fb9d81b3f356f4ac21d89ad0a87d9229a8e42b29f807208519c3",
            },
            ["0.3.5"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.3.5.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.3.5/openkal-musl-0.3.5.tar.gz",
                },
                sha256 = "0f8335633d230f0989db6083f5d5dff35a11d32fac940281dc886e3ba7bb6a55",
            },
            ["0.3.4"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.3.4.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.3.4/openkal-musl-0.3.4.tar.gz",
                },
                sha256 = "a2c17775bc17d2c981dca624bebe1661e6d1662844f2cecf7d465c2828a27249",
            },
            ["0.3.3"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.3.3.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.3.3/openkal-musl-0.3.3.tar.gz",
                },
                sha256 = "1a5ebc69bae296b98783719e2db242ae17a118e4ee35e73b1ad836bc94afedca",
            },
            ["0.3.2"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.3.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.3.2/openkal-musl-0.3.2.tar.gz",
                },
                sha256 = "35246bf4326e0f4c9b606ae1934b5f7752cfc10832a7039d71291f7c5707d886",
            },
            ["0.3.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.3.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.3.1/openkal-musl-0.3.1.tar.gz",
                },
                sha256 = "c09c6f4f29b9121be2dba69959043fef4effe52807215882c9f2e62644f9331b",
            },
            ["0.3.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.3.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.3.0/openkal-musl-0.3.0.tar.gz",
                },
                sha256 = "ec96bc1f68c42daf2b8db4815138b8fc548cebb910c13482dbefa4c4a8994f17",
            },
        },
        windows = {
            ["0.4.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.4.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.4.0/openkal-musl-0.4.0.tar.gz",
                },
                sha256 = "aa29225b7a71fb9d81b3f356f4ac21d89ad0a87d9229a8e42b29f807208519c3",
            },
            ["0.3.5"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.3.5.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.3.5/openkal-musl-0.3.5.tar.gz",
                },
                sha256 = "0f8335633d230f0989db6083f5d5dff35a11d32fac940281dc886e3ba7bb6a55",
            },
            ["0.3.4"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.3.4.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.3.4/openkal-musl-0.3.4.tar.gz",
                },
                sha256 = "a2c17775bc17d2c981dca624bebe1661e6d1662844f2cecf7d465c2828a27249",
            },
            ["0.3.3"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.3.3.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.3.3/openkal-musl-0.3.3.tar.gz",
                },
                sha256 = "1a5ebc69bae296b98783719e2db242ae17a118e4ee35e73b1ad836bc94afedca",
            },
            ["0.3.2"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.3.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.3.2/openkal-musl-0.3.2.tar.gz",
                },
                sha256 = "35246bf4326e0f4c9b606ae1934b5f7752cfc10832a7039d71291f7c5707d886",
            },
            ["0.3.1"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.3.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.3.1/openkal-musl-0.3.1.tar.gz",
                },
                sha256 = "c09c6f4f29b9121be2dba69959043fef4effe52807215882c9f2e62644f9331b",
            },
            ["0.3.0"] = {
                url    = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-musl/archive/refs/tags/0.3.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/openkal-musl/releases/download/0.3.0/openkal-musl-0.3.0.tar.gz",
                },
                sha256 = "ec96bc1f68c42daf2b8db4815138b8fc548cebb910c13482dbefa4c4a8994f17",
            },
        },
    },

    mcpp = "*/mcpp.toml",
}
