// libwebp through the published module, with the demux and mux features:
// RGBA with alpha encoded lossy at a quality and lossless and decoded back;
// the advanced API (WebPConfig, WebPPicture, a memory writer) with its pinned
// bytes; an animation encoded with WebPAnimEncoder and played back with
// WebPAnimDecoder; and the error paths.
import std;
import mcpplibs.mwrap.libwebp.demux;  // re-exports mcpplibs.mwrap.libwebp
import mcpplibs.mwrap.libwebp.mux;

using namespace mcpplibs::mwrap::libwebp;  // the headers' static inline functions, adapted

namespace {

int failures = 0;

void check(bool ok, std::string_view what) {
    std::println("{:<64} {}", what, ok ? "ok" : "FAILED");
    failures += !ok;
}

constexpr int W = 96, H = 64;

std::vector<std::uint8_t> picture(int shift) {
    std::vector<std::uint8_t> rgba(static_cast<std::size_t>(W) * H * 4);
    for (int y = 0; y < H; ++y)
        for (int x = 0; x < W; ++x) {
            auto* p = &rgba[(static_cast<std::size_t>(y) * W + x) * 4];
            p[0] = static_cast<std::uint8_t>((x + shift) * 2);
            p[1] = static_cast<std::uint8_t>(y * 4);
            p[2] = static_cast<std::uint8_t>(255 - x * 2);
            p[3] = static_cast<std::uint8_t>(y < 8 ? 64 : 255);
        }
    return rgba;
}

std::uint64_t fnv1a(std::span<const std::uint8_t> data) {
    std::uint64_t h = 0xcbf29ce484222325ull;
    for (const auto b : data) h = (h ^ b) * 0x100000001b3ull;
    return h;
}

}  // namespace

