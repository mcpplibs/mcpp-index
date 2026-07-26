-- Form B inline descriptor for Catch2 v2 — a modern C++ test framework.
-- v2 is HEADER-ONLY: the amalgamated single header (catch.hpp) contains
-- the full implementation. Define `CATCH_CONFIG_MAIN` before including it
-- in exactly one TU to get a ready-made main(), or define
-- `CATCH_CONFIG_RUNNER` to write your own.
--
-- This descriptor exposes the header via include_dirs and carries a tiny
-- anchor TU so mcpp always has a buildable lib target (same shape as
-- compat.eigen / compat.opengl / compat.khrplatform).
--
-- Features (sources-only gate):
--   `main` — compiles a generated TU that defines CATCH_CONFIG_MAIN and
--   includes <catch2/catch.hpp>, providing a default main(). Excluded by
--   default; request features = ["main"] for a no-config entry point.
--
-- All `mcpp` paths are GLOBS relative to the verdir; the leading `*`
-- absorbs the GitHub tarball's `Catch2-<tag>/` wrap layer.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "catch2-v2",
    description = "A modern, C++-native test framework for unit-tests, TDD and BDD — v2 (C++11, header-only)",
    licenses    = {"BSL-1.0"},
    repo        = "https://github.com/catchorg/Catch2",
    type        = "package",

    xpm = {
        linux = {
            ["2.13.10"] = {
                url    = "https://github.com/catchorg/Catch2/archive/refs/tags/v2.13.10.tar.gz",
                sha256 = "d54a712b7b1d7708bc7a819a8e6e47b2fde9536f487b89ccbca295072a7d9943",
            },
        },
        macosx = {
            ["2.13.10"] = {
                url    = "https://github.com/catchorg/Catch2/archive/refs/tags/v2.13.10.tar.gz",
                sha256 = "d54a712b7b1d7708bc7a819a8e6e47b2fde9536f487b89ccbca295072a7d9943",
            },
        },
        windows = {
            ["2.13.10"] = {
                url    = "https://github.com/catchorg/Catch2/archive/refs/tags/v2.13.10.tar.gz",
                sha256 = "d54a712b7b1d7708bc7a819a8e6e47b2fde9536f487b89ccbca295072a7d9943",
            },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        c_standard   = "c11",
        include_dirs = { "*/single_include" },
        generated_files = {
            ["mcpp_generated/catch2_v2_anchor.c"] = [==[
int mcpp_compat_catch2_v2_anchor(void) { return 0; }
]==],
            ["mcpp_generated/catch2_v2_main.cpp"] = [==[
#define CATCH_CONFIG_MAIN
#include <catch2/catch.hpp>
]==],
        },
        sources      = { "mcpp_generated/catch2_v2_anchor.c" },
        targets      = { ["catch2-v2"] = { kind = "lib" } },
        features     = {
            ["main"] = { sources = { "mcpp_generated/catch2_v2_main.cpp" } },
        },
        deps         = { },
    },
}
