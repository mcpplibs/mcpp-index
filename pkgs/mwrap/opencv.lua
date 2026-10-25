-- Immutable upstream-aligned mwrap source release; GLOBAL and CN bytes are identical.
package = {
    spec = "1",
    namespace = "mcpplibs.mwrap",
    name = "opencv",
    description = "opencv-m upstream-preserving C++23 module wrapper",
    licenses = { "Apache-2.0" },
    repo = "https://github.com/mcpplibs/opencv-m",
    type = "package",
    extensions = {
        autoupdate = {
            tag = "mwrap-${version}",
            url = "https://github.com/mcpplibs/opencv-m/releases/download/${tag}/opencv-m-${version}.tar.gz",
        },
    },
    xpm = {
        linux = {
            ["5.0.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/opencv-m/releases/download/mwrap-5.0.0/opencv-m-5.0.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-opencv/releases/download/5.0.0/opencv-m-5.0.0.tar.gz",
                },
                sha256 = "01e440d03eef4b77a7bb7a7043f2c28b83f18e9270f203462a0fe69c1d41d0a2",
            },
        },
        macosx = {
            ["5.0.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/opencv-m/releases/download/mwrap-5.0.0/opencv-m-5.0.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-opencv/releases/download/5.0.0/opencv-m-5.0.0.tar.gz",
                },
                sha256 = "01e440d03eef4b77a7bb7a7043f2c28b83f18e9270f203462a0fe69c1d41d0a2",
            },
        },
        windows = {
            ["5.0.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/opencv-m/releases/download/mwrap-5.0.0/opencv-m-5.0.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-opencv/releases/download/5.0.0/opencv-m-5.0.0.tar.gz",
                },
                sha256 = "01e440d03eef4b77a7bb7a7043f2c28b83f18e9270f203462a0fe69c1d41d0a2",
            },
        },
    },
}
