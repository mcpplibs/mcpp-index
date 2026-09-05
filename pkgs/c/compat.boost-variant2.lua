-- Form B inline descriptor for Boost.Variant2 1.92.0 — never-empty variant (feeds Boost.System's result).
-- Part of the modular-boost header family; see compat.boost-config for the
-- family wiring and version-train policy. Header closure verified by grepping
-- every `<boost/...>` include across the include tree (both `#include` and
-- `# include` spellings) and cross-checked against this repo's CMakeLists
-- INTERFACE line:
--     variant2 -> assert, config, mp11
-- Header-only, traditional `#include` consumption; no CN mirror yet; BSL-1.0.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "boost-variant2",
    description = "Boost.Variant2 1.92.0 — never-empty variant (feeds Boost.System's result)",
    licenses    = {"BSL-1.0"},
    repo        = "https://github.com/boostorg/variant2",
    type        = "package",

    xpm = {
        linux = {
            ["1.92.0"] = {
                url    = "https://github.com/boostorg/variant2/archive/refs/tags/boost-1.92.0.tar.gz",
                sha256 = "3137ec23fdfa5c7d67e31b5227b8ffd0dd918dec8f2fb9b6cebcb998f65c7180",
            },
        },
        macosx = {
            ["1.92.0"] = {
                url    = "https://github.com/boostorg/variant2/archive/refs/tags/boost-1.92.0.tar.gz",
                sha256 = "3137ec23fdfa5c7d67e31b5227b8ffd0dd918dec8f2fb9b6cebcb998f65c7180",
            },
        },
        windows = {
            ["1.92.0"] = {
                url    = "https://github.com/boostorg/variant2/archive/refs/tags/boost-1.92.0.tar.gz",
                sha256 = "3137ec23fdfa5c7d67e31b5227b8ffd0dd918dec8f2fb9b6cebcb998f65c7180",
            },
        },
    },

    mcpp = {
        language     = "c++20",
        import_std   = false,
        include_dirs = { "*/include" },
        generated_files = {
            ["mcpp_generated/boost_variant2_anchor.cpp"] = [==[
int mcpp_compat_boost_variant2_anchor(void) { return 0; }
]==],
        },
        sources      = { "mcpp_generated/boost_variant2_anchor.cpp" },
        targets      = { ["boost_variant2"] = { kind = "lib" } },
        deps         = {
            ["compat.boost-assert"] = "1.92.0",
            ["compat.boost-config"] = "1.92.0",
            ["compat.boost-mp11"] = "1.92.0",
        },
    },
}
