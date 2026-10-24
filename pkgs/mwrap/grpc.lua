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
                url = "https://github.com/mcpplibs/grpc-m/archive/ab7971acb2ab065352856fd04420c6deb45fad5a.tar.gz",
                sha256 = "46269ec706f87fada3b435d68921296b63df136cae16c5ca79623238ecf6480f",
            },
        },
        macosx = {
            ["1.83.0"] = {
                url = "https://github.com/mcpplibs/grpc-m/archive/ab7971acb2ab065352856fd04420c6deb45fad5a.tar.gz",
                sha256 = "46269ec706f87fada3b435d68921296b63df136cae16c5ca79623238ecf6480f",
            },
        },
    },
}
