-- Form B inline descriptor for Boost.Preprocessor 1.92.0 — preprocessor metaprogramming (feeds Utility/TypeTraits).
-- Part of the modular-boost header family; see compat.boost-config for the
-- family wiring and version-train policy. Header closure verified by grepping
-- every `<boost/...>` include across the include tree (both `#include` and
-- `# include` spellings) and cross-checked against this repo's CMakeLists
-- INTERFACE line:
--     preprocessor -> (nothing)
-- Header-only, traditional `#include` consumption; no CN mirror yet; BSL-1.0.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "boost-preprocessor",
    description = "Boost.Preprocessor 1.92.0 — preprocessor metaprogramming (feeds Utility/TypeTraits)",
    licenses    = {"BSL-1.0"},
    repo        = "https://github.com/boostorg/preprocessor",
    type        = "package",

    xpm = {
        linux = {
            ["1.92.0"] = {
                url    = "https://github.com/boostorg/preprocessor/archive/refs/tags/boost-1.92.0.tar.gz",
                sha256 = "7c8f444bb5cf5f37d594ca421938ef0271f7d9866275347f25ceabffb931de7d",
            },
        },
        macosx = {
            ["1.92.0"] = {
                url    = "https://github.com/boostorg/preprocessor/archive/refs/tags/boost-1.92.0.tar.gz",
                sha256 = "7c8f444bb5cf5f37d594ca421938ef0271f7d9866275347f25ceabffb931de7d",
            },
        },
        windows = {
            ["1.92.0"] = {
                url    = "https://github.com/boostorg/preprocessor/archive/refs/tags/boost-1.92.0.tar.gz",
                sha256 = "7c8f444bb5cf5f37d594ca421938ef0271f7d9866275347f25ceabffb931de7d",
            },
        },
    },

    mcpp = {
        language     = "c++20",
        import_std   = false,
        include_dirs = { "*/include" },
        generated_files = {
            ["mcpp_generated/boost_preprocessor_anchor.cpp"] = [==[
int mcpp_compat_boost_preprocessor_anchor(void) { return 0; }
]==],
        },
        sources      = { "mcpp_generated/boost_preprocessor_anchor.cpp" },
        targets      = { ["boost_preprocessor"] = { kind = "lib" } },
        deps         = {
            -- (none: this header set's include closure stays inside boost/preprocessor/)
        },
    },
}
