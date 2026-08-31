-- gnome.gobject — part of GLib 2.82.5.
--
-- Upstream ships glib as one source tree producing FOUR separate shared
-- libraries, and this index follows that split: `gnome.glib`,
-- `gnome.gobject`, `gnome.gmodule` and `gnome.gio` are four packages from one
-- fork, because that is what a consumer links.
--
-- ─────────────────────────────────────────────────────────────────────────
-- ⭐ FOUR WRONG MACRO NAMES, AND WHY NOTHING CAUGHT THEM
--
-- The FIRST 2.82.5 tarball — cut before `gnome.gio` existed, superseded by the
-- one this descriptor names — defined:
--
--     what it defined                what upstream defines
--     G_UNICODE_TYPE_TYPE            G_TYPE_UNICODE_TYPE
--     G_UNICODE_BREAK_TYPE_TYPE      G_TYPE_UNICODE_BREAK_TYPE
--     G_UNICODE_SCRIPT_TYPE_...      G_TYPE_UNICODE_SCRIPT
--     G_NORMALIZE_TYPE_MODE          G_TYPE_NORMALIZE_MODE
--
-- ⭐ HOW IT GOT THROUGH IS THE PART WORTH KEEPING. `glib-mkenums` has TWO
-- prefixes and they come from different places:
--
--     enum_prefix    from the ENUMERATORS  (G_UNICODE_)   → drives the nicks
--     @ENUMPREFIX@   from the TYPE NAME    (G)            → drives the macro
--
-- The reimplementation used the first for both. Every FUNCTION name was still
-- right — `g_unicode_type_get_type` — so the library compiled, linked, and
-- passed a test that checked the function and the nick. Only the macro was
-- wrong, and nothing in the fork named the macro.
--
-- ⚠️ The version did NOT move, because the package version is upstream's: the
-- tag was re-cut and the sha256 below is the new one. The store keys on
-- (name, version), so a machine that extracted the first 2.82.5 keeps it —
-- clear that entry if `G_TYPE_UNICODE_TYPE` is still undefined.
--
-- The lesson generalised: one generator has several independent outputs, and
-- a test that exercises one of them is not evidence about the others. CI now
-- checks the macro, the nick, and enum-vs-flags separately.
--
-- ─────────────────────────────────────────────────────────────────────────
-- WHY A FORK
--
-- Generators, not line count. GLib has seven; `build.mcpp` reimplements six
-- and the seventh's output is checked in and diffed. See `gnome.glib` for the
-- table and `gnome.gio` for the seventh.
--
-- glib-mkenums is reproduced for the inputs this build points it at — for
-- gobject that is `glib/gunicode.h`, four enums. It reads upstream's
-- `.template` files from the tree so a template change is picked up, and
-- exits non-zero if that header stops yielding four enums: a silent drop
-- would produce a library missing `g_unicode_script_get_type` and the failure
-- would land in a consumer.
--
-- https://github.com/mcpplibs/glib
--
-- ❌ "THERE IS NO MODULE" USED TO BE HERE, AND IT WAS THE WRONG CONCLUSION.
--
-- The observation was right: glib's API IS macro-heavy, and macros do not
-- cross a module boundary. What did not follow is that a module is therefore
-- pointless. It hands a consumer 2,732 declarations, which is everything
-- except the macros — and the function API is most of what gio is used for.
--
-- It was also the wrong shape for this index, where the NAMESPACE is the
-- contract: `gnome.*` promises `import` the way `freedesktop.cairo` and
-- `wlroots.wlroots` do. See the module section above.
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
-- ─────────────────────────────────────────────────────────────────────────
-- ⭐ TWO WAYS TO CONSUME IT, AND YOU PICK ONE
--
--     import gnome.gobject;          -- the module route
--     #include <glib-object.h>       -- the header route
--
-- The namespace is the contract in this index: `compat.xxx` means headers, an
-- owner namespace means the package exposes `import`. This module exports
-- 495 names. It re-exports `gnome.glib`, because
-- `glib-object.h` includes `glib.h` and because a consumer CANNOT name
-- `gnome.glib` itself — it is a workspace path dependency.
--
-- ⚠️ THE TWO ROUTES DO NOT COMPOSE. A TU that imports the module AND textually
-- includes a glib header reaches <time.h> twice — once through the module's
-- global fragment, once directly — and the same `struct tm` from the same file
-- becomes two entities:
--
--     error: conflicting declaration 'struct tm'
--     note: previous declaration as 'struct tm'   (of module gnome.gobject)
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
    name        = "gobject",
    description = "GObject 2.82.5 — the GLib type system: GType, signals, properties, closures and GValue",
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

    mcpp = "*/mcpp/gobject/mcpp.toml",
}
