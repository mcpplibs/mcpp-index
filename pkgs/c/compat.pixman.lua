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
-- upstream builds ONE STATIC LIBRARY PER INSTRUCTION SET, each from its own
-- source files compiled with that set's flags:
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
-- not ignored — clang reports `unsupported option '-mssse3' for target`. So
-- `target_cfg` selects each architecture's SIMD sources, their per-file flags
-- and the matching `USE_*` defines together; the engine evaluates it against
-- the RESOLVED target (root and dependency alike). Still no fork, no
-- `build.mcpp`.
--
-- ─────────────────────────────────────────────────────────────────────────
-- WHAT IS COMPILED AND WHAT IS NOT
--
-- Base `sources` mirrors upstream's `pixman_files` (including the per-arch
-- dispatchers `pixman-x86.c`, `pixman-arm.c`, `pixman-mips.c`, `pixman-ppc.c`
-- and `pixman-riscv.c`, each of which compiles to a passthrough stub when its
-- `USE_*` macros are unset). Architecture-specific SIMD is gated by
-- `target_cfg` so macro definitions and translation units cannot drift apart:
--
--   * x86_64: `pixman-sse2.c` (`-msse2`) and `pixman-ssse3.c` (`-mssse3`) with
--     `USE_SSE2=1`, `USE_SSSE3=1`, dispatched at runtime via CPUID in
--     `pixman-x86.c`. MMX is omitted (32-bit x86 era).
--   * aarch64: `pixman-arm-neon.c`, `pixman-arma64-neon-asm.S`, and
--     `pixman-arma64-neon-asm-bilinear.S` with `USE_ARM_A64_NEON=1`. NEON is
--     part of the ARMv8-A baseline, so no extra ISA flag or runtime auxv probe
--     is needed. `ASM_HAVE_FUNC_DIRECTIVE` is left unset because Clang's
--     integrated assembler rejects `.func`/`.endfunc` while GNU as does not
--     require them.
--   * Other Linux architectures (e.g. riscv64): neither `target_cfg` matches,
--     no `USE_*` macro is defined, `<cpuid.h>` is not included, and pixman
--     degrades cleanly to its generic + fast-path C implementation.
--
-- `pixman-config.h` and `pixman-version.h` are meson's `configure_file`
-- outputs. They are generated here rather than probed: every value in them is
-- a property of the target, and the target is Linux with a GCC-compatible
-- toolchain.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "pixman",
    description = "pixman 0.46.4 — low-level pixel manipulation, with per-architecture SIMD (x86_64 SSE2/SSSE3, aarch64 NEON)",
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
/* meson's configure_file output for Linux with a GCC-compatible toolchain.
   Architecture-specific SIMD macros (USE_SSE2, USE_SSSE3, USE_ARM_A64_NEON)
   are defined alongside their sources in target_cfg so macro and TU selection
   cannot drift apart. */
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
#ifdef __GLIBC__
#define HAVE_FEENABLEEXCEPT 1
#endif
#define HAVE_BUILTIN_CLZ 1
#ifdef __SIZEOF_FLOAT128__
#define HAVE_FLOAT128 1
#endif
#ifdef __SIZEOF_LONG__
#define SIZEOF_LONG __SIZEOF_LONG__
#endif
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

        cflags  = { "-D_GNU_SOURCE", "-DHAVE_CONFIG_H", "-fPIC" },
        ldflags = { "-lm" },

        -- Per-architecture SIMD implementations and their matching USE_*
        -- defines. Each x86_64 entry gives ONE file the instruction set it
        -- implements, so the compiler may emit those instructions there and
        -- nowhere else — which is what makes pixman's CPUID dispatch in
        -- pixman-x86.c safe. On aarch64, NEON is part of the ARMv8-A baseline
        -- and needs no extra compiler flag.
        target_cfg = {
            ["cfg(arch = \"x86_64\")"] = {
                defines = { "USE_SSE2=1", "USE_SSSE3=1" },
                sources = {
                    "*/pixman/pixman-sse2.c",
                    "*/pixman/pixman-ssse3.c",
                },
                flags = {
                    { glob = "*/pixman/pixman-sse2.c",  cflags = { "-msse2" } },
                    { glob = "*/pixman/pixman-ssse3.c", cflags = { "-mssse3" } },
                },
            },
            ["cfg(arch = \"aarch64\")"] = {
                defines = { "USE_ARM_A64_NEON=1" },
                sources = {
                    "*/pixman/pixman-arm-neon.c",
                    "*/pixman/pixman-arma64-neon-asm.S",
                    "*/pixman/pixman-arma64-neon-asm-bilinear.S",
                },
            },
        },

        targets = { ["pixman-1"] = { kind = "lib" } },
    },
}
