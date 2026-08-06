-- llama.cpp 的 C++23 module 层(import llamacpp;),内含 pin 住的上游 checkpoint。
--
-- 版本就是上游的构建号。旧的 `0.1.0` 需要一张对照表才能读懂 —— llama.cpp-m 的
-- README 当时正是这么写的:"Version 0.1.0 maps to llama.cpp b10069"。
--
-- `b10069` 不是 semver。已实测 mcpp 能处理:解析、版本键匹配、wire 寻址都正常;
-- 不成立的只有**范围**(`^b10069` 解析不了),所以消费者精确 pin。见 mcpp#363。
--
-- 无 CN 镜像(与迁移前一致):mcpp-res 下没有对应仓库,而 docs/cn-mirror.md 明文
-- 允许单字符串 url 作为正当回退 —— lint 只对表形式要求 CN 指向 gitcode。
-- 命名空间说的是这个库是谁的,不是谁打的包;版本说的是你拿到的是哪一版上游。
-- 规则与全生态迁移表:mcpp-index#163。
--
-- `mcpplibs` 是 mcpp 的**默认命名空间**(`kDefaultNamespace`),裸名就落在那里 ——
-- 它不是"上游是谁"的答案。因此上游库迁到上游 org 名下,消费者写限定名。
package = {
    spec        = "1",
    namespace   = "ggml-org",
    name        = "llamacpp",
    description = "C++23 module package for llama.cpp b10069 (import llamacpp;)",
    licenses    = {"MIT"},
    repo        = "https://github.com/mcpplibs/llama.cpp-m",
    type        = "package",

    xpm = {
        linux = {
            ["b10069"] = {
                url = "https://github.com/mcpplibs/llama.cpp-m/archive/refs/tags/b10069.tar.gz",
                sha256 = "be0b0deeb31136ea9cf0ba61eda1fb7baf8795a6579494a0991afd2323213e0b",
            },
        },
        macosx = {
            ["b10069"] = {
                url = "https://github.com/mcpplibs/llama.cpp-m/archive/refs/tags/b10069.tar.gz",
                sha256 = "be0b0deeb31136ea9cf0ba61eda1fb7baf8795a6579494a0991afd2323213e0b",
            },
        },
        windows = {
            ["b10069"] = {
                url = "https://github.com/mcpplibs/llama.cpp-m/archive/refs/tags/b10069.tar.gz",
                sha256 = "be0b0deeb31136ea9cf0ba61eda1fb7baf8795a6579494a0991afd2323213e0b",
            },
        },
    },

    -- (无 `mcpp` 字段 —— 默认查找会命中 <verdir>/*/mcpp.toml)
}
