-- Form B inline descriptor for Catch2 v3 — a modern C++ test framework.
-- Built as a static library from the individual source files under
-- src/catch2/ (NOT the amalgamated distribution). Consumers include
-- <catch2/catch_all.hpp> (or more specific headers) and provide their
-- own main() using Catch::Session, or request the `main` feature for a
-- ready-made default entry point.
--
-- Features (sources-only gate):
--   `main` — compiles catch_main.cpp (upstream's default main via
--   Catch::Session). Excluded from the default source set via `!`
--   negation; only compiled when features = ["main"] is requested
--   (same pattern as compat.gtest's `main` feature).
--
-- All `mcpp` paths are GLOBS relative to the verdir; the leading `*`
-- absorbs the GitHub tarball's `Catch2-<tag>/` wrap layer.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "catch2",
    description = "A modern, C++-native test framework for unit-tests, TDD and BDD — v3 (C++14+)",
    licenses    = {"BSL-1.0"},
    repo        = "https://github.com/catchorg/Catch2",
    type        = "package",

    xpm = {
        linux = {
            ["3.15.2"] = {
                url    = "https://github.com/catchorg/Catch2/archive/refs/tags/v3.15.2.tar.gz",
                sha256 = "acfae120892c2b67a74142d36d060c0caa96f1c3aaa8aabd96e19961163d0420",
            },
        },
        macosx = {
            ["3.15.2"] = {
                url    = "https://github.com/catchorg/Catch2/archive/refs/tags/v3.15.2.tar.gz",
                sha256 = "acfae120892c2b67a74142d36d060c0caa96f1c3aaa8aabd96e19961163d0420",
            },
        },
        windows = {
            ["3.15.2"] = {
                url    = "https://github.com/catchorg/Catch2/archive/refs/tags/v3.15.2.tar.gz",
                sha256 = "acfae120892c2b67a74142d36d060c0caa96f1c3aaa8aabd96e19961163d0420",
            },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        -- expose src/ so that #include <catch2/…> resolves to
        -- Catch2-<tag>/src/catch2/…
        -- mcpp_generated/ provides catch2/catch_user_config.hpp (normally
        -- CMake-generated; we materialise a reasonable default here).
        include_dirs = { "*/src", "mcpp_generated" },
        -- catch_main.cpp provides a default main(). Excluded via `!`
        -- negation from the default source set; only compiled when
        -- features = ["main"] is requested (same pattern as compat.gtest).
        generated_files = {
            ["mcpp_generated/catch2/catch_user_config.hpp"] = [==[
#ifndef CATCH_USER_CONFIG_HPP_INCLUDED
#define CATCH_USER_CONFIG_HPP_INCLUDED

#ifndef CATCH_CONFIG_DEFAULT_REPORTER
#define CATCH_CONFIG_DEFAULT_REPORTER "console"
#endif
#ifndef CATCH_CONFIG_CONSOLE_WIDTH
#define CATCH_CONFIG_CONSOLE_WIDTH 80
#endif

#endif
]==],
        },
        sources      = {
            "*/src/catch2/**/*.cpp",
            "!*/src/catch2/internal/catch_main.cpp",
        },
        targets      = { ["catch2"] = { kind = "lib" } },
        features     = {
            ["main"] = { sources = { "*/src/catch2/internal/catch_main.cpp" } },
        },
        deps         = { },
    },
}
