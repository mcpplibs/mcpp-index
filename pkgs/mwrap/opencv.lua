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
                url = "https://github.com/mcpplibs/opencv-m/archive/52d6e0490645653310bbb6980dce35d3b395e3bf.tar.gz",
                sha256 = "6f7abaefed05b1971e17eebde938e784957efae1f68506a0afffaf6312a27dcb",
            },
        },
        macosx = {
            ["5.0.0"] = {
                url = "https://github.com/mcpplibs/opencv-m/archive/52d6e0490645653310bbb6980dce35d3b395e3bf.tar.gz",
                sha256 = "6f7abaefed05b1971e17eebde938e784957efae1f68506a0afffaf6312a27dcb",
            },
        },
        windows = {
            ["5.0.0"] = {
                url = "https://github.com/mcpplibs/opencv-m/archive/52d6e0490645653310bbb6980dce35d3b395e3bf.tar.gz",
                sha256 = "6f7abaefed05b1971e17eebde938e784957efae1f68506a0afffaf6312a27dcb",
            },
        },
    },
}
