-- openkal-dos --- openkal on DOS through DPMI. TECHNICAL EXPERIMENT ONLY (the
-- package's README): no stability, no support. A project names the target
-- `i686-dos-musl` with openkal-platform (0.28.0+), which selects this
-- implementation, seals the program with openkal-dos-tools' okdos and runs it
-- under DOSBox Staging through dirun.
package = {
    spec        = "1",
    namespace   = "mcpplibs",
    name        = "openkal-dos",
    description = "An implementation of openkal on DOS through DPMI (technical experiment only)",
    licenses    = {"Apache-2.0"},
    repo        = "https://github.com/mcpplibs/openkal-dos",
    type        = "package",

    xpm = {
        linux = {
            ["0.2.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-dos/archive/refs/tags/0.2.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/openkal-dos/releases/download/0.2.0/openkal-dos-0.2.0.tar.gz",
                },
                sha256 = "c909dfe41c96b781dba99ab5c04d2a9efd7cb72abe1a6d0079cd5027b664cb31",
            },
            ["0.1.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-dos/archive/refs/tags/0.1.1.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/openkal-dos/releases/download/0.1.1/openkal-dos-0.1.1.tar.gz",
                },
                sha256 = "7b2c0509dc27ac75a1d625aefc53fc164547830ae9bccc41c3d37ebef834a1b2",
            },
            ["0.1.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-dos/archive/refs/tags/0.1.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/openkal-dos/releases/download/0.1.0/openkal-dos-0.1.0.tar.gz",
                },
                sha256 = "2214f353512e114b6fad44e7cfe5f711931a3baefa29de4310b95039d3192e23",
            },
        },
        macosx = {
            ["0.2.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-dos/archive/refs/tags/0.2.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/openkal-dos/releases/download/0.2.0/openkal-dos-0.2.0.tar.gz",
                },
                sha256 = "c909dfe41c96b781dba99ab5c04d2a9efd7cb72abe1a6d0079cd5027b664cb31",
            },
            ["0.1.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-dos/archive/refs/tags/0.1.1.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/openkal-dos/releases/download/0.1.1/openkal-dos-0.1.1.tar.gz",
                },
                sha256 = "7b2c0509dc27ac75a1d625aefc53fc164547830ae9bccc41c3d37ebef834a1b2",
            },
            ["0.1.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-dos/archive/refs/tags/0.1.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/openkal-dos/releases/download/0.1.0/openkal-dos-0.1.0.tar.gz",
                },
                sha256 = "2214f353512e114b6fad44e7cfe5f711931a3baefa29de4310b95039d3192e23",
            },
        },
        windows = {
            ["0.2.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-dos/archive/refs/tags/0.2.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/openkal-dos/releases/download/0.2.0/openkal-dos-0.2.0.tar.gz",
                },
                sha256 = "c909dfe41c96b781dba99ab5c04d2a9efd7cb72abe1a6d0079cd5027b664cb31",
            },
            ["0.1.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-dos/archive/refs/tags/0.1.1.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/openkal-dos/releases/download/0.1.1/openkal-dos-0.1.1.tar.gz",
                },
                sha256 = "7b2c0509dc27ac75a1d625aefc53fc164547830ae9bccc41c3d37ebef834a1b2",
            },
            ["0.1.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/openkal-dos/archive/refs/tags/0.1.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/openkal-dos/releases/download/0.1.0/openkal-dos-0.1.0.tar.gz",
                },
                sha256 = "2214f353512e114b6fad44e7cfe5f711931a3baefa29de4310b95039d3192e23",
            },
        },
    },

    -- The package's own manifest, inside the tarball's wrap directory.
    mcpp = "*/mcpp.toml",
}
