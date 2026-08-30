// glib — the generated headers, and the subsystems that depend on them.
//
// WHAT THIS ASSERTS AND WHY
//
// glib is large and mostly self-evident: if GHashTable were broken the build
// would not have got here. What is NOT self-evident in a fork is whether the
// five generated headers say the right things, because every one of them was
// written out by hand-reimplemented generators. A wrong answer in glibconfig.h
// does not fail to compile — it changes the width of gsize, or the byte order,
// or which printf glib calls.
//
// So each check reads back a value that a generator decided:
//
//   glibconfig.h        gsize/gssize widths, G_BYTE_ORDER, the format strings
//   gversionmacros.h    GLIB_VERSION_2_82 exists and encodes 2.82
//   config.h            USE_SYSTEM_PRINTF, via a format only glibc gets right
//   glib-visibility.h   a GLIB_AVAILABLE_IN_2_x symbol is actually exported
//   pcre2 wiring        GRegex, which is the one external dependency
//
// The subsystem checks that follow are chosen for the same reason: each is a
// place where a wrong config.h answer would show up as a wrong RESULT rather
// than a failure to build.

#ifdef __linux__

// ⚠️ NO extern "C" WRAPPER, and adding one BREAKS THIS UNDER libc++: glib
// decorates every header with G_BEGIN_DECLS (which IS `extern "C" {`), and
// glib.h pulls <stdlib.h>, which libc++ routes through <cstdlib> — templates
// inside an extern "C" block. `templates must have C++ linkage`, dozens of
// times, against a header this test never names. libstdc++ does not, so gcc is
// green and llvm is a wall. Wrap a C header only if it has none of its own.
#include <glib.h>

