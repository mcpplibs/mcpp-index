-- Form B inline descriptor for Boost.Align 1.92.0 — aligned allocation functions, allocators and traits.
-- Part of the modular-boost header family; see compat.boost-config for the
-- family wiring and version-train policy. Header closure verified by grepping
-- every `<boost/...>` include across the include tree (both `#include` and
-- `# include` spellings) and cross-checked against this repo's CMakeLists
-- INTERFACE line:
--     align -> assert, config, core
-- Header-only, traditional `#include` consumption; no CN mirror yet; BSL-1.0.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "boost-align",
    description = "Boost.Align 1.92.0 — aligned allocation functions, allocators and traits",
    licenses    = {"BSL-1.0"},
    repo        = "https://github.com/boostorg/align",
    type        = "package",

    xpm = {
        linux = {
            ["1.92.0"] = {
                url    = "https://github.com/boostorg/align/archive/refs/tags/boost-1.92.0.tar.gz",
                sha256 = "e9d7a0012be7849d36e366e565e5d05028069a1be3ea67bf31ed129c8344864c",
            },
        },
        macosx = {
            ["1.92.0"] = {
                url    = "https://github.com/boostorg/align/archive/refs/tags/boost-1.92.0.tar.gz",
                sha256 = "e9d7a0012be7849d36e366e565e5d05028069a1be3ea67bf31ed129c8344864c",
            },
        },
        windows = {
            ["1.92.0"] = {
                url    = "https://github.com/boostorg/align/archive/refs/tags/boost-1.92.0.tar.gz",
                sha256 = "e9d7a0012be7849d36e366e565e5d05028069a1be3ea67bf31ed129c8344864c",
            },
        },
    },

    mcpp = {
        language     = "c++20",
        import_std   = false,
        include_dirs = { "*/include" },
        generated_files = {
            ["mcpp_generated/boost_align_anchor.cpp"] = [==[
int mcpp_compat_boost_align_anchor(void) { return 0; }
]==],
        },
        sources      = { "mcpp_generated/boost_align_anchor.cpp" },
        targets      = { ["boost_align"] = { kind = "lib" } },
        deps         = {
            ["compat.boost-assert"] = "1.92.0",
            ["compat.boost-config"] = "1.92.0",
            ["compat.boost-core"] = "1.92.0",
        },
    },
}
