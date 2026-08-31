// pango — international text layout, exercised rather than merely linked.
//
// WHAT CAN BE ASSERTED WITHOUT A FONT
//
// This member has no font backend: finding and rasterising fonts is pangoft2's
// job and drawing is pangocairo's. So a layout test here would be asserting
// that the RUNNER has fonts, which is not what this package is.
//
// Everything below is an INTERMEDIATE QUANTITY — something pango computes from
// data it carries, with no font map involved — and each names a specific part
// of the build, so a failure says which one broke:
//
//   the version macros    include/pango/pango-features.h, one of two generated
//                         headers, and PANGO_BINARY_AGE from config.h — which
//                         is not substituted from a template but WRITTEN,
//                         because upstream's configure_file has no input
//   the GENERATED enums   pango-enum-types.{h,c}, 27 GTypes from a
//                         reimplemented glib-mkenums
//   itemisation           itemize.c + pango-script.c: splitting a mixed-script
//                         string into runs is pure Unicode table work
//   bidi                  pango-bidi-type.c over compat.fribidi
//   line breaking         break.c, the Unicode line-breaking algorithm
//   the attribute list    pango-attributes.c + pango-markup.c, the parser
//   GListModel            ⭐ what pango was blocked on: PangoFontMap declares
//                         G_IMPLEMENT_INTERFACE(G_TYPE_LIST_MODEL, …), so the
//                         type cannot even register without gio

#ifdef __linux__

// ⚠️ NO extern "C" WRAPPER. pango decorates its headers with G_BEGIN_DECLS, so
// one is redundant — and harmful, because pango.h reaches <stdlib.h>, which
// libc++ routes through <cstdlib>, which defines TEMPLATES. Inside an
// extern "C" block that is `templates must have C++ linkage`, dozens of times,
// against a header this file never names.
#include <pango/pango.h>

