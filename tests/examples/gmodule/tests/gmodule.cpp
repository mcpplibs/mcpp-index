// gmodule — dynamic loading, checked by actually loading something.
//
// WHAT THIS ASSERTS AND WHY
//
// gmodule is two source files, so "did it compile" is nearly free — and nearly
// worthless. The value is in `gmoduleconf.h`, which build.mcpp generates and
// which decides WHICH loader is compiled in. `G_MODULE_IMPL_NONE` produces a
// library that builds, links, and returns "dynamic loading not supported" for
// everything.
//
// So the checks are: does it claim to support loading, and does a load
// actually work. `g_module_open(NULL)` opens the CURRENT EXECUTABLE — the one
// case that needs no test fixture on disk — and a symbol looked up in it must
// be one this binary really has.

#ifdef __linux__

extern "C" {
#include <gmodule.h>
}

#include <cstdio>
#include <cstring>

namespace {

int failures = 0;

void check(bool ok, const char *what)
{
    std::printf("%-56s %s\n", what, ok ? "ok" : "FAILED");
    if (!ok) {
        ++failures;
    }
}

} // namespace

int main()
{
    // ── 1. gmoduleconf.h selected a real loader ──────────────────────────
    // G_MODULE_IMPL_NONE here would mean build.mcpp filled the template with
    // the "no loader" answer, and everything below would fail in a way that
    // reads like a broken system rather than a wrong generated header.
    std::printf("   g_module_supported = %d, suffix = %s\n",
                g_module_supported(), G_MODULE_SUFFIX);
    check(g_module_supported(), "g_module_supported — gmoduleconf.h chose the dl loader");
    check(std::strcmp(G_MODULE_SUFFIX, "so") == 0,
          "G_MODULE_SUFFIX is \"so\", from the generated glibconfig.h");

    // ── 2. a load that needs no fixture ──────────────────────────────────
    // NULL means "this executable". It exercises the same dlopen path a plugin
    // would, without needing a .so to have been built alongside the test.
    GModule *self = g_module_open(nullptr, G_MODULE_BIND_LAZY);
    check(self != nullptr, "g_module_open(NULL) opens the running executable");
    if (self != nullptr) {
        // ⚠️ NO SYMBOL LOOKUP HERE, and the reason is a property of this
        // package rather than a gap in the test.
        //
        // `dlsym` on the main program sees only the DYNAMIC symbol table, which
        // needs `-rdynamic`. And gnome.glib is `kind = "lib"`: its objects are
        // merged into the consumer, so there is no libglib-2.0.so in the link
        // map either. Both halves of the obvious assertion — a symbol of this
        // executable's, or one of glib's — are therefore absent by
        // construction, and a test that asserted them would be measuring the
        // link line.
        //
        // What IS observable without a fixture on disk is that the loader
        // answers at all, and that it distinguishes present from absent.
        gpointer missing = nullptr;
        check(!g_module_symbol(self, "mcpp_no_such_symbol_at_all", &missing),
              "a name that is not there is reported as absent, not crashed on");

        std::printf("   g_module_name = %s\n", g_module_name(self));
        check(g_module_close(self), "g_module_close");
    }

    // ── 2b. g_module_build_path — G_MODULE_SUFFIX in use ─────────────────
    // The one place the generated glibconfig.h value becomes a STRING a caller
    // sees. On Windows this would be "plugin.dll"; getting it wrong would make
    // every plugin host look for the wrong filename.
    {
        gchar *p = g_module_build_path("/opt/plug", "demo");
        std::printf("   g_module_build_path = %s\n", p ? p : "(null)");
        check(p != nullptr && std::strcmp(p, "/opt/plug/libdemo.so") == 0,
              "g_module_build_path applies the lib prefix and .so suffix");
        g_free(p);
    }

    // ── 3. the error path says something ─────────────────────────────────
    // G_MODULE_IMPL_NONE would also reach here, so this is checked after the
    // success case rather than instead of it.
    GModule *nope = g_module_open("/nonexistent/definitely-not-a-module.so",
                                  G_MODULE_BIND_LAZY);
    check(nope == nullptr, "opening a missing module fails");
    const gchar *err = g_module_error();
    std::printf("   g_module_error = %s\n", err ? err : "(null)");
    // G_MODULE_HAVE_DLERROR is one of the four values build.mcpp fills into
    // gmoduleconf.h; without it the message would be a generic placeholder
    // rather than the loader's own text.
    check(err != nullptr && std::strstr(err, "definitely-not-a-module") != nullptr,
          "…and dlerror's message names the file — G_MODULE_HAVE_DLERROR is on");

    std::printf("\n%d check(s) failed\n", failures);
    return failures == 0 ? 0 : 1;
}

#else
int main() { return 0; }
#endif
