-- Form B inline descriptor for {fmt} in its header form: consumers write
-- `#include <fmt/format.h>` and link, exactly as upstream's README shows.
--
-- This is the NON-module half of the pair. `pkgs/f/fmtlib.fmt.lua` is the
-- module sibling (`import fmt;`), and it is built from a rewritten
-- `src/fmt.cc`; the two carry deliberately separate identities under separate
-- namespaces because they are two ways to consume the same release. A consumer
-- picks one — a project that wants the `#include` spelling must not be forced
-- to take a module BMI it never imports, which is what a single identity
-- would do.
--
-- SHAPE: upstream's own default library, transcribed rather than wrapped.
-- `src/format.cc` is `format-inl.h` plus the explicit instantiations, and
-- `src/os.cc` is the OS layer (file / buffered_file / pipe / ostream /
-- getpagesize). Both are what CMake's default configure produces:
-- `add_library(fmt src/format.cc)` and, under the default `FMT_OS=ON`,
-- `target_sources(fmt PRIVATE src/os.cc)`. There is no generated_files and no
-- anchor TU here — unlike the module package, nothing has to be synthesized.
--
-- `src/fmt.cc` is NOT taken: it is upstream's C++20 module interface unit
-- (`export module fmt;`), i.e. the module build, covered by fmtlib.fmt.
--
-- `include_dirs = {"*/include"}` with the leading glob absorbing the archive's
-- `fmt-12.2.0/` wrap layer; the public headers live under `include/fmt/`, so
-- `{"*"}` would compile this package and still leave every consumer's
-- `#include <fmt/…>` unresolvable. The same mistake the compat.rapidcsv
-- descriptor is annotated against.
--
-- NO `defines`, and none are needed:
--   * `FMT_OS` is read by `src/fmt.cc` alone in this release — the headers no
--     longer consult it — so compiling os.cc unconditionally is the whole
--     story on both sides of the boundary.
--   * `FMT_SHARED` / `FMT_LIB_EXPORT` select a DLL's dllexport/dllimport
--     spelling in base.h and are only read on Win32 in a non-header-only
--     build. This target is a static lib in every consumer, so neither is
--     defined, and the plain `FMT_API` (empty) branch is the correct one.
--
-- MSVC AND `/utf-8` (a consumer-side fact, not this package's): upstream marks
-- `/utf-8` PUBLIC for MSVC because `chrono.h` carries a UTF-8 literal — the
-- micro sign in the sub-second unit string, line 581,
-- `detail::use_utf8 ? "<micro sign>s" : "us"`. That is the ONLY non-ASCII
-- byte sequence reachable from the library: this package's own three TUs
-- (format.cc, os.cc, fmt-c.cc) and every header they include — base.h,
-- format.h, format-inl.h — are pure ASCII, measured byte by byte. So the
-- library itself is unaffected by the source charset, and `cxxflags` could not
-- fix the consumer's copy anyway (it applies to this package's TUs only). A
-- consumer on MSVC that formats Unicode through fmt/chrono.h must pass
-- `/utf-8` itself, the same way tests/examples/openssl and openblas pass their
-- own consumer-side flags. A chrono test here would be asserting the member's
-- toolchain, not the package, so this member does not include that header.
--
-- NO CN mirror yet -- the url stays a plain string (the documented fallback
-- when there is no `mcpp-res` access, and the shape compat.rapidcsv / pybind11
-- / etl use). Adding the mirror later only rewrites `url` into
-- `{ GLOBAL = …, CN = … }`; the sha256 does not change, since the mirror
-- re-hosts the tag archive byte for byte.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "fmt",
    description = "A modern formatting library for C++ — header form (#include <fmt/format.h>)",
    licenses    = {"MIT"},
    repo        = "https://github.com/fmtlib/fmt",
    type        = "package",

    xpm = {
        linux = {
            ["12.2.0"] = {
                url    = "https://github.com/fmtlib/fmt/archive/refs/tags/12.2.0.tar.gz",
                sha256 = "8b852bb5aa6e7d8564f9e81394055395dd1d1936d38dfd3a17792a02bebd7af0",
            },
        },
        macosx = {
            ["12.2.0"] = {
                url    = "https://github.com/fmtlib/fmt/archive/refs/tags/12.2.0.tar.gz",
                sha256 = "8b852bb5aa6e7d8564f9e81394055395dd1d1936d38dfd3a17792a02bebd7af0",
            },
        },
        windows = {
            ["12.2.0"] = {
                url    = "https://github.com/fmtlib/fmt/archive/refs/tags/12.2.0.tar.gz",
                sha256 = "8b852bb5aa6e7d8564f9e81394055395dd1d1936d38dfd3a17792a02bebd7af0",
            },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        -- fmt-c.h's C face is `_Generic` plus compound literals: C11. Inert for
        -- this package's own TUs, which are all C++ (the compat.richdem shape).
        c_standard   = "c11",
        include_dirs = { "*/include" },
        sources      = { "*/src/format.cc", "*/src/os.cc" },
        targets      = { ["fmt"] = { kind = "lib" } },

        -- Upstream ships the C API as a SEPARATE library (`add_library(fmt-c
        -- STATIC src/fmt-c.cc)`, header include/fmt/fmt-c.h): one extra TU that
        -- the overwhelmingly common consumer — one that writes C++ and never
        -- touches fmt/fmt-c.h — should not pay for. That is exactly the
        -- "additional compilable source" the sources-only feature table is
        -- for (the compat.concurrentqueue `c-api` and compat.cjson `utils`
        -- precedent), and it is OFF by default. Requested as
        -- `fmt = { version = "12.2.0", features = ["c-api"] }`, it joins the
        -- same lib target.
        --
        -- The gate is real, measured, not assumed. With the feature off,
        -- tests/examples/fmt-c stops at LINK (Windows/LLVM wording):
        --     lld-link: error: undefined symbol: fmt_vformat
        --     lld-link: error: undefined symbol: fmt_vprint
        -- The fmt_arg constructors are `static inline` in the header, so the
        -- unresolved symbols can only be fmt-c.cc's; the package build reports
        -- 3 units with the feature and 2 without it. Transcript in
        -- .agents/docs/2026-10-15-add-compat-fmt-plan.md.
        --
        -- NOT covered here, deliberately: grep the tarball for another optional
        -- TU and there is none. fmt-header-only is a define-only INTERFACE
        -- target (FMT_HEADER_ONLY), and FMT_OS is not a source toggle either
        -- (the headers stopped reading it), so neither is expressible as a
        -- sources-only feature.
        features     = {
            ["c-api"] = { sources = { "*/src/fmt-c.cc" } },
        },
        deps         = { },
    },
}
