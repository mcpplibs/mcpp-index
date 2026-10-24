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
                url = "https://github.com/mcpplibs/opencv-m/archive/7e4fe399d3ee4d56133817288fa28ffc38207470.tar.gz",
                sha256 = "1248a3fabfc7116941656c476389e86c7654b229570bc1d00ff4943b6eb1afbf",
            },
        },
        macosx = {
            ["5.0.0.1"] = {
                url = "https://github.com/mcpplibs/opencv-m/archive/7e4fe399d3ee4d56133817288fa28ffc38207470.tar.gz",
                sha256 = "1248a3fabfc7116941656c476389e86c7654b229570bc1d00ff4943b6eb1afbf",
            },
        },
        windows = {
            ["5.0.0.1"] = {
                url = "https://github.com/mcpplibs/opencv-m/archive/7e4fe399d3ee4d56133817288fa28ffc38207470.tar.gz",
                sha256 = "1248a3fabfc7116941656c476389e86c7654b229570bc1d00ff4943b6eb1afbf",
            },
        },
    },
}
