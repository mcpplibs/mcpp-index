-- Immutable upstream-aligned mwrap source release (protobuf-m mwrap-35.1);
-- GLOBAL and CN bytes are identical.
--
-- The wrapper is Apache-2.0; the library it links, compat.protobuf (Protocol
-- Buffers 35.1 over compat.abseil 20250512.1, the release mcpplibs.mwrap.grpc
-- builds on, so a program using both links one protobuf and one Abseil), is
-- BSD-3-Clause, linked statically: the package deploys the protobuf,
-- utf8_range and Abseil notices beside programs (runtime.deploy). Features:
-- `gzip` (the gzip streams, over compat.zlib), `upb` (protobuf's C runtime),
-- `codegen` (protoc and the mcpplibs.protogen build rule, re-exported, so a
-- consumer's build.mcpp says `protogen::generate_all()`). The wrapper's own CI
-- covers Linux, macOS, Windows and the Web (wasm32-emscripten, tests under
-- node); `codegen` on Linux and macOS (compat.protobuf 35.1 does not build
-- protoc on Windows).
package = {
    spec = "1",
    namespace = "mcpplibs.mwrap",
    name = "protobuf",
    description = "protobuf-m: Protocol Buffers 35.1 (messages, descriptors, reflection, well-known types, JSON and text formats, run-time .proto parsing) as C++23 modules; protoc code generation through the codegen feature",
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
}
