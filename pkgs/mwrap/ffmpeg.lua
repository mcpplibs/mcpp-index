-- Immutable candidate for the new mwrap identity; formal release URLs follow after source CI.
package = {
    spec = "1",
    namespace = "mcpplibs.mwrap",
    name = "ffmpeg",
    description = "ffmpeg-m upstream-preserving C++23 module wrapper",
    licenses = { "Apache-2.0" },
    repo = "https://github.com/mcpplibs/ffmpeg-m",
    type = "package",
    xpm = {
        linux = {
            ["8.1.2"] = {
                url = "https://github.com/mcpplibs/ffmpeg-m/archive/0ec0231fa4276b109134136234ffc67169bca6ec.tar.gz",
                sha256 = "25951bb282c1feaa0408b23c4d2b242f846dad0ee35978b18bcfd954a6fa9c23",
            },
        },
        macosx = {
            ["8.1.2"] = {
                url = "https://github.com/mcpplibs/ffmpeg-m/archive/0ec0231fa4276b109134136234ffc67169bca6ec.tar.gz",
                sha256 = "25951bb282c1feaa0408b23c4d2b242f846dad0ee35978b18bcfd954a6fa9c23",
            },
        },
        windows = {
            ["8.1.2"] = {
                url = "https://github.com/mcpplibs/ffmpeg-m/archive/0ec0231fa4276b109134136234ffc67169bca6ec.tar.gz",
                sha256 = "25951bb282c1feaa0408b23c4d2b242f846dad0ee35978b18bcfd954a6fa9c23",
            },
        },
    },
}
