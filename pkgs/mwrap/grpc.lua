-- Immutable upstream-aligned mwrap source release; GLOBAL and CN bytes are identical.
--
-- 1.83.0.1 (wrapper revision): compat.openssl 3.5.9 (3.5 LTS) instead of 3.5.1,
-- the OpenSSL of mcpplibs.mwrap.openssl 3.5.9, so a program using both links
-- one OpenSSL; the gRPC source, modules and API are those of 1.83.0, and
-- grpcgen and grpc-plugin are unchanged. Linux and macOS: on Windows the
-- package builds and links, and its runtime aborts at startup (not claimed).
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
            ["1.83.0.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/grpc-m/releases/download/mwrap-1.83.0.1/grpc-m-1.83.0.1.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-grpc/releases/download/1.83.0.1/grpc-m-1.83.0.1.tar.gz",
                },
                sha256 = "5f71291472460f980f64e0d8d76ac8bccd5f76fa4ed3fd35904b22f8db9d17f9",
            },
            ["1.83.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/grpc-m/releases/download/mwrap-1.83.0/grpc-m-1.83.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-grpc/releases/download/1.83.0/grpc-m-1.83.0.tar.gz",
                },
                sha256 = "772403e3d2bc64d00998ba262ebb5edd8476603931e70cd2fea1a3257f6d42ca",
            },
        },
        macosx = {
            ["1.83.0.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/grpc-m/releases/download/mwrap-1.83.0.1/grpc-m-1.83.0.1.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-grpc/releases/download/1.83.0.1/grpc-m-1.83.0.1.tar.gz",
                },
                sha256 = "5f71291472460f980f64e0d8d76ac8bccd5f76fa4ed3fd35904b22f8db9d17f9",
            },
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
