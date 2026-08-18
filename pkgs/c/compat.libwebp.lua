-- compat.libwebp — the WebP image codec, encode + decode, built from upstream
-- source rather than linked against a host libwebp.
--
-- Shape A (C-source compat): a consumer writes `#include <webp/encode.h>` /
-- `<webp/decode.h>` and links one lib.
--
-- WHAT IS IN THE LIB. dec + enc + dsp + utils + sharpyuv, as five directory
-- globs. sharpyuv is inside the SAME archive rather than a package of its own
-- because the encoder's picture_csp_enc.c calls into it directly — upstream's
-- CMake builds it as a separate target only to reuse it elsewhere, and there is
-- nothing else here to reuse it.
--
-- WHAT IS NOT. `src/demux` and `src/mux` (animation and metadata containers:
-- WebPDemux* / WebPMux*) are separate upstream libraries with their own public
-- headers; they belong in a feature, and nothing asks for them yet.
-- `examples/`, `extras/`, `imageio/` and `swig/` are tools and bindings.
--
-- SIMD, and the one thing this package has to decide. Every
-- `src/dsp/*_sse2.c`, `*_sse41.c`, `*_neon.c`, `*_mips*.c`, `*_msa.c` variant is
-- compiled unconditionally; which of them produce CODE is decided by
-- `src/dsp/cpu.h`, and the ones that do not fall back to a `WEBP_DSP_INIT_STUB`
-- so the link stays complete either way. That is what makes the directory glob
-- safe and why there are no per-file flags here.
--
-- SSE4.1 IS TURNED OFF, on purpose. Its gate is
--
--     #if (defined(__SSE4_1__) || defined(WEBP_MSC_SSE41)) && \
--         (!defined(HAVE_CONFIG_H) || defined(WEBP_HAVE_SSE41))
--
-- and `WEBP_MSC_SSE41` keys off `_MSC_VER` alone. Every MSVC-ABI compiler
-- defines that — including clang — but only cl.exe actually lets any intrinsic
-- be used without a target flag. Under clang the SSE4.1 sources then fail with
--
--     always_inline function '_mm_shuffle_epi8' requires target feature 'ssse3',
--     but would be inlined into function 'VP8L32bToPlanar_SSE41' that is
--     compiled without support for 'ssse3'
--
-- Upstream's CMake answers this with a PER-FILE `-msse4.1`, which mcpp has no
-- field for. Adding it package-wide instead would let clang emit SSE4.1 in the
-- BASELINE translation units too, past libwebp's own runtime CPU dispatch — an
-- artifact that SIGILLs on a pre-2008 CPU rather than falling back. So this
-- package takes the other half of upstream's mechanism: `HAVE_CONFIG_H` plus a
-- generated `src/webp/config.h` that names SSE2 and NEON and NOT SSE4.1.
-- x86-64's baseline SSE2 and aarch64's baseline NEON both need no flag and stay
-- on; SSE4.1's `VP8DspInitSSE41` becomes the stub and its call site disappears
-- with `WEBP_HAVE_SSE41`.
--
-- INCLUDE ROOTS, both of them. The library's own sources include flat from the
-- archive root (`#include "src/dsp/dsp.h"`, `"sharpyuv/sharpyuv.h"`), while
-- consumers include `<webp/decode.h>` — which lives at `src/webp/decode.h`. Both
-- roots therefore travel to dependents.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "libwebp",
    description = "WebP image codec: encode + decode + sharpyuv, built from upstream sources",
    licenses    = {"BSD-3-Clause"},
    repo        = "https://github.com/webmproject/libwebp",
    type        = "package",

    xpm = {
        linux = {
            ["1.5.0"] = {
                url = {
                    GLOBAL = "https://github.com/webmproject/libwebp/archive/refs/tags/v1.5.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/libwebp/releases/download/1.5.0/libwebp-1.5.0.tar.gz",
                },
                sha256 = "668c9aba45565e24c27e17f7aaf7060a399f7f31dba6c97a044e1feacb930f37",
            },
        },
        macosx = {
            ["1.5.0"] = {
                url = {
                    GLOBAL = "https://github.com/webmproject/libwebp/archive/refs/tags/v1.5.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/libwebp/releases/download/1.5.0/libwebp-1.5.0.tar.gz",
                },
                sha256 = "668c9aba45565e24c27e17f7aaf7060a399f7f31dba6c97a044e1feacb930f37",
            },
        },
        windows = {
            ["1.5.0"] = {
                url = {
                    GLOBAL = "https://github.com/webmproject/libwebp/archive/refs/tags/v1.5.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/libwebp/releases/download/1.5.0/libwebp-1.5.0.tar.gz",
                },
                sha256 = "668c9aba45565e24c27e17f7aaf7060a399f7f31dba6c97a044e1feacb930f37",
            },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        c_standard   = "c11",
        include_dirs = { "*", "*/src", "mcpp_generated" },
        -- The header libwebp's autotools build generates and its tarball does
        -- not ship. Sources reach it as `#include "src/webp/config.h"`, so it
        -- has to sit under a root that spells that path.
        --
        -- Defining HAVE_CONFIG_H flips EVERY `(!defined(HAVE_CONFIG_H) ||
        -- defined(WEBP_HAVE_x))` gate in src/dsp/cpu.h from "on unless denied"
        -- to "off unless allowed", so this file is the allow-list — which is
        -- exactly the control upstream's configure script exercises.
        generated_files = {
            ["mcpp_generated/src/webp/config.h"] = [==[
#ifndef MCPP_COMPAT_LIBWEBP_CONFIG_H
#define MCPP_COMPAT_LIBWEBP_CONFIG_H

/* The SIMD families this package compiles. Both are the BASELINE of their
   architecture and need no target flag: SSE2 on x86-64, NEON on aarch64. Each
   is still guarded by the compiler's own macro first, so naming both here is
   safe on either architecture. */
#define WEBP_HAVE_SSE2
#define WEBP_HAVE_NEON

/* WEBP_HAVE_SSE41 is deliberately absent — see the descriptor header. Leaving
   it out turns dec_sse41.c and friends into WEBP_DSP_INIT_STUB and removes the
   `if (VP8GetCPUInfo(kSSE4_1)) VP8DspInitSSE41();` call, so the library still
   links and still dispatches, one tier lower. */

/* MIPS/MSA are likewise absent: nothing here targets them, and under
   HAVE_CONFIG_H silence means off. */

#if defined(__GNUC__) || defined(__clang__)
#define HAVE_BUILTIN_BSWAP16
#define HAVE_BUILTIN_BSWAP32
#define HAVE_BUILTIN_BSWAP64
#endif

#endif  /* MCPP_COMPAT_LIBWEBP_CONFIG_H */
]==],
        },
        cflags = { "-DHAVE_CONFIG_H" },
        -- 117 translation units, as five directory globs. Each directory holds
        -- only library code; the tools live in examples/ extras/ imageio/ swig/
        -- and the container libraries in src/demux src/mux, none of which are
        -- matched here.
        sources = {
            "*/src/dec/*.c",
            "*/src/enc/*.c",
            "*/src/dsp/*.c",
            "*/src/utils/*.c",
            "*/sharpyuv/*.c",
        },
        targets = { ["webp"] = { kind = "lib" } },
        deps    = { },

        -- libm for the dsp math, pthread for utils/thread_utils.c's worker pool.
        -- Both are sysroot components, not third-party host libraries. Windows
        -- needs neither: the CRT carries the math and thread_utils uses the Win32
        -- thread API directly.
        linux  = { ldflags = { "-lpthread", "-lm" } },
        macosx = { ldflags = { "-lpthread", "-lm" } },
    },
}
