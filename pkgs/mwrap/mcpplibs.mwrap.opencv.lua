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
                url = "https://github.com/mcpplibs/opencv-m/archive/5056249212be1470de7fa7c85ea9fc805f72349d.tar.gz",
                sha256 = "9bb69f39be2bd135e83fe1d9afc6b3e00adeaa70a65be315bb29cc5a92e0e40d",
            },
        },
        macosx = {
            ["5.0.0.1"] = {
                url = "https://github.com/mcpplibs/opencv-m/archive/5056249212be1470de7fa7c85ea9fc805f72349d.tar.gz",
                sha256 = "9bb69f39be2bd135e83fe1d9afc6b3e00adeaa70a65be315bb29cc5a92e0e40d",
            },
        },
        windows = {
            ["5.0.0.1"] = {
                url = "https://github.com/mcpplibs/opencv-m/archive/5056249212be1470de7fa7c85ea9fc805f72349d.tar.gz",
                sha256 = "9bb69f39be2bd135e83fe1d9afc6b3e00adeaa70a65be315bb29cc5a92e0e40d",
            },
        },
    },
}
