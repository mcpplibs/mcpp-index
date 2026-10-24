-- Immutable candidate for the new mwrap identity; formal release URLs follow after source CI.
package = {
    spec = "1",
    namespace = "mcpplibs.mwrap",
    name = "grpc",
    description = "grpc-m upstream-preserving C++23 module wrapper",
    licenses = { "Apache-2.0" },
    repo = "https://github.com/mcpplibs/grpc-m",
    type = "package",
    xpm = {
        linux = {
            ["1.83.0"] = {
                url = "https://github.com/mcpplibs/grpc-m/archive/72281792e3ed20f7a1b832efa98be7176bb80170.tar.gz",
                sha256 = "9842a747bdf81d7625ff6c2cc611d92a2be46f786374d79dc84a569985ed631d",
            },
        },
        macosx = {
            ["1.83.0"] = {
                url = "https://github.com/mcpplibs/grpc-m/archive/72281792e3ed20f7a1b832efa98be7176bb80170.tar.gz",
                sha256 = "9842a747bdf81d7625ff6c2cc611d92a2be46f786374d79dc84a569985ed631d",
            },
        },
    },
}
