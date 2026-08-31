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

import gnome.pango;   // re-exports gnome.gio, and glib/gobject behind it

// ⚠️ NO <cstdio> AND NO <cstring>. The module's global fragment already saw
// <stdio.h> and <string.h> through pango.h, and reaching them TEXTUALLY as
// well makes the same `struct _IO_FILE` two entities:
//
//     error: conflicting declaration 'struct _IO_FILE'
//
// glib's own g_print and strcmp-equivalent come through the module, which is
// the point: on the module route a consumer includes nothing.

int main()
{
    int failures = 0;
    auto check = [&](bool ok, const char *what) {
        g_print("%-58s %s\n", what, ok ? "ok" : "FAILED");
        if (!ok) ++failures;
    };

    g_print("import gnome.pango — %s\n\n", pango_version_string());

    check(pango_version() >= 15601, "pango_version() through the module");
    check(pango_version_check(1, 56, 0) == nullptr,
          "pango_version_check — PANGO_BINARY_AGE came from config.h");

    // ⚠️ PANGO_TYPE_ALIGNMENT is a MACRO; the module carries the FUNCTION it
    // wraps. That is the shape of the module route, and why the header route
    // stays supported next door.
    check(pango_alignment_get_type() != 0, "the generated enum GTypes register");
    check(pango_font_map_get_type() != 0, "PangoFontMap registers");

    // An ENUMERATOR, exported by name — GCC makes them visible through an
    // exported typedef and clang does not, so they are listed explicitly.
    PangoDirection d = PANGO_DIRECTION_RTL;
    check(static_cast<int>(d) != 0, "an enumerator is exported by name");

    // Script itemisation: pure Unicode table work, no fonts, no macros.
    {
        const char *text = "Hello \344\270\226\347\225\214";
        PangoScriptIter *it = pango_script_iter_new(text, -1);
        int runs = 0;
        do { ++runs; } while (pango_script_iter_next(it));
        pango_script_iter_free(it);
        check(runs >= 2, "pango_script_iter splits Latin from Han");
    }

    // Line breaking.
    {
        PangoLogAttr attrs[16] = {};
        pango_get_log_attrs("hello world", -1, -1,
                            pango_language_from_string("en-US"), attrs, 16);
        check(attrs[6].is_line_break, "a line break is allowed before \"world\"");
    }

    // The markup parser, which reaches glib's GMarkup through the re-export
    // chain — gnome.pango pulls gnome.gio, which re-exports gnome.glib.
    {
        char *text = nullptr;
        const gboolean ok = pango_parse_markup("a <b>bold</b> word", -1, 0,
                                               nullptr, &text, nullptr, nullptr);
        check(ok && text && g_strcmp0(text, "a bold word") == 0,
              "pango_parse_markup — and g_free below is glib, transitively");
        g_free(text);
    }

    g_print("\n%s\n", failures == 0 ? "all ok" : "FAILURES");
    return failures == 0 ? 0 : 1;
}

#else
#include <cstdio>
int main() { std::printf("linux only\n"); return 0; }
#endif
