-- Form B inline descriptor for Boost.System 1.92.0 — error_code/system_error and the boost/cerrno.hpp shim.
-- Part of the modular-boost header family; see compat.boost-config for the
-- family wiring and version-train policy. Header closure verified by grepping
-- every `<boost/...>` include across the include tree (both `#include` and
-- `# include` spellings) and cross-checked against this repo's CMakeLists
-- INTERFACE line:
--     system -> assert, compat, config, mp11, throw_exception, variant2, winapi
-- Header-only, traditional `#include` consumption; no CN mirror yet; BSL-1.0.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "boost-system",
    description = "Boost.System 1.92.0 — error_code/system_error and the boost/cerrno.hpp shim",
    licenses    = {"BSL-1.0"},
    repo        = "https://github.com/boostorg/system",
    type        = "package",

    xpm = {
        linux = {
            ["1.92.0"] = {
                url    = "https://github.com/boostorg/system/archive/refs/tags/boost-1.92.0.tar.gz",
                sha256 = "7eead7ca317453ae546fb6444212c0429e909f102654b69847f8d8904d18735a",
            },
        },
        macosx = {
            ["1.92.0"] = {
                url    = "https://github.com/boostorg/system/archive/refs/tags/boost-1.92.0.tar.gz",
                sha256 = "7eead7ca317453ae546fb6444212c0429e909f102654b69847f8d8904d18735a",
            },
        },
        windows = {
            ["1.92.0"] = {
                url    = "https://github.com/boostorg/system/archive/refs/tags/boost-1.92.0.tar.gz",
                sha256 = "7eead7ca317453ae546fb6444212c0429e909f102654b69847f8d8904d18735a",
            },
        },
    },

    mcpp = {
        language     = "c++20",
        import_std   = false,
        include_dirs = { "*/include" },
        generated_files = {
            ["mcpp_generated/boost_system_anchor.cpp"] = [==[
int mcpp_compat_boost_system_anchor(void) { return 0; }
]==],
        },
        sources      = { "mcpp_generated/boost_system_anchor.cpp" },
        targets      = { ["boost_system"] = { kind = "lib" } },
        deps         = {
            ["compat.boost-assert"] = "1.92.0",
            ["compat.boost-compat"] = "1.92.0",
            ["compat.boost-config"] = "1.92.0",
            ["compat.boost-mp11"] = "1.92.0",
            ["compat.boost-throw-exception"] = "1.92.0",
            ["compat.boost-variant2"] = "1.92.0",
            ["compat.boost-winapi"] = "1.92.0",
        },
    },
}
