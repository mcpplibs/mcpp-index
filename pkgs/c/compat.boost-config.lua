-- Form B inline descriptor for Boost.Config 1.92.0 — the root of this index's
-- modular-boost header family. Each boostorg/<lib> repository is packaged from
-- its OWN release-train tag (`boost-1.92.0`) instead of the ~224 MiB monolith,
-- mirroring how vcpkg splits Boost into per-library ports: consumers download
-- exactly the closure they use (Config alone is ~300 KiB of archives).
--
-- Family wiring (verified by grepping every `<boost/...>` include across each
-- package's include tree AND cross-checked against each repo's CMakeLists
-- INTERFACE link line):
--     config           -> (nothing)
--     assert           -> config
--     type-traits      -> config
--     throw-exception  -> assert, config
--     uuid             -> all four above
-- The five shipped header sets are pairwise disjoint, so five `*/include`
-- include roots union into one coherent `boost/` tree with no collisions.
-- Upgrades move the WHOLE train together (every boostorg repo tags the same
-- release); partial trains are untested territory.
--
-- Header-only, traditional `#include` consumption only — no module unit here.
-- Upstream ships none for Config, and this family deliberately stays on the
-- textual path (see compat.jwt-cpp / tests/examples/boost-*).
--
-- No CN mirror yet: plain-string upstream URL, like boost-ext.ut. Consumers in
-- CN fall back to the GLOBAL source until a maintainer backfills gitcode.
--
-- License: Boost Software License 1.0 (BSL-1.0), file LICENSE_1_0.txt.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "boost-config",
    description = "Boost.Config 1.92.0 — platform/compiler/stdlib detection macros; root of the modular-boost header family",
    licenses    = {"BSL-1.0"},
    repo        = "https://github.com/boostorg/config",
    type        = "package",

    xpm = {
        linux = {
            ["1.92.0"] = {
                url    = "https://github.com/boostorg/config/archive/refs/tags/boost-1.92.0.tar.gz",
                sha256 = "b4171037f13373203ba79cbc141d612982052283e696a315185ab5bea46102a0",
            },
        },
        macosx = {
            ["1.92.0"] = {
                url    = "https://github.com/boostorg/config/archive/refs/tags/boost-1.92.0.tar.gz",
                sha256 = "b4171037f13373203ba79cbc141d612982052283e696a315185ab5bea46102a0",
            },
        },
        windows = {
            ["1.92.0"] = {
                url    = "https://github.com/boostorg/config/archive/refs/tags/boost-1.92.0.tar.gz",
                sha256 = "b4171037f13373203ba79cbc141d612982052283e696a315185ab5bea46102a0",
            },
        },
    },

    mcpp = {
        language     = "c++20",
        import_std   = false,
        -- Exposes `boost/` (config.hpp, version.hpp, detail/, no_tr1/, ...) so
        -- consumers write `#include <boost/config.hpp>`. This package also owns
        -- the family's shared oddments that live outside boost/config/: the
        -- historical boost/cstdint.hpp, boost/limits.hpp, boost/static_assert.hpp,
        -- boost/detail/workaround.hpp — and boost/version.hpp, which downstream
        -- members assert against.
        include_dirs = { "*/include" },
        -- Header-only: a trivial anchor TU gives mcpp a buildable lib target.
        generated_files = {
            ["mcpp_generated/boost_config_anchor.cpp"] = [==[
int mcpp_compat_boost_config_anchor(void) { return 0; }
]==],
        },
        sources      = { "mcpp_generated/boost_config_anchor.cpp" },
        targets      = { ["boost_config"] = { kind = "lib" } },
        deps         = { },
    },
}
