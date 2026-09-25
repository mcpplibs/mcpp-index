-- compat.libaio — libaio 0.3.113, the userspace wrapper over Linux's native
-- asynchronous I/O syscalls (io_setup / io_submit / io_getevents / io_cancel /
-- io_destroy, plus the io_prep_* helpers and the io_queue_* convenience layer).
--
-- Shape A (C-source compat), same as compat.cjson / compat.hiredis: upstream's
-- own `libaio_srcs` list from src/Makefile compiled into one lib target. There
-- is no configure step and nothing generated — twelve small TUs and one public
-- header.
--
-- LINUX ONLY, and not in the "portable library with a Linux backend" sense:
-- libaio IS the Linux AIO ABI. Every TU is `syscall(__NR_io_*, …)`, and the
-- header's `struct iocb` is the kernel's. There is no macOS or Windows section
-- to write, so consumers gate the dependency with
-- `[target.'cfg(linux)'.dependencies]` — compat.wil does the same in the other
-- direction. (Single-platform `xpm` is why the platform-version-parity lint
-- stays quiet here: it only compares platforms that both carry versions.)
--
-- _GNU_SOURCE IS LOAD-BEARING, and not for a GNU extension in the sources.
-- `-std=c11` defines __STRICT_ANSI__, which turns _DEFAULT_SOURCE off, and
-- without it glibc hides two things libaio needs: <unistd.h> stops declaring
-- `syscall()` (which every TU here reaches through `syscall.h`'s
-- `_body_io_syscall` macro), and `sigset_t` never arrives, so even the PUBLIC
-- header fails to parse at `io_pgetevents(…, sigset_t *sigmask)`. Upstream
-- never hits this because its Makefile compiles in the compiler's default gnu
-- mode. `c_standard = "gnu11"` is the declaration upstream's build implies,
-- and mcpp up to 2026.9.25.1 did not apply it to a package in the dependency
-- position: the root's value reached every C unit of the graph and a
-- dependency's own was dropped, so the build failed exactly as if nothing had
-- been declared (verified in the emitted compile_commands.json under
-- 2026.8.27.2). mcpp 2026.9.26.1 applies it (mcpp-community/mcpp#695); the
-- define stays because it works under every engine this index admits.
--
-- Two further GNU-isms ride along and are fine under plain `-std=c11` because
-- gcc/clang only diagnose them under -pedantic: `syscall.h`'s named-variadic
-- macro `_body_io_syscall(sname, args...)`, and the bare `;` at file scope that
-- is all raw_syscall.c contains on every arch but ia64.
--
-- INCLUDE LAYOUT. Upstream installs exactly one header, `libaio.h`, but in the
-- tarball it sits in `src/` next to the private ones — and one of those is
-- named `syscall.h`, which is also a glibc header. Putting `*/src` on the
-- include path would therefore SHADOW <syscall.h> for every consumer TU. So the
-- package ships a one-line forwarding header through `generated_files` and
-- exposes only the directory holding it (the compat.gmp pattern), which is also
-- what upstream's install layout promises: `libaio.h` and nothing else. The
-- package's own TUs reach the real header through the same forwarder, and their
-- `#include "syscall.h"` / `"aio_ring.h"` resolve next to the including .c —
-- quote-form searches the includer's own directory first — so no -I into `src/`
-- is needed at all.
--
-- WHAT IS NOT COMPILED. `src/struct_offsets.c` is upstream's build-time
-- assertion that the `iocb.u` union members line up; its own comment says "this
-- code does not end up in the compiled object files", and upstream's Makefile
-- compiles it separately from the library. `harness/` is the test suite — it
-- carries its own `main()`, and a mcpp lib target's objects all enter the
-- consumer's link eagerly, so a main() shipped in a package collides with the
-- consumer's own. Neither belongs behind a feature; there are no optional
-- COMPILABLE components here, so this package declares no `features` at all.
--
-- SYMBOL VERSIONING is the one thing worth knowing before consuming this.
-- io_cancel.c / io_getevents.c / io_queue_wait.c define their functions under
-- versioned names (`io_getevents_0_4`) and publish the plain name through
-- `.symver … @@LIBAIO_0.4`; compat-0_1.c adds the three `@LIBAIO_0.1` aliases
-- for the pre-0.3 ABI. For an EXECUTABLE that is transparent — the default
-- (`@@`) version defines the base symbol, verified here against both ld.bfd and
-- lld — which is the case a `kind = "lib"` package is for. Building a SHARED
-- library straight out of these objects needs upstream's `src/libaio.map`
-- version script, or the link fails with `undefined version LIBAIO_0.4`;
-- that is a property of upstream's own libaio.a, not something this descriptor
-- introduces, and it is why compat-0_1.c stays in rather than being dropped:
-- removing it would not lift the restriction (the `@@` symvers alone are enough
-- to trigger it) and would make the object set differ from upstream's for no
-- gain.
--
-- VERSION. 0.3.113 is upstream's latest release (pagure tag `libaio-0.3.113`).
-- The GLOBAL url is the release tarball from releases.pagure.org rather than a
-- git-archive of the tag: pagure regenerates archives, so their sha256 drifts,
-- while the release file is fixed bytes (hashed twice here, identical).
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "libaio",
    description = "Linux-native asynchronous I/O access library (libaio)",
    licenses    = {"LGPL-2.1-or-later"},
    repo        = "https://pagure.io/libaio",
    type        = "package",

    xpm = {
        linux = {
            ["0.3.113"] = {
                url    = {
                    GLOBAL = "https://releases.pagure.org/libaio/libaio-0.3.113.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/libaio/releases/download/0.3.113/libaio-0.3.113.tar.gz",
                },
                sha256 = "2c44d1c5fd0d43752287c9ae1eb9c023f04ef848ea8d4aafa46e9aedb678200b",
            },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        c_standard   = "c11",

        -- Only the forwarding header below, so `src/`'s private headers —
        -- above all its `syscall.h` — never reach a consumer's include path.
        include_dirs = { "libaio-0.3.113/mcpp/include" },

        -- _GNU_SOURCE: see the header comment — without it `syscall()` and
        -- `sigset_t` are hidden under -std=c11 and nothing compiles.
        -- -fPIC: matches upstream (its CFLAGS carry it for libaio.a as well as
        -- the .so) and is what lets these objects link into a shared consumer.
        cflags = { "-D_GNU_SOURCE", "-fPIC" },

        -- Upstream src/Makefile's `libaio_srcs`, verbatim and in its order,
        -- including its section comments.
        sources = {
            -- libaio provided functions
            "libaio-0.3.113/src/io_queue_init.c",
            "libaio-0.3.113/src/io_queue_release.c",
            "libaio-0.3.113/src/io_queue_wait.c",
            "libaio-0.3.113/src/io_queue_run.c",
            -- real syscalls
            "libaio-0.3.113/src/io_getevents.c",
            "libaio-0.3.113/src/io_submit.c",
            "libaio-0.3.113/src/io_cancel.c",
            "libaio-0.3.113/src/io_setup.c",
            "libaio-0.3.113/src/io_destroy.c",
            "libaio-0.3.113/src/io_pgetevents.c",
            -- internal functions
            "libaio-0.3.113/src/raw_syscall.c",
            -- old symbols
            "libaio-0.3.113/src/compat-0_1.c",
        },

        -- `libaio.a` / `-laio`, the spelling every consumer already knows.
        targets = { ["aio"] = { kind = "lib" } },
        deps    = {},

        -- The whole public surface of the package. Quote-form, so it resolves
        -- against this file's own directory and lands on upstream's real
        -- header two levels up — the angle-bracket trick compat.hiredis uses
        -- would need `src/` on the include path, which is exactly what this
        -- header exists to avoid.
        generated_files = {
            ["libaio-0.3.113/mcpp/include/libaio.h"] =
[[
#pragma once
/* compat.libaio: upstream installs libaio.h alone, but the release tarball
   keeps it in src/ beside the private headers -- one of which is named
   syscall.h and would shadow glibc's for every consumer TU. This forwarder is
   the only thing on the include path. */
#include "../../src/libaio.h"
]],
        },
    },
}
