-- compat.libvpx — libvpx 1.17.0, the WebM project's VP9 video codec (encoder
-- and decoder), BSD-3-Clause with the WebM project's royalty-free patent
-- grant (PATENTS).
--
-- VP9 is the royalty-free video codec of WebM: what browsers decode
-- everywhere, YouTube streams and the WebM container (compat.libwebm) carries.
-- This package is the reference encoder and decoder: one-pass and two-pass
-- encoding at every speed (good quality and real time), constant quality,
-- bit rate targets, lossless, spatial and temporal layers, and the decoder
-- with frame-parallel and row-multithreaded decoding.
--
-- ─────────────────────────────────────────────────────────────────────────
-- THE TAG ARCHIVE AND UPSTREAM'S OWN CONFIGURE, ONCE
--
-- libvpx publishes no release tarball: the archive is the v1.17.0 tag's
-- (GitHub mirror of chromium.googlesource.com/webm/libvpx). Its build is a
-- hand-written configure script and makefiles that generate a config header
-- and three run-time CPU dispatch ("RTCD") headers with perl. They were
-- generated once, by upstream's own
--
--     configure --target=generic-gnu --disable-vp8 --enable-vp9
--               --disable-examples --disable-tools --disable-docs
--               --disable-unit-tests --disable-webm-io --disable-libyuv
--               --enable-static --disable-shared --enable-multithread
--
-- and are carried here as generated_files, unchanged but for the three lines
-- of vpx_config.h that describe the host operating system (pthread.h and
-- unistd.h everywhere but Windows, where vpx_util/vpx_pthread.h maps the
-- worker threads onto Win32; pthread_setname_np where glibc or Apple has it,
-- which vpx_thread.c tests with #ifdef), now decided by the preprocessor.
-- The source list is exactly the 101 C files that configuration's
-- makefiles compile (plus its vpx_config.c, generated: the build-config
-- string vpx_codec_build_config() answers).
--
-- ─────────────────────────────────────────────────────────────────────────
-- GENERIC C: NO SIMD, NO ASSEMBLER, NO CPU DETECTION
--
-- The generic target is libvpx's portable reference build: every DSP
-- function is its C version (the RTCD headers #define each name to its _c
-- function), so one configuration builds unchanged on x86-64 and aarch64,
-- on Linux, macOS, Windows and Emscripten. libvpx's x86 speed comes from
-- yasm/nasm assembly and per-file intrinsics flags (-mssse3, -mavx2 …)
-- behind run-time dispatch, which a descriptor cannot select per file and
-- per architecture; those are a later revision. The C paths are the ones
-- upstream's own tests check every SIMD version against.
--
-- Multithreading is ON (configure's default): an encoder or decoder asked for
-- one thread (the default, g_threads = 0 or 1) creates none, so a
-- single-threaded encode is reproducible; more threads tile the work. On
-- Emscripten without its pthreads (no -pthread) CONFIG_MULTITHREAD is 0:
-- libvpx's single-threaded worker then runs each tile's job in turn, so a
-- request for threads still encodes, on one.
--
-- ─────────────────────────────────────────────────────────────────────────
-- HEADERS
--
-- Consumers include <vpx/vpx_encoder.h>, <vpx/vpx_decoder.h>,
-- <vpx/vp8cx.h> and <vpx/vp8dx.h> (upstream's installed layout) from the
-- archive root. The generated headers are a private include directory of
-- each platform block (the shape compat.opus uses): the library's own
-- sources reach "./vpx_config.h" and "./vpx_dsp_rtcd.h" there, consumers do
-- not need them.
--
-- kind = "lib": a static library.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "libvpx",
    description = "libvpx 1.17.0 — the VP9 video codec (encoder and decoder), portable C, BSD-3-Clause with a royalty-free patent grant",
    licenses    = {"BSD-3-Clause"},
    repo        = "https://github.com/webmproject/libvpx",
    type        = "package",

    extensions = {
        autoupdate = {
            tag = "v${version}",
            url = "https://github.com/webmproject/libvpx/archive/refs/tags/${tag}.tar.gz",
        },
    },

    xpm = {
        linux = {
            ["1.17.0"] = {
                url    = "https://github.com/webmproject/libvpx/archive/refs/tags/v1.17.0.tar.gz",
                sha256 = "1020f184046187baa2985dbde38e0691f49c44088bca7a1842b0236c6081dc0a",
            },
        },
        macosx = {
            ["1.17.0"] = {
                url    = "https://github.com/webmproject/libvpx/archive/refs/tags/v1.17.0.tar.gz",
                sha256 = "1020f184046187baa2985dbde38e0691f49c44088bca7a1842b0236c6081dc0a",
            },
        },
        windows = {
            ["1.17.0"] = {
                url    = "https://github.com/webmproject/libvpx/archive/refs/tags/v1.17.0.tar.gz",
                sha256 = "1020f184046187baa2985dbde38e0691f49c44088bca7a1842b0236c6081dc0a",
            },
        },
    },

    mcpp = {
        language   = "c++23",
        import_std = false,
        c_standard = "c11",

        -- <vpx/…>: the public headers, at the archive root as installed.
        include_dirs = { "*" },

        sources = {
            "*/vp9/common/vp9_alloccommon.c",
            "*/vp9/common/vp9_blockd.c",
            "*/vp9/common/vp9_common_data.c",
            "*/vp9/common/vp9_entropy.c",
            "*/vp9/common/vp9_entropymode.c",
            "*/vp9/common/vp9_entropymv.c",
            "*/vp9/common/vp9_filter.c",
            "*/vp9/common/vp9_frame_buffers.c",
            "*/vp9/common/vp9_idct.c",
            "*/vp9/common/vp9_loopfilter.c",
            "*/vp9/common/vp9_mvref_common.c",
            "*/vp9/common/vp9_pred_common.c",
            "*/vp9/common/vp9_quant_common.c",
            "*/vp9/common/vp9_reconinter.c",
            "*/vp9/common/vp9_reconintra.c",
            "*/vp9/common/vp9_rtcd.c",
            "*/vp9/common/vp9_scale.c",
            "*/vp9/common/vp9_scan.c",
            "*/vp9/common/vp9_seg_common.c",
            "*/vp9/common/vp9_thread_common.c",
            "*/vp9/common/vp9_tile_common.c",
            "*/vp9/decoder/vp9_decodeframe.c",
            "*/vp9/decoder/vp9_decodemv.c",
            "*/vp9/decoder/vp9_decoder.c",
            "*/vp9/decoder/vp9_detokenize.c",
            "*/vp9/decoder/vp9_dsubexp.c",
            "*/vp9/decoder/vp9_job_queue.c",
            "*/vp9/encoder/vp9_alt_ref_aq.c",
            "*/vp9/encoder/vp9_aq_360.c",
            "*/vp9/encoder/vp9_aq_complexity.c",
            "*/vp9/encoder/vp9_aq_cyclicrefresh.c",
            "*/vp9/encoder/vp9_aq_variance.c",
            "*/vp9/encoder/vp9_bitstream.c",
            "*/vp9/encoder/vp9_context_tree.c",
            "*/vp9/encoder/vp9_cost.c",
            "*/vp9/encoder/vp9_dct.c",
            "*/vp9/encoder/vp9_encodeframe.c",
            "*/vp9/encoder/vp9_encodemb.c",
            "*/vp9/encoder/vp9_encodemv.c",
            "*/vp9/encoder/vp9_encoder.c",
            "*/vp9/encoder/vp9_ethread.c",
            "*/vp9/encoder/vp9_extend.c",
            "*/vp9/encoder/vp9_ext_ratectrl.c",
            "*/vp9/encoder/vp9_firstpass.c",
            "*/vp9/encoder/vp9_frame_scale.c",
            "*/vp9/encoder/vp9_lookahead.c",
            "*/vp9/encoder/vp9_mbgraph.c",
            "*/vp9/encoder/vp9_mcomp.c",
            "*/vp9/encoder/vp9_multi_thread.c",
            "*/vp9/encoder/vp9_noise_estimate.c",
            "*/vp9/encoder/vp9_picklpf.c",
            "*/vp9/encoder/vp9_pickmode.c",
            "*/vp9/encoder/vp9_quantize.c",
            "*/vp9/encoder/vp9_ratectrl.c",
            "*/vp9/encoder/vp9_rd.c",
            "*/vp9/encoder/vp9_rdopt.c",
            "*/vp9/encoder/vp9_resize.c",
            "*/vp9/encoder/vp9_segmentation.c",
            "*/vp9/encoder/vp9_skin_detection.c",
            "*/vp9/encoder/vp9_speed_features.c",
            "*/vp9/encoder/vp9_subexp.c",
            "*/vp9/encoder/vp9_svc_layercontext.c",
            "*/vp9/encoder/vp9_temporal_filter.c",
            "*/vp9/encoder/vp9_tokenize.c",
            "*/vp9/encoder/vp9_tpl_model.c",
            "*/vp9/encoder/vp9_treewriter.c",
            "*/vp9/vp9_cx_iface.c",
            "*/vp9/vp9_dx_iface.c",
            "*/vp9/vp9_iface_common.c",
            "*/vpx_dsp/avg.c",
            "*/vpx_dsp/bitreader_buffer.c",
            "*/vpx_dsp/bitreader.c",
            "*/vpx_dsp/bitwriter_buffer.c",
            "*/vpx_dsp/bitwriter.c",
            "*/vpx_dsp/fwd_txfm.c",
            "*/vpx_dsp/intrapred.c",
            "*/vpx_dsp/inv_txfm.c",
            "*/vpx_dsp/loopfilter.c",
            "*/vpx_dsp/prob.c",
            "*/vpx_dsp/psnr.c",
            "*/vpx_dsp/quantize.c",
            "*/vpx_dsp/sad.c",
            "*/vpx_dsp/skin_detection.c",
            "*/vpx_dsp/sse.c",
            "*/vpx_dsp/subtract.c",
            "*/vpx_dsp/sum_squares.c",
            "*/vpx_dsp/variance.c",
            "*/vpx_dsp/vpx_convolve.c",
            "*/vpx_dsp/vpx_dsp_rtcd.c",
            "*/vpx_mem/vpx_mem.c",
            "*/vpx_scale/generic/gen_scalers.c",
            "*/vpx_scale/generic/vpx_scale.c",
            "*/vpx_scale/generic/yv12config.c",
            "*/vpx_scale/generic/yv12extend.c",
            "*/vpx_scale/vpx_scale_rtcd.c",
            "*/vpx/src/vpx_codec.c",
            "*/vpx/src/vpx_decoder.c",
            "*/vpx/src/vpx_encoder.c",
            "*/vpx/src/vpx_image.c",
            "*/vpx_util/vpx_thread.c",
            "*/vpx_util/vpx_write_yuv_frame.c",
            "mcpp_generated/vpx_config.c",
        },

        generated_files = {
            ["mcpp_generated/vpx_config.h"] = [==[
/* Copyright (c) 2011 The WebM project authors. All Rights Reserved. */
/*  */
/* Use of this source code is governed by a BSD-style license */
/* that can be found in the LICENSE file in the root of the source */
/* tree. An additional intellectual property rights grant can be found */
/* in the file PATENTS.  All contributing project authors may */
/* be found in the AUTHORS file in the root of the source tree. */
/* This file automatically generated by configure. Do not edit! */
/* compat.libvpx: configure --target=generic-gnu --disable-vp8 --enable-vp9
   --enable-multithread (no SIMD, no assembler, no run-time CPU detection);
   what depends on the operating system is decided below, where configure
   would have probed the host. */
#ifndef VPX_CONFIG_H
#define VPX_CONFIG_H
#define RESTRICT    
#define INLINE      inline
#define VPX_ARCH_ARM 0
#define VPX_ARCH_AARCH64 0
#define VPX_ARCH_MIPS 0
#define VPX_ARCH_X86 0
#define VPX_ARCH_X86_64 0
#define VPX_ARCH_PPC 0
#define VPX_ARCH_LOONGARCH 0
#define HAVE_NEON_ASM 0
#define HAVE_NEON 0
#define HAVE_NEON_DOTPROD 0
#define HAVE_NEON_I8MM 0
#define HAVE_SVE 0
#define HAVE_SVE2 0
#define HAVE_MIPS32 0
#define HAVE_DSPR2 0
#define HAVE_MSA 0
#define HAVE_MIPS64 0
#define HAVE_X86_ASM 0
#define HAVE_MMX 0
#define HAVE_SSE 0
#define HAVE_SSE2 0
#define HAVE_SSE3 0
#define HAVE_SSSE3 0
#define HAVE_SSE4_1 0
#define HAVE_AVX 0
#define HAVE_AVX2 0
#define HAVE_AVX512 0
#define HAVE_VSX 0
#define HAVE_MMI 0
#define HAVE_LSX 0
#define HAVE_LASX 0
#define HAVE_VPX_PORTS 1
#if defined(_WIN32)
/* Windows: vpx_util/vpx_pthread.h maps the worker threads onto Win32. */
#define HAVE_PTHREAD_H 0
#define HAVE_UNISTD_H 0
#else
#define HAVE_PTHREAD_H 1
#define HAVE_UNISTD_H 1
#endif
/* Only where it is: vpx_util/vpx_thread.c tests it with #ifdef. */
#if defined(__APPLE__) || (defined(__GLIBC__) && !defined(__GNU__))
#define HAVE_PTHREAD_SETNAME_NP 1
#endif
#define CONFIG_DEPENDENCY_TRACKING 1
#define CONFIG_EXTERNAL_BUILD 0
#define CONFIG_INSTALL_DOCS 1
#define CONFIG_INSTALL_BINS 1
#define CONFIG_INSTALL_LIBS 1
#define CONFIG_INSTALL_SRCS 0
#define CONFIG_DEBUG 0
#define CONFIG_GPROF 0
#define CONFIG_GCOV 0
#define CONFIG_RVCT 0
#define CONFIG_GCC 1
#define CONFIG_MSVS 0
#define CONFIG_PIC 1
#define CONFIG_BIG_ENDIAN 0
#define CONFIG_CODEC_SRCS 0
#define CONFIG_DEBUG_LIBS 0
#define CONFIG_DEQUANT_TOKENS 0
#define CONFIG_DC_RECON 0
#define CONFIG_RUNTIME_CPU_DETECT 0
#define CONFIG_POSTPROC 0
#define CONFIG_VP9_POSTPROC 0
#if defined(__EMSCRIPTEN__) && !defined(__EMSCRIPTEN_PTHREADS__)
#define CONFIG_MULTITHREAD 0
#else
#define CONFIG_MULTITHREAD 1
#endif
#define CONFIG_INTERNAL_STATS 0
#define CONFIG_VP8_ENCODER 0
#define CONFIG_VP8_DECODER 0
#define CONFIG_VP9_ENCODER 1
#define CONFIG_VP9_DECODER 1
#define CONFIG_VP8 0
#define CONFIG_VP9 1
#define CONFIG_ENCODERS 1
#define CONFIG_DECODERS 1
#define CONFIG_STATIC_MSVCRT 0
#define CONFIG_SPATIAL_RESAMPLING 1
#define CONFIG_REALTIME_ONLY 0
#define CONFIG_ONTHEFLY_BITPACKING 0
#define CONFIG_ERROR_CONCEALMENT 0
#define CONFIG_SHARED 0
#define CONFIG_STATIC 1
#define CONFIG_SMALL 0
#define CONFIG_POSTPROC_VISUALIZER 0
#define CONFIG_OS_SUPPORT 1
#define CONFIG_UNIT_TESTS 0
#define CONFIG_WEBM_IO 0
#define CONFIG_LIBYUV 0
#define CONFIG_DECODE_PERF_TESTS 0
#define CONFIG_ENCODE_PERF_TESTS 0
#define CONFIG_MULTI_RES_ENCODING 0
#define CONFIG_TEMPORAL_DENOISING 1
#define CONFIG_VP9_TEMPORAL_DENOISING 0
#define CONFIG_COEFFICIENT_RANGE_CHECKING 0
#define CONFIG_VP9_HIGHBITDEPTH 0
#define CONFIG_BETTER_HW_COMPATIBILITY 0
#define CONFIG_EXPERIMENTAL 0
#define CONFIG_SIZE_LIMIT 0
#define CONFIG_ALWAYS_ADJUST_BPM 0
#define CONFIG_BITSTREAM_DEBUG 0
#define CONFIG_MISMATCH_DEBUG 0
#define CONFIG_FP_MB_STATS 0
#define CONFIG_EMULATE_HARDWARE 0
#define CONFIG_NON_GREEDY_MV 0
#define CONFIG_COLLECT_COMPONENT_TIMING 0
#endif /* VPX_CONFIG_H */
]==],
            ["mcpp_generated/vpx_config.c"] = [==[
/* Copyright (c) 2011 The WebM project authors. All Rights Reserved. */
/*  */
/* Use of this source code is governed by a BSD-style license */
/* that can be found in the LICENSE file in the root of the source */
/* tree. An additional intellectual property rights grant can be found */
/* in the file PATENTS.  All contributing project authors may */
/* be found in the AUTHORS file in the root of the source tree. */
#include "vpx/vpx_codec.h"
static const char* const cfg = "--target=generic-gnu --disable-vp8 --enable-vp9 --disable-examples --disable-tools --disable-docs --disable-unit-tests --disable-webm-io --disable-libyuv --enable-static --disable-shared --enable-multithread";
const char *vpx_codec_build_config(void) {return cfg;}
]==],
            ["mcpp_generated/vpx_version.h"] = [==[
// This file is generated. Do not edit.
#ifndef VPX_VERSION_H_
#define VPX_VERSION_H_
#define VERSION_MAJOR  1
#define VERSION_MINOR  17
#define VERSION_PATCH  0
#define VERSION_EXTRA  ""
#define VERSION_PACKED ((VERSION_MAJOR<<16)|(VERSION_MINOR<<8)|(VERSION_PATCH))
#define VERSION_STRING_NOSP "v1.17.0"
#define VERSION_STRING      " v1.17.0"
#endif  // VPX_VERSION_H_
]==],
            ["mcpp_generated/vp9_rtcd.h"] = [==[
/*
 *  Copyright (c) 2017 The WebM project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

// This file is generated. Do not edit.
#ifndef VP9_RTCD_H_
#define VP9_RTCD_H_

#ifdef RTCD_C
#define RTCD_EXTERN
#else
#define RTCD_EXTERN extern
#endif

/*
 * VP9
 */

#include "vpx/vpx_integer.h"
#include "vp9/common/vp9_common.h"
#include "vp9/common/vp9_enums.h"
#include "vp9/common/vp9_filter.h"
#if !CONFIG_REALTIME_ONLY && CONFIG_VP9_ENCODER
#include "vp9/encoder/vp9_temporal_filter.h"
#endif

struct macroblockd;

/* Encoder forward decls */
struct macroblock;
struct macroblock_plane;
struct vp9_sad_table;
struct ScanOrder;
struct search_site_config;
struct mv;
union int_mv;
struct yv12_buffer_config;

#ifdef __cplusplus
extern "C" {
#endif

void vp9_apply_temporal_filter_c(const uint8_t *y_src, int y_src_stride, const uint8_t *y_pre, int y_pre_stride, const uint8_t *u_src, const uint8_t *v_src, int uv_src_stride, const uint8_t *u_pre, const uint8_t *v_pre, int uv_pre_stride, unsigned int block_width, unsigned int block_height, int ss_x, int ss_y, int strength, const int *const blk_fw, int use_32x32, uint32_t *y_accumulator, uint16_t *y_count, uint32_t *u_accumulator, uint16_t *u_count, uint32_t *v_accumulator, uint16_t *v_count);
#define vp9_apply_temporal_filter vp9_apply_temporal_filter_c

int64_t vp9_block_error_c(const tran_low_t *coeff, const tran_low_t *dqcoeff, intptr_t block_size, int64_t *ssz);
#define vp9_block_error vp9_block_error_c

int64_t vp9_block_error_fp_c(const tran_low_t *coeff, const tran_low_t *dqcoeff, int block_size);
#define vp9_block_error_fp vp9_block_error_fp_c

int vp9_diamond_search_sad_c(const struct macroblock *x, const struct search_site_config *cfg,  struct mv *ref_mv, uint32_t start_mv_sad, struct mv *best_mv, int search_param, int sad_per_bit, int *num00, const struct vp9_sad_table *sad_fn_ptr, const struct mv *center_mv);
#define vp9_diamond_search_sad vp9_diamond_search_sad_c

void vp9_fht16x16_c(const int16_t *input, tran_low_t *output, int stride, int tx_type);
#define vp9_fht16x16 vp9_fht16x16_c

void vp9_fht4x4_c(const int16_t *input, tran_low_t *output, int stride, int tx_type);
#define vp9_fht4x4 vp9_fht4x4_c

void vp9_fht8x8_c(const int16_t *input, tran_low_t *output, int stride, int tx_type);
#define vp9_fht8x8 vp9_fht8x8_c

void vp9_fwht4x4_c(const int16_t *input, tran_low_t *output, int stride);
#define vp9_fwht4x4 vp9_fwht4x4_c

void vp9_iht16x16_256_add_c(const tran_low_t *input, uint8_t *dest, int stride, int tx_type);
#define vp9_iht16x16_256_add vp9_iht16x16_256_add_c

void vp9_iht4x4_16_add_c(const tran_low_t *input, uint8_t *dest, int stride, int tx_type);
#define vp9_iht4x4_16_add vp9_iht4x4_16_add_c

void vp9_iht8x8_64_add_c(const tran_low_t *input, uint8_t *dest, int stride, int tx_type);
#define vp9_iht8x8_64_add vp9_iht8x8_64_add_c

void vp9_quantize_fp_c(const tran_low_t *coeff_ptr, intptr_t n_coeffs, const struct macroblock_plane *const mb_plane, tran_low_t *qcoeff_ptr, tran_low_t *dqcoeff_ptr, const int16_t *dequant_ptr, uint16_t *eob_ptr, const struct ScanOrder *const scan_order);
#define vp9_quantize_fp vp9_quantize_fp_c

void vp9_quantize_fp_32x32_c(const tran_low_t *coeff_ptr, intptr_t n_coeffs, const struct macroblock_plane *const mb_plane, tran_low_t *qcoeff_ptr, tran_low_t *dqcoeff_ptr, const int16_t *dequant_ptr, uint16_t *eob_ptr, const struct ScanOrder *const scan_order);
#define vp9_quantize_fp_32x32 vp9_quantize_fp_32x32_c

void vp9_scale_and_extend_frame_c(const struct yv12_buffer_config *src, struct yv12_buffer_config *dst, INTERP_FILTER filter_type, int phase_scaler);
#define vp9_scale_and_extend_frame vp9_scale_and_extend_frame_c

void vpx_convolve12_c(const uint8_t *src, ptrdiff_t src_stride, uint8_t *dst, ptrdiff_t dst_stride, const InterpKernel12 *filter, int x0_q4, int x_step_q4, int y0_q4, int y_step_q4, int w, int h);
#define vpx_convolve12 vpx_convolve12_c

void vpx_convolve12_horiz_c(const uint8_t *src, ptrdiff_t src_stride, uint8_t *dst, ptrdiff_t dst_stride, const InterpKernel12 *filter, int x0_q4, int x_step_q4, int y0_q4, int y_step_q4, int w, int h);
#define vpx_convolve12_horiz vpx_convolve12_horiz_c

void vpx_convolve12_vert_c(const uint8_t *src, ptrdiff_t src_stride, uint8_t *dst, ptrdiff_t dst_stride, const InterpKernel12 *filter, int x0_q4, int x_step_q4, int y0_q4, int y_step_q4, int w, int h);
#define vpx_convolve12_vert vpx_convolve12_vert_c

void vp9_rtcd(void);

#include "vpx_config.h"

#ifdef RTCD_C
static void setup_rtcd_internal(void)
{
}
#endif

#ifdef __cplusplus
}  // extern "C"
#endif

#endif  // VP9_RTCD_H_
]==],
            ["mcpp_generated/vpx_dsp_rtcd.h"] = [==[
/*
 *  Copyright (c) 2017 The WebM project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

// This file is generated. Do not edit.
#ifndef VPX_DSP_RTCD_H_
#define VPX_DSP_RTCD_H_

#ifdef RTCD_C
#define RTCD_EXTERN
#else
#define RTCD_EXTERN extern
#endif

/*
 * DSP
 */

#include "vpx/vpx_integer.h"
#include "vpx_dsp/vpx_dsp_common.h"
#include "vpx_dsp/vpx_filter.h"
#if CONFIG_VP9_ENCODER
 struct macroblock_plane;
 struct ScanOrder;
#endif


#ifdef __cplusplus
extern "C" {
#endif

unsigned int vpx_avg_4x4_c(const uint8_t *, int p);
#define vpx_avg_4x4 vpx_avg_4x4_c

unsigned int vpx_avg_8x8_c(const uint8_t *, int p);
#define vpx_avg_8x8 vpx_avg_8x8_c

void vpx_comp_avg_pred_c(uint8_t *comp_pred, const uint8_t *pred, int width, int height, const uint8_t *ref, int ref_stride);
#define vpx_comp_avg_pred vpx_comp_avg_pred_c

void vpx_convolve8_c(const uint8_t *src, ptrdiff_t src_stride, uint8_t *dst, ptrdiff_t dst_stride, const InterpKernel *filter, int x0_q4, int x_step_q4, int y0_q4, int y_step_q4, int w, int h);
#define vpx_convolve8 vpx_convolve8_c

void vpx_convolve8_avg_c(const uint8_t *src, ptrdiff_t src_stride, uint8_t *dst, ptrdiff_t dst_stride, const InterpKernel *filter, int x0_q4, int x_step_q4, int y0_q4, int y_step_q4, int w, int h);
#define vpx_convolve8_avg vpx_convolve8_avg_c

void vpx_convolve8_avg_horiz_c(const uint8_t *src, ptrdiff_t src_stride, uint8_t *dst, ptrdiff_t dst_stride, const InterpKernel *filter, int x0_q4, int x_step_q4, int y0_q4, int y_step_q4, int w, int h);
#define vpx_convolve8_avg_horiz vpx_convolve8_avg_horiz_c

void vpx_convolve8_avg_vert_c(const uint8_t *src, ptrdiff_t src_stride, uint8_t *dst, ptrdiff_t dst_stride, const InterpKernel *filter, int x0_q4, int x_step_q4, int y0_q4, int y_step_q4, int w, int h);
#define vpx_convolve8_avg_vert vpx_convolve8_avg_vert_c

void vpx_convolve8_horiz_c(const uint8_t *src, ptrdiff_t src_stride, uint8_t *dst, ptrdiff_t dst_stride, const InterpKernel *filter, int x0_q4, int x_step_q4, int y0_q4, int y_step_q4, int w, int h);
#define vpx_convolve8_horiz vpx_convolve8_horiz_c

void vpx_convolve8_vert_c(const uint8_t *src, ptrdiff_t src_stride, uint8_t *dst, ptrdiff_t dst_stride, const InterpKernel *filter, int x0_q4, int x_step_q4, int y0_q4, int y_step_q4, int w, int h);
#define vpx_convolve8_vert vpx_convolve8_vert_c

void vpx_convolve_avg_c(const uint8_t *src, ptrdiff_t src_stride, uint8_t *dst, ptrdiff_t dst_stride, const InterpKernel *filter, int x0_q4, int x_step_q4, int y0_q4, int y_step_q4, int w, int h);
#define vpx_convolve_avg vpx_convolve_avg_c

void vpx_convolve_copy_c(const uint8_t *src, ptrdiff_t src_stride, uint8_t *dst, ptrdiff_t dst_stride, const InterpKernel *filter, int x0_q4, int x_step_q4, int y0_q4, int y_step_q4, int w, int h);
#define vpx_convolve_copy vpx_convolve_copy_c

void vpx_d117_predictor_16x16_c(uint8_t *dst, ptrdiff_t stride, const uint8_t *above, const uint8_t *left);
#define vpx_d117_predictor_16x16 vpx_d117_predictor_16x16_c

void vpx_d117_predictor_32x32_c(uint8_t *dst, ptrdiff_t stride, const uint8_t *above, const uint8_t *left);
#define vpx_d117_predictor_32x32 vpx_d117_predictor_32x32_c

void vpx_d117_predictor_4x4_c(uint8_t *dst, ptrdiff_t stride, const uint8_t *above, const uint8_t *left);
#define vpx_d117_predictor_4x4 vpx_d117_predictor_4x4_c

void vpx_d117_predictor_8x8_c(uint8_t *dst, ptrdiff_t stride, const uint8_t *above, const uint8_t *left);
#define vpx_d117_predictor_8x8 vpx_d117_predictor_8x8_c

void vpx_d135_predictor_16x16_c(uint8_t *dst, ptrdiff_t stride, const uint8_t *above, const uint8_t *left);
#define vpx_d135_predictor_16x16 vpx_d135_predictor_16x16_c

void vpx_d135_predictor_32x32_c(uint8_t *dst, ptrdiff_t stride, const uint8_t *above, const uint8_t *left);
#define vpx_d135_predictor_32x32 vpx_d135_predictor_32x32_c

void vpx_d135_predictor_4x4_c(uint8_t *dst, ptrdiff_t stride, const uint8_t *above, const uint8_t *left);
#define vpx_d135_predictor_4x4 vpx_d135_predictor_4x4_c

void vpx_d135_predictor_8x8_c(uint8_t *dst, ptrdiff_t stride, const uint8_t *above, const uint8_t *left);
#define vpx_d135_predictor_8x8 vpx_d135_predictor_8x8_c

void vpx_d153_predictor_16x16_c(uint8_t *dst, ptrdiff_t stride, const uint8_t *above, const uint8_t *left);
#define vpx_d153_predictor_16x16 vpx_d153_predictor_16x16_c

void vpx_d153_predictor_32x32_c(uint8_t *dst, ptrdiff_t stride, const uint8_t *above, const uint8_t *left);
#define vpx_d153_predictor_32x32 vpx_d153_predictor_32x32_c

void vpx_d153_predictor_4x4_c(uint8_t *dst, ptrdiff_t stride, const uint8_t *above, const uint8_t *left);
#define vpx_d153_predictor_4x4 vpx_d153_predictor_4x4_c

void vpx_d153_predictor_8x8_c(uint8_t *dst, ptrdiff_t stride, const uint8_t *above, const uint8_t *left);
#define vpx_d153_predictor_8x8 vpx_d153_predictor_8x8_c

void vpx_d207_predictor_16x16_c(uint8_t *dst, ptrdiff_t stride, const uint8_t *above, const uint8_t *left);
#define vpx_d207_predictor_16x16 vpx_d207_predictor_16x16_c

void vpx_d207_predictor_32x32_c(uint8_t *dst, ptrdiff_t stride, const uint8_t *above, const uint8_t *left);
#define vpx_d207_predictor_32x32 vpx_d207_predictor_32x32_c

void vpx_d207_predictor_4x4_c(uint8_t *dst, ptrdiff_t stride, const uint8_t *above, const uint8_t *left);
#define vpx_d207_predictor_4x4 vpx_d207_predictor_4x4_c

void vpx_d207_predictor_8x8_c(uint8_t *dst, ptrdiff_t stride, const uint8_t *above, const uint8_t *left);
#define vpx_d207_predictor_8x8 vpx_d207_predictor_8x8_c

void vpx_d45_predictor_16x16_c(uint8_t *dst, ptrdiff_t stride, const uint8_t *above, const uint8_t *left);
#define vpx_d45_predictor_16x16 vpx_d45_predictor_16x16_c

void vpx_d45_predictor_32x32_c(uint8_t *dst, ptrdiff_t stride, const uint8_t *above, const uint8_t *left);
#define vpx_d45_predictor_32x32 vpx_d45_predictor_32x32_c

void vpx_d45_predictor_4x4_c(uint8_t *dst, ptrdiff_t stride, const uint8_t *above, const uint8_t *left);
#define vpx_d45_predictor_4x4 vpx_d45_predictor_4x4_c

void vpx_d45_predictor_8x8_c(uint8_t *dst, ptrdiff_t stride, const uint8_t *above, const uint8_t *left);
#define vpx_d45_predictor_8x8 vpx_d45_predictor_8x8_c

void vpx_d45e_predictor_4x4_c(uint8_t *dst, ptrdiff_t stride, const uint8_t *above, const uint8_t *left);
#define vpx_d45e_predictor_4x4 vpx_d45e_predictor_4x4_c

void vpx_d63_predictor_16x16_c(uint8_t *dst, ptrdiff_t stride, const uint8_t *above, const uint8_t *left);
#define vpx_d63_predictor_16x16 vpx_d63_predictor_16x16_c

void vpx_d63_predictor_32x32_c(uint8_t *dst, ptrdiff_t stride, const uint8_t *above, const uint8_t *left);
#define vpx_d63_predictor_32x32 vpx_d63_predictor_32x32_c

void vpx_d63_predictor_4x4_c(uint8_t *dst, ptrdiff_t stride, const uint8_t *above, const uint8_t *left);
#define vpx_d63_predictor_4x4 vpx_d63_predictor_4x4_c

void vpx_d63_predictor_8x8_c(uint8_t *dst, ptrdiff_t stride, const uint8_t *above, const uint8_t *left);
#define vpx_d63_predictor_8x8 vpx_d63_predictor_8x8_c

void vpx_d63e_predictor_4x4_c(uint8_t *dst, ptrdiff_t stride, const uint8_t *above, const uint8_t *left);
#define vpx_d63e_predictor_4x4 vpx_d63e_predictor_4x4_c

void vpx_dc_128_predictor_16x16_c(uint8_t *dst, ptrdiff_t stride, const uint8_t *above, const uint8_t *left);
#define vpx_dc_128_predictor_16x16 vpx_dc_128_predictor_16x16_c

void vpx_dc_128_predictor_32x32_c(uint8_t *dst, ptrdiff_t stride, const uint8_t *above, const uint8_t *left);
#define vpx_dc_128_predictor_32x32 vpx_dc_128_predictor_32x32_c

void vpx_dc_128_predictor_4x4_c(uint8_t *dst, ptrdiff_t stride, const uint8_t *above, const uint8_t *left);
#define vpx_dc_128_predictor_4x4 vpx_dc_128_predictor_4x4_c

void vpx_dc_128_predictor_8x8_c(uint8_t *dst, ptrdiff_t stride, const uint8_t *above, const uint8_t *left);
#define vpx_dc_128_predictor_8x8 vpx_dc_128_predictor_8x8_c

void vpx_dc_left_predictor_16x16_c(uint8_t *dst, ptrdiff_t stride, const uint8_t *above, const uint8_t *left);
#define vpx_dc_left_predictor_16x16 vpx_dc_left_predictor_16x16_c

void vpx_dc_left_predictor_32x32_c(uint8_t *dst, ptrdiff_t stride, const uint8_t *above, const uint8_t *left);
#define vpx_dc_left_predictor_32x32 vpx_dc_left_predictor_32x32_c

void vpx_dc_left_predictor_4x4_c(uint8_t *dst, ptrdiff_t stride, const uint8_t *above, const uint8_t *left);
#define vpx_dc_left_predictor_4x4 vpx_dc_left_predictor_4x4_c

void vpx_dc_left_predictor_8x8_c(uint8_t *dst, ptrdiff_t stride, const uint8_t *above, const uint8_t *left);
#define vpx_dc_left_predictor_8x8 vpx_dc_left_predictor_8x8_c

void vpx_dc_predictor_16x16_c(uint8_t *dst, ptrdiff_t stride, const uint8_t *above, const uint8_t *left);
#define vpx_dc_predictor_16x16 vpx_dc_predictor_16x16_c

void vpx_dc_predictor_32x32_c(uint8_t *dst, ptrdiff_t stride, const uint8_t *above, const uint8_t *left);
#define vpx_dc_predictor_32x32 vpx_dc_predictor_32x32_c

void vpx_dc_predictor_4x4_c(uint8_t *dst, ptrdiff_t stride, const uint8_t *above, const uint8_t *left);
#define vpx_dc_predictor_4x4 vpx_dc_predictor_4x4_c

void vpx_dc_predictor_8x8_c(uint8_t *dst, ptrdiff_t stride, const uint8_t *above, const uint8_t *left);
#define vpx_dc_predictor_8x8 vpx_dc_predictor_8x8_c

void vpx_dc_top_predictor_16x16_c(uint8_t *dst, ptrdiff_t stride, const uint8_t *above, const uint8_t *left);
#define vpx_dc_top_predictor_16x16 vpx_dc_top_predictor_16x16_c

void vpx_dc_top_predictor_32x32_c(uint8_t *dst, ptrdiff_t stride, const uint8_t *above, const uint8_t *left);
#define vpx_dc_top_predictor_32x32 vpx_dc_top_predictor_32x32_c

void vpx_dc_top_predictor_4x4_c(uint8_t *dst, ptrdiff_t stride, const uint8_t *above, const uint8_t *left);
#define vpx_dc_top_predictor_4x4 vpx_dc_top_predictor_4x4_c

void vpx_dc_top_predictor_8x8_c(uint8_t *dst, ptrdiff_t stride, const uint8_t *above, const uint8_t *left);
#define vpx_dc_top_predictor_8x8 vpx_dc_top_predictor_8x8_c

void vpx_fdct16x16_c(const int16_t *input, tran_low_t *output, int stride);
#define vpx_fdct16x16 vpx_fdct16x16_c

void vpx_fdct16x16_1_c(const int16_t *input, tran_low_t *output, int stride);
#define vpx_fdct16x16_1 vpx_fdct16x16_1_c

void vpx_fdct32x32_c(const int16_t *input, tran_low_t *output, int stride);
#define vpx_fdct32x32 vpx_fdct32x32_c

void vpx_fdct32x32_1_c(const int16_t *input, tran_low_t *output, int stride);
#define vpx_fdct32x32_1 vpx_fdct32x32_1_c

void vpx_fdct32x32_rd_c(const int16_t *input, tran_low_t *output, int stride);
#define vpx_fdct32x32_rd vpx_fdct32x32_rd_c

void vpx_fdct4x4_c(const int16_t *input, tran_low_t *output, int stride);
#define vpx_fdct4x4 vpx_fdct4x4_c

void vpx_fdct4x4_1_c(const int16_t *input, tran_low_t *output, int stride);
#define vpx_fdct4x4_1 vpx_fdct4x4_1_c

void vpx_fdct8x8_c(const int16_t *input, tran_low_t *output, int stride);
#define vpx_fdct8x8 vpx_fdct8x8_c

void vpx_fdct8x8_1_c(const int16_t *input, tran_low_t *output, int stride);
#define vpx_fdct8x8_1 vpx_fdct8x8_1_c

void vpx_get16x16var_c(const uint8_t *src_ptr, int src_stride, const uint8_t *ref_ptr, int ref_stride, unsigned int *sse, int *sum);
#define vpx_get16x16var vpx_get16x16var_c

unsigned int vpx_get4x4sse_cs_c(const unsigned char *src_ptr, int src_stride, const unsigned char *ref_ptr, int ref_stride);
#define vpx_get4x4sse_cs vpx_get4x4sse_cs_c

void vpx_get8x8var_c(const uint8_t *src_ptr, int src_stride, const uint8_t *ref_ptr, int ref_stride, unsigned int *sse, int *sum);
#define vpx_get8x8var vpx_get8x8var_c

unsigned int vpx_get_mb_ss_c(const int16_t *);
#define vpx_get_mb_ss vpx_get_mb_ss_c

void vpx_h_predictor_16x16_c(uint8_t *dst, ptrdiff_t stride, const uint8_t *above, const uint8_t *left);
#define vpx_h_predictor_16x16 vpx_h_predictor_16x16_c

void vpx_h_predictor_32x32_c(uint8_t *dst, ptrdiff_t stride, const uint8_t *above, const uint8_t *left);
#define vpx_h_predictor_32x32 vpx_h_predictor_32x32_c

void vpx_h_predictor_4x4_c(uint8_t *dst, ptrdiff_t stride, const uint8_t *above, const uint8_t *left);
#define vpx_h_predictor_4x4 vpx_h_predictor_4x4_c

void vpx_h_predictor_8x8_c(uint8_t *dst, ptrdiff_t stride, const uint8_t *above, const uint8_t *left);
#define vpx_h_predictor_8x8 vpx_h_predictor_8x8_c

void vpx_hadamard_16x16_c(const int16_t *src_diff, ptrdiff_t src_stride, int16_t *coeff);
#define vpx_hadamard_16x16 vpx_hadamard_16x16_c

void vpx_hadamard_32x32_c(const int16_t *src_diff, ptrdiff_t src_stride, int16_t *coeff);
#define vpx_hadamard_32x32 vpx_hadamard_32x32_c

void vpx_hadamard_8x8_c(const int16_t *src_diff, ptrdiff_t src_stride, int16_t *coeff);
#define vpx_hadamard_8x8 vpx_hadamard_8x8_c

void vpx_he_predictor_4x4_c(uint8_t *dst, ptrdiff_t stride, const uint8_t *above, const uint8_t *left);
#define vpx_he_predictor_4x4 vpx_he_predictor_4x4_c

void vpx_idct16x16_10_add_c(const tran_low_t *input, uint8_t *dest, int stride);
#define vpx_idct16x16_10_add vpx_idct16x16_10_add_c

void vpx_idct16x16_1_add_c(const tran_low_t *input, uint8_t *dest, int stride);
#define vpx_idct16x16_1_add vpx_idct16x16_1_add_c

void vpx_idct16x16_256_add_c(const tran_low_t *input, uint8_t *dest, int stride);
#define vpx_idct16x16_256_add vpx_idct16x16_256_add_c

void vpx_idct16x16_38_add_c(const tran_low_t *input, uint8_t *dest, int stride);
#define vpx_idct16x16_38_add vpx_idct16x16_38_add_c

void vpx_idct32x32_1024_add_c(const tran_low_t *input, uint8_t *dest, int stride);
#define vpx_idct32x32_1024_add vpx_idct32x32_1024_add_c

void vpx_idct32x32_135_add_c(const tran_low_t *input, uint8_t *dest, int stride);
#define vpx_idct32x32_135_add vpx_idct32x32_135_add_c

void vpx_idct32x32_1_add_c(const tran_low_t *input, uint8_t *dest, int stride);
#define vpx_idct32x32_1_add vpx_idct32x32_1_add_c

void vpx_idct32x32_34_add_c(const tran_low_t *input, uint8_t *dest, int stride);
#define vpx_idct32x32_34_add vpx_idct32x32_34_add_c

void vpx_idct4x4_16_add_c(const tran_low_t *input, uint8_t *dest, int stride);
#define vpx_idct4x4_16_add vpx_idct4x4_16_add_c

void vpx_idct4x4_1_add_c(const tran_low_t *input, uint8_t *dest, int stride);
#define vpx_idct4x4_1_add vpx_idct4x4_1_add_c

void vpx_idct8x8_12_add_c(const tran_low_t *input, uint8_t *dest, int stride);
#define vpx_idct8x8_12_add vpx_idct8x8_12_add_c

void vpx_idct8x8_1_add_c(const tran_low_t *input, uint8_t *dest, int stride);
#define vpx_idct8x8_1_add vpx_idct8x8_1_add_c

void vpx_idct8x8_64_add_c(const tran_low_t *input, uint8_t *dest, int stride);
#define vpx_idct8x8_64_add vpx_idct8x8_64_add_c

int16_t vpx_int_pro_col_c(const uint8_t *ref, const int width);
#define vpx_int_pro_col vpx_int_pro_col_c

void vpx_int_pro_row_c(int16_t hbuf[16], const uint8_t *ref, const int ref_stride, const int height);
#define vpx_int_pro_row vpx_int_pro_row_c

void vpx_iwht4x4_16_add_c(const tran_low_t *input, uint8_t *dest, int stride);
#define vpx_iwht4x4_16_add vpx_iwht4x4_16_add_c

void vpx_iwht4x4_1_add_c(const tran_low_t *input, uint8_t *dest, int stride);
#define vpx_iwht4x4_1_add vpx_iwht4x4_1_add_c

void vpx_lpf_horizontal_16_c(uint8_t *s, int pitch, const uint8_t *blimit, const uint8_t *limit, const uint8_t *thresh);
#define vpx_lpf_horizontal_16 vpx_lpf_horizontal_16_c

void vpx_lpf_horizontal_16_dual_c(uint8_t *s, int pitch, const uint8_t *blimit, const uint8_t *limit, const uint8_t *thresh);
#define vpx_lpf_horizontal_16_dual vpx_lpf_horizontal_16_dual_c

void vpx_lpf_horizontal_4_c(uint8_t *s, int pitch, const uint8_t *blimit, const uint8_t *limit, const uint8_t *thresh);
#define vpx_lpf_horizontal_4 vpx_lpf_horizontal_4_c

void vpx_lpf_horizontal_4_dual_c(uint8_t *s, int pitch, const uint8_t *blimit0, const uint8_t *limit0, const uint8_t *thresh0, const uint8_t *blimit1, const uint8_t *limit1, const uint8_t *thresh1);
#define vpx_lpf_horizontal_4_dual vpx_lpf_horizontal_4_dual_c

void vpx_lpf_horizontal_8_c(uint8_t *s, int pitch, const uint8_t *blimit, const uint8_t *limit, const uint8_t *thresh);
#define vpx_lpf_horizontal_8 vpx_lpf_horizontal_8_c

void vpx_lpf_horizontal_8_dual_c(uint8_t *s, int pitch, const uint8_t *blimit0, const uint8_t *limit0, const uint8_t *thresh0, const uint8_t *blimit1, const uint8_t *limit1, const uint8_t *thresh1);
#define vpx_lpf_horizontal_8_dual vpx_lpf_horizontal_8_dual_c

void vpx_lpf_vertical_16_c(uint8_t *s, int pitch, const uint8_t *blimit, const uint8_t *limit, const uint8_t *thresh);
#define vpx_lpf_vertical_16 vpx_lpf_vertical_16_c

void vpx_lpf_vertical_16_dual_c(uint8_t *s, int pitch, const uint8_t *blimit, const uint8_t *limit, const uint8_t *thresh);
#define vpx_lpf_vertical_16_dual vpx_lpf_vertical_16_dual_c

void vpx_lpf_vertical_4_c(uint8_t *s, int pitch, const uint8_t *blimit, const uint8_t *limit, const uint8_t *thresh);
#define vpx_lpf_vertical_4 vpx_lpf_vertical_4_c

void vpx_lpf_vertical_4_dual_c(uint8_t *s, int pitch, const uint8_t *blimit0, const uint8_t *limit0, const uint8_t *thresh0, const uint8_t *blimit1, const uint8_t *limit1, const uint8_t *thresh1);
#define vpx_lpf_vertical_4_dual vpx_lpf_vertical_4_dual_c

void vpx_lpf_vertical_8_c(uint8_t *s, int pitch, const uint8_t *blimit, const uint8_t *limit, const uint8_t *thresh);
#define vpx_lpf_vertical_8 vpx_lpf_vertical_8_c

void vpx_lpf_vertical_8_dual_c(uint8_t *s, int pitch, const uint8_t *blimit0, const uint8_t *limit0, const uint8_t *thresh0, const uint8_t *blimit1, const uint8_t *limit1, const uint8_t *thresh1);
#define vpx_lpf_vertical_8_dual vpx_lpf_vertical_8_dual_c

void vpx_minmax_8x8_c(const uint8_t *s, int p, const uint8_t *d, int dp, int *min, int *max);
#define vpx_minmax_8x8 vpx_minmax_8x8_c

unsigned int vpx_mse16x16_c(const uint8_t *src_ptr, int src_stride, const uint8_t *ref_ptr, int ref_stride, unsigned int *sse);
#define vpx_mse16x16 vpx_mse16x16_c

unsigned int vpx_mse16x8_c(const uint8_t *src_ptr, int src_stride, const uint8_t *ref_ptr, int ref_stride, unsigned int *sse);
#define vpx_mse16x8 vpx_mse16x8_c

unsigned int vpx_mse8x16_c(const uint8_t *src_ptr, int src_stride, const uint8_t *ref_ptr, int ref_stride, unsigned int *sse);
#define vpx_mse8x16 vpx_mse8x16_c

unsigned int vpx_mse8x8_c(const uint8_t *src_ptr, int src_stride, const uint8_t *ref_ptr, int ref_stride, unsigned int *sse);
#define vpx_mse8x8 vpx_mse8x8_c

void vpx_quantize_b_c(const tran_low_t *coeff_ptr, intptr_t n_coeffs, const struct macroblock_plane *const mb_plane, tran_low_t *qcoeff_ptr, tran_low_t *dqcoeff_ptr, const int16_t *dequant_ptr, uint16_t *eob_ptr, const struct ScanOrder *const scan_order);
#define vpx_quantize_b vpx_quantize_b_c

void vpx_quantize_b_32x32_c(const tran_low_t *coeff_ptr, const struct macroblock_plane *const mb_plane, tran_low_t *qcoeff_ptr, tran_low_t *dqcoeff_ptr, const int16_t *dequant_ptr, uint16_t *eob_ptr, const struct ScanOrder *const scan_order);
#define vpx_quantize_b_32x32 vpx_quantize_b_32x32_c

unsigned int vpx_sad16x16_c(const uint8_t *src_ptr, int src_stride, const uint8_t *ref_ptr, int ref_stride);
#define vpx_sad16x16 vpx_sad16x16_c

unsigned int vpx_sad16x16_avg_c(const uint8_t *src_ptr, int src_stride, const uint8_t *ref_ptr, int ref_stride, const uint8_t *second_pred);
#define vpx_sad16x16_avg vpx_sad16x16_avg_c

void vpx_sad16x16x4d_c(const uint8_t *src_ptr, int src_stride, const uint8_t *const ref_array[4], int ref_stride, uint32_t sad_array[4]);
#define vpx_sad16x16x4d vpx_sad16x16x4d_c

unsigned int vpx_sad16x32_c(const uint8_t *src_ptr, int src_stride, const uint8_t *ref_ptr, int ref_stride);
#define vpx_sad16x32 vpx_sad16x32_c

unsigned int vpx_sad16x32_avg_c(const uint8_t *src_ptr, int src_stride, const uint8_t *ref_ptr, int ref_stride, const uint8_t *second_pred);
#define vpx_sad16x32_avg vpx_sad16x32_avg_c

void vpx_sad16x32x4d_c(const uint8_t *src_ptr, int src_stride, const uint8_t *const ref_array[4], int ref_stride, uint32_t sad_array[4]);
#define vpx_sad16x32x4d vpx_sad16x32x4d_c

unsigned int vpx_sad16x8_c(const uint8_t *src_ptr, int src_stride, const uint8_t *ref_ptr, int ref_stride);
#define vpx_sad16x8 vpx_sad16x8_c

unsigned int vpx_sad16x8_avg_c(const uint8_t *src_ptr, int src_stride, const uint8_t *ref_ptr, int ref_stride, const uint8_t *second_pred);
#define vpx_sad16x8_avg vpx_sad16x8_avg_c

void vpx_sad16x8x4d_c(const uint8_t *src_ptr, int src_stride, const uint8_t *const ref_array[4], int ref_stride, uint32_t sad_array[4]);
#define vpx_sad16x8x4d vpx_sad16x8x4d_c

unsigned int vpx_sad32x16_c(const uint8_t *src_ptr, int src_stride, const uint8_t *ref_ptr, int ref_stride);
#define vpx_sad32x16 vpx_sad32x16_c

unsigned int vpx_sad32x16_avg_c(const uint8_t *src_ptr, int src_stride, const uint8_t *ref_ptr, int ref_stride, const uint8_t *second_pred);
#define vpx_sad32x16_avg vpx_sad32x16_avg_c

void vpx_sad32x16x4d_c(const uint8_t *src_ptr, int src_stride, const uint8_t *const ref_array[4], int ref_stride, uint32_t sad_array[4]);
#define vpx_sad32x16x4d vpx_sad32x16x4d_c

unsigned int vpx_sad32x32_c(const uint8_t *src_ptr, int src_stride, const uint8_t *ref_ptr, int ref_stride);
#define vpx_sad32x32 vpx_sad32x32_c

unsigned int vpx_sad32x32_avg_c(const uint8_t *src_ptr, int src_stride, const uint8_t *ref_ptr, int ref_stride, const uint8_t *second_pred);
#define vpx_sad32x32_avg vpx_sad32x32_avg_c

void vpx_sad32x32x4d_c(const uint8_t *src_ptr, int src_stride, const uint8_t *const ref_array[4], int ref_stride, uint32_t sad_array[4]);
#define vpx_sad32x32x4d vpx_sad32x32x4d_c

unsigned int vpx_sad32x64_c(const uint8_t *src_ptr, int src_stride, const uint8_t *ref_ptr, int ref_stride);
#define vpx_sad32x64 vpx_sad32x64_c

unsigned int vpx_sad32x64_avg_c(const uint8_t *src_ptr, int src_stride, const uint8_t *ref_ptr, int ref_stride, const uint8_t *second_pred);
#define vpx_sad32x64_avg vpx_sad32x64_avg_c

void vpx_sad32x64x4d_c(const uint8_t *src_ptr, int src_stride, const uint8_t *const ref_array[4], int ref_stride, uint32_t sad_array[4]);
#define vpx_sad32x64x4d vpx_sad32x64x4d_c

unsigned int vpx_sad4x4_c(const uint8_t *src_ptr, int src_stride, const uint8_t *ref_ptr, int ref_stride);
#define vpx_sad4x4 vpx_sad4x4_c

unsigned int vpx_sad4x4_avg_c(const uint8_t *src_ptr, int src_stride, const uint8_t *ref_ptr, int ref_stride, const uint8_t *second_pred);
#define vpx_sad4x4_avg vpx_sad4x4_avg_c

void vpx_sad4x4x4d_c(const uint8_t *src_ptr, int src_stride, const uint8_t *const ref_array[4], int ref_stride, uint32_t sad_array[4]);
#define vpx_sad4x4x4d vpx_sad4x4x4d_c

unsigned int vpx_sad4x8_c(const uint8_t *src_ptr, int src_stride, const uint8_t *ref_ptr, int ref_stride);
#define vpx_sad4x8 vpx_sad4x8_c

unsigned int vpx_sad4x8_avg_c(const uint8_t *src_ptr, int src_stride, const uint8_t *ref_ptr, int ref_stride, const uint8_t *second_pred);
#define vpx_sad4x8_avg vpx_sad4x8_avg_c

void vpx_sad4x8x4d_c(const uint8_t *src_ptr, int src_stride, const uint8_t *const ref_array[4], int ref_stride, uint32_t sad_array[4]);
#define vpx_sad4x8x4d vpx_sad4x8x4d_c

unsigned int vpx_sad64x32_c(const uint8_t *src_ptr, int src_stride, const uint8_t *ref_ptr, int ref_stride);
#define vpx_sad64x32 vpx_sad64x32_c

unsigned int vpx_sad64x32_avg_c(const uint8_t *src_ptr, int src_stride, const uint8_t *ref_ptr, int ref_stride, const uint8_t *second_pred);
#define vpx_sad64x32_avg vpx_sad64x32_avg_c

void vpx_sad64x32x4d_c(const uint8_t *src_ptr, int src_stride, const uint8_t *const ref_array[4], int ref_stride, uint32_t sad_array[4]);
#define vpx_sad64x32x4d vpx_sad64x32x4d_c

unsigned int vpx_sad64x64_c(const uint8_t *src_ptr, int src_stride, const uint8_t *ref_ptr, int ref_stride);
#define vpx_sad64x64 vpx_sad64x64_c

unsigned int vpx_sad64x64_avg_c(const uint8_t *src_ptr, int src_stride, const uint8_t *ref_ptr, int ref_stride, const uint8_t *second_pred);
#define vpx_sad64x64_avg vpx_sad64x64_avg_c

void vpx_sad64x64x4d_c(const uint8_t *src_ptr, int src_stride, const uint8_t *const ref_array[4], int ref_stride, uint32_t sad_array[4]);
#define vpx_sad64x64x4d vpx_sad64x64x4d_c

unsigned int vpx_sad8x16_c(const uint8_t *src_ptr, int src_stride, const uint8_t *ref_ptr, int ref_stride);
#define vpx_sad8x16 vpx_sad8x16_c

unsigned int vpx_sad8x16_avg_c(const uint8_t *src_ptr, int src_stride, const uint8_t *ref_ptr, int ref_stride, const uint8_t *second_pred);
#define vpx_sad8x16_avg vpx_sad8x16_avg_c

void vpx_sad8x16x4d_c(const uint8_t *src_ptr, int src_stride, const uint8_t *const ref_array[4], int ref_stride, uint32_t sad_array[4]);
#define vpx_sad8x16x4d vpx_sad8x16x4d_c

unsigned int vpx_sad8x4_c(const uint8_t *src_ptr, int src_stride, const uint8_t *ref_ptr, int ref_stride);
#define vpx_sad8x4 vpx_sad8x4_c

unsigned int vpx_sad8x4_avg_c(const uint8_t *src_ptr, int src_stride, const uint8_t *ref_ptr, int ref_stride, const uint8_t *second_pred);
#define vpx_sad8x4_avg vpx_sad8x4_avg_c

void vpx_sad8x4x4d_c(const uint8_t *src_ptr, int src_stride, const uint8_t *const ref_array[4], int ref_stride, uint32_t sad_array[4]);
#define vpx_sad8x4x4d vpx_sad8x4x4d_c

unsigned int vpx_sad8x8_c(const uint8_t *src_ptr, int src_stride, const uint8_t *ref_ptr, int ref_stride);
#define vpx_sad8x8 vpx_sad8x8_c

unsigned int vpx_sad8x8_avg_c(const uint8_t *src_ptr, int src_stride, const uint8_t *ref_ptr, int ref_stride, const uint8_t *second_pred);
#define vpx_sad8x8_avg vpx_sad8x8_avg_c

void vpx_sad8x8x4d_c(const uint8_t *src_ptr, int src_stride, const uint8_t *const ref_array[4], int ref_stride, uint32_t sad_array[4]);
#define vpx_sad8x8x4d vpx_sad8x8x4d_c

unsigned int vpx_sad_skip_16x16_c(const uint8_t *src_ptr, int src_stride, const uint8_t *ref_ptr, int ref_stride);
#define vpx_sad_skip_16x16 vpx_sad_skip_16x16_c

void vpx_sad_skip_16x16x4d_c(const uint8_t *src_ptr, int src_stride, const uint8_t *const ref_array[4], int ref_stride, uint32_t sad_array[4]);
#define vpx_sad_skip_16x16x4d vpx_sad_skip_16x16x4d_c

unsigned int vpx_sad_skip_16x32_c(const uint8_t *src_ptr, int src_stride, const uint8_t *ref_ptr, int ref_stride);
#define vpx_sad_skip_16x32 vpx_sad_skip_16x32_c

void vpx_sad_skip_16x32x4d_c(const uint8_t *src_ptr, int src_stride, const uint8_t *const ref_array[4], int ref_stride, uint32_t sad_array[4]);
#define vpx_sad_skip_16x32x4d vpx_sad_skip_16x32x4d_c

unsigned int vpx_sad_skip_16x8_c(const uint8_t *src_ptr, int src_stride, const uint8_t *ref_ptr, int ref_stride);
#define vpx_sad_skip_16x8 vpx_sad_skip_16x8_c

void vpx_sad_skip_16x8x4d_c(const uint8_t *src_ptr, int src_stride, const uint8_t *const ref_array[4], int ref_stride, uint32_t sad_array[4]);
#define vpx_sad_skip_16x8x4d vpx_sad_skip_16x8x4d_c

unsigned int vpx_sad_skip_32x16_c(const uint8_t *src_ptr, int src_stride, const uint8_t *ref_ptr, int ref_stride);
#define vpx_sad_skip_32x16 vpx_sad_skip_32x16_c

void vpx_sad_skip_32x16x4d_c(const uint8_t *src_ptr, int src_stride, const uint8_t *const ref_array[4], int ref_stride, uint32_t sad_array[4]);
#define vpx_sad_skip_32x16x4d vpx_sad_skip_32x16x4d_c

unsigned int vpx_sad_skip_32x32_c(const uint8_t *src_ptr, int src_stride, const uint8_t *ref_ptr, int ref_stride);
#define vpx_sad_skip_32x32 vpx_sad_skip_32x32_c

void vpx_sad_skip_32x32x4d_c(const uint8_t *src_ptr, int src_stride, const uint8_t *const ref_array[4], int ref_stride, uint32_t sad_array[4]);
#define vpx_sad_skip_32x32x4d vpx_sad_skip_32x32x4d_c

unsigned int vpx_sad_skip_32x64_c(const uint8_t *src_ptr, int src_stride, const uint8_t *ref_ptr, int ref_stride);
#define vpx_sad_skip_32x64 vpx_sad_skip_32x64_c

void vpx_sad_skip_32x64x4d_c(const uint8_t *src_ptr, int src_stride, const uint8_t *const ref_array[4], int ref_stride, uint32_t sad_array[4]);
#define vpx_sad_skip_32x64x4d vpx_sad_skip_32x64x4d_c

unsigned int vpx_sad_skip_4x4_c(const uint8_t *src_ptr, int src_stride, const uint8_t *ref_ptr, int ref_stride);
#define vpx_sad_skip_4x4 vpx_sad_skip_4x4_c

void vpx_sad_skip_4x4x4d_c(const uint8_t *src_ptr, int src_stride, const uint8_t *const ref_array[4], int ref_stride, uint32_t sad_array[4]);
#define vpx_sad_skip_4x4x4d vpx_sad_skip_4x4x4d_c

unsigned int vpx_sad_skip_4x8_c(const uint8_t *src_ptr, int src_stride, const uint8_t *ref_ptr, int ref_stride);
#define vpx_sad_skip_4x8 vpx_sad_skip_4x8_c

void vpx_sad_skip_4x8x4d_c(const uint8_t *src_ptr, int src_stride, const uint8_t *const ref_array[4], int ref_stride, uint32_t sad_array[4]);
#define vpx_sad_skip_4x8x4d vpx_sad_skip_4x8x4d_c

unsigned int vpx_sad_skip_64x32_c(const uint8_t *src_ptr, int src_stride, const uint8_t *ref_ptr, int ref_stride);
#define vpx_sad_skip_64x32 vpx_sad_skip_64x32_c

void vpx_sad_skip_64x32x4d_c(const uint8_t *src_ptr, int src_stride, const uint8_t *const ref_array[4], int ref_stride, uint32_t sad_array[4]);
#define vpx_sad_skip_64x32x4d vpx_sad_skip_64x32x4d_c

unsigned int vpx_sad_skip_64x64_c(const uint8_t *src_ptr, int src_stride, const uint8_t *ref_ptr, int ref_stride);
#define vpx_sad_skip_64x64 vpx_sad_skip_64x64_c

void vpx_sad_skip_64x64x4d_c(const uint8_t *src_ptr, int src_stride, const uint8_t *const ref_array[4], int ref_stride, uint32_t sad_array[4]);
#define vpx_sad_skip_64x64x4d vpx_sad_skip_64x64x4d_c

unsigned int vpx_sad_skip_8x16_c(const uint8_t *src_ptr, int src_stride, const uint8_t *ref_ptr, int ref_stride);
#define vpx_sad_skip_8x16 vpx_sad_skip_8x16_c

void vpx_sad_skip_8x16x4d_c(const uint8_t *src_ptr, int src_stride, const uint8_t *const ref_array[4], int ref_stride, uint32_t sad_array[4]);
#define vpx_sad_skip_8x16x4d vpx_sad_skip_8x16x4d_c

unsigned int vpx_sad_skip_8x4_c(const uint8_t *src_ptr, int src_stride, const uint8_t *ref_ptr, int ref_stride);
#define vpx_sad_skip_8x4 vpx_sad_skip_8x4_c

void vpx_sad_skip_8x4x4d_c(const uint8_t *src_ptr, int src_stride, const uint8_t *const ref_array[4], int ref_stride, uint32_t sad_array[4]);
#define vpx_sad_skip_8x4x4d vpx_sad_skip_8x4x4d_c

unsigned int vpx_sad_skip_8x8_c(const uint8_t *src_ptr, int src_stride, const uint8_t *ref_ptr, int ref_stride);
#define vpx_sad_skip_8x8 vpx_sad_skip_8x8_c

void vpx_sad_skip_8x8x4d_c(const uint8_t *src_ptr, int src_stride, const uint8_t *const ref_array[4], int ref_stride, uint32_t sad_array[4]);
#define vpx_sad_skip_8x8x4d vpx_sad_skip_8x8x4d_c

int vpx_satd_c(const int16_t *coeff, int length);
#define vpx_satd vpx_satd_c

void vpx_scaled_2d_c(const uint8_t *src, ptrdiff_t src_stride, uint8_t *dst, ptrdiff_t dst_stride, const InterpKernel *filter, int x0_q4, int x_step_q4, int y0_q4, int y_step_q4, int w, int h);
#define vpx_scaled_2d vpx_scaled_2d_c

void vpx_scaled_avg_2d_c(const uint8_t *src, ptrdiff_t src_stride, uint8_t *dst, ptrdiff_t dst_stride, const InterpKernel *filter, int x0_q4, int x_step_q4, int y0_q4, int y_step_q4, int w, int h);
#define vpx_scaled_avg_2d vpx_scaled_avg_2d_c

void vpx_scaled_avg_horiz_c(const uint8_t *src, ptrdiff_t src_stride, uint8_t *dst, ptrdiff_t dst_stride, const InterpKernel *filter, int x0_q4, int x_step_q4, int y0_q4, int y_step_q4, int w, int h);
#define vpx_scaled_avg_horiz vpx_scaled_avg_horiz_c

void vpx_scaled_avg_vert_c(const uint8_t *src, ptrdiff_t src_stride, uint8_t *dst, ptrdiff_t dst_stride, const InterpKernel *filter, int x0_q4, int x_step_q4, int y0_q4, int y_step_q4, int w, int h);
#define vpx_scaled_avg_vert vpx_scaled_avg_vert_c

void vpx_scaled_horiz_c(const uint8_t *src, ptrdiff_t src_stride, uint8_t *dst, ptrdiff_t dst_stride, const InterpKernel *filter, int x0_q4, int x_step_q4, int y0_q4, int y_step_q4, int w, int h);
#define vpx_scaled_horiz vpx_scaled_horiz_c

void vpx_scaled_vert_c(const uint8_t *src, ptrdiff_t src_stride, uint8_t *dst, ptrdiff_t dst_stride, const InterpKernel *filter, int x0_q4, int x_step_q4, int y0_q4, int y_step_q4, int w, int h);
#define vpx_scaled_vert vpx_scaled_vert_c

int64_t vpx_sse_c(const uint8_t *src, int src_stride, const uint8_t *ref, int ref_stride, int width, int height);
#define vpx_sse vpx_sse_c

uint32_t vpx_sub_pixel_avg_variance16x16_c(const uint8_t *src_ptr, int src_stride, int x_offset, int y_offset, const uint8_t *ref_ptr, int ref_stride, uint32_t *sse, const uint8_t *second_pred);
#define vpx_sub_pixel_avg_variance16x16 vpx_sub_pixel_avg_variance16x16_c

uint32_t vpx_sub_pixel_avg_variance16x32_c(const uint8_t *src_ptr, int src_stride, int x_offset, int y_offset, const uint8_t *ref_ptr, int ref_stride, uint32_t *sse, const uint8_t *second_pred);
#define vpx_sub_pixel_avg_variance16x32 vpx_sub_pixel_avg_variance16x32_c

uint32_t vpx_sub_pixel_avg_variance16x8_c(const uint8_t *src_ptr, int src_stride, int x_offset, int y_offset, const uint8_t *ref_ptr, int ref_stride, uint32_t *sse, const uint8_t *second_pred);
#define vpx_sub_pixel_avg_variance16x8 vpx_sub_pixel_avg_variance16x8_c

uint32_t vpx_sub_pixel_avg_variance32x16_c(const uint8_t *src_ptr, int src_stride, int x_offset, int y_offset, const uint8_t *ref_ptr, int ref_stride, uint32_t *sse, const uint8_t *second_pred);
#define vpx_sub_pixel_avg_variance32x16 vpx_sub_pixel_avg_variance32x16_c

uint32_t vpx_sub_pixel_avg_variance32x32_c(const uint8_t *src_ptr, int src_stride, int x_offset, int y_offset, const uint8_t *ref_ptr, int ref_stride, uint32_t *sse, const uint8_t *second_pred);
#define vpx_sub_pixel_avg_variance32x32 vpx_sub_pixel_avg_variance32x32_c

uint32_t vpx_sub_pixel_avg_variance32x64_c(const uint8_t *src_ptr, int src_stride, int x_offset, int y_offset, const uint8_t *ref_ptr, int ref_stride, uint32_t *sse, const uint8_t *second_pred);
#define vpx_sub_pixel_avg_variance32x64 vpx_sub_pixel_avg_variance32x64_c

uint32_t vpx_sub_pixel_avg_variance4x4_c(const uint8_t *src_ptr, int src_stride, int x_offset, int y_offset, const uint8_t *ref_ptr, int ref_stride, uint32_t *sse, const uint8_t *second_pred);
#define vpx_sub_pixel_avg_variance4x4 vpx_sub_pixel_avg_variance4x4_c

uint32_t vpx_sub_pixel_avg_variance4x8_c(const uint8_t *src_ptr, int src_stride, int x_offset, int y_offset, const uint8_t *ref_ptr, int ref_stride, uint32_t *sse, const uint8_t *second_pred);
#define vpx_sub_pixel_avg_variance4x8 vpx_sub_pixel_avg_variance4x8_c

uint32_t vpx_sub_pixel_avg_variance64x32_c(const uint8_t *src_ptr, int src_stride, int x_offset, int y_offset, const uint8_t *ref_ptr, int ref_stride, uint32_t *sse, const uint8_t *second_pred);
#define vpx_sub_pixel_avg_variance64x32 vpx_sub_pixel_avg_variance64x32_c

uint32_t vpx_sub_pixel_avg_variance64x64_c(const uint8_t *src_ptr, int src_stride, int x_offset, int y_offset, const uint8_t *ref_ptr, int ref_stride, uint32_t *sse, const uint8_t *second_pred);
#define vpx_sub_pixel_avg_variance64x64 vpx_sub_pixel_avg_variance64x64_c

uint32_t vpx_sub_pixel_avg_variance8x16_c(const uint8_t *src_ptr, int src_stride, int x_offset, int y_offset, const uint8_t *ref_ptr, int ref_stride, uint32_t *sse, const uint8_t *second_pred);
#define vpx_sub_pixel_avg_variance8x16 vpx_sub_pixel_avg_variance8x16_c

uint32_t vpx_sub_pixel_avg_variance8x4_c(const uint8_t *src_ptr, int src_stride, int x_offset, int y_offset, const uint8_t *ref_ptr, int ref_stride, uint32_t *sse, const uint8_t *second_pred);
#define vpx_sub_pixel_avg_variance8x4 vpx_sub_pixel_avg_variance8x4_c

uint32_t vpx_sub_pixel_avg_variance8x8_c(const uint8_t *src_ptr, int src_stride, int x_offset, int y_offset, const uint8_t *ref_ptr, int ref_stride, uint32_t *sse, const uint8_t *second_pred);
#define vpx_sub_pixel_avg_variance8x8 vpx_sub_pixel_avg_variance8x8_c

uint32_t vpx_sub_pixel_variance16x16_c(const uint8_t *src_ptr, int src_stride, int x_offset, int y_offset, const uint8_t *ref_ptr, int ref_stride, uint32_t *sse);
#define vpx_sub_pixel_variance16x16 vpx_sub_pixel_variance16x16_c

uint32_t vpx_sub_pixel_variance16x32_c(const uint8_t *src_ptr, int src_stride, int x_offset, int y_offset, const uint8_t *ref_ptr, int ref_stride, uint32_t *sse);
#define vpx_sub_pixel_variance16x32 vpx_sub_pixel_variance16x32_c

uint32_t vpx_sub_pixel_variance16x8_c(const uint8_t *src_ptr, int src_stride, int x_offset, int y_offset, const uint8_t *ref_ptr, int ref_stride, uint32_t *sse);
#define vpx_sub_pixel_variance16x8 vpx_sub_pixel_variance16x8_c

uint32_t vpx_sub_pixel_variance32x16_c(const uint8_t *src_ptr, int src_stride, int x_offset, int y_offset, const uint8_t *ref_ptr, int ref_stride, uint32_t *sse);
#define vpx_sub_pixel_variance32x16 vpx_sub_pixel_variance32x16_c

uint32_t vpx_sub_pixel_variance32x32_c(const uint8_t *src_ptr, int src_stride, int x_offset, int y_offset, const uint8_t *ref_ptr, int ref_stride, uint32_t *sse);
#define vpx_sub_pixel_variance32x32 vpx_sub_pixel_variance32x32_c

uint32_t vpx_sub_pixel_variance32x64_c(const uint8_t *src_ptr, int src_stride, int x_offset, int y_offset, const uint8_t *ref_ptr, int ref_stride, uint32_t *sse);
#define vpx_sub_pixel_variance32x64 vpx_sub_pixel_variance32x64_c

uint32_t vpx_sub_pixel_variance4x4_c(const uint8_t *src_ptr, int src_stride, int x_offset, int y_offset, const uint8_t *ref_ptr, int ref_stride, uint32_t *sse);
#define vpx_sub_pixel_variance4x4 vpx_sub_pixel_variance4x4_c

uint32_t vpx_sub_pixel_variance4x8_c(const uint8_t *src_ptr, int src_stride, int x_offset, int y_offset, const uint8_t *ref_ptr, int ref_stride, uint32_t *sse);
#define vpx_sub_pixel_variance4x8 vpx_sub_pixel_variance4x8_c

uint32_t vpx_sub_pixel_variance64x32_c(const uint8_t *src_ptr, int src_stride, int x_offset, int y_offset, const uint8_t *ref_ptr, int ref_stride, uint32_t *sse);
#define vpx_sub_pixel_variance64x32 vpx_sub_pixel_variance64x32_c

uint32_t vpx_sub_pixel_variance64x64_c(const uint8_t *src_ptr, int src_stride, int x_offset, int y_offset, const uint8_t *ref_ptr, int ref_stride, uint32_t *sse);
#define vpx_sub_pixel_variance64x64 vpx_sub_pixel_variance64x64_c

uint32_t vpx_sub_pixel_variance8x16_c(const uint8_t *src_ptr, int src_stride, int x_offset, int y_offset, const uint8_t *ref_ptr, int ref_stride, uint32_t *sse);
#define vpx_sub_pixel_variance8x16 vpx_sub_pixel_variance8x16_c

uint32_t vpx_sub_pixel_variance8x4_c(const uint8_t *src_ptr, int src_stride, int x_offset, int y_offset, const uint8_t *ref_ptr, int ref_stride, uint32_t *sse);
#define vpx_sub_pixel_variance8x4 vpx_sub_pixel_variance8x4_c

uint32_t vpx_sub_pixel_variance8x8_c(const uint8_t *src_ptr, int src_stride, int x_offset, int y_offset, const uint8_t *ref_ptr, int ref_stride, uint32_t *sse);
#define vpx_sub_pixel_variance8x8 vpx_sub_pixel_variance8x8_c

void vpx_subtract_block_c(int rows, int cols, int16_t *diff_ptr, ptrdiff_t diff_stride, const uint8_t *src_ptr, ptrdiff_t src_stride, const uint8_t *pred_ptr, ptrdiff_t pred_stride);
#define vpx_subtract_block vpx_subtract_block_c

uint64_t vpx_sum_squares_2d_i16_c(const int16_t *src, int stride, int size);
#define vpx_sum_squares_2d_i16 vpx_sum_squares_2d_i16_c

void vpx_tm_predictor_16x16_c(uint8_t *dst, ptrdiff_t stride, const uint8_t *above, const uint8_t *left);
#define vpx_tm_predictor_16x16 vpx_tm_predictor_16x16_c

void vpx_tm_predictor_32x32_c(uint8_t *dst, ptrdiff_t stride, const uint8_t *above, const uint8_t *left);
#define vpx_tm_predictor_32x32 vpx_tm_predictor_32x32_c

void vpx_tm_predictor_4x4_c(uint8_t *dst, ptrdiff_t stride, const uint8_t *above, const uint8_t *left);
#define vpx_tm_predictor_4x4 vpx_tm_predictor_4x4_c

void vpx_tm_predictor_8x8_c(uint8_t *dst, ptrdiff_t stride, const uint8_t *above, const uint8_t *left);
#define vpx_tm_predictor_8x8 vpx_tm_predictor_8x8_c

void vpx_v_predictor_16x16_c(uint8_t *dst, ptrdiff_t stride, const uint8_t *above, const uint8_t *left);
#define vpx_v_predictor_16x16 vpx_v_predictor_16x16_c

void vpx_v_predictor_32x32_c(uint8_t *dst, ptrdiff_t stride, const uint8_t *above, const uint8_t *left);
#define vpx_v_predictor_32x32 vpx_v_predictor_32x32_c

void vpx_v_predictor_4x4_c(uint8_t *dst, ptrdiff_t stride, const uint8_t *above, const uint8_t *left);
#define vpx_v_predictor_4x4 vpx_v_predictor_4x4_c

void vpx_v_predictor_8x8_c(uint8_t *dst, ptrdiff_t stride, const uint8_t *above, const uint8_t *left);
#define vpx_v_predictor_8x8 vpx_v_predictor_8x8_c

unsigned int vpx_variance16x16_c(const uint8_t *src_ptr, int src_stride, const uint8_t *ref_ptr, int ref_stride, unsigned int *sse);
#define vpx_variance16x16 vpx_variance16x16_c

unsigned int vpx_variance16x32_c(const uint8_t *src_ptr, int src_stride, const uint8_t *ref_ptr, int ref_stride, unsigned int *sse);
#define vpx_variance16x32 vpx_variance16x32_c

unsigned int vpx_variance16x8_c(const uint8_t *src_ptr, int src_stride, const uint8_t *ref_ptr, int ref_stride, unsigned int *sse);
#define vpx_variance16x8 vpx_variance16x8_c

unsigned int vpx_variance32x16_c(const uint8_t *src_ptr, int src_stride, const uint8_t *ref_ptr, int ref_stride, unsigned int *sse);
#define vpx_variance32x16 vpx_variance32x16_c

unsigned int vpx_variance32x32_c(const uint8_t *src_ptr, int src_stride, const uint8_t *ref_ptr, int ref_stride, unsigned int *sse);
#define vpx_variance32x32 vpx_variance32x32_c

unsigned int vpx_variance32x64_c(const uint8_t *src_ptr, int src_stride, const uint8_t *ref_ptr, int ref_stride, unsigned int *sse);
#define vpx_variance32x64 vpx_variance32x64_c

unsigned int vpx_variance4x4_c(const uint8_t *src_ptr, int src_stride, const uint8_t *ref_ptr, int ref_stride, unsigned int *sse);
#define vpx_variance4x4 vpx_variance4x4_c

unsigned int vpx_variance4x8_c(const uint8_t *src_ptr, int src_stride, const uint8_t *ref_ptr, int ref_stride, unsigned int *sse);
#define vpx_variance4x8 vpx_variance4x8_c

unsigned int vpx_variance64x32_c(const uint8_t *src_ptr, int src_stride, const uint8_t *ref_ptr, int ref_stride, unsigned int *sse);
#define vpx_variance64x32 vpx_variance64x32_c

unsigned int vpx_variance64x64_c(const uint8_t *src_ptr, int src_stride, const uint8_t *ref_ptr, int ref_stride, unsigned int *sse);
#define vpx_variance64x64 vpx_variance64x64_c

unsigned int vpx_variance8x16_c(const uint8_t *src_ptr, int src_stride, const uint8_t *ref_ptr, int ref_stride, unsigned int *sse);
#define vpx_variance8x16 vpx_variance8x16_c

unsigned int vpx_variance8x4_c(const uint8_t *src_ptr, int src_stride, const uint8_t *ref_ptr, int ref_stride, unsigned int *sse);
#define vpx_variance8x4 vpx_variance8x4_c

unsigned int vpx_variance8x8_c(const uint8_t *src_ptr, int src_stride, const uint8_t *ref_ptr, int ref_stride, unsigned int *sse);
#define vpx_variance8x8 vpx_variance8x8_c

void vpx_ve_predictor_4x4_c(uint8_t *dst, ptrdiff_t stride, const uint8_t *above, const uint8_t *left);
#define vpx_ve_predictor_4x4 vpx_ve_predictor_4x4_c

int vpx_vector_var_c(const int16_t *ref, const int16_t *src, const int bwl);
#define vpx_vector_var vpx_vector_var_c

void vpx_dsp_rtcd(void);

#include "vpx_config.h"

#ifdef RTCD_C
static void setup_rtcd_internal(void)
{
}
#endif

#ifdef __cplusplus
}  // extern "C"
#endif

#endif  // VPX_DSP_RTCD_H_
]==],
            ["mcpp_generated/vpx_scale_rtcd.h"] = [==[
/*
 *  Copyright (c) 2017 The WebM project authors. All Rights Reserved.
 *
 *  Use of this source code is governed by a BSD-style license
 *  that can be found in the LICENSE file in the root of the source
 *  tree. An additional intellectual property rights grant can be found
 *  in the file PATENTS.  All contributing project authors may
 *  be found in the AUTHORS file in the root of the source tree.
 */

// This file is generated. Do not edit.
#ifndef VPX_SCALE_RTCD_H_
#define VPX_SCALE_RTCD_H_

#ifdef RTCD_C
#define RTCD_EXTERN
#else
#define RTCD_EXTERN extern
#endif

struct yv12_buffer_config;

#ifdef __cplusplus
extern "C" {
#endif

void vp8_horizontal_line_2_1_scale_c(const unsigned char *source, unsigned int source_width, unsigned char *dest, unsigned int dest_width);
#define vp8_horizontal_line_2_1_scale vp8_horizontal_line_2_1_scale_c

void vp8_horizontal_line_5_3_scale_c(const unsigned char *source, unsigned int source_width, unsigned char *dest, unsigned int dest_width);
#define vp8_horizontal_line_5_3_scale vp8_horizontal_line_5_3_scale_c

void vp8_horizontal_line_5_4_scale_c(const unsigned char *source, unsigned int source_width, unsigned char *dest, unsigned int dest_width);
#define vp8_horizontal_line_5_4_scale vp8_horizontal_line_5_4_scale_c

void vp8_vertical_band_2_1_scale_c(unsigned char *source, unsigned int src_pitch, unsigned char *dest, unsigned int dest_pitch, unsigned int dest_width);
#define vp8_vertical_band_2_1_scale vp8_vertical_band_2_1_scale_c

void vp8_vertical_band_2_1_scale_i_c(unsigned char *source, unsigned int src_pitch, unsigned char *dest, unsigned int dest_pitch, unsigned int dest_width);
#define vp8_vertical_band_2_1_scale_i vp8_vertical_band_2_1_scale_i_c

void vp8_vertical_band_5_3_scale_c(unsigned char *source, unsigned int src_pitch, unsigned char *dest, unsigned int dest_pitch, unsigned int dest_width);
#define vp8_vertical_band_5_3_scale vp8_vertical_band_5_3_scale_c

void vp8_vertical_band_5_4_scale_c(unsigned char *source, unsigned int src_pitch, unsigned char *dest, unsigned int dest_pitch, unsigned int dest_width);
#define vp8_vertical_band_5_4_scale vp8_vertical_band_5_4_scale_c

void vp8_yv12_copy_frame_c(const struct yv12_buffer_config *src_ybc, struct yv12_buffer_config *dst_ybc);
#define vp8_yv12_copy_frame vp8_yv12_copy_frame_c

void vp8_yv12_extend_frame_borders_c(struct yv12_buffer_config *ybf);
#define vp8_yv12_extend_frame_borders vp8_yv12_extend_frame_borders_c

void vpx_extend_frame_borders_c(struct yv12_buffer_config *ybf);
#define vpx_extend_frame_borders vpx_extend_frame_borders_c

void vpx_extend_frame_inner_borders_c(struct yv12_buffer_config *ybf);
#define vpx_extend_frame_inner_borders vpx_extend_frame_inner_borders_c

void vpx_yv12_copy_frame_c(const struct yv12_buffer_config *src_ybc, struct yv12_buffer_config *dst_ybc);
#define vpx_yv12_copy_frame vpx_yv12_copy_frame_c

void vpx_yv12_copy_y_c(const struct yv12_buffer_config *src_ybc, struct yv12_buffer_config *dst_ybc);
#define vpx_yv12_copy_y vpx_yv12_copy_y_c

void vpx_scale_rtcd(void);

#include "vpx_config.h"

#ifdef RTCD_C
static void setup_rtcd_internal(void)
{
}
#endif

#ifdef __cplusplus
}  // extern "C"
#endif

#endif  // VPX_SCALE_RTCD_H_
]==],
        },

        linux = {
            include_dirs         = { "mcpp_generated" },
            private_include_dirs = { "mcpp_generated" },
            -- Linked into shared objects by its consumers: position independent.
            -- No contraction: a multiply-add fused or not is the same everywhere.
            cflags               = { "-fPIC", "-ffp-contract=off", "-D_GNU_SOURCE" },
            ldflags              = { "-lm", "-lpthread" },
        },
        macosx = {
            include_dirs         = { "mcpp_generated" },
            private_include_dirs = { "mcpp_generated" },
            cflags               = { "-fPIC", "-ffp-contract=off" },
        },
        -- No -fPIC: PE/COFF has no such distinction, and clang rejects it for
        -- the MSVC target.
        windows = {
            include_dirs         = { "mcpp_generated" },
            private_include_dirs = { "mcpp_generated" },
            cflags               = { "-ffp-contract=off" },
        },

        targets = { vpx = { kind = "lib" } },
        deps    = {},
    },
}
