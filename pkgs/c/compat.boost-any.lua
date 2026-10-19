package = {
    spec        = "1",
    namespace   = "compat",
    name        = "boost-any",
    description = "Boost.Any 1.92.0 — a type-safe container for single values of different types",
    licenses    = {"BSL-1.0"},
    repo        = "https://github.com/boostorg/any",
    type        = "package",

    extensions = {
        autoupdate = {
            tag = "boost-${version}",
            url = "https://github.com/boostorg/any/archive/refs/tags/${tag}.tar.gz",
        },
    },

    xpm = {
        linux = {
            ["1.92.0"] = {
                url    = "https://github.com/boostorg/any/archive/refs/tags/boost-1.92.0.tar.gz",
                sha256 = "335090455387b06b356bbc317d4949f6e7455165942bd7f50dbfe9cab96d624a",
            },
        },
        macosx = {
            ["1.92.0"] = {
                url    = "https://github.com/boostorg/any/archive/refs/tags/boost-1.92.0.tar.gz",
                sha256 = "335090455387b06b356bbc317d4949f6e7455165942bd7f50dbfe9cab96d624a",
            },
        },
        windows = {
            ["1.92.0"] = {
                url    = "https://github.com/boostorg/any/archive/refs/tags/boost-1.92.0.tar.gz",
                sha256 = "335090455387b06b356bbc317d4949f6e7455165942bd7f50dbfe9cab96d624a",
            },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        include_dirs = { "*/include" },
        generated_files = {
            ["mcpp_generated/boost_any_anchor.cpp"] = "int mcpp_compat_boost_any_anchor(void) { return 0; }\n",
        },
        sources = { "mcpp_generated/boost_any_anchor.cpp" },
        targets = { ["boost_any"] = { kind = "lib" } },
        deps = {
            ["compat.boost-config"] = "1.92.0",
            ["compat.boost-throw-exception"] = "1.92.0",
            ["compat.boost-type-index"] = "1.92.0",
        },
    },
}
