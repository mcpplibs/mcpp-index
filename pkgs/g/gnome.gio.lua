-- gnome.gio — part of GLib 2.82.5.
--
-- Files, streams, sockets, D-Bus, GApplication, GSettings, GResource — and
-- `GListModel`, which is what pango's `PangoFontMap` implements.
--
-- Upstream ships glib as one source tree producing FOUR separate shared
-- libraries, and this index follows that split: `gnome.glib`, `gnome.gobject`,
-- `gnome.gmodule` and `gnome.gio` are four packages from one fork, because
-- that is what a consumer links.
--
-- ─────────────────────────────────────────────────────────────────────────
-- ⭐ THIS PACKAGE EXISTS BECAUSE AN EARLIER ARGUMENT WAS WRONG
--
-- gio was left out of this index once, with the reason: two of its six
-- generators are `gdbus-codegen`, an 8,351-line Python program that turns
-- D-Bus interface XML into GObject skeletons, and reimplementing it in
-- `build.mcpp` is not proportionate. That premise was measured and correct.
-- The conclusion did not follow, because it conflated two different things:
--
--     reproducing the generator     ≠     obtaining its output
--
-- The build never needed the generator. It needed 15,392 lines of C that are a
-- PURE FUNCTION of five XML files and the codegen version — no target, no
-- host, no locale enters it. So `mcpp/tools/gengdbus.sh` produces them once,
-- they live in `mcpp/generated/`, and a CI job REGENERATES AND DIFFS them on a
-- runner with a different Python than the one that produced them.
--
-- That last part is the whole argument. Committed output has exactly one
-- failure mode a build never sees: it can stop matching its input, and it
-- still compiles. A diff is what makes "checked in" different from "stale".
--
-- The same arrangement `freedesktop.wayland-protocols-*` already used for its
-- 195 generated files — where it was FORCED, since a package whose product is
-- headers cannot generate at build time. Here it is not forced; it is simply
-- the cheap way to get code a rewrite would otherwise have to produce.
--
-- ─────────────────────────────────────────────────────────────────────────
-- THE OTHER FIVE GENERATORS ARE C++, AS EVERYWHERE ELSE IN THIS FORK
--
--     gio-visibility.h        gen_visibility("GIO", …)
--     gnetworking.h           one substitution
--     gioenumtypes.{h,c}      glib-mkenums over 82 enums
--
-- ⚠️ 82 ENUMS AGAINST gobject's FOUR, and what changes at that scale is not
-- the loop but the ANNOTATIONS — with a trap in each direction:
--
--   gio writes `/*< private >*/`, `/*< public >*/` and `/*< protected >*/`
--   144 times. Those are GTK-DOC annotations for STRUCT MEMBERS and mean
--   nothing to mkenums. A scanner that read every `/*< … >*/` would silently
--   drop enumerators.
--
--   `GConverterFlags` has NO `/*< flags >*/` despite the name, so upstream
--   registers it with `g_enum_register_static`. A scanner that guessed from
--   the type name would disagree with upstream's ABI.
--
-- The nicks are public API — `g_flags_get_value_by_nick` reads them — and gio
-- overrides seventeen of them. Derived, `G_CONVERTER_NO_FLAGS` would be
-- "no-flags"; upstream says "none".
--
-- `gconstructor_as_data.h` is upstream's sixth generator and is NOT here: it
-- embeds `glib/gconstructor.h` as a C string for `glib-compile-resources`, a
-- TOOL. See below.
--
-- ─────────────────────────────────────────────────────────────────────────
-- ⚠️ WHAT gio NEEDS BESIDES gio/*.c — AND WHY EACH IS CHECKED BY NAME
--
-- gio is assembled from four kinds of input. A missing `gio/*.c` is an
-- undefined reference, which the linker catches. The other three DEGRADE
-- SILENTLY, so the example test asserts each one by name rather than trusting
-- that it built:
--
--     gio/xdgmime/        absent → g_content_type_guess answers
--                         "application/octet-stream" for everything
--     gio/inotify/        absent → the file monitor quietly falls back to
--                         polling; the test reads the backend's TYPE NAME,
--                         which is the only place the two differ
--     subprojects/gvdb/   absent → GResource and GSettings' schema reader are
--                         never reachable, and nothing says so
--     mcpp/generated/     stale → it still compiles; the portal calls fail
--                         only inside a Flatpak sandbox
--
-- `-DXDG_PREFIX=_gio_xdg` is load-bearing rather than hygiene: xdgmime's
-- header macro-renames every `xdg_mime_*` symbol, and `gcontenttype.c` calls
-- the unprefixed spelling. Both sides must see the same value or the calls and
-- the definitions are different symbols.
--
-- ─────────────────────────────────────────────────────────────────────────
-- NO TOOLS, AND NO EXTERNAL DEPENDENCY BUT zlib
--
-- The ten tools — `gio-tool`, `gdbus-tool`, `glib-compile-schemas`,
-- `glib-compile-resources`, `gsettings`, … — are NOT built. Each provides
-- `main`, and a dependency that provides one collides with the consumer's;
-- that is the rule every package in this index follows.
--
-- Upstream's meson names exactly one external dependency for the library
-- beyond glib itself: `libelf`, used by `gresource-tool.c` — an
-- `executable()`, not the library. Measured: no library source mentions elf at
-- all. There is therefore NO libelf feature, because there is nothing for it
-- to switch.
--
-- `libmount`, `selinux` and `sysprof` are `auto` upstream and absent here.
-- Each is `#ifdef`-tested, so each is ABSENT rather than 0, and gio degrades
-- the way upstream intends: GUnixMountMonitor falls back to reading
-- /proc/self/mountinfo, and the SELinux and tracing attributes are not
-- offered. Defining any of them as 0 would say "yes" — see `gnome.glib` for
-- the nine macros that lesson came from.
--
-- ─────────────────────────────────────────────────────────────────────────
-- ⚠️ NAME WHAT YOU USE; DO NOT NAME glib
--
--     [dependencies]
--     gnome.gio     = "2.82.5"
--     gnome.gobject = "2.82.5"
--     # gnome.glib and gnome.gmodule arrive transitively
--
-- gio declares glib, gobject and gmodule as workspace PATH dependencies — they
-- are built from one tree — and mcpp rejects a package requested both ways:
--
--     error: dependency 'gnome.glib' is requested as both a version dep
--            (by 'your-package') and a path dep (by 'gnome.gio')
--
-- ─────────────────────────────────────────────────────────────────────────
-- ⚠️ NO extern "C" WRAPPER
--
-- gio decorates every header with G_BEGIN_DECLS, so a wrapper is redundant —
-- and harmful: gio.h reaches <stdlib.h>, which libc++ routes through <cstdlib>,
-- which defines TEMPLATES. Inside an extern "C" block that is
-- `templates must have C++ linkage`, dozens of times, against a header the
-- consumer never named. libstdc++ does not route them that way, so gcc is
-- green and clang is a wall.
--
-- There is no module, for the same reason as the rest of the family: the API
-- is macro-heavy (`G_DEFINE_TYPE`, `G_IS_FILE`, `g_signal_connect`) and macros
-- do not cross a module boundary.
--
-- ─────────────────────────────────────────────────────────────────────────
-- LINUX ONLY
--
-- This is the Unix build: the Windows and Cocoa backends are excluded because
-- they are ALTERNATIVES to the Unix ones, not companions — both halves define
-- the volume monitor, the app-info backend and the settings backend. The
-- generated `glibconfig.h` fixes `G_OS_UNIX` besides, and the upstream tree
-- carries two `COPYING` symlinks a Windows extraction would not survive.
package = {
    spec        = "1",
    namespace   = "gnome",
    name        = "gio",
    description = "GIO 2.82.5 — files, streams, sockets, D-Bus, GSettings and GListModel",
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

    mcpp = "*/mcpp/gio/mcpp.toml",
}
