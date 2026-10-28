-- compat.opus — libopus, the Opus audio codec (RFC 6716; Xiph.Org, Skype,
-- Mozilla, Amazon and others), BSD-3-Clause.
--
-- The reference encoder and decoder of Opus: SILK for speech, CELT for music,
-- and the hybrid of both, at 8–48 kHz, mono to 255 channels (multistream and
-- ambisonic projection), with the repacketizer and the packet parsers. The
-- codec half of compat.opusfile, which reads Ogg Opus files over it.
--
-- ─────────────────────────────────────────────────────────────────────────
-- THE RELEASE TARBALL, NOT THE TAG ARCHIVE
--
-- 1.6.1 is published on downloads.xiph.org (its SHA256SUMS.txt gives this
-- sha256); the GitHub repository has the v1.6.1 tag but no release. The
-- tarball is what a build without autotools needs: `package_version`, and
-- the DNN model data (dnn/*_data.c) that the tag archive leaves to
-- `autogen.sh` to download. This build compiles none of dnn/, but a future
-- deep-PLC / DRED / OSCE feature could, from the same bytes.
--
-- ─────────────────────────────────────────────────────────────────────────
-- WHAT IS BUILT: UPSTREAM'S DEFAULT FLOATING-POINT LIBRARY, IN PLAIN C
--
-- The sources are the lists of upstream's own makefiles for a float build
-- (CMake and meson read the same .mk files):
--
--   celt_sources.mk  CELT_SOURCES (18 files; mini_kfft.c is QEXT-only)
--   silk_sources.mk  SILK_SOURCES (every silk/*.c) + SILK_SOURCES_FLOAT
--                    (every silk/float/*.c)
--   opus_sources.mk  OPUS_SOURCES + OPUS_SOURCES_FLOAT (14 files; the
--                    demos and comparison tools in src/ are not library code)
--
-- The features are upstream's defaults in configure, CMake and meson alike:
-- floating point (not FIXED_POINT), the float API, hardening on, assertions,
-- custom modes, fuzzing and FLOAT_APPROX off, and the four optional
-- extensions OFF — deep PLC, DRED and OSCE (the DNN features, `dnn/`) and
-- QEXT (the 96 kHz quality extension). Stack arrays are C99 VLAs
-- (VAR_ARRAYS, which CMake picks on every compiler that has them, as clang
-- and gcc do on all three platforms here).
--
-- No SIMD and no run-time CPU detection. Upstream's x86 intrinsics are per
-- file: pitch_sse4_1.c needs -msse4.1, NSQ_del_dec_avx2.c -mavx2, and so on,
-- each behind OPUS_X86_MAY_HAVE_* and the RTCD tables. A descriptor's flags
-- are per package and its platform blocks per OS, not per architecture, so
-- neither those files nor the aarch64-only NEON files can be selected
-- correctly here; the C paths they replace are the reference implementation
-- and are what upstream's own --disable-intrinsics builds run. The one
-- architecture-specific line left is upstream's: celt/float_cast.h converts
-- float to int with cvtss2si under __SSE__ and with vcvtns on __aarch64__,
-- from the compiler's own predefined macros.
--
-- ─────────────────────────────────────────────────────────────────────────
-- A GENERATED config.h, AND ONLY PUBLIC HEADERS FOR CONSUMERS
--
-- Every source includes "config.h" under HAVE_CONFIG_H. The one here
-- (mcpp_generated/config.h) defines what configure would: OPUS_BUILD,
-- PACKAGE_VERSION "1.6.1" (so opus_get_version_string() reads
-- "libopus 1.6.1"), VAR_ARRAYS, HAVE_LRINT/HAVE_LRINTF and ENABLE_HARDENING.
-- It and the internal header directories (the tarball root, celt, silk,
-- silk/float — "arch.h", "debug.h", "config.h"…) are PRIVATE include
-- directories of each platform block, the shape compat.sheenbidi uses: the
-- -I reaches this package's translation units and not its consumers', whose
-- include path gets only `*/include` — <opus.h>, <opus_multistream.h>,
-- <opus_projection.h>, <opus_defines.h>, <opus_types.h>, the spelling
-- upstream's pkg-config gives (-I${includedir}/opus) and opusfile.h uses.
--
-- On Linux and macOS the library is compiled with -fvisibility=hidden, as
-- upstream's configure does: OPUS_EXPORT marks the public functions visible
-- when OPUS_BUILD is defined, so a shared object linking this archive exports
-- opus_* and not the codec's internal celt_* / silk_* symbols.
--
-- kind = "lib": a static library. OPUS_EXPORT is dllexport only under
-- DLL_EXPORT, which is not defined, so Windows consumers need no define.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "opus",
    description = "libopus 1.6.1 — the Opus audio codec (RFC 6716), encoder and decoder, floating point, BSD-3-Clause",
    licenses    = {"BSD-3-Clause"},
    repo        = "https://github.com/xiph/opus",
    type        = "package",

    extensions = {
        autoupdate = {
            tag = "v${version}",
            url = "https://downloads.xiph.org/releases/opus/opus-${version}.tar.gz",
        },
    },

    xpm = {
        linux = {
            ["1.6.1"] = {
                url = {
                    GLOBAL = "https://downloads.xiph.org/releases/opus/opus-1.6.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/opus/releases/download/1.6.1/opus-1.6.1.tar.gz",
                },
                sha256 = "6ffcb593207be92584df15b32466ed64bbec99109f007c82205f0194572411a1",
            },
        },
        macosx = {
            ["1.6.1"] = {
                url = {
                    GLOBAL = "https://downloads.xiph.org/releases/opus/opus-1.6.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/opus/releases/download/1.6.1/opus-1.6.1.tar.gz",
                },
                sha256 = "6ffcb593207be92584df15b32466ed64bbec99109f007c82205f0194572411a1",
            },
        },
        windows = {
            ["1.6.1"] = {
                url = {
                    GLOBAL = "https://downloads.xiph.org/releases/opus/opus-1.6.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/opus/releases/download/1.6.1/opus-1.6.1.tar.gz",
                },
                sha256 = "6ffcb593207be92584df15b32466ed64bbec99109f007c82205f0194572411a1",
            },
        },
    },

    mcpp = {
        language   = "c++23",
        import_std = false,
        c_standard = "c99",

        -- The public headers: <opus.h>, <opus_multistream.h>, <opus_projection.h>.
        include_dirs = { "*/include" },

        sources = {
            "*/celt/bands.c",
            "*/celt/celt.c",
            "*/celt/celt_encoder.c",
            "*/celt/celt_decoder.c",
            "*/celt/cwrs.c",
            "*/celt/entcode.c",
            "*/celt/entdec.c",
            "*/celt/entenc.c",
            "*/celt/kiss_fft.c",
            "*/celt/laplace.c",
            "*/celt/mathops.c",
            "*/celt/mdct.c",
            "*/celt/modes.c",
            "*/celt/pitch.c",
            "*/celt/celt_lpc.c",
            "*/celt/quant_bands.c",
            "*/celt/rate.c",
            "*/celt/vq.c",
            "*/silk/*.c",
            "*/silk/float/*.c",
            "*/src/opus.c",
            "*/src/opus_decoder.c",
            "*/src/opus_encoder.c",
            "*/src/extensions.c",
            "*/src/opus_multistream.c",
            "*/src/opus_multistream_encoder.c",
            "*/src/opus_multistream_decoder.c",
            "*/src/repacketizer.c",
            "*/src/opus_projection_encoder.c",
            "*/src/opus_projection_decoder.c",
            "*/src/mapping_matrix.c",
            "*/src/analysis.c",
            "*/src/mlp.c",
            "*/src/mlp_data.c",
        },
        cflags = { "-DHAVE_CONFIG_H" },

        generated_files = {
            ["mcpp_generated/config.h"] = [==[
/* config.h for libopus 1.6.1 — what upstream's configure defines for its
   default floating-point build without intrinsics. */
#ifndef MCPP_COMPAT_OPUS_CONFIG_H
#define MCPP_COMPAT_OPUS_CONFIG_H

#define OPUS_BUILD 1
#define PACKAGE_VERSION "1.6.1"

/* C99 variable-length arrays for the codec's stack buffers. */
#define VAR_ARRAYS 1

#define HAVE_LRINT 1
#define HAVE_LRINTF 1

/* Run-time checks that are cheap and safe for use in production (default on). */
#define ENABLE_HARDENING 1

#endif
]==],
        },

        linux = {
            include_dirs         = { "*", "*/celt", "*/silk", "*/silk/float", "mcpp_generated" },
            private_include_dirs = { "*", "*/celt", "*/silk", "*/silk/float", "mcpp_generated" },
            -- Linked into shared objects by its consumers: position independent;
            -- only the OPUS_EXPORT functions visible, as upstream's configure does.
            cflags               = { "-fPIC", "-fvisibility=hidden" },
            ldflags              = { "-lm" },
        },
        macosx = {
            include_dirs         = { "*", "*/celt", "*/silk", "*/silk/float", "mcpp_generated" },
            private_include_dirs = { "*", "*/celt", "*/silk", "*/silk/float", "mcpp_generated" },
            cflags               = { "-fPIC", "-fvisibility=hidden" },
        },
        -- No -fPIC: PE/COFF has no such distinction, and clang rejects it for
        -- the MSVC target.
        windows = {
            include_dirs         = { "*", "*/celt", "*/silk", "*/silk/float", "mcpp_generated" },
            private_include_dirs = { "*", "*/celt", "*/silk", "*/silk/float", "mcpp_generated" },
        },

        targets = { opus = { kind = "lib" } },
        deps    = {},
    },
}
