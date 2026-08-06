-- grpcgen —— protoc + grpc_cpp_plugin 的调用收成一条可 import 的构建规则。
--
--   [dependencies]
--   grpcgen = { version = "1.83.0", host-module = true }
--
--   // build.mcpp
--   import mcpp;
--   import grpcgen;
--   int main() { return grpcgen::generate({"helloworld"}) ? 0 : 1; }
--
-- 这是本生态**自己写的** 163 行 C++(不是上游任何东西),所以留在 `mcpplibs`。
-- 包名承重:mcpp 用依赖的裸 package.name 注册 host 模块,故包名即模块名,必须是
-- 合法 C++ 模块名 —— `grpc-rules` 不行(连字符),`grpcgen` 可以。
--
-- 需要 mcpp >= 2026.8.5.2:规则里 `import std;` 与 `import mcpp;` 在此之前都编不过。
-- 命名空间说的是这个库是谁的,不是谁打的包;版本说的是你拿到的是哪一版上游。
-- 规则与全生态迁移表:mcpp-index#163。
--
-- `mcpplibs` 是 mcpp 的**默认命名空间**(`kDefaultNamespace`),裸名就落在那里 ——
-- 它不是"上游是谁"的答案。因此上游库迁到上游 org 名下,消费者写限定名。
package = {
    spec        = "1",
    namespace   = "mcpplibs",
    name        = "grpcgen",
    description = "protoc + grpc_cpp_plugin codegen as an importable mcpp build rule (host-module)",
    licenses    = {"Apache-2.0"},
    repo        = "https://github.com/mcpplibs/grpc-m",
    type        = "package",

    xpm = {
        linux = {
            ["1.83.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/grpc-m/archive/refs/tags/v1.83.0-2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/grpc/releases/download/1.83.0/grpc-m-1.83.0-2.tar.gz",
                },
                sha256 = "9083a85879f67b726d68130ca8374e791e3cc73f9fff8d324cde11314c70b06e",
            },
        },
        macosx = {
            ["1.83.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/grpc-m/archive/refs/tags/v1.83.0-2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/grpc/releases/download/1.83.0/grpc-m-1.83.0-2.tar.gz",
                },
                sha256 = "9083a85879f67b726d68130ca8374e791e3cc73f9fff8d324cde11314c70b06e",
            },
        },
        windows = {
            ["1.83.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/grpc-m/archive/refs/tags/v1.83.0-2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/grpc/releases/download/1.83.0/grpc-m-1.83.0-2.tar.gz",
                },
                sha256 = "9083a85879f67b726d68130ca8374e791e3cc73f9fff8d324cde11314c70b06e",
            },
        },
    },

    mcpp = "*/rules/mcpp.toml",
}
