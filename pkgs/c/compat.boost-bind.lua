-- Form B inline descriptor for Boost.Bind 1.92.0 — bind.hpp expression binders and mem_fn.
-- Part of the modular-boost header family; see compat.boost-config for the
-- family wiring and version-train policy. Header closure verified by grepping
-- every `<boost/...>` include across the include tree (both `#include` and
-- `# include` spellings) and cross-checked against this repo's CMakeLists
-- INTERFACE line:
--     bind -> config, core
-- Header-only, traditional `#include` consumption; no CN mirror yet; BSL-1.0.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "boost-bind",
    description = "Boost.Bind 1.92.0 — bind.hpp expression binders and mem_fn",
    licenses    = {"BSL-1.0"},
    repo        = "https://github.com/boostorg/bind",
    type        = "package",

    xpm = {
        linux = {
            ["1.92.0"] = {
                url    = "https://github.com/boostorg/bind/archive/refs/tags/boost-1.92.0.tar.gz",
                sha256 = "63b4d0f508cea880638f332f2f2c5f9581c8f3e751dd4a385635386ceb5bd72d",
            },
        },
        macosx = {
            ["1.92.0"] = {
                url    = "https://github.com/boostorg/bind/archive/refs/tags/boost-1.92.0.tar.gz",
                sha256 = "63b4d0f508cea880638f332f2f2c5f9581c8f3e751dd4a385635386ceb5bd72d",
            },
        },
        windows = {
            ["1.92.0"] = {
                url    = "https://github.com/boostorg/bind/archive/refs/tags/boost-1.92.0.tar.gz",
                sha256 = "63b4d0f508cea880638f332f2f2c5f9581c8f3e751dd4a385635386ceb5bd72d",
            },
        },
    },

    mcpp = {
        language     = "c++20",
        import_std   = false,
        include_dirs = { "*/include" },
        generated_files = {
            ["mcpp_generated/boost_bind_anchor.cpp"] = [==[
int mcpp_compat_boost_bind_anchor(void) { return 0; }
]==],
        },
        sources      = { "mcpp_generated/boost_bind_anchor.cpp" },
        targets      = { ["boost_bind"] = { kind = "lib" } },
        deps         = {
            ["compat.boost-config"] = "1.92.0",
            ["compat.boost-core"] = "1.92.0",
        },
    },
}
