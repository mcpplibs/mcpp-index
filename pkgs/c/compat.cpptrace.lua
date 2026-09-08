-- compat.cpptrace — stack traces for C++11 and up, from source.
--
-- Here because `compat.libassert` cannot exist without it: libassert's whole
-- value proposition is an assertion that prints a stack trace, and upstream
-- gets that by FetchContent-ing this repository at a pinned commit. This index
-- does not run FetchContent, so the dependency becomes an ordinary package —
-- which is better anyway: one cpptrace in the graph rather than one per
-- consumer that vendored it.
--
-- ── Whole-source glob, because every backend guards itself ─────────────────
--
-- Shape E without the config header. cpptrace supports six symbol backends,
-- six unwinders and three demanglers, and CMake compiles only the selected
-- ones. That selection is unnecessary here: EVERY backend file opens with its
-- own `#ifdef` (`symbols_with_libdwarf.cpp` → `#ifdef
-- CPPTRACE_GET_SYMBOLS_WITH_LIBDWARF`, and so on down the list), so an
-- unselected backend compiles to an empty translation unit exactly the way
-- curl's `vtls/gtls.c` does. The source list is therefore a plain glob and the
-- whole configuration lives in the defines below.
--
-- ── The backends chosen, and what they cost ────────────────────────────────
--
-- The criterion is ZERO EXTERNAL DEPENDENCIES on every platform, because a
-- diagnostic library that drags in libdwarf, libunwind or libbacktrace makes
-- itself harder to adopt than the problem it solves.
--
--   unix     `_Unwind_Backtrace` from libgcc (always present, it is what the
--            C++ runtime already uses to unwind), `dladdr` for symbols, and
--            `abi::__cxa_demangle` for names.
--   windows  DbgHelp for all three. `dbghelp.dll` is part of Windows itself,
--            so `-ldbghelp` needs nothing installed.
--
-- ⚠️ THE COST IS LINE NUMBERS. `dladdr` resolves an address to a symbol name
-- and the object it came from — it does NOT read DWARF, so traces carry
-- function names without file:line. That is the price of not depending on
-- libdwarf, and it is the right trade for this index today: the alternative is
-- vendoring libdwarf (which upstream itself FetchContents) as a fourth
-- package, for information that matters to a developer at a debugger rather
-- than to CI. A future `libdwarf` feature can add it without changing anything
-- a consumer writes.
--
-- ── Two generated pieces ───────────────────────────────────────────────────
--
--   * `cpptrace/version.hpp` is a `configure_file` of `cmake/in/version-hpp.in`
--     whose only inputs are the three version numbers in `project()`. Snapshot,
--     not a build step.
--   * `CPPTRACE_STATIC_DEFINE` is upstream's own switch (it is checked in
--     `include/cpptrace/basic.hpp`, not generated), and it is required: without
--     it every declaration carries `__declspec(dllexport)` /
--     `visibility("default")` for a shared library this package does not build.
--
--     ⚠️ IT GOES IN `defines`, NOT `cxxflags`, AND ONLY WINDOWS SAYS SO. The
--     macro decorates DECLARATIONS, so it has to reach every TU that INCLUDES
--     the headers — not just this package's own. As `cxxflags` (package-private)
--     Linux stayed green, because there the difference is
--     `visibility("default")` versus nothing and the link is unaffected. On the
--     MSVC ABI it is `dllimport` versus nothing, which is an ABI difference, and
--     `compat.libassert` — whose TUs include these headers — failed to link:
--
--         lld-link: warning: locally defined symbol imported:
--             cpptrace::v1::runtime_error::runtime_error(...) [LNK4217]
--         lld-link: error: undefined symbol: __declspec(dllimport)
--             cpptrace::v1::stacktrace_frame::operator!=(...) const
--
--     Measured on the windows CI leg. The BACKEND macros below stay in
--     `cxxflags` on purpose: those select which .cpp compiles to something and
--     are nobody else's business.
--
-- Upstream also ships `src/cpptrace.cppm` (`export module cpptrace;`). It is
-- deliberately NOT built here: this entry is `compat.*`, which in this index
-- promises header consumption and nothing else, and libassert — the reason
-- this package exists — consumes the headers. A module entry under the owning
-- namespace can be added later without disturbing this one.
--
-- CN mirror: `gitcode.com/mcpp-res/cpptrace`, the upstream tarball re-hosted
-- BYTE-IDENTICALLY (verified: the mirror's sha256 equals the one declared
-- here, which is what lets one `sha256` serve both arms). GLOBAL stays the
-- default; CN is the fallback `mcpp self config --mirror CN` selects.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "cpptrace",
    description = "cpptrace — simple, portable stack traces for C++",
    licenses    = {"MIT"},
    repo        = "https://github.com/jeremy-rifkin/cpptrace",
    type        = "package",

    xpm = {
        linux = {
            ["1.0.4"] = {
                url    = {
                    GLOBAL = "https://github.com/jeremy-rifkin/cpptrace/archive/refs/tags/v1.0.4.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/cpptrace/releases/download/1.0.4/cpptrace-1.0.4.tar.gz",
                },
                sha256 = "5c9f5b301e903714a4d01f1057b9543fa540f7bfcc5e3f8bd1748e652e24f9ea",
            },
        },
        macosx = {
            ["1.0.4"] = {
                url    = {
                    GLOBAL = "https://github.com/jeremy-rifkin/cpptrace/archive/refs/tags/v1.0.4.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/cpptrace/releases/download/1.0.4/cpptrace-1.0.4.tar.gz",
                },
                sha256 = "5c9f5b301e903714a4d01f1057b9543fa540f7bfcc5e3f8bd1748e652e24f9ea",
            },
        },
        windows = {
            ["1.0.4"] = {
                url    = {
                    GLOBAL = "https://github.com/jeremy-rifkin/cpptrace/archive/refs/tags/v1.0.4.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/cpptrace/releases/download/1.0.4/cpptrace-1.0.4.tar.gz",
                },
                sha256 = "5c9f5b301e903714a4d01f1057b9543fa540f7bfcc5e3f8bd1748e652e24f9ea",
            },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        c_standard   = "c11",

        -- `*/src` carries private headers the sources include as `utils/…`,
        -- `binary/…`; `mcpp_generated` carries the version header at the path
        -- `<cpptrace/version.hpp>` upstream's public headers open.
        include_dirs = { "*/include", "*/src", "mcpp_generated" },

        generated_files = {
            ["mcpp_generated/cpptrace/version.hpp"] = [==[
/* configure_file() of cmake/in/version-hpp.in for cpptrace 1.0.4. */
#ifndef CPPTRACE_VERSION_HPP
#define CPPTRACE_VERSION_HPP

#define CPPTRACE_VERSION_MAJOR 1
#define CPPTRACE_VERSION_MINOR 0
#define CPPTRACE_VERSION_PATCH 4

#define CPPTRACE_TO_VERSION(MAJOR, MINOR, PATCH) ((MAJOR) * 10000 + (MINOR) * 100 + (PATCH))
#define CPPTRACE_VERSION CPPTRACE_TO_VERSION(CPPTRACE_VERSION_MAJOR, CPPTRACE_VERSION_MINOR, CPPTRACE_VERSION_PATCH)

#endif
]==],
        },

        sources = { "*/src/**/*.cpp" },
        targets = { ["cpptrace"] = { kind = "lib" } },
        deps    = { },

        -- Interface-visible: see the header note. Not `cxxflags`.
        defines = { "CPPTRACE_STATIC_DEFINE" },

        linux = {
            cxxflags = {
                "-DCPPTRACE_UNWIND_WITH_UNWIND",
                "-DCPPTRACE_GET_SYMBOLS_WITH_LIBDL",
                "-DCPPTRACE_DEMANGLE_WITH_CXXABI",
            },
            -- dladdr lives in libdl on glibc.
            ldflags = { "-ldl" },
        },

        macosx = {
            cxxflags = {
                "-DCPPTRACE_UNWIND_WITH_UNWIND",
                "-DCPPTRACE_GET_SYMBOLS_WITH_LIBDL",
                "-DCPPTRACE_DEMANGLE_WITH_CXXABI",
            },
        },

        windows = {
            cxxflags = {
                "-DCPPTRACE_UNWIND_WITH_DBGHELP",
                "-DCPPTRACE_GET_SYMBOLS_WITH_DBGHELP",
                "-DCPPTRACE_DEMANGLE_WITH_WINAPI",
            },
            ldflags = { "-ldbghelp" },
        },
    },
}
