-- Immutable candidate for the new mwrap identity; formal release URLs follow after source CI.
package = {
    spec = "1",
    namespace = "mcpplibs.mwrap",
    name = "opencv",
    description = "opencv-m upstream-preserving C++23 module wrapper",
    licenses = { "Apache-2.0" },
    repo = "https://github.com/mcpplibs/opencv-m",
    type = "package",
    xpm = {
        linux = {
            ["5.0.0"] = {
                url = "https://github.com/mcpplibs/opencv-m/archive/671bb173f4163acad705e7760792a4ec80629e83.tar.gz",
                sha256 = "bed373e7dca627ff584e544467c3bf4f2a9a48f36dea2c7471e2aec505f08fa7",
            },
        },
        macosx = {
            ["5.0.0"] = {
                url = "https://github.com/mcpplibs/opencv-m/archive/671bb173f4163acad705e7760792a4ec80629e83.tar.gz",
                sha256 = "bed373e7dca627ff584e544467c3bf4f2a9a48f36dea2c7471e2aec505f08fa7",
            },
        },
        windows = {
            ["5.0.0"] = {
                url = "https://github.com/mcpplibs/opencv-m/archive/671bb173f4163acad705e7760792a4ec80629e83.tar.gz",
                sha256 = "bed373e7dca627ff584e544467c3bf4f2a9a48f36dea2c7471e2aec505f08fa7",
            },
        },
    },
}
