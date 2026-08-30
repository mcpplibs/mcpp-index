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
-- The fork pins hwdata v0.410, checks the input in beside the output, and its
-- CI regenerates and diffs. Same arrangement as freedesktop.libevdev with
-- upstream's bundled kernel headers.
--
-- NO MODULE WRAPPER, deliberately: this library's consumer is wlroots, which is
-- C, and the surface is 74 functions over ~360 structs. The design doc's rule
-- applies — the module layer is a RESULT of forking, not a reason to fork.
--
-- ⚠ C++ CONSUMERS MUST WRAP THE INCLUDES. Not one of the seven public headers
-- has an `extern "C"` block, so a C++ TU mangles every declaration and the link
-- fails with `undefined reference to di_info_get_make(di_info const*)` — naming
-- a symbol that is right there. Same as compat.libseat.
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
                    GLOBAL = "https://github.com/mcpplibs/libdisplay-info/releases/download/v0.2.0/libdisplay-info-0.2.0-mcpp.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/libdisplay-info/releases/download/0.2.0/libdisplay-info-0.2.0-mcpp.tar.gz",
                },
                sha256 = "df065a6e040799536a6c93a0202f2766b8c3388b546d0ba4a43290a89aa33ccc",
            },
        },
    },

    mcpp = "*/mcpp/displayinfo/mcpp.toml",
}
