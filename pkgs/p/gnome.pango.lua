-- gnome.pango — international text layout.
--
-- Itemisation, the bidirectional algorithm, line breaking, markup and layout.
-- It knows about scripts and fonts and NOTHING about rasterising: that is
-- `gnome.pangoft2`, and drawing is `gnome.pangocairo`. Upstream ships them as
-- three shared libraries and this index follows that split, because it is what
-- a consumer links.
--
-- ─────────────────────────────────────────────────────────────────────────
-- ⭐ THIS IS THE PACKAGE THAT WAS BLOCKED ON gio
--
-- `PangoFontMap` declares
--
--     G_IMPLEMENT_INTERFACE (G_TYPE_LIST_MODEL, pango_font_map_list_model_init)
--
-- so the type cannot even REGISTER without gio's interface. The index recorded
-- that gap for a while under a reason that turned out to be wrong — see
-- `gnome.gio` for what the reason was and why it did not follow.--
-- ─────────────────────────────────────────────────────────────────────────
-- ⭐ TWO WAYS TO CONSUME IT, AND YOU PICK ONE
--
--     import gnome.pango;
--     #include <pango/pango.h>
--
-- The namespace is the contract in this index: `compat.xxx` means headers, an
-- owner namespace means the package exposes `import`. This module exports
-- 851 names and re-exports `gnome.gio`, because pango.h
-- includes glib-object.h and a consumer cannot name gio itself — it is a
-- workspace path dependency.
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
-- ⚠️ NAME gio ALONE if you also want it. glib, gobject and gmodule are
-- workspace PATH dependencies of `gnome.gio`, and mcpp rejects a package
-- requested both ways:
--
--     error: dependency 'gnome.gobject' is requested as both a version dep
--            (by 'pango') and a path dep (by 'gnome.gio@2.82.5'). Pick one.
--
-- That error is how this fork learned it, on the first build.
package = {
    spec        = "1",
    namespace   = "gnome",
    name        = "pango",
    description = "Pango 1.56.1 — international text layout: itemisation, shaping, bidi and line breaking",
    licenses    = {"LGPL-2.1-or-later"},
    repo        = "https://github.com/mcpplibs/pango",
    type        = "package",

    xpm = {
        linux = {
            ["1.56.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/pango/archive/refs/tags/1.56.1.tar.gz",
                    -- ⚠️ The container tag is `1.56.1-8`, not `1.56.1`. gitcode
                    -- refuses to REPLACE an asset of the same name in an
                    -- existing release, so each corrected tarball needs a new
                    -- container tag while the PACKAGE version stays upstream's.
                    -- Verified byte-identical to the GLOBAL tag archive.
                    CN     = "https://gitcode.com/mcpp-res/pango/releases/download/1.56.1-8/pango-1.56.1.tar.gz",
                },
                sha256 = "e9a1c28defa0e21a85eac3e0b4301c340a2ffc26592bd74d479fcd8af77e90b5",
            },
        },
    },

    mcpp = "*/mcpp/pango/mcpp.toml",
}
