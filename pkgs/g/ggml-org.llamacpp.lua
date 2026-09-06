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
            -- b10069.1 ADDS `backend-vulkan`, AND ITS BUILD PROGRAM NEEDS mcpp
            -- 2026.9.5.2+. It calls `mcpp::toolchain_sysroot()` and
            -- `mcpp::toolchain_binutils_dir()` to tell the shader generator's
            -- compiler where the ecosystem's C library is; without them that
            -- compiler reads the host's, which is the dependency this ecosystem
            -- removes. On an older mcpp the build program does not compile, and
            -- the error names the function rather than the version -- a qualified
            -- name that does not exist is ill-formed, not `false`, so no package
            -- can probe for it (mcpp docs/07).
            --
            -- b10069.2 REFUSES A libc++ TOOLCHAIN BY NAME, and needs
            -- `mcpp::cxx_stdlib()` (2026.9.6.3) to do it. Upstream's
            -- ggml-vulkan.cpp destroys a `std::unique_ptr` to an incomplete type,
            -- which libc++ rejects by static assertion and libstdc++ accepts;
            -- b10069.1 documented that and could not refuse it, because the only
            -- signal available then was `mcpp::compiler()`, which answers "clang"
            -- for both standard libraries.
            --
            -- These entries are what raised the CI pin to 2026.9.6.3
            -- (validate.yml). The pin had drifted about ten releases behind, so
            -- it was not this package that outran the index; the index had
            -- stopped following the engine. The workspace members build
            -- `b10069.2` under the new pin.
            --
            -- `min_mcpp` is NOT the lever for this, and does not move. It states
            -- the oldest mcpp that can RESOLVE every descriptor, and this
            -- descriptor uses no new grammar. A client on the floor keeps the
            -- whole index and keeps `b10069`, which stays published for exactly
            -- that case; raising the floor would refuse the index outright over a
            -- build-program API such a client may never reach.
            --
            -- Both revisions are kept. `b10069` is not semver, so no range
            -- expresses "or later" and consumers pin exactly -- which means a
            -- consumer wanting a feature must be able to name the revision that
            -- has it, and one that cannot use the newer engine must still find a
            -- revision it can build.
            ["b10069.2"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/llama.cpp-m/archive/refs/tags/b10069.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/llamacpp/releases/download/b10069.2/llamacpp-b10069.2.tar.gz",
                },
                sha256 = "1456b6003dada314661534bdcbbd7c73590c0d31940f8750d5f4178d459ffc34",
            },
            ["b10069.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/llama.cpp-m/archive/refs/tags/b10069.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/llamacpp/releases/download/b10069.1/llamacpp-b10069.1.tar.gz",
                },
                sha256 = "4f30c253a7008f82e5bba9d8f894db660e3ebfbc18e2ee745d13c85b7332bbf5",
            },
            ["b10069"] = {
                url = "https://github.com/mcpplibs/llama.cpp-m/archive/refs/tags/b10069.tar.gz",
                sha256 = "be0b0deeb31136ea9cf0ba61eda1fb7baf8795a6579494a0991afd2323213e0b",
            },
        },
        macosx = {
            ["b10069.2"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/llama.cpp-m/archive/refs/tags/b10069.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/llamacpp/releases/download/b10069.2/llamacpp-b10069.2.tar.gz",
                },
                sha256 = "1456b6003dada314661534bdcbbd7c73590c0d31940f8750d5f4178d459ffc34",
            },
            ["b10069.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/llama.cpp-m/archive/refs/tags/b10069.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/llamacpp/releases/download/b10069.1/llamacpp-b10069.1.tar.gz",
                },
                sha256 = "4f30c253a7008f82e5bba9d8f894db660e3ebfbc18e2ee745d13c85b7332bbf5",
            },
            ["b10069"] = {
                url = "https://github.com/mcpplibs/llama.cpp-m/archive/refs/tags/b10069.tar.gz",
                sha256 = "be0b0deeb31136ea9cf0ba61eda1fb7baf8795a6579494a0991afd2323213e0b",
            },
        },
        windows = {
            ["b10069.2"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/llama.cpp-m/archive/refs/tags/b10069.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/llamacpp/releases/download/b10069.2/llamacpp-b10069.2.tar.gz",
                },
                sha256 = "1456b6003dada314661534bdcbbd7c73590c0d31940f8750d5f4178d459ffc34",
            },
            ["b10069.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/llama.cpp-m/archive/refs/tags/b10069.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/llamacpp/releases/download/b10069.1/llamacpp-b10069.1.tar.gz",
                },
                sha256 = "4f30c253a7008f82e5bba9d8f894db660e3ebfbc18e2ee745d13c85b7332bbf5",
            },
            ["b10069"] = {
                url = "https://github.com/mcpplibs/llama.cpp-m/archive/refs/tags/b10069.tar.gz",
                sha256 = "be0b0deeb31136ea9cf0ba61eda1fb7baf8795a6579494a0991afd2323213e0b",
            },
        },
    },

    -- (无 `mcpp` 字段 —— 默认查找会命中 <verdir>/*/mcpp.toml)
}
