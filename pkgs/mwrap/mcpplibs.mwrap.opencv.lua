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
                url = "https://github.com/mcpplibs/opencv-m/archive/5da7fc8abedc700ce1ed91a1f57067ad552c74fc.tar.gz",
                sha256 = "5b26b4150610a25f69947e570bb6eed5d832b276d79d5e04af5fdc5842f5279c",
            },
        },
        macosx = {
            ["5.0.0.1"] = {
                url = "https://github.com/mcpplibs/opencv-m/archive/5da7fc8abedc700ce1ed91a1f57067ad552c74fc.tar.gz",
                sha256 = "5b26b4150610a25f69947e570bb6eed5d832b276d79d5e04af5fdc5842f5279c",
            },
        },
        windows = {
            ["5.0.0.1"] = {
                url = "https://github.com/mcpplibs/opencv-m/archive/5da7fc8abedc700ce1ed91a1f57067ad552c74fc.tar.gz",
                sha256 = "5b26b4150610a25f69947e570bb6eed5d832b276d79d5e04af5fdc5842f5279c",
            },
        },
    },
}
