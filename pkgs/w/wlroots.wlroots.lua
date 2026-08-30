-- wlroots — the compositor library this whole stack was built toward.
--
-- Every dependency wlroots has was already in this index before this
-- descriptor existed: wayland-server/client/protocols/scanner/egl, libdrm,
-- pixman, xkbcommon, libinput, libudev, libseat, egl, glesv2, gbm and
-- libdisplay-info. This is the package that spends them.
--
--     [dependencies]
--     wlroots.wlroots = "0.20.2"
--
--     import wlroots;
--     wlr_scene *scene = wlr_scene_create();
--
-- ─────────────────────────────────────────────────────────────────────────
-- WHY A FORK
--
-- Six generators, which is what decides fork-versus-descriptor in this index
-- (the criterion is generators, not line count — cairo is 104k lines and
-- needed no fork):
--
--     45 Wayland protocols  ->  wayland-scanner, three outputs each
--     backend/drm/gen_pnpids.sh
--     render/gles2/shaders/embed.sh
--     configure_file  ->  include/wlr/config.h, include/config.h,
--                         include/wlr/version.h
--
-- Three are shell scripts upstream. The fork has no `sh` and no `python`:
-- `build.mcpp` is compiled and run by mcpp, so each generator is a function
-- in it. https://github.com/mcpplibs/wlroots
--
-- ─────────────────────────────────────────────────────────────────────────
-- ⚠️ `import wlroots;` IS NOT A CONVENIENCE — IT IS THE ONLY WAY IN
--
-- wlroots' 121 public headers contain NOT ONE `extern "C"` block, and two of
-- them are not valid C++ at all. Five declarations use C99's array-parameter
-- form:
--
--     void wlr_scene_rect_set_color(struct wlr_scene_rect *rect,
--                                   const float color[static 4]);
--
-- which g++ reports as `expected primary-expression before 'static'` — and
-- then, the parse never recovering, every LATER declaration in the file as
-- "has not been declared", which sends you looking for missing feature
-- guards. Three struct members are named `namespace`, `delete` and `class`.
--
-- So a C++ consumer cannot `#include <wlr/types/wlr_scene.h>` under any
-- arrangement of `extern "C"`. The fork's build program writes C++-safe copies
-- of the affected headers — `[static N]` reduced to `[N]`, the keyword members
-- given an `#ifdef __cplusplus` spelling at the same offset, the `#else` arm
-- upstream verbatim — and the module wraps the lot.
--
--     upstream C                            C++
--     wlr_layer_surface_v1::namespace       ::namespace_
--     wlr_input_method_v2::delete           ::delete_
--
-- Two limits, both inherent rather than defects in the wrapper:
--
--   * MACROS DO NOT CROSS A MODULE BOUNDARY. `WLR_HAS_*`, `wl_container_of`
--     and `wl_list_for_each` come from headers. `#include <wlr/config.h>`
--     alongside the import is safe — it is nothing but `#define`s.
--   * A HEADER THAT DECLARES SOMETHING MUST NOT BE INCLUDED ALONGSIDE THE
--     MODULE. `<wlr/version.h>` has no `extern "C"`, so including it gives
--     those three names C++ linkage while the module's have C linkage, and the
--     link fails with ``undefined reference to `wlr_version_get_major()'`` —
--     the parentheses in that message are the tell.
--
-- ─────────────────────────────────────────────────────────────────────────
-- FEATURES
--
--     wlroots.wlroots = { version = "0.20.2", default-features = false,
--                         features = ["session", "drm"] }
--
-- Default: `drm`, `libinput`, `session`, `gles2`, `gbm`; `udmabuf` is also
-- available. `drm` and `libinput` both require `session`, and the build
-- program says so at configure time rather than letting it become a link
-- failure naming `wlr_session_*`.
--
-- Not offered, each for a stated reason rather than an omission:
--
--     vulkan-renderer     needs glslang to compile four shaders to SPIR-V;
--                         glslang is not in this index, and a feature that
--                         cannot build is worse than an absent one
--     x11-backend         needs xcb + xcb-errors; the point of this stack is
--     xwayland            a compositor that does not drag X11 in
--     color-management    needs lcms2; `color_fallback.c` is built instead,
--                         which is upstream's own arrangement without it
--
-- ─────────────────────────────────────────────────────────────────────────
-- THE PINNED pnp.ids
--
-- The DRM backend turns a monitor's three-letter PNP id into a manufacturer
-- name from a table generated at build time. Upstream's `gen_pnpids.sh` reads
-- `/usr/share/hwdata/pnp.ids` OFF THE BUILD MACHINE, so the answer would
-- depend on where the package was built — the same trap
-- `freedesktop.libdisplay-info` documents. The fork pins hwdata v0.410 and
-- checks it in beside the generator.
--
-- The fork's generator is also stricter than upstream's: `PNP_ID` keeps only
-- the low five bits of each character, so ids differing in case collide —
-- hwdata really does carry `inu` alongside uppercase ids — and a collision is
-- reported naming both rather than emitted as two identical `case` labels.
package = {
    spec        = "1",
    namespace   = "wlroots",
    name        = "wlroots",
    description = "wlroots 0.20.2 — modular Wayland compositor library, with DRM/libinput/session/GLES2/pixman/GBM built and X11 left out",
    licenses    = {"MIT"},
    repo        = "https://github.com/mcpplibs/wlroots",
    type        = "package",

    xpm = {
        linux = {
            ["0.20.2"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/wlroots/archive/refs/tags/0.20.2.tar.gz",
                    -- ⚠️ THE CONTAINER TAG IS NOT THE PACKAGE VERSION.
                    --
                    -- The fork's tag was re-cut three times while this descriptor was
                    -- still unpublished — safe precisely because nothing in the
                    -- world had extracted it yet, which is the only time re-
                    -- cutting ever is — and gitcode refuses to REPLACE an asset
                    -- of the same name in an existing release. So each corrected
                    -- tarball needed a new container: `0.20.2`, `0.20.2-1` and
                    -- now `0.20.2-3`. Only the last is referenced; the earlier
                    -- two hold superseded bytes and are left alone rather than
                    -- deleted, so a stale reference fails a checksum rather than
                    -- a download.
                    --
                    -- Verified: this URL's sha256 equals the GLOBAL one's below.
                    CN     = "https://gitcode.com/mcpp-res/wlroots/releases/download/0.20.2-3/wlroots-0.20.2.tar.gz",
                },
                sha256 = "a9a9c2d8604486f655c919c5f94f90f75d04b09710eb3b151f2ec6ea866fd04e",
            },
        },
    },

    mcpp = "*/mcpp/wlroots/mcpp.toml",
}
