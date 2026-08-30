-- Form A: the release ships its own mcpp.toml and module sources.
-- No mcpp-res mirror exists yet, so the upstream URL intentionally stays a string.
package = {
    spec        = "1",
    namespace   = "mcpplibs",
    name        = "cmp",
    description = "A C++23 coroutine runtime project built with mcpp and C++ Modules",
    licenses    = {"Apache-2.0"},
    repo        = "https://github.com/mcpplibs/cmp",
    type        = "package",

    xpm = {
        linux = {
            ["0.1.0"] = {
                url    = "https://github.com/mcpplibs/cmp/releases/download/v0.1.0/cmp-0.1.0.tar.gz",
                sha256 = "17ab5e1e8fdef278d1e82eb62f0387a04e4e6d01f35408af1295de80304de1b9",
            },
        },
        macosx = {
            ["0.1.0"] = {
                url    = "https://github.com/mcpplibs/cmp/releases/download/v0.1.0/cmp-0.1.0.tar.gz",
                sha256 = "17ab5e1e8fdef278d1e82eb62f0387a04e4e6d01f35408af1295de80304de1b9",
            },
        },
        windows = {
            ["0.1.0"] = {
                url    = "https://github.com/mcpplibs/cmp/releases/download/v0.1.0/cmp-0.1.0.tar.gz",
                sha256 = "17ab5e1e8fdef278d1e82eb62f0387a04e4e6d01f35408af1295de80304de1b9",
            },
        },
    },
}
