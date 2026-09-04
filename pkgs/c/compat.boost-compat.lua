-- Form B inline descriptor for Boost.Compat 1.92.0 — C++11-17 backports of newer standard facilities (invoke, to_chars).
-- Part of the modular-boost header family; see compat.boost-config for the
-- family wiring and version-train policy. Header closure verified by grepping
-- every `<boost/...>` include across the include tree (both `#include` and
-- `# include` spellings) and cross-checked against this repo's CMakeLists
-- INTERFACE line:
--     compat -> assert, config, throw_exception
-- Header-only, traditional `#include` consumption; no CN mirror yet; BSL-1.0.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "boost-compat",
    description = "Boost.Compat 1.92.0 — C++11-17 backports of newer standard facilities (invoke, to_chars)",
    licenses    = {"BSL-1.0"},
    repo        = "https://github.com/boostorg/compat",
    type        = "package",

    xpm = {
        linux = {
            ["1.92.0"] = {
                url    = "https://github.com/boostorg/compat/archive/refs/tags/boost-1.92.0.tar.gz",
                sha256 = "5c75932af3b259abce882b203e6bd2ce5de7e7630e1fea24494fcb4e7da43c41",
            },
        },
        macosx = {
            ["1.92.0"] = {
                url    = "https://github.com/boostorg/compat/archive/refs/tags/boost-1.92.0.tar.gz",
                sha256 = "5c75932af3b259abce882b203e6bd2ce5de7e7630e1fea24494fcb4e7da43c41",
            },
        },
        windows = {
            ["1.92.0"] = {
                url    = "https://github.com/boostorg/compat/archive/refs/tags/boost-1.92.0.tar.gz",
                sha256 = "5c75932af3b259abce882b203e6bd2ce5de7e7630e1fea24494fcb4e7da43c41",
            },
        },
    },

    mcpp = {
        language     = "c++20",
        import_std   = false,
        include_dirs = { "*/include" },
        generated_files = {
            ["mcpp_generated/boost_compat_anchor.cpp"] = [==[
int mcpp_compat_boost_compat_anchor(void) { return 0; }
]==],
        },
        sources      = { "mcpp_generated/boost_compat_anchor.cpp" },
        targets      = { ["boost_compat"] = { kind = "lib" } },
        deps         = {
            ["compat.boost-assert"] = "1.92.0",
            ["compat.boost-config"] = "1.92.0",
            ["compat.boost-throw-exception"] = "1.92.0",
        },
    },
}
