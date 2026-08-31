-- freedesktop.wayland-cursor — the pointer image a Wayland client sets on
-- itself.
--
-- Wayland has NO SERVER-SIDE CURSOR. A client that wants a pointer loads a
-- cursor theme, turns the image into a `wl_buffer`, and attaches it to a
-- surface it hands to `wl_pointer.set_cursor`. This library is the first two
-- steps — without it every application parses the XCursor file format itself,
-- which is what `upstream/cursor/xcursor.c` is.
--
-- NOT `compat.xcursor`, which is X11's `libXcursor.so.1` and talks to an X
-- server. This one has no X dependency and produces a `wl_buffer` via `wl_shm`.
--
-- ─────────────────────────────────────────────────────────────────────────
-- THE COMPILED-IN THEME PATH IS EMPTY, AND THAT IS A DECISION
--
-- `xcursor.c:493` bakes in
--
--     "~/.icons:/usr/share/icons:/usr/share/pixmaps:~/.cursors:"
--     "/usr/share/cursors/xorg-x11:" ICONDIR
--
-- — a list of HOST paths. After relocation those name the host machine's
-- themes, which is the same silent host edge that gave Vulkan an llvmpipe
-- device instead of the GPU.
--
-- `xcursor_library_path()` reads `getenv("XCURSOR_PATH")` first and returns it
-- verbatim when set (`xcursor.c:515`), so the compiled-in list is a FALLBACK
-- and the environment is the real interface — the same shape as
-- `LIBINPUT_QUIRKS_DIR` and `XKB_CONFIG_ROOT`, and the same answer: compile it
-- empty, let the ecosystem declare `XCURSOR_PATH`.
--
-- What that costs, named rather than discovered: a client with no
-- `XCURSOR_PATH` gets a theme with no cursors from `wl_cursor_theme_load`.
-- Visible, rather than a pointer that works on the developer's machine and
-- nowhere else. Nothing in this index or in xim ships cursor themes yet; when
-- something does, it declares the variable, exactly as `xim:xkeyboard-config`
-- declares `XKB_CONFIG_ROOT`.
--
-- ─────────────────────────────────────────────────────────────────────────
-- SIXTH AND LAST MEMBER OF THE SAME TARBALL
--
-- `freedesktop.wayland`, `-server`, `-util`, `-scanner`, `-egl` and this one
-- are six index entries backed by ONE archive, each naming a different
-- workspace member. With this one the fork builds every library upstream
-- ships; there is no seventh.
--
-- Adding it changed the archive, so all six carry the new sha256 in the same
-- commit — and the tag was left alone with a new release ASSET published
-- instead, for the reason recorded when `-egl` was added.
package = {
    spec        = "1",
    namespace   = "freedesktop",
    name        = "wayland-cursor",
    description = "libwayland-cursor 1.26.0 — load an XCursor theme into a wl_buffer, for clients that set their own pointer",
    licenses    = {"MIT"},
    repo        = "https://github.com/mcpplibs/wayland",
    type        = "package",

    xpm = {
        linux = {
            ["1.26.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/wayland/releases/download/v1.26.0/wayland-1.26.0-mcpp4.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/wayland/releases/download/1.26.0/wayland-1.26.0-mcpp4.tar.gz",
                },
                sha256 = "9bce2cc00c61399a3c2fb15e730b664073694154860bc5e2b4496bcf09e55e52",
            },
        },
    },

    mcpp = "*/mcpp/cursor/mcpp.toml",
}
