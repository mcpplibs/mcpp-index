// The side header from the installed package, beside the import: the
// header's vpx_codec_control macro (its typed static control) and the
// adapted control set the same thing; a VPX_CTRL_<id> feature test; the
// mapped constants beside the macros (a function-like macro is not expanded
// when its name is followed by `)`).
#include <mwrap/libvpx/macros.hpp>

import std;
import mcpplibs.mwrap.libvpx;

namespace m = mcpplibs::mwrap::libvpx::macros;

#ifndef VPX_CTRL_VP9E_SET_ROW_MT
#error "the VPX_CTRL_<id> feature tests come with the header"
#endif

int main() {
    vpx_codec_enc_cfg_t cfg;
    if (vpx_codec_enc_config_default(vpx_codec_vp9_cx(), &cfg, 0) != VPX_CODEC_OK) return 1;
    cfg.g_w = 64;
    cfg.g_h = 64;
    vpx_codec_ctx_t a, b;
    if ((m::vpx_codec_enc_init)(&a, vpx_codec_vp9_cx(), &cfg, 0) != VPX_CODEC_OK) return 2;
    if (vpx_codec_enc_init(&b, vpx_codec_vp9_cx(), &cfg, 0) != VPX_CODEC_OK) return 3;
    if (vpx_codec_control(&a, VP8E_SET_CPUUSED, 7) != VPX_CODEC_OK) return 4;
    if (mcpplibs::mwrap::libvpx::vpx_codec_control_VP8E_SET_CPUUSED(&b, VP8E_SET_CPUUSED, 7) != VPX_CODEC_OK) return 5;
    if (&::vpx_codec_encode != &vpx_codec_encode) return 6;
    static_assert((m::VPX_VERSION_MAJOR)(0x011100) == VPX_VERSION_MAJOR(0x011100));
    vpx_codec_destroy(&a);
    vpx_codec_destroy(&b);
    return 0;
}
