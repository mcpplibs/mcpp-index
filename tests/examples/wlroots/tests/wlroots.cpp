// wlroots — what can be asserted without a seat, a GPU or a compositor.
//
// WHAT THIS TEST IS FOR
//
// A compositor library is mostly untestable in CI: creating a backend wants a
// DRM master, a libseat session and an input device, and none of a runner's
// three exist. So the temptation is to assert that it linked, which is worth
// almost nothing — a package can link and still have compiled none of the
// files a consumer needs (this index has measured exactly that).
//
// Everything below is chosen to be an INTERMEDIATE QUANTITY: a value the
// library computes on its own, from data it carries, with no device involved.
// Each one names a specific generator in build.mcpp, so a failure says which
// one broke rather than "wlroots is broken":
//
//   version           → include/wlr/version.h
//   WLR_HAS_*         → include/wlr/config.h, and the feature set behind it
//   the PNP table     → pnpids.c, from the pinned hwdata
//   the box maths     → util/box.c, i.e. that ordinary sources compiled
//   the module itself → 986 `using ::` declarations that must all resolve
//   `namespace_`      → the C++ keyword-member rewrite
//
// ⚠️ NO extern "C" WRAPPER, and that is the point. wlroots' public headers
// contain not one `extern "C"` block, and two of them are not even valid C++
// (C99 `[static N]` array parameters). A C++ consumer cannot include them at
// all. `import wlroots;` is not a nicety here — it is the only way in.

#ifdef __linux__

// ⚠️ THE MODULE CANNOT CARRY MACROS, so `WLR_HAS_*` comes from the header.
// Macros are preprocessor entities and nothing exports them.
//
// ⚠️ AND ONLY A MACRO-ONLY HEADER MAY BE INCLUDED ALONGSIDE THE MODULE.
// `<wlr/config.h>` is nothing but `#define`s, so it is safe. `<wlr/version.h>`
// is not: it DECLARES wlr_version_get_major and has no `extern "C"` of its
// own, so including it here gives those three names C++ linkage while the
// module's have C linkage — two different entities, and the link fails with
//
//     undefined reference to `wlr_version_get_major()'
//
// naming a function the library plainly contains. The parentheses in that
// message are the tell: a mangled name, i.e. the wrong one. Take declarations
// from the module and macros from the header, never the same name from both.
#include <wlr/config.h>

import wlroots;

// `get_pnp_manufacturer` is INTERNAL to the DRM backend — declared in the
// private `backend/drm/util.h`, so it is not in the module and not in any
// installed header. Declared here because the generated table behind it is
// the one thing in this package whose failure looks exactly like success.
// `const char code[static 3]` and `const char *` are the same parameter after
// array-to-pointer decay, so this declaration is ABI-identical to upstream's.
extern "C" const char *get_pnp_manufacturer(const char *code);

#include <cstdio>
#include <cstring>

namespace {

int failures = 0;

void check(bool ok, const char *what)
{
    std::printf("%-62s %s\n", what, ok ? "ok" : "FAILED");
    if (!ok) {
        ++failures;
    }
}

} // namespace

