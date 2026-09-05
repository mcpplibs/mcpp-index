-- Form B inline descriptor for Boost.Logic 1.92.0 — tribool three-state boolean (Beast detect_ssl).
-- Part of the modular-boost header family; see compat.boost-config for the
-- family wiring and version-train policy. Header closure verified by grepping
-- every `<boost/...>` include across the include tree (both `#include` and
-- `# include` spellings) and cross-checked against this repo's CMakeLists
-- INTERFACE line:
--     logic -> config, core
-- Header-only, traditional `#include` consumption; no CN mirror yet; BSL-1.0.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "boost-logic",
    description = "Boost.Logic 1.92.0 — tribool three-state boolean (Beast detect_ssl)",
    licenses    = {"BSL-1.0"},
    repo        = "https://github.com/boostorg/logic",
    type        = "package",

    xpm = {
        linux = {
            ["1.92.0"] = {
                url    = "https://github.com/boostorg/logic/archive/refs/tags/boost-1.92.0.tar.gz",
                sha256 = "c87ccdd307318d2d9dd80e462f3fe72ea635b8cf6a240956229ecceaa3de9eec",
            },
        },
        macosx = {
            ["1.92.0"] = {
                url    = "https://github.com/boostorg/logic/archive/refs/tags/boost-1.92.0.tar.gz",
                sha256 = "c87ccdd307318d2d9dd80e462f3fe72ea635b8cf6a240956229ecceaa3de9eec",
            },
        },
        windows = {
            ["1.92.0"] = {
                url    = "https://github.com/boostorg/logic/archive/refs/tags/boost-1.92.0.tar.gz",
                sha256 = "c87ccdd307318d2d9dd80e462f3fe72ea635b8cf6a240956229ecceaa3de9eec",
            },
        },
    },

    mcpp = {
        language     = "c++20",
        import_std   = false,
        include_dirs = { "*/include" },
        generated_files = {
            ["mcpp_generated/boost_logic_anchor.cpp"] = [==[
int mcpp_compat_boost_logic_anchor(void) { return 0; }
]==],
        },
        sources      = { "mcpp_generated/boost_logic_anchor.cpp" },
        targets      = { ["boost_logic"] = { kind = "lib" } },
        deps         = {
            ["compat.boost-config"] = "1.92.0",
            ["compat.boost-core"] = "1.92.0",
        },
    },
}
