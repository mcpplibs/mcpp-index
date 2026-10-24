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
                url = "https://github.com/mcpplibs/opencv-m/archive/019eaadb4c2212246cf20e29447bb1ef960333ba.tar.gz",
                sha256 = "e265add2c6ed3aa9e6dba677a8731e8a385e5f8419093336a18fbdab54be5661",
            },
        },
        macosx = {
            ["5.0.0.1"] = {
                url = "https://github.com/mcpplibs/opencv-m/archive/019eaadb4c2212246cf20e29447bb1ef960333ba.tar.gz",
                sha256 = "e265add2c6ed3aa9e6dba677a8731e8a385e5f8419093336a18fbdab54be5661",
            },
        },
        windows = {
            ["5.0.0.1"] = {
                url = "https://github.com/mcpplibs/opencv-m/archive/019eaadb4c2212246cf20e29447bb1ef960333ba.tar.gz",
                sha256 = "e265add2c6ed3aa9e6dba677a8731e8a385e5f8419093336a18fbdab54be5661",
            },
        },
    },
}
