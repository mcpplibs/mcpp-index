-- compat.libseat — seatd 0.9.3's libseat, session and device handover.
--
-- A Wayland compositor has to open DRM and input devices, and it has to become
-- DRM master. On a desktop that is normally logind's job; libseat is the
-- abstraction over "whatever does that here", and it is what wlroots and
-- everything built on it links.
--
-- ─────────────────────────────────────────────────────────────────────────
-- WHICH BACKENDS, AND WHY logind IS DELIBERATELY OFF
--
-- Upstream builds three:
--
--   seatd     talk to a running seatd daemon over a socket
--   builtin   BE the seat manager, in-process
--   logind    talk to systemd-logind or elogind        ← NOT built here
--
-- logind is off for the same reason systemd's libudev is not the libudev in
-- this index: it is not separable. Building it would make this package
-- depend on `libsystemd`, which drags a distribution's worth of build inputs
-- in for one D-Bus conversation — and the ecosystem already has the other two
-- paths, which need nothing outside this package.
--
-- What that costs, named rather than discovered: on a machine where the
-- session IS managed by logind, a compositor linking this libseat will not use
-- it. It falls back to the seatd daemon (`SEATD_SOCK`) or to the builtin
-- manager, which is the documented way to run a compositor from a TTY. That is
-- the configuration this index can actually support end to end.
--
-- BUILTIN IS ON, and it is what makes the package useful with no daemon at
-- all: the compositor becomes its own seat manager. It needs the privileges to
-- open the devices — running from a TTY, or with the right group membership —
-- which is the same requirement any seat manager has.
--
-- ─────────────────────────────────────────────────────────────────────────
-- SHAPE: inline, and the source list is upstream's two lists deduplicated
--
-- `libseat.c` and `backend/noop.c` are the library; `private_files` is a
-- static lib linked into it, and with BUILTIN_ENABLED upstream appends
-- `server_files` to that. The two lists OVERLAP — `common/log.c`,
-- `linked_list.c` and `connection.c` are in both — and meson deduplicates.
-- mcpp does not: naming a file twice is a duplicate-symbol link error, so the
-- list below is the union, written once.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "libseat",
    description = "libseat 0.9.3 — session and device handover for compositors, with the seatd and builtin backends",
    licenses    = {"MIT"},
    repo        = "https://git.sr.ht/~kennylevinsen/seatd",
    type        = "package",

    xpm = {
        linux = {
            ["0.9.3"] = {
                url = {
                    GLOBAL = "https://github.com/kennylevinsen/seatd/archive/refs/tags/0.9.3.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/seatd/releases/download/0.9.3/seatd-0.9.3.tar.gz",
                },
                sha256 = "302564d54d8e28191fadfd734f2675ecb0c9e0615a58011b89ef15dfa4dbaa96",
            },
        },
    },

    mcpp = {
        language   = "c++23",
        import_std = false,
        c_standard = "c11",

        include_dirs = { "*", "*/include" },

        sources = {
            -- the library proper
            "*/libseat/libseat.c",
            "*/libseat/backend/noop.c",
            "*/libseat/backend/seatd.c",
            -- private_files
            "*/common/connection.c",
            "*/common/linked_list.c",
            "*/common/log.c",
            -- server_files, minus the three already named above
            "*/common/terminal.c",
            "*/common/evdev.c",
            "*/common/hidraw.c",
            "*/common/drm.c",
            "*/seatd/poller.c",
            "*/seatd/seat.c",
            "*/seatd/client.c",
            "*/seatd/server.c",
            -- `common/wscons.c` IS here, and the first version of this
            -- descriptor left it out on the reasoning that it is the
            -- NetBSD/OpenBSD console driver. It is — but it self-gates on
            -- `__NetBSD__` and provides a STUB on every other platform, while
            -- `seatd/seat.c:351` calls `path_is_wscons` unconditionally. The
            -- omission surfaced as an undefined reference from a file that has
            -- nothing to do with BSD consoles.
            "*/common/wscons.c",
        },

        cflags = {
            -- EMPTY value: seatd/client.c and friends define _GNU_SOURCE
            -- themselves, and a -D with a value would make every one of them
            -- warn about a redefinition.
            "-D_GNU_SOURCE=",
            "-DLIBSEAT=1",
            -- The seatd socket the seatd backend connects to when
            -- SEATD_SOCK is unset. Upstream defaults to this path and the
            -- environment variable overrides it, so this is a fallback rather
            -- than a host dependency: nothing is opened at build time, and a
            -- missing socket is what makes libseat fall through to the
            -- builtin backend.
            [[-DSEATD_DEFAULTPATH=\"/run/seatd.sock\"]],
            "-DSEATD_ENABLED=1",
            "-DBUILTIN_ENABLED=1",
            -- LOGIND_ENABLED is deliberately absent; see the header comment.
            "-fPIC",
        },

        ldflags = { "-lrt" },

        targets = { ["seat"] = { kind = "lib" } },
    },
}
