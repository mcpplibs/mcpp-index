-- Immutable upstream-aligned mwrap source release; GLOBAL and CN bytes are identical.
package = {
    spec = "1",
    namespace = "mcpplibs.mwrap",
    name = "grpc",
    description = "grpc-m upstream-preserving C++23 module wrapper",
    licenses = { "Apache-2.0" },
    repo = "https://github.com/mcpplibs/grpc-m",
    type = "package",
    extensions = {
        autoupdate = {
            tag = "mwrap-${version}",
            url = "https://github.com/mcpplibs/grpc-m/releases/download/${tag}/grpc-m-${version}.tar.gz",
        },
    },
    xpm = {
        linux = {
            ["1.83.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/grpc-m/releases/download/mwrap-1.83.0/grpc-m-1.83.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-grpc/releases/download/1.83.0/grpc-m-1.83.0.tar.gz",
                },
                sha256 = "772403e3d2bc64d00998ba262ebb5edd8476603931e70cd2fea1a3257f6d42ca",
            },
        },
        macosx = {
            ["1.83.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/grpc-m/releases/download/mwrap-1.83.0/grpc-m-1.83.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-grpc/releases/download/1.83.0/grpc-m-1.83.0.tar.gz",
                },
                sha256 = "772403e3d2bc64d00998ba262ebb5edd8476603931e70cd2fea1a3257f6d42ca",
            },
        },
    },
}
