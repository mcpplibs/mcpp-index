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
-- The quirks database (`quirks.c`) reads `.quirks` files at runtime from a
-- directory compiled in as `LIBINPUT_QUIRKS_DIR`. That path is EMPTY here for
-- the same reason libgbm's backend path and libxkbcommon's config root are:
-- upstream's default points into the build prefix, which after relocation is
-- the HOST's dataset. Empty means devices get libinput's built-in defaults
-- rather than a host machine's model quirks — correct behaviour, one fewer
-- silent host edge.
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
        c_standard = "c11",

        include_dirs = { "*/src", "*/include", "mcpp_generated" },

        generated_files = {
            ["mcpp_generated/config.h"] = [==[
#ifndef MCPP_LIBINPUT_CONFIG_H
#define MCPP_LIBINPUT_CONFIG_H
/* meson's config.h, written out for Linux with a GCC-compatible toolchain.

   LIBINPUT_QUIRKS_DIR is EMPTY on purpose. quirks.c reads model-specific
   `.quirks` files from it at runtime; upstream's default points into the
   build prefix, which after relocation is the HOST's dataset. Empty means a
   device gets libinput's built-in defaults instead of another machine's
   quirks — the same stance compat.libgbm takes with GBM_BACKENDS_PATH.

   HAVE_LUA and HAVE_LIBWACOM are absent: both are optional upstream and both
   would add a dependency this package does not need to do its job. */
#define LIBINPUT_QUIRKS_DIR ""
#define LIBINPUT_QUIRKS_SRCDIR ""
#define HAVE_LIBEVDEV_DISABLE_PROPERTY 1
#define HAVE_MEMFD_CREATE 1
#define HAVE_LOCALE_H 1
#define HAVE_STRERRORNAME_NP 1
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
