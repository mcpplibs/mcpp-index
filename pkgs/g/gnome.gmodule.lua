-- gnome.gmodule — part of GLib 2.82.5.
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
-- ❌ THE "gio IS NOT IN THIS INDEX" SECTION THAT USED TO BE HERE WAS WRONG.
--
-- It argued that reimplementing `gdbus-codegen` in `build.mcpp` was not
-- proportionate, and concluded that gio must be absent. The premise held; the
-- conclusion did not follow, because the build never needed the GENERATOR —
-- only its OUTPUT, which is a pure function of five XML files. That output is
-- now checked in and CI regenerates and diffs it.
--
-- `gnome.gio` is in this index. See gnome.glib for the full note.
--
-- ─────────────────────────────────────────────────────────────────────────
-- ⚠️ NAME WHAT YOU USE; DO NOT NAME glib
--
--     [dependencies]
--     gnome.gobject = "2.82.5"
--     gnome.gio     = "2.82.5"
--     gnome.gmodule = "2.82.5"
--     # gnome.glib arrives transitively
--
-- gobject and gmodule declare glib as a workspace PATH dependency — they are
-- built from one tree — and mcpp rejects a package requested both ways:
--
--     error: dependency 'gnome.glib' is requested as both a version dep
--            (by 'your-package') and a path dep (by 'gnome.gmodule.82.5')
--
-- Same shape as freedesktop.wayland-protocols-*. A consumer that only wants
-- glib itself may of course name it alone.
--
-- ─────────────────────────────────────────────────────────────────────────
-- ⚠️ NO extern "C" WRAPPER
--
-- glib decorates every header with G_BEGIN_DECLS, so a wrapper is redundant —
-- and harmful: glib.h pulls <stdlib.h>, which libc++ routes through <cstdlib>,
-- which defines TEMPLATES. Inside an extern "C" block that is
-- `templates must have C++ linkage`, dozens of times, against a header the
-- consumer never named. libstdc++ does not route them that way, so gcc is
-- green and clang is a wall.
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
    name        = "gmodule",
    description = "GModule 2.82.5 — portable dynamic module loading over dlopen",
    licenses    = {"LGPL-2.1-or-later"},
    repo        = "https://github.com/mcpplibs/glib",
    type        = "package",

    xpm = {
        linux = {
            ["2.82.5"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/glib/archive/refs/tags/2.82.5.tar.gz",
                    -- ⚠️ The container tag is `2.82.5-3`, not `2.82.5`. gitcode
                    -- refuses to REPLACE an asset of the same name in an
                    -- existing release, so each corrected tarball needs a new
                    -- container tag while the PACKAGE version stays upstream's.
                    -- Verified byte-identical to the GLOBAL tag archive.
                    CN     = "https://gitcode.com/mcpp-res/glib/releases/download/2.82.5-3/glib-2.82.5.tar.gz",
                },
                sha256 = "628b8f98a51238563704bf50817d575a46421acc32d987ca93edc941a1749d62",
            },
        },
    },

    mcpp = "*/mcpp/gmodule/mcpp.toml",
}
