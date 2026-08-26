-- Form B C-source compat descriptor for Brotli. The three source globs match
-- upstream v1.2.0's BROTLI_COMMON_SOURCES, BROTLI_DEC_SOURCES, and
-- BROTLI_ENC_SOURCES CMake sets; the CLI, tests, fuzzers, and the optional C++
-- lazy static-initialization implementation are outside those sets.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "brotli",
    description = "Brotli compression library",
    licenses    = {"MIT"},
    repo        = "https://github.com/google/brotli",
    type        = "package",

    xpm = {
        linux = {
            ["1.2.0"] = {
                url    = "https://github.com/google/brotli/archive/refs/tags/v1.2.0.tar.gz",
                sha256 = "816c96e8e8f193b40151dad7e8ff37b1221d019dbcb9c35cd3fadbfe6477dfec",
            },
        },
        macosx = {
            ["1.2.0"] = {
                url    = "https://github.com/google/brotli/archive/refs/tags/v1.2.0.tar.gz",
                sha256 = "816c96e8e8f193b40151dad7e8ff37b1221d019dbcb9c35cd3fadbfe6477dfec",
            },
        },
        windows = {
            ["1.2.0"] = {
                url    = "https://github.com/google/brotli/archive/refs/tags/v1.2.0.tar.gz",
                sha256 = "816c96e8e8f193b40151dad7e8ff37b1221d019dbcb9c35cd3fadbfe6477dfec",
            },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        c_standard   = "c11",
        include_dirs = { "*/c/include" },
        sources      = {
            "*/c/common/*.c",
            "*/c/dec/*.c",
            "*/c/enc/*.c",
        },
        targets = { ["brotli"] = { kind = "lib" } },
        deps    = {},

        -- Upstream detects libm and propagates it for static builds.
        linux   = { ldflags = { "-lm" } },
        macosx  = { ldflags = { "-lm" } },
        windows = {
            -- This is upstream's only MSVC-specific library definition.
            cflags = { "-D_CRT_SECURE_NO_WARNINGS" },
        },
    },
}
