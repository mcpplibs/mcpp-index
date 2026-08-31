-- gnome.pangocairo — the cairo backend, and the usual entry point.
--
-- Almost every consumer reaches pango through this member:
-- `pango_cairo_create_layout(cr)` then `pango_cairo_show_layout(cr, layout)`
-- is the whole API most programs need.
--
-- ⚠️ IT DEPENDS ON pangoft2, NOT JUST cairo. Upstream compiles
-- `pangocairo-fcfont.c` and `pangocairo-fcfontmap.c` whenever the freetype
-- backend is enabled (meson.build:489) — they are what let a cairo surface
-- draw a fontconfig-selected font, which on Linux is every font.
--
-- ─────────────────────────────────────────────────────────────────────────
-- ⚠️ A SILENT DEGRADATION WORTH KNOWING ABOUT
--
-- `HAVE_CAIRO_FREETYPE` was dropped from config.h once by an editing slip.
-- NOTHING FAILED TO BUILD. `pangocairo-fontmap.c` simply registered no
-- backends, and the program died at run time with
--
--     Pango-CRITICAL: Unknown $PANGOCAIRO_BACKEND value.
--       Available backends are:          <- an empty list
--
-- then segfaulted. The fork's test now reads the font map's FONT TYPE and
-- requires `CAIRO_FONT_TYPE_FT`, which catches it immediately.
--
-- ⚠️ AND freedesktop.cairo's MODULE IS NOT SUFFICIENT ON ITS OWN. Measured on
-- 1.18.2: 470 names, ZERO enumerators (no `CAIRO_FORMAT_ARGB32`, no
-- `CAIRO_FONT_TYPE_FT`) and no `cairo_t`. The index's own cairo example does
-- not notice, because it writes BOTH `#include <cairo.h>` and
-- `import freedesktop.cairo;`. pangocairo cannot mix the routes, so its module
-- scans cairo.h itself; that can go when cairo's wrapper is fixed.--
-- ─────────────────────────────────────────────────────────────────────────
-- ⭐ TWO WAYS TO CONSUME IT, AND YOU PICK ONE
--
--     import gnome.pangocairo;
--     #include <pango/pangocairo.h>
--
-- The namespace is the contract in this index: `compat.xxx` means headers, an
-- owner namespace means the package exposes `import`. This module exports
-- 284 names and re-exports `gnome.pango`,
-- `gnome.pangoft2` and `freedesktop.cairo`.
--
-- ⚠️ THE TWO ROUTES DO NOT COMPOSE. A TU that does both reaches <stdio.h>
-- twice — once through the module's global fragment, once directly — and the
-- same `struct _IO_FILE` becomes two entities. Which route to take is decided
-- by macros, which a module cannot carry: code using `PANGO_TYPE_*` or
-- `G_OBJECT` takes the header route, code using the function API imports and
-- includes nothing. Each member ships a test for each route.
--
-- ─────────────────────────────────────────────────────────────────────────
-- WHY A FORK: GENERATORS, NOT LINE COUNT
--
-- The criterion that made cairo (104k lines) a plain descriptor and
-- libdisplay-info (2k) a fork. Pango has three, and the fork adds a fourth:
--
--     configure_file         pango-features.h.meson -> pango-features.h
--     configure_file         (NO input template)    -> config.h
--     gobject/glib-mkenums   pango_headers          -> pango-enum-types.{h,c}
--     (the fork's own)       gen_module()           -> the .cppm wrapper
--
-- ⚠️ config.h is the odd one: upstream writes
-- `configure_file(output: 'config.h', configuration: pango_conf)` with NO
-- `input:`, so meson emits a `#define` per key and there is nothing in the
-- tree to substitute into. The file is WRITTEN, and every value in it is a
-- decision. Two are arithmetic — `PANGO_BINARY_AGE = minor*100 + micro` and
-- `PANGO_INTERFACE_AGE = minor odd ? 0 : micro` — and `pango_version_check()`
-- reads the first, so a wrong value makes a correct version comparison answer
-- wrongly AT RUN TIME rather than failing to build.
--
-- https://github.com/mcpplibs/pango
--
-- ─────────────────────────────────────────────────────────────────────────
-- LINUX ONLY. The generated config.h fixes the visibility attribute and the
-- font backend, and pangoxft (the X11 backend) is deliberately not built —
-- Xft is not in this index and a Wayland stack does not want it.
--
-- ⚠️ `gnome.pango` and `gnome.pangoft2` are workspace PATH dependencies of
-- this package, so a consumer must NOT name them as well. Naming
-- `gnome.pangocairo` alone gets the whole stack.
package = {
    spec        = "1",
    namespace   = "gnome",
    name        = "pangocairo",
    description = "PangoCairo 1.56.1 — pango's cairo rendering backend, the usual entry point",
    licenses    = {"LGPL-2.1-or-later"},
    repo        = "https://github.com/mcpplibs/pango",
    type        = "package",

    xpm = {
        linux = {
            ["1.56.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/pango/archive/refs/tags/1.56.1.tar.gz",
                    -- ⚠️ The container tag is `1.56.1-4`, not `1.56.1`. gitcode
                    -- refuses to REPLACE an asset of the same name in an
                    -- existing release, so each corrected tarball needs a new
                    -- container tag while the PACKAGE version stays upstream's.
                    -- Verified byte-identical to the GLOBAL tag archive.
                    CN     = "https://gitcode.com/mcpp-res/pango/releases/download/1.56.1-4/pango-1.56.1.tar.gz",
                },
                sha256 = "b470a658e05ef0e14d779bc852371ce52dd11efa76d10782347be40f1d63476b",
            },
        },
    },

    mcpp = "*/mcpp/pangocairo/mcpp.toml",
}
