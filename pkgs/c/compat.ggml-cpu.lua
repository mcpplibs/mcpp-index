-- compat.ggml-cpu — llama.cpp b10069 mandatory CPU backend
--
-- 消费者引入:
--     mcpp add compat.ggml-cpu@b10069
--
-- CPU 是必需基线, 不作为可互换 accelerator 提供.
-- 特性: 默认启用的 llamafile kernel, CPU repack.

package = {
    spec        = "1",
    namespace   = "compat",
    name        = "compat.ggml-cpu",
    description = "GGML CPU backend — b10069",
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
        include_dirs = {
            "*/ggml/include",
            "*/ggml/src",
            "*/ggml/src/ggml-cpu",
            "mcpp_generated",
        },
        generated_files = {
            ["mcpp_generated/ggml-cpu_cpp.cpp"] = "#include \"ggml-cpu.cpp\"\n",
        },
        sources = {
            "*/ggml/src/ggml-cpu/ggml-cpu.c",
            "mcpp_generated/ggml-cpu_cpp.cpp",
            "*/ggml/src/ggml-cpu/binary-ops.cpp",
            "*/ggml/src/ggml-cpu/hbm.cpp",
            "*/ggml/src/ggml-cpu/ops.cpp",
            "*/ggml/src/ggml-cpu/quants.c",
            "*/ggml/src/ggml-cpu/repack.cpp",
            "*/ggml/src/ggml-cpu/traits.cpp",
            "*/ggml/src/ggml-cpu/unary-ops.cpp",
            "*/ggml/src/ggml-cpu/vec.cpp",
            "*/ggml/src/ggml-cpu/amx/amx.cpp",
            "*/ggml/src/ggml-cpu/amx/mmq.cpp",
        },
        targets = {
            ["ggml-cpu"] = { kind = "lib" },
        },
        cflags   = { "-w", "-DGGML_USE_CPU_REPACK" },
        cxxflags = { "-w", "-DGGML_USE_CPU_REPACK" },
        features = {
            ["default"]   = { implies = { "llamafile" } },
            ["llamafile"] = {
                sources = { "*/ggml/src/ggml-cpu/llamafile/sgemm.cpp" },
                flags = {
                    {
                        glob    = "*/ggml/src/ggml-cpu/**",
                        defines = { "GGML_USE_LLAMAFILE" },
                    },
                    {
                        glob    = "mcpp_generated/ggml-cpu_cpp.cpp",
                        defines = { "GGML_USE_LLAMAFILE" },
                    },
                },
            },
        },
        deps = {
            ["compat.ggml-base"] = "b10069",
        },
        linux = {
            sources = {
                "*/ggml/src/ggml-cpu/arch/x86/quants.c",
                "*/ggml/src/ggml-cpu/arch/x86/repack.cpp",
            },
            cflags   = { "-D_GNU_SOURCE" },
            cxxflags = { "-D_GNU_SOURCE" },
        },
        macosx = {
            sources = {
                "*/ggml/src/ggml-cpu/arch/arm/quants.c",
                "*/ggml/src/ggml-cpu/arch/arm/repack.cpp",
            },
            cflags   = { "-D_DARWIN_C_SOURCE" },
            cxxflags = { "-D_DARWIN_C_SOURCE" },
        },
        windows = {
            sources = {
                "*/ggml/src/ggml-cpu/arch/x86/quants.c",
                "*/ggml/src/ggml-cpu/arch/x86/repack.cpp",
            },
            cflags   = { "-D_CRT_SECURE_NO_WARNINGS", "-DWIN32_LEAN_AND_MEAN" },
            cxxflags = { "-D_CRT_SECURE_NO_WARNINGS", "-DWIN32_LEAN_AND_MEAN" },
            ldflags  = { "-ladvapi32" },
        },
    },
}
