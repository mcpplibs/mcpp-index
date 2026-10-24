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
                url = "https://github.com/mcpplibs/grpc-m/archive/bda43a641d1c67262ea15fd682466ff3c511796b.tar.gz",
                sha256 = "9f0f356dbf0a591974500bdf49f0c753e944e60a89f8755c43edc79d2b6ecc90",
            },
        },
        macosx = {
            ["1.83.0"] = {
                url = "https://github.com/mcpplibs/grpc-m/archive/bda43a641d1c67262ea15fd682466ff3c511796b.tar.gz",
                sha256 = "9f0f356dbf0a591974500bdf49f0c753e944e60a89f8755c43edc79d2b6ecc90",
            },
        },
    },
}
