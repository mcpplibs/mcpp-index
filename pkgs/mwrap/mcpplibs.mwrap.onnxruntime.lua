-- Immutable candidate source archive; the CPU SDK is owned by compat.onnxruntime.
-- No release tag is created by this descriptor. Updates require a verified source
-- revision and archive checksum, not a URL-only automatic version substitution.
package = {
    spec = "1",
    namespace = "mcpplibs.mwrap",
    name = "onnxruntime",
    description = "ONNX Runtime 1.25.1 CPU C/C++ APIs through upstream-preserving modules",
    licenses = { "MIT" },
    repo = "https://github.com/mcpplibs/onnxruntime-m",
    type = "package",
    xpm = {
        linux = {
            ["1.25.1"] = {
                url = "https://github.com/mcpplibs/onnxruntime-m/archive/2c3495fb2f6a108404871aaee996b1b104635e0a.tar.gz",
                sha256 = "26a89e349d3eb01e339d3c091ff0371ccc4401026f94698bef8e607ad27bc407",
            },
        },
        macosx = {
            ["1.25.1"] = {
                url = "https://github.com/mcpplibs/onnxruntime-m/archive/2c3495fb2f6a108404871aaee996b1b104635e0a.tar.gz",
                sha256 = "26a89e349d3eb01e339d3c091ff0371ccc4401026f94698bef8e607ad27bc407",
            },
        },
        windows = {
            ["1.25.1"] = {
                url = "https://github.com/mcpplibs/onnxruntime-m/archive/2c3495fb2f6a108404871aaee996b1b104635e0a.tar.gz",
                sha256 = "26a89e349d3eb01e339d3c091ff0371ccc4401026f94698bef8e607ad27bc407",
            },
        },
    },
}