int main()
{
    // ── 1. version.h was generated, and says what the manifest says ───────
    std::printf("   wlroots %d.%d.%d\n", wlr_version_get_major(),
                wlr_version_get_minor(), wlr_version_get_micro());
    check(wlr_version_get_major() == 0 && wlr_version_get_minor() == 20,
          "version.h reports 0.20, the version the manifest declares");

    // ── 2. config.h reports THIS build's features ────────────────────────
    // Not "some features are on" — the exact default set, so a feature that
    // silently stopped being compiled is a failure and not a shrug.
    std::printf("   drm=%d libinput=%d session=%d gles2=%d gbm=%d | "
                "x11=%d vulkan=%d xwayland=%d\n",
                WLR_HAS_DRM_BACKEND, WLR_HAS_LIBINPUT_BACKEND, WLR_HAS_SESSION,
                WLR_HAS_GLES2_RENDERER, WLR_HAS_GBM_ALLOCATOR,
                WLR_HAS_X11_BACKEND, WLR_HAS_VULKAN_RENDERER, WLR_HAS_XWAYLAND);
    check(WLR_HAS_DRM_BACKEND && WLR_HAS_LIBINPUT_BACKEND && WLR_HAS_SESSION
              && WLR_HAS_GLES2_RENDERER && WLR_HAS_GBM_ALLOCATOR,
          "the five default features are all on");
    check(!WLR_HAS_X11_BACKEND && !WLR_HAS_VULKAN_RENDERER && !WLR_HAS_XWAYLAND,
          "…and X11, Vulkan and Xwayland are off, as the manifest says");

    // ── 3. util/box.c: ordinary sources really were compiled ─────────────
    // Pure arithmetic on two rectangles, no device. If the package had linked
    // without compiling anything this would not resolve.
    wlr_box a{.x = 0, .y = 0, .width = 100, .height = 50};
    wlr_box b{.x = 60, .y = 20, .width = 100, .height = 50};
    wlr_box out{};
    const bool overlap = wlr_box_intersection(&out, &a, &b);
    std::printf("   intersection = %d,%d %dx%d\n", out.x, out.y, out.width, out.height);
    check(overlap && out.x == 60 && out.y == 20 && out.width == 40 && out.height == 30,
          "wlr_box_intersection computes the overlap");

    check(wlr_box_contains_point(&a, 10, 10) && !wlr_box_contains_point(&a, 10, 90),
          "wlr_box_contains_point agrees with the box it was given");

    // ── 4. the scene graph allocates ─────────────────────────────────────
    // wlr_scene_create needs no backend — it is the one non-trivial object a
    // test can build. It also proves types/scene/*.c compiled.
    wlr_scene *scene = wlr_scene_create();
    check(scene != nullptr, "wlr_scene_create without a backend");
    if (scene != nullptr) {
        const float colour[4] = {1.0f, 0.0f, 0.0f, 1.0f};
        wlr_scene_rect *rect = wlr_scene_rect_create(&scene->tree, 32, 16, colour);
        check(rect != nullptr, "…and a rect in it");
        // wlr_scene_rect_set_color is one of the five declarations that use
        // C99 `[static 4]`. Calling it is what proves the rewritten header
        // declares the same function the library defines.
        if (rect != nullptr) {
            const float other[4] = {0.0f, 1.0f, 0.0f, 1.0f};
            wlr_scene_rect_set_color(rect, other);
            check(true, "…and wlr_scene_rect_set_color, whose C99 [static 4] was rewritten");
        }
        wlr_scene_node_destroy(&scene->tree.node);
    }

    // ── 5. the C++ keyword-member rewrite ────────────────────────────────
    // `struct wlr_layer_surface_v1` has a member C++ cannot name. The header
    // this build compiles against renames it under `#ifdef __cplusplus`, at
    // the same offset. Reading it through a null-object offset would be UB, so
    // this asserts on a real object's storage instead.
    wlr_layer_surface_v1 ls{};
    ls.namespace_ = const_cast<char *>("panel");
    check(std::strcmp(ls.namespace_, "panel") == 0,
          "wlr_layer_surface_v1::namespace_ is reachable from C++");

    // ── 6. the PNP table generated from the PINNED hwdata ────────────────
    // The failure this catches looks exactly like a passing build: upstream's
    // gen_pnpids.sh reads /usr/share/hwdata/pnp.ids off the BUILD MACHINE, so
    // the manufacturer a monitor reports would depend on where the package was
    // built. `get_pnp_manufacturer` is wlroots-internal rather than exported,
    // so it is reached through the DRM backend header's declaration.
    //
    // "ACR" is the id in the EDID of the Acer monitor freedesktop.libdisplay-
    // info tests against, which is where the expected string comes from.
    const char *acr = get_pnp_manufacturer("ACR");
    const char *del = get_pnp_manufacturer("DEL");
    // ⚠️ "JJJ", not an arbitrary byte triple. PNP_ID keeps only the LOW FIVE
    // BITS of each character, so "\x01\x02\x03" packs to the same key as "ABC"
    // and returns AboCom System Inc. — measured, and it is upstream's encoding
    // rather than a bug here. An id that is genuinely absent has to be one
    // whose 15-bit key no entry occupies; "JJJ" (key 10570) is one of them.
    const char *nope = get_pnp_manufacturer("JJJ");
    std::printf("   ACR=%s  DEL=%s  JJJ=%s\n", acr ? acr : "(null)",
                del ? del : "(null)", nope ? nope : "(null)");
    check(acr != nullptr && std::strstr(acr, "Acer") != nullptr,
          "the pinned pnp.ids resolved ACR to Acer");
    check(del != nullptr && std::strstr(del, "Dell") != nullptr, "…and DEL to Dell");
    check(nope == nullptr, "…and an unoccupied key returns NULL, not a neighbour");

    std::printf("\n%d check(s) failed\n", failures);
    return failures == 0 ? 0 : 1;
}

#else
int main() { return 0; }
#endif
