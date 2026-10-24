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
                url = "https://github.com/mcpplibs/opencv-m/archive/c052ccf15de43689c23b70952bb3c0a63779f71f.tar.gz",
                sha256 = "e7016133547422085b293800d102becfa6c5fc8bd3d0fa9f3a36b88ccf227674",
            },
        },
        macosx = {
            ["5.0.0.1"] = {
                url = "https://github.com/mcpplibs/opencv-m/archive/c052ccf15de43689c23b70952bb3c0a63779f71f.tar.gz",
                sha256 = "e7016133547422085b293800d102becfa6c5fc8bd3d0fa9f3a36b88ccf227674",
            },
        },
        windows = {
            ["5.0.0.1"] = {
                url = "https://github.com/mcpplibs/opencv-m/archive/c052ccf15de43689c23b70952bb3c0a63779f71f.tar.gz",
                sha256 = "e7016133547422085b293800d102becfa6c5fc8bd3d0fa9f3a36b88ccf227674",
            },
        },
    },
}
