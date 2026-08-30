-- freedesktop.libdisplay-info — EDID and DisplayID parsing, and the gate on
-- wlroots.
--
-- A monitor describes itself in a 128-byte EDID blob the kernel exposes through
-- DRM. Parsing it by hand is a known trap — decades of vendor quirks — so
-- wlroots, mutter and KWin all use this library for a display's make, model,
-- serial and mode list.
--
-- WHY THIS ONE MATTERS MORE THAN ITS SIZE SUGGESTS. Read from wlroots 0.18.2's
-- own meson: `backend/drm/meson.build` declares `libdisplay-info` with
-- `required: 'drm' in backends`, and the DRM backend is what a compositor on
-- real hardware uses. With this package everything wlroots needs is in the
-- index — wayland-server/client/protocols/scanner/egl, libdrm, pixman,
-- xkbcommon, libinput, libudev, libseat, egl, glesv2, gbm — so wlroots becomes
-- a question of whether to package it rather than whether it can be packaged.
--
-- ─────────────────────────────────────────────────────────────────────────
-- FORM B, AND THE INPUT IS PINNED
--
-- `pnp-id-table.c` is generated — 2,583 lines mapping every PNP vendor ID to a
-- manufacturer name. Upstream's meson looks for hwdata and, not finding it,
-- falls back to the BUILD MACHINE's `/usr/share/hwdata/pnp.ids`. Measured on
-- 2026-08-30: the host's file and hwdata v0.410's differ by 35 lines, and the
-- tables generated from them by 15 (2568 vs 2583) — so an unpinned build makes
-- `di_info_get_make` answer differently depending on where it was compiled.
--
-- The fork pins hwdata v0.410 and checks it in as an INPUT. There is no
-- checked-in output and no regenerate-and-diff CI step, because there is
-- nothing to keep honest: `build.mcpp` PRODUCES the table during the build.
--
-- NOTHING IN THIS PACKAGE NEEDS python3, sh OR ANY OTHER TOOL. `build.mcpp` is
-- C++ that mcpp compiles and runs, and it does every generated artifact:
--
--     pnp-id-table.c            2,583 lines, into the out dir
--     src/libdisplay-info.cppm  the module wrapper, 206 names
--
-- IT IS ALSO MORE CORRECT THAN UPSTREAM'S GENERATOR. pnp.ids stores
-- `DemoPad<U+00A0>Software<U+00A0>Ltd`, and U+00A0 is the two bytes c2 a0.
-- Upstream reads the file as TEXT and escapes the codepoint by ordinal —
-- `\240`, a single byte that is not its UTF-8 encoding, so the string a
-- consumer prints is invalid UTF-8. build.mcpp escapes BYTES. Diffed over the
-- whole file: 2,583 lines, identical except for the handful of non-ASCII names,
-- where this one is right.
--
-- THE MODULE IS GENERATED, not hand-written: 206 names read out of the public
-- headers, so a version bump cannot silently drop one.
--
--     import freedesktop.displayinfo;
--
-- and that also removes a real burden — not one of the seven public headers has
-- an `extern "C"` block, so a C++ TU that #includes them mangles every
-- declaration and fails to link with `undefined reference to
-- di_info_get_make(di_info const*)`. The module does that wrapping once, inside
-- the module purview, so a consumer does not. (compat.libseat has the same
-- upstream problem and no module, so there the consumer still wraps.)
package = {
    spec        = "1",
    namespace   = "freedesktop",
    name        = "libdisplay-info",
    description = "libdisplay-info 0.2.0 — EDID and DisplayID parsing, with the PNP vendor table pre-generated from a pinned hwdata",
    licenses    = {"MIT"},
    repo        = "https://github.com/mcpplibs/libdisplay-info",
    type        = "package",

    xpm = {
        linux = {
            ["0.2.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/libdisplay-info/releases/download/v0.2.0/libdisplay-info-0.2.0-mcpp2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/libdisplay-info/releases/download/0.2.0/libdisplay-info-0.2.0-mcpp2.tar.gz",
                },
                sha256 = "8df9a8064146b2b38378bd8b146894d084ffda43b88b43c485b954da073a7617",
            },
        },
    },

    mcpp = "*/mcpp/displayinfo/mcpp.toml",
}
