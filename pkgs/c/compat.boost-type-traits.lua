-- Form B inline descriptor for Boost.TypeTraits 1.92.0 — the is_same /
-- add_pointer / remove_cv / integral_constant family (the C++03-era trait
-- toolkit; modern code usually reaches for std:: traits, but Boost headers
-- still lean on these).
-- Part of the modular-boost header family; see compat.boost-config for the
-- family wiring and version-train policy.
--
-- Header references: type_traits includes boost/config/, boost/detail/
-- workarounds, boost/static_assert.hpp and boost/version.hpp — all shipped by
-- compat.boost-config. Matches upstream CMakeLists' INTERFACE line:
-- Boost::config + Boost::type_traits's own tree.
--
-- Header-only, traditional `#include` consumption; no CN mirror yet; BSL-1.0.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "boost-type-traits",
    description = "Boost.TypeTraits 1.92.0 — compile-time type introspection traits",
    licenses    = {"BSL-1.0"},
    repo        = "https://github.com/boostorg/type_traits",
    type        = "package",

    xpm = {
        linux = {
            ["1.92.0"] = {
                url    = "https://github.com/boostorg/type_traits/archive/refs/tags/boost-1.92.0.tar.gz",
                sha256 = "ee6c4d3d993f9138d9a77c57c3d91111aafed79add4f09f4e0a7effcfcdc0cae",
            },
        },
        macosx = {
            ["1.92.0"] = {
                url    = "https://github.com/boostorg/type_traits/archive/refs/tags/boost-1.92.0.tar.gz",
                sha256 = "ee6c4d3d993f9138d9a77c57c3d91111aafed79add4f09f4e0a7effcfcdc0cae",
            },
        },
        windows = {
            ["1.92.0"] = {
                url    = "https://github.com/boostorg/type_traits/archive/refs/tags/boost-1.92.0.tar.gz",
                sha256 = "ee6c4d3d993f9138d9a77c57c3d91111aafed79add4f09f4e0a7effcfcdc0cae",
            },
        },
    },

    mcpp = {
        language     = "c++20",
        import_std   = false,
        include_dirs = { "*/include" },   -- exposes boost/type_traits/*
        generated_files = {
            ["mcpp_generated/boost_type_traits_anchor.cpp"] = [==[
int mcpp_compat_boost_type_traits_anchor(void) { return 0; }
]==],
        },
        sources      = { "mcpp_generated/boost_type_traits_anchor.cpp" },
        targets      = { ["boost_type_traits"] = { kind = "lib" } },
        deps         = { ["compat.boost-config"] = "1.92.0" },
    },
}
