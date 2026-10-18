-- Form B inline descriptor for the Embedded Template Library (ETL), a
-- header-only collection of fixed-capacity containers and utilities for
-- resource-constrained systems.
--
-- The upstream CMake target is INTERFACE-only and exposes `include/`, so a
-- small C anchor gives mcpp a buildable library target while consumers use
-- headers such as `<etl/vector.h>`.
--
-- ETL supports older language modes, but this package is built by mcpp, whose
-- supported C++ standard starts at C++20. The package therefore uses C++23
-- for its anchor and remains compatible with C++20 consumers.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "etl",
    description = "Embedded Template Library — fixed-capacity containers and utilities (header-only)",
    licenses    = {"MIT"},
    repo        = "https://github.com/ETLCPP/etl",
    type        = "package",

    xpm = {
        linux = {
            ["20.49.0"] = {
                url    = "https://github.com/ETLCPP/etl/archive/refs/tags/20.49.0.tar.gz",
                sha256 = "b3e7a5544795ec8f4a1b2ab46f6e88fdb78be5a07738f008ce11dd37ed14b6e4",
            },
        },
        macosx = {
            ["20.49.0"] = {
                url    = "https://github.com/ETLCPP/etl/archive/refs/tags/20.49.0.tar.gz",
                sha256 = "b3e7a5544795ec8f4a1b2ab46f6e88fdb78be5a07738f008ce11dd37ed14b6e4",
            },
        },
        windows = {
            ["20.49.0"] = {
                url    = "https://github.com/ETLCPP/etl/archive/refs/tags/20.49.0.tar.gz",
                sha256 = "b3e7a5544795ec8f4a1b2ab46f6e88fdb78be5a07738f008ce11dd37ed14b6e4",
            },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        c_standard   = "c11",
        include_dirs = { "*/include" },
        generated_files = {
            ["mcpp_generated/etl_anchor.c"] = [==[
int mcpp_compat_etl_headers_anchor(void) { return 0; }
]==],
        },
        sources = { "mcpp_generated/etl_anchor.c" },
        targets = { ["etl"] = { kind = "lib" } },
        deps    = {},
    },
}
