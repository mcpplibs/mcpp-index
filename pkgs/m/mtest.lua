-- mtest --- mcpplibs.mtest, the C++ library of the mtest test system.
--
-- One of the packages of mcpp-community/mtest, which share one tag and one
-- archive; each descriptor names its member's manifest. Cases, expectations,
-- fixtures and attributes with no macro and no header; a program built with it
-- speaks the mtest test protocol (spec/protocol.md), and its entry begins a
-- test file that defines no `main` (mcpp 2026.11.8.1 and later).
package = {
    spec        = "1",
    namespace   = "mcpplibs",
    name        = "mtest",
    description = "mcpplibs.mtest: the C++ test library of mtest --- cases, expectations, fixtures, bench, conformance and end-to-end helpers, with no macro and no header, speaking the mtest test protocol",
    licenses    = {"Apache-2.0"},
    repo        = "https://github.com/mcpp-community/mtest",
    type        = "package",

    extensions = {
        autoupdate = {
            tag = "v${version}",
            url = "https://github.com/mcpp-community/mtest/archive/refs/tags/${tag}.tar.gz",
        },
    },

    xpm = {
        linux = {
            ["0.3.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mtest/archive/refs/tags/v0.3.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mtest/releases/download/v0.3.0/mtest-v0.3.0.tar.gz",
                },
                sha256 = "b695022706d5fac107918c1d9461b953a8f462c63b78acacf52ea427e7009187",
            },
            ["0.2.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mtest/archive/refs/tags/v0.2.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mtest/releases/download/v0.2.0/mtest-v0.2.0.tar.gz",
                },
                sha256 = "600f52ff1b55489b012c16174fcded3dc9b9aea112377c783a2c9425072e03d2",
            },
            ["0.1.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mtest/archive/refs/tags/v0.1.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mtest/releases/download/v0.1.0/mtest-v0.1.0.tar.gz",
                },
                sha256 = "2e09528d97173371e0238c720cb8ac80602241f4e05d55d3acb12f21b5c95c75",
            },
        },
        macosx = {
            ["0.3.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mtest/archive/refs/tags/v0.3.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mtest/releases/download/v0.3.0/mtest-v0.3.0.tar.gz",
                },
                sha256 = "b695022706d5fac107918c1d9461b953a8f462c63b78acacf52ea427e7009187",
            },
            ["0.2.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mtest/archive/refs/tags/v0.2.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mtest/releases/download/v0.2.0/mtest-v0.2.0.tar.gz",
                },
                sha256 = "600f52ff1b55489b012c16174fcded3dc9b9aea112377c783a2c9425072e03d2",
            },
            ["0.1.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mtest/archive/refs/tags/v0.1.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mtest/releases/download/v0.1.0/mtest-v0.1.0.tar.gz",
                },
                sha256 = "2e09528d97173371e0238c720cb8ac80602241f4e05d55d3acb12f21b5c95c75",
            },
        },
        windows = {
            ["0.3.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mtest/archive/refs/tags/v0.3.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mtest/releases/download/v0.3.0/mtest-v0.3.0.tar.gz",
                },
                sha256 = "b695022706d5fac107918c1d9461b953a8f462c63b78acacf52ea427e7009187",
            },
            ["0.2.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mtest/archive/refs/tags/v0.2.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mtest/releases/download/v0.2.0/mtest-v0.2.0.tar.gz",
                },
                sha256 = "600f52ff1b55489b012c16174fcded3dc9b9aea112377c783a2c9425072e03d2",
            },
            ["0.1.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mtest/archive/refs/tags/v0.1.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mtest/releases/download/v0.1.0/mtest-v0.1.0.tar.gz",
                },
                sha256 = "2e09528d97173371e0238c720cb8ac80602241f4e05d55d3acb12f21b5c95c75",
            },
        },
    },

    mcpp = "*/lib/mcpp.toml",
}
