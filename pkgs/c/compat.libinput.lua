-- compat.libinput — libinput 1.31.3, the input stack a compositor drives.
--
-- Touchpads, mice, tablets, touchscreens, keyboards: libinput turns evdev
-- streams into gestures, scroll, pointer acceleration and tap-to-click. It is
-- the last piece of the input chain — libevdev reads the device, libudev finds
-- it, mtdev normalises multitouch, and libinput makes it behave.
--
-- ─────────────────────────────────────────────────────────────────────────
-- SHAPE: inline, and it is the top of a four-package chain
--
--     compat.libinput
--       ├── freedesktop.libevdev   the evdev wrapper
--       ├── compat.libudev         libudev-zero, no systemd
--       └── compat.mtdev           multitouch protocol A -> B
--
-- None of the four needs a fork of libinput itself: the sources are listed in
-- meson and there is no code generation. The forks in that list are there for
-- their own generated files, not for this one.
--
-- ─────────────────────────────────────────────────────────────────────────
-- WHAT IS DELIBERATELY OFF
--
-- LUA PLUGINS. libinput 1.31 grew a Lua plugin system; upstream makes it
-- optional (`required: get_option('lua-plugins')`). It is off here because a
-- device-input library that embeds a scripting runtime is a larger promise
-- than this package should make on its own — `compat.lua` is in the index for
-- a project that wants it, and turning it on is a descriptor change rather
-- than a fork.
--
-- LIBWACOM. Tablet model data, an optional dependency upstream guards the same
-- way. Nothing in this index provides it, and without it libinput falls back
-- to generic tablet handling rather than failing.
--
-- The quirks database (`quirks.c`) reads `.quirks` files at runtime — model
-- specific tuning like a touchpad's pressure range. `libinput.c:1911` takes the
-- directory from `getenv("LIBINPUT_QUIRKS_DIR")` and falls back to a
-- compiled-in path, and the compiled-in path is EMPTY here for the same reason
-- libgbm's backend path and libxkbcommon's config root are: upstream's default
-- points into the build prefix, which after relocation is the HOST's dataset.
--
-- So this is a WIRING question, not a dead end — the same shape as
-- GBM_BACKENDS_PATH, down to the environment variable. What is missing is a
-- provider: the `.quirks` files ship inside libinput's own tarball, but
-- mcpp-index has no way for a package to publish a data DIRECTORY, so nothing
-- currently fills the variable. Until something does, libinput logs
--
--     failed to find data files ... will negatively affect device behavior
--
-- and runs on its built-in defaults. That is a real degradation and it is
-- graceful: enumeration, events and gestures all work — what is lost is
-- per-model tuning. Verified in tests/examples/libinput, which passes with the
-- message present.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "libinput",
    description = "libinput 1.31.3 — touchpad, mouse, tablet and keyboard input handling for compositors",
    licenses    = {"MIT"},
    repo        = "https://gitlab.freedesktop.org/libinput/libinput",
    type        = "package",

    xpm = {
        linux = {
            ["1.31.3"] = {
                url = {
                    GLOBAL = "https://gitlab.freedesktop.org/libinput/libinput/-/archive/1.31.3/libinput-1.31.3.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/libinput/releases/download/1.31.3/libinput-1.31.3.tar.gz",
                },
                sha256 = "b6749bf6f1890f6631c0a70a027c35fec9d2e096a39f720548896e41474a9854",
            },
        },
    },

    mcpp = {
        language   = "c++23",
        import_std = false,
        -- Upstream asks for `c_std=gnu99` and means it — see the `typeof`
        -- note in cflags. `c_standard = "gnu11"` was tried here first and is
        -- NOT the fix: mcpp accepts the string and still emits `-std=c11`, so
        -- the descriptor would claim a dialect the compiler never sees.
        c_standard = "c11",

        -- `"*"` is the package ROOT, and it is here for exactly one file:
        -- `libinput-plugin-mouse-wheel-lowres.c:31` writes
        -- `#include "src/evdev-frame.h"` while every other source in the tree
        -- writes `#include "evdev-frame.h"`. Upstream gets both spellings for
        -- free because meson compiles from the project root; a package that
        -- only puts `*/src` on the search path resolves 39 files and fails the
        -- fortieth.
        include_dirs = { "*", "*/src", "*/include", "mcpp_generated" },

        generated_files = {
            ["mcpp_generated/config.h"] = [==[
#ifndef MCPP_LIBINPUT_CONFIG_H
#define MCPP_LIBINPUT_CONFIG_H
/* meson's config.h, written out for Linux with a GCC-compatible toolchain.

   LIBINPUT_QUIRKS_DIR is EMPTY on purpose, and it is a FALLBACK rather than
   the only way in: `libinput.c:1911` reads `getenv("LIBINPUT_QUIRKS_DIR")`
   first. Upstream's compiled-in default points into the build prefix, which
   after relocation is the HOST's dataset — so empty means a device gets
   libinput's built-in defaults instead of another machine's quirks, and an
   environment that has a dataset can still name it. Exactly the shape
   compat.libgbm has with GBM_BACKENDS_PATH, down to the variable.

   HAVE_LUA and HAVE_LIBWACOM are absent: both are optional upstream and both
   would add a dependency this package does not need to do its job. */
#define LIBINPUT_QUIRKS_DIR ""
#define LIBINPUT_QUIRKS_SRCDIR ""
/* The user's quirks override, `<sysconfdir>/libinput/local-overrides.quirks`
   upstream. Empty for the reason above: relocated, it names the HOST's file. */
#define LIBINPUT_QUIRKS_OVERRIDE_FILE ""

/* Plugin search paths, both EMPTY and both required to exist:
   `libinput_plugin_system_append_default_paths` (libinput-plugin.c:387) names
   them unconditionally, outside any HAVE_PLUGINS guard. Empty paths append
   nothing, which is the behaviour this package wants — see the header comment
   on why the Lua plugin system is off. */
#define LIBINPUT_PLUGIN_LIBDIR ""
#define LIBINPUT_PLUGIN_ETCDIR ""

/* Printed into log messages that point a user at the documentation for the
   behaviour being reported. meson builds it from the version: micro < 90 means
   a release, so the URL names this release rather than `latest`. */
#define HTTP_DOC_LINK "https://wayland.freedesktop.org/libinput/doc/1.31.3"

#define HAVE_LIBEVDEV_DISABLE_PROPERTY 1
#define HAVE_MEMFD_CREATE 1
#define HAVE_LOCALE_H 1
#define HAVE_STRERRORNAME_NP 1
#define HAVE_SIGABBREV_NP 1
#define HAVE_PIDFD_OPEN 1

/* glibc has versionsort(3), and saying so is load-bearing rather than
   cosmetic: `libinput-versionsort.h` provides its OWN static fallback when
   this is unset, and a static definition of a name glibc already declared
   extern is a hard error, not a shadow. */
#define HAVE_VERSIONSORT 1

/* mtdev is a declared dependency of this package, so the plugin that uses it
   is compiled unconditionally (see `libinput-plugin-mtdev.c` in sources). */
#define HAVE_MTDEV 1

/* HAVE_C23_AUTO is deliberately ABSENT. meson probes for it by compiling
   `auto foo = gmtime(NULL);`, which needs C23; this package builds as c11, so
   the probe would fail here too and upstream's non-auto path is correct. */
#endif
]==],

            -- meson's `src/libinput-version.h.in`, substituted for 1.31.3.
            --
            -- `libinput-private.h:45` includes it unconditionally, so every one
            -- of the 40 sources below needs it — this is not an optional
            -- convenience header. It went missing in the first version of this
            -- descriptor and NOTHING CAUGHT IT: the package validated, entered
            -- the index and shipped, because no test member consumed it and a
            -- package nobody compiles cannot fail to compile. The
            -- `tests/examples/libinput` member exists so that stays true only
            -- until someone builds it — which is what found this.
            --
            -- The three numbers are the version in `xpm` above, split. They are
            -- the package's public version macros, so a consumer doing
            -- `#if LIBINPUT_VERSION_MAJOR >= 1` gets a real answer; leaving
            -- them at 0 would compile just as well and lie.
            ["mcpp_generated/libinput-version.h"] = [==[
#ifndef LIBINPUT_VERSION_H
#define LIBINPUT_VERSION_H

#define LIBINPUT_VERSION_MAJOR 1
#define LIBINPUT_VERSION_MINOR 31
#define LIBINPUT_VERSION_MICRO 3
#define LIBINPUT_VERSION "1.31.3"

#endif
]==],
        },

        sources = {
            "*/src/util-files.c",
            "*/src/util-list.c",
            "*/src/util-ratelimit.c",
            "*/src/util-strings.c",
            "*/src/util-prop-parsers.c",
            "*/src/filter.c",
            "*/src/filter-custom.c",
            "*/src/filter-flat.c",
            "*/src/filter-low-dpi.c",
            "*/src/filter-mouse.c",
            "*/src/filter-touchpad.c",
            "*/src/filter-touchpad-flat.c",
            "*/src/filter-touchpad-x230.c",
            "*/src/filter-tablet.c",
            "*/src/filter-trackpoint.c",
            "*/src/filter-trackpoint-flat.c",
            "*/src/quirks.c",
            "*/src/libinput.c",
            "*/src/libinput-plugin.c",
            "*/src/libinput-plugin-button-debounce.c",
            "*/src/libinput-plugin-mouse-wheel.c",
            "*/src/libinput-plugin-mouse-wheel-lowres.c",
            "*/src/libinput-plugin-tablet-double-tool.c",
            "*/src/libinput-plugin-tablet-eraser-button.c",
            "*/src/libinput-plugin-tablet-forced-tool.c",
            "*/src/libinput-plugin-tablet-proximity-timer.c",
            "*/src/libinput-private-config.c",
            "*/src/evdev.c",
            "*/src/evdev-fallback.c",
            "*/src/evdev-plugin.c",
            "*/src/evdev-totem.c",
            "*/src/evdev-middle-button.c",
            "*/src/evdev-mt-touchpad.c",
            "*/src/evdev-mt-touchpad-tap.c",
            "*/src/evdev-mt-touchpad-thumb.c",
            "*/src/evdev-mt-touchpad-buttons.c",
            "*/src/evdev-mt-touchpad-edge-scroll.c",
            "*/src/evdev-mt-touchpad-gestures.c",
            "*/src/evdev-tablet.c",
            "*/src/evdev-tablet-pad.c",
            "*/src/evdev-tablet-pad-leds.c",
            "*/src/path-seat.c",
            "*/src/udev-seat.c",
            "*/src/timer.c",
            "*/src/util-libinput.c",
            -- gated on have_mtdev upstream; mtdev is a declared dependency
            -- here, so the plugin is unconditional.
            "*/src/libinput-plugin-mtdev.c",
        },

        cflags = {
            "-D_GNU_SOURCE",
            "-DHAVE_CONFIG_H",

            -- The GNU `typeof` keyword, supplied by hand.
            --
            -- `util-mem.h:180` is `(typeof(*ptr_))_steal(ptr_)` — the cast that
            -- makes every `steal()` in the tree type-safe. Bare `typeof` is a
            -- GNU extension (and C23's spelling); ISO C11 has only
            -- `__typeof__`. Under `-std=c11` GCC parses `typeof(...)` as a call
            -- to an undeclared function, the cast collapses to `int`, and the
            -- damage lands as `-Wint-conversion` errors in a dozen unrelated
            -- files that never mention typeof.
            --
            -- This is a `-D` rather than `c_standard = "gnu11"` because the
            -- gnu dialects do not reach the compiler: mcpp accepts the string
            -- and still emits `-std=c11`. Measured, not assumed — gnu11 was
            -- set here and these exact errors survived it.
            --
            -- Safe because `__typeof__` IS `typeof`, always available in any
            -- dialect, and nothing can be named `typeof` in code that expects
            -- gnu99 anyway.
            "-Dtypeof=__typeof__",

            "-fPIC",
        },

        ldflags = { "-lm", "-lrt" },

        deps = {
            ["freedesktop.libevdev"] = "1.13.7",
            ["compat.libudev"]       = "1.0.5",
            ["compat.mtdev"]         = "1.1.7",
        },

        targets = { ["input"] = { kind = "lib" } },
    },
}
