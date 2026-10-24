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
                url = "https://github.com/mcpplibs/onnxruntime-m/archive/c4516819f18ffc8f27e45c5516a661d03d9024a9.tar.gz",
                sha256 = "a253358479741fe4aea12da7b783b70926b21b7e32dd4ab305a8237072ed5b02",
            },
        },
        macosx = {
            ["1.25.1.1"] = {
                url = "https://github.com/mcpplibs/onnxruntime-m/archive/c4516819f18ffc8f27e45c5516a661d03d9024a9.tar.gz",
                sha256 = "a253358479741fe4aea12da7b783b70926b21b7e32dd4ab305a8237072ed5b02",
            },
        },
        windows = {
            ["1.25.1.1"] = {
                url = "https://github.com/mcpplibs/onnxruntime-m/archive/c4516819f18ffc8f27e45c5516a661d03d9024a9.tar.gz",
                sha256 = "a253358479741fe4aea12da7b783b70926b21b7e32dd4ab305a8237072ed5b02",
            },
        },
    },
}
