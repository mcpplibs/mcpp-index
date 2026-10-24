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
                url = "https://github.com/mcpplibs/onnxruntime-m/archive/a20def5e72c167a604045218c0f688e04f36611b.tar.gz",
                sha256 = "940854eda99acc97c18cb806d5dacc1e5d22d41f1a97e223b24ac7158259869e",
            },
        },
        macosx = {
            ["1.25.1"] = {
                url = "https://github.com/mcpplibs/onnxruntime-m/archive/a20def5e72c167a604045218c0f688e04f36611b.tar.gz",
                sha256 = "940854eda99acc97c18cb806d5dacc1e5d22d41f1a97e223b24ac7158259869e",
            },
        },
        windows = {
            ["1.25.1"] = {
                url = "https://github.com/mcpplibs/onnxruntime-m/archive/a20def5e72c167a604045218c0f688e04f36611b.tar.gz",
                sha256 = "940854eda99acc97c18cb806d5dacc1e5d22d41f1a97e223b24ac7158259869e",
            },
        },
    },
}
