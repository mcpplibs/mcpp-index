-- freedesktop.wayland-egl — libwayland-egl, and the reason a Wayland client
-- could not use the GPU until now.
--
-- A Wayland client that draws with EGL needs three things: a `wl_surface` from
-- libwayland-client, an `EGLDisplay` from libEGL, and something to join them.
-- That something is `wl_egl_window_create(surface, w, h)` — the only way to get
-- an `EGLNativeWindowType` on Wayland, and it lives in this library and nowhere
-- else. Without it the sequence
--
--     wl_surface -> wl_egl_window -> eglCreateWindowSurface -> draw
--
-- has no second step.
--
-- WHY IT WAS MISSING, since the gap is instructive: the fork built the four
-- members a COMPOSITOR needs — client, server, util, scanner — and a compositor
-- renders into GBM buffers, so it never asks for this. The index therefore
-- looked complete from the server side and was unusable from the client side.
-- Upstream ships the source in the same tarball (`upstream/egl/`, 118 lines);
-- this was a member nobody had written, not a decision anyone had made.
--
-- ─────────────────────────────────────────────────────────────────────────
-- FIFTH MEMBER OF THE SAME TARBALL
--
-- `freedesktop.wayland`, `-server`, `-util`, `-scanner` and this one are five
-- index entries backed by ONE archive, each naming a different workspace
-- member. Adding this one changed the archive, so all five carry the new
-- sha256 in the same commit — see the note in that commit on why the tag was
-- left alone and a release ASSET was published instead.
package = {
    spec        = "1",
    namespace   = "freedesktop",
    name        = "wayland-egl",
    description = "libwayland-egl 1.26.0 — wl_egl_window, the bridge from a wl_surface to an EGL window surface",
    licenses    = {"MIT"},
    repo        = "https://github.com/mcpplibs/wayland",
    type        = "package",

    xpm = {
        linux = {
            ["1.26.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/wayland/releases/download/v1.26.0/wayland-1.26.0-mcpp3.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/wayland/releases/download/1.26.0/wayland-1.26.0-mcpp3.tar.gz",
                },
                sha256 = "b95537b21b0df2119a84ec8b3b833a564259e52fbbe2b119c5f9dd7cbaad55a0",
            },
        },
    },

    mcpp = "*/mcpp/egl/mcpp.toml",
}
