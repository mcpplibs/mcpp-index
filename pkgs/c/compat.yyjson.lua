local versions = {
    ["0.13.0"] = {
        url = "https://github.com/ibireme/yyjson/archive/refs/tags/0.13.0.tar.gz",
        sha256 = "34e0f62a2bc11ab20d601e8ca1cc2b2079503aa45119a19133d89d19b94a0fae",
    },
}

-- compat.yyjson — High-performance C JSON parser with SIMD optimizations.
-- Single-source ANSI C library, no mandatory dependencies.
-- EUI-NEO uses yyjson internally via core/platform/json.cpp for JSON parsing.
--
-- All `mcpp` paths are GLOBS relative to the verdir; the leading `*/`
-- absorbs the GitHub tarball's `yyjson-0.12.0/` wrap layer.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "yyjson",
    description = "Fastest C JSON library with SIMD — ANSI C, zero dependencies",
    licenses    = {"MIT"},
    repo        = "https://github.com/ibireme/yyjson",
    type        = "package",

    extensions = {
        autoupdate = {
            tag = "${version}",
            url = "https://github.com/ibireme/yyjson/archive/refs/tags/${tag}.tar.gz",
        },
    },

    xpm = {
        linux = {
            ["0.12.0"] = {
                url    = "https://github.com/ibireme/yyjson/archive/refs/tags/0.12.0.tar.gz",
                sha256 = "b16246f617b2a136c78d73e5e2647c6f1de1313e46678062985bdcf1f40bb75d",
            },
            ["0.13.0"] = versions["0.13.0"],
        },
        macosx = {
            ["0.12.0"] = {
                url    = "https://github.com/ibireme/yyjson/archive/refs/tags/0.12.0.tar.gz",
                sha256 = "b16246f617b2a136c78d73e5e2647c6f1de1313e46678062985bdcf1f40bb75d",
            },
            ["0.13.0"] = versions["0.13.0"],
        },
        windows = {
            ["0.12.0"] = {
                url    = "https://github.com/ibireme/yyjson/archive/refs/tags/0.12.0.tar.gz",
                sha256 = "b16246f617b2a136c78d73e5e2647c6f1de1313e46678062985bdcf1f40bb75d",
            },
            ["0.13.0"] = versions["0.13.0"],
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        c_standard   = "c99",
        include_dirs = { "*/src" },
        sources      = { "*/src/yyjson.c" },
        targets      = { ["yyjson"] = { kind = "lib" } },
        deps         = {},
    },
}
