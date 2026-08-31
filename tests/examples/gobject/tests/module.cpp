// ⭐ THE MODULE, WHICH IS WHAT THE NAMESPACE PROMISES.
//
// In this index the namespace is the contract: `compat.xxx` is consumed with
// `#include`, an owner namespace like `gnome.xxx` exposes `import`. The test
// next to this file consumes gnome.gobject through its headers; this one consumes
// the same package through its module, so both doors are checked from the
// OUTSIDE — which is what an index example is for.
//
// ⚠️ THE TWO DOORS DO NOT COMPOSE, and that is GCC's rule rather than a choice
// here. A TU that imports the module AND textually includes a glib header
// reaches <time.h> twice — once through the module's global fragment, once
// directly — and the same `struct tm` from the same file becomes two entities:
//
//     error: conflicting declaration 'struct tm'
//     note: previous declaration as 'struct tm'   (of module gnome.glib)
//
// So a consumer picks ONE route, and which one is decided by macros: a module
// cannot carry them, and glib's are half its API. Code using `G_DEFINE_TYPE`,
// `G_OBJECT` or `G_TYPE_*` takes the header route. Code using the FUNCTION API
// — most of gio, and much of glib — imports and includes nothing.
#ifdef __linux__

import gnome.gobject;   // re-exports gnome.glib

#include <cstdio>
#include <cstring>

int main()
{
    int failures = 0;
    auto check = [&](bool ok, const char *what) {
        std::printf("%-58s %s\n", what, ok ? "ok" : "FAILED");
        if (!ok) ++failures;
    };

    std::printf("import gnome.gobject\n\n");

    // ⚠️ EVERY G_TYPE_* IS A MACRO, so this file reaches the type registry
    // through the FUNCTIONS those macros wrap. That is not a workaround — it
    // is the shape of the module route, and it is why the header route stays
    // supported next door.
    const GType obj = g_object_get_type();
    check(obj != 0, "g_object_get_type() — the registry answers");
    check(std::strcmp(g_type_name(obj), "GObject") == 0, "g_type_name(GObject)");
    check(g_type_is_a(obj, obj), "g_type_is_a on GObject itself");

    // The four GTypes build.mcpp's glib-mkenums reimplementation produced.
    // ⭐ Their MACRO names are what shipped wrong once (G_UNICODE_TYPE_TYPE for
    // G_TYPE_UNICODE_TYPE) — but a macro cannot come through a module, so this
    // route checks the FUNCTIONS and the header route next door checks the
    // macros. Two different outputs of one generator, tested separately on
    // purpose.
    check(g_unicode_script_get_type() != 0 && g_unicode_type_get_type() != 0
              && g_unicode_break_type_get_type() != 0 && g_normalize_mode_get_type() != 0,
          "the four generated enum GTypes register");

    // GValue, entirely through functions.
    // G_VALUE_INIT is a MACRO; zero-initialising is what it expands to.
    GValue v = {};
    g_value_init(&v, g_type_from_name("gint"));
    g_value_set_int(&v, 42);
    check(g_value_get_int(&v) == 42, "GValue: set and get an int");
    g_value_unset(&v);

    // A real object, created and reference-counted without a single macro.
    GObject *o = static_cast<GObject *>(g_object_new(obj, nullptr));
    check(o != nullptr, "g_object_new(GObject)");
    g_object_ref(o);
    g_object_unref(o);
    g_object_unref(o);

    // gnome.glib arrived through gnome.gobject, as glib-object.h -> glib.h does.
    char *s = g_strdup_printf("%d", 7);
    check(s != nullptr && std::strcmp(s, "7") == 0,
          "g_strdup_printf — gnome.glib came through gnome.gobject");
    g_free(s);

    std::printf("\n%s\n", failures == 0 ? "all ok" : "FAILURES");
    return failures == 0 ? 0 : 1;
}

#else
#include <cstdio>
int main() { std::printf("linux only\n"); return 0; }
#endif
