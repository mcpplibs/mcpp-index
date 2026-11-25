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
            ["0.11.3"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mtest/archive/refs/tags/v0.11.3.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mtest/releases/download/v0.11.3/mtest-v0.11.3.tar.gz",
                },
                sha256 = "da46a7361a5c7dbdcad3aab3d7e2de324bd5b8248967dd787eedf1ae6b5f529f",
            },
            ["0.11.2"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mtest/archive/refs/tags/v0.11.2.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mtest/releases/download/v0.11.2/mtest-v0.11.2.tar.gz",
                },
                sha256 = "1236da4c4529faaf1c4524611e653f89c7fa43868d279357ade85cf7e3fcbc4c",
            },
            ["0.11.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mtest/archive/refs/tags/v0.11.1.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mtest/releases/download/v0.11.1/mtest-v0.11.1.tar.gz",
                },
                sha256 = "69c45ff361a99fc578de9450628d86cb64996dfd9c01ff4e9fd71710ec1b3509",
            },
            ["0.11.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mtest/archive/refs/tags/v0.11.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mtest/releases/download/v0.11.0/mtest-v0.11.0.tar.gz",
                },
                sha256 = "457635770e34e1915b0ed87032c12f435f45a1477caaa60a4ffe9da56da7d398",
            },
        },
        macosx = {
            ["0.11.3"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mtest/archive/refs/tags/v0.11.3.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mtest/releases/download/v0.11.3/mtest-v0.11.3.tar.gz",
                },
                sha256 = "da46a7361a5c7dbdcad3aab3d7e2de324bd5b8248967dd787eedf1ae6b5f529f",
            },
            ["0.11.2"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mtest/archive/refs/tags/v0.11.2.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mtest/releases/download/v0.11.2/mtest-v0.11.2.tar.gz",
                },
                sha256 = "1236da4c4529faaf1c4524611e653f89c7fa43868d279357ade85cf7e3fcbc4c",
            },
            ["0.11.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mtest/archive/refs/tags/v0.11.1.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mtest/releases/download/v0.11.1/mtest-v0.11.1.tar.gz",
                },
                sha256 = "69c45ff361a99fc578de9450628d86cb64996dfd9c01ff4e9fd71710ec1b3509",
            },
            ["0.11.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mtest/archive/refs/tags/v0.11.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mtest/releases/download/v0.11.0/mtest-v0.11.0.tar.gz",
                },
                sha256 = "457635770e34e1915b0ed87032c12f435f45a1477caaa60a4ffe9da56da7d398",
            },
        },
        windows = {
            ["0.11.3"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mtest/archive/refs/tags/v0.11.3.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mtest/releases/download/v0.11.3/mtest-v0.11.3.tar.gz",
                },
                sha256 = "da46a7361a5c7dbdcad3aab3d7e2de324bd5b8248967dd787eedf1ae6b5f529f",
            },
            ["0.11.2"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mtest/archive/refs/tags/v0.11.2.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mtest/releases/download/v0.11.2/mtest-v0.11.2.tar.gz",
                },
                sha256 = "1236da4c4529faaf1c4524611e653f89c7fa43868d279357ade85cf7e3fcbc4c",
            },
            ["0.11.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mtest/archive/refs/tags/v0.11.1.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mtest/releases/download/v0.11.1/mtest-v0.11.1.tar.gz",
                },
                sha256 = "69c45ff361a99fc578de9450628d86cb64996dfd9c01ff4e9fd71710ec1b3509",
            },
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
