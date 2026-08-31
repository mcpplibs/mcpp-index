// cairo, via its MODULE — and this is the route that had never been checked.
//
// ⭐ WHY THIS FILE EXISTS
//
// The package exposed `import freedesktop.cairo;` and the only test that named
// it also wrote `#include <cairo.h>`. So the header supplied whatever the
// module lacked, and what it lacked was substantial:
//
//     470 names exported, and among the missing:
//       cairo_t              the single most-used type in the library
//       192 enumerators      every CAIRO_FORMAT_*, CAIRO_STATUS_*, CAIRO_OPERATOR_*
//
// It was found from OUTSIDE, by gnome.pangocairo — which cannot mix the two
// routes (pangocairo.h reaches glib and therefore <stdio.h>, so a textual
// include alongside the import makes `struct _IO_FILE` two entities) and
// therefore had to ask the module for `cairo_t` and got nothing.
//
// This file includes NOTHING. That is the whole point: if a name is missing
// from the module, this fails to compile.

#ifdef __linux__

import cairo;

#include <cstdio>

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
    std::printf("import cairo — %s\n\n", cairo_version_string());

    // ── the types, including the one that used to be missing ─────────────
    cairo_surface_t *surf = cairo_image_surface_create(CAIRO_FORMAT_ARGB32, 64, 64);
    check(cairo_surface_status(surf) == CAIRO_STATUS_SUCCESS,
          "cairo_image_surface_create — CAIRO_FORMAT_ARGB32 is an ENUMERATOR");
    check(cairo_image_surface_get_format(surf) == CAIRO_FORMAT_ARGB32,
          "…and the surface reports the format that was asked for");

    // ⭐ `cairo_t` — `typedef struct _cairo cairo_t;`. The old regex required at
    // least one character between `cairo_` and `_t`, so this one name, the one
    // every cairo program starts with, was the one it could not match.
    cairo_t *cr = cairo_create(surf);
    check(cairo_status(cr) == CAIRO_STATUS_SUCCESS, "cairo_create returns a live cairo_t");

    // ── draw, and read the pixels back ───────────────────────────────────
    cairo_set_source_rgb(cr, 1.0, 0.0, 0.0);
    cairo_rectangle(cr, 8, 8, 48, 48);
    cairo_fill(cr);
    cairo_surface_flush(surf);

    const unsigned char *d = cairo_image_surface_get_data(surf);
    const int stride = cairo_image_surface_get_stride(surf);
    check(d != nullptr, "the image surface has readable pixel data");

    long ink = 0;
    for (int y = 0; d && y < 64; ++y) {
        for (int x = 0; x < 64; ++x) {
            if (d[static_cast<long>(y) * stride + 4 * x + 3] != 0) {
                ++ink;
            }
        }
    }
    std::printf("   filled pixels: %ld (expected 48*48 = 2304)\n", ink);
    check(ink == 48 * 48, "the rectangle is exactly the pixels it asked for");

    // ── more enumerators, from three different enums ─────────────────────
    cairo_set_operator(cr, CAIRO_OPERATOR_OVER);
    check(cairo_get_operator(cr) == CAIRO_OPERATOR_OVER, "CAIRO_OPERATOR_OVER");
    cairo_set_line_cap(cr, CAIRO_LINE_CAP_ROUND);
    check(cairo_get_line_cap(cr) == CAIRO_LINE_CAP_ROUND, "CAIRO_LINE_CAP_ROUND");
    cairo_set_fill_rule(cr, CAIRO_FILL_RULE_EVEN_ODD);
    check(cairo_get_fill_rule(cr) == CAIRO_FILL_RULE_EVEN_ODD, "CAIRO_FILL_RULE_EVEN_ODD");

    // ── the matrix, which is a struct type rather than an opaque handle ──
    cairo_matrix_t m;
    cairo_matrix_init_identity(&m);
    cairo_matrix_translate(&m, 3.0, 4.0);
    check(m.x0 == 3.0 && m.y0 == 4.0, "cairo_matrix_t is a usable value type");

    // ── the FreeType font backend, which is a default feature ────────────
    // ⚠️ The point is the ENUMERATOR: CAIRO_FONT_TYPE_FT is what a consumer
    // compares against, and it was among the 192 that never made it out.
    cairo_font_face_t *ff = cairo_get_font_face(cr);
    std::printf("   default font backend: %d (CAIRO_FONT_TYPE_FT=%d)\n",
                (int) cairo_font_face_get_type(ff), (int) CAIRO_FONT_TYPE_FT);
    check(cairo_font_face_status(ff) == CAIRO_STATUS_SUCCESS,
          "the default font face is live");

    cairo_destroy(cr);
    cairo_surface_destroy(surf);

    std::printf("\n%s\n", failures == 0 ? "all ok" : "FAILURES");
    return failures == 0 ? 0 : 1;
}

#else

#include <cstdio>
int main() { std::printf("cairo: Linux only here.\n"); return 0; }

#endif
