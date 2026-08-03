-- Form B inline descriptor for [Boost::ext].UT — the C++20 single-header
-- unit-testing framework shipped by the boost-ext org (NOT an official Boost
-- library; hence the `boost-ext` package namespace, NOT `compat` and NOT
-- `boost`). Exposed as the C++23 module `boost.ut` so users can write
-- `import boost.ut;` out of the box.
--
-- The upstream release tarball DOES ship an official module interface unit
-- at `include/boost/ut.cppm` (`export module boost.ut;`), but it cannot be
-- used VERBATIM on this index's three CI platforms:
--
--   * GCC 16.1 (--std=c++23) rejects the verbatim file with `-Wtemplate-body`:
--       ut.hpp:1916:5: error: 'size_t' was not declared in this scope;
--         did you mean 'std::size_t'?
--     GCC's two-phase lookup in the module purview is strict: names used at
--     namespace scope of templates must be visible where the template is
--     DEFINED. ut.hpp uses unqualified `size_t` at namespace scope (lines
--     1916/1917/1936/1937) and relies on `std::empty`, `utility::match`,
--     the literal `using` block, etc. — all of which only resolve if the
--     standard library is fully visible in the purview.
--
--   * Clang 22.1 on the MSVC ABI (Windows default target) rejects the verbatim
--     file with `use of undeclared identifier '__argc'` (and `__argv`):
--     ut.hpp line 687 is `#if defined(_MSC_VER)` and references the MSVC
--     builtins `__argc` / `__argv`. Clang DOES set `_MSC_VER` on the MSVC
--     ABI but does NOT provide those builtins (the adjacent branches at
--     lines 291 / 311 / 1147 already gate clang out — line 687 was missed).
--
--   * Clang 20.1.7 (macOS CI's auto-installed default on macos-15) compiles
--     the verbatim file (WITH `export import std;`) fine but the resulting
--     test binary SIGSEGVs (exit 139) during static init of
--     `cfg::runner<reporter_junit<printer>>` — no "Suite '...'" output. A
--     macOS lldb backtrace pins it exactly:
--         frame #0: reporter_junit::reporter_junit at ut.hpp:1620:31
--         stop reason = EXC_BAD_ACCESS (code=1, address=0xffffffffffffffe8)
--     ut.hpp:1620 is the member-init `std::streambuf* cout_save =
--     std::cout.rdbuf();`. The address -0x18 means `std::cout`'s vptr is
--     ZERO — the stream object was NEVER constructed. Root cause:
--     `export import std;` inside the module makes `std::cout` refer to the
--     module's OWN copy of the std stream entities, NOT libc++'s — an ODR
--     split between "the std module's std::cout" and "the libc++ library's
--     std::cout" (Apple libc++ does not merge module std entities the way
--     libstdc++/MSVC STL do). libc++'s `ios_base::Init` constructs the
--     library copy; the module's copy stays all-zero, so
--     `cfg`'s member-init `std::cout.rdbuf()` dereferences the null vptr.
--
-- The FIX (matching how every other successful C++23 module package in this
-- index — nlohmann.json, marzer.tomlplusplus, neargye.magic_enum — is built):
-- the module TU must NOT `export import std;`. It pulls stdlib in via
-- `#include` only, so every `std::*` symbol inside ut.hpp is the library's
-- own (same ODR entity the linker binds). Consumers `import std;` themselves
-- (the test member does), which is the established pattern and works on all
-- three CI platforms. Removing `export import std;` alone was NOT enough
-- though — it used to explode on GCC with a cascade of `-Wtemplate-body`
-- errors (`std::empty`, `utility::match`, `call_steps_`, the literal `using`
-- block, …) because GCC's two-phase lookup could not see the stdlib names
-- from `#include` in the module purview. Two things make it work now:
--   1. the module's GLOBAL-MODULE-FRAGMENT `#include`s (below, before
--      `export module`) make all the stdlib headers VISIBLE to the module
--      TU (GMF declarations are visible to the purview); and
--   2. `cxxflags = { "-Wno-template-body" }` silences GCC's remaining
--      two-phase-lookup pedantry inside ut.hpp's templates. GCC 16.1
--      accepts `-Wno-template-body` (verified), and ut.hpp compiles + runs
--      green on gcc 16.1 / x86_64-windows-gnu AND llvm 20.1.7 /
--      x86_64-windows-msvc.
--
-- So this descriptor is a `generated_files` wrapper over upstream's
-- `include/boost/ut.cppm` INTENT — ut.hpp included in the module purview
-- with `BOOST_UT_CXX_MODULES=1`, so the `export namespace boost::...{...}`
-- block ut.hpp opens at line 111 exports everything — with these deviations:
--
--   dev 1. `export import std;` is DROPPED (the macOS ODR-split fix above),
--          and instead the global-module-fragment `#include`s every stdlib
--          header ut.hpp needs (its own includes at lines 73-104 still run,
--          the GMF list just guarantees they're all present and visible for
--          GCC's two-phase lookup).
--   dev 2. Two compiler-compat shims:
--          shim a: `using std::size_t;` — lifts `std::size_t` into the
--                  global namespace so the unqualified `size_t` at ut.hpp
--                  namespace scope resolves (GCC template-body pedantry;
--                  std::size_t is available because <cstddef> is in the GMF).
--          shim b: `#define __argc 0` / `#define __argv nullptr` gated to
--                  `__clang__` on `_MSC_VER` — fixes Clang-on-Windows
--                  (`__argc` / `__argv` builtins missing under `_MSC_VER`);
--                  MSVC itself never enters the guard.
--   dev 3. The post-v2.3.1 explicit-template-instantiation block (see below)
--          is appended AFTER `#include "ut.hpp"`, lifted VERBATIM from
--          upstream `master`. It is upstream's fix for a Clang module
--          LINKAGE gap and is a harmless no-op on GCC/MSVC; it does NOT
--          address the macOS ODR-split (dev 1 does). Kept because upstream
--          added it for a reason and it is cheap to carry.
--
-- The base `ut.hpp` stays pinned to the reproducible v2.3.1 release tag —
-- the shims add NO code of our own beyond what the compiler/runtime had to
-- see anyway, and the appended instantiation block is upstream master's own
-- byte-for-byte fix.
--
-- include_dirs exposes `*/include/boost` so the wrapper's `#include "ut.hpp"`
-- resolves (and `#include <boost/ut.hpp>` remains available to consumers who
-- want the header form). The upstream path is a GLOB — the leading `*`
-- absorbs the archive's `ut-2.3.1/` wrap layer — while the generated cppm
-- path is verdir-relative (no glob), like nlohmann.json / marzer.tomlplusplus.
--
-- `import_std` stays false: the module TU must not get an injected
-- `import std;` (mcpp would otherwise add one), and consumers are expected
-- to `import std;` themselves exactly like the other module packages.
--
-- License: Boost Software License 1.0. The SPDX identifier is BSL-1.0.
--
-- Package identity: `namespace = "boost-ext"`, `name = "ut"`; the C++20
-- namespace the library actually declares is `boost::ext::ut::v2_3_1` —
-- unrelated to the mcpp namespace, which uses `-` precisely because `.` would
-- collide with mcpp's own `<ns>.<short>` addressing convention.
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
        -- GCC 16.1's module two-phase lookup (the -Wtemplate-body errors)
        -- needs every stdlib name visible at template-definition time; the
        -- GMF includes below provide that. The remaining pedantry inside
        -- ut.hpp's templates (unqualified `size_t`, `std::empty`, the
        -- literals using-block, ...) is silenced with -Wno-template-body.
        -- Clang 20.1.7 / 22.1 do NOT need this flag and ignore it.
        cxxflags     = { "-Wno-template-body" },
        -- Upstream's v2.3.1 ut.cppm reproduced with the deviations documented
        -- at the top of this descriptor:
        --   dev 1: `export import std;` DROPPED — global-module-fragment
        --          `#include`s of every stdlib header ut.hpp needs instead
        --          (macOS ODR-split fix; see header comment).
        --   dev 2: two compiler-compat shims (`using std::size_t;` for GCC;
        --          `__argc`/`__argv` define for Clang-on-Windows MSVC ABI).
        --   dev 3: post-v2.3.1 explicit-template-instantiation block (from
        --          upstream `master`) appended after `#include "ut.hpp"`.
        -- Verdir-relative path, no glob — like nlohmann.json / marzer.tomlplusplus.
        generated_files = {
            ["mcpp_generated/boost.ut.cppm"] = [==[
module;

// Global-module-fragment: every stdlib header ut.hpp needs, so the module
// TU sees the SAME std entities the library links (no `export import std;`
// → no module-vs-library ODR split on std::cout — the macOS SIGSEGV fix)
// AND GCC's module two-phase lookup finds the names it needs.
#include <cstddef>
#include <algorithm>
#include <array>
#include <chrono>
#include <concepts>
#include <cstdint>
#include <fstream>
#include <functional>
#include <iostream>
#include <memory>
#include <optional>
#include <sstream>
#include <stack>
#include <string>
#include <string_view>
#include <type_traits>
#include <unordered_map>
#include <utility>
#include <variant>
#include <vector>
#include <exception>
#include <format>
#include <source_location>
#include <version>

#if __has_include(<unistd.h>) and __has_include(<sys/wait.h>)
#include <sys/wait.h>
#include <unistd.h>
#endif

export module boost.ut;

// ---- mcpp-index compat shim 1/2: GCC template-body fix -------------------
// ut.hpp uses `size_t` unqualified at namespace scope (e.g. line 1916);
// GCC's module two-phase lookup needs it resolvable where used. <cstddef>
// (in the GMF above) brings std::size_t; this `using` lifts it to the
// global namespace so the unqualified name resolves inside the exported
// namespace block ut.hpp opens below.
using std::size_t;

// ---- mcpp-index compat shim 2/2: Clang-on-Windows fix ---------------------
// ut.hpp line 687 is `#if defined(_MSC_VER)` and references the MSVC
// builtins `__argc` / `__argv`. Clang on the MSVC ABI (x86_64-windows-msvc)
// sets `_MSC_VER` but does NOT provide those builtins — the neighboring
// upstream guards at lines 291 / 311 / 1147 already gate clang out, but
// line 687 missed it. Provide macros as stand-ins (cfg::largc is reassigned
// from main() args at runtime anyway, so the value is unused). MSVC itself
// never enters this guard, so its real builtins are untouched.
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

// ---- mcpp-index deviation 3: post-v2.3.1 explicit template instantiations --
// Lifted VERBATIM from upstream `master`'s include/boost/ut.cppm. v2.3.1's
// ut.cppm stops at `#include "ut.hpp"`, which leaves the member templates
// the runner dispatches to (`reporter_junit<>::on<...>`, `test::operator=<>`,
// `expect<bool>`) only IMPLICITLY instantiable. Explicitly instantiating
// them forces emission — upstream's fix for a Clang module linkage gap.
// NOTE: this does NOT fix the macOS crash (ut.hpp:1620 `std::cout.rdbuf()`
// ODR split) — dev 1 (no `export import std;`) is the macOS fix. Both stay:
// dev 1 is the ODR fix, dev 3 is upstream's verbatim linkage-gap fix.
// Once a >2.3.1 release ships this block, switch `sources` to
// `*/include/boost/ut.cppm` and drop `generated_files`; these lines come
// back with the verbatim upstream cppm.
template class boost::ut::reporter_junit<boost::ut::printer>;
template void boost::ut::reporter_junit<boost::ut::printer>::on<bool>(boost::ut::events::log<bool>);
template void boost::ut::reporter_junit<boost::ut::printer>::on<bool>(boost::ut::events::assertion_pass<bool>);
template void boost::ut::reporter_junit<boost::ut::printer>::on<bool>(boost::ut::events::assertion_fail<bool>);
template auto boost::ut::detail::test::operator=<>(test_location<void (*)()> _test);
template auto boost::ut::expect<bool>(const bool&expr,const reflection::source_location&);
template void boost::ut::reporter_junit<>::on<boost::ut::detail::fatal_<bool>>(events::assertion_fail<boost::ut::detail::fatal_<bool>>);
template void boost::ut::reporter_junit<>::on<boost::ut::detail::fatal_<bool>>(events::assertion_pass<boost::ut::detail::fatal_<bool>>);
template void boost::ut::reporter_junit<>::on<boost::ut::detail::fatal_<bool>>(events::log<boost::ut::detail::fatal_<bool>>);
]==],
        },
        sources      = { "mcpp_generated/boost.ut.cppm" },
        targets      = { ["boost_ut"] = { kind = "lib" } },
        deps         = { },
    },
}