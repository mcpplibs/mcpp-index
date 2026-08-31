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

    // ⭐ 这八个函数在 mcpp4 之前根本够不着(`static inline` 无法从模块导出),
    // 而**没有任何测试调用过它们**,所以谁都没发现。缺口是从外面被一个最小
    // wlroots 合成器问出来的。下面每一行都是"再塌陷就编译不过"的探针。
    {
        // wayland-util.h 的定点数 —— 协议里每个亚像素坐标的载体
        check(wl_fixed_from_int(3) == 768, "wl_fixed_from_int");
        check(wl_fixed_to_double(wl_fixed_from_double(1.5)) == 1.5, "wl_fixed double 往返");
        check(wl_fixed_from_double(-1.5) == -384, "负数按上游 round() 舍入");

        // wayland-server-core.h 的 signal —— 每次 wlroots 挂监听都要它
        wl_signal sig{};
        wl_signal_init(&sig);
        check(sig.listener_list.next == &sig.listener_list, "wl_signal_init");
        wl_listener l{};
        l.notify = [](wl_listener *, void *) {};
        wl_signal_add(&sig, &l);
        check(wl_signal_get(&sig, l.notify) == &l, "wl_signal_add + wl_signal_get");
        wl_list_remove(&l.link);
    }

    std::printf("\n%d check(s) failed\n", failures);
    return failures == 0 ? 0 : 1;
}

#else

int main() { return 0; }

#endif
