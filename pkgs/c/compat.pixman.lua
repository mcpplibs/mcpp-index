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
-- `[build] flags` with a `glob` is what expresses the per-file instruction
-- sets, and this is not a new mechanism: `compat.sdl2` already scopes `-msse3`
-- to one file the same way. What those globs cannot express is an
-- ARCHITECTURE: they are unconditional, and `-mssse3` on an aarch64 compiler is
-- not ignored — clang reports `unsupported option '-mssse3' for target`. So the
-- two SIMD translation units and their globs live in
-- `target_cfg['cfg(arch = "x86_64")']`, which the engine evaluates against the
-- RESOLVED target (root and dependency alike); on every other architecture the
-- generic C paths (and pixman-x86.c's stub, which is always compiled) are what
-- the runtime dispatch chooses from. Still no fork, no `build.mcpp`.
--
-- ─────────────────────────────────────────────────────────────────────────
-- WHAT IS COMPILED AND WHAT IS NOT
--
-- The x86 SIMD (`pixman-sse2.c`, `pixman-ssse3.c`, reached through
-- `pixman-x86.c`'s CPUID dispatch) is in on x86_64 only; MMX is not. MMX is
-- 32-bit-x86 era and upstream itself gates it behind `have_mmx`, which is
-- false on x86_64 toolchains. The ARM/MIPS/PPC/RISC-V variants come with
-- assembly files and their own probes; they are absent here for the same
-- reason `freedesktop.egl` leaves X11 out — those targets build the generic C
-- paths, and the runtime dispatch degrades to them rather than failing.
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
/* meson's configure_file output, written out for the targets this package
   builds: Linux, x86_64 and aarch64, with a GCC-compatible or clang toolchain.
   The SSE2/SSSE3 units are compiled only under the descriptor's
   target_cfg['cfg(arch = "x86_64")'], so the two macros are defined only when
   the compiler is one: defined elsewhere they would make pixman-x86.c call
   _pixman_implementation_create_sse2/ssse3 with no translation unit behind
   them (pixman-private.h reads them the same way meson's config does). */
#if defined(__i386__) || defined(__x86_64__)
#define USE_SSE2 1
#define USE_SSSE3 1
#endif
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
            -- Always compiled: with USE_SSE2/USE_SSSE3 undefined (every
            -- architecture but x86_64) it is upstream's stub that returns the
            -- implementation chain unchanged, and pixman-implementation.c calls
            -- _pixman_x86_get_implementations unconditionally.
            "*/pixman/pixman-x86.c",
        },

        cflags = { "-D_GNU_SOURCE", "-DHAVE_CONFIG_H", "-fPIC" },

        -- The x86 SIMD implementations, and the whole reason this package
        -- needs no fork. Each glob entry gives ONE file the instruction set it
        -- implements, so the compiler may emit those instructions there and
        -- nowhere else — which is what makes pixman's CPUID dispatch in
        -- pixman-x86.c safe. Both halves are conditional: on other
        -- architectures there is no -msse2/-mssse3 to accept (clang rejects
        -- them for the target), and upstream's meson would not build these
        -- two units either.
        target_cfg = {
            ["cfg(arch = \"x86_64\")"] = {
                sources = {
                    "*/pixman/pixman-sse2.c",
                    "*/pixman/pixman-ssse3.c",
                },
                flags = {
                    { glob = "*/pixman/pixman-sse2.c",  cflags = { "-msse2" } },
                    { glob = "*/pixman/pixman-ssse3.c", cflags = { "-mssse3" } },
                },
            },
        },

        targets = { ["pixman-1"] = { kind = "lib" } },
    },
}
