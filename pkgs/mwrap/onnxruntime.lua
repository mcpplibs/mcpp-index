-- Immutable candidate for the new mwrap identity; formal release URLs follow after source CI.
package = {
    spec = "1",
    namespace = "mcpplibs.mwrap",
    name = "onnxruntime",
    description = "onnxruntime-m upstream-preserving C++23 module wrapper",
    licenses = { "Apache-2.0" },
    repo = "https://github.com/mcpplibs/onnxruntime-m",
    type = "package",
    xpm = {
        linux = {
            ["1.25.1.1"] = {
                url = "https://github.com/mcpplibs/onnxruntime-m/archive/8ae5e786b707f445299c13b3b8ecdfcf33938ff3.tar.gz",
                sha256 = "fdeb077ebb08c8d7ddc2bff8784b2529071b8128f7f1c6b12ae8a6de6a8f2a3a",
            },
        },
        macosx = {
            ["1.25.1.1"] = {
                url = "https://github.com/mcpplibs/onnxruntime-m/archive/8ae5e786b707f445299c13b3b8ecdfcf33938ff3.tar.gz",
                sha256 = "fdeb077ebb08c8d7ddc2bff8784b2529071b8128f7f1c6b12ae8a6de6a8f2a3a",
            },
        },
        windows = {
            ["1.25.1.1"] = {
                url = "https://github.com/mcpplibs/onnxruntime-m/archive/8ae5e786b707f445299c13b3b8ecdfcf33938ff3.tar.gz",
                sha256 = "fdeb077ebb08c8d7ddc2bff8784b2529071b8128f7f1c6b12ae8a6de6a8f2a3a",
            },
        },
    },
}
