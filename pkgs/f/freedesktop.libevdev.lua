-- freedesktop.libevdev — libevdev 1.13.7, the evdev wrapper libinput sits on.
--
-- The kernel's input interface is a stream of `struct input_event`. libevdev
-- turns it into something a program can ask questions of: what axes does this
-- device have, what is each one's current state, what changed since last time.
-- `libinput` links it, so a compositor's input stack does not work without it.
--
-- ─────────────────────────────────────────────────────────────────────────
-- SHAPE: a fork, and the reason is one generated file
--
-- `event-names.h` maps every `EV_*` / `KEY_*` / `ABS_*` constant to its
-- string — 1,692 lines, emitted by a Python script. An inline descriptor would
-- have to carry 72 KB of generated C as a literal with nothing able to check
-- it against its source, so the generator runs once in
-- [mcpplibs/libevdev](https://github.com/mcpplibs/libevdev), the output is
-- checked in, and that fork's CI regenerates and diffs. No Python in a
-- consumer's build.
--
-- THE GENERATION IS DETERMINISTIC ONLY BECAUSE UPSTREAM BUNDLES THE KERNEL
-- HEADERS, and that is worth stating because it is the kind of thing a
-- packager gets wrong silently. `meson.build:43` generates from
-- `upstream/include/linux/` — the tarball's own copy — not `/usr/include`.
-- Measured: the host's headers produce a DIFFERENT table (1664 lines against
-- 1692), so a build that reached for them would make
-- `libevdev_event_code_get_name` answer differently depending on the machine
-- it was compiled on. The fork's CI regenerates against the bundled copy for
-- exactly that reason.
--
-- `kind = "lib"`: upstream ships `libevdev.so.2`, but nothing dlopens it and
-- nothing here needs its soname — libinput links it directly.
package = {
    spec        = "1",
    namespace   = "freedesktop",
    name        = "libevdev",
    description = "libevdev 1.13.7 — a wrapper for the Linux evdev input interface, event-name tables pre-generated",
    licenses    = {"MIT"},
    repo        = "https://github.com/mcpplibs/libevdev",
    type        = "package",

    xpm = {
        linux = {
            ["1.13.7"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/libevdev/archive/refs/tags/1.13.7.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/libevdev/releases/download/1.13.7/libevdev-1.13.7.tar.gz",
                },
                sha256 = "39505f777a2c89a4ef7c60761cf506b8998fe176ad9612e0543675aaae631831",
            },
        },
    },

    mcpp = "*/mcpp/evdev/mcpp.toml",
}
