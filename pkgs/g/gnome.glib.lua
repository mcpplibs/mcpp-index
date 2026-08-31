-- gnome.glib — part of GLib 2.82.5.
--
-- Upstream ships glib as one source tree producing FOUR separate shared
-- libraries, and this index follows that split: `gnome.glib`,
-- `gnome.gobject`, `gnome.gmodule` and `gnome.gio` are four packages from one
-- fork, because that is what a consumer links.
--
-- ─────────────────────────────────────────────────────────────────────────
-- THE PACKAGE VERSION IS UPSTREAM'S, WITH NOTHING APPENDED
--
-- `2.82.5` means GLib 2.82.5. When the fork changes and upstream does not, the
-- tag is RE-CUT IN PLACE and the `sha256` below moves — there is no
-- fork-revision component for a consumer to read.
--
-- ⚠️ The store keys on (name, version), so a machine that already extracted a
-- 2.82.5 keeps what it extracted. This tarball added `gnome.gio` and corrected
-- four generated macro names in `gnome.gobject`; if you do not see either,
-- clear that store entry. The container tag on the CN mirror is what tells the
-- two tarballs apart — see the `xpm` block.
--
-- ─────────────────────────────────────────────────────────────────────────
-- WHY A FORK
--
-- Generators, not line count. GLib has seven, and `build.mcpp` reimplements
-- six, so the tree carries no `sh` and no `python` in the build path:
--
--     gen-visibility-macros.py versions-macros    glib/gversionmacros.h
--     gen-visibility-macros.py visibility-macros  four *-visibility.h
--     configure_file                              glibconfig.h
--     configure_file                              gmodule/gmoduleconf.h
--     configure_file                              gio/gnetworking.h
--     gobject/glib-mkenums (816 lines of Python)  glib-enumtypes.{h,c}
--                                                 gio/gioenumtypes.{h,c}
--     configure_file                              config.h
--
-- The seventh, `gdbus-codegen`, is NOT reimplemented — its output is checked
-- in and CI regenerates and diffs it. See gnome.gio for why that is the right
-- shape rather than a shortcut.
--
-- glib-mkenums is reproduced for the inputs this build points it at — four
-- enums for gobject, 82 for gio — reading upstream's `.template` files from
-- the tree so a template change is picked up, and exiting non-zero if a
-- header stops yielding what it should: a silent drop would produce a library
-- missing `g_unicode_script_get_type` and the failure would land in a
-- consumer.
--
-- https://github.com/mcpplibs/glib
--
-- ─────────────────────────────────────────────────────────────────────────
-- THERE IS NO MODULE. glib's API is macro-heavy — `G_DEFINE_TYPE`,
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
-- It argued: two of gio's six generators are `gdbus-codegen`, an 8,351-line
-- Python program, and reimplementing it in `build.mcpp` is not proportionate
-- — therefore gio is absent and pango is blocked.
--
-- The premise was right and the conclusion did not follow. It conflated
--
--     reproducing the generator     ≠     obtaining its output
--
-- The build never needed the generator. It needed 15,392 lines of C that are
-- a pure function of five XML files and the codegen version. Those are now
-- produced once by a maintainer script, checked in, and REGENERATED AND
-- DIFFED BY CI — the same arrangement `freedesktop.wayland-protocols-*` had
-- already been using for its 195 generated files.
--
-- `gnome.gio` is in this index. pango is not blocked.
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
-- ─────────────────────────────────────────────────────────────────────────
-- ⭐ TWO WAYS TO CONSUME IT, AND YOU PICK ONE
--
--     import gnome.glib;          -- the module route
--     #include <glib.h>       -- the header route
--
-- The namespace is the contract in this index: `compat.xxx` means headers, an
-- owner namespace means the package exposes `import`. This module exports
-- 2,732 names.
--
-- ⚠️ THE TWO ROUTES DO NOT COMPOSE. A TU that imports the module AND textually
-- includes a glib header reaches <time.h> twice — once through the module's
-- global fragment, once directly — and the same `struct tm` from the same file
-- becomes two entities:
--
--     error: conflicting declaration 'struct tm'
--     note: previous declaration as 'struct tm'   (of module gnome.glib)
--
-- WHICH ROUTE IS DECIDED BY MACROS. A module cannot carry them, and glib's are
-- half its API — 1,337 `#define` against 1,312 declarations for glib, 1,679
-- against 1,753 for gio. `G_DEFINE_TYPE`, `G_OBJECT`, `g_signal_connect` and
-- every `G_TYPE_*` are macros, so code that defines a GObject subclass takes
-- the HEADER route. Code that uses the function API — most of gio — takes the
-- MODULE route and includes nothing at all.
--
-- The wrapper is GENERATED from upstream's public headers, so a name upstream
-- adds or removes cannot be silently missed. That is not a preference at this
-- size: four separate silent misses were found by consumers rather than by the
-- build — a brace inside a char literal that swallowed the rest of a file,
-- `G_DECLARE_INTERFACE` (which expands to the names rather than spelling
-- them), `<glibconfig.h>` being spelled without a `glib/` prefix, and glib's
-- habit of parenthesising a name to defend it from macro expansion.
--
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
                    -- ⚠️ The container tag is `2.82.5-4`, not `2.82.5`. gitcode
                    -- refuses to REPLACE an asset of the same name in an
                    -- existing release, so each corrected tarball needs a new
                    -- container tag while the PACKAGE version stays upstream's.
                    -- Verified byte-identical to the GLOBAL tag archive.
                    CN     = "https://gitcode.com/mcpp-res/glib/releases/download/2.82.5-4/glib-2.82.5.tar.gz",
                },
                sha256 = "38a175bcd8899f376b6540e2e3ef7450169205fc56bdb909cfb086a0438553e5",
            },
        },
    },

    mcpp = "*/mcpp/glib/mcpp.toml",
}
