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
                url = "https://github.com/mcpplibs/opencv-m/archive/becda22229cb5ed43d7ce098291cf7a4e5f7d15b.tar.gz",
                sha256 = "67fdaec136e4acb4b0aa9d6a37c1c7952fa278180d82d6eab77dcac4211404ce",
            },
        },
        macosx = {
            ["5.0.0.1"] = {
                url = "https://github.com/mcpplibs/opencv-m/archive/becda22229cb5ed43d7ce098291cf7a4e5f7d15b.tar.gz",
                sha256 = "67fdaec136e4acb4b0aa9d6a37c1c7952fa278180d82d6eab77dcac4211404ce",
            },
        },
        windows = {
            ["5.0.0.1"] = {
                url = "https://github.com/mcpplibs/opencv-m/archive/becda22229cb5ed43d7ce098291cf7a4e5f7d15b.tar.gz",
                sha256 = "67fdaec136e4acb4b0aa9d6a37c1c7952fa278180d82d6eab77dcac4211404ce",
            },
        },
    },
}
