-- Immutable candidate source archive; retained OpenCV sources have one owner.
-- No release tag is created by this descriptor. Updates require a verified source
-- revision and archive checksum, not a URL-only automatic version substitution.
package = {
    spec = "1",
    namespace = "mcpplibs.mwrap",
    name = "opencv",
    description = "OpenCV 5.0.0 C++ APIs through feature-selected modules",
    licenses = { "Apache-2.0" },
    repo = "https://github.com/mcpplibs/opencv-m",
    type = "package",
    xpm = {
        linux = {
            ["5.0.0.1"] = {
                url = "https://github.com/mcpplibs/opencv-m/archive/16baa03ef4353188c816a6ff5962a5da53998814.tar.gz",
                sha256 = "556df2142b56cac8f635597bcec9bf32a45957cc0203cff0feb5cf9e256b09c1",
            },
        },
        macosx = {
            ["5.0.0.1"] = {
                url = "https://github.com/mcpplibs/opencv-m/archive/16baa03ef4353188c816a6ff5962a5da53998814.tar.gz",
                sha256 = "556df2142b56cac8f635597bcec9bf32a45957cc0203cff0feb5cf9e256b09c1",
            },
        },
        windows = {
            ["5.0.0.1"] = {
                url = "https://github.com/mcpplibs/opencv-m/archive/16baa03ef4353188c816a6ff5962a5da53998814.tar.gz",
                sha256 = "556df2142b56cac8f635597bcec9bf32a45957cc0203cff0feb5cf9e256b09c1",
            },
        },
    },
}
