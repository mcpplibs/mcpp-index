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
                url = "https://github.com/mcpplibs/opencv-m/archive/726f016e6616546108bea831387cda50ebac1667.tar.gz",
                sha256 = "2cb4d5820d20f3ddf8233d95303a032d3b440231f78f9ce0856d1805dfc6993b",
            },
        },
        macosx = {
            ["5.0.0"] = {
                url = "https://github.com/mcpplibs/opencv-m/archive/726f016e6616546108bea831387cda50ebac1667.tar.gz",
                sha256 = "2cb4d5820d20f3ddf8233d95303a032d3b440231f78f9ce0856d1805dfc6993b",
            },
        },
        windows = {
            ["5.0.0"] = {
                url = "https://github.com/mcpplibs/opencv-m/archive/726f016e6616546108bea831387cda50ebac1667.tar.gz",
                sha256 = "2cb4d5820d20f3ddf8233d95303a032d3b440231f78f9ce0856d1805dfc6993b",
            },
        },
    },
}
