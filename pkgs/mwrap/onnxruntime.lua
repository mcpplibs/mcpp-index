-- Immutable upstream-aligned mwrap source release; GLOBAL and CN bytes are identical.
package = {
    spec = "1",
    namespace = "mcpplibs.mwrap",
    name = "onnxruntime",
    description = "onnxruntime-m upstream-preserving C++23 module wrapper",
    licenses = { "Apache-2.0" },
    repo = "https://github.com/mcpplibs/onnxruntime-m",
    type = "package",
    extensions = {
        autoupdate = {
            tag = "mwrap-${version}",
            url = "https://github.com/mcpplibs/onnxruntime-m/releases/download/${tag}/onnxruntime-m-${version}.tar.gz",
        },
    },
    xpm = {
        linux = {
            ["1.25.1.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/onnxruntime-m/releases/download/mwrap-1.25.1.1/onnxruntime-m-1.25.1.1.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-onnxruntime/releases/download/1.25.1.1/onnxruntime-m-1.25.1.1.tar.gz",
                },
                sha256 = "a2d3c7fa22901b34b3f16ef3521dd1502b5aca26d711e1b62fb4609a1b12ea16",
            },
            ["1.25.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/onnxruntime-m/releases/download/mwrap-1.25.1/onnxruntime-m-1.25.1.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-onnxruntime/releases/download/1.25.1/onnxruntime-m-1.25.1.tar.gz",
                },
                revision = 1,
                floor = 1,
                sha256 = "bec1f319d9869624b0efeb20c0376c1e429b07f6652f65536f17fca722458d6e",
            },
        },
        macosx = {
            ["1.25.1.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/onnxruntime-m/releases/download/mwrap-1.25.1.1/onnxruntime-m-1.25.1.1.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-onnxruntime/releases/download/1.25.1.1/onnxruntime-m-1.25.1.1.tar.gz",
                },
                sha256 = "a2d3c7fa22901b34b3f16ef3521dd1502b5aca26d711e1b62fb4609a1b12ea16",
            },
            ["1.25.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/onnxruntime-m/releases/download/mwrap-1.25.1/onnxruntime-m-1.25.1.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-onnxruntime/releases/download/1.25.1/onnxruntime-m-1.25.1.tar.gz",
                },
                revision = 1,
                floor = 1,
                sha256 = "bec1f319d9869624b0efeb20c0376c1e429b07f6652f65536f17fca722458d6e",
            },
        },
        windows = {
            ["1.25.1.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/onnxruntime-m/releases/download/mwrap-1.25.1.1/onnxruntime-m-1.25.1.1.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-onnxruntime/releases/download/1.25.1.1/onnxruntime-m-1.25.1.1.tar.gz",
                },
                sha256 = "a2d3c7fa22901b34b3f16ef3521dd1502b5aca26d711e1b62fb4609a1b12ea16",
            },
            ["1.25.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/onnxruntime-m/releases/download/mwrap-1.25.1/onnxruntime-m-1.25.1.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-onnxruntime/releases/download/1.25.1/onnxruntime-m-1.25.1.tar.gz",
                },
                revision = 1,
                floor = 1,
                sha256 = "bec1f319d9869624b0efeb20c0376c1e429b07f6652f65536f17fca722458d6e",
            },
        },
    },
}
