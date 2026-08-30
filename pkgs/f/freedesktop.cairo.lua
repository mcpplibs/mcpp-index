-- freedesktop.cairo — 2D vector drawing.
--
-- Paths, strokes, fills, text runs, and surfaces to put them on. A compositor
-- that only composites does not need it; a desktop SHELL — panel, launcher,
-- notification — draws through it, and pango renders text through it.
--
-- ─────────────────────────────────────────────────────────────────────────
-- EASIER THAN ITS SIZE SUGGESTS, AND THAT CORRECTS A JUDGEMENT
--
-- 104k lines of C and NO CODE GENERATION AT ALL: upstream's meson emits exactly
-- two artifacts, `config.h` and `cairo-features.h`, and both are
-- `configure_file` — probe answers, not generated code. fontconfig is a
-- quarter the size and needed seven generators.
--
-- The design doc had cairo listed as the larger job on line count alone. It was
-- wrong: FORK DIFFICULTY IS DECIDED BY GENERATORS, NOT BY LINES.
--
-- ─────────────────────────────────────────────────────────────────────────
-- THE BACKENDS ARE FEATURES, AND X11 IS OFF BY DEFAULT
--
--     default = ["ft", "fc", "png"]
--
-- Upstream makes each backend a `get_option()`, which lets a distribution
-- decide once for everyone. An index cannot: a Wayland compositor and an X11
-- application want different cairos out of the same package. So someone drawing
-- a circle in a Wayland program does not acquire libX11 to do it, and someone
-- who wants X11 writes
--
--     cairo = { version = "1.18.2", features = ["xlib"] }
--
-- The fork's CI checks that on the ARTIFACT, not on the manifest: no
-- `cairo-xlib-*.o`, and no `XOpenDisplay` in any object.
--
-- ─────────────────────────────────────────────────────────────────────────
-- THE ARCHIVE IS THE SOURCE, NOT THE TEST SUITE
--
-- cairo's release carries 61 MB of reference images under `test/`, none of
-- which this package compiles. Published whole it was a 47 MB download for
-- 6 MB of source; `test/` and `perf/` are removed and the fork's
-- "upstream is unmodified" check compares the remaining tree, so every file a
-- build can reach is still diffed. 47.8 MB -> 1.8 MB.
--
-- ⚠ ONE PROBE ANSWER IS WORTH KNOWING BEFORE SOMEONE "FIXES" IT.
-- `WORDS_BIGENDIAN` and `FLOAT_WORDS_BIGENDIAN` are ABSENT from config.h, not
-- defined to 0 — cairo tests them with `#ifdef` (cairoint.h:196), so a 0 says
-- BIG-ENDIAN. On x86-64 that compiles, links, reports success, keeps
-- `cairo_paint` working, and gives every PATH garbage fixed-point coordinates:
-- `cairo_rectangle(4,4,16,16)` came out with extents -8.03e+06 … 4.37e+06 and
-- `cairo_fill` changed zero pixels. Measured.
package = {
    spec        = "1",
    namespace   = "freedesktop",
    name        = "cairo",
    description = "cairo 1.18.2 — 2D vector drawing, backends as features with X11 off by default",
    licenses    = {"LGPL-2.1-or-later", "MPL-1.1"},
    repo        = "https://github.com/mcpplibs/cairo",
    type        = "package",

    xpm = {
        linux = {
            ["1.18.2"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/cairo/releases/download/v1.18.2/cairo-1.18.2-mcpp2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/cairo/releases/download/1.18.2/cairo-1.18.2-mcpp2.tar.gz",
                },
                sha256 = "202352a38d0847628c55cd0f9c67e85ac78667ad76bc88691ab47606d1104ef7",
            },
        },
    },

    mcpp = "*/mcpp/cairo/mcpp.toml",
}
