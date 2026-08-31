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

import gnome.pangoft2;   // re-exports gnome.pango, and gio/glib behind it

int main()
{
    int failures = 0;
    auto check = [&](bool ok, const char *what) {
        g_print("%-58s %s\n", what, ok ? "ok" : "FAILED");
        if (!ok) ++failures;
    };

    g_print("import gnome.pangoft2\n\n");

    const GType ft2 = pango_ft2_font_map_get_type();
    check(ft2 != 0, "PangoFT2FontMap registers");
    check(g_type_is_a(ft2, pango_fc_font_map_get_type()),
          "…derives from PangoFcFontMap — the fontconfig half");
    check(g_type_is_a(ft2, pango_font_map_get_type()),
          "…and from PangoFontMap — gnome.pango came through the re-export");

    PangoFontMap *map = pango_ft2_font_map_new();
    check(map != nullptr, "pango_ft2_font_map_new()");
    if (map) {
        PangoFontFamily **f = nullptr;
        int n = -1;
        pango_font_map_list_families(map, &f, &n);
        g_print("   font families visible: %d\n", n);
        check(n >= 0, "list_families answers (0 is valid — see the header test)");
        g_free(f);
        g_object_unref(map);
    }

    // pango-ot-tag.c, pure table work and no fonts.
    check(pango_ot_tag_to_script(pango_ot_tag_from_script(PANGO_SCRIPT_ARABIC))
              == PANGO_SCRIPT_ARABIC,
          "the OpenType script tag mapping round-trips");

    g_print("\n%s\n", failures == 0 ? "all ok" : "FAILURES");
    return failures == 0 ? 0 : 1;
}

#else
#include <cstdio>
int main() { std::printf("linux only\n"); return 0; }
#endif
