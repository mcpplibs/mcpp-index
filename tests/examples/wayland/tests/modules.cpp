// The module wrappers, used the way a consumer would.
//
// The claim they make is narrow and testable: `import freedesktop.wayland.client;` gives
// you the same entities `#include <wayland-client.h>` does, spelled the same
// way. So this file includes NOTHING from wayland — no header — and still
// calls the stock API. If an export were missing, this would not compile; if a
// name had been renamed or wrapped, it would not compile either.
//
// tests/wayland.cpp is the header-based sibling. Both must pass: the module
// layer is an addition, not a replacement.

#ifdef __linux__

#include <cstdio>
#include <string>
#include <vector>

import freedesktop.wayland.client;
import freedesktop.wayland.server;
import freedesktop.wayland.util;

namespace {

int failures = 0;

void check(bool ok, const char *what)
{
    std::printf("%-58s %s\n", what, ok ? "ok" : "FAILED");
    if (!ok) ++failures;
}

// A node linked through wl_list, the shape every wayland consumer writes.
struct listener_node {
    int id;
    wl_list link;
};

} // namespace

int main()
{
    // ── 1. Client entities, with no #include anywhere ────────────────────
    {
        wl_display *d = wl_display_connect("mcpp-no-such-compositor");
        check(d == nullptr, "wl_display_connect through the module returns NULL");

        // A protocol interface object: generated code, exported by the module.
        check(std::string(wl_registry_interface.name) == "wl_registry",
              "wl_registry_interface arrives through freedesktop.wayland.client");
        check(std::string(wl_compositor_interface.name) == "wl_compositor",
              "so does wl_compositor_interface");
    }

    // ── 2. Server entities ───────────────────────────────────────────────
    {
        wl_display *s = wl_display_create();
        check(s != nullptr, "wl_display_create through freedesktop.wayland.server");
        if (s != nullptr) {
            wl_event_loop *loop = wl_display_get_event_loop(s);
            check(loop != nullptr, "wl_display_get_event_loop returns a loop");
            wl_display_destroy(s);
        }
    }

    // ── 3. The macros, as entities ───────────────────────────────────────
    // These are the names a module cannot export as macros; freedesktop.wayland.util
    // carries them as a constant, a template and ranges. Exercised here in a
    // consumer rather than only in the package's own test.
    {
        wl_list head;
        head.prev = &head;
        head.next = &head;

        listener_node a{1, {}}, b{2, {}};
        for (listener_node *n : {&a, &b}) {
            wl_list *prev = head.prev;
            n->link.prev = prev; n->link.next = &head;
            prev->next = &n->link; head.prev = &n->link;
        }

        std::vector<int> seen;
        for (listener_node *n : wl_list_each<&listener_node::link>(&head)) {
            seen.push_back(n->id);
        }
        check(seen.size() == 2 && seen[0] == 1 && seen[1] == 2,
              "wl_list_each walks a consumer's own list type");

        check(wl_container_of<&listener_node::link>(&b.link) == &b,
              "wl_container_of recovers the containing object");

        check(WL_MARSHAL_FLAG_DESTROY == 1u,
              "WL_MARSHAL_FLAG_DESTROY keeps upstream's value");
    }

    std::printf("\n%d check(s) failed\n", failures);
    return failures == 0 ? 0 : 1;
}

#else

int main() { return 0; }

#endif
