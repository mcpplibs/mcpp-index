-- ⚠️ 已冻结 —— 本条目不再接收新版本。
--
-- 本包已迁往 `ggml-org:llamacpp@b10069`(见 pkgs/g/ggml-org.llamacpp.lua),理由是命名空间说的是这个库是谁的、
-- 版本说的是你拿到的是哪一版上游;`mcpplibs` 是 mcpp 的默认命名空间,两者都不是它
-- 该表达的东西。规则与全生态迁移表:mcpp-index#163。
--
-- 这里保留而不删除:已经在用 `mcpplibs:llamacpp` 的消费者继续解析得到它。新版本只在新条目下
-- 发布。迁移方式是把依赖写成限定形式 ——
--
--     [dependencies.ggml-org]
--     llamacpp = "b10069"
--
-- Form A descriptor: llama.cpp-m ships its own mcpp.toml and a vendored,
-- pinned llama.cpp checkpoint. The default lookup finds that manifest inside
-- the GitHub tag archive. CPU is the default backend; Metal is an additive
-- package feature for macOS ARM64 consumers.
package = {
    spec        = "1",
    name        = "llamacpp",
    namespace   = "mcpplibs",
    description = "C++23 module package for llama.cpp (import llamacpp)",
    licenses    = {"MIT"},
    repo        = "https://github.com/mcpplibs/llama.cpp-m",
    type        = "package",

    xpm = {
        linux = {
            ["0.1.0"] = {
                url    = "https://github.com/mcpplibs/llama.cpp-m/archive/refs/tags/v0.1.0.tar.gz",
                sha256 = "9af34d44349e520f2f9bd2eace29eb6a634ab4633a7f3bafa225f77be178ca84",
            },
        },
        macosx = {
            ["0.1.0"] = {
                url    = "https://github.com/mcpplibs/llama.cpp-m/archive/refs/tags/v0.1.0.tar.gz",
                sha256 = "9af34d44349e520f2f9bd2eace29eb6a634ab4633a7f3bafa225f77be178ca84",
            },
        },
        windows = {
            ["0.1.0"] = {
                url    = "https://github.com/mcpplibs/llama.cpp-m/archive/refs/tags/v0.1.0.tar.gz",
                sha256 = "9af34d44349e520f2f9bd2eace29eb6a634ab4633a7f3bafa225f77be178ca84",
            },
        },
    },

    -- No `mcpp` field: default lookup finds <verdir>/*/mcpp.toml.
}
