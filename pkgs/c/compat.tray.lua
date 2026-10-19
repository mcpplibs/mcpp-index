-- compat.tray — Cross-platform system tray icon library.
-- Header-only single-file C library (tray.h).
-- Usage: #define TRAY_IMPLEMENTATION before #include "tray.h" in one TU.
--
-- EUI-NEO uses tray in core/platform/tray_bridge.c for system tray support.
--
-- All `mcpp` paths are GLOBS relative to the verdir; the leading `*/`
-- absorbs the GitHub tarball's `tray-<sha>/` wrap layer.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "tray",
    description = "Cross-platform system tray icon library (header-only)",
    licenses    = {"MIT"},
    repo        = "https://github.com/zserge/tray",
    type        = "package",

    extensions = {
        autoupdate = {
            tag = "v${version}",
            url = "https://github.com/zserge/tray/archive/refs/tags/${tag}.tar.gz",
        },
    },

    xpm = {
        linux = {
            ["0.0.0-8dd1358"] = {
                url    = "https://github.com/zserge/tray/archive/8dd1358b92562faf7c032cf5362fa97cbc7e13e9.tar.gz",
                sha256 = "b08c9436bde3266ec4798d7829deb1b822b8930467d233b89fcb6044a0d59189",
            },
        },
        macosx = {
            ["0.0.0-8dd1358"] = {
                url    = "https://github.com/zserge/tray/archive/8dd1358b92562faf7c032cf5362fa97cbc7e13e9.tar.gz",
                sha256 = "b08c9436bde3266ec4798d7829deb1b822b8930467d233b89fcb6044a0d59189",
            },
        },
        windows = {
            ["0.0.0-8dd1358"] = {
                url    = "https://github.com/zserge/tray/archive/8dd1358b92562faf7c032cf5362fa97cbc7e13e9.tar.gz",
                sha256 = "b08c9436bde3266ec4798d7829deb1b822b8930467d233b89fcb6044a0d59189",
            },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        c_standard   = "c99",
        include_dirs = { "*" },
        -- tray is header-only; the anchor .c prevents an empty static library.
        generated_files = {
            ["mcpp_generated/tray_anchor.c"] = [[
                /* Anchor — tray is header-only via #define TRAY_IMPLEMENTATION */
                int mcpp_compat_tray_anchor(void) { return 0; }
            ]],
        },
        sources = { "mcpp_generated/tray_anchor.c" },
        targets = { ["tray"] = { kind = "lib" } },
        deps    = {},
    },
}
