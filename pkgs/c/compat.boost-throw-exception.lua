-- Form B inline descriptor for Boost.ThrowException 1.92.0 —
-- BOOST_THROW_EXCEPTION and boost::throw_exception, the family's uniform
-- "raise a std::exception-derived error" path.
-- Part of the modular-boost header family; see compat.boost-config for the
-- family wiring and version-train policy.
--
-- Header references: throw_exception includes boost/assert/ (compat.boost-assert)
-- and boost/config/ (compat.boost-config); boost/exception/exception.hpp is its
-- own. Matches upstream CMakeLists' INTERFACE line: Boost::assert + Boost::config.
--
-- Header-only, traditional `#include` consumption; no CN mirror yet; BSL-1.0.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "boost-throw-exception",
    description = "Boost.ThrowException 1.92.0 — common exception-raising infrastructure for Boost libraries",
    licenses    = {"BSL-1.0"},
    repo        = "https://github.com/boostorg/throw_exception",
    type        = "package",

    xpm = {
        linux = {
            ["1.92.0"] = {
                url    = "https://github.com/boostorg/throw_exception/archive/refs/tags/boost-1.92.0.tar.gz",
                sha256 = "1ddbb967a43504e28bbe2a35a010df9f7ff5d1a49d3678c9fdfc035fd32ce005",
            },
        },
        macosx = {
            ["1.92.0"] = {
                url    = "https://github.com/boostorg/throw_exception/archive/refs/tags/boost-1.92.0.tar.gz",
                sha256 = "1ddbb967a43504e28bbe2a35a010df9f7ff5d1a49d3678c9fdfc035fd32ce005",
            },
        },
        windows = {
            ["1.92.0"] = {
                url    = "https://github.com/boostorg/throw_exception/archive/refs/tags/boost-1.92.0.tar.gz",
                sha256 = "1ddbb967a43504e28bbe2a35a010df9f7ff5d1a49d3678c9fdfc035fd32ce005",
            },
        },
    },

    mcpp = {
        language     = "c++20",
        import_std   = false,
        include_dirs = { "*/include" },   -- exposes boost/throw_exception.hpp
        generated_files = {
            ["mcpp_generated/boost_throw_exception_anchor.cpp"] = [==[
int mcpp_compat_boost_throw_exception_anchor(void) { return 0; }
]==],
        },
        sources      = { "mcpp_generated/boost_throw_exception_anchor.cpp" },
        targets      = { ["boost_throw_exception"] = { kind = "lib" } },
        deps         = {
            ["compat.boost-assert"] = "1.92.0",
            ["compat.boost-config"] = "1.92.0",
        },
    },
}
