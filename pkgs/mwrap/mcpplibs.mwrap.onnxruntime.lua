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
                url = "https://github.com/mcpplibs/onnxruntime-m/archive/576c780bfcbd792c7f4194942c90324f183a48aa.tar.gz",
                sha256 = "3654811f65b98ade75b5e46fe59a0c4479d815aa7fa9aceff9f9cc3fffd8ddc1",
            },
        },
        macosx = {
            ["1.25.1"] = {
                url = "https://github.com/mcpplibs/onnxruntime-m/archive/576c780bfcbd792c7f4194942c90324f183a48aa.tar.gz",
                sha256 = "3654811f65b98ade75b5e46fe59a0c4479d815aa7fa9aceff9f9cc3fffd8ddc1",
            },
        },
        windows = {
            ["1.25.1"] = {
                url = "https://github.com/mcpplibs/onnxruntime-m/archive/576c780bfcbd792c7f4194942c90324f183a48aa.tar.gz",
                sha256 = "3654811f65b98ade75b5e46fe59a0c4479d815aa7fa9aceff9f9cc3fffd8ddc1",
            },
        },
    },
}
