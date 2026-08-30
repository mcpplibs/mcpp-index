// freedesktop.wayland-egl — the step that used to be missing.
//
// WHAT THIS CAN AND CANNOT ASSERT, decided by what the library actually is.
//
// libwayland-egl is 118 lines and holds no connection: `wl_egl_window_create`
// allocates a struct, stores the `wl_surface *` it was handed, and records a
// size. It calls no client function and talks to no compositor — an EGL
// implementation later reads and writes the struct through
// `wayland-egl-backend.h`.
//
// So a CI runner with no compositor can exercise the whole library honestly.
// What it cannot do is `eglCreateWindowSurface`, which needs a real
// `wl_display` from a real compositor — asserting that here would only assert
// that the runner has a desktop session.
//
// THE BACKEND HEADER IS INCLUDED ON PURPOSE. `wayland-egl-core.h` exposes four
// functions and an opaque type, so through it alone the only observable is
// "create returned non-null". `wayland-egl-backend.h` is the contract this
// library has with an EGL implementation — Mesa includes it — and reading the
// struct through it is what lets the test check that create and resize wrote
// what they claim.
//
// The `wl_surface *` is a null pointer ON PURPOSE: upstream stores it without
// dereferencing (wayland-egl.c:93), so this exercises the real path, and the
// test can then assert the pointer round-tripped.

#ifdef __linux__

#include <wayland-client.h>
#include <wayland-egl.h>
#include <wayland-egl-backend.h>

#include <cstdio>
#include <cstring>

import freedesktop.wayland.egl;

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
    // ── 1. The module carries the API ────────────────────────────────────
    // Taking the address of each is what makes this a check rather than a
    // comment: a name that vanished from the module is a compile error here,
    // which is the guarantee genmod.py gives the client and server wrappers
    // and that this hand-written module needs by other means.
    check(&wl_egl_window_create != nullptr,            "module exports wl_egl_window_create");
    check(&wl_egl_window_destroy != nullptr,           "module exports wl_egl_window_destroy");
    check(&wl_egl_window_resize != nullptr,            "module exports wl_egl_window_resize");
    check(&wl_egl_window_get_attached_size != nullptr, "module exports wl_egl_window_get_attached_size");

    // ── 2. The bridge itself ─────────────────────────────────────────────
    // This is the call that did not exist in this ecosystem before: the only
    // way to turn a wl_surface into something EGL can render into.
    wl_egl_window *w = wl_egl_window_create(nullptr, 640, 480);
    check(w != nullptr, "wl_egl_window_create(surface, 640, 480)");
    if (w == nullptr) {
        std::printf("\n%d check(s) failed\n", failures);
        return 1;
    }

    // ── 3. It wrote what it was given ────────────────────────────────────
    // Read back through the backend header, which is how Mesa reads it.
    // `version` matters most of the three: an EGL implementation switches on
    // it, and it is the field upstream casts away constness to set.
    std::printf("   version=%ld  size=%d x %d\n",
                (long)w->version, w->width, w->height);
    check(w->version == WL_EGL_WINDOW_VERSION, "…and stamped WL_EGL_WINDOW_VERSION");
    check(w->width == 640 && w->height == 480, "…and recorded 640 x 480");
    check(w->surface == nullptr,               "…and round-tripped the wl_surface pointer");

    // ── 4. attached size is 0 BEFORE any EGL implementation attaches ─────
    // Not an oversight and not the creation size: `attached_width/height` are
    // written by the EGL side when it attaches a buffer, and `create` calloc's
    // them to zero. The first version of this test asserted 640 x 480 here and
    // was wrong — the check now encodes the real contract, which is that a
    // window nothing has rendered into reports nothing attached.
    int aw = -1, ah = -1;
    wl_egl_window_get_attached_size(w, &aw, &ah);
    std::printf("   attached size before any EGL attach: %d x %d\n", aw, ah);
    check(aw == 0 && ah == 0, "get_attached_size reports 0 x 0 until EGL attaches");

    // ── 5. Resize is what a client calls on every configure event ────────
    wl_egl_window_resize(w, 800, 600, 0, 0);
    check(w->width == 800 && w->height == 600, "wl_egl_window_resize updated the geometry");

    // A rejected resize, which is a real branch: upstream returns early on a
    // non-positive dimension rather than storing it, so the previous size must
    // survive. Same guard `create` uses.
    wl_egl_window_resize(w, 0, 600, 0, 0);
    check(w->width == 800 && w->height == 600, "…and a width of 0 is refused, not stored");

    wl_egl_window_destroy(w);
    check(true, "wl_egl_window_destroy");

    // ── 6. create rejects a degenerate size ──────────────────────────────
    check(wl_egl_window_create(nullptr, 0, 480) == nullptr,
          "wl_egl_window_create refuses a width of 0");

    // ── 7. The two halves agree on the linkage they share ────────────────
    // `wl_display_connect` comes from libwayland-client and is NOT in
    // libwayland-egl — the fork's CI asserts that separation on the library,
    // and this asserts the consumer side: both are reachable from one program,
    // which is the arrangement a real client is in.
    check(&wl_display_connect != nullptr,
          "libwayland-client is in the same program (wl_display_connect)");

    std::printf("\n%d check(s) failed\n", failures);
    return failures == 0 ? 0 : 1;
}

#else
int main() { return 0; }
#endif
