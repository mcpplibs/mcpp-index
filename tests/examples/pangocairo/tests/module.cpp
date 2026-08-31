// ⭐ THE MODULE, WHICH IS WHAT THE NAMESPACE PROMISES.
//
// In this index the namespace is the contract: `compat.xxx` is consumed with
// `#include`, an owner namespace like `gnome.xxx` exposes `import`. The test
// next to this file takes the header route; this one takes the module, so both
// doors are tested rather than assumed.
//
// ⚠️ THE TWO DOORS DO NOT COMPOSE. A TU that imports the module AND textually
// includes a pango or glib header reaches <time.h> twice — once through the
// module's global fragment, once directly — and the same `struct tm` becomes
// two entities. So a consumer picks ONE, and which one is decided by macros:
// a module cannot carry them. Code using `PANGO_TYPE_*` or `G_OBJECT` takes
// the header route; code using the function API imports and includes nothing.
#ifdef __linux__

import gnome.pangocairo;   // re-exports gnome.pango and gnome.pangoft2

int main()
{
    int failures = 0;
    auto check = [&](bool ok, const char *what) {
        g_print("%-58s %s\n", what, ok ? "ok" : "FAILED");
        if (!ok) ++failures;
    };

    g_print("import gnome.pangocairo\n\n");

    PangoFontMap *map = pango_cairo_font_map_get_default();
    check(map != nullptr, "pango_cairo_font_map_get_default()");
    // ⚠️ G_OBJECT_TYPE_NAME is a MACRO and cannot come through a module. The
    // font TYPE is a better check anyway: it asserts the backend directly
    // rather than by a substring of a class name.
    check(map && pango_cairo_font_map_get_font_type(
                     reinterpret_cast<PangoCairoFontMap *>(map)) == CAIRO_FONT_TYPE_FT,
          "…and its font type is FreeType — HAVE_CAIRO_FREETYPE took");

    // ⚠️ FAMILIES ARE ENUMERATED BEFORE DRAWING, matching the header-route
    // test next door. When this ran AFTER the draw, the module test drew 0
    // pixels on a runner where the header test drew 116 — same machine, same
    // four families, identical drawing code. The only difference was this
    // call's position, so it is now in the same place in both, and the count
    // is reported so the two are comparable rather than merely both "ok".
    int families = -1;
    {
        PangoFontFamily **f = nullptr;
        pango_font_map_list_families(map, &f, &families);
        g_free(f);
    }
    g_print("   font families visible: %d\n", families);

    PangoContext *ctx = pango_font_map_create_context(map);
    PangoLayout *layout = pango_layout_new(ctx);
    pango_layout_set_text(layout, "Hello \344\270\226\347\225\214", -1);
    PangoFontDescription *desc = pango_font_description_from_string("Sans 24");
    pango_layout_set_font_description(layout, desc);
    check(pango_layout_get_character_count(layout) == 8,
          "the layout counts 8 characters");

    int w = 0, h = 0;
    pango_layout_get_pixel_size(layout, &w, &h);
    g_print("   layout pixel size: %dx%d\n", w, h);

    // ⚠️ THE SURFACE IS CHECKED, and its format is PRINTED. The first version
    // of this test only counted pixels, so when it reported 0 on a runner
    // where the header-route twin reported 116 there was nothing to go on:
    // "0 pixels" is a symptom shared by "nothing was drawn", "the surface is
    // in an error state" and "the pixel loop is reading the wrong bytes".
    cairo_surface_t *surf = cairo_image_surface_create(CAIRO_FORMAT_ARGB32, 400, 100);
    g_print("   surface status=%d format=%d (CAIRO_FORMAT_ARGB32=%d)\n",
            (int) cairo_surface_status(surf),
            (int) cairo_image_surface_get_format(surf),
            (int) CAIRO_FORMAT_ARGB32);
    check(cairo_surface_status(surf) == CAIRO_STATUS_SUCCESS,
          "the ARGB32 surface was created without error");
    check(cairo_image_surface_get_format(surf) == CAIRO_FORMAT_ARGB32,
          "…and the format it reports is the one that was asked for");

    cairo_t *cr = cairo_create(surf);
    cairo_set_source_rgb(cr, 0, 0, 0);
    cairo_move_to(cr, 10, 10);
    pango_cairo_show_layout(cr, layout);
    cairo_destroy(cr);

    cairo_surface_flush(surf);
    const unsigned char *d = cairo_image_surface_get_data(surf);
    check(d != nullptr, "the surface has readable pixel data");
    const int stride = cairo_image_surface_get_stride(surf);
    long drawn = 0;
    for (int y = 0; d && y < 100; ++y)
        for (int x = 0; x < 400; ++x)
            if (d[(long)y * stride + 4 * x + 3] != 0) ++drawn;
    g_print("   non-transparent pixels: %ld\n", drawn);

    // ⚠️ Only assertable when the runner HAS fonts — see the header-route test
    // next door for why 0 families is a property of the machine.
    if (families > 0)
        // `> 0`, not a tuned number — see the header-route test next door for
        // why a threshold here is an assertion about the runner's fonts.
        check(drawn > 0, "pango_cairo_show_layout put ink on the surface");
    else
        g_print("   ⚠️  0 font families: the rendering assertion was NOT run.\n");

    cairo_surface_destroy(surf);
    pango_font_description_free(desc);
    g_object_unref(layout);
    g_object_unref(ctx);

    g_print("\n%s\n", failures == 0 ? "all ok" : "FAILURES");
    return failures == 0 ? 0 : 1;
}

#else
#include <cstdio>
int main() { std::printf("linux only\n"); return 0; }
#endif
