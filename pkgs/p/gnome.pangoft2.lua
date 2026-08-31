-- gnome.pangoft2 — the FreeType/fontconfig font backend.
--
-- `gnome.pango` knows nothing about how to find or rasterise a font. This is
-- the half that does, on Linux: fontconfig answers "which file", FreeType
-- answers "what do the glyphs look like".
--
-- ⚠️ IT ALSO CARRIES pango-ot.h, whose whole body sits behind
-- `#ifndef PANGO_DISABLE_DEPRECATED` and whose own header says "Deprecated.
-- Use HarfBuzz directly!". It is still compiled and still part of this
-- member's ABI, so it is still tested.--
-- ─────────────────────────────────────────────────────────────────────────
-- ⭐ TWO WAYS TO CONSUME IT, AND YOU PICK ONE
--
--     import gnome.pangoft2;
--     #include <pango/pangoft2.h>
--
-- The namespace is the contract in this index: `compat.xxx` means headers, an
-- owner namespace means the package exposes `import`. This module exports
-- 88 names and re-exports `gnome.pango`.
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
-- ⚠️ `gnome.pango` is a workspace PATH dependency of this package, so a
-- consumer must NOT name it as well. Same for `gnome.gio` behind it.
package = {
    spec        = "1",
    namespace   = "gnome",
    name        = "pangoft2",
    description = "PangoFT2 1.56.1 — pango's FreeType and fontconfig font backend",
    licenses    = {"LGPL-2.1-or-later"},
    repo        = "https://github.com/mcpplibs/pango",
    type        = "package",

    xpm = {
        linux = {
            ["1.56.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/pango/archive/refs/tags/1.56.1.tar.gz",
                    -- ⚠️ The container tag is `1.56.1-6`, not `1.56.1`. gitcode
                    -- refuses to REPLACE an asset of the same name in an
                    -- existing release, so each corrected tarball needs a new
                    -- container tag while the PACKAGE version stays upstream's.
                    -- Verified byte-identical to the GLOBAL tag archive.
                    CN     = "https://gitcode.com/mcpp-res/pango/releases/download/1.56.1-6/pango-1.56.1.tar.gz",
                },
                sha256 = "19507c6712304750a0e9cc282135dda1919a1b89c0c4ce61e22411df0532a980",
            },
        },
    },

    mcpp = "*/mcpp/pangoft2/mcpp.toml",
}
