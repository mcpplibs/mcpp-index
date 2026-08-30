-- compat.pixman — pixman 0.46.4, the pixel-manipulation library.
--
-- The software compositing path. A Wayland compositor uses it for the surfaces
-- it cannot hand to the GPU — damage regions, cursor blending, the fallback
-- when there is no EGL — and cairo, X and Mesa all sit on it too.
--
-- ─────────────────────────────────────────────────────────────────────────
-- SHAPE: an inline descriptor, and the SIMD is why that is worth saying
--
-- pixman is a separable project with its own releases, so by the criterion it
-- is a source build. What made it look like it needed a fork is the SIMD:
-- upstream builds ONE STATIC LIBRARY PER INSTRUCTION SET, each from a single
-- `.c` compiled with that set's flags:
--
--     foreach simd : simds                       # meson.build:63
--       pixman_simd_libs += static_library(
--         'pixman-' + simd[0], [name + '.c', ...], c_args : simd[2])
--
-- Package-wide `cflags` cannot express that. `-mssse3` applied to every file
-- would let the compiler emit SSSE3 in code that runs before the CPUID check
-- in `pixman-x86.c` — an illegal-instruction crash on an older CPU, from a
-- library whose whole design is to dispatch at runtime.
--
-- `[build] flags` with a `glob` is what expresses it, and this is not a new
-- mechanism: `compat.sdl2` already scopes `-msse3` to one file the same way.
-- So no fork, no `build.mcpp`. Contrast `freedesktop.gldispatch`, where the
-- per-architecture choice is WHICH FILES to compile rather than which flags to
-- give them — that one does need `build.mcpp`.
--
-- ─────────────────────────────────────────────────────────────────────────
-- WHAT IS COMPILED AND WHAT IS NOT
--
-- The x86 SIMD (`pixman-sse2.c`, `pixman-ssse3.c`) is in; MMX is not. MMX is
-- 32-bit-x86 era and upstream itself gates it behind `have_mmx`, which is
-- false on x86_64 toolchains. The ARM/MIPS/PPC/RISC-V variants come with
-- assembly files and their own probes; they are absent here for the same
-- reason `freedesktop.egl` leaves X11 out — nothing in this index builds for
-- those targets yet, and the runtime dispatch degrades to the generic path
-- rather than failing.
--
-- `pixman-config.h` and `pixman-version.h` are meson's `configure_file`
-- outputs. They are generated here rather than probed: every value in them is
-- a property of the target, and the target is Linux with a GCC-compatible
-- toolchain.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "pixman",
    description = "pixman 0.46.4 — low-level pixel manipulation, with runtime-dispatched x86 SIMD",
    licenses    = {"MIT"},
    repo        = "https://gitlab.freedesktop.org/pixman/pixman",
    type        = "package",

    xpm = {
        linux = {
            ["0.46.4"] = {
                url = {
                    GLOBAL = "https://gitlab.freedesktop.org/pixman/pixman/-/archive/pixman-0.46.4/pixman-pixman-0.46.4.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/pixman/releases/download/0.46.4/pixman-0.46.4.tar.gz",
                },
                sha256 = "1b8288086e5da0ec5cb95cf174a919cc6fe4548f10dc3cd873b3bb1d9e8fdeab",
            },
        },
    },

    mcpp = {
        language   = "c++23",
        import_std = false,
        c_standard = "c11",

        include_dirs = { "*/pixman", "mcpp_generated" },

        generated_files = {
            ["mcpp_generated/pixman-config.h"] = [[
#ifndef PIXMAN_CONFIG_H
#define PIXMAN_CONFIG_H
/* meson's configure_file output, written out for the one target this
   package builds: Linux, x86_64, a GCC-compatible toolchain. */
#define USE_SSE2 1
#define USE_SSSE3 1
#define USE_GCC_INLINE_ASM 1
#define HAVE_PTHREADS 1
#define HAVE_POSIX_MEMALIGN 1
#define HAVE_MMAP 1
#define HAVE_MPROTECT 1
#define HAVE_GETPAGESIZE 1
#define HAVE_SYS_MMAN_H 1
#define HAVE_UNISTD_H 1
#define HAVE_FENV_H 1
#define HAVE_FEDIVBYZERO 1
#define HAVE_FEENABLEEXCEPT 1
#define HAVE_BUILTIN_CLZ 1
#define HAVE_FLOAT128 1
#define TOOLCHAIN_SUPPORTS_ATTRIBUTE_CONSTRUCTOR 1
#define TLS __thread
#define PACKAGE "pixman"
#endif
]],
            ["mcpp_generated/pixman-version.h"] = [[
#ifndef PIXMAN_VERSION_H__
#define PIXMAN_VERSION_H__
#ifndef PIXMAN_H__
#  error pixman-version.h should only be included by pixman.h
#endif
#define PIXMAN_VERSION_MAJOR 0
#define PIXMAN_VERSION_MINOR 46
#define PIXMAN_VERSION_MICRO 4
#define PIXMAN_VERSION_STRING "0.46.4"
#define PIXMAN_VERSION_ENCODE(major, minor, micro) (        \
          ((major) * 10000)                                 \
        + ((minor) *   100)                                 \
        + ((micro) *     1))
#define PIXMAN_VERSION PIXMAN_VERSION_ENCODE(       \
        PIXMAN_VERSION_MAJOR,                       \
        PIXMAN_VERSION_MINOR,                       \
        PIXMAN_VERSION_MICRO)

/* PIXMAN_API lives HERE upstream, not in a compiler header, and leaving it
   out is silent: every `PIXMAN_API void pixman_fill(...)` in pixman.h then
   parses as an unknown identifier and the declaration is lost. What surfaces
   is `implicit declaration of function 'pixman_fill'` from a SIMD file that
   has nothing to do with it. */
#ifndef PIXMAN_API
# define PIXMAN_API
#endif
#endif
]],
        },

        sources = {
            "*/pixman/pixman.c",
            "*/pixman/pixman-access.c",
            "*/pixman/pixman-access-accessors.c",
            "*/pixman/pixman-arm.c",
            "*/pixman/pixman-bits-image.c",
            "*/pixman/pixman-combine32.c",
            "*/pixman/pixman-combine-float.c",
            "*/pixman/pixman-conical-gradient.c",
            "*/pixman/pixman-edge.c",
            "*/pixman/pixman-edge-accessors.c",
            "*/pixman/pixman-fast-path.c",
            "*/pixman/pixman-filter.c",
            "*/pixman/pixman-glyph.c",
            "*/pixman/pixman-general.c",
            "*/pixman/pixman-gradient-walker.c",
            "*/pixman/pixman-image.c",
            "*/pixman/pixman-implementation.c",
            "*/pixman/pixman-linear-gradient.c",
            "*/pixman/pixman-matrix.c",
            "*/pixman/pixman-mips.c",
            "*/pixman/pixman-noop.c",
            "*/pixman/pixman-ppc.c",
            "*/pixman/pixman-radial-gradient.c",
            "*/pixman/pixman-region16.c",
            "*/pixman/pixman-region32.c",
            "*/pixman/pixman-region64f.c",
            "*/pixman/pixman-riscv.c",
            "*/pixman/pixman-solid-fill.c",
            "*/pixman/pixman-timer.c",
            "*/pixman/pixman-trap.c",
            "*/pixman/pixman-utils.c",
            "*/pixman/pixman-x86.c",
            -- the runtime-dispatched implementations
            "*/pixman/pixman-sse2.c",
            "*/pixman/pixman-ssse3.c",
        },

        cflags = { "-D_GNU_SOURCE", "-DHAVE_CONFIG_H", "-fPIC" },

        -- The whole reason this package needs no fork. Each entry gives ONE
        -- file the instruction set it implements, so the compiler may emit
        -- those instructions there and nowhere else — which is what makes
        -- pixman's CPUID dispatch in pixman-x86.c safe.
        flags = {
            { glob = "*/pixman/pixman-sse2.c",  cflags = { "-msse2" } },
            { glob = "*/pixman/pixman-ssse3.c", cflags = { "-mssse3" } },
        },

        targets = { ["pixman-1"] = { kind = "lib" } },
    },
}
