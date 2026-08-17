// Behavioral test: encode a synthetic image and decode it back.
//
// Linking is not the interesting question for this package — the source list is
// five directory globs including every SIMD variant, and a variant that failed
// to self-gate would still LINK while producing wrong pixels. So the assertions
// are on the pixels: lossless must round-trip exactly, lossy must stay close,
// and the encoder must actually respond to its quality knob.
#include <webp/decode.h>
#include <webp/encode.h>

#include <cassert>
#include <cstdint>
#include <cstdlib>
#include <vector>

namespace {

constexpr int kW = 64;
constexpr int kH = 48;

// A gradient with a hard edge: smooth enough for the lossy path to do well,
// structured enough that a broken transform shows up as a large delta.
std::vector<uint8_t> make_rgba() {
    std::vector<uint8_t> px(static_cast<std::size_t>(kW) * kH * 4);
    for (int y = 0; y < kH; ++y) {
        for (int x = 0; x < kW; ++x) {
            uint8_t* p = &px[(static_cast<std::size_t>(y) * kW + x) * 4];
            p[0] = static_cast<uint8_t>(x * 4);
            p[1] = static_cast<uint8_t>(y * 5);
            p[2] = static_cast<uint8_t>(x < kW / 2 ? 30 : 220);
            p[3] = 255;
        }
    }
    return px;
}

}  // namespace

int main() {
    const std::vector<uint8_t> src = make_rgba();
    const int stride = kW * 4;

    // --- the header round-trips the dimensions ---
    uint8_t* lossless = nullptr;
    const std::size_t lossless_size =
        WebPEncodeLosslessRGBA(src.data(), kW, kH, stride, &lossless);
    assert(lossless_size > 0 && lossless != nullptr);

    int w = 0, h = 0;
    assert(WebPGetInfo(lossless, lossless_size, &w, &h) == 1);
    assert(w == kW && h == kH);

    // --- lossless must be EXACT ---
    uint8_t* decoded = WebPDecodeRGBA(lossless, lossless_size, &w, &h);
    assert(decoded != nullptr && w == kW && h == kH);
    for (std::size_t i = 0; i < src.size(); ++i) assert(decoded[i] == src[i]);
    WebPFree(decoded);

    // --- lossy must be close, and quality must have an effect ---
    uint8_t* q90 = nullptr;
    const std::size_t q90_size = WebPEncodeRGBA(src.data(), kW, kH, stride, 90.0f, &q90);
    assert(q90_size > 0 && q90 != nullptr);

    uint8_t* q10 = nullptr;
    const std::size_t q10_size = WebPEncodeRGBA(src.data(), kW, kH, stride, 10.0f, &q10);
    assert(q10_size > 0 && q10 != nullptr);
    assert(q10_size < q90_size);   // a lower quality must produce a smaller file

    decoded = WebPDecodeRGBA(q90, q90_size, &w, &h);
    assert(decoded != nullptr && w == kW && h == kH);
    long total = 0;
    for (std::size_t i = 0; i < src.size(); ++i)
        total += std::abs(static_cast<int>(decoded[i]) - static_cast<int>(src[i]));
    const double mean_abs_error = static_cast<double>(total) / static_cast<double>(src.size());
    assert(mean_abs_error < 8.0);  // quality 90 on a smooth image
    WebPFree(decoded);

    WebPFree(lossless);
    WebPFree(q90);
    WebPFree(q10);
    return 0;
}
