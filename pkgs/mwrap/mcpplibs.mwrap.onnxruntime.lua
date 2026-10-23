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
                url = "https://github.com/mcpplibs/onnxruntime-m/archive/de3a0a9da143f4ae52eb5e1a0302ba3fdf623b6d.tar.gz",
                sha256 = "24d4bc26d2f426e3643f21d289d92e7a23b3ba54524a099a1079c1c490915251",
            },
        },
        macosx = {
            ["1.25.1"] = {
                url = "https://github.com/mcpplibs/onnxruntime-m/archive/de3a0a9da143f4ae52eb5e1a0302ba3fdf623b6d.tar.gz",
                sha256 = "24d4bc26d2f426e3643f21d289d92e7a23b3ba54524a099a1079c1c490915251",
            },
        },
        windows = {
            ["1.25.1"] = {
                url = "https://github.com/mcpplibs/onnxruntime-m/archive/de3a0a9da143f4ae52eb5e1a0302ba3fdf623b6d.tar.gz",
                sha256 = "24d4bc26d2f426e3643f21d289d92e7a23b3ba54524a099a1079c1c490915251",
            },
        },
    },
}
