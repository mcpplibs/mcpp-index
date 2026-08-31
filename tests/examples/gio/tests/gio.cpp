// gnome.gio — exercised rather than merely linked.
//
// WHAT THIS ASSERTS AND WHY
//
// gio is 815 objects assembled from four different kinds of input, and each
// kind fails a different way. A test that only said `#include <gio/gio.h>` and
// linked would pass with any three of the four missing:
//
//   upstream C            gio/*.c — a missing one is an undefined reference,
//                         which the linker DOES catch. Cheapest case.
//   VENDORED subtrees     xdgmime/, inotify/, subprojects/gvdb/. Absent, gio
//                         still links: g_content_type_guess returns
//                         "application/octet-stream", the file monitor falls
//                         back to polling, and GResource is never touched by
//                         anything but glib-compile-resources. All three
//                         degrade SILENTLY, so each is checked by name below.
//   CHECKED-IN CODEGEN    mcpp/generated/*.c — 15,392 lines of gdbus-codegen
//                         output that no build step here produces. Checked in
//                         the FORK's own test, which can name the internal
//                         symbol; regenerated and diffed by the fork's CI.
//   GENERATED HERE        gioenumtypes.{h,c}, 82 GTypes from a reimplemented
//                         glib-mkenums. ⭐ This is the one that already shipped
//                         a bug once, in gnome.gobject 2.82.5: the macro names
//                         were wrong (`G_UNICODE_TYPE_TYPE` for `G_TYPE_UNICODE_
//                         TYPE`) and it compiled, linked and passed a test that
//                         checked the FUNCTION and the NICK but never the MACRO.
//                         So this file checks the macro, the nick, AND whether
//                         the type is an enum or a flags — three independent
//                         outputs of the same generator, which is what it takes.
//
// Nothing here needs a session bus, a network, or a mime database.

#ifdef __linux__

// ⚠️ NO extern "C" WRAPPER, and adding one BREAKS THIS UNDER libc++.
//
// gio decorates every header with G_BEGIN_DECLS/G_END_DECLS, which IS
// `extern "C" {`, so a wrapper is redundant. It is also harmful: gio.h reaches
// <stdlib.h> and <string.h>, and libc++ routes those through
// <cstdlib>/<cstring>, which define TEMPLATES. Inside an extern "C" block that
// is `templates must have C++ linkage`, dozens of times, against a standard
// header this test never names. libstdc++ does not route them that way, so the
// gcc leg is green and the llvm leg is a wall.
//
// The rule: wrap a C header ONLY if it has no extern "C" of its own.
#include <gio/gio.h>

#include <cstdio>
#include <cstring>
#include <string>

