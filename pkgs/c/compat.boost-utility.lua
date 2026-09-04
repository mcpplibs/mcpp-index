-- Form B inline descriptor for Boost.Utility 1.92.0 — result_of, compressed_pair, call_traits, in_place factories.
-- Part of the modular-boost header family; see compat.boost-config for the
-- family wiring and version-train policy. Header closure verified by grepping
-- every `<boost/...>` include across the include tree (both `#include` and
-- `# include` spellings) and cross-checked against this repo's CMakeLists
-- INTERFACE line:
--     utility -> assert, config, core, io, preprocessor, throw_exception, type_traits
-- Header-only, traditional `#include` consumption; no CN mirror yet; BSL-1.0.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "boost-utility",
    description = "Boost.Utility 1.92.0 — result_of, compressed_pair, call_traits, in_place factories",
    licenses    = {"BSL-1.0"},
    repo        = "https://github.com/boostorg/utility",
    type        = "package",

    xpm = {
        linux = {
            ["1.92.0"] = {
                url    = "https://github.com/boostorg/utility/archive/refs/tags/boost-1.92.0.tar.gz",
                sha256 = "41ef0d92840b0db9249f20ac17bbe1eca0ec1f35dd5261920a255475820b7c19",
            },
        },
        macosx = {
            ["1.92.0"] = {
                url    = "https://github.com/boostorg/utility/archive/refs/tags/boost-1.92.0.tar.gz",
                sha256 = "41ef0d92840b0db9249f20ac17bbe1eca0ec1f35dd5261920a255475820b7c19",
            },
        },
        windows = {
            ["1.92.0"] = {
                url    = "https://github.com/boostorg/utility/archive/refs/tags/boost-1.92.0.tar.gz",
                sha256 = "41ef0d92840b0db9249f20ac17bbe1eca0ec1f35dd5261920a255475820b7c19",
            },
        },
    },

    mcpp = {
        language     = "c++20",
        import_std   = false,
        include_dirs = { "*/include" },
        generated_files = {
            ["mcpp_generated/boost_utility_anchor.cpp"] = [==[
int mcpp_compat_boost_utility_anchor(void) { return 0; }
]==],
        },
        sources      = { "mcpp_generated/boost_utility_anchor.cpp" },
        targets      = { ["boost_utility"] = { kind = "lib" } },
        deps         = {
            ["compat.boost-assert"] = "1.92.0",
            ["compat.boost-config"] = "1.92.0",
            ["compat.boost-core"] = "1.92.0",
            ["compat.boost-io"] = "1.92.0",
            ["compat.boost-preprocessor"] = "1.92.0",
            ["compat.boost-throw-exception"] = "1.92.0",
            ["compat.boost-type-traits"] = "1.92.0",
        },
    },
}
