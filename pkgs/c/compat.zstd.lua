package = {
    spec        = "1",
    namespace   = "compat",
    name        = "zstd",
    description = "Zstandard real-time compression algorithm",
    licenses    = {"BSD-3-Clause", "GPL-2.0-only"},
    repo        = "https://github.com/facebook/zstd",
    type        = "package",

    xpm = {
        linux = {
            ["1.5.7"] = {
                url    = {
                    GLOBAL = "https://github.com/facebook/zstd/archive/refs/tags/v1.5.7.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/zstd/releases/download/1.5.7/zstd-1.5.7.tar.gz",
                },
                sha256 = "37d7284556b20954e56e1ca85b80226768902e2edabd3b649e9e72c0c9012ee3",
            },
        },
        macosx = {
            ["1.5.7"] = {
                url    = {
                    GLOBAL = "https://github.com/facebook/zstd/archive/refs/tags/v1.5.7.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/zstd/releases/download/1.5.7/zstd-1.5.7.tar.gz",
                },
                sha256 = "37d7284556b20954e56e1ca85b80226768902e2edabd3b649e9e72c0c9012ee3",
            },
        },
        windows = {
            ["1.5.7"] = {
                url    = {
                    GLOBAL = "https://github.com/facebook/zstd/archive/refs/tags/v1.5.7.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/zstd/releases/download/1.5.7/zstd-1.5.7.tar.gz",
                },
                sha256 = "37d7284556b20954e56e1ca85b80226768902e2edabd3b649e9e72c0c9012ee3",
            },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        c_standard   = "c11",
        include_dirs = {
            "*/lib",
            "*/lib/common",
            "*/lib/compress",
            "*/lib/decompress",
        },
        cflags = { "-D_GNU_SOURCE", "-DZSTD_DISABLE_ASM=1" },
        sources = {
            "*/lib/common/*.c",
            "*/lib/compress/*.c",
            "*/lib/decompress/*.c",
            "!*/lib/common/zstd_trace.c",
        },
        targets = { ["zstd"] = { kind = "lib" } },
        deps    = {},
    },
}
