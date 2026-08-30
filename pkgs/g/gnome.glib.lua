-- gnome.glib — part of GLib 2.82.5.
--
-- Upstream ships glib as one source tree producing FOUR separate shared
-- libraries, and this index follows that split: `gnome.glib`,
-- `gnome.gobject` and `gnome.gmodule` are three packages from one fork,
-- because that is what a consumer links. (The fourth, gio, is absent — see
-- below.)
--
-- ─────────────────────────────────────────────────────────────────────────
-- WHY A FORK
--
-- Generators, not line count. GLib has six, and `build.mcpp` reimplements all
-- of them, so the tree carries no `sh` and no `python`:
--
--     gen-visibility-macros.py versions-macros    glib/gversionmacros.h
--     gen-visibility-macros.py visibility-macros  three *-visibility.h
--     configure_file                              glibconfig.h
--     configure_file                              gmodule/gmoduleconf.h
--     gobject/glib-mkenums (816 lines of Python)  glib-enumtypes.{h,c}
--     configure_file                              config.h
--
-- glib-mkenums is reproduced FOR THE ONE INPUT this build points it at —
-- `glib/gunicode.h`, four enums — rather than wholesale. It reads upstream's
-- `.template` files from the tree so a template change is picked up, and
-- exits non-zero if that header stops yielding four enums: a silent drop
-- would produce a library missing `g_unicode_script_get_type` and the failure
-- would land in a consumer.
--
-- https://github.com/mcpplibs/glib
--
-- ─────────────────────────────────────────────────────────────────────────
-- ⚠️ C++ CONSUMERS MUST WRAP THE INCLUDES
--
-- glib's headers carry their own `G_BEGIN_DECLS`, so this is usually fine —
-- but the generated `glib-enumtypes.h` comes from a template, and wrapping
-- costs nothing:
--
--     extern "C" {
--     #include <glib-object.h>
--     }
--
-- There is no module. glib's API is macro-heavy — `G_DEFINE_TYPE`,
-- `G_OBJECT`, `g_signal_connect` are all macros — and macros do not cross a
-- module boundary, so an `import` would hand a consumer the declarations and
-- withhold the half of the API that makes them usable. Compare
-- `wlroots.wlroots`, where the module is the ONLY way in because the headers
-- are not valid C++ at all: the shape follows what upstream's headers are,
-- not a house style.
--
-- ─────────────────────────────────────────────────────────────────────────
-- ⚠️ gio IS NOT IN THIS INDEX, AND THAT BLOCKS pango
--
-- Two of gio's six generators are `gdbus-codegen`, an 8,351-line Python
-- program that turns D-Bus interface XML into GObject skeletons. Seven gio
-- sources include its output and two more reference those, so it cannot be
-- dropped without changing what gio is, and reimplementing it in
-- `build.mcpp` is not proportionate.
--
-- pango uses `GListModel`, which lives in gio, so the text-layout line stops
-- here. Measured and recorded rather than left as an unexplained gap.
--
-- ─────────────────────────────────────────────────────────────────────────
-- LINUX ONLY
--
-- The generated `glibconfig.h` fixes `G_OS_UNIX`, the POSIX thread
-- implementation and the poll constants, and `build.mcpp` refuses to run
-- anywhere else rather than emitting a header that is quietly wrong. The
-- upstream tree also contains two `COPYING` symlinks, which a Windows
-- extraction would not survive — one more reason the descriptor offers
-- `linux` alone.
package = {
    spec        = "1",
    namespace   = "gnome",
    name        = "glib",
    description = "GLib 2.82.5 — data structures, the main loop, Unicode, GVariant and GRegex",
    licenses    = {"LGPL-2.1-or-later"},
    repo        = "https://github.com/mcpplibs/glib",
    type        = "package",

    xpm = {
        linux = {
            ["2.82.5"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/glib/archive/refs/tags/2.82.5.tar.gz",
                    -- ⚠️ The container tag is `2.82.5-1`, not `2.82.5`. The fork's
                    -- tag was re-cut once while this descriptor was still
                    -- unpublished — safe only because nothing had extracted it
                    -- yet — and gitcode refuses to REPLACE an asset of the same
                    -- name in an existing release. Verified: this URL's sha256
                    -- equals the GLOBAL tarball's.
                    CN     = "https://gitcode.com/mcpp-res/glib/releases/download/2.82.5-1/glib-2.82.5.tar.gz",
                },
                sha256 = "98118dacf3ebc9d5aefba340e9248385f1643b76ca672b864c37a3e4fb71caf6",
            },
        },
    },

    mcpp = "*/mcpp/glib/mcpp.toml",
}
