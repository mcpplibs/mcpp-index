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
                url = "https://github.com/mcpplibs/grpc-m/archive/f3035f79989e9d3a8c3810ac74a2fe97fe266b1e.tar.gz",
                sha256 = "475df00140ef669453f19e71e519b7a9b6c2e012e11a22cacc4d0c54862f5e8b",
            },
        },
        macosx = {
            ["1.83.0"] = {
                url = "https://github.com/mcpplibs/grpc-m/archive/f3035f79989e9d3a8c3810ac74a2fe97fe266b1e.tar.gz",
                sha256 = "475df00140ef669453f19e71e519b7a9b6c2e012e11a22cacc4d0c54862f5e8b",
            },
        },
    },
}
