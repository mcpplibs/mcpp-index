// pangoft2 — the FreeType/fontconfig backend.
//
// ⚠️ WHAT THIS DOES *NOT* ASSERT: that any particular font is found. That
// depends on the RUNNER having /usr/share/fonts and a fontconfig
// configuration, and `freedesktop.fontconfig` deliberately compiles its
// runtime paths EMPTY so it does not silently read the developer's fonts. A
// test that demanded "DejaVu Sans" would be checking the machine, not this
// build.
//
// What IS asserted is everything that does not need a font file: that the
// font map type registers, that it IS a PangoFontMap and a GListModel, that
// the fontconfig and FreeType halves are actually linked in (by calling into
// each), and that enumerating families returns a well-formed answer — which on
// a runner with no fonts is legitimately zero.

#ifdef __linux__

#include <pango/pangoft2.h>
#include <pango/pangofc-fontmap.h>
// ⚠️ pango-ot.h is NOT reached through pangoft2.h. It is a separate installed
// header, and its whole body sits behind `#ifndef PANGO_DISABLE_DEPRECATED` —
// upstream's own comment is "Deprecated. Use HarfBuzz directly!". It is still
// compiled into this member and still part of its ABI, so it is still tested.
#include <pango/pango-ot.h>
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

} // namespace

int main()
{
    std::printf("pangoft2 (pango %s)\n\n", pango_version_string());

    // ── the types register ───────────────────────────────────────────────
    const GType ft2 = pango_ft2_font_map_get_type();
    check(ft2 != 0, "PangoFT2FontMap registers");
    check(g_type_is_a(ft2, pango_fc_font_map_get_type()),
          "…and derives from PangoFcFontMap — the fontconfig half is linked");
    check(g_type_is_a(ft2, pango_font_map_get_type()),
          "…and from PangoFontMap — gnome.pango is linked");
    check(g_type_is_a(ft2, g_list_model_get_type()),
          "…and it is a GListModel, inherited through PangoFontMap");

    // ── an actual instance, which runs fontconfig's initialisation ───────
    PangoFontMap *map = pango_ft2_font_map_new();
    check(map != nullptr, "pango_ft2_font_map_new() — FcInit ran without dying");

    if (map != nullptr) {
        // ⚠️ ZERO IS A VALID ANSWER HERE. compat.fontconfig ships empty runtime
        // paths on purpose, so a runner with no FONTCONFIG_FILE finds no
        // fonts. What is asserted is that the call ANSWERS — the out
        // parameters are consistent — not what it answers.
        PangoFontFamily **families = nullptr;
        int n = -1;
        pango_font_map_list_families(map, &families, &n);
        std::printf("   font families visible: %d\n", n);
        check(n >= 0, "pango_font_map_list_families answers");
        check(n == 0 || families != nullptr,
              "…and the array matches the count it reported");
        g_free(families);

        // The resolution the FT2 map carries, which is its own state rather
        // than anything fontconfig had to find.
        pango_ft2_font_map_set_resolution(PANGO_FT2_FONT_MAP(map), 96.0, 96.0);

        PangoContext *ctx = pango_font_map_create_context(map);
        check(ctx != nullptr, "…and it can create a PangoContext");
        if (ctx != nullptr) {
            check(pango_context_get_font_map(ctx) == map,
                  "…which points back at the font map");
            g_object_unref(ctx);
        }
        g_object_unref(map);
    }

    // ── the OpenType tag helpers: pango-ot-tag.c, pure table work ────────
    {
        const PangoOTTag t = pango_ot_tag_from_script(PANGO_SCRIPT_ARABIC);
        // 'arab' — the OpenType script tag, four packed bytes.
        check(t == PANGO_OT_TAG_MAKE('a', 'r', 'a', 'b'),
              "pango_ot_tag_from_script(ARABIC) is 'arab'");
        check(pango_ot_tag_to_script(t) == PANGO_SCRIPT_ARABIC,
              "…and the mapping round-trips");
    }

    std::printf("\n%s\n", failures == 0 ? "all ok" : "FAILURES");
    return failures == 0 ? 0 : 1;
}

#else

#include <cstdio>
int main() { std::printf("pangoft2: Linux only.\n"); return 0; }

#endif
