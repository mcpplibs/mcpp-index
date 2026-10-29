// compat.libvpx — VP9 end to end.
//
// WHAT THIS ASSERTS AND WHY
//
// Each check exercises a different part of the source list, so a file left
// out of the descriptor shows up as a link error or a wrong answer here:
//
//   the versions           vpx_codec_version_str, the generated vpx_version.h,
//                          vpx_codec_build_config (the generated vpx_config.c)
//   one pass, good quality 24 frames of a moving gradient at constant quality,
//                          the first a key frame, decoded back by the VP9
//                          decoder with a PSNR a correct codec reaches
//   real time              the same frames at speed 8 (vp9_pickmode, the
//                          cyclic-refresh aq), decoded back
//   lossless               every pixel back exactly (the WHT, lossless mode)
//   reproducible           one thread, the same settings: the same bytes twice
//   threads                four tile columns on four threads, decoded on two
//
// A pass means the encoder and the decoder agree with one another on this
// platform's build of each.

#include <vpx/vp8cx.h>
#include <vpx/vp8dx.h>
#include <vpx/vpx_decoder.h>
#include <vpx/vpx_encoder.h>

#include <cmath>
#include <cstdint>
#include <cstdio>
#include <cstring>
#include <string>
#include <vector>

namespace {

int failures = 0;

void check(bool ok, const char *what)
{
    std::printf("%-64s %s\n", what, ok ? "ok" : "FAILED");
    if (!ok) ++failures;
}

constexpr int W = 320, H = 192, FRAMES = 24;

// A gradient that moves and a square that crosses it: motion to predict,
// edges to keep.
void draw(vpx_image_t &img, int t)
{
    for (int y = 0; y < H; ++y)
        for (int x = 0; x < W; ++x) {
            int v = (x * 2 + y + t * 5) & 255;
            if (x >= 40 + t * 8 && x < 80 + t * 8 && y >= 60 && y < 100) v = 235;
            img.planes[0][y * img.stride[0] + x] = static_cast<unsigned char>(v);
        }
    for (int y = 0; y < H / 2; ++y)
        for (int x = 0; x < W / 2; ++x) {
            img.planes[1][y * img.stride[1] + x] = static_cast<unsigned char>(128 + ((x + t) & 31) - 16);
            img.planes[2][y * img.stride[2] + x] = static_cast<unsigned char>(128 - ((y + t) & 31) + 16);
        }
}

struct Encoded {
    std::vector<std::vector<unsigned char>> packets;
    std::vector<bool> keys;
    bool ok = false;
};

Encoded encode(unsigned long deadline, int speed, bool lossless, int threads)
{
    Encoded out;
    vpx_codec_enc_cfg_t cfg;
    if (vpx_codec_enc_config_default(vpx_codec_vp9_cx(), &cfg, 0) != VPX_CODEC_OK) return out;
    cfg.g_w = W;
    cfg.g_h = H;
    cfg.g_timebase = {1, 30};
    cfg.g_threads = threads;
    cfg.g_lag_in_frames = 0;
    cfg.rc_end_usage = VPX_Q;
    cfg.kf_max_dist = 1000;
    vpx_codec_ctx_t ctx;
    if (vpx_codec_enc_init(&ctx, vpx_codec_vp9_cx(), &cfg, 0) != VPX_CODEC_OK) return out;
    vpx_codec_control(&ctx, VP8E_SET_CPUUSED, speed);
    vpx_codec_control(&ctx, VP8E_SET_CQ_LEVEL, 20);
    if (lossless) vpx_codec_control(&ctx, VP9E_SET_LOSSLESS, 1);
    if (threads > 1) vpx_codec_control(&ctx, VP9E_SET_TILE_COLUMNS, 2);
    vpx_image_t img;
    vpx_img_alloc(&img, VPX_IMG_FMT_I420, W, H, 16);
    auto drain = [&] {
        vpx_codec_iter_t it = nullptr;
        while (const vpx_codec_cx_pkt_t *p = vpx_codec_get_cx_data(&ctx, &it)) {
            if (p->kind != VPX_CODEC_CX_FRAME_PKT) continue;
            const auto *b = static_cast<const unsigned char *>(p->data.frame.buf);
            out.packets.emplace_back(b, b + p->data.frame.sz);
            out.keys.push_back((p->data.frame.flags & VPX_FRAME_IS_KEY) != 0);
        }
    };
    bool ok = true;
    for (int t = 0; t < FRAMES; ++t) {
        draw(img, t);
        ok = ok && vpx_codec_encode(&ctx, &img, t, 1, 0, deadline) == VPX_CODEC_OK;
        drain();
    }
    ok = ok && vpx_codec_encode(&ctx, nullptr, FRAMES, 1, 0, deadline) == VPX_CODEC_OK;
    drain();
    vpx_img_free(&img);
    out.ok = ok && vpx_codec_destroy(&ctx) == VPX_CODEC_OK;
    return out;
}

// Decoded back: the lowest luma PSNR over the frames, and whether every pixel matched.
struct Decoded {
    int frames = 0;
    double worst_psnr = 1e9;
    bool exact = true;
};

Decoded decode(const Encoded &e, int threads)
{
    Decoded d;
    vpx_codec_ctx_t ctx;
    vpx_codec_dec_cfg_t cfg{};
    cfg.threads = threads;
    if (vpx_codec_dec_init(&ctx, vpx_codec_vp9_dx(), &cfg, 0) != VPX_CODEC_OK) return d;
    vpx_image_t ref;
    vpx_img_alloc(&ref, VPX_IMG_FMT_I420, W, H, 16);
    for (const auto &p : e.packets) {
        if (vpx_codec_decode(&ctx, p.data(), static_cast<unsigned int>(p.size()), nullptr, 0) != VPX_CODEC_OK) return d;
        vpx_codec_iter_t it = nullptr;
        while (vpx_image_t *img = vpx_codec_get_frame(&ctx, &it)) {
            draw(ref, d.frames);
            double se = 0;
            for (int plane = 0; plane < 3; ++plane) {
                const int pw = plane ? W / 2 : W, ph = plane ? H / 2 : H;
                for (int y = 0; y < ph; ++y)
                    for (int x = 0; x < pw; ++x) {
                        const int a = img->planes[plane][y * img->stride[plane] + x];
                        const int b = ref.planes[plane][y * ref.stride[plane] + x];
                        if (a != b) d.exact = false;
                        if (plane == 0) se += double(a - b) * (a - b);
                    }
            }
            const double mse = se / (W * H);
            const double psnr = mse == 0 ? 99 : 10 * std::log10(255.0 * 255.0 / mse);
            if (psnr < d.worst_psnr) d.worst_psnr = psnr;
            ++d.frames;
        }
    }
    vpx_img_free(&ref);
    vpx_codec_destroy(&ctx);
    return d;
}

}  // namespace

