-- Form B inline descriptor for Boost.WinAPI 1.92.0 — WinAPI wrappers; owns boost/detail/winapi/* shims too.
-- Part of the modular-boost header family; see compat.boost-config for the
-- family wiring and version-train policy. Header closure verified by grepping
-- every `<boost/...>` include across the include tree (both `#include` and
-- `# include` spellings) and cross-checked against this repo's CMakeLists
-- INTERFACE line:
--     winapi -> config, predef
-- Header-only, traditional `#include` consumption; no CN mirror yet; BSL-1.0.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "boost-winapi",
    description = "Boost.WinAPI 1.92.0 — WinAPI wrappers; owns boost/detail/winapi/* shims too",
    licenses    = {"BSL-1.0"},
    repo        = "https://github.com/boostorg/winapi",
    type        = "package",

    xpm = {
        linux = {
            ["1.92.0"] = {
                url    = "https://github.com/boostorg/winapi/archive/refs/tags/boost-1.92.0.tar.gz",
                sha256 = "09993abc4ba7b8238e9068983cda9db12b0e3ee39c8aed8e21162e98d0a3ad4e",
            },
        },
        macosx = {
            ["1.92.0"] = {
                url    = "https://github.com/boostorg/winapi/archive/refs/tags/boost-1.92.0.tar.gz",
                sha256 = "09993abc4ba7b8238e9068983cda9db12b0e3ee39c8aed8e21162e98d0a3ad4e",
            },
        },
        windows = {
            ["1.92.0"] = {
                url    = "https://github.com/boostorg/winapi/archive/refs/tags/boost-1.92.0.tar.gz",
                sha256 = "09993abc4ba7b8238e9068983cda9db12b0e3ee39c8aed8e21162e98d0a3ad4e",
            },
        },
    },

    mcpp = {
        language     = "c++20",
        import_std   = false,
        include_dirs = { "*/include" },
        generated_files = {
            ["mcpp_generated/boost_winapi_anchor.cpp"] = [==[
int mcpp_compat_boost_winapi_anchor(void) { return 0; }
]==],
        },
        sources      = { "mcpp_generated/boost_winapi_anchor.cpp" },
        targets      = { ["boost_winapi"] = { kind = "lib" } },
        deps         = {
            ["compat.boost-config"] = "1.92.0",
            ["compat.boost-predef"] = "1.92.0",
        },
    },
}
