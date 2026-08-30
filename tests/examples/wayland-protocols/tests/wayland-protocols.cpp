// wayland-protocols, as a compositor would consume it.
//
// The packages ship the marshalling code wayland-scanner generates from
// upstream's XML. Three things can be wrong and none is a missing symbol:
//
//   1. THE HEADERS ARE THE PUBLIC INTERFACE. A consumer writes
//      `#include <xdg-shell-client-protocol.h>`, so the generated directory
//      has to be EXPOSED rather than build-private. This file compiling is the
//      first assertion, and freedesktop.wayland had exactly this bug once —
//      masked locally by a header the SubOS happened to carry.
//
//   2. THE INTERFACE TABLES MUST LINK. A header-only package sails past
//      compilation; `xdg_wm_base_interface` is a `wl_interface` OBJECT in the
//      generated .c, so reading it proves the .c files were compiled.
//
//   3. TWO TIERS MUST COMPOSE. stable and staging are separate packages
//      precisely so they can be used together; that they do is what this
//      member is for. (stable + unstable is the pair that cannot — 13 shared
//      symbols — which is upstream's semantics rather than a defect.)
//
// Nothing here connects: no compositor and no display.

#ifdef __linux__

#include <wayland-client.h>
#include <wayland-server.h>

#include <xdg-shell-client-protocol.h>          // stable
#include <xdg-shell-server-protocol.h>
#include <linux-dmabuf-v1-client-protocol.h>    // stable — the GBM bridge
#include <cursor-shape-v1-client-protocol.h>    // staging

#include <cstdio>
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

void report(const wl_interface &i, const char *want, const char *tier)
{
    std::printf("   %-8s %-28s version %d, %d method(s)\n",
                tier, i.name ? i.name : "(null)", i.version, i.method_count);
    check(i.name != nullptr && std::strcmp(i.name, want) == 0,
          (std::string(tier) + " " + want + " is linked in").c_str());
    check(i.method_count > 0, "…and it describes its requests");
}

} // namespace

int main()
{
    // ── 1. Both tiers linked, in one program ─────────────────────────────
    report(xdg_wm_base_interface,             "xdg_wm_base",             "stable");
    report(zwp_linux_dmabuf_v1_interface,     "zwp_linux_dmabuf_v1",     "stable");
    report(wp_cursor_shape_manager_v1_interface,
                                              "wp_cursor_shape_manager_v1", "staging");

    // ── 2. The server side was generated too ─────────────────────────────
    // `xdg_wm_base_send_ping` is a `static inline` only the SERVER header
    // defines. Client and server headers are separate scanner outputs and a
    // packaging mistake tends to lose one of them.
    check(reinterpret_cast<const void *>(&xdg_wm_base_send_ping) != nullptr,
          "the server-side headers were generated too");

    // ── 3. The library that marshals these is new enough ─────────────────
    // The generated code calls wl_proxy_marshal_flags, which arrived in
    // libwayland 1.19 — so the protocols and the client library are not from
    // different eras.
    check(reinterpret_cast<void *>(&wl_proxy_marshal_flags) != nullptr,
          "libwayland provides wl_proxy_marshal_flags");
    check(reinterpret_cast<void *>(&wl_display_create) != nullptr,
          "libwayland-server is linked for the compositor side");

    // ── 4. The GBM bridge protocol is the stable one ─────────────────────
    // linux-dmabuf is how a compositor hands a gbm_bo to a client, so it is
    // the protocol that ties this package to compat.libgbm. It lives in
    // stable/ upstream; the unstable spelling is one of the three this index
    // deliberately does not ship.
    check(zwp_linux_dmabuf_v1_interface.version >= 4,
          "linux-dmabuf is the stable v4+ interface, not the unstable spelling");

    std::printf("\n%d check(s) failed\n", failures);
    return failures == 0 ? 0 : 1;
}

// ── 1.49.1: the enum headers upstream installs ───────────────────────────────
//
// `wayland-scanner enum-header` output, which this fork did not generate before
// 1.49.1. wlroots 0.20 includes these from TEN of its PUBLIC headers, so a
// consumer of wlroots writing the ordinary `#include <wlr/...>` needs them on
// the include path — which is why they belong to THIS package rather than to
// wlroots.
//
// The enum header carries only the protocol's enums: no interface symbols and
// no libwayland dependency. Including it in a translation unit that links
// nothing proves exactly that.
#include <wayland-protocols/xdg-shell-enum.h>
#include <wayland-protocols/tablet-v2-enum.h>

static_assert(XDG_TOPLEVEL_STATE_MAXIMIZED == 1,
              "xdg-shell-enum.h did not come from the scanner");
static_assert(ZWP_TABLET_TOOL_V2_TYPE_PEN == 0x140,
              "tablet-v2-enum.h did not come from the scanner");

#else

int main() { return 0; }

#endif