int main()
{
    std::printf("%s / %s\n", vpx_codec_version_str(), vpx_codec_build_config());
    check(std::string(vpx_codec_version_str()) == "v1.17.0", "vpx_codec_version_str is v1.17.0 (the generated vpx_version.h)");
    check(std::string(vpx_codec_build_config()).find("--target=generic-gnu") != std::string::npos, "vpx_codec_build_config (the generated vpx_config.c)");
    check(std::string(vpx_codec_iface_name(vpx_codec_vp9_cx())).find("VP9 Encoder") != std::string::npos, "the VP9 encoder interface");

    const Encoded good = encode(VPX_DL_GOOD_QUALITY, 4, false, 1);
    check(good.ok && good.packets.size() == FRAMES && good.keys.front() && !good.keys.back(), "good quality: a packet a frame, the first a key frame");
    const Decoded gd = decode(good, 1);
    std::printf("  good: %zu packets, worst PSNR %.2f dB\n", good.packets.size(), gd.worst_psnr);
    check(gd.frames == FRAMES && gd.worst_psnr > 38, "good quality decoded back above 38 dB");

    const Encoded rt = encode(VPX_DL_REALTIME, 8, false, 1);
    const Decoded rd = decode(rt, 1);
    std::printf("  real time: worst PSNR %.2f dB\n", rd.worst_psnr);
    check(rt.ok && rd.frames == FRAMES && rd.worst_psnr > 30, "real time (speed 8) decoded back above 30 dB");

    const Encoded ll = encode(VPX_DL_GOOD_QUALITY, 4, true, 1);
    const Decoded ld = decode(ll, 1);
    check(ll.ok && ld.frames == FRAMES && ld.exact, "lossless: every pixel back exactly");

    const Encoded again = encode(VPX_DL_GOOD_QUALITY, 4, false, 1);
    check(again.packets == good.packets, "one thread: the same bytes twice");

    const Encoded mt = encode(VPX_DL_GOOD_QUALITY, 5, false, 4);
    const Decoded md = decode(mt, 2);
    check(mt.ok && md.frames == FRAMES && md.worst_psnr > 36, "four threads and tile columns, decoded on two");

    std::printf("%s\n", failures ? "FAILED" : "all passed");
    return failures ? 1 : 0;
}
