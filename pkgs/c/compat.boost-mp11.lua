-- Form B inline descriptor for Boost.Mp11 1.92.0 — C++11 metaprogramming list/combinator library.
-- Part of the modular-boost header family; see compat.boost-config for the
-- family wiring and version-train policy. Header closure verified by grepping
-- every `<boost/...>` include across the include tree (both `#include` and
-- `# include` spellings) and cross-checked against this repo's CMakeLists
-- INTERFACE line:
--     mp11 -> (nothing)
-- Header-only, traditional `#include` consumption; no CN mirror yet; BSL-1.0.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "boost-mp11",
    description = "Boost.Mp11 1.92.0 — C++11 metaprogramming list/combinator library",
    licenses    = {"BSL-1.0"},
    repo        = "https://github.com/boostorg/mp11",
    type        = "package",

    xpm = {
        linux = {
            ["1.92.0"] = {
                url    = "https://github.com/boostorg/mp11/archive/refs/tags/boost-1.92.0.tar.gz",
                sha256 = "a5754dc5ff9e7ff34119983889530e3ab8d8fb43ce2b4fea9c18673044df45d9",
            },
        },
        macosx = {
            ["1.92.0"] = {
                url    = "https://github.com/boostorg/mp11/archive/refs/tags/boost-1.92.0.tar.gz",
                sha256 = "a5754dc5ff9e7ff34119983889530e3ab8d8fb43ce2b4fea9c18673044df45d9",
            },
        },
        windows = {
            ["1.92.0"] = {
                url    = "https://github.com/boostorg/mp11/archive/refs/tags/boost-1.92.0.tar.gz",
                sha256 = "a5754dc5ff9e7ff34119983889530e3ab8d8fb43ce2b4fea9c18673044df45d9",
            },
        },
    },

    mcpp = {
        language     = "c++20",
        import_std   = false,
        include_dirs = { "*/include" },
        generated_files = {
            ["mcpp_generated/boost_mp11_anchor.cpp"] = [==[
int mcpp_compat_boost_mp11_anchor(void) { return 0; }
]==],
        },
        sources      = { "mcpp_generated/boost_mp11_anchor.cpp" },
        targets      = { ["boost_mp11"] = { kind = "lib" } },
        deps         = {
            -- (none: this header set's include closure stays inside boost/mp11/)
        },
    },
}
