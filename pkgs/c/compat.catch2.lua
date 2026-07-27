-- Form B inline descriptor for Catch2 — a modern C++-native test framework.
--
-- ONE package, TWO majors. v2 and v3 have completely different source layouts
-- (`single_include/catch2/catch.hpp` vs `src/catch2/**`), and this descriptor
-- covers both by taking the UNION of the two layouts' globs. That works only
-- because the two sets are DISJOINT:
--
--   | glob                    | 2.13.10                         | 3.15.2 |
--   |-------------------------|---------------------------------|--------|
--   | */single_include        | exists                          | absent |
--   | */src/catch2/**/*.cpp   | 0 matches — v2's only src/ file | 107    |
--   |                         | is src/catch_with_main.cpp,     |        |
--   |                         | NOT under src/catch2/           |        |
--
-- So each version lights up exactly one half and the other degenerates to
-- empty: v2 resolves to header-only (single_include + the anchor TU below),
-- v3 to a 106-TU static library. An include_dir whose glob matches nothing is
-- not an error, which is what makes the union safe.
--
-- THIS DISJOINTNESS IS THE LOAD-BEARING PREMISE, and it is a property of the
-- two upstream trees rather than something this descriptor can enforce. Re-
-- check the table above when adding a version. The right long-term shape is
-- per-version build blocks — mcpp-community/mcpp#290 — after which this
-- collapses into explicit ["2.x"] / ["3.x"] tables and the assumption goes
-- away entirely. Splitting into two packages was rejected: it encodes a
-- version into the `name` segment, which SPEC-001 identity reserves for an
-- atomic name, and it breaks semver across the major (a consumer could not
-- write `catch2 = "^3"`).
--
-- Features (sources-only gate):
--   `main` — compiles a GENERATED TU supplying a default entry point. It
--   branches on __has_include(<catch2/catch_all.hpp>), which exists only in
--   v3, to pick the v3 (Catch::Session) or v2 (CATCH_CONFIG_MAIN) spelling.
--   Excluded by default; request `features = ["main"]`.
--
--   It deliberately does NOT point at upstream's
--   src/catch2/internal/catch_main.cpp. That file is matched by the sources
--   glob and must be `!`-negated, else a consumer with its own main() gets
--   `multiple definition of 'main'`; and a `!` negation is an ABSOLUTE
--   exclusion that a feature cannot add back — pointing the feature at the
--   negated path yields a feature that silently does nothing and an
--   `undefined reference to 'main'` at link time. Both directions were
--   measured on mcpp 0.0.109. Note this is NOT `compat.gtest`'s shape:
--   gtest lists gtest_main.cc as a LITERAL `sources` entry, and feature
--   gating matches literal entries — a file pulled in by a glob is not gated
--   at all. A generated TU sidesteps the whole conflict.
--
--   Cost of not reusing upstream's file: no LeakDetector registration (a
--   Windows CRT-debug nicety) and no wmain variant (reachable only under
--   _UNICODE on Windows). Consumers needing either write their own main().
--
-- All `mcpp` paths are GLOBS relative to the verdir; the leading `*` absorbs
-- the GitHub tarball's `Catch2-<tag>/` wrap layer.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "catch2",
    description = "A modern, C++-native test framework for unit-tests, TDD and BDD",
    licenses    = {"BSL-1.0"},
    repo        = "https://github.com/catchorg/Catch2",
    type        = "package",

    xpm = {
        linux = {
            ["2.13.10"] = {
                url = {
                    GLOBAL = "https://github.com/catchorg/Catch2/archive/refs/tags/v2.13.10.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/catch2/releases/download/2.13.10/catch2-2.13.10.tar.gz",
                },
                sha256 = "d54a712b7b1d7708bc7a819a8e6e47b2fde9536f487b89ccbca295072a7d9943",
            },
            ["3.15.2"] = {
                url = {
                    GLOBAL = "https://github.com/catchorg/Catch2/archive/refs/tags/v3.15.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/catch2/releases/download/3.15.2/catch2-3.15.2.tar.gz",
                },
                sha256 = "acfae120892c2b67a74142d36d060c0caa96f1c3aaa8aabd96e19961163d0420",
            },
        },
        macosx = {
            ["2.13.10"] = {
                url = {
                    GLOBAL = "https://github.com/catchorg/Catch2/archive/refs/tags/v2.13.10.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/catch2/releases/download/2.13.10/catch2-2.13.10.tar.gz",
                },
                sha256 = "d54a712b7b1d7708bc7a819a8e6e47b2fde9536f487b89ccbca295072a7d9943",
            },
            ["3.15.2"] = {
                url = {
                    GLOBAL = "https://github.com/catchorg/Catch2/archive/refs/tags/v3.15.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/catch2/releases/download/3.15.2/catch2-3.15.2.tar.gz",
                },
                sha256 = "acfae120892c2b67a74142d36d060c0caa96f1c3aaa8aabd96e19961163d0420",
            },
        },
        windows = {
            ["2.13.10"] = {
                url = {
                    GLOBAL = "https://github.com/catchorg/Catch2/archive/refs/tags/v2.13.10.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/catch2/releases/download/2.13.10/catch2-2.13.10.tar.gz",
                },
                sha256 = "d54a712b7b1d7708bc7a819a8e6e47b2fde9536f487b89ccbca295072a7d9943",
            },
            ["3.15.2"] = {
                url = {
                    GLOBAL = "https://github.com/catchorg/Catch2/archive/refs/tags/v3.15.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/catch2/releases/download/3.15.2/catch2-3.15.2.tar.gz",
                },
                sha256 = "acfae120892c2b67a74142d36d060c0caa96f1c3aaa8aabd96e19961163d0420",
            },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        c_standard   = "c11",          -- for the anchor TU below

        -- Union of both layouts. v2 resolves */single_include, v3 resolves
        -- */src; the other one matches nothing and is skipped. mcpp_generated
        -- carries catch2/catch_user_config.hpp for v3.
        include_dirs = { "*/single_include", "*/src", "mcpp_generated" },

        generated_files = {
            -- v3 only. Upstream ships catch_user_config.hpp.in and lets CMake
            -- materialise it. Only the two VALUE defines are mandatory —
            -- everything else in the .in is a #cmakedefine, i.e. absent means
            -- "use the compiler-detected default", which is what we want.
            -- #ifndef-guarded so a consumer can override via -D.
            -- Re-read the upstream .in when bumping v3: a newly added
            -- mandatory value-define would otherwise break silently here.
            -- v2 never includes this file.
            ["mcpp_generated/catch2/catch_user_config.hpp"] = [==[
#ifndef CATCH_USER_CONFIG_HPP_INCLUDED
#define CATCH_USER_CONFIG_HPP_INCLUDED

#ifndef CATCH_CONFIG_DEFAULT_REPORTER
#define CATCH_CONFIG_DEFAULT_REPORTER "console"
#endif
#ifndef CATCH_CONFIG_CONSOLE_WIDTH
#define CATCH_CONFIG_CONSOLE_WIDTH 80
#endif

#endif // CATCH_USER_CONFIG_HPP_INCLUDED
]==],
            -- Required for v2, where the sources glob below matches nothing
            -- and a lib target still needs at least one TU (same shape as
            -- compat.eigen / compat.khrplatform). Inert extra object on v3.
            ["mcpp_generated/catch2_anchor.c"] = [==[
int mcpp_compat_catch2_anchor(void) { return 0; }
]==],
            -- The `main` feature's TU. See the header comment for why this is
            -- generated rather than upstream's catch_main.cpp.
            ["mcpp_generated/catch2_main.cpp"] = [==[
#if __has_include(<catch2/catch_all.hpp>)
// Catch2 v3: the library is compiled in; just drive a session.
#  include <catch2/catch_session.hpp>
int main(int argc, char* argv[]) { return Catch::Session().run(argc, argv); }
#else
// Catch2 v2 is header-only: this TU is also where the implementation lands.
#  define CATCH_CONFIG_MAIN
#  include <catch2/catch.hpp>
#endif
]==],
        },

        sources      = {
            "mcpp_generated/catch2_anchor.c",
            "*/src/catch2/**/*.cpp",
            -- Upstream's default main(); would collide with a consumer's own.
            "!*/src/catch2/internal/catch_main.cpp",
        },

        targets      = { ["catch2"] = { kind = "lib" } },
        features     = {
            ["main"] = { sources = { "mcpp_generated/catch2_main.cpp" } },
        },
        deps         = { },
    },
}
