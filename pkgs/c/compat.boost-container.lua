-- Form B inline descriptor for Boost.Container 1.92.0 — STL-compatible containers; Beast consumes allocator_traits.
-- Part of the modular-boost header family; see compat.boost-config for the
-- family wiring and version-train policy. Header closure verified by grepping
-- every `<boost/...>` include across the include tree (both `#include` and
-- `# include` spellings) and cross-checked against this repo's CMakeLists
-- INTERFACE line:
--     container -> assert, config, intrusive, move
-- Header-only, traditional `#include` consumption; no CN mirror yet; BSL-1.0.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "boost-container",
    description = "Boost.Container 1.92.0 — STL-compatible containers; Beast consumes allocator_traits",
    licenses    = {"BSL-1.0"},
    repo        = "https://github.com/boostorg/container",
    type        = "package",

    xpm = {
        linux = {
            ["1.92.0"] = {
                url    = "https://github.com/boostorg/container/archive/refs/tags/boost-1.92.0.tar.gz",
                sha256 = "aa5823d6b5eaac5a56af6b4ea90e9560f9659d3237e62db7e54f434a5611ae7f",
            },
        },
        macosx = {
            ["1.92.0"] = {
                url    = "https://github.com/boostorg/container/archive/refs/tags/boost-1.92.0.tar.gz",
                sha256 = "aa5823d6b5eaac5a56af6b4ea90e9560f9659d3237e62db7e54f434a5611ae7f",
            },
        },
        windows = {
            ["1.92.0"] = {
                url    = "https://github.com/boostorg/container/archive/refs/tags/boost-1.92.0.tar.gz",
                sha256 = "aa5823d6b5eaac5a56af6b4ea90e9560f9659d3237e62db7e54f434a5611ae7f",
            },
        },
    },

    mcpp = {
        language     = "c++20",
        import_std   = false,
        include_dirs = { "*/include" },
        generated_files = {
            ["mcpp_generated/boost_container_anchor.cpp"] = [==[
int mcpp_compat_boost_container_anchor(void) { return 0; }
]==],
        },
        sources      = { "mcpp_generated/boost_container_anchor.cpp" },
        targets      = { ["boost_container"] = { kind = "lib" } },
        deps         = {
            ["compat.boost-assert"] = "1.92.0",
            ["compat.boost-config"] = "1.92.0",
            ["compat.boost-intrusive"] = "1.92.0",
            ["compat.boost-move"] = "1.92.0",
        },
    },
}
