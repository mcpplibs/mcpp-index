-- 命名空间说的是这个库是谁的,不是谁打的包 —— gRPC 是 grpc/grpc 的,本仓库只是
-- vendored 它的源码并加了 module 层。`mcpplibs` 是 mcpp 的默认命名空间
-- (`kDefaultNamespace`),不是这个问题的答案。规则见 mcpp-index#163。
--
-- 与其余四个包不同,这条是**就地迁移**而非"旧的冻结 + 新增":它 2026-08-05 才进
-- 索引(#151),满打满算一天,唯一的消费者是本仓的 tests/examples/grpc-module。
-- 为一天的历史留一份永久重复条目不划算。
--
-- 归档换成 v1.83.0-2:`src/` / `include/` / `third_party/` 与 v1.83.0 逐字节相同,
-- 多出的只有 plugin/(grpc_cpp_plugin)与 rules/(grpcgen)。v1.83.0 的 sha256 已
-- 经发布过,移动 tag 会让它校验失败(mcpp#349:发布数据不得让程序失效),故另起。
-- Form A descriptor: the public gRPC package ships its own mcpp.toml, so this
-- file carries metadata and a download address and nothing else. mcpp's default
-- lookup finds <verdir>/*/mcpp.toml inside the GitHub source tarball wrap.
--
-- WHY THIS IS A SEPARATE REPOSITORY. Every other heavy library in this index is
-- a `compat` descriptor pointing at an upstream tarball. gRPC cannot be: it
-- publishes NO self-contained source artifact. v1.83.0 has no release assets at
-- all, and its tag archive carries abseil, protobuf, re2, boringssl and zlib as
-- EMPTY submodule placeholders (one directory entry each), so there is nothing
-- for `url` + `sha256` to point at. grpc-m's release tarball IS that artifact:
-- upstream's src/ and include/ vendored with zero patches, plus the two
-- third_party pieces gRPC really does ship (address_sorting, xxhash).
--
-- WHAT IT DOES NOT VENDOR is the reason it belongs in this index rather than
-- standing alone. abseil, protobuf(+upb), re2, c-ares, OpenSSL and zlib are all
-- taken from the packages here, so a consumer that also uses protobuf or abseil
-- directly links ONE copy instead of colliding with a second vendored set. The
-- descriptors it depends on landed in #147 (abseil, protobuf), #148 (re2, the
-- protobuf `upb` feature) and #149 (c-ares).
--
-- The package builds without CMake, Bazel or a configure step: gRPC's tree
-- contains no .h.in or config.h.cmake, and its generated upb code is checked in
-- upstream, so mcpp needs only include paths. 1001 TUs, all compiled by the
-- resolved toolchain — no external build system runs, so nothing inherits a
-- foreign C++ ABI.
--
-- Exposes `import grpc;` over gRPC's public C++ API. The import must come AFTER
-- every textual #include in a TU (gRPC's codegen emits headers, so real
-- programs always mix the two); the package's README explains why and the
-- module's own header comment carries the measured failure modes.
--
-- linux + macOS only; see the note in the xpm table.
--
-- Optional feature `ares` is ON by default, matching upstream gRPC:
-- `grpc = { version = "1.83.0", default-features = false }` drops the c-ares
-- resolver and its dependency, which is upstream's own `grpc_no_ares=true`.
package = {
    spec        = "1",
    name        = "grpc",
    namespace   = "grpc",
    description = "gRPC 1.83.0 — vendored upstream source build with import grpc; (abseil/protobuf/re2/c-ares/OpenSSL come from this index)",
    licenses    = {"Apache-2.0"},
    repo        = "https://github.com/mcpplibs/grpc-m",
    type        = "package",

    xpm = {
        linux = {
            ["1.83.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/grpc-m/archive/refs/tags/v1.83.0-3.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/grpc/releases/download/1.83.0/grpc-m-1.83.0-3.tar.gz",
                },
                sha256 = "9a0514a325e348fb013a89bb7b1acb9b41f42d5e9f3c92cee8be788e1e48d74f",
            },
        },
        macosx = {
            ["1.83.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/grpc-m/archive/refs/tags/v1.83.0-3.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/grpc/releases/download/1.83.0/grpc-m-1.83.0-3.tar.gz",
                },
                sha256 = "9a0514a325e348fb013a89bb7b1acb9b41f42d5e9f3c92cee8be788e1e48d74f",
            },
        },
        -- No windows block, and the reason is a DEPENDENCY rather than gRPC:
        -- compat.openssl has no windows xpm entry ("windows deferred —
        -- requires prebuilt MSVC libs"), so resolution there fails with
        --   E_NOT_FOUND: package 'compat:openssl@3.5.1' not found
        -- before anything is compiled. gRPC's secure build cannot drop TLS, so
        -- this package's platform coverage is exactly compat.openssl's, and it
        -- widens the day that entry lands — the package already carries its
        -- windows compile/link flags.
    },

    -- (no `mcpp` field -- default lookup will find <verdir>/*/mcpp.toml)
}
