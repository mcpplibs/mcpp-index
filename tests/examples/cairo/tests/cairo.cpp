// freedesktop.cairo — draw something, read the pixels back, and check that the
// feature split actually took effect.
//
// Cairo needs no display and no fonts on disk to draw: an image surface is
// memory, and that is what a compositor's software fallback and every
// screenshot path use. So this test draws for real rather than only checking
// that symbols resolve.
//
// THE FEATURE ASSERTIONS ARE THE POINT OF THE PACKAGE. `xlib` and `xcb` are off
// by default, and "off" has to mean the macro is undefined — otherwise a
// consumer could `#include <cairo-xlib.h>` and fail at link instead of at
// compile, which is the wrong place to find out.

#ifdef __linux__

#include <cairo.h>

#include <cstdio>
#include <cstring>

import freedesktop.cairo;

namespace {

int failures = 0;

void check(bool ok, const char *what)
{
    std::printf("%-58s %s\n", what, ok ? "ok" : "FAILED");
    if (!ok) {
        ++failures;
    }
}

} // namespace

int main()
{
    std::printf("   cairo %s\n", cairo_version_string());
    check(cairo_version() >= 11802, "cairo_version reports 1.18.2 or newer");

    // ── 1. Draw, then read the pixel back ────────────────────────────────
    // A 64x64 ARGB32 surface, filled with an exact colour, then one pixel
    // sampled. Exact because cairo_set_source_rgb takes doubles and
    // 0.25/0.5/0.75 land on 64/128/191 without rounding ambiguity — the same
    // values the GBM/EGL closed-loop test uses, for the same reason.
    cairo_surface_t *s = cairo_image_surface_create(CAIRO_FORMAT_ARGB32, 64, 64);
    check(cairo_surface_status(s) == CAIRO_STATUS_SUCCESS,
          "cairo_image_surface_create(ARGB32, 64, 64)");

    cairo_t *cr = cairo_create(s);
    check(cairo_status(cr) == CAIRO_STATUS_SUCCESS, "cairo_create on it");

    // ONE drawing pass, THEN one flush, THEN read. The first version of this
    // test flushed and read between the paint and the stroke, and the stroke
    // then changed zero pixels with `cairo_status` still SUCCESS — cairo had
    // handed the buffer out and did not take it back. `cairo_surface_flush` is
    // the end of a drawing sequence, not a checkpoint inside one.
    cairo_set_source_rgb(cr, 0.25, 0.5, 0.75);
    cairo_paint(cr);

    cairo_set_source_rgb(cr, 1, 1, 1);
    cairo_set_line_width(cr, 8);
    cairo_move_to(cr, 8, 8);
    cairo_line_to(cr, 56, 56);
    cairo_stroke(cr);

    check(cairo_status(cr) == CAIRO_STATUS_SUCCESS, "…and the context is still clean");
    cairo_surface_flush(s);

    const unsigned char *d = cairo_image_surface_get_data(s);
    const int stride = cairo_image_surface_get_stride(s);

    // ARGB32 is little-endian: B G R A.
    // (56,8) is far from the diagonal, so it still carries the paint —
    // 0.25/0.5/0.75 land on 64/128/191 with no rounding ambiguity, the same
    // values the GBM/EGL closed-loop test uses and for the same reason.
    const unsigned char *bg = d + 8 * stride + 56 * 4;
    std::printf("   (56,8) = %u %u %u %u (B G R A)\n", bg[0], bg[1], bg[2], bg[3]);
    check(bg[2] == 64 && bg[1] == 128 && bg[0] == 191 && bg[3] == 255,
          "the painted background is exactly what was asked for");

    // (32,32) is on the diagonal, under an 8px white stroke.
    const unsigned char *on = d + 32 * stride + 32 * 4;
    std::printf("   (32,32) = %u %u %u %u\n", on[0], on[1], on[2], on[3]);
    // ── 3. The path machinery, checked directly ─────────────────────────
    //
    // These three are here because of what they caught. With
    // `WORDS_BIGENDIAN` defined to 0 — which cairo tests with `#ifdef`, so 0
    // means BIG-ENDIAN — every path got garbage fixed-point coordinates while
    // `cairo_status` reported success and `cairo_paint` kept working:
    //
    //     path_extents      -8.03e+06 -8.03e+06 4.37e+06 4.37e+06
    //     in_fill(40, 40)   1          (the point is outside the rectangle)
    //
    // The pixel check above catches it too, but only as "the stroke drew
    // nothing", which sends you looking for a missing source file. These say
    // where the arithmetic went wrong.
    {
        cairo_t *c3 = cairo_create(s);
        cairo_rectangle(c3, 4, 4, 16, 16);
        double x1, y1, x2, y2;
        cairo_path_extents(c3, &x1, &y1, &x2, &y2);
        std::printf("   path_extents = %g %g %g %g\n", x1, y1, x2, y2);
        check(x1 == 4 && y1 == 4 && x2 == 20 && y2 == 20,
              "a rectangle path has the extents it was given");
        check(cairo_in_fill(c3, 10, 10) == 1, "…and a point inside it reads as inside");
        check(cairo_in_fill(c3, 40, 40) == 0, "…and a point outside reads as outside");
        cairo_destroy(c3);
    }

    check(on[0] == 255 && on[1] == 255 && on[2] == 255,
          "…and the stroked diagonal covers the centre in white");


    cairo_destroy(cr);
    cairo_surface_destroy(s);

    // ── 3. The default feature set ───────────────────────────────────────
#ifdef CAIRO_HAS_FT_FONT
    check(true, "feature ft is ON by default (CAIRO_HAS_FT_FONT)");
#else
    check(false, "feature ft should be ON by default");
#endif
#ifdef CAIRO_HAS_FC_FONT
    check(true, "feature fc is ON by default (CAIRO_HAS_FC_FONT)");
#else
    check(false, "feature fc should be ON by default");
#endif
#ifdef CAIRO_HAS_PNG_FUNCTIONS
    check(true, "feature png is ON by default");
#else
    check(false, "feature png should be ON by default");
#endif

    // ── 4. X11 is OFF, and that is the whole point ───────────────────────
    // A Wayland program must not acquire libX11 by depending on cairo. If this
    // ever fails, someone made a backend unconditional.
#ifdef CAIRO_HAS_XLIB_SURFACE
    check(false, "xlib must be OFF unless the consumer asks for it");
#else
    check(true, "feature xlib is OFF by default — no libX11 pulled in");
#endif
#ifdef CAIRO_HAS_XCB_SURFACE
    check(false, "xcb must be OFF unless the consumer asks for it");
#else
    check(true, "feature xcb is OFF by default");
#endif

    // ── 5. The module carries what the features enabled ──────────────────
    // `cairo_image_surface_create_from_png` lives behind CAIRO_HAS_PNG_FUNCTIONS
    // inside cairo.h itself, not in a feature header — the module generator has
    // to notice that or a png-enabled consumer cannot reach it through `import`.
    check(&cairo_surface_write_to_png != nullptr,
          "module exports a name guarded inside cairo.h (write_to_png)");
    check(&cairo_ft_font_face_create_for_ft_face != nullptr,
          "…and one from a feature header (cairo_ft_font_face_create…)");

    std::printf("\n%d check(s) failed\n", failures);
    return failures == 0 ? 0 : 1;
}

#else
int main() { return 0; }
#endif