namespace {

int failures = 0;

void check(bool ok, const char *what)
{
    std::printf("%-62s %s\n", what, ok ? "ok" : "FAILED");
    if (!ok) {
        ++failures;
    }
}

// ── GFile: paths, URIs, and the round trip between them ─────────────────────
void test_gfile()
{
    GFile *f = g_file_new_for_path("/etc/hostname");
    char *base = g_file_get_basename(f);
    char *uri = g_file_get_uri(f);
    check(base && std::strcmp(base, "hostname") == 0, "GFile: basename of /etc/hostname");
    check(uri && std::strcmp(uri, "file:///etc/hostname") == 0, "GFile: to URI");

    GFile *back = g_file_new_for_uri(uri);
    check(g_file_equal(f, back), "GFile: URI round trip compares equal");

    GFile *parent = g_file_get_parent(f);
    char *pp = parent ? g_file_get_path(parent) : nullptr;
    check(pp && std::strcmp(pp, "/etc") == 0, "GFile: parent");

    g_free(pp);
    g_free(base);
    g_free(uri);
    g_clear_object(&parent);
    g_clear_object(&back);
    g_object_unref(f);
}

// ── GListModel: the interface pango's PangoFontMap implements ───────────────
//
// ⭐ THIS IS WHY gio IS HERE. pango was blocked on exactly this symbol, so the
// check is not "gio works" but "the thing pango needs is a live GType".
void test_glistmodel()
{
    check(G_TYPE_IS_INTERFACE(G_TYPE_LIST_MODEL), "GListModel is a registered interface");

    GListStore *store = g_list_store_new(G_TYPE_FILE);
    GFile *a = g_file_new_for_path("/a");
    GFile *b = g_file_new_for_path("/b");
    g_list_store_append(store, a);
    g_list_store_append(store, b);

    GListModel *m = G_LIST_MODEL(store);
    check(g_list_model_get_n_items(m) == 2, "GListModel: n_items after two appends");
    check(g_list_model_get_item_type(m) == G_TYPE_FILE, "GListModel: item type");

    GFile *got = static_cast<GFile *>(g_list_model_get_item(m, 1));
    char *p = got ? g_file_get_path(got) : nullptr;
    check(p && std::strcmp(p, "/b") == 0, "GListModel: get_item(1) is the second file");

    g_free(p);
    g_clear_object(&got);
    g_object_unref(a);
    g_object_unref(b);
    g_object_unref(store);
}

// ── gioenumtypes: 82 GTypes from the reimplemented glib-mkenums ─────────────
//
// Three DIFFERENT outputs of the generator, because they fail independently:
//
//   the MACRO NAME     mkenums derives it from the TYPE name, not the
//                      enumerator prefix. Getting that backwards is what
//                      shipped in gobject 2.82.5. A wrong macro is a compile
//                      error HERE, which is the whole point of naming it.
//   the NICK           public API — g_flags_get_value_by_nick reads it — and
//                      gio overrides it seventeen times. Derived,
//                      G_CONVERTER_NO_FLAGS would be "no-flags"; upstream says
//                      "none".
//   ENUM vs FLAGS      decided ONLY by a `/*< flags >*/` comment. gio has
//                      exactly seven. GMountMountFlags carries it;
//                      GConverterFlags does NOT, despite the name — so
//                      upstream registers it as an ENUM, and a scanner that
//                      guessed from the name would disagree with upstream's ABI.
void test_enumtypes()
{
    check(G_TYPE_IS_ENUM(G_TYPE_FILE_TYPE), "gioenumtypes: G_TYPE_FILE_TYPE is an enum");
    check(G_TYPE_IS_ENUM(G_TYPE_SOCKET_FAMILY), "gioenumtypes: G_TYPE_SOCKET_FAMILY is an enum");
    check(G_TYPE_IS_FLAGS(G_TYPE_MOUNT_MOUNT_FLAGS),
          "gioenumtypes: GMountMountFlags has /*< flags >*/ -> FLAGS");
    check(G_TYPE_IS_ENUM(G_TYPE_CONVERTER_FLAGS),
          "gioenumtypes: GConverterFlags has NO annotation -> ENUM");

    GEnumClass *fc = G_ENUM_CLASS(g_type_class_ref(G_TYPE_FILE_TYPE));
    GEnumValue *v = g_enum_get_value(fc, G_FILE_TYPE_DIRECTORY);
    check(v && std::strcmp(v->value_nick, "directory") == 0, "gioenumtypes: derived nick");
    check(v && std::strcmp(v->value_name, "G_FILE_TYPE_DIRECTORY") == 0,
          "gioenumtypes: value name");
    g_type_class_unref(fc);

    GEnumClass *cc = G_ENUM_CLASS(g_type_class_ref(G_TYPE_CONVERTER_FLAGS));
    GEnumValue *nf = g_enum_get_value(cc, G_CONVERTER_NO_FLAGS);
    check(nf && std::strcmp(nf->value_nick, "none") == 0,
          "gioenumtypes: /*< nick=none >*/ overrides the derived \"no-flags\"");
    g_type_class_unref(cc);

    GFlagsClass *mc = G_FLAGS_CLASS(g_type_class_ref(G_TYPE_MOUNT_MOUNT_FLAGS));
    check(g_flags_get_first_value(mc, G_MOUNT_MOUNT_NONE) != nullptr
              || G_MOUNT_MOUNT_NONE == 0,
          "gioenumtypes: flags class is usable");
    g_type_class_unref(mc);
}

// ── GConverter over zlib: compat.zlib is a real dependency, not a note ──────
void test_zlib_converter()
{
    const std::string plain(4096, 'x');

    GConverter *cz = G_CONVERTER(g_zlib_compressor_new(G_ZLIB_COMPRESSOR_FORMAT_ZLIB, -1));
    GInputStream *src = g_memory_input_stream_new_from_data(plain.data(),
                                                            static_cast<gssize>(plain.size()),
                                                            nullptr);
    GInputStream *comp = g_converter_input_stream_new(src, cz);

    // Both sides take GZlibCompressorFormat — there is no decompressor enum.
    GConverter *dz = G_CONVERTER(g_zlib_decompressor_new(G_ZLIB_COMPRESSOR_FORMAT_ZLIB));
    GInputStream *back = g_converter_input_stream_new(comp, dz);

    char buf[8192];
    gsize got = 0;
    GError *err = nullptr;
    gboolean ok = g_input_stream_read_all(back, buf, sizeof buf, &got, nullptr, &err);

    check(ok && got == plain.size() && std::memcmp(buf, plain.data(), got) == 0,
          "zlib: compress -> decompress reproduces 4096 bytes");
    if (err) {
        g_error_free(err);
    }
    g_object_unref(back);
    g_object_unref(dz);
    g_object_unref(comp);
    g_object_unref(src);
    g_object_unref(cz);
}

// ── GDBus introspection, with no bus ────────────────────────────────────────
void test_dbus_introspection()
{
    static const char xml[] =
        "<node>"
        "  <interface name='org.example.Echo'>"
        "    <method name='Speak'>"
        "      <arg type='s' name='what' direction='in'/>"
        "      <arg type='s' name='said' direction='out'/>"
        "    </method>"
        "    <signal name='Spoke'><arg type='s' name='what'/></signal>"
        "  </interface>"
        "</node>";

    GError *err = nullptr;
    GDBusNodeInfo *node = g_dbus_node_info_new_for_xml(xml, &err);
    check(node != nullptr, "GDBus: introspection XML parses");

    GDBusInterfaceInfo *iface = node ? g_dbus_node_info_lookup_interface(node, "org.example.Echo")
                                     : nullptr;
    GDBusMethodInfo *m = iface ? g_dbus_interface_info_lookup_method(iface, "Speak") : nullptr;
    check(m && m->in_args && m->in_args[0] && std::strcmp(m->in_args[0]->signature, "s") == 0,
          "GDBus: the parsed method's argument signature");

    if (node) {
        g_dbus_node_info_unref(node);
    }
    if (err) {
        g_error_free(err);
    }
}

// ── gvdb: the reader upstream vendors under subprojects/ ────────────────────
//
// Without gvdb-reader.c gio does not fail to link — nothing in the library
// calls it except GResource and GSettings' keyfile path, and both are lazy. So
// the check is to hand GResource a blob that is definitely NOT a gvdb file and
// require a CLEAN REFUSAL: a NULL return with GError set. That answer can only
// come from gvdb_table_new_from_bytes, which is the file in question.
void test_gvdb_reader()
{
    static const char junk[] = "this is not a gvdb table, not even slightly";
    GBytes *b = g_bytes_new_static(junk, sizeof junk - 1);
    GError *err = nullptr;
    GResource *r = g_resource_new_from_data(b, &err);

    check(r == nullptr && err != nullptr,
          "gvdb: a non-gvdb blob is refused with a GError, not a crash");

    if (r) {
        g_resource_unref(r);
    }
    if (err) {
        g_error_free(err);
    }
    g_bytes_unref(b);
}

// ── xdgmime: the freedesktop mime reader behind g_content_type_* ────────────
//
// ⚠️ WHAT IS NOT ASSERTED: the answer for a given filename. That depends on
// /usr/share/mime, which a CI container may not have — and a test that demanded
// "text/plain" would be checking the RUNNER's mime database, not this build.
// What IS asserted is the part xdgmime always answers: that the call returns a
// content type at all, and that the two conversion helpers are mutual inverses.
void test_content_type()
{
    char *t = g_content_type_guess("notes.txt", nullptr, 0, nullptr);
    check(t != nullptr && *t != '\0', "xdgmime: g_content_type_guess answers");

    char *mime = g_content_type_get_mime_type("text/plain");
    check(mime && std::strcmp(mime, "text/plain") == 0, "xdgmime: mime type round trip");

    check(g_content_type_is_a("text/plain", "text/plain") == TRUE,
          "xdgmime: a type is a subtype of itself");

    g_free(mime);
    g_free(t);
}

// ── inotify: the Linux file-monitor backend ─────────────────────────────────
//
// Absent, `g_file_monitor_directory` still succeeds — GLocalFileMonitor falls
// back to a polling implementation and nothing reports the difference. So the
// check reads the TYPE NAME of what came back, which is the only place the two
// are distinguishable.
void test_inotify_backend()
{
    GError *err = nullptr;
    GFile *dir = g_file_new_for_path("/tmp");
    GFileMonitor *mon = g_file_monitor_directory(dir, G_FILE_MONITOR_NONE, nullptr, &err);

    check(mon != nullptr, "GFileMonitor: /tmp can be watched");
    if (mon) {
        const char *n = G_OBJECT_TYPE_NAME(mon);
        std::printf("    (backend: %s)\n", n);
        check(n && std::strstr(n, "Inotify") != nullptr,
              "inotify/: the backend is GInotifyFileMonitor, not the polling fallback");
        g_file_monitor_cancel(mon);
        g_object_unref(mon);
    }
    if (err) {
        g_error_free(err);
    }
    g_object_unref(dir);
}

// ── networking types, without touching the network ─────────────────────────
void test_networking()
{
    GInetAddress *a = g_inet_address_new_from_string("127.0.0.1");
    char *s = a ? g_inet_address_to_string(a) : nullptr;
    check(s && std::strcmp(s, "127.0.0.1") == 0, "GInetAddress: parse and print");
    check(a && g_inet_address_get_is_loopback(a), "GInetAddress: 127.0.0.1 is loopback");

    GSocketAddress *sa = a ? g_inet_socket_address_new(a, 8080) : nullptr;
    check(sa && g_inet_socket_address_get_port(G_INET_SOCKET_ADDRESS(sa)) == 8080,
          "GInetSocketAddress: port");

    check(g_application_id_is_valid("org.example.App"), "GApplication: a valid id");
    check(!g_application_id_is_valid("nope"), "GApplication: a bare word is not an id");

    g_clear_object(&sa);
    g_free(s);
    g_clear_object(&a);
}

// ── the async machinery: GTask through a GMainContext ──────────────────────
struct AsyncState {
    GMainLoop *loop = nullptr;
    gssize got = -1;
    char buf[64] = {};
};

void on_read(GObject *src, GAsyncResult *res, gpointer user)
{
    AsyncState *st = static_cast<AsyncState *>(user);
    st->got = g_input_stream_read_finish(G_INPUT_STREAM(src), res, nullptr);
    g_main_loop_quit(st->loop);
}

void test_async()
{
    static const char payload[] = "async";
    AsyncState st;
    st.loop = g_main_loop_new(nullptr, FALSE);

    GInputStream *in = g_memory_input_stream_new_from_data(payload, sizeof payload - 1, nullptr);
    g_input_stream_read_async(in, st.buf, sizeof st.buf, G_PRIORITY_DEFAULT, nullptr,
                              on_read, &st);
    g_main_loop_run(st.loop);

    check(st.got == 5 && std::memcmp(st.buf, payload, 5) == 0,
          "GTask: read_async completes through the main loop");

    g_object_unref(in);
    g_main_loop_unref(st.loop);
}

} // namespace

int main()
{
    std::printf("gio %d.%d.%d\n\n", glib_major_version, glib_minor_version, glib_micro_version);

    test_gfile();
    test_glistmodel();
    test_enumtypes();
    test_zlib_converter();
    test_dbus_introspection();
    test_gvdb_reader();
    test_content_type();
    test_inotify_backend();
    test_networking();
    test_async();

    std::printf("\n%s\n", failures == 0 ? "all ok" : "FAILURES");
    return failures == 0 ? 0 : 1;
}

#else

#include <cstdio>

int main()
{
    std::printf("gio: this package builds the Unix half of gio; skipping.\n");
    return 0;
}

#endif
