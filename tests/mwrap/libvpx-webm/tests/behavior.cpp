// The wrapper through its modules alone: VP9 frames encoded through the typed
// controls, muxed into a WebM in memory with mkvmuxer (track UID given),
// parsed back with mkvparser and decoded within a PSNR; the same bytes twice.
import std;
import mcpplibs.mwrap.libvpx;

namespace m = mcpplibs::mwrap::libvpx::macros;
namespace vpx = mcpplibs::mwrap::libvpx;

namespace {

constexpr int W = 160, H = 96, FRAMES = 20;

void draw(vpx_image_t& img, int t) {
    for (int y = 0; y < H; ++y)
        for (int x = 0; x < W; ++x)
            img.planes[0][y * img.stride[0] + x] = static_cast<unsigned char>(x >= 20 + 4 * t && x < 50 + 4 * t && y >= 30 && y < 60 ? 230 : 16 + (x + y + 3 * t) % 200);
    for (int p = 1; p < 3; ++p)
        for (int y = 0; y < H / 2; ++y)
            for (int x = 0; x < W / 2; ++x) img.planes[p][y * img.stride[p] + x] = static_cast<unsigned char>(p == 1 ? 100 + x : 150 - y);
}

class Memory final : public mkvmuxer::IMkvWriter {
public:
    std::vector<unsigned char> bytes;
    std::int64_t at = 0;
    mkvmuxer::int32 Write(const void* buf, mkvmuxer::uint32 len) override {
        if (bytes.size() < static_cast<std::size_t>(at) + len) bytes.resize(static_cast<std::size_t>(at) + len);
        std::memcpy(bytes.data() + at, buf, len);
        at += len;
        return 0;
    }
    mkvmuxer::int64 Position() const override { return at; }
    mkvmuxer::int32 Position(mkvmuxer::int64 p) override { return at = p, 0; }
    bool Seekable() const override { return true; }
    void ElementStartNotify(mkvmuxer::uint64, mkvmuxer::int64) override {}
};

class Reader final : public mkvparser::IMkvReader {
public:
    explicit Reader(const std::vector<unsigned char>& b) : bytes(b) {}
    int Read(long long pos, long len, unsigned char* buf) override {
        if (pos < 0 || len < 0 || static_cast<std::size_t>(pos + len) > bytes.size()) return -1;
        std::memcpy(buf, bytes.data() + pos, static_cast<std::size_t>(len));
        return 0;
    }
    int Length(long long* total, long long* available) override {
        *total = *available = static_cast<long long>(bytes.size());
        return 0;
    }
    const std::vector<unsigned char>& bytes;
};

std::vector<unsigned char> webm() {
    vpx_codec_enc_cfg_t cfg;
    vpx_codec_enc_config_default(vpx_codec_vp9_cx(), &cfg, 0);
    cfg.g_w = W;
    cfg.g_h = H;
    cfg.g_timebase = {1, 30};
    cfg.g_lag_in_frames = 0;
    cfg.rc_end_usage = VPX_Q;
    vpx_codec_ctx_t enc;
    if (m::vpx_codec_enc_init(&enc, vpx_codec_vp9_cx(), &cfg, 0) != VPX_CODEC_OK) return {};
    vpx::vpx_codec_control_VP8E_SET_CPUUSED(&enc, VP8E_SET_CPUUSED, 6);
    vpx::vpx_codec_control_VP8E_SET_CQ_LEVEL(&enc, VP8E_SET_CQ_LEVEL, 20u);
    Memory out;
    mkvmuxer::Segment segment;
    segment.Init(&out);
    segment.set_mode(mkvmuxer::Segment::kFile);
    const auto track = segment.AddVideoTrack(W, H, 1);
    auto* v = static_cast<mkvmuxer::VideoTrack*>(segment.GetTrackByNumber(track));
    v->set_codec_id(mkvmuxer::Tracks::kVp9CodecId);
    v->set_uid(7);
    vpx_image_t img;
    vpx_img_alloc(&img, VPX_IMG_FMT_I420, W, H, 16);
    for (int t = 0; t <= FRAMES; ++t) {
        if (t < FRAMES) draw(img, t);
        vpx_codec_encode(&enc, t < FRAMES ? &img : nullptr, t, 1, 0, m::VPX_DL_GOOD_QUALITY);
        vpx_codec_iter_t it = nullptr;
        while (const vpx_codec_cx_pkt_t* p = vpx_codec_get_cx_data(&enc, &it))
            if (p->kind == VPX_CODEC_CX_FRAME_PKT)
                segment.AddFrame(static_cast<const std::uint8_t*>(p->data.frame.buf), p->data.frame.sz, track,
                                 static_cast<std::uint64_t>(p->data.frame.pts) * 1'000'000'000 / 30, (p->data.frame.flags & m::VPX_FRAME_IS_KEY) != 0);
    }
    vpx_img_free(&img);
    vpx_codec_destroy(&enc);
    segment.Finalize();
    return out.bytes;
}

}  // namespace

int main() {
    const auto file = webm();
    if (file.empty() || file != webm()) return 1;
    Reader reader(file);
    long long pos = 0;
    mkvparser::EBMLHeader header;
    mkvparser::Segment* raw = nullptr;
    if (header.Parse(&reader, pos) != 0 || std::string_view(header.m_docType) != "webm") return 2;
    if (mkvparser::Segment::CreateInstance(&reader, pos, raw) != 0 || !raw || raw->Load() < 0) return 3;
    std::unique_ptr<mkvparser::Segment> segment(raw);
    vpx_codec_dec_cfg_t dcfg{};
    vpx_codec_ctx_t dec;
    if (m::vpx_codec_dec_init(&dec, vpx_codec_vp9_dx(), &dcfg, 0) != VPX_CODEC_OK) return 4;
    vpx_image_t ref;
    vpx_img_alloc(&ref, VPX_IMG_FMT_I420, W, H, 16);
    int frames = 0;
    double worst = 99;
    for (const mkvparser::Cluster* c = segment->GetFirst(); c && !c->EOS(); c = segment->GetNext(c)) {
        const mkvparser::BlockEntry* e = nullptr;
        for (c->GetFirst(e); e && !e->EOS(); c->GetNext(e, e)) {
            const mkvparser::Block::Frame& f = e->GetBlock()->GetFrame(0);
            std::vector<unsigned char> data(static_cast<std::size_t>(f.len));
            f.Read(&reader, data.data());
            vpx_codec_decode(&dec, data.data(), static_cast<unsigned>(data.size()), nullptr, 0);
            vpx_codec_iter_t it = nullptr;
            while (vpx_image_t* out = vpx_codec_get_frame(&dec, &it)) {
                draw(ref, frames++);
                double se = 0;
                for (int y = 0; y < H; ++y)
                    for (int x = 0; x < W; ++x) {
                        const int d = out->planes[0][y * out->stride[0] + x] - ref.planes[0][y * ref.stride[0] + x];
                        se += d * d;
                    }
                if (se > 0) worst = std::min(worst, 10 * std::log10(255.0 * 255.0 * W * H / se));
            }
        }
    }
    vpx_img_free(&ref);
    vpx_codec_destroy(&dec);
    std::println("{} frames in {} bytes of WebM, worst PSNR {:.1f} dB ({})", frames, file.size(), worst, vpx_codec_version_str());
    return frames == FRAMES && worst > 35 ? 0 : 5;
}
