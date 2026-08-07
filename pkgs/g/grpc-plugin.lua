-- grpc_cpp_plugin —— gRPC 的 C++ 代码生成器,作为 mcpp host tool 构建。
--
-- 为什么是独立包而不是 grpc 里的一个 target:mcpp 把一个包编成**一个对象池**,
-- 并把其中每个实现对象链进该包的每个 kind="bin" 目标(src/build/plan.cppm 的
-- "Also include implementation .cpp/.cc/.cxx/.c units")。没有 per-target 源码
-- 分区。所以插件若住在 grpc 里,会链进全部约 1000 个 gRPC TU,并继承 OpenSSL /
-- re2 / c-ares / zlib —— 而它真正需要的只有 protobuf 的 libprotoc(9 个 TU)。
--
-- 也因此它的平台覆盖比主包宽:主包受 compat.openssl 的 windows 缺口限制,插件不受。
--
-- 代码是上游的(plugin/src/compiler/* 每个文件都是 Copyright gRPC authors),
-- 所以归 `grpc` 命名空间。
--
-- manifest 在归档的 plugin/ 子目录里,默认查找(<verdir>/mcpp.toml 与
-- <verdir>/*/mcpp.toml)够不到两级,故用显式 mcpp 指针。
-- 命名空间说的是这个库是谁的,不是谁打的包;版本说的是你拿到的是哪一版上游。
-- 规则与全生态迁移表:mcpp-index#163。
--
-- `mcpplibs` 是 mcpp 的**默认命名空间**(`kDefaultNamespace`),裸名就落在那里 ——
-- 它不是"上游是谁"的答案。因此上游库迁到上游 org 名下,消费者写限定名。
package = {
    spec        = "1",
    namespace   = "grpc",
    name        = "grpc-plugin",
    description = "grpc_cpp_plugin 1.83.0 — the gRPC C++ code generator, buildable as an mcpp host tool",
    licenses    = {"Apache-2.0"},
    repo        = "https://github.com/mcpplibs/grpc-m",
    type        = "package",

    xpm = {
        linux = {
            ["1.83.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/grpc-m/archive/refs/tags/v1.83.0-4.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/grpc/releases/download/1.83.0/grpc-m-1.83.0-4.tar.gz",
                },
                sha256 = "991e9928e0fde0bd9a9fdc80229d976438f03d953b6679a6a71edab258c54baa",
            },
        },
        macosx = {
            ["1.83.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/grpc-m/archive/refs/tags/v1.83.0-4.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/grpc/releases/download/1.83.0/grpc-m-1.83.0-4.tar.gz",
                },
                sha256 = "991e9928e0fde0bd9a9fdc80229d976438f03d953b6679a6a71edab258c54baa",
            },
        },
        windows = {
            ["1.83.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/grpc-m/archive/refs/tags/v1.83.0-4.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/grpc/releases/download/1.83.0/grpc-m-1.83.0-4.tar.gz",
                },
                sha256 = "991e9928e0fde0bd9a9fdc80229d976438f03d953b6679a6a71edab258c54baa",
            },
        },
    },

    mcpp = "*/plugin/mcpp.toml",
}
