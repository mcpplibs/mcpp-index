-- Immutable candidate for the new mwrap identity; formal release URLs follow after source CI.
package = {
    spec = "1",
    namespace = "mcpplibs.mwrap",
    name = "onnxruntime",
    description = "onnxruntime-m upstream-preserving C++23 module wrapper",
    licenses = { "MIT" },
    repo = "https://github.com/mcpplibs/onnxruntime-m",
    type = "package",
    xpm = {
        linux = {
            ["1.25.1"] = {
                url = "https://github.com/mcpplibs/onnxruntime-m/archive/45073fc979c8091f9d94988ea973e634fa5728ff.tar.gz",
                sha256 = "29abd207e2072a460bc992a02f8433efcde0245486d92f6a9dca23008cc079d7",
            },
        },
        macosx = {
            ["1.25.1"] = {
                url = "https://github.com/mcpplibs/onnxruntime-m/archive/45073fc979c8091f9d94988ea973e634fa5728ff.tar.gz",
                sha256 = "29abd207e2072a460bc992a02f8433efcde0245486d92f6a9dca23008cc079d7",
            },
        },
        windows = {
            ["1.25.1"] = {
                url = "https://github.com/mcpplibs/onnxruntime-m/archive/45073fc979c8091f9d94988ea973e634fa5728ff.tar.gz",
                sha256 = "29abd207e2072a460bc992a02f8433efcde0245486d92f6a9dca23008cc079d7",
            },
        },
    },
}
