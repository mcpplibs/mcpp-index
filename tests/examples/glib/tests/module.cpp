// ⭐ THE MODULE, WHICH IS WHAT THE NAMESPACE PROMISES.
//
// In this index the namespace is the contract: `compat.xxx` is consumed with
// `#include`, an owner namespace like `gnome.xxx` exposes `import`. glib.cpp
// next to this file takes the header route; this one takes the module, so both
// doors are tested rather than assumed.
//
// ─────────────────────────────────────────────────────────────────────────
// ⚠️ THE TWO DOORS DO NOT COMPOSE, AND THAT IS GCC'S RULE, NOT A CHOICE HERE.
//
// A TU that imports gnome.glib AND textually includes a glib header reaches
// `<time.h>` twice — once through the module's global fragment, once directly
// — and the same `struct tm` from the same file becomes two entities:
//
//     error: conflicting declaration 'struct tm'
//     note: previous declaration as 'struct tm'   (of module gnome.glib)
//
// repeated for every type in it. So a consumer picks ONE route.
//
// WHAT THAT MEANS IN PRACTICE, stated plainly because it decides which route
// to pick: a module cannot carry macros, and glib's macros are half its API
// (1,337 `#define` against 1,312 declarations; for gio 1,679 against 1,753).
// Code that uses `G_DEFINE_TYPE`, `G_OBJECT` or `G_TYPE_*` takes the header
// route. Code that uses the FUNCTION API — most of gio, and a great deal of
// glib — can import and include nothing at all, which is what this file does.
#ifdef __linux__

import gnome.glib;

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
    std::printf("import gnome.glib — %d.%d.%d\n\n",
                glib_major_version, glib_minor_version, glib_micro_version);
    check(glib_major_version == 2 && glib_minor_version == 82,
          "the version variables come through the module");

    // ── strings: GString and the g_str* family ───────────────────────────
    GString *s = g_string_new("import");
    g_string_append(s, " works");
    check(std::strcmp(s->str, "import works") == 0, "GString: new + append");
    g_string_free(s, 1);   // TRUE is a MACRO — not reachable through a module

    char *up = g_ascii_strup("mcpp", -1);
    check(up && std::strcmp(up, "MCPP") == 0, "g_ascii_strup");
    g_free(up);

    // ── containers ───────────────────────────────────────────────────────
    GPtrArray *a = g_ptr_array_new();
    g_ptr_array_add(a, const_cast<char *>("one"));
    g_ptr_array_add(a, const_cast<char *>("two"));
    check(a->len == 2, "GPtrArray: two elements");
    g_ptr_array_free(a, 1);

    GHashTable *h = g_hash_table_new(g_str_hash, g_str_equal);
    g_hash_table_insert(h, const_cast<char *>("k"), const_cast<char *>("v"));
    const char *got = static_cast<const char *>(g_hash_table_lookup(h, "k"));
    check(got && std::strcmp(got, "v") == 0, "GHashTable: insert and look up");
    g_hash_table_destroy(h);

    // ── an ENUMERATOR, reached through its typedef ───────────────────────
    // glib writes `typedef enum { … } GNormalizeMode;` — an UNNAMED enum
    // behind a typedef — and exporting the typedef is what makes the
    // enumerators visible. Nothing in the module names them individually.
    GNormalizeMode nfd = G_NORMALIZE_NFD, nfc = G_NORMALIZE_NFC;
    check(nfd != nfc, "an enumerator arrives with its typedef");

    // ── Unicode, which is where glib's own tables live ───────────────────
    check(g_unichar_isalpha(0x4E2D), "g_unichar_isalpha on U+4E2D");
    check(g_unichar_type(0x4E2D) == G_UNICODE_OTHER_LETTER, "g_unichar_type");

    // ── GVariant: parse and read back ────────────────────────────────────
    GVariant *v = g_variant_new_int32(42);
    check(g_variant_get_int32(v) == 42, "GVariant: int32 round trip");
    g_variant_unref(v);

    // ── the main loop ────────────────────────────────────────────────────
    GMainContext *ctx = g_main_context_new();
    check(ctx != nullptr, "GMainContext: created");
    g_main_context_unref(ctx);

    std::printf("\n%s\n", failures == 0 ? "all ok" : "FAILURES");
    return failures == 0 ? 0 : 1;
}

#else

#include <cstdio>
int main() { std::printf("linux only\n"); return 0; }

#endif
