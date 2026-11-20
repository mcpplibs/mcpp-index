-- mcpplibs.mtest.doctest --- doctest speaking the mtest test protocol.
--
-- A package of mcpp-community/mtest (one tag, one archive): a test main that
-- lists, selects and reports doctest's cases by the protocol, level 1, and doctest's
-- implementation compiled once in the package (mtest 0.11.0).
package = {
    spec        = "1",
    namespace   = "mcpplibs.mtest",
    name        = "doctest",
    description = "doctest speaking the mtest test protocol: doctest's implementation and a test main that lists, selects and reports its cases",
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
            ["0.11.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mtest/archive/refs/tags/v0.11.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mtest/releases/download/v0.11.0/mtest-v0.11.0.tar.gz",
                },
                sha256 = "457635770e34e1915b0ed87032c12f435f45a1477caaa60a4ffe9da56da7d398",
            },
        },
        macosx = {
            ["0.11.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mtest/archive/refs/tags/v0.11.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mtest/releases/download/v0.11.0/mtest-v0.11.0.tar.gz",
                },
                sha256 = "457635770e34e1915b0ed87032c12f435f45a1477caaa60a4ffe9da56da7d398",
            },
        },
        windows = {
            ["0.11.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mtest/archive/refs/tags/v0.11.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mtest/releases/download/v0.11.0/mtest-v0.11.0.tar.gz",
                },
                sha256 = "457635770e34e1915b0ed87032c12f435f45a1477caaa60a4ffe9da56da7d398",
            },
        },
    },

    mcpp = "*/adapters/doctest/mcpp.toml",
}
