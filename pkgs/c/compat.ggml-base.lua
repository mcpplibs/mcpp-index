-- compat.ggml-base — llma.cpp b10069 GGML base library
--
-- 消费者引入:
--     mcpp add compat.ggml-base@b10069
--
-- 注意: llama.cpp 使用滚动 "b" 系列 tag (非语义化版本), 消费端应 pin 精确版本:
--     [dependencies.compat]
--     ggml-base = "=b10069"

package = {
    spec        = "1",
    namespace   = "compat",
    name        = "compat.ggml-base",
    description = "GGML base tensor library — b10069",
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
            "mcpp_generated",
        },
        generated_files = {
            ["mcpp_generated/ggml_cpp.cpp"]     = "#include \"ggml.cpp\"\n",
            ["mcpp_generated/ggml_build_info.h"] = [=[
#pragma once
#define GGML_VERSION "b10069"
#define GGML_COMMIT "178a6c44937154dc4c4eff0d166f4a044c4fceba"
]=],
        },
        sources = {
            "*/ggml/src/ggml.c",
            "mcpp_generated/ggml_cpp.cpp",
            "*/ggml/src/ggml-alloc.c",
            "*/ggml/src/ggml-backend.cpp",
            "*/ggml/src/ggml-backend-meta.cpp",
            "*/ggml/src/ggml-opt.cpp",
            "*/ggml/src/ggml-threading.cpp",
            "*/ggml/src/ggml-quants.c",
            "*/ggml/src/gguf.cpp",
        },
        targets = {
            ["ggml-base"] = { kind = "lib" },
        },
        cflags    = { "-w", "-include", "ggml_build_info.h" },
        cxxflags  = { "-w" },
        linux     = { ldflags = { "-lpthread", "-lm" } },
        macosx    = { ldflags = { "-lpthread", "-lm" } },
    },
}
