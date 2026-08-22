-- Form B inline descriptor for Boost.Assert 1.92.0 — BOOST_ASSERT /
-- BOOST_VERIFY / BOOST_CURRENT_LOCATION / boost::source_location.
-- Part of the modular-boost header family; see compat.boost-config for the
-- family wiring and version-train policy (all five packages move together).
--
-- Header references: assert's own tree includes boost/config.hpp and
-- boost/cstdint.hpp, both shipped by compat.boost-config — hence the single
-- dep. Nothing else crosses the family boundary (verified by grep, matching
-- upstream CMakeLists' INTERFACE line: Boost::config only).
--
-- Header-only, traditional `#include` consumption; no CN mirror yet (plain
-- upstream URL, like boost-ext.ut); BSL-1.0.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "boost-assert",
    description = "Boost.Assert 1.92.0 — configurable assert macros with source-location support",
    licenses    = {"BSL-1.0"},
    repo        = "https://github.com/boostorg/assert",
    type        = "package",

    xpm = {
        linux = {
            ["1.92.0"] = {
                url    = "https://github.com/boostorg/assert/archive/refs/tags/boost-1.92.0.tar.gz",
                sha256 = "8d49fc69df12e8fbc0e7fe3c4ede45044747199ccdeaf66c2aebb146becc54aa",
            },
        },
        macosx = {
            ["1.92.0"] = {
                url    = "https://github.com/boostorg/assert/archive/refs/tags/boost-1.92.0.tar.gz",
                sha256 = "8d49fc69df12e8fbc0e7fe3c4ede45044747199ccdeaf66c2aebb146becc54aa",
            },
        },
        windows = {
            ["1.92.0"] = {
                url    = "https://github.com/boostorg/assert/archive/refs/tags/boost-1.92.0.tar.gz",
                sha256 = "8d49fc69df12e8fbc0e7fe3c4ede45044747199ccdeaf66c2aebb146becc54aa",
            },
        },
    },

    mcpp = {
        language     = "c++20",
        import_std   = false,
        include_dirs = { "*/include" },   -- exposes boost/assert.hpp + friends
        generated_files = {
            ["mcpp_generated/boost_assert_anchor.cpp"] = [==[
int mcpp_compat_boost_assert_anchor(void) { return 0; }
]==],
        },
        sources      = { "mcpp_generated/boost_assert_anchor.cpp" },
        targets      = { ["boost_assert"] = { kind = "lib" } },
        deps         = { ["compat.boost-config"] = "1.92.0" },
    },
}