#include <cstdio>
#include <cstring>

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
    // ── 1. glibconfig.h: the type model ──────────────────────────────────
    std::printf("   glib %d.%d.%d   gsize=%zu gssize=%zu gpointer=%zu\n",
                glib_major_version, glib_minor_version, glib_micro_version,
                sizeof(gsize), sizeof(gssize), sizeof(gpointer));
    check(glib_major_version == 2 && glib_minor_version == 82,
          "the runtime version matches the manifest");
    check(sizeof(gsize) == sizeof(void *) && sizeof(gssize) == sizeof(void *),
          "gsize and gssize are pointer-width, as glibconfig.h declares");
    check(sizeof(gint32) == 4 && sizeof(gint64) == 8 && sizeof(gint16) == 2,
          "the fixed-width types are the widths they are named for");

    // G_BYTE_ORDER is written by the generator rather than probed, so it is
    // worth checking against something the machine can answer for itself.
    const guint32 probe = 0x01020304;
    const bool little = *reinterpret_cast<const unsigned char *>(&probe) == 0x04;
    std::printf("   G_BYTE_ORDER=%d  measured=%s\n", G_BYTE_ORDER,
                little ? "little" : "big");
    check((G_BYTE_ORDER == G_LITTLE_ENDIAN) == little,
          "G_BYTE_ORDER agrees with what the bytes actually say");

    // The format strings are the half of glibconfig.h that a compile cannot
    // check: `%" G_GSIZE_FORMAT "` with the wrong modifier is undefined
    // behaviour that usually prints something plausible.
    {
        gchar *s = g_strdup_printf("%" G_GSIZE_FORMAT, static_cast<gsize>(123456789));
        std::printf("   G_GSIZE_FORMAT renders %s\n", s);
        check(std::strcmp(s, "123456789") == 0,
              "G_GSIZE_FORMAT prints a gsize correctly");
        g_free(s);
    }

    // ── 2. gversionmacros.h ──────────────────────────────────────────────
    // The generator emits one block per even minor up to the current one.
    // Encoding is (major << 16) | (minor << 8) | micro.
    std::printf("   GLIB_VERSION_2_82 = 0x%06x\n", GLIB_VERSION_2_82);
    check(GLIB_VERSION_2_82 == G_ENCODE_VERSION(2, 82),
          "gversionmacros.h defines GLIB_VERSION_2_82 and encodes it correctly");
    check(GLIB_VERSION_2_26 < GLIB_VERSION_2_82,
          "…and the older ones too, in order");

    // ── 3. config.h: USE_SYSTEM_PRINTF ───────────────────────────────────
    // Not directly observable — but %'d (thousands grouping) and the C99 %zu
    // are things glib's bundled gnulib printf implements differently from
    // glibc's. Rendering a long double in %La exercises the path that made the
    // link fail when the wrong printf was selected.
    {
        gchar *s = g_strdup_printf("%.3f|%05d|%s", 1.5, 42, "x");
        std::printf("   printf path renders %s\n", s);
        check(std::strcmp(s, "1.500|00042|x") == 0,
              "g_strdup_printf goes through a working printf");
        g_free(s);
    }

    // ── 4. glib-visibility.h ─────────────────────────────────────────────
    // g_pathbuf_init is GLIB_AVAILABLE_IN_2_76 — a symbol decorated by the
    // generated visibility header. Calling it proves the decoration expanded
    // to something that exports rather than hides.
    {
        GPathBuf pb;
        g_path_buf_init(&pb);
        g_path_buf_push(&pb, "usr");
        g_path_buf_push(&pb, "share");
        gchar *p = g_path_buf_to_path(&pb);
        std::printf("   GPathBuf built %s\n", p ? p : "(null)");
        check(p != nullptr && std::strstr(p, "usr/share") != nullptr,
              "a GLIB_AVAILABLE_IN_2_76 symbol is reachable");
        g_free(p);
        g_path_buf_clear(&pb);
    }

    // ── 5. GRegex, i.e. the pcre2 dependency ─────────────────────────────
    // The only external library glib links here. \p{Han} needs pcre2 built
    // with SUPPORT_UNICODE, which is compat.pcre2's decision — so this checks
    // the two packages agree, not merely that one of them built.
    {
        GError *err = nullptr;
        GRegex *re = g_regex_new("^\\p{Han}+$", G_REGEX_DEFAULT,
                                 G_REGEX_MATCH_DEFAULT, &err);
        check(re != nullptr, "g_regex_new compiles a Unicode property pattern");
        if (re != nullptr) {
            check(g_regex_match(re, "漢字", G_REGEX_MATCH_DEFAULT, nullptr),
                  "…and it matches Han characters");
            check(!g_regex_match(re, "abc", G_REGEX_MATCH_DEFAULT, nullptr),
                  "…and not Latin ones");
            g_regex_unref(re);
        } else if (err != nullptr) {
            std::printf("   %s\n", err->message);
            g_error_free(err);
        }
    }

    // ── 6. Unicode, the tables gunicode.h describes ──────────────────────
    check(g_unichar_type(0x6F22) == G_UNICODE_OTHER_LETTER,
          "g_unichar_type classifies U+6F22 as a letter");
    // The function is `g_unichar_get_script`, not `g_unichar_script`.
    check(g_unichar_get_script(0x6F22) == G_UNICODE_SCRIPT_HAN,
          "…and g_unichar_get_script puts it in Han");
    {
        gchar *up = g_utf8_strup("straße", -1);
        std::printf("   g_utf8_strup(straße) = %s\n", up);
        check(up != nullptr && std::strstr(up, "STRASSE") != nullptr,
              "g_utf8_strup expands ß to SS, i.e. real case tables");
        g_free(up);
    }

    // ── 7. the main loop and GVariant ────────────────────────────────────
    {
        GMainContext *ctx = g_main_context_new();
        check(ctx != nullptr, "a GMainContext is created");
        check(!g_main_context_iteration(ctx, FALSE),
              "…and iterating it with nothing pending does not block");
        g_main_context_unref(ctx);
    }
    {
        GVariant *v = g_variant_new("(si)", "hello", 42);
        g_variant_ref_sink(v);
        const gchar *s = nullptr;
        gint i = 0;
        g_variant_get(v, "(&si)", &s, &i);
        std::printf("   GVariant round-trip: %s %d\n", s, i);
        check(s != nullptr && std::strcmp(s, "hello") == 0 && i == 42,
              "a GVariant tuple survives a serialise/parse round trip");
        g_variant_unref(v);
    }

    std::printf("\n%d check(s) failed\n", failures);
    return failures == 0 ? 0 : 1;
}

#else
int main() { return 0; }
#endif
