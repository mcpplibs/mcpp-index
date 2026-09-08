-- compat.libassert — the assertion library that prints the expression, the
-- values in it, and a stack trace.
--
--     DEBUG_ASSERT(vec.size() > n, "index out of range", vec, n);
--
-- Shape A over eight C++ TUs. The interesting parts are all about what it
-- needs and what it deliberately does not.
--
-- ── cpptrace is a real dependency, not a vendored copy ─────────────────────
--
-- Upstream FetchContents cpptrace at a pinned commit (1.0.4) and builds it
-- inside its own tree. Here it is `compat.cpptrace`, the same package anything
-- else in this index would use — so a consumer that links both gets one
-- cpptrace rather than two copies of the same symbols.
--
-- ── magic_enum is NOT needed, and that is upstream's own answer ────────────
--
-- `LIBASSERT_USE_MAGIC_ENUM` looks like a library feature and is not: read
-- CMakeLists around line 232 and it is switched on only under
-- `LIBASSERT_BUILD_TESTING`, for upstream's own test suite. The library
-- sources never mention magic_enum. So nothing here turns it off — there was
-- never anything to turn off. (A consumer coming from xmake's
-- `libassert[magic_enum=n]` is asking for exactly this build.)
--
-- ── LIBASSERT_STATIC_DEFINE, same reason as cpptrace ───────────────────────
--
-- Upstream's `include/libassert/platform.hpp` decorates every declaration with
-- `__declspec(dllexport)` / `visibility("default")` unless that macro says the
-- build is static. It is checked in rather than generated, so this is a define
-- and not a snapshot — but it is not optional, and it has to reach CONSUMERS
-- too, not just this package's own TUs: the attribute is on the declarations
-- they include. Hence `defines`, which mcpp applies to both, rather than
-- `cxxflags`, which is package-private.
--
-- ── One generated header ───────────────────────────────────────────────────
--
-- `libassert/version.hpp` is a `configure_file` of `cmake/in/version-hpp.in`
-- whose only inputs are the three numbers in `project()`. Snapshot, not a
-- build step — the same shape `compat.cpptrace` uses.
--
-- Upstream also ships `src/libassert.cppm` (`export module libassert;`), which
-- this entry does not build: `compat.*` promises header consumption in this
-- index, and the `.cppm` is excluded by the `*.cpp` glob rather than by an
-- exclusion rule. A module entry under the owning namespace can be added later
-- without disturbing this one.
--
-- CN mirror: `gitcode.com/mcpp-res/libassert`, the upstream tarball re-hosted
-- BYTE-IDENTICALLY (verified: the mirror's sha256 equals the one declared
-- here, which is what lets one `sha256` serve both arms). GLOBAL stays the
-- default; CN is the fallback `mcpp self config --mirror CN` selects.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "libassert",
    description = "libassert — the ergonomic assertion library, with expression decomposition and stack traces",
    licenses    = {"MIT"},
    repo        = "https://github.com/jeremy-rifkin/libassert",
    type        = "package",

    xpm = {
        linux = {
            ["2.2.1"] = {
                url    = {
                    GLOBAL = "https://github.com/jeremy-rifkin/libassert/archive/refs/tags/v2.2.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/libassert/releases/download/2.2.1/libassert-2.2.1.tar.gz",
                },
                sha256 = "a7882ff2922c6d57f955f5ea9418014619e0855e936eb92e5443914dd1a8f724",
            },
        },
        macosx = {
            ["2.2.1"] = {
                url    = {
                    GLOBAL = "https://github.com/jeremy-rifkin/libassert/archive/refs/tags/v2.2.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/libassert/releases/download/2.2.1/libassert-2.2.1.tar.gz",
                },
                sha256 = "a7882ff2922c6d57f955f5ea9418014619e0855e936eb92e5443914dd1a8f724",
            },
        },
        windows = {
            ["2.2.1"] = {
                url    = {
                    GLOBAL = "https://github.com/jeremy-rifkin/libassert/archive/refs/tags/v2.2.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/libassert/releases/download/2.2.1/libassert-2.2.1.tar.gz",
                },
                sha256 = "a7882ff2922c6d57f955f5ea9418014619e0855e936eb92e5443914dd1a8f724",
            },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        c_standard   = "c11",

        include_dirs = { "*/include", "mcpp_generated" },

        generated_files = {
            ["mcpp_generated/libassert/version.hpp"] = [==[
/* configure_file() of cmake/in/version-hpp.in for libassert 2.2.1. */
#ifndef LIBASSERT_VERSION_HPP
#define LIBASSERT_VERSION_HPP

#define LIBASSERT_VERSION_MAJOR 2
#define LIBASSERT_VERSION_MINOR 2
#define LIBASSERT_VERSION_PATCH 1
#define LIBASSERT_TO_VERSION(MAJOR, MINOR, PATCH) ((MAJOR) * 10000 + (MINOR) * 100 + (PATCH))
#define LIBASSERT_VERSION LIBASSERT_TO_VERSION(LIBASSERT_VERSION_MAJOR, LIBASSERT_VERSION_MINOR, LIBASSERT_VERSION_PATCH)

#endif
]==],
        },

        -- `*.cpp` leaves `src/libassert.cppm` out by extension; the private
        -- headers next to them are reached by quoted include, so `*/src` does
        -- not go on the include path and consumers never see `utils.hpp`.
        sources = { "*/src/*.cpp" },
        targets = { ["libassert"] = { kind = "lib" } },
        deps    = { ["compat.cpptrace"] = "1.0.4" },

        defines = { "LIBASSERT_STATIC_DEFINE" },
    },
}
