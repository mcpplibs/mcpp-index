-- compat.llamacpp — llama.cpp b10069, source build (Form B inline)
-- CPU backend on all platforms + Metal GPU backend on macOS.
--
-- 消费者引入:
--     mcpp add compat.llamacpp@b10069
--
-- 注意: llama.cpp 使用滚动 "b" 系列 tag (非语义化版本), 消费端应 pin 精确版本:
--     [dependencies.compat]
--     llamacpp = "=b10069"
--
-- 本包编译 ggml 核心张量库 + CPU 后端 + llama 推理层的全部源码 (~175个翻译单元),
-- 产出单一 libllama 目标。不包含 CLI 工具 (llama-cli/llama-server) 和 vendor/
-- 单头文件库 (cpp-httplib/nlohmann/stb/miniaudio), 这些仅被工具层使用。
--
-- ========== 平台架构 ==========
-- linux:   x86-64 with AVX/AVX2/AVX512 auto-detection (编译器内置宏), CPU only
-- macosx:  arm64 (Apple Silicon) with NEON + Metal GPU backend
--           Intel Mac 需用户自行替换 arch/arm/* → arch/x86/*
-- windows: x86-64 with AVX/AVX2 auto-detection, CPU only
--
-- ========== 已知排除 ==========
-- src/models/t5.cpp: upstream 含 template explicit specialization after implicit
-- instantiation 模式, Clang >= 17 在 C++23 两阶段查找规则下拒绝。已从源列表中排除;
-- T5 (Google Text-to-Text Transfer Transformer) 模型架构不可用。
--
-- ========== 依赖 ==========
-- 零外部依赖: 核心库不依赖任何第三方代码 (vendor/ 仅用于 llama-server 等工具)。
--
-- ========== 已知限制 ==========
-- 1. Metal GPU 后端 (macOS) 不嵌入 Metal shader 库。运行时按顺序搜索:
--    a. default.metallib (可执行文件同目录)
--    b. GGML_METAL_PATH_RESOURCES env var → ggml-metal.metal
--    c. ggml-metal.metal (当前工作目录)
--    若未找到 shader, Metal 设备初始化静默失败, 回退到纯 CPU 推理。
--    如需 GPU 加速, 请从 llama.cpp 源码预编译 default.metallib:
--      xcrun -sdk macosx metal -O3 -c ggml-metal.metal -o - |
--        xcrun -sdk macosx metallib - -o default.metallib
-- 2. CUDA/Vulkan/SYCL 等 GPU 后端暂不提供 (需要外部 SDK + 专用编译器)。
-- 3. 单 SIMD 变体 (GGML_CPU_ALL_VARIANTS=OFF)。多变体运行时分发需 CMake 级
--    对同一源文件编译多次的能力, mcpp 当前不支持。
-- 4. 不包含测试/工具/example 代码。
-- 5. Windows 上 GGML CPU 后端依赖 Clang/GCC intrinsics, MSVC 可能编译失败;
--    建议在 Windows 上使用 clang-cl。

package = {
    spec        = "1",
    namespace   = "compat",
    name        = "compat.llamacpp",
    description = "llama.cpp b10069 — LLM inference library (GGML + llama + CPU + Metal GPU)",
    licenses    = {"MIT"},
    repo        = "https://github.com/ggml-org/llama.cpp",
    type        = "package",

    xpm = {
        linux = {
            ["b10069"] = {
                url = {
                    GLOBAL = "https://github.com/ggml-org/llama.cpp/archive/refs/tags/b10069.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/llamacpp/releases/download/b10069/llama.cpp-b10069.tar.gz",
                },
                sha256 = "293a7c65a11e2203c5468a06d0d0e8d21dfff16ad08712b16c61efbe0d93e097",
            },
        },
        macosx = {
            ["b10069"] = {
                url = {
                    GLOBAL = "https://github.com/ggml-org/llama.cpp/archive/refs/tags/b10069.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/llamacpp/releases/download/b10069/llama.cpp-b10069.tar.gz",
                },
                sha256 = "293a7c65a11e2203c5468a06d0d0e8d21dfff16ad08712b16c61efbe0d93e097",
            },
        },
        windows = {
            ["b10069"] = {
                url = {
                    GLOBAL = "https://github.com/ggml-org/llama.cpp/archive/refs/tags/b10069.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/llamacpp/releases/download/b10069/llama.cpp-b10069.tar.gz",
                },
                sha256 = "293a7c65a11e2203c5468a06d0d0e8d21dfff16ad08712b16c61efbe0d93e097",
            },
        },
    },

    mcpp = {
        c_standard  = "c11",
        language    = "c++23",
        import_std  = false,

        -- Public headers: llama.h + llama-cpp.h for consumers,
        -- ggml/include for internal consumption of ggml.h etc.
        include_dirs = {
            "*/include",
            "*/ggml/include",
            -- Internal headers needed by ggml-cpu and llama source files.
            -- mcpp treats all include_dirs as public; these are implementation
            -- detail headers (ggml-impl.h, llama-impl.h, etc.) that consumers
            -- should not include directly.
            "*/ggml/src",
            "*/ggml/src/ggml-cpu",
            -- llama internal headers (models/models.h includes llama-model.h
            -- from the parent directory)
            "*/src",
            -- Metal internal headers (ggml-metal-impl.h, ggml-metal-device.h, etc.)
            "*/ggml/src/ggml-metal",
            -- For generated wrapper files that #include colliding source files
            "mcpp_generated",
        },

        -- Wrappers for sources whose .c and .cpp basenames collide -----------
        -- mcpp derives object filenames from the source path after stripping the
        -- extension, so ggml/src/ggml.c and ggml/src/ggml.cpp both produce
        -- ggml/src/ggml.o and collide. We wrap the .cpp variants under unique
        -- generated names to avoid this.
        generated_files = {
            -- Wrapper for .m/.cpp basename collision: ggml-metal-device.m and
            -- ggml-metal-device.cpp both strip to ggml-metal-device.o.
            -- Wrap the .m variant under a unique generated name.
            ["mcpp_generated/ggml_metal_device_m.m"] = [==[
#include "ggml-metal-device.m"
]==],
            -- Header force-included via -include to provide version string
            -- constants without shell quote-stripping issues.
            ["mcpp_generated/ggml_build_info.h"] = [==[
#pragma once
#define GGML_VERSION "b10069"
#define GGML_COMMIT "b10069"
]==],
            -- Wrappers for .c/.cpp basename collisions (mcpp strips extension
            -- when deriving object name, so ggml.c + ggml.cpp both → ggml.o)
            ["mcpp_generated/ggml_cpp.cpp"] = [==[
#include "ggml.cpp"
]==],
            ["mcpp_generated/ggml-cpu_cpp.cpp"] = [==[
#include "ggml-cpu.cpp"
]==],
        },

        -- Core sources (always compiled) ---------------------------------------
        sources = {
            -- ggml-base
            "*/ggml/src/ggml.c",
            "mcpp_generated/ggml_cpp.cpp",       -- wraps ggml/src/ggml.cpp
            "*/ggml/src/ggml-alloc.c",
            "*/ggml/src/ggml-backend.cpp",
            "*/ggml/src/ggml-backend-meta.cpp",
            "*/ggml/src/ggml-backend-reg.cpp",
            -- Provides dl_load_library/dl_error for ggml-backend-reg.cpp.
            -- Not guarded by GGML_BACKEND_DL in upstream; always needed.
            "*/ggml/src/ggml-backend-dl.cpp",
            "*/ggml/src/ggml-opt.cpp",
            "*/ggml/src/ggml-threading.cpp",
            "*/ggml/src/ggml-quants.c",
            "*/ggml/src/gguf.cpp",

            -- ggml-cpu common
            "*/ggml/src/ggml-cpu/ggml-cpu.c",
            "mcpp_generated/ggml-cpu_cpp.cpp",   -- wraps ggml/src/ggml-cpu/ggml-cpu.cpp
            "*/ggml/src/ggml-cpu/binary-ops.cpp",
            "*/ggml/src/ggml-cpu/hbm.cpp",
            "*/ggml/src/ggml-cpu/ops.cpp",
            "*/ggml/src/ggml-cpu/quants.c",
            "*/ggml/src/ggml-cpu/repack.cpp",
            "*/ggml/src/ggml-cpu/traits.cpp",
            "*/ggml/src/ggml-cpu/unary-ops.cpp",
            "*/ggml/src/ggml-cpu/vec.cpp",

            -- AMX (Intel Advanced Matrix Extensions, Sapphire Rapids+)
            "*/ggml/src/ggml-cpu/amx/amx.cpp",
            "*/ggml/src/ggml-cpu/amx/mmq.cpp",

            -- llama library (29 files)
            "*/src/llama.cpp",
            "*/src/llama-adapter.cpp",
            "*/src/llama-arch.cpp",
            "*/src/llama-batch.cpp",
            "*/src/llama-chat.cpp",
            "*/src/llama-context.cpp",
            "*/src/llama-cparams.cpp",
            "*/src/llama-grammar.cpp",
            "*/src/llama-graph.cpp",
            "*/src/llama-hparams.cpp",
            "*/src/llama-impl.cpp",
            "*/src/llama-io.cpp",
            "*/src/llama-kv-cache.cpp",
            "*/src/llama-kv-cache-dsa.cpp",
            "*/src/llama-kv-cache-dsv4.cpp",
            "*/src/llama-kv-cache-iswa.cpp",
            "*/src/llama-memory.cpp",
            "*/src/llama-memory-hybrid.cpp",
            "*/src/llama-memory-hybrid-iswa.cpp",
            "*/src/llama-memory-recurrent.cpp",
            "*/src/llama-mmap.cpp",
            "*/src/llama-model.cpp",
            "*/src/llama-model-loader.cpp",
            "*/src/llama-model-saver.cpp",
            "*/src/llama-quant.cpp",
            "*/src/llama-sampler.cpp",
            "*/src/llama-vocab.cpp",
            "*/src/unicode.cpp",
            "*/src/unicode-data.cpp",

            -- Per-model architecture implementations (all ~125 files)
            "*/src/models/*.cpp",
        },

        targets = {
            ["llama"] = { kind = "lib" },
        },

        -- Top-level flags (platform-neutral, applies to all TUs) ----------------
        cflags = {
            "-w",
            "-DGGML_USE_CPU",
            "-DGGML_BUILD",
            "-DGGML_SCHED_NO_REALLOC",
            -- Force-include build-info header defining GGML_VERSION/GGML_COMMIT
            -- as string literals (avoid shell quote-stripping of -D flags)
            "-include",
            "ggml_build_info.h",
        },
        cxxflags = {
            "-w",
            "-DGGML_USE_CPU",
            "-DGGML_BUILD",
            "-DGGML_SCHED_NO_REALLOC",
        },

        -- Per-file overrides ---------------------------------------------------
        -- These 3 model files fail with C++23 due to explicit specialization
        -- after implicit instantiation (Clang >= 17 enforces two-phase lookup
        -- more strictly). Compile them in C++20 mode as a workaround.
        flags = {
            {
                glob = "*/src/models/t5.cpp",
                cxxflags = { "-std=c++20" },
            },
            {
                glob = "*/src/models/eagle3.cpp",
                cxxflags = { "-std=c++20" },
            },
            {
                glob = "*/src/models/dflash.cpp",
                cxxflags = { "-std=c++20" },
            },
            -- Metal backend .m files use manual retain/release (MRC), not ARC.
            -- Compile without Automatic Reference Counting.
            {
                glob = "mcpp_generated/ggml_metal_device_m.m",
                cflags = { "-fno-objc-arc" },
            },
            {
                glob = "*/ggml/src/ggml-metal/ggml-metal-context.m",
                cflags = { "-fno-objc-arc" },
            },
            -- ggml-metal.cpp and ggml-metal-device.cpp use std::unique_ptr but
            -- the upstream headers don't pull in <memory> on macOS (libc++ has
            -- stricter transitive includes than libstdc++). Inject it.
            {
                glob = "*/ggml/src/ggml-metal/ggml-metal.cpp",
                cxxflags = { "-include", "memory" },
            },
            {
                glob = "*/ggml/src/ggml-metal/ggml-metal-device.cpp",
                cxxflags = { "-include", "memory" },
            },
        },

        -- Features -------------------------------------------------------------
        features = {
            ["default"] = { implies = { "llamafile" } },

            -- llamafile sgemm: alternative GEMM kernel (performance enhancement)
            -- Enabled by default. Disable with default-features=false if it
            -- causes issues on niche platforms.
            ["llamafile"] = {
                sources = { "*/ggml/src/ggml-cpu/llamafile/sgemm.cpp" },
                defines = { "GGML_USE_LLAMAFILE" },
            },

            -- Metal GPU backend (macOS only, opt-in).
            --
            -- Enables Apple GPU acceleration via MTL. The Metal framework ships
            -- with macOS/Xcode — no external SDK required. At runtime the Metal
            -- shader library must be accessible:
            --   1. default.metallib next to the executable
            --   2. GGML_METAL_PATH_RESOURCES env var -> ggml-metal.metal
            --   3. ggml-metal.metal in cwd
            -- Without a shader library, context creation fails and the program
            -- can't fall back to CPU. Enable only when you can provide the
            -- shader (pre-compiled .metallib or source + xcrun at build time).
            --
            -- Enable with: mcpp add compat.llamacpp@b10069 --features metal
            ["metal"] = {
                sources = {
                    "*/ggml/src/ggml-metal/ggml-metal.cpp",
                    "*/ggml/src/ggml-metal/ggml-metal-common.cpp",
                    "*/ggml/src/ggml-metal/ggml-metal-device.cpp",
                    "mcpp_generated/ggml_metal_device_m.m",
                    "*/ggml/src/ggml-metal/ggml-metal-context.m",
                    "*/ggml/src/ggml-metal/ggml-metal-ops.cpp",
                },
                defines = { "GGML_USE_METAL" },
            },
        },

        deps = {},

        -- =====================================================================
        -- Per-platform blocks
        -- =====================================================================

        -- Linux (x86-64) -------------------------------------------------------
        linux = {
            sources = {
                -- x86 arch-specific CPU backend sources
                "*/ggml/src/ggml-cpu/arch/x86/quants.c",
                "*/ggml/src/ggml-cpu/arch/x86/repack.cpp",
                "*/ggml/src/ggml-cpu/arch/x86/cpu-feats.cpp",
            },
            cflags = {
                "-D_GNU_SOURCE",
            },
            cxxflags = {
                "-D_GNU_SOURCE",
            },
            ldflags = {
                "-lpthread",
                "-ldl",
                "-lm",
            },
        },

        -- macOS (ARM64 / Apple Silicon primary; x86-64 Intel Mac requires
        -- user to substitute arch/arm/* sources with arch/x86/* via their
        -- own mcpp.toml overrides) --------------------------------------------
        macosx = {
            sources = {
                -- ARM arch-specific CPU backend sources (Apple Silicon)
                "*/ggml/src/ggml-cpu/arch/arm/quants.c",
                "*/ggml/src/ggml-cpu/arch/arm/repack.cpp",
                "*/ggml/src/ggml-cpu/arch/arm/cpu-feats.cpp",
            },
            cflags = {
                "-D_DARWIN_C_SOURCE",
            },
            cxxflags = {
                "-D_DARWIN_C_SOURCE",
            },
            ldflags = {
                "-lpthread",
                "-lm",
                -- Metal frameworks: always present in ldflags so the "metal"
                -- feature can link against them. For static builds these are
                -- no-ops unless Metal symbols are actually referenced.
                "-framework", "Foundation",
                "-framework", "Metal",
                "-framework", "MetalKit",
            },
        },

        -- Windows (x86-64) ----------------------------------------------------
        windows = {
            sources = {
                -- x86 arch-specific CPU backend sources
                "*/ggml/src/ggml-cpu/arch/x86/quants.c",
                "*/ggml/src/ggml-cpu/arch/x86/repack.cpp",
                "*/ggml/src/ggml-cpu/arch/x86/cpu-feats.cpp",
            },
            cflags = {
                "-D_CRT_SECURE_NO_WARNINGS",
                "-DWIN32_LEAN_AND_MEAN",
            },
            cxxflags = {
                "-D_CRT_SECURE_NO_WARNINGS",
                "-DWIN32_LEAN_AND_MEAN",
            },
            ldflags = {
                "-lbcrypt",
                "-lws2_32",
            },
        },
    },
}
