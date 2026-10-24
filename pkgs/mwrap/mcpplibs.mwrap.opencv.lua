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
                url = "https://github.com/mcpplibs/opencv-m/archive/71d0967124222f23999d57e4d514df6a4ed60834.tar.gz",
                sha256 = "d2c0b85536bf4cbb22c914cc055d63cb780cfb25492da3bdc53bd0a08022ed24",
            },
        },
        macosx = {
            ["5.0.0.1"] = {
                url = "https://github.com/mcpplibs/opencv-m/archive/71d0967124222f23999d57e4d514df6a4ed60834.tar.gz",
                sha256 = "d2c0b85536bf4cbb22c914cc055d63cb780cfb25492da3bdc53bd0a08022ed24",
            },
        },
        windows = {
            ["5.0.0.1"] = {
                url = "https://github.com/mcpplibs/opencv-m/archive/71d0967124222f23999d57e4d514df6a4ed60834.tar.gz",
                sha256 = "d2c0b85536bf4cbb22c914cc055d63cb780cfb25492da3bdc53bd0a08022ed24",
            },
        },
    },
}
