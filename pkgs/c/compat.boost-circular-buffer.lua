package = {
    spec        = "1",
    namespace   = "compat",
    name        = "boost-circular-buffer",
    description = "Boost.CircularBuffer 1.92.0 — a STL-compatible ring buffer container",
    licenses    = {"BSL-1.0"},
    repo        = "https://github.com/boostorg/circular_buffer",
    type        = "package",

    extensions = {
        autoupdate = {
            tag = "boost-${version}",
            url = "https://github.com/boostorg/circular_buffer/archive/refs/tags/${tag}.tar.gz",
        },
    },

    xpm = {
        linux = {
            ["1.92.0"] = {
                url    = "https://github.com/boostorg/circular_buffer/archive/refs/tags/boost-1.92.0.tar.gz",
                sha256 = "0845c8f06fe5a40ef5955360f37054bd8bb856d2ecd4ae5daa8c04252358e34e",
            },
        },
        macosx = {
            ["1.92.0"] = {
                url    = "https://github.com/boostorg/circular_buffer/archive/refs/tags/boost-1.92.0.tar.gz",
                sha256 = "0845c8f06fe5a40ef5955360f37054bd8bb856d2ecd4ae5daa8c04252358e34e",
            },
        },
        windows = {
            ["1.92.0"] = {
                url    = "https://github.com/boostorg/circular_buffer/archive/refs/tags/boost-1.92.0.tar.gz",
                sha256 = "0845c8f06fe5a40ef5955360f37054bd8bb856d2ecd4ae5daa8c04252358e34e",
            },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        include_dirs = { "*/include" },
        generated_files = {
            ["mcpp_generated/boost_circular_buffer_anchor.cpp"] = "int mcpp_compat_boost_circular_buffer_anchor(void) { return 0; }\n",
        },
        sources = { "mcpp_generated/boost_circular_buffer_anchor.cpp" },
        targets = { ["boost_circular_buffer"] = { kind = "lib" } },
        deps = {
            ["compat.boost-concept-check"] = "1.92.0",
            ["compat.boost-config"] = "1.92.0",
            ["compat.boost-core"] = "1.92.0",
            ["compat.boost-move"] = "1.92.0",
            ["compat.boost-throw-exception"] = "1.92.0",
            ["compat.boost-type-traits"] = "1.92.0",
        },
    },
}