// ⚠️ pango.h does NOT pull gio in, even though PangoFontMap implements
// GListModel — the interface is used in the implementation, not the header.
// A consumer that wants to treat a font map as a list model includes gio
// itself, which is legitimate: gnome.gio arrives transitively as a dependency
// of this package.
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
    std::printf("pango %s\n\n", pango_version_string());

    // ── 1. the two generated headers, and config.h ───────────────────────
    check(PANGO_VERSION_MAJOR == 1 && PANGO_VERSION_MINOR == 56
              && PANGO_VERSION_MICRO == 1,
          "pango-features.h reports the version the manifest declares");
    check(std::strcmp(PANGO_VERSION_STRING, "1.56.1") == 0,
          "…and its @…@ substitution produced the string form");
    check(pango_version() == PANGO_VERSION,
          "the runtime version agrees with the compiled-in one");

    // ⚠️ PANGO_BINARY_AGE lives in config.h, which upstream produces with a
    // configure_file that has NO input template — so it is written here rather
    // than substituted, and a wrong value is a wrong ANSWER rather than a
    // build error. pango_version_check consults it.
    check(pango_version_check(1, 56, 0) == nullptr,
          "pango_version_check accepts 1.56.0 — PANGO_BINARY_AGE is right");
    check(pango_version_check(1, 99, 0) != nullptr,
          "…and rejects a version from the future");

    // ── 2. the GENERATED enum types ──────────────────────────────────────
    // These exist only because build.mcpp reproduced glib-mkenums over
    // pango's public headers. Registering one and reading a value back is the
    // only evidence the generator produced REGISTERABLE code rather than a
    // header that happens to compile.
    const GType align = pango_alignment_get_type();
    check(align != 0, "pango_alignment_get_type() registered a GType");
    check(align == PANGO_TYPE_ALIGNMENT,
          "…and the MACRO is spelled the way upstream spells it");

    GEnumClass *ec = static_cast<GEnumClass *>(g_type_class_ref(align));
    GEnumValue *v = ec ? g_enum_get_value(ec, PANGO_ALIGN_CENTER) : nullptr;
    check(v && std::strcmp(v->value_name, "PANGO_ALIGN_CENTER") == 0,
          "…with PANGO_ALIGN_CENTER under its own name");
    check(v && std::strcmp(v->value_nick, "center") == 0,
          "…and the nick mkenums derives, \"center\"");
    if (ec) {
        g_type_class_unref(ec);
    }
    check(pango_wrap_mode_get_type() != 0 && pango_ellipsize_mode_get_type() != 0
              && pango_script_get_type() != 0,
          "the other generated enum types register too");

    // ── 3. ⭐ GListModel — the gio dependency, at run time ────────────────
    // PangoFontMap's class init declares
    //   G_IMPLEMENT_INTERFACE (G_TYPE_LIST_MODEL, pango_font_map_list_model_init)
    // so registering the type at all requires gio's interface to exist. This
    // is the check that the text-layout line is actually joined up.
    const GType fm = pango_font_map_get_type();
    check(fm != 0, "PangoFontMap registers");
    check(g_type_is_a(fm, g_list_model_get_type()),
          "…and it IS a GListModel — the gio gate, at run time");

    // ── 4. itemisation: Unicode script runs, no fonts involved ───────────
    // "Hello 世界 مرحبا" is Latin, Han and Arabic. Splitting it is pure table
    // work in pango-script.c.
    {
        const char *text = "Hello \344\270\226\347\225\214 \331\205\330\261\330\255\330\250\330\247";
        PangoScriptIter *it = pango_script_iter_new(text, -1);
        int runs = 0;
        bool saw_han = false, saw_arabic = false;
        do {
            const char *s = nullptr, *e = nullptr;
            PangoScript sc;
            pango_script_iter_get_range(it, &s, &e, &sc);
            ++runs;
            saw_han    |= (sc == PANGO_SCRIPT_HAN);
            saw_arabic |= (sc == PANGO_SCRIPT_ARABIC);
        } while (pango_script_iter_next(it));
        pango_script_iter_free(it);
        std::printf("   script runs: %d\n", runs);
        check(runs >= 3, "pango_script_iter splits a mixed-script string");
        check(saw_han && saw_arabic, "…and identifies Han and Arabic by name");
    }

    // ── 5. bidi, which is compat.fribidi doing the work ──────────────────
    // Deprecated since 1.44 and still exported; testing them is testing what
    // the library actually offers.
    G_GNUC_BEGIN_IGNORE_DEPRECATIONS
    check(pango_unichar_direction(0x05D0) == PANGO_DIRECTION_RTL,
          "Hebrew alef is right-to-left");
    check(pango_unichar_direction('A') == PANGO_DIRECTION_LTR,
          "…and 'A' is left-to-right");
    {
        const char *rtl = "\330\247\331\204\330\263\331\204\330\247\331\205";  // "السلام"
        check(pango_find_base_dir(rtl, -1) == PANGO_DIRECTION_RTL,
              "pango_find_base_dir on an Arabic string");
    }
    G_GNUC_END_IGNORE_DEPRECATIONS

    // ── 6. line breaking: break.c over the Unicode algorithm ─────────────
    {
        const char *text = "hello world";
        PangoLogAttr attrs[16] = {};
        pango_get_log_attrs(text, -1, -1, pango_language_from_string("en-US"),
                            attrs, 16);
        // A break is allowed before "world" (offset 6) and not mid-word.
        check(attrs[6].is_line_break, "a line break is allowed before \"world\"");
        check(!attrs[3].is_line_break, "…and not in the middle of \"hello\"");
        check(attrs[5].is_white, "…and the space is classified as white");
    }

    // ── 7. the markup parser ─────────────────────────────────────────────
    {
        PangoAttrList *attrs = nullptr;
        char *text = nullptr;
        GError *err = nullptr;
        const gboolean ok = pango_parse_markup("a <b>bold</b> word", -1, 0,
                                               &attrs, &text, nullptr, &err);
        check(ok && text && std::strcmp(text, "a bold word") == 0,
              "pango_parse_markup strips the tags and keeps the text");
        check(attrs != nullptr, "…and produces an attribute list");
        if (attrs) {
            pango_attr_list_unref(attrs);
        }
        g_free(text);
        if (err) {
            g_error_free(err);
        }
    }

    // ── 8. language tags, which carry their own sample text tables ───────
    {
        PangoLanguage *ja = pango_language_from_string("ja-JP");
        check(ja != nullptr, "pango_language_from_string");
        check(std::strcmp(pango_language_to_string(ja), "ja-jp") == 0,
              "…normalises the tag to lower case");
        check(pango_language_includes_script(ja, PANGO_SCRIPT_HAN),
              "…and knows Japanese uses Han");
    }

    std::printf("\n%s\n", failures == 0 ? "all ok" : "FAILURES");
    return failures == 0 ? 0 : 1;
}

#else

#include <cstdio>

int main()
{
    std::printf("pango: this package builds the Linux half; skipping.\n");
    return 0;
}

#endif
