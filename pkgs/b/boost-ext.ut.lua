-- Form B inline descriptor for [Boost::ext].UT — the C++20 single-header
-- unit-testing framework shipped by the boost-ext org (NOT an official Boost
-- library; hence the `boost-ext` package namespace, NOT `compat` and NOT
-- `boost`). Exposed as the C++23 module `boost.ut` so users can write
-- `import boost.ut;` out of the box.
--
-- The upstream release tarball ships an official module interface unit at
-- `include/boost/ut.cppm` (`export module boost.ut;`). This descriptor
-- reproduces that file through `generated_files` with EXACTLY ONE deviation —
-- everything else, including `export import std;`, is upstream's own bytes in
-- upstream's own order.
--
-- The one deviation: Clang on the MSVC ABI (`*-pc-windows-msvc`, this index's
-- Windows default toolchain — llvm@20.1.7, NOT mingw, NOT cl.exe) rejects
-- upstream's file with
--     ut.hpp:688:29: error: use of undeclared identifier '__argc'
--     ut.hpp:689:63: error: use of undeclared identifier '__argv'
-- ut.hpp line 687 is `#if defined(_MSC_VER)` and reaches for the MSVC builtins
-- `__argc` / `__argv`. Clang DOES set `_MSC_VER` on that ABI but does NOT
-- provide those builtins — the neighbouring upstream guards at lines 291 / 311
-- / 1147 already gate clang out, line 687 missed it. So the wrapper defines the
-- two names as macros around the `#include`, under `_MSC_VER && __clang__`
-- only: real MSVC never enters the guard and keeps its builtins, and no
-- non-Windows target ever sees the macros. `cfg::largc` / `cfg::largv` are
-- reassigned from `main()`'s argv at runtime, so the stand-in values are never
-- read.
--
-- That is the whole delta. In particular this descriptor does NOT:
--   * drop `export import std;` — keeping upstream's spelling is what makes
--     GCC 16.1 accept ut.hpp's unqualified `size_t` (ut.hpp:1916 et al) and
--     the `literals` using-block with no `-Wno-template-body` and no
--     hand-written global-module-fragment include list;
--   * carry the post-v2.3.1 explicit-template-instantiation block from
--     upstream `master` — it is in no release tag, and the macOS crash it was
--     tried against turned out to be a toolchain-side problem (below).
--
-- macOS: the verbatim module used to SIGSEGV (exit 139) during static init of
-- `cfg::runner<reporter_junit<printer>>`, at ut.hpp:1620's member-init
-- `std::streambuf* cout_save = std::cout.rdbuf();` — libc++'s `std::cout` had
-- not been constructed yet. That is mcpp-community/mcpp#336, fixed in mcpp
-- 2026.8.3.1: Mach-O has no priority-ordered init section and libc++'s
-- `<iostream>` carries no `ios_base::Init` guard of its own, so mcpp now links
-- a generated object first whose constructor brings the streams up. It is not
-- fixable package-side (`std::ios_base::Init` is only forward-declared in
-- libc++'s `<ios>`), which is why this package needs mcpp >= 2026.8.3.1 on
-- macOS — covered by the floor this index declares in index.toml.
--
-- `include_dirs` exposes `*/include/boost` so the wrapper's `#include
-- "ut.hpp"` resolves (and `#include <boost/ut.hpp>` stays available to
-- consumers who want the header form). That path is a GLOB — the leading `*`
-- absorbs the archive's `ut-2.3.1/` wrap layer — while the generated cppm path
-- is verdir-relative (no glob), like nlohmann.json / marzer.tomlplusplus.
--
-- `import_std` stays false: the module TU must not get an injected `import
-- std;` (upstream's file does its own `export import std;`), and consumers
-- `import std;` themselves exactly like the other module packages.
--
-- No features. ut is header-only plus a single module unit, with no extra
-- compilable sources to gate; its optional `BOOST_UT_CONFIG_*` toggles are
-- compile-time defines, which the `features` table cannot carry today (the
-- same limitation as compat.eigen's `EIGEN_MPL2_ONLY` and toml++'s
-- `TOML_EXCEPTIONS`).
--
-- No CN mirror: plain-string upstream URLs, which tests/check_mirror_urls.lua
-- accepts as-is. CN users fall back to the GLOBAL source until a maintainer
-- backfills the gitcode release.
--
-- License: Boost Software License 1.0. The SPDX identifier is BSL-1.0.
--
-- Package identity: `namespace = "boost-ext"`, `name = "ut"`. The C++
-- namespace the library declares is `boost::ext::ut::v2_3_1` — unrelated to
-- the mcpp namespace, which uses `-` precisely because `.` would collide with
-- mcpp's own `<ns>.<short>` addressing convention.
package = {
    spec        = "1",
    namespace   = "boost-ext",
    name        = "ut",
    description = "[Boost::ext].UT — C++20 single-header unit testing framework, exposed as the C++23 module boost.ut",
    licenses    = {"BSL-1.0"},
    repo        = "https://github.com/boost-ext/ut",
    type        = "package",

    xpm = {
        linux = {
            ["2.3.1"] = {
                url    = "https://github.com/boost-ext/ut/archive/refs/tags/v2.3.1.tar.gz",
                sha256 = "e51bf1873705819730c3f9d2d397268d1c26128565478e2e65b7d0abb45ea9b1",
            },
        },
        macosx = {
            ["2.3.1"] = {
                url    = "https://github.com/boost-ext/ut/archive/refs/tags/v2.3.1.tar.gz",
                sha256 = "e51bf1873705819730c3f9d2d397268d1c26128565478e2e65b7d0abb45ea9b1",
            },
        },
        windows = {
            ["2.3.1"] = {
                url    = "https://github.com/boost-ext/ut/archive/refs/tags/v2.3.1.tar.gz",
                sha256 = "e51bf1873705819730c3f9d2d397268d1c26128565478e2e65b7d0abb45ea9b1",
            },
        },
    },

    mcpp = {
        schema       = "0.1",
        language     = "c++23",
        import_std   = false,
        modules      = { "boost.ut" },
        include_dirs = { "*/include/boost" },
        -- Upstream's v2.3.1 include/boost/ut.cppm, reproduced verbatim apart
        -- from the __argc / __argv shim documented at the top of this file.
        -- Verdir-relative path, no glob.
        generated_files = {
            ["mcpp_generated/boost.ut.cppm"] = [==[
module;

#if __has_include(<unistd.h>) and __has_include(<sys/wait.h>)
#include <sys/wait.h>
#include <unistd.h>
#endif

export module boost.ut;
export import std;

// ---- the only mcpp-index deviation from upstream v2.3.1's ut.cppm ---------
// ut.hpp:687 is `#if defined(_MSC_VER)` and references the MSVC builtins
// __argc / __argv. Clang on the MSVC ABI (this index's Windows default,
// *-pc-windows-msvc) sets _MSC_VER but does not provide them; the adjacent
// upstream guards at lines 291 / 311 / 1147 already gate clang out, 687
// missed it. cfg::largc / cfg::largv are reassigned from main()'s argv at
// runtime, so these stand-in values are never read. MSVC itself never enters
// the guard and keeps its own builtins.
#if defined(_MSC_VER) and defined(__clang__)
  #define __argc 0
  #define __argv ((const char**)nullptr)
#endif

#define BOOST_UT_CXX_MODULES 1
#include "ut.hpp"

#if defined(_MSC_VER) and defined(__clang__)
  #undef __argc
  #undef __argv
#endif
]==],
        },
        sources      = { "mcpp_generated/boost.ut.cppm" },
        targets      = { ["boost_ut"] = { kind = "lib" } },
        deps         = { },
    },
}
