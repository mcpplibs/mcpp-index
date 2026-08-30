-- freedesktop.egl — libEGL.so.1, plus `import khronos.egl;`.
--
-- EGL is the window-system binding: `eglGetPlatformDisplay`,
-- `eglCreateContext`, `eglCreateWindowSurface`, `eglMakeCurrent`, and the
-- `eglCreateImage` / dmabuf import path. It is the piece that makes
-- compat.libgbm useful for RENDERING rather than only for allocation — the
-- canonical headless-GPU sequence is
--
--     int fd = open("/dev/dri/renderD128", O_RDWR);
--     struct gbm_device *gbm = gbm_create_device(fd);           // compat.libgbm
--     EGLDisplay dpy = eglGetPlatformDisplay(EGL_PLATFORM_GBM_KHR, gbm, NULL);
--
-- and without EGL the first two lines have nowhere to go. With compat.libdrm
-- (which turns the resulting buffer into a scanout via `drmModeAddFB2`) these
-- three are the whole KMS/DRM stack.
--
-- ─────────────────────────────────────────────────────────────────────────
-- SHAPE: a source build, because libglvnd is a separable project
--
-- EGL is a Khronos SPECIFICATION; the thing you link on Linux is libglvnd's
-- vendor-neutral `libEGL.so.1`, which dlopens the actual vendor driver. This
-- package builds it, from a fork of libglvnd v1.7.0 that adds mcpp build
-- support and patches no upstream file.
--
-- This entry REPLACES the earlier `compat.egl`, which bound `xim:libglvnd`.
-- That binding's own comment recorded the reason it was one — "libglvnd IS a
-- separable project, so by the criterion this should be a source build; it is
-- still a binding for effort alone" — and the criterion is the only thing that
-- decides. The effort was the generated dispatch (~1000 lines of Python over
-- the Khronos XML) plus `libGLdispatch.so.0`; the fork checks the generated
-- code in and builds both, so no Python and no second build system run here.
--
-- ─────────────────────────────────────────────────────────────────────────
-- ONE ENTRY, TWO LIBRARIES
--
-- `libGLdispatch.so.0` is built by a sibling workspace member that this one
-- reaches by PATH rather than through the index — see the fork's
-- `mcpp/egl/mcpp.toml`. GLVND exists to be the ONE dispatch point in a
-- process, and a second index entry would let a consumer name both and get two
-- package instances each building their own copy; soname reuse maps one and
-- silently discards the other. It becomes a published entry the day something
-- other than libEGL needs it — `libGL` and `libGLX` would.
--
-- ─────────────────────────────────────────────────────────────────────────
-- THE MODULE ADDS NO API, AND IS NAMED FOR THE SPECIFICATION
--
-- `import khronos.egl;` replaces `#include <EGL/egl.h>` and changes nothing
-- else: every exported name is upstream's, spelled upstream's way. Unlike
-- wayland's module this one needed no forwarders — EGL's entry points are
-- declared `EGLAPI … EGLAPIENTRY` with external linkage rather than
-- `static inline`, so `using ::name;` reaches all of them.
--
-- `khronos.` AND NOT `freedesktop.`, even though the package is
-- `freedesktop.egl`. EGL is a Khronos SPECIFICATION with several
-- implementations; libglvnd is one, and freedesktop is only where it is
-- hosted. A module name is global and permanent in a way a package name is
-- not, so it should name the INTERFACE's owner rather than whoever supplies
-- the definitions — otherwise swapping implementations forces every consumer
-- to edit its imports, which defeats a wrapper whose whole promise is that it
-- changes nothing but the include line.
--
-- `mcpplibs.openkal` paid for this lesson already: its 0.1.0 was withdrawn
-- rather than kept because it "placed the module a consumer imports under the
-- control of the implementation, which contradicts what the specification is
-- for". `freedesktop.wayland` resolves the other way for the same reason —
-- freedesktop DOES own the wayland protocol, so those modules are
-- `freedesktop.wayland.{client,server,util}`.
--
-- A side effect worth having: two EGL providers in one build now collide on
-- the module name instead of coexisting silently, which is what GLVND's
-- one-dispatch-point design wants anyway.
--
-- ONE CONSEQUENCE WORTH KNOWING: the module interface unit is compiled INTO
-- `libEGL.so.1`, because mcpp links every library target against all of a
-- package's sources. So this libEGL carries `DT_NEEDED` on libstdc++, libm and
-- libgcc_s, where the ecosystem payload's carries only libGLdispatch and libc.
-- It is not a defect and not specific to EGL — `freedesktop.wayland`'s
-- libraries have exactly the same five entries for exactly the same reason —
-- but a consumer counting a dispatch library's footprint should expect it.
--
-- The `EGL_*` CONSTANTS are macros and no module can export a macro, so a
-- consumer that needs `EGL_NO_DISPLAY` includes `<EGL/egl.h>` beside the
-- import — the same header the module was generated from. This is the same
-- split freedesktop.wayland-util exists to close for wayland; EGL's macros are
-- plain integer tokens rather than the statement-expressions and
-- `offsetof` arithmetic wayland's are, so there is nothing to reinterpret.
--
-- ─────────────────────────────────────────────────────────────────────────
-- WHERE THE VENDORS COME FROM, AND WHY THIS PACKAGE SETS NOTHING
--
-- Upstream compiles in `<prefix>/share/glvnd/egl_vendor.d` as the vendor
-- search path — right on a distribution, wrong the moment the payload is
-- relocated, the same shape as libgbm's compiled-in backend path. The fork
-- compiles in an EMPTY default on purpose, so a missing declaration surfaces
-- as "no vendor found" rather than as silently loading the HOST's driver into
-- a sandboxed process.
--
-- The mechanism for the real path is libglvnd's own
-- `__EGL_VENDOR_LIBRARY_DIRS`, and supplying it is the ENVIRONMENT's job:
-- `xim:mesa` declares it through the graphics discovery layer
-- (openxlings/xim-pkgindex#713), exactly as it declares `GBM_BACKENDS_PATH`
-- for compat.libgbm. So this package declares no runtime dependency on Mesa
-- either: a consumer that only wants the client-side API (`eglQueryString`,
-- `eglGetProcAddress`, the device enumeration extensions) needs no driver at
-- all, and one that wants to render adds compat.libgbm, which pins the payload.
--
-- X11 IS NOT A DEPENDENCY, and that is worth stating because it usually is.
-- `ENABLE_EGL_X11` is deliberately unset in the fork, so the X11 platform is
-- not compiled and Xorg reaches no consumer — including the headless GBM ones,
-- which have no display at all. Consumers that want it add compat.x11 and
-- define `USE_X11` for the header's own `#elif`.
package = {
    spec        = "1",
    namespace   = "freedesktop",
    name        = "egl",
    description = "libEGL — GLVND's vendor-neutral EGL dispatch, built from source, with a C++23 module",
    licenses    = {"MIT"},
    repo        = "https://github.com/mcpplibs/libglvnd",
    type        = "package",

    xpm = {
        linux = {
            -- libglvnd's version, not EGL's: the spec level is 1.5 and is a
            -- property of the dispatch rather than of this package. What a
            -- consumer pins here is which libglvnd it links.
            ["1.7.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/libglvnd/archive/refs/tags/v1.7.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/libglvnd/releases/download/1.7.0/libglvnd-1.7.0.tar.gz",
                },
                sha256 = "11347b0ffffbcb9ca51cd3941dff9ef923b21bb1e9469f3e5cff42ed487bf77d",
            },
        },
    },

    mcpp = "*/mcpp/egl/mcpp.toml",
}
