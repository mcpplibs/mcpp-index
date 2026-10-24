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
                url = "https://github.com/mcpplibs/opencv-m/archive/8d1ee87583f4a39334476cbaf8e90cfa6a0318fa.tar.gz",
                sha256 = "55f43a1f357854486790f5d8d426a68fbc87c37c2de3d7755d3be3eef3ef2373",
            },
        },
        macosx = {
            ["5.0.0.1"] = {
                url = "https://github.com/mcpplibs/opencv-m/archive/8d1ee87583f4a39334476cbaf8e90cfa6a0318fa.tar.gz",
                sha256 = "55f43a1f357854486790f5d8d426a68fbc87c37c2de3d7755d3be3eef3ef2373",
            },
        },
        windows = {
            ["5.0.0.1"] = {
                url = "https://github.com/mcpplibs/opencv-m/archive/8d1ee87583f4a39334476cbaf8e90cfa6a0318fa.tar.gz",
                sha256 = "55f43a1f357854486790f5d8d426a68fbc87c37c2de3d7755d3be3eef3ef2373",
            },
        },
    },
}
