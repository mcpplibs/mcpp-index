-- protogen: protoc as an importable mcpp build rule (host-module), the generic,
-- protobuf-owned layer of code generation: one build-graph edge per .proto,
-- C++ messages by default, any protoc plugin as a parameter.
--
--   [build-dependencies]
--   mcpplibs.protogen = { version = "35.1", host-module = true }
--
--   // build.mcpp
--   import mcpp;
--   import protogen;
--   int main() { return protogen::generate_all() ? 0 : 1; }
--
-- mcpplibs.mwrap.protobuf's `codegen` feature brings it (and protoc) with one
-- line. Its version is protobuf's: the rule, the protoc it drives and the
-- runtime the generated code links are one release. It is the rules/ package
-- of the protobuf-m release (mwrap-35.1), the same bytes as
-- pkgs/mwrap/protobuf.lua; grpcgen (pkgs/g/grpcgen.lua) is its gRPC
-- counterpart, with the same API and the gRPC plugin added.
package = {
    spec = "1",
    namespace = "mcpplibs",
    name = "protogen",
    description = "protoc as an importable mcpp build rule (host-module): one edge per .proto, C++ messages, any protoc plugin",
    licenses = { "Apache-2.0" },
    repo = "https://github.com/mcpplibs/protobuf-m",
    type = "package",
    extensions = {
        autoupdate = {
            tag = "mwrap-${version}",
            url = "https://github.com/mcpplibs/protobuf-m/releases/download/${tag}/protobuf-m-${version}.tar.gz",
        },
    },
    xpm = {
        linux = {
            ["35.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/protobuf-m/releases/download/mwrap-35.1/protobuf-m-35.1.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-protobuf/releases/download/35.1/protobuf-m-35.1.tar.gz",
                },
                sha256 = "26b0305e7d602e049391aa579e7e3cef17ebedff27c4ff416054c03df9c687ed",
            },
        },
        macosx = {
            ["35.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/protobuf-m/releases/download/mwrap-35.1/protobuf-m-35.1.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-protobuf/releases/download/35.1/protobuf-m-35.1.tar.gz",
                },
                sha256 = "26b0305e7d602e049391aa579e7e3cef17ebedff27c4ff416054c03df9c687ed",
            },
        },
        windows = {
            ["35.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/protobuf-m/releases/download/mwrap-35.1/protobuf-m-35.1.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-protobuf/releases/download/35.1/protobuf-m-35.1.tar.gz",
                },
                sha256 = "26b0305e7d602e049391aa579e7e3cef17ebedff27c4ff416054c03df9c687ed",
            },
        },
    },
    mcpp = "*/rules/mcpp.toml",
}
