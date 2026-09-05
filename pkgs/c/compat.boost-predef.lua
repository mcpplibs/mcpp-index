-- Form B inline descriptor for Boost.Predef 1.92.0 — compiler/architecture/OS detection macros (feeds WinAPI).
-- Part of the modular-boost header family; see compat.boost-config for the
-- family wiring and version-train policy. Header closure verified by grepping
-- every `<boost/...>` include across the include tree (both `#include` and
-- `# include` spellings) and cross-checked against this repo's CMakeLists
-- INTERFACE line:
--     predef -> (nothing)
-- Header-only, traditional `#include` consumption; no CN mirror yet; BSL-1.0.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "boost-predef",
    description = "Boost.Predef 1.92.0 — compiler/architecture/OS detection macros (feeds WinAPI)",
    licenses    = {"BSL-1.0"},
    repo        = "https://github.com/boostorg/predef",
    type        = "package",

    xpm = {
        linux = {
            ["1.92.0"] = {
                url    = "https://github.com/boostorg/predef/archive/refs/tags/boost-1.92.0.tar.gz",
                sha256 = "4c870bcf7f547f3e3d1db26700b078a33f87c4c8232cd1c8d89ec82be6b54130",
            },
        },
        macosx = {
            ["1.92.0"] = {
                url    = "https://github.com/boostorg/predef/archive/refs/tags/boost-1.92.0.tar.gz",
                sha256 = "4c870bcf7f547f3e3d1db26700b078a33f87c4c8232cd1c8d89ec82be6b54130",
            },
        },
        windows = {
            ["1.92.0"] = {
                url    = "https://github.com/boostorg/predef/archive/refs/tags/boost-1.92.0.tar.gz",
                sha256 = "4c870bcf7f547f3e3d1db26700b078a33f87c4c8232cd1c8d89ec82be6b54130",
            },
        },
    },

    mcpp = {
        language     = "c++20",
        import_std   = false,
        include_dirs = { "*/include" },
        generated_files = {
            ["mcpp_generated/boost_predef_anchor.cpp"] = [==[
int mcpp_compat_boost_predef_anchor(void) { return 0; }
]==],
        },
        sources      = { "mcpp_generated/boost_predef_anchor.cpp" },
        targets      = { ["boost_predef"] = { kind = "lib" } },
        deps         = {
            -- (none: this header set's include closure stays inside boost/predef/)
        },
    },
}
