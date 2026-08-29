// compat.wayland — behavioral test, runnable with no compositor.
//
// Two seams, and the second is the one a compositor author depends on.
//
//   1. THE CLIENT LIBRARY, which the package puts on the link line itself.
//      `wl_display_connect` on a machine with no compositor must return NULL
//      cleanly -- that exercises the real library (it reads WAYLAND_DISPLAY,
//      builds a socket path and fails to connect) without needing a server.
//
//   2. THE LIBRARIES THE PACKAGE DELIBERATELY DOES NOT LINK. libwayland-server
//      is harvested into the farm but kept off `ldflags`, so a consumer reaches
//      it by adding `-lwayland-server` to its own build — which this member's
//      mcpp.toml does. If the farm ever stops carrying the server library, the
//      documented escape hatch silently stops working; this file is what turns
//      that into a link error here instead.

#ifdef __linux__

#include <wayland-client.h>
#include <wayland-server-core.h>

#include <dlfcn.h>

#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <string>

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
    // ── 1. Headers resolved from the flat include root ───────────────────
    check(WL_DISPLAY_ERROR_INVALID_OBJECT == 0,
          "wayland-client.h provides the core protocol enums");

    // ── 2. Both libraries are really linked ──────────────────────────────
    for (const char *sym : {"wl_display_connect", "wl_display_disconnect",
                            "wl_proxy_marshal", "wl_registry_interface"}) {
        check(::dlsym(RTLD_DEFAULT, sym) != nullptr,
              (std::string("libwayland-client exports ") + sym).c_str());
    }
    // This one comes from the farm via the consumer's own -lwayland-server,
    // not from anything this package puts on the link line.
    for (const char *sym : {"wl_display_create", "wl_display_destroy"}) {
        check(::dlsym(RTLD_DEFAULT, sym) != nullptr,
              (std::string("libwayland-server exports ") + sym).c_str());
    }

    // ── 3. Connecting with no compositor fails cleanly ───────────────────
    // Deliberately points at a socket that cannot exist, so the result does
    // not depend on whether the machine running the test has a session.
    ::setenv("WAYLAND_DISPLAY", "mcpp-no-such-compositor", 1);
    ::unsetenv("WAYLAND_SOCKET");
    wl_display *dpy = wl_display_connect(nullptr);
    std::printf("   wl_display_connect (no compositor) = %p\n", (void *)dpy);
    check(dpy == nullptr,
          "wl_display_connect returns NULL rather than crashing");
    if (dpy != nullptr) {
        wl_display_disconnect(dpy);
    }

    // ── 4. The server library can actually build a display ───────────────
    // No socket is bound, so this needs no privileges and no session; it is
    // the cheapest proof that libwayland-server is functional and not merely
    // present.
    wl_display *server = wl_display_create();
    std::printf("   wl_display_create = %p\n", (void *)server);
    check(server != nullptr, "wl_display_create succeeds (server library live)");
    if (server != nullptr) {
        wl_display_destroy(server);
    }

    std::printf("\n%d check(s) failed\n", failures);
    return failures == 0 ? 0 : 1;
}

#else

int main()
{
    return 0;
}

#endif
