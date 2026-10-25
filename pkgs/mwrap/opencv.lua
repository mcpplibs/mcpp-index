-- Immutable candidate for the new mwrap identity; formal release URLs follow after source CI.
package = {
    spec = "1",
    namespace = "mcpplibs.mwrap",
    name = "opencv",
    description = "opencv-m upstream-preserving C++23 module wrapper",
    licenses = { "Apache-2.0" },
    repo = "https://github.com/mcpplibs/opencv-m",
    type = "package",
    xpm = {
        linux = {
            ["5.0.0"] = {
                url = "https://github.com/mcpplibs/opencv-m/archive/867b319cbd3b7417f1472bdf0788d9901e0e4f5c.tar.gz",
                sha256 = "8b2c048703b91bcb8b98ffd6adf11508aa47add2a190774186d5cb5e28811d16",
            },
        },
        macosx = {
            ["5.0.0"] = {
                url = "https://github.com/mcpplibs/opencv-m/archive/867b319cbd3b7417f1472bdf0788d9901e0e4f5c.tar.gz",
                sha256 = "8b2c048703b91bcb8b98ffd6adf11508aa47add2a190774186d5cb5e28811d16",
            },
        },
        windows = {
            ["5.0.0"] = {
                url = "https://github.com/mcpplibs/opencv-m/archive/867b319cbd3b7417f1472bdf0788d9901e0e4f5c.tar.gz",
                sha256 = "8b2c048703b91bcb8b98ffd6adf11508aa47add2a190774186d5cb5e28811d16",
            },
        },
    },
}
