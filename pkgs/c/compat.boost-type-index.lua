-- Form B inline descriptor for Boost.TypeIndex 1.92.0 — runtime type information with RTTI-free fallback.
-- Part of the modular-boost header family; see compat.boost-config for the
-- family wiring and version-train policy. Header closure verified by grepping
-- every `<boost/...>` include across the include tree (both `#include` and
-- `# include` spellings) and cross-checked against this repo's CMakeLists
-- INTERFACE line:
--     type_index -> config, container_hash, throw_exception
-- Header-only, traditional `#include` consumption; no CN mirror yet; BSL-1.0.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "boost-type-index",
    description = "Boost.TypeIndex 1.92.0 — runtime type information with RTTI-free fallback",
    licenses    = {"BSL-1.0"},
    repo        = "https://github.com/boostorg/type_index",
    type        = "package",

    xpm = {
        linux = {
            ["1.92.0"] = {
                url    = "https://github.com/boostorg/type_index/archive/refs/tags/boost-1.92.0.tar.gz",
                sha256 = "5012b75aace9288c9c9d0d58e830fbbaac0331ac64638edced1f8c673e87f256",
            },
        },
        macosx = {
            ["1.92.0"] = {
                url    = "https://github.com/boostorg/type_index/archive/refs/tags/boost-1.92.0.tar.gz",
                sha256 = "5012b75aace9288c9c9d0d58e830fbbaac0331ac64638edced1f8c673e87f256",
            },
        },
        windows = {
            ["1.92.0"] = {
                url    = "https://github.com/boostorg/type_index/archive/refs/tags/boost-1.92.0.tar.gz",
                sha256 = "5012b75aace9288c9c9d0d58e830fbbaac0331ac64638edced1f8c673e87f256",
            },
        },
    },

    mcpp = {
        language     = "c++20",
        import_std   = false,
        include_dirs = { "*/include" },
        generated_files = {
            ["mcpp_generated/boost_type_index_anchor.cpp"] = [==[
int mcpp_compat_boost_type_index_anchor(void) { return 0; }
]==],
        },
        sources      = { "mcpp_generated/boost_type_index_anchor.cpp" },
        targets      = { ["boost_type_index"] = { kind = "lib" } },
        deps         = {
            ["compat.boost-config"] = "1.92.0",
            ["compat.boost-container-hash"] = "1.92.0",
            ["compat.boost-throw-exception"] = "1.92.0",
        },
    },
}
