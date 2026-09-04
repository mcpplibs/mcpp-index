-- Form B inline descriptor for Boost.StaticString 1.92.0 — fixed-capacity string behind beast::static_string.
-- Part of the modular-boost header family; see compat.boost-config for the
-- family wiring and version-train policy. Header closure verified by grepping
-- every `<boost/...>` include across the include tree (both `#include` and
-- `# include` spellings) and cross-checked against this repo's CMakeLists
-- INTERFACE line:
--     static_string -> assert, config, container_hash, core, throw_exception, utility
-- Header-only, traditional `#include` consumption; no CN mirror yet; BSL-1.0.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "boost-static-string",
    description = "Boost.StaticString 1.92.0 — fixed-capacity string behind beast::static_string",
    licenses    = {"BSL-1.0"},
    repo        = "https://github.com/boostorg/static_string",
    type        = "package",

    xpm = {
        linux = {
            ["1.92.0"] = {
                url    = "https://github.com/boostorg/static_string/archive/refs/tags/boost-1.92.0.tar.gz",
                sha256 = "7a02f012eeb384d804605b76949e4f16e925e50731ba2d4b3a0074db1b959a4f",
            },
        },
        macosx = {
            ["1.92.0"] = {
                url    = "https://github.com/boostorg/static_string/archive/refs/tags/boost-1.92.0.tar.gz",
                sha256 = "7a02f012eeb384d804605b76949e4f16e925e50731ba2d4b3a0074db1b959a4f",
            },
        },
        windows = {
            ["1.92.0"] = {
                url    = "https://github.com/boostorg/static_string/archive/refs/tags/boost-1.92.0.tar.gz",
                sha256 = "7a02f012eeb384d804605b76949e4f16e925e50731ba2d4b3a0074db1b959a4f",
            },
        },
    },

    mcpp = {
        language     = "c++20",
        import_std   = false,
        include_dirs = { "*/include" },
        generated_files = {
            ["mcpp_generated/boost_static_string_anchor.cpp"] = [==[
int mcpp_compat_boost_static_string_anchor(void) { return 0; }
]==],
        },
        sources      = { "mcpp_generated/boost_static_string_anchor.cpp" },
        targets      = { ["boost_static_string"] = { kind = "lib" } },
        deps         = {
            ["compat.boost-assert"] = "1.92.0",
            ["compat.boost-config"] = "1.92.0",
            ["compat.boost-container-hash"] = "1.92.0",
            ["compat.boost-core"] = "1.92.0",
            ["compat.boost-throw-exception"] = "1.92.0",
            ["compat.boost-utility"] = "1.92.0",
        },
    },
}
