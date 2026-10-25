-- Form B inline descriptor for SOCI — a C++ database access layer that puts one
-- API in front of many engines. A consumer writes `#include <soci/soci.h>` and
-- links `soci`.
--
-- SHAPE: A (C++ source compat). Upstream is CMake-built; this descriptor compiles
-- the TUs directly — `src/core/*.cpp` (upstream's 22-file `add_library(soci_core
-- …)` list) and `src/backends/sqlite3/*.cpp` (upstream's 10-file `soci_sqlite3`
-- list) — into ONE lib target. Upstream ships those as two libraries, but a
-- backend-less SOCI core cannot open a session at all, so the split buys a
-- consumer nothing here; and mcpp's `sources` is one list per package anyway.
-- Same-named TUs across the two directories (blob, error, session, statement
-- each exist twice) do not collide: mcpp mirrors the source path relative to the
-- wrap directory into the object path (`obj/compat_soci/soci-4.1.4/src/core/…`).
--
-- WHY THE SQLITE3 BACKEND, AND WHY IT IS NOT GATED. A backend is what makes SOCI
-- usable, so a core-only package would be a package nobody can use. sqlite3 is
-- the only backend whose client library is BOTH in this index (`compat.sqlite3`)
-- and needs nothing from the host: upstream vendors it as the `3rdparty/sqlite3`
-- GIT SUBMODULE, and a source tarball carries no submodules — the dependency edge
-- replaces it, exactly as `compat.sqlitecpp` does (and two consumers of SQLite in
-- one link then share one amalgamation instead of embedding private copies).
-- The other seven backends (mysql, odbc, postgresql, oracle, db2, firebird,
-- empty) each need an outside library — libpq, Oracle, DB2 and Firebird clients
-- are not in this index at all — so they are left out rather than half-declared.
-- Adding one later is a `sources` line plus a `deps` line, not a rework.
--
-- THE TWO DEPENDENCIES.
--   * `compat.fmt` — SOCI 4.1 made fmt a HARD dependency of the core: seven core
--     TUs (backend-loader, connection-parameters, error, row, session, statement,
--     values) `#include <fmt/format.h>` unconditionally, and the sqlite3
--     backend's session/standard-use-type/vector-* TUs do too. What this package
--     needs is an ORDINARY fmt: headers plus a library of global-module symbols.
--     The module form cannot serve it, and that is measured rather than assumed —
--     compiling those headers header-only into SOCI's TUs while the C++23 module
--     package `fmtlib.fmt` sat in the same link produced real duplicate symbols
--     on the MSVC ABI (lld-link: duplicate symbol
--     `fmt::v12::detail::dragonbox::cache_accessor<double>::compute_mul`, defined
--     once in the module object and once in SOCI's values.o), because a module
--     object's COMDAT keys do not collide with header-only ones. `compat.fmt` is
--     that ordinary fmt, and it is what the module package's own comment calls
--     its header-form sibling. Nothing here needs any define about fmt.
--   * `compat.sqlite3` — the sqlite3 backend's client library, i.e. what the
--     missing submodule would have provided.
--
-- MACROS THAT CANNOT CROSS THE DESCRIPTOR. Upstream passes three groups of PRIVATE
-- compile definitions to `soci_core`/`soci_sqlite3`; mcpp's `cxxflags` is
-- package-private (it reaches this package's TUs and not a consumer compiling
-- `soci.h` — the property `compat.zlib` documents at length), so all three are
-- free of consumer-visible side effects:
--
--   1. `-DSOCI_SQLITE3_SOURCE=1`, a plain flag — load-bearing and easy to miss:
--      `soci-sqlite3.h` puts `#include <sqlite3.h>` INSIDE `namespace sqlite_api`
--      and only does so `#ifdef SOCI_SQLITE3_SOURCE`; without the define the
--      backend sees just the two forward declarations, and every `sqlite3_*` call
--      fails to compile with "use of undeclared identifier". Consumers are the
--      mirror image of that switch: including the header WITHOUT the define is
--      the supported consumer mode, which is why the define must not leak.
--   2. `SOCI_LIB_PREFIX` / `SOCI_LIB_SUFFIX` / `SOCI_DEBUG_POSTFIX`, which
--      backend-loader.cpp uses to build backend shared-object names for dlopen().
--      They are QUOTED string macros, and quotes do not survive the descriptor →
--      mcpp → compiler-argv pipeline (`compat.unixodbc` measured the same wall
--      with `LT_CONFIG_H`), so they arrive via a force-included shim header
--      instead. Their values mirror upstream's own computation; nothing here
--      ships or loads a backend DSO, so the name is inert — backends are compiled
--      INTO the same lib, and a consumer reaches the sqlite3 backend through the
--      `soci::sqlite3` factory object rather than through `session("sqlite3",…)`,
--      which would go looking for `libsoci_sqlite3.so`.
--   3. `SOCI_HAVE_SQLITE3`, i.e. `soci-config.h` — the one header upstream's
--      CMake GENERATES rather than ships, and `soci/soci-platform.h` includes it
--      unconditionally. mcpp has no configure step, so it is reproduced verbatim
--      in `generated_files`, including the commented-out `SOCI_HAVE_*` lines for
--      the backends that are not built.
--
-- Boost is NOT a dependency and is deliberately left off: SOCI's public headers
-- only reach for `<boost/…>` under `SOCI_USE_BOOST`, which upstream's CMake
-- defines only when it finds Boost, and no source uses Boost otherwise.
--
-- `include_dirs` carries `*/include/private` because the core TUs include the
-- private headers (`soci-case.h`, `soci-mutex.h`, …) by bare name. mcpp has no
-- build-only include path, so consumers see that directory too; it is inert
-- (the private headers are not self-contained) and is the price of not copying
-- upstream's headers around.
--
-- No CN mirror: no `mcpp-res` write access from here, so `url` stays a plain
-- string and CN users fall back to the GLOBAL source (docs/cn-mirror.md; the
-- precedent is compat.nanodbc / compat.sqlite3, and the maintainer can turn it
-- into a { GLOBAL, CN } table later without the sha256 changing).
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "soci",
    description = "SOCI — a C++ database access library with one API over many engines",
    licenses    = {"BSL-1.0"},
    repo        = "https://github.com/SOCI/soci",
    type        = "package",

    extensions = {
        autoupdate = {
            tag = "v${version}",
            url = "https://github.com/SOCI/soci/archive/refs/tags/${tag}.tar.gz",
        },
    },

    xpm = {
        linux = {
            ["4.1.4"] = {
                url    = "https://github.com/SOCI/soci/archive/refs/tags/v4.1.4.tar.gz",
                sha256 = "144f017cccc2e2d806badb3313d6ab3c67a1925bccaa747a46fb3907108a615d",
            },
        },
        macosx = {
            ["4.1.4"] = {
                url    = "https://github.com/SOCI/soci/archive/refs/tags/v4.1.4.tar.gz",
                sha256 = "144f017cccc2e2d806badb3313d6ab3c67a1925bccaa747a46fb3907108a615d",
            },
        },
        windows = {
            ["4.1.4"] = {
                url    = "https://github.com/SOCI/soci/archive/refs/tags/v4.1.4.tar.gz",
                sha256 = "144f017cccc2e2d806badb3313d6ab3c67a1925bccaa747a46fb3907108a615d",
            },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        -- `*/include` exposes <soci/soci.h> and the per-backend
        -- <soci/sqlite3/soci-sqlite3.h>; `*/include/private` is for the core's own
        -- bare-name private includes; `mcpp_generated/include` carries the
        -- generated soci-config.h and the force-included shim (see the header).
        include_dirs = { "*/include", "*/include/private", "mcpp_generated/include" },

        generated_files = {
            -- Upstream's CMake `file(GENERATE)`s this from the SOCI_<BACKEND> cache
            -- variables (`src/CMakeLists.txt`); it is the only header in the
            -- public API set that does not exist in the tarball. Content below is
            -- what CMake emits with the sqlite3 backend enabled and the others
            -- off, byte-for-byte including the disabled `/* #define */` lines.
            ["mcpp_generated/include/soci/soci-config.h"] = [==[
#ifndef SOCI_SOCICONFIG_H_INCLUDED
#define SOCI_SOCICONFIG_H_INCLUDED

/* #define SOCI_HAVE_EMPTY */

/* #define SOCI_HAVE_DB2 */

/* #define SOCI_HAVE_FIREBIRD */

/* #define SOCI_HAVE_MYSQL */

/* #define SOCI_HAVE_ODBC */

/* #define SOCI_HAVE_ORACLE */

/* #define SOCI_HAVE_POSTGRESQL */

#define SOCI_HAVE_SQLITE3 1

#endif
]==],

            -- Point (2) in the header comment: the quoted-string definitions CMake
            -- passes PRIVATE to soci_core, which the descriptor cannot express.
            -- Force-included (see cxxflags) so backend-loader.cpp sees them no
            -- matter which TU is being compiled.
            ["mcpp_generated/include/mcpp_soci_defines.h"] = [==[
#ifndef MCPP_SOCI_DEFINES_H
#define MCPP_SOCI_DEFINES_H
#if defined(_WIN32)
#define SOCI_LIB_PREFIX "soci_"
#define SOCI_LIB_SUFFIX ".dll"
#elif defined(__APPLE__)
#define SOCI_LIB_PREFIX "libsoci_"
#define SOCI_LIB_SUFFIX ".dylib"
#else
#define SOCI_LIB_PREFIX "libsoci_"
#define SOCI_LIB_SUFFIX ".so"
#endif
#define SOCI_DEBUG_POSTFIX ""
#endif
]==],
        },

        cxxflags = { "-DSOCI_SQLITE3_SOURCE=1",
                     "-include", "mcpp_soci_defines.h" },

        sources = {
            "*/src/core/*.cpp",
            "*/src/backends/sqlite3/*.cpp",
        },

        targets = { ["soci"] = { kind = "lib" } },

        -- Must be an ORDINARY (non-module) fmt — see the header comment for the
        -- measured reason. If `compat.fmt` is ever re-cut as a header-only
        -- package, this package has to add `-DFMT_HEADER_ONLY=1` to `cxxflags`
        -- to match it.
        deps = {
            ["compat.fmt"]     = "12.2.0",
            ["compat.sqlite3"] = "3.45.3",
        },
    },
}
