// ⭐ THE MODULE, WHICH IS WHAT THE NAMESPACE PROMISES.
//
// In this index the namespace is the contract: `compat.xxx` is consumed with
// `#include`, an owner namespace like `gnome.xxx` exposes `import`. The test
// next to this file consumes gnome.gio through its headers; this one consumes
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

import gnome.gio;   // re-exports gnome.glib, gnome.gobject, gnome.gmodule

#include <cstdio>
#include <cstring>

int main()
{
    int failures = 0;
    auto check = [&](bool ok, const char *what) {
        std::printf("%-58s %s\n", what, ok ? "ok" : "FAILED");
        if (!ok) ++failures;
    };

    std::printf("import gnome.gio\n\n");

    // ⭐ THE SYMBOL pango WAS BLOCKED ON, through the module route.
    // G_TYPE_LIST_MODEL is a macro; g_list_model_get_type() is what it wraps.
    const GType lm = g_list_model_get_type();
    check(lm != 0, "g_list_model_get_type() — the interface is registered");
    check(std::strcmp(g_type_name(lm), "GListModel") == 0, "…and it is GListModel");

    // GFile: gio's function API needs no macros at all, which is the case the
    // module route is actually for.
    GFile *f = g_file_new_for_path("/etc/hostname");
    char *base = g_file_get_basename(f);
    char *uri = g_file_get_uri(f);
    check(base && std::strcmp(base, "hostname") == 0, "GFile: basename");
    check(uri && std::strcmp(uri, "file:///etc/hostname") == 0, "GFile: to URI");
    g_free(base);
    g_free(uri);

    // A GListStore holding GFiles — g_file_get_type() rather than G_TYPE_FILE.
    GListStore *store = g_list_store_new(g_file_get_type());
    g_list_store_append(store, f);
    check(g_list_model_get_n_items(reinterpret_cast<GListModel *>(store)) == 1,
          "GListModel: one item after append");
    g_object_unref(store);
    g_object_unref(f);

    // Streams, and the zlib converter — compat.zlib is a real dependency.
    const char plain[] = "the module route needs no macros";
    GInputStream *src = g_memory_input_stream_new_from_data(plain, sizeof plain - 1, nullptr);
    GConverter *cz = reinterpret_cast<GConverter *>(
        g_zlib_compressor_new(G_ZLIB_COMPRESSOR_FORMAT_ZLIB, -1));
    GInputStream *comp = g_converter_input_stream_new(src, cz);
    GConverter *dz = reinterpret_cast<GConverter *>(
        g_zlib_decompressor_new(G_ZLIB_COMPRESSOR_FORMAT_ZLIB));
    GInputStream *back = g_converter_input_stream_new(comp, dz);
    char buf[128] = {};
    gsize got = 0;
    g_input_stream_read_all(back, buf, sizeof buf, &got, nullptr, nullptr);
    check(got == sizeof plain - 1 && std::memcmp(buf, plain, got) == 0,
          "zlib: compress -> decompress round trip");
    g_object_unref(back); g_object_unref(dz);
    g_object_unref(comp); g_object_unref(src); g_object_unref(cz);

    // D-Bus introspection, with no bus.
    static const char xml[] =
        "<node><interface name='org.example.Echo'>"
        "<method name='Speak'><arg type='s' name='what' direction='in'/></method>"
        "</interface></node>";
    GDBusNodeInfo *node = g_dbus_node_info_new_for_xml(xml, nullptr);
    check(node != nullptr, "GDBus: introspection XML parses");
    if (node) g_dbus_node_info_unref(node);

    // The three siblings arrived through gnome.gio, matching gio.h's includes.
    char *s = g_strdup("glib");                                   // gnome.glib
    check(s && std::strcmp(s, "glib") == 0, "g_strdup — gnome.glib re-exported");
    g_free(s);
    check(g_object_get_type() != 0, "g_object_get_type — gnome.gobject re-exported");
    check(g_module_supported(), "g_module_supported — gnome.gmodule re-exported");

    std::printf("\n%s\n", failures == 0 ? "all ok" : "FAILURES");
    return failures == 0 ? 0 : 1;
}

#else
#include <cstdio>
int main() { std::printf("linux only\n"); return 0; }
#endif
