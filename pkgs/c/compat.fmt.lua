-- Form B inline descriptor for {fmt} — a modern formatting library for C++.
-- C++-source compat build (same shape as compat.gtest): compile the library's
-- non-header translation units into a lib and expose the `include/` tree via
-- include_dirs, so consumers write `#include <fmt/core.h>` / `<fmt/format.h>`.
--
-- Sources: fmt's compiled implementation is `src/format.cc` (core formatting)
-- and `src/os.cc` (optional OS-specific I/O — fmt::ostream, file descriptors).
-- These two are exactly upstream CMake's `fmt` target sources. NOT globbed:
--   * `src/fmt.cc`   — the C++20 named-module unit (starts with `module;`); it
--                      must be compiled as a module interface, not a plain TU,
--                      so it is deliberately excluded here.
--   * `src/fmt-c.cc` — the optional C API; gated behind the `c-api` feature
--                      below (excluded by default, same pattern as compat.gtest
--                      gating gtest_main behind `main`).
--
-- All `mcpp` paths are GLOBS relative to the verdir; the leading `*/` absorbs
-- the GitHub tarball's `fmt-<tag>/` wrap layer.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "compat.fmt",
    description = "A modern formatting library for C++",
    licenses    = {"MIT"},
    repo        = "https://github.com/fmtlib/fmt",
    type        = "package",

    xpm = {
        linux = {
            ["12.2.0"] = {
                url    = "https://github.com/fmtlib/fmt/archive/refs/tags/12.2.0.tar.gz",
                sha256 = "8b852bb5aa6e7d8564f9e81394055395dd1d1936d38dfd3a17792a02bebd7af0",
            },
        },
        macosx = {
            ["12.2.0"] = {
                url    = "https://github.com/fmtlib/fmt/archive/refs/tags/12.2.0.tar.gz",
                sha256 = "8b852bb5aa6e7d8564f9e81394055395dd1d1936d38dfd3a17792a02bebd7af0",
            },
        },
        windows = {
            ["12.2.0"] = {
                url    = "https://github.com/fmtlib/fmt/archive/refs/tags/12.2.0.tar.gz",
                sha256 = "8b852bb5aa6e7d8564f9e81394055395dd1d1936d38dfd3a17792a02bebd7af0",
            },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        include_dirs = { "*/include" },
        sources      = { "*/src/format.cc", "*/src/os.cc" },
        targets      = { ["fmt"] = { kind = "lib" } },
        -- Optional C API (src/fmt-c.cc, <fmt/fmt-c.h>), source-gated like
        -- compat.gtest's `main` / compat.cjson's `utils`. NOTE: mcpp 0.0.81 does
        -- not yet propagate a feature requested on a DEPENDENCY into its compile
        -- plan, so this object is not built and fmt_vformat is unresolved even
        -- with the feature on — the same gap compat.eigen notes for `eigen_blas`.
        -- Kept form-correct; lights up once mcpp propagates dependency features.
        features     = {
            ["c-api"] = { sources = { "*/src/fmt-c.cc" } },
        },
        deps         = { },
    },
}
