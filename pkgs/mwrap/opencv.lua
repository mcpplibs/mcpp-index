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
                url = "https://github.com/mcpplibs/opencv-m/archive/5fd742c2d3d7ffa6b6ce3e375c01d0aae8f4ee5d.tar.gz",
                sha256 = "188dfd39b59109e62e2bdd7f8b1832198e734d62ad06632123bd24662382d341",
            },
        },
        macosx = {
            ["5.0.0"] = {
                url = "https://github.com/mcpplibs/opencv-m/archive/5fd742c2d3d7ffa6b6ce3e375c01d0aae8f4ee5d.tar.gz",
                sha256 = "188dfd39b59109e62e2bdd7f8b1832198e734d62ad06632123bd24662382d341",
            },
        },
        windows = {
            ["5.0.0"] = {
                url = "https://github.com/mcpplibs/opencv-m/archive/5fd742c2d3d7ffa6b6ce3e375c01d0aae8f4ee5d.tar.gz",
                sha256 = "188dfd39b59109e62e2bdd7f8b1832198e734d62ad06632123bd24662382d341",
            },
        },
    },
}
