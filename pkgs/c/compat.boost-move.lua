-- Form B inline descriptor for Boost.Move 1.92.0 — move-emulation traits and move-aware utilities.
-- Part of the modular-boost header family; see compat.boost-config for the
-- family wiring and version-train policy. Header closure verified by grepping
-- every `<boost/...>` include across the include tree (both `#include` and
-- `# include` spellings) and cross-checked against this repo's CMakeLists
-- INTERFACE line:
--     move -> config
-- Header-only, traditional `#include` consumption; no CN mirror yet; BSL-1.0.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "boost-move",
    description = "Boost.Move 1.92.0 — move-emulation traits and move-aware utilities",
    licenses    = {"BSL-1.0"},
    repo        = "https://github.com/boostorg/move",
    type        = "package",

    xpm = {
        linux = {
            ["1.92.0"] = {
                url    = "https://github.com/boostorg/move/archive/refs/tags/boost-1.92.0.tar.gz",
                sha256 = "7e50df59f1e5ba7614a762255a58142a7c2eccb8fa23c59a8a27789f25cad762",
            },
        },
        macosx = {
            ["1.92.0"] = {
                url    = "https://github.com/boostorg/move/archive/refs/tags/boost-1.92.0.tar.gz",
                sha256 = "7e50df59f1e5ba7614a762255a58142a7c2eccb8fa23c59a8a27789f25cad762",
            },
        },
        windows = {
            ["1.92.0"] = {
                url    = "https://github.com/boostorg/move/archive/refs/tags/boost-1.92.0.tar.gz",
                sha256 = "7e50df59f1e5ba7614a762255a58142a7c2eccb8fa23c59a8a27789f25cad762",
            },
        },
    },

    mcpp = {
        language     = "c++20",
        import_std   = false,
        include_dirs = { "*/include" },
        generated_files = {
            ["mcpp_generated/boost_move_anchor.cpp"] = [==[
int mcpp_compat_boost_move_anchor(void) { return 0; }
]==],
        },
        sources      = { "mcpp_generated/boost_move_anchor.cpp" },
        targets      = { ["boost_move"] = { kind = "lib" } },
        deps         = {
            ["compat.boost-config"] = "1.92.0",
        },
    },
}
