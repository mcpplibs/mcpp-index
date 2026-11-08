-- mcpplibs.mtest.manifest --- mtest's static case manifest.
--
-- A package of mcpp-community/mtest (one tag, one archive): the cases a source
-- file declares with mcpplibs.mtest -- objects, the cases they declare, their
-- kinds and attributes -- read from its text without building it. A tool that
-- reads tests (mtest's engine, an editor) depends on it alone.
package = {
    spec        = "1",
    namespace   = "mcpplibs.mtest",
    name        = "manifest",
    description = "mtest's static case manifest: the cases a source file declares, with their kinds and attributes, read without building it",
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
        },
    },

    mcpp = "*/manifest/mcpp.toml",
}
