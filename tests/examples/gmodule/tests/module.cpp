// ⭐ THE MODULE, WHICH IS WHAT THE NAMESPACE PROMISES.
//
// In this index the namespace is the contract: `compat.xxx` is consumed with
// `#include`, an owner namespace like `gnome.xxx` exposes `import`. The test
// next to this file consumes gnome.gmodule through its headers; this one consumes
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

import gnome.gmodule;   // re-exports gnome.glib

#include <cstdio>
#include <cstring>

int main()
{
    int failures = 0;
    auto check = [&](bool ok, const char *what) {
        std::printf("%-58s %s\n", what, ok ? "ok" : "FAILED");
        if (!ok) ++failures;
    };

    std::printf("import gnome.gmodule\n\n");

    check(g_module_supported(), "g_module_supported() through the module");

    // An enumerator, reached through its typedef — glib writes
    // `typedef enum { … } GModuleFlags;` and exporting the typedef is what
    // makes G_MODULE_BIND_LAZY visible. Nothing names it individually.
    GModuleFlags f = G_MODULE_BIND_LAZY;
    check(static_cast<int>(f) == 1, "an enumerator arrives with its typedef");

    GModule *m = g_module_open("/nonexistent/definitely-not-a-module.so", f);
    check(m == nullptr, "opening a missing module fails");
    const char *err = g_module_error();
    check(err != nullptr && std::strstr(err, "definitely-not-a-module") != nullptr,
          "…and g_module_error names the file — the dl loader is wired up");

    // ⭐ gnome.glib ARRIVES THROUGH gnome.gmodule, and it has to: glib is a
    // workspace PATH dependency, so a consumer that named it as well would get
    //   error: dependency 'gnome.glib' is requested as both a version dep
    //          and a path dep
    // gmodule.h includes glib.h, so the module re-exports gnome.glib to match.
    char *p = g_strdup("re-exported");
    check(p != nullptr && std::strcmp(p, "re-exported") == 0,
          "g_strdup — gnome.glib came through gnome.gmodule");
    g_free(p);

    std::printf("\n%s\n", failures == 0 ? "all ok" : "FAILURES");
    return failures == 0 ? 0 : 1;
}

#else
#include <cstdio>
int main() { std::printf("linux only\n"); return 0; }
#endif
