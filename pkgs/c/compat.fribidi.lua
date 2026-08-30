-- compat.fribidi — the Unicode bidirectional algorithm.
--
-- THE GATE ON pango. Arabic and Hebrew text is stored in logical order and
-- drawn in visual order, and working out which run goes which way is UAX #9 —
-- a specified algorithm with a conformance test suite, not something a text
-- layout engine reimplements. pango's meson makes it a hard dependency, so
-- nothing above it renders right-to-left text without this.
--
-- ─────────────────────────────────────────────────────────────────────────
-- WHY AN INLINE DESCRIPTOR AND NOT A FORK
--
-- fribidi generates seven tables from the Unicode Character Database, with
-- eight C programs under `gen.tab/` that are compiled and RUN during a normal
-- build. That is exactly the shape that forced forks for libevdev, libxkbcommon
-- and libdisplay-info — except that the RELEASE TARBALL SHIPS THE OUTPUT:
--
--     lib/arabic-misc.tab.i        lib/brackets-type.tab.i
--     lib/arabic-shaping.tab.i     lib/joining-type.tab.i
--     lib/bidi-type.tab.i          lib/mirroring.tab.i
--     lib/brackets.tab.i
--     lib/fribidi-unicode-version.h
--
-- Verified: the seven `#include "*.tab.i"` in `lib/*.c` are matched one for one
-- by files in the tarball, and `fribidi-unicode-version.h` — which meson also
-- generates — is there too. So there is nothing to generate and no fork to
-- justify. The criterion has always been "does something have to be RUN", and
-- here the answer is no.
--
-- Only `fribidi-config.h` is missing, because it is a `configure_file`
-- substitution rather than a generated table, and every value in it is a
-- property of this build. It is written out below.
--
-- ─────────────────────────────────────────────────────────────────────────
-- kind = "lib", NOT "shared"
--
-- Upstream ships libfribidi.so.0. Nothing dlopens it — pango links it at build
-- time — so merging the objects avoids a SONAME that would then have to coexist
-- with a distribution's copy. Same choice as freedesktop.libdisplay-info,
-- freedesktop.libevdev and wlroots, and for the same reason.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "fribidi",
    description = "GNU FriBidi 1.0.16 — the Unicode bidirectional algorithm (UAX #9), the dependency pango needs for right-to-left text",
    licenses    = {"LGPL-2.1-or-later"},
    repo        = "https://github.com/fribidi/fribidi",
    type        = "package",

    xpm = {
        linux = {
            ["1.0.16"] = {
                url = {
                    GLOBAL = "https://github.com/fribidi/fribidi/releases/download/v1.0.16/fribidi-1.0.16.tar.xz",
                    CN     = "https://gitcode.com/mcpp-res/fribidi/releases/download/1.0.16/fribidi-1.0.16.tar.xz",
                },
                sha256 = "1b1cde5b235d40479e91be2f0e88a309e3214c8ab470ec8a2744d82a5a9ea05c",
            },
        },
    },

    mcpp = {
        language   = "c++23",
        import_std = false,
        c_standard = "c11",

        -- `*/lib` carries both the public headers and the seven `.tab.i`
        -- tables, which the sources include by bare name.
        include_dirs = { "mcpp_generated", "*/lib", "*" },

        generated_files = {
            -- meson's `configure_file` output. Upstream's template
            -- (lib/fribidi-config.h.in) substitutes ten placeholders; nine are
            -- constants of this release and the tenth is sizeof(int).
            ["mcpp_generated/fribidi-config.h"] = [[
/* compat.fribidi: meson's configure_file output for lib/fribidi-config.h.in,
   written out because every substitution is a constant of this release or a
   property of the target. */
#ifndef FRIBIDI_CONFIG_H
#define FRIBIDI_CONFIG_H

#define FRIBIDI "fribidi"
#define FRIBIDI_NAME "GNU FriBidi"
#define FRIBIDI_BUGREPORT "https://github.com/fribidi/fribidi/issues/new"

#define FRIBIDI_VERSION "1.0.16"
#define FRIBIDI_MAJOR_VERSION 1
#define FRIBIDI_MINOR_VERSION 0
#define FRIBIDI_MICRO_VERSION 16

/* meson.build:16 — bumped by upstream when the ABI changes, and reported
   through fribidi_version_info. Not derived from the release number. */
#define FRIBIDI_INTERFACE_VERSION 4
#define FRIBIDI_INTERFACE_VERSION_STRING "4"

/* Every target this index builds for is ILP32-or-LP64 with a 32-bit int.
   fribidi uses it only to size FriBidiLevel arithmetic. */
#define FRIBIDI_SIZEOF_INT 4

/* @FRIBIDI_MSVC_BUILD_PLACEHOLDER@ expands to nothing on a non-MSVC build,
   which is what it is doing here by being absent. */

#endif /* FRIBIDI_CONFIG_H */
]],

            -- The autotools-style probe answers. fribidi reads five of these
            -- and every one is `#ifdef`-tested, so "defined" is the whole
            -- statement and the value is decoration.
            ["mcpp_generated/config.h"] = [[
#ifndef MCPP_FRIBIDI_CONFIG_H
#define MCPP_FRIBIDI_CONFIG_H

/* HAVE_FRIBIDI_CONFIG_H makes fribidi-common.h include the header above
   instead of falling back to its built-in defaults — which are for a
   hand-built copy and get the version wrong. */
#define HAVE_FRIBIDI_CONFIG_H 1

/* HAVE_STRINGIZE says the preprocessor supports `#x`, which every C99
   compiler does. Without it fribidi-common.h takes a K&R path. */
#define HAVE_STRINGIZE 1

#define HAVE_STDLIB_H 1
#define HAVE_STRING_H 1
#define HAVE_STRINGS_H 1
#define HAVE_MEMORY_H 1
#define SIZEOF_INT 4

/* HAVE_FRIBIDI_CUSTOM_H and HAVE_FRIBIDI_UNICODE_VERSION_H are
   DELIBERATELY ABSENT rather than 0.
   - fribidi_custom.h does not exist here (it is a downstream hook), and
     `#ifdef HAVE_FRIBIDI_CUSTOM_H` would then include a missing file.
   - fribidi-unicode-version.h DOES exist in the tarball, but the macro that
     guards it is only consulted on the autotools path; the meson path — the
     one whose file layout this package reproduces — includes it directly. */

#endif
]],
        },

        -- lib/*.c, all eighteen. There is nothing to exclude: the charset
        -- converters (cp1255, cp1256, iso8859-6/8, cap-rtl) are part of the
        -- library upstream ships, `fribidi-deprecated.c` keeps the ABI, and
        -- the `bin/` programs (fribidi_benchmark, the CLI) are not here for
        -- the usual reason — a dependency that provides `main` collides with
        -- the consumer's.
        sources = { "*/lib/*.c" },

        cflags = {
            "-DHAVE_CONFIG_H",
            "-D_GNU_SOURCE",
            -- Upstream's own, from lib/meson.build: without it every public
            -- symbol would be hidden and pango would fail to link.
            "-DFRIBIDI_BUILD",
            -- pango is linked into shared objects, so the objects must be
            -- position independent.
            "-fPIC",
        },

        targets = { fribidi = { kind = "lib" } },
    },
}
