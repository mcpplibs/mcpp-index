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
            ["1.25.1"] = {
                url = "https://github.com/mcpplibs/onnxruntime-m/archive/dc900ae129a8dda86067cd5ef85658c7606bac7d.tar.gz",
                sha256 = "dda7f64be72ec27756dd200a64297bce67a2717c9a25dbd01643bcb0fc094984",
            },
        },
        macosx = {
            ["1.25.1"] = {
                url = "https://github.com/mcpplibs/onnxruntime-m/archive/dc900ae129a8dda86067cd5ef85658c7606bac7d.tar.gz",
                sha256 = "dda7f64be72ec27756dd200a64297bce67a2717c9a25dbd01643bcb0fc094984",
            },
        },
        windows = {
            ["1.25.1"] = {
                url = "https://github.com/mcpplibs/onnxruntime-m/archive/dc900ae129a8dda86067cd5ef85658c7606bac7d.tar.gz",
                sha256 = "dda7f64be72ec27756dd200a64297bce67a2717c9a25dbd01643bcb0fc094984",
            },
        },
    },
}
