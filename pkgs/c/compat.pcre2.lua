-- compat.pcre2 — Perl-compatible regular expressions, second edition.
--
-- THE GATE ON glib. `glib/gregex.c` is written against pcre2's 8-bit API and
-- glib's meson makes it a hard dependency (`libpcre2-8`, required: true), so
-- nothing in the GLib/GObject/Pango stack can be built without it.
--
-- ─────────────────────────────────────────────────────────────────────────
-- WHY AN INLINE DESCRIPTOR AND NOT A FORK
--
-- The criterion in this index is GENERATORS, not line count — 133k lines here
-- against cairo's 104k, and cairo needed no fork either. pcre2 has three
-- generated inputs and the release tarball SHIPS ALL THREE, which is
-- deliberate on upstream's part: they exist so a build without autotools or
-- CMake is possible.
--
--     src/pcre2.h.generic            the public header
--     src/config.h.generic           the probe answers
--     src/pcre2_chartables.c.dist    the default character tables
--
-- The last one is the interesting case. Upstream normally builds a
-- `pcre2_dftables` program and RUNS IT to emit `pcre2_chartables.c` from the
-- build machine's C library locale — the same build-machine-dependence that
-- made libdisplay-info and wlroots pin their `pnp.ids`. `.dist` is the C-locale
-- output, checked in by upstream precisely so a build need not run a program to
-- get a deterministic answer. Using it is both simpler AND more reproducible.
--
-- ⚠️ pcre2.h AND config.h ARE WRITTEN OUT HERE rather than copied from the
-- `.generic` files, because both encode choices this package is making:
-- SUPPORT_UNICODE and the code-unit width are not properties of pcre2, they
-- are properties of the library this index wants glib to link.
--
-- ─────────────────────────────────────────────────────────────────────────
-- ONE CODE-UNIT WIDTH, AND WHY THAT IS NOT A LIMITATION
--
-- pcre2 compiles the SAME sources once per code-unit width, with every public
-- symbol renamed by `PCRE2_SUFFIX` — so libpcre2-8, -16 and -32 are three
-- libraries with disjoint symbol sets built from one directory. Building all
-- three would triple the object count for consumers that want one.
--
-- 8 is the width glib uses, and it is the width UTF-8 needs. A consumer that
-- wanted 16- or 32-bit would need its own package, not a feature here: the
-- symbol names differ, so the two cannot coexist in one target anyway.
--
-- ⚠️ `PCRE2_CODE_UNIT_WIDTH` must ALSO be defined by the consumer before
-- `#include <pcre2.h>`, because the header uses it to pick which set of
-- declarations to expose. Omitting it is a compile error that says so:
--     "PCRE2_CODE_UNIT_WIDTH must be defined before including pcre2.h"
-- glib does this itself (`#define PCRE2_CODE_UNIT_WIDTH 8` in gregex.c), so
-- nothing extra is needed for the stack this package exists for.
--
-- ─────────────────────────────────────────────────────────────────────────
-- JIT IS OFF
--
-- `pcre2_jit_compile.c` IS compiled — it has to be, because
-- `pcre2_jit_compile()` and friends are part of the API and must exist as
-- symbols — but without SUPPORT_JIT they are stubs that return
-- PCRE2_ERROR_JIT_BADOPTION. That is upstream's own arrangement, not a
-- mutilation: `pcre2_config(PCRE2_CONFIG_JIT)` reports 0 and every caller that
-- checks (glib does) takes the interpreter path.
--
-- The reason to leave it off is that the JIT is a per-architecture assembler
-- (sljit) with its own execution-memory allocator, and enabling it on a target
-- this index has not tested would trade a working regex engine for a possible
-- SIGSEGV. It can be turned on later by one line, once there is a test that
-- would notice.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "pcre2",
    description = "PCRE2 10.44 — 8-bit Perl-compatible regular expressions with Unicode properties, the dependency glib's GRegex is written against",
    licenses    = {"BSD-3-Clause"},
    repo        = "https://github.com/PCRE2Project/pcre2",
    type        = "package",

    xpm = {
        linux = {
            ["10.44"] = {
                url = {
                    GLOBAL = "https://github.com/PCRE2Project/pcre2/releases/download/pcre2-10.44/pcre2-10.44.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/pcre2/releases/download/10.44/pcre2-10.44.tar.gz",
                },
                sha256 = "86b9cb0aa3bcb7994faa88018292bc704cdbb708e785f7c74352ff6ea7d3175b",
            },
        },
    },

    mcpp = {
        language   = "c++23",
        import_std = false,
        c_standard = "c11",

        -- `*` is the extract directory. `*/src` puts `pcre2_chartables.c.dist`
        -- and the internal headers on the path; `mcpp_generated` carries the
        -- two headers written below, and comes FIRST so `pcre2.h` resolves to
        -- ours rather than to any host copy.
        include_dirs = { "mcpp_generated", "*/src", "*" },

        generated_files = {
            -- The public header. Upstream's `pcre2.h.in` is a template whose
            -- only substitutions are the version numbers and, in the `.generic`
            -- form, nothing else — so this is that file's content with the
            -- three version macros filled in.
            --
            -- Rather than reproduce 700 lines of declarations, this includes
            -- the `.generic` copy upstream ships and supplies only what the
            -- template would have substituted. `#include` does not care about
            -- the file extension.
            ["mcpp_generated/pcre2.h"] = [[
#ifndef MCPP_PCRE2_H
#define MCPP_PCRE2_H
/* compat.pcre2: upstream's own pre-substituted public header.
 *
 * pcre2.h.generic is what upstream ships for builds that do not run configure,
 * and it is byte-identical to what autotools would produce for this version —
 * the only substitutions in pcre2.h.in are the three version numbers, and the
 * .generic copy already has them. Including it rather than copying it means a
 * version bump cannot leave a stale duplicate behind. */
#include "pcre2.h.generic"
#endif
]],

            -- The probe answers. Every one describes THIS package's build, not
            -- pcre2's defaults — the distinction that turned eight undefined
            -- references into an afternoon on fontconfig.
            ["mcpp_generated/config.h"] = [[
#ifndef MCPP_PCRE2_CONFIG_H
#define MCPP_PCRE2_CONFIG_H

/* ── what this build supports ─────────────────────────────────────────── */

/* SUPPORT_UNICODE brings in pcre2_ucd.c's property tables (about 100 KB) and
 * makes \p{...}, \X and PCRE2_UTF work. glib's GRegex exposes all three
 * through its own API, so this is not optional for the stack this package
 * exists for. */
#define SUPPORT_UNICODE 1

/* SUPPORT_JIT is DELIBERATELY ABSENT rather than 0.
 *
 * pcre2 tests it with `#ifdef SUPPORT_JIT` (pcre2_jit_compile.c:60 and
 * pcre2_internal.h), so `#define SUPPORT_JIT 0` would say YES — the same trap
 * that cost cairo an hour of silently-empty drawing. Absent means absent.
 *
 * pcre2_jit_compile.c is still COMPILED; without this macro it provides the
 * public JIT entry points as stubs returning PCRE2_ERROR_JIT_BADOPTION, which
 * is upstream's arrangement and what pcre2_config(PCRE2_CONFIG_JIT) reports. */

/* Same rule: these are all `#ifdef`-tested and so are left undefined.
 *   SUPPORT_PCRE2GREP_JIT, SUPPORT_PCRE2GREP_CALLOUT  — pcre2grep only
 *   SUPPORT_LIBBZ2, SUPPORT_LIBZ, SUPPORT_LIBEDIT,
 *   SUPPORT_LIBREADLINE                               — pcre2grep/pcre2test only
 *   EBCDIC, EBCDIC_NL25                               — not this century
 *   NEVER_BACKSLASH_C, PCRE2_DEBUG                    — behaviour changes
 *   SUPPORT_VALGRIND                                  — instrumentation
 */

/* ── the numeric limits, upstream's own defaults ──────────────────────── */
/* Not tuned: these are the values every distribution ships, and a consumer
 * that needs different ones sets them per-match through the match context. */
#define HEAP_LIMIT 20000000
#define LINK_SIZE 2
#define MATCH_LIMIT 10000000
#define MATCH_LIMIT_DEPTH MATCH_LIMIT
#define MAX_NAME_COUNT 10000
#define MAX_NAME_SIZE 32
#define MAX_VARLOOKBEHIND 255
#define PARENS_NEST_LIMIT 250
#define NEWLINE_DEFAULT 2   /* LF — the Unix convention, and glib's assumption */

/* ── the C library ────────────────────────────────────────────────────── */
/* glibc and any musl this index would target have had all of these for
 * decades. They are `#ifdef`-tested, so defining them to 1 and defining them
 * at all are the same statement. */
#define HAVE_ATTRIBUTE_UNINITIALIZED 1
#define HAVE_BUILTIN_MUL_OVERFLOW 1
#define HAVE_DIRENT_H 1
#define HAVE_INTTYPES_H 1
#define HAVE_LIMITS_H 1
#define HAVE_MEMFD_CREATE 1
#define HAVE_MEMMOVE 1
#define HAVE_MKOSTEMP 1
#define HAVE_SECURE_GETENV 1
#define HAVE_STDINT_H 1
#define HAVE_STDLIB_H 1
#define HAVE_STRERROR 1
#define HAVE_STRING_H 1
#define HAVE_STRINGS_H 1
#define HAVE_SYS_STAT_H 1
#define HAVE_SYS_TYPES_H 1
#define HAVE_SYS_WAIT_H 1
#define HAVE_UNISTD_H 1

/* Identification, used by pcre2_config(PCRE2_CONFIG_VERSION) and in error
 * text. Kept exactly in step with the tarball this descriptor names. */
#define PACKAGE "pcre2"
#define PACKAGE_NAME "PCRE2"
#define PACKAGE_STRING "PCRE2 10.44"
#define PACKAGE_TARNAME "pcre2"
#define PACKAGE_VERSION "10.44"
#define VERSION "10.44"

/* ── the export decoration ────────────────────────────────────────────── */

/* PCRE2_EXPORT must be DEFINED, and empty is the right value.
 *
 * pcre2_internal.h:150 builds the declaration specifier out of it —
 * `#define PCRE2_EXP_DECL extern PCRE2_EXPORT` — so leaving it out does not
 * mean "no decoration", it means the token survives into the source and every
 * exported declaration becomes a syntax error:
 *
 *     pcre2.h.generic:800: error: expected ';' before 'const'
 *       PCRE2_EXP_DECL const uint8_t *PCRE2_CALL_CONVENTION
 *
 * — reported against pcre2's own header, which reads like a broken tarball.
 * Empty is what upstream's config.h.generic uses on Unix: the objects merge
 * into the consumer (kind = "lib"), so there is no shared-library boundary to
 * decorate and default visibility is correct.
 *
 * PCRE2_EXP_DEFN and PCRE2_STATIC stay undefined for the same reason
 * config.h.generic leaves them undefined on Unix: both are Windows or
 * special-environment hooks, and pcre2_internal.h derives PCRE2_EXP_DEFN from
 * PCRE2_EXP_DECL when it is absent. */
#define PCRE2_EXPORT

#endif
]],

            -- The default character tables. Upstream builds and RUNS
            -- `pcre2_dftables` to produce this file from the build machine's
            -- locale; `.dist` is the C-locale output they ship so that nobody
            -- has to. Including it keeps the answer independent of where the
            -- package was built — the same reasoning that pins `pnp.ids` in
            -- freedesktop.libdisplay-info and wlroots.
            ["mcpp_generated/pcre2_chartables.c"] = [[
/* compat.pcre2: upstream's C-locale default tables, compiled as-is.
 *
 * Upstream's normal path compiles `pcre2_dftables` and runs it against the
 * BUILD MACHINE's locale, so `isalpha()` in a Turkish locale would produce a
 * different table than in C. `.dist` is the C-locale answer, checked in by
 * upstream for exactly this reason.
 *
 * Found through the "*"-glob src directory on the include path; #include does
 * not care about the file extension. */
#include "pcre2_chartables.c.dist"
]],
        },

        -- Upstream's CMakeLists PCRE2_SOURCES, in order, minus
        -- `pcre2_chartables.c` (generated above). The programs — pcre2test,
        -- pcre2grep, pcre2demo, the fuzzer, the JIT test — are not here: they
        -- have their own `main`, and a dependency that provides one collides
        -- with the consumer's (this index has measured that).
        --
        -- `pcre2posix.c` is also absent. It is a separate library upstream
        -- (libpcre2-posix) whose symbols are regcomp/regexec — names glibc
        -- already defines — so merging it into a consumer would be a
        -- duplicate-symbol trap for a POSIX API nothing here asks for.
        sources = {
            "*/src/pcre2_auto_possess.c",
            "mcpp_generated/pcre2_chartables.c",
            "*/src/pcre2_chkdint.c",
            "*/src/pcre2_compile.c",
            "*/src/pcre2_config.c",
            "*/src/pcre2_context.c",
            "*/src/pcre2_convert.c",
            "*/src/pcre2_dfa_match.c",
            "*/src/pcre2_error.c",
            "*/src/pcre2_extuni.c",
            "*/src/pcre2_find_bracket.c",
            "*/src/pcre2_jit_compile.c",
            "*/src/pcre2_maketables.c",
            "*/src/pcre2_match.c",
            "*/src/pcre2_match_data.c",
            "*/src/pcre2_newline.c",
            "*/src/pcre2_ord2utf.c",
            "*/src/pcre2_pattern_info.c",
            "*/src/pcre2_script_run.c",
            "*/src/pcre2_serialize.c",
            "*/src/pcre2_string_utils.c",
            "*/src/pcre2_study.c",
            "*/src/pcre2_substitute.c",
            "*/src/pcre2_substring.c",
            "*/src/pcre2_tables.c",
            "*/src/pcre2_ucd.c",
            "*/src/pcre2_valid_utf.c",
            "*/src/pcre2_xclass.c",
        },

        -- `-DPCRE2_CODE_UNIT_WIDTH=8` is what selects the library being built;
        -- every source reads it. `-DHAVE_CONFIG_H` makes them include the
        -- config.h above. `-fPIC` because glib is linked into shared objects
        -- and a non-PIC object cannot be.
        cflags = {
            "-DHAVE_CONFIG_H",
            "-DPCRE2_CODE_UNIT_WIDTH=8",
            "-D_GNU_SOURCE",
            "-fPIC",
        },

        targets = { ["pcre2-8"] = { kind = "lib" } },
    },
}
