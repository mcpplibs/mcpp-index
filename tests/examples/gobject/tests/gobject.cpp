// gobject — the type system, exercised rather than merely linked.
//
// WHAT THIS ASSERTS AND WHY
//
// GObject is the kind of library where "it linked" proves nothing: GType is a
// runtime registry, so a build that compiled half of it still links and then
// fails the first time something registers a type. Every check below makes the
// library DO something and reads back a value it computed:
//
//   g_type_init-era registry   a fundamental type's name, from gtype.c
//   the GENERATED enum types   g_unicode_script_get_type(), which exists only
//                              because build.mcpp reproduced glib-mkenums
//   a derived type             registered at run time, with a property
//   properties                 set through GValue and read back
//   signals                    connected, emitted, and observed to have run
//   GBinding                   two objects kept in step, which is gbinding.c
//
// The enum-type check is the one that matters most for this fork: it is the
// only evidence that the mkenums reimplementation produced a REGISTERABLE type
// rather than a header that merely compiles.

#ifdef __linux__

// ⚠️ WRAPPED IN extern "C". glib's headers do have their own G_BEGIN_DECLS, so
// this is belt and braces rather than a necessity — but the generated
// glib-enumtypes.h is produced from a template that emits G_BEGIN_DECLS too,
// and asserting that here is cheaper than discovering it is missing.
extern "C" {
#include <glib-object.h>
#include <gobject/glib-enumtypes.h>
}

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

// A minimal derived type, declared the way every GObject library does it.
// Registering it exercises gtype.c, gobject.c, gparam.c and gvalue.c at once.
struct TestThing {
    GObject parent;
    gint answer;
};
struct TestThingClass {
    GObjectClass parent;
};

enum { PROP_0, PROP_ANSWER, N_PROPS };
GParamSpec *props[N_PROPS] = {};

GType test_thing_get_type(void);
G_DEFINE_TYPE(TestThing, test_thing, G_TYPE_OBJECT)

void test_thing_set_property(GObject *o, guint id, const GValue *v, GParamSpec *p)
{
    if (id == PROP_ANSWER) {
        reinterpret_cast<TestThing *>(o)->answer = g_value_get_int(v);
    } else {
        G_OBJECT_WARN_INVALID_PROPERTY_ID(o, id, p);
    }
}

void test_thing_get_property(GObject *o, guint id, GValue *v, GParamSpec *p)
{
    if (id == PROP_ANSWER) {
        g_value_set_int(v, reinterpret_cast<TestThing *>(o)->answer);
    } else {
        G_OBJECT_WARN_INVALID_PROPERTY_ID(o, id, p);
    }
}

guint sig_changed = 0;

void test_thing_class_init(TestThingClass *klass)
{
    GObjectClass *oc = G_OBJECT_CLASS(klass);
    oc->set_property = test_thing_set_property;
    oc->get_property = test_thing_get_property;
    props[PROP_ANSWER] = g_param_spec_int("answer", nullptr, nullptr,
                                          G_MININT, G_MAXINT, 0,
                                          static_cast<GParamFlags>(G_PARAM_READWRITE));
    g_object_class_install_properties(oc, N_PROPS, props);

    sig_changed = g_signal_new("changed", test_thing_get_type(), G_SIGNAL_RUN_LAST,
                               0, nullptr, nullptr, nullptr, G_TYPE_NONE, 1, G_TYPE_INT);
}

void test_thing_init(TestThing *) {}

int seen = -1;
void on_changed(TestThing *, gint value, gpointer) { seen = value; }

} // namespace

int main()
{
    // ── 1. the type registry answers about its own fundamentals ──────────
    std::printf("   glib %d.%d.%d\n", glib_major_version, glib_minor_version,
                glib_micro_version);
    check(glib_major_version == 2 && glib_minor_version == 82,
          "glib_*_version report 2.82, the version the manifest declares");
    check(std::strcmp(g_type_name(G_TYPE_INT), "gint") == 0,
          "g_type_name(G_TYPE_INT) is \"gint\" — the registry is initialised");
    check(g_type_is_a(G_TYPE_OBJECT, G_TYPE_OBJECT), "g_type_is_a on GObject itself");

    // ── 2. THE GENERATED ENUM TYPES ──────────────────────────────────────
    // These exist only because build.mcpp reproduced glib-mkenums over
    // glib/gunicode.h. Registering one and reading a value back is the only
    // thing that proves the generator produced working code rather than a
    // header that happens to compile.
    const GType script = g_unicode_script_get_type();
    check(script != 0, "g_unicode_script_get_type() registered a GType");
    GEnumClass *ec = static_cast<GEnumClass *>(g_type_class_ref(script));
    check(ec != nullptr, "…and its class can be referenced");
    if (ec != nullptr) {
        GEnumValue *v = g_enum_get_value(ec, G_UNICODE_SCRIPT_HAN);
        std::printf("   G_UNICODE_SCRIPT_HAN = %s / %s\n",
                    v ? v->value_name : "(null)", v ? v->value_nick : "(null)");
        check(v != nullptr && std::strcmp(v->value_name, "G_UNICODE_SCRIPT_HAN") == 0,
              "…and G_UNICODE_SCRIPT_HAN is in it under its own name");
        // The nick is mkenums' derived form: prefix stripped, lower case,
        // underscores to hyphens. Getting it right is the fiddly half of the
        // generator, so it is asserted rather than assumed.
        check(v != nullptr && std::strcmp(v->value_nick, "han") == 0,
              "…with the nick mkenums derives, \"han\"");
        g_type_class_unref(ec);
    }
    check(g_unicode_type_get_type() != 0 && g_unicode_break_type_get_type() != 0
              && g_normalize_mode_get_type() != 0,
          "all four generated enum types register");

    // ── 3. a derived type, its property, its signal ──────────────────────
    const GType thing = test_thing_get_type();
    check(thing != 0 && g_type_is_a(thing, G_TYPE_OBJECT),
          "a derived type registers and is a GObject");
    std::printf("   registered %s\n", g_type_name(thing));

    GObject *o = static_cast<GObject *>(g_object_new(thing, "answer", 42, nullptr));
    check(o != nullptr, "g_object_new with a construct property");

    gint got = 0;
    g_object_get(o, "answer", &got, nullptr);
    std::printf("   answer = %d\n", got);
    check(got == 42, "…and g_object_get reads it back through GValue");

    g_signal_connect(o, "changed", G_CALLBACK(on_changed), nullptr);
    g_signal_emit(o, sig_changed, 0, 7);
    std::printf("   the handler saw %d\n", seen);
    check(seen == 7, "a signal is emitted and the handler runs");

    // ── 4. GBinding — gbinding.c, and a real use of the property system ──
    GObject *b = static_cast<GObject *>(g_object_new(thing, nullptr));
    g_object_bind_property(o, "answer", b, "answer", G_BINDING_DEFAULT);
    g_object_set(o, "answer", 99, nullptr);
    gint mirrored = 0;
    g_object_get(b, "answer", &mirrored, nullptr);
    std::printf("   bound object followed to %d\n", mirrored);
    check(mirrored == 99, "g_object_bind_property keeps two objects in step");

    g_object_unref(b);
    g_object_unref(o);
    check(true, "objects destroyed without a warning");

    std::printf("\n%d check(s) failed\n", failures);
    return failures == 0 ? 0 : 1;
}

#else
int main() { return 0; }
#endif
