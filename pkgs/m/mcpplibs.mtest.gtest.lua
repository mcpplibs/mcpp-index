-- mcpplibs.mtest.gtest --- GoogleTest speaking the mtest test protocol.
--
-- A package of mcpp-community/mtest (one tag, one archive): a test main that
-- lists, selects and reports GoogleTest's cases by the protocol, level 1.
package = {
    spec        = "1",
    namespace   = "mcpplibs.mtest",
    name        = "gtest",
    description = "GoogleTest speaking the mtest test protocol: a test main that lists, selects and reports GoogleTest's cases",
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
            ["0.7.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mtest/archive/refs/tags/v0.7.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mtest/releases/download/v0.7.0/mtest-v0.7.0.tar.gz",
                },
                sha256 = "ab312f844066e6070c929be3eabee9091a903b550b8220c8c59d098e17b42bd6",
            },
            ["0.6.3"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mtest/archive/refs/tags/v0.6.3.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mtest/releases/download/v0.6.3/mtest-v0.6.3.tar.gz",
                },
                sha256 = "a41e5001e40098beacb92d62f92b4f09d0e5dd2113fb98eda5e949af277cbaa2",
            },
            ["0.6.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mtest/archive/refs/tags/v0.6.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mtest/releases/download/v0.6.0/mtest-v0.6.0.tar.gz",
                },
                sha256 = "eb90f823b4b2c6e4407110cd7c4bac290b683fdf3c1b6b471a58e9e7016b5472",
            },
            ["0.5.2"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mtest/archive/refs/tags/v0.5.2.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mtest/releases/download/v0.5.2/mtest-v0.5.2.tar.gz",
                },
                sha256 = "e61819239dca14d3c987f554b8c09e5bc248fdb8bba2650adb53e775db2ccf93",
            },
            ["0.5.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mtest/archive/refs/tags/v0.5.1.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mtest/releases/download/v0.5.1/mtest-v0.5.1.tar.gz",
                },
                sha256 = "48625c19d548aa4e90bf658f895fe99c10bf9316efaa3354d4cb65df9ccd7324",
            },
            ["0.5.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mtest/archive/refs/tags/v0.5.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mtest/releases/download/v0.5.0/mtest-v0.5.0.tar.gz",
                },
                sha256 = "586d8a2f4fb5d335583642ccc0ccfc20a0600e8886eebf07707e959bbd3e9b47",
            },
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
            ["0.7.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mtest/archive/refs/tags/v0.7.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mtest/releases/download/v0.7.0/mtest-v0.7.0.tar.gz",
                },
                sha256 = "ab312f844066e6070c929be3eabee9091a903b550b8220c8c59d098e17b42bd6",
            },
            ["0.6.3"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mtest/archive/refs/tags/v0.6.3.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mtest/releases/download/v0.6.3/mtest-v0.6.3.tar.gz",
                },
                sha256 = "a41e5001e40098beacb92d62f92b4f09d0e5dd2113fb98eda5e949af277cbaa2",
            },
            ["0.6.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mtest/archive/refs/tags/v0.6.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mtest/releases/download/v0.6.0/mtest-v0.6.0.tar.gz",
                },
                sha256 = "eb90f823b4b2c6e4407110cd7c4bac290b683fdf3c1b6b471a58e9e7016b5472",
            },
            ["0.5.2"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mtest/archive/refs/tags/v0.5.2.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mtest/releases/download/v0.5.2/mtest-v0.5.2.tar.gz",
                },
                sha256 = "e61819239dca14d3c987f554b8c09e5bc248fdb8bba2650adb53e775db2ccf93",
            },
            ["0.5.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mtest/archive/refs/tags/v0.5.1.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mtest/releases/download/v0.5.1/mtest-v0.5.1.tar.gz",
                },
                sha256 = "48625c19d548aa4e90bf658f895fe99c10bf9316efaa3354d4cb65df9ccd7324",
            },
            ["0.5.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mtest/archive/refs/tags/v0.5.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mtest/releases/download/v0.5.0/mtest-v0.5.0.tar.gz",
                },
                sha256 = "586d8a2f4fb5d335583642ccc0ccfc20a0600e8886eebf07707e959bbd3e9b47",
            },
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
            ["0.7.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mtest/archive/refs/tags/v0.7.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mtest/releases/download/v0.7.0/mtest-v0.7.0.tar.gz",
                },
                sha256 = "ab312f844066e6070c929be3eabee9091a903b550b8220c8c59d098e17b42bd6",
            },
            ["0.6.3"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mtest/archive/refs/tags/v0.6.3.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mtest/releases/download/v0.6.3/mtest-v0.6.3.tar.gz",
                },
                sha256 = "a41e5001e40098beacb92d62f92b4f09d0e5dd2113fb98eda5e949af277cbaa2",
            },
            ["0.6.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mtest/archive/refs/tags/v0.6.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mtest/releases/download/v0.6.0/mtest-v0.6.0.tar.gz",
                },
                sha256 = "eb90f823b4b2c6e4407110cd7c4bac290b683fdf3c1b6b471a58e9e7016b5472",
            },
            ["0.5.2"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mtest/archive/refs/tags/v0.5.2.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mtest/releases/download/v0.5.2/mtest-v0.5.2.tar.gz",
                },
                sha256 = "e61819239dca14d3c987f554b8c09e5bc248fdb8bba2650adb53e775db2ccf93",
            },
            ["0.5.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mtest/archive/refs/tags/v0.5.1.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mtest/releases/download/v0.5.1/mtest-v0.5.1.tar.gz",
                },
                sha256 = "48625c19d548aa4e90bf658f895fe99c10bf9316efaa3354d4cb65df9ccd7324",
            },
            ["0.5.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mtest/archive/refs/tags/v0.5.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mtest/releases/download/v0.5.0/mtest-v0.5.0.tar.gz",
                },
                sha256 = "586d8a2f4fb5d335583642ccc0ccfc20a0600e8886eebf07707e959bbd3e9b47",
            },
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

    mcpp = "*/adapters/gtest/mcpp.toml",
}
