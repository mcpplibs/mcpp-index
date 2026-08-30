// freedesktop.wayland-cursor — the client-side pointer.
//
// WHAT CANNOT BE ASSERTED HERE, AND WHY THE FIRST VERSION OF THIS FILE CRASHED
//
// `wl_cursor_theme_load(name, size, shm)` is not callable without a compositor,
// and not merely inadvisable: line 410 of upstream's wayland-cursor.c is
//
//     theme->pool = shm_pool_create(shm, size * size * 4);
//
// which reaches `wl_shm_create_pool(shm, ...)` and dereferences the proxy with
// no null check. The first version of this test passed `nullptr` on the theory
// that only the theme PARSER would run — it segfaulted (exit 139). A `wl_shm`
// comes from a compositor's registry, so the buffer half of this library
// belongs in a program that has one, exactly as opening /dev/input/event*
// belongs outside tests/examples/libinput.
//
// WHAT IS ASSERTED IS STILL THE PART THAT CARRIES THE PACKAGING RISK: that the
// hand-written module wrapper exports every name, that the two PUBLIC structs
// are usable as values rather than opaque handles, and that libwayland-client
// is really linked in. The compiled-in cursor search path being empty — the
// other packaging decision — is checked in the fork's CI by grepping the
// binary, which is the only place it is visible.

#ifdef __linux__

#include <wayland-client.h>
#include <wayland-cursor.h>

#include <cstdio>
#include <cstdlib>
#include <cstring>

import freedesktop.wayland.cursor;

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
    // Taking the address of each: a name that vanished from the hand-written
    // module wrapper is a compile error here. That is the guarantee
    // mcpp/tools/genmod.py gives the client and server wrappers, which this
    // one is too small to justify.
    check(&wl_cursor_theme_load != nullptr,         "module exports wl_cursor_theme_load");
    check(&wl_cursor_theme_destroy != nullptr,      "module exports wl_cursor_theme_destroy");
    check(&wl_cursor_theme_get_cursor != nullptr,   "module exports wl_cursor_theme_get_cursor");
    check(&wl_cursor_image_get_buffer != nullptr,   "module exports wl_cursor_image_get_buffer");
    check(&wl_cursor_frame != nullptr,              "module exports wl_cursor_frame");
    check(&wl_cursor_frame_and_duration != nullptr, "module exports wl_cursor_frame_and_duration");

    // ── 2. The public structs are VALUES, not opaque handles ─────────────
    // `wl_cursor` and `wl_cursor_image` have their fields in the public header
    // and a client reads them to place the hotspot every time the pointer
    // enters a surface. Exporting them as opaque would compile here and fail
    // at the caller's first `image->hotspot_x`, which is why the fields are
    // touched rather than just the types named.
    wl_cursor_image img{};
    img.width = 24; img.height = 24;
    img.hotspot_x = 4; img.hotspot_y = 4; img.delay = 50;
    check(img.width == 24 && img.hotspot_x == 4 && img.delay == 50,
          "wl_cursor_image fields are reachable through the module");

    wl_cursor cur{};
    wl_cursor_image *one = &img;
    cur.image_count = 1;
    cur.images = &one;
    cur.name = const_cast<char *>("left_ptr");
    check(cur.image_count == 1 && cur.images[0]->hotspot_y == 4,
          "wl_cursor fields are reachable, including the images array");

    // ── 3. wl_cursor_frame works on a theme-less cursor ──────────────────
    // The animation helper is pure arithmetic over the images array — no shm,
    // no compositor — so it IS callable here, and it is the one piece of real
    // behaviour this test can exercise. A single-image cursor is not animated,
    // so every timestamp must select frame 0.
    check(wl_cursor_frame(&cur, 0) == 0,      "wl_cursor_frame(t=0) selects the only frame");
    check(wl_cursor_frame(&cur, 100000) == 0, "…and so does a far-future timestamp");

    uint32_t duration = 12345;   // wayland-cursor.h includes <stdint.h>, not <cstdint>
    const int f = wl_cursor_frame_and_duration(&cur, 0, &duration);
    std::printf("   frame_and_duration -> frame %d, duration %u\n", f, duration);
    check(f == 0, "wl_cursor_frame_and_duration agrees on the frame");

    // ── 4. It links the client for real ──────────────────────────────────
    // Unlike libwayland-egl, this library CALLS into libwayland-client — that
    // is exactly why §3's theme loader needs a live wl_shm. The two are in one
    // program by necessity rather than by convention.
    //
    // `wl_display_connect` AND NOT `wl_shm_create_pool`, which is what this
    // check said first and what the llvm leg rejected:
    //
    //     ld.lld: error: undefined symbol: wl_proxy_get_version
    //     >>>   wayland-cursor.o:(wl_shm_create_pool(wl_shm*, int, int))
    //
    // `wl_shm_create_pool` is one of wayland-scanner's `static inline`
    // protocol wrappers (mcpp/generated/wayland-client-protocol.h:2202), so
    // taking its address FORCES this translation unit to emit a copy — and
    // that copy calls `wl_proxy_marshal_flags` and friends, which live in
    // libwayland-client. GNU ld resolves those through the transitive
    // DT_NEEDED of libwayland-cursor; lld deliberately does not, and lld is
    // right: a program that names a symbol should link the library that
    // defines it.
    //
    // `wl_display_connect` is an ordinary exported function, so referencing it
    // proves the same thing without emitting anything. Same form the sibling
    // wayland-egl test uses, which is why that one was green on both legs.
    check(&wl_display_connect != nullptr,
          "libwayland-client is linked in (wl_display_connect)");

    // ── 5. Report the environment the ecosystem is expected to fill ───────
    // Not asserted: nothing in the index or in xim ships cursor themes yet, so
    // an unset XCURSOR_PATH is the current correct state rather than a defect.
    // When a theme package exists this becomes an assertion, exactly as the
    // RMLVO check in tests/examples/libxkbcommon did once xkeyboard-config
    // landed.
    const char *xp = std::getenv("XCURSOR_PATH");
    std::printf("   XCURSOR_PATH = %s\n",
                xp ? xp : "(unset — no cursor-theme package exists yet)");

    std::printf("\n%d check(s) failed\n", failures);
    return failures == 0 ? 0 : 1;
}

#else
int main() { return 0; }
#endif
