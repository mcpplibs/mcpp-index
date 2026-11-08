-- mcpplibs.mtest.capi --- the C ABI of the mtest test protocol.
--
-- A package of mcpp-community/mtest (one tag, one archive): include/mtest.h and
-- a shared library through which a program of any language with a C FFI
-- reports by the protocol.
package = {
    spec        = "1",
    namespace   = "mcpplibs.mtest",
    name        = "capi",
    description = "mtest's C ABI: the test protocol's events for any language with a C FFI",
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
            ["0.4.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mtest/archive/refs/tags/v0.4.1.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mtest/releases/download/v0.4.1/mtest-v0.4.1.tar.gz",
                },
                sha256 = "c0a769eba5d36d5c70186fe6cb8092b2f2237b5526a694d4f14581fe81eb8c86",
            },
            ["0.4.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mtest/archive/refs/tags/v0.4.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mtest/releases/download/v0.4.0/mtest-v0.4.0.tar.gz",
                },
                sha256 = "9c90fc7b225a5d0dc562070cf3c2d1336a391c77b56755d62854bc38d2c88040",
            },
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
            ["0.4.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mtest/archive/refs/tags/v0.4.1.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mtest/releases/download/v0.4.1/mtest-v0.4.1.tar.gz",
                },
                sha256 = "c0a769eba5d36d5c70186fe6cb8092b2f2237b5526a694d4f14581fe81eb8c86",
            },
            ["0.4.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mtest/archive/refs/tags/v0.4.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mtest/releases/download/v0.4.0/mtest-v0.4.0.tar.gz",
                },
                sha256 = "9c90fc7b225a5d0dc562070cf3c2d1336a391c77b56755d62854bc38d2c88040",
            },
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
            ["0.4.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mtest/archive/refs/tags/v0.4.1.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mtest/releases/download/v0.4.1/mtest-v0.4.1.tar.gz",
                },
                sha256 = "c0a769eba5d36d5c70186fe6cb8092b2f2237b5526a694d4f14581fe81eb8c86",
            },
            ["0.4.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mtest/archive/refs/tags/v0.4.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mtest/releases/download/v0.4.0/mtest-v0.4.0.tar.gz",
                },
                sha256 = "9c90fc7b225a5d0dc562070cf3c2d1336a391c77b56755d62854bc38d2c88040",
            },
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

    mcpp = "*/capi/mcpp.toml",
}
