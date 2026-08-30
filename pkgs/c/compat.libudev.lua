-- compat.libudev — libudev-zero 1.0.5, a libudev without systemd.
--
-- `libinput` needs libudev to enumerate input devices and to hear about
-- hotplug. Upstream libudev is part of systemd, which an ecosystem that builds
-- its own userspace cannot take: systemd is not separable, its build wants a
-- large slice of the distribution, and the result would be a package that
-- exists to provide 5,000 lines of device enumeration.
--
-- ─────────────────────────────────────────────────────────────────────────
-- WHY libudev-zero AND NOT eudev OR systemd
--
-- Three implementations of this ABI exist:
--
--   systemd's       the original; not separable, see above
--   eudev           Gentoo's fork of the systemd code; UNMAINTAINED since 2021
--   libudev-zero    a from-scratch reimplementation of the same ABI, MIT,
--                   five C files, no daemon at all
--
-- The third is the only one that is both alive and separable. It reads
-- /sys directly instead of talking to a udev daemon, which is exactly right
-- here: a subos has no udevd, and a program that needed one would work on the
-- developer's machine and nowhere else.
--
-- WHAT IT DOES NOT DO, and it matters: no hotplug MONITOR over netlink from
-- udevd — `udev_monitor` returns devices from /sys at open time. libinput
-- degrades to "the devices present at startup", which is correct for a
-- compositor brought up on a fixed machine and wrong for hot-plugging a
-- keyboard mid-session. Named here rather than discovered later.
--
-- ─────────────────────────────────────────────────────────────────────────
-- SHAPE: `kind = "shared"` with the CANONICAL soname, deliberately
--
-- `libudev.so.1` is the soname systemd's carries, and this package uses it on
-- purpose. A host libinput or a payload that already links libudev.so.1 will
-- REUSE whatever is in the link map — the same soname-reuse property
-- compat.libdrm relies on — so a process ends up with exactly one libudev and
-- it is this one. Merged in as objects instead, a consumer and a dependency
-- would each get their own copy of the device list.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "libudev",
    description = "libudev-zero 1.0.5 — the libudev ABI without systemd or a daemon, for libinput",
    licenses    = {"ISC"},
    repo        = "https://github.com/illiliti/libudev-zero",
    type        = "package",

    xpm = {
        linux = {
            -- libudev-zero's own version. It reports itself as udev 251
            -- through `udev_get_version`, which is the ABI level it targets
            -- rather than anything about this package.
            ["1.0.5"] = {
                url = {
                    GLOBAL = "https://github.com/illiliti/libudev-zero/archive/refs/tags/1.0.5.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/libudev-zero/releases/download/1.0.5/libudev-zero-1.0.5.tar.gz",
                },
                sha256 = "bf4372f79ddbe6b0e266a3d2994ffac7018a7edf4f87632aecb5176565d96138",
            },
        },
    },

    mcpp = {
        language   = "c++23",
        import_std = false,
        c_standard = "c11",

        include_dirs = { "*", "mcpp_generated" },

        -- Upstream's header is `udev.h`; it becomes `libudev.h` at INSTALL
        -- time (Makefile's install-headers), which a package with no install
        -- step does not get for free. Every consumer in the world writes
        -- `#include <libudev.h>` — that is the name systemd's libudev ships —
        -- so a forwarding header carries it. Same shape as compat.libdrm's
        -- per-directory forwarders, and for the same reason: the include
        -- SPELLING is part of the interface.
        --
        -- A LITERAL, not a `..` concatenation: the descriptor parser reads
        -- `generated_files` as data and does not execute Lua, so a
        -- concatenated value fails with `malformed mcpp segment near key
        -- 'define'` — an error naming a key that is not the problem.
        generated_files = {
            ["mcpp_generated/libudev.h"] = [[
#ifndef MCPP_LIBUDEV_FORWARD_H
#define MCPP_LIBUDEV_FORWARD_H
#include <udev.h>
#endif
]],
        },

        sources = {
            "*/udev.c",
            "*/udev_device.c",
            "*/udev_enumerate.c",
            "*/udev_list.c",
            "*/udev_monitor.c",
        },

        cflags = {
            "-D_GNU_SOURCE",
            -- The USB vendor/product name database, and deliberately EMPTY.
            --
            -- Upstream points this at `<prefix>/share/hwdata/usb.ids`, which
            -- after relocation means the HOST's file. Same shape as libgbm's
            -- compiled-in backend path and libglvnd's vendor directory, and it
            -- gets the same answer: an empty default, so a missing database
            -- surfaces as "no USB names" rather than as silently reading a
            -- host file into a sandboxed process.
            --
            -- The degradation is graceful by upstream's own design:
            -- `usb_ids_lookup_vendor` opens the file and `return 0` if it
            -- cannot (udev.c:95). Device ENUMERATION — what libinput actually
            -- needs — never touches it; what is lost is the human-readable
            -- vendor string on a USB device.
            --
            -- Nothing in this index ships hwdata yet. When something does,
            -- this becomes a path the environment declares, exactly like
            -- GBM_BACKENDS_PATH.
            [[-DUSB_IDS_PATH=\"\"]],
            "-fPIC",
        },

        targets = {
            ["udev"] = { kind = "shared", soname = "libudev.so.1" },
        },
    },
}
