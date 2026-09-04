-- Form B inline descriptor for Boost.Core 1.92.0 — core utilities: addressof, empty_value, ref, type.hpp shims.
-- Part of the modular-boost header family; see compat.boost-config for the
-- family wiring and version-train policy. Header closure verified by grepping
-- every `<boost/...>` include across the include tree (both `#include` and
-- `# include` spellings) and cross-checked against this repo's CMakeLists
-- INTERFACE line:
--     core -> assert, config, throw_exception
-- Header-only, traditional `#include` consumption; no CN mirror yet; BSL-1.0.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "boost-core",
    description = "Boost.Core 1.92.0 — core utilities: addressof, empty_value, ref, type.hpp shims",
    licenses    = {"BSL-1.0"},
    repo        = "https://github.com/boostorg/core",
    type        = "package",

    xpm = {
        linux = {
            ["1.92.0"] = {
                url    = "https://github.com/boostorg/core/archive/refs/tags/boost-1.92.0.tar.gz",
                sha256 = "aa4eb2ccbe5577ded70f25b8f0d852a5246591f90cc34916160739e3d0dbfea6",
            },
        },
        macosx = {
            ["1.92.0"] = {
                url    = "https://github.com/boostorg/core/archive/refs/tags/boost-1.92.0.tar.gz",
                sha256 = "aa4eb2ccbe5577ded70f25b8f0d852a5246591f90cc34916160739e3d0dbfea6",
            },
        },
        windows = {
            ["1.92.0"] = {
                url    = "https://github.com/boostorg/core/archive/refs/tags/boost-1.92.0.tar.gz",
                sha256 = "aa4eb2ccbe5577ded70f25b8f0d852a5246591f90cc34916160739e3d0dbfea6",
            },
        },
    },

    mcpp = {
        language     = "c++20",
        import_std   = false,
        include_dirs = { "*/include" },
        generated_files = {
            ["mcpp_generated/boost_core_anchor.cpp"] = [==[
int mcpp_compat_boost_core_anchor(void) { return 0; }
]==],
        },
        sources      = { "mcpp_generated/boost_core_anchor.cpp" },
        targets      = { ["boost_core"] = { kind = "lib" } },
        deps         = {
            ["compat.boost-assert"] = "1.92.0",
            ["compat.boost-config"] = "1.92.0",
            ["compat.boost-throw-exception"] = "1.92.0",
        },
    },
}
