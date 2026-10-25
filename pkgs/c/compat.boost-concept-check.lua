package = {
    spec        = "1",
    namespace   = "compat",
    name        = "boost-concept-check",
    description = "Boost.ConceptCheck 1.92.0 — compile-time checks for C++ concepts and requirements",
    licenses    = {"BSL-1.0"},
    repo        = "https://github.com/boostorg/concept_check",
    type        = "package",

    extensions = {
        autoupdate = {
            tag = "boost-${version}",
            url = "https://github.com/boostorg/concept_check/archive/refs/tags/${tag}.tar.gz",
        },
    },

    xpm = {
        linux = {
            ["1.92.0"] = {
                url    = "https://github.com/boostorg/concept_check/archive/refs/tags/boost-1.92.0.tar.gz",
                sha256 = "8dbd2385b0045eddb4c0f071f3c9740c1e61fa3c4cb50d29e139b4b05f55b7e8",
            },
        },
        macosx = {
            ["1.92.0"] = {
                url    = "https://github.com/boostorg/concept_check/archive/refs/tags/boost-1.92.0.tar.gz",
                sha256 = "8dbd2385b0045eddb4c0f071f3c9740c1e61fa3c4cb50d29e139b4b05f55b7e8",
            },
        },
        windows = {
            ["1.92.0"] = {
                url    = "https://github.com/boostorg/concept_check/archive/refs/tags/boost-1.92.0.tar.gz",
                sha256 = "8dbd2385b0045eddb4c0f071f3c9740c1e61fa3c4cb50d29e139b4b05f55b7e8",
            },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        include_dirs = { "*/include" },
        generated_files = {
            ["mcpp_generated/boost_concept_check_anchor.cpp"] = "int mcpp_compat_boost_concept_check_anchor(void) { return 0; }\n",
        },
        sources = { "mcpp_generated/boost_concept_check_anchor.cpp" },
        targets = { ["boost_concept_check"] = { kind = "lib" } },
        deps = {
            ["compat.boost-assert"] = "1.92.0",
            ["compat.boost-config"] = "1.92.0",
            ["compat.boost-type-traits"] = "1.92.0",
            ["compat.boost-preprocessor"] = "1.92.0",
        },
    },
}