int main() {
    const auto rgba = picture(0);

    // The simple API, lossy at quality 80 and lossless.
    std::uint8_t *lossy = nullptr, *lossless = nullptr;
    const std::size_t lossy_size = WebPEncodeRGBA(rgba.data(), W, H, W * 4, 80.f, &lossy);
    const std::size_t lossless_size = WebPEncodeLosslessRGBA(rgba.data(), W, H, W * 4, &lossless);
    check(lossy_size > 0 && lossless_size > 0, "WebPEncodeRGBA / WebPEncodeLosslessRGBA");
    WebPBitstreamFeatures features;
    check(WebPGetFeatures(lossy, lossy_size, &features) == VP8_STATUS_OK && features.format == 1 && features.has_alpha,
          "WebPGetFeatures: lossy, with alpha");
    int width = 0, height = 0;
    check(WebPGetInfo(lossless, lossless_size, &width, &height) && width == W && height == H, "WebPGetInfo");
    std::uint8_t* back = WebPDecodeRGBA(lossless, lossless_size, &width, &height);
    check(back && std::equal(rgba.begin(), rgba.end(), back), "lossless round trip, every pixel");
    WebPFree(back);
    back = WebPDecodeRGBA(lossy, lossy_size, &width, &height);
    int worst = 0;
    bool alpha = back != nullptr;
    for (std::size_t i = 0; back && i < rgba.size(); ++i)
        if (i % 4 == 3) alpha = alpha && back[i] == rgba[i];
        else if (rgba[i - i % 4 + 3] == 255) worst = std::max(worst, std::abs(int(back[i]) - int(rgba[i])));
    check(back && alpha && worst < 24, std::format("lossy round trip: alpha exact, colour within {}", worst));
    WebPFree(back);
    WebPFree(lossy);
    WebPFree(lossless);

    // The advanced API: the same settings give the same bytes everywhere.
    WebPConfig config;
    WebPPicture pic;
    WebPMemoryWriter writer;
    check(WebPConfigInit(&config) && WebPPictureInit(&pic), "WebPConfigInit / WebPPictureInit");
    config.quality = 75;
    config.method = 4;
    pic.use_argb = 1;
    pic.width = W;
    pic.height = H;
    WebPMemoryWriterInit(&writer);
    pic.writer = WebPMemoryWrite;
    pic.custom_ptr = &writer;
    const bool encoded = WebPPictureImportRGBA(&pic, rgba.data(), W * 4) && WebPEncode(&config, &pic);
    const auto hash = encoded ? fnv1a({writer.mem, writer.size}) : 0;
    check(encoded && hash == 0xf128a79c2ff683a2ull, std::format("WebPEncode q75 m4: {} bytes, fnv1a 0x{:016x}", writer.size, hash));
    WebPPictureFree(&pic);
    WebPMemoryWriterClear(&writer);

    // An animation: three frames in, three full canvases out.
    WebPAnimEncoderOptions options;
    check(WebPAnimEncoderOptionsInit(&options) != 0, "WebPAnimEncoderOptionsInit");
    WebPAnimEncoder* encoder = WebPAnimEncoderNew(W, H, &options);
    config.lossless = 1;
    config.exact = 1;
    bool added = encoder && WebPPictureInit(&pic);
    pic.use_argb = 1;
    pic.width = W;
    pic.height = H;
    for (int f = 0; f < 3 && added; ++f) {
        const auto frame = picture(f * 10);
        added = WebPPictureImportRGBA(&pic, frame.data(), W * 4) && WebPAnimEncoderAdd(encoder, &pic, f * 100, &config);
    }
    WebPPictureFree(&pic);
    WebPData animation;
    WebPDataInit(&animation);
    added = added && WebPAnimEncoderAdd(encoder, nullptr, 300, nullptr) && WebPAnimEncoderAssemble(encoder, &animation);
    WebPAnimEncoderDelete(encoder);
    check(added, std::format("WebPAnimEncoder: 3 frames, {} bytes", animation.size));
    WebPAnimDecoderOptions decoding;
    check(WebPAnimDecoderOptionsInit(&decoding) != 0, "WebPAnimDecoderOptionsInit");
    decoding.color_mode = MODE_RGBA;
    WebPAnimDecoder* decoder = WebPAnimDecoderNew(&animation, &decoding);
    WebPAnimInfo info{};
    check(decoder && WebPAnimDecoderGetInfo(decoder, &info) && info.frame_count == 3, "WebPAnimDecoder: 3 frames");
    int f = 0;
    bool frames = decoder != nullptr;
    while (decoder && WebPAnimDecoderHasMoreFrames(decoder)) {
        std::uint8_t* canvas = nullptr;
        int timestamp = 0;
        const auto expected = picture(f * 10);
        frames = frames && WebPAnimDecoderGetNext(decoder, &canvas, &timestamp) && timestamp == (f + 1) * 100 &&
                 std::equal(expected.begin(), expected.end(), canvas);
        ++f;
    }
    check(frames && f == 3, "every frame exact, at its time");
    WebPAnimDecoderDelete(decoder);
    WebPDemuxer* demux = WebPDemux(&animation);
    check(demux && WebPDemuxGetI(demux, WEBP_FF_FRAME_COUNT) == 3, "WebPDemux: frame count");
    WebPDemuxDelete(demux);
    WebPDataClear(&animation);

    // Errors answer, never abort.
    const std::array<std::uint8_t, 12> garbage{'R', 'I', 'F', 'F', 4, 0, 0, 0, 'W', 'E', 'B', 'P'};
    check(WebPDecodeRGBA(garbage.data(), garbage.size(), &width, &height) == nullptr, "garbage: WebPDecodeRGBA is null");
    const WebPData bad{garbage.data(), garbage.size()};
    check(WebPAnimDecoderNew(&bad, nullptr) == nullptr, "garbage: WebPAnimDecoderNew is null");
    std::uint8_t* none = nullptr;
    check(WebPEncodeRGBA(rgba.data(), mcpplibs::mwrap::libwebp::macros::WEBP_MAX_DIMENSION + 1, 1, W * 4, 75.f, &none) == 0,
          "beyond WEBP_MAX_DIMENSION: 0 bytes");
    WebPFree(none);
    return failures;
}
