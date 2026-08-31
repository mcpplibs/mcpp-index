// pangocairo — the whole text-layout line, end to end.
//
// ⭐ THIS IS THE ONE TEST IN THE STACK THAT PRODUCES PIXELS, and it is worth
// stating what that costs to reach:
//
//     gnome.pango       itemisation, bidi, line breaking
//     gnome.pangoft2    fontconfig picks the file, FreeType rasterises
//     gnome.gio         PangoFontMap is a GListModel
//     compat.harfbuzz   shaping
//     compat.fribidi    the bidi algorithm
//     freedesktop.cairo the surface the glyphs land on
//
// Seven packages, and a blank image means one of them is not doing its job.
//
// ⚠️ IT DEGRADES HONESTLY WHEN THERE ARE NO FONTS. `freedesktop.fontconfig`
// compiles its runtime paths EMPTY on purpose, so a runner with no
// FONTCONFIG_FILE and no /usr/share/fonts legitimately finds zero families —
// and then there is nothing to draw and nothing to assert. That case is
// REPORTED rather than passed over in silence, because "0 families, so we
// skipped the only real check" and "the text rendered" must not look alike.

#ifdef __linux__

#include <pango/pangocairo.h>
#include <gio/gio.h>

#include <cstdio>
#include <cstring>

namespace {

int failures = 0;

void check(bool ok, const char *what)
{
    std::printf("%-60s %s\n", what, ok ? "ok" : "FAILED");
    if (!ok) {
        ++failures;
    }
}

// How many pixels in an ARGB32 surface are not fully transparent.
long ink(cairo_surface_t *s)
{
    cairo_surface_flush(s);
    const unsigned char *d = cairo_image_surface_get_data(s);
    if (d == nullptr) {
        return -1;
    }
    const int w = cairo_image_surface_get_width(s);
    const int h = cairo_image_surface_get_height(s);
    const int stride = cairo_image_surface_get_stride(s);
    long n = 0;
    for (int y = 0; y < h; ++y) {
        const unsigned char *row = d + static_cast<long>(y) * stride;
        for (int x = 0; x < w; ++x) {
            if (row[4 * x + 3] != 0) {
                ++n;
            }
        }
    }
    return n;
}

} // namespace

int main()
{
    std::printf("pangocairo (pango %s, cairo %s)\n\n",
                pango_version_string(), cairo_version_string());

    // ── the types register, and the inheritance is the dependency graph ──
    const GType fm = pango_cairo_font_map_get_type();
    check(fm != 0, "PangoCairoFontMap registers");

    PangoFontMap *map = pango_cairo_font_map_get_default();
    check(map != nullptr, "pango_cairo_font_map_get_default()");
    check(PANGO_IS_CAIRO_FONT_MAP(map), "…and it is a PangoCairoFontMap");
    check(g_type_is_a(G_OBJECT_TYPE(map), g_list_model_get_type()),
          "…and a GListModel, which is gio, inherited through PangoFontMap");

    // ⚠️ THE BACKEND IS THE CHECK THAT pangoft2 IS ACTUALLY WIRED IN. Without
    // HAVE_CAIRO_FREETYPE the fc font map is never registered and the default
    // map is some other implementation — which still builds, still runs, and
    // never finds a font. So the type NAME is read.
    const char *backend = G_OBJECT_TYPE_NAME(map);
    std::printf("   font map backend: %s\n", backend);
    check(backend != nullptr && std::strstr(backend, "Fc") != nullptr,
          "…and it is the FONTCONFIG-backed map — HAVE_CAIRO_FREETYPE took");

    int families = -1;
    {
        PangoFontFamily **f = nullptr;
        pango_font_map_list_families(map, &f, &families);
        g_free(f);
    }
    std::printf("   font families visible: %d\n", families);
    check(families >= 0, "pango_font_map_list_families answers");

    // ── layout, entirely without a surface ───────────────────────────────
    PangoContext *ctx = pango_font_map_create_context(map);
    check(ctx != nullptr, "pango_font_map_create_context");

    PangoLayout *layout = pango_layout_new(ctx);
    pango_layout_set_text(layout, "Hello \344\270\226\347\225\214", -1);
    PangoFontDescription *desc = pango_font_description_from_string("Sans 24");
    pango_layout_set_font_description(layout, desc);

    check(pango_layout_get_character_count(layout) == 8,
          "the layout counts 8 characters — \"Hello \" plus two Han");
    check(pango_layout_get_line_count(layout) == 1, "…on one line");

    int w = 0, h = 0;
    pango_layout_get_pixel_size(layout, &w, &h);
    std::printf("   layout pixel size: %dx%d\n", w, h);

    // ── and now the pixels ───────────────────────────────────────────────
    cairo_surface_t *surf = cairo_image_surface_create(CAIRO_FORMAT_ARGB32, 400, 100);
    check(cairo_surface_status(surf) == CAIRO_STATUS_SUCCESS,
          "a 400x100 ARGB32 surface");
    cairo_t *cr = cairo_create(surf);
    cairo_set_source_rgb(cr, 0, 0, 0);
    cairo_move_to(cr, 10, 10);
    pango_cairo_show_layout(cr, layout);
    cairo_destroy(cr);

    const long drawn = ink(surf);
    std::printf("   non-transparent pixels: %ld\n", drawn);

    if (families > 0) {
        // ⭐ THE WHOLE LINE, IN ONE ASSERTION.
        check(w > 0 && h > 0, "the layout measured a non-empty box");
        // ⚠️ `> 0`, NOT `> 100`. An earlier version used 100 and PASSED here
        // (216 pixels, 184 font families) while FAILING on a CI runner with
        // four families and 72 — because with almost no fonts "世界" renders
        // as tofu boxes and the ink is thinner. The threshold was calibrated
        // to the developer's font set, which makes it an assertion about the
        // MACHINE rather than about this build. Ink is ink: any positive count
        // proves all seven packages put pixels down.
        check(drawn > 0,
              "pango_cairo_show_layout put ink on the surface — seven packages");
    } else {
        // Not a pass. The runner has no fonts, so the only real check could
        // not run, and saying so is the point.
        std::printf("   ⚠️  0 font families: this runner has no fonts, so the\n"
                    "       rendering assertion was NOT run. That is a property\n"
                    "       of the machine, not of this build.\n");
        check(drawn >= 0, "the surface is readable (rendering check skipped)");
    }

    // pangocairo-context.c: the resolution and font options a context carries.
    pango_cairo_context_set_resolution(ctx, 96.0);
    check(pango_cairo_context_get_resolution(ctx) == 96.0,
          "pangocairo-context.c round-trips the resolution");

    cairo_surface_destroy(surf);
    pango_font_description_free(desc);
    g_object_unref(layout);
    g_object_unref(ctx);

    std::printf("\n%s\n", failures == 0 ? "all ok" : "FAILURES");
    return failures == 0 ? 0 : 1;
}

#else

#include <cstdio>
int main() { std::printf("pangocairo: Linux only.\n"); return 0; }

#endif
