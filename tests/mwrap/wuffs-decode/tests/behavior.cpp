// mcpplibs.mwrap.wuffs, installed: Wuffs through the module alone.
import std;
import mcpplibs.mwrap.wuffs;

using namespace mcpplibs::mwrap::wuffs;          // the adapted static inline API
using namespace mcpplibs::mwrap::wuffs::macros;  // WUFFS_VERSION, WUFFS_BASE__FOURCC__PNG …

namespace {
// 2x2 RGB PNG: red, green / blue, white.
constexpr std::uint8_t png[] = {
    0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a, 0x00, 0x00, 0x00, 0x0d, 0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x02,
    0x00, 0x00, 0x00, 0x02, 0x08, 0x02, 0x00, 0x00, 0x00, 0xfd, 0xd4, 0x9a, 0x73, 0x00, 0x00, 0x00, 0x12, 0x49, 0x44, 0x41,
    0x54, 0x78, 0xda, 0x63, 0xf8, 0xcf, 0xc0, 0xc0, 0x00, 0xc2, 0x0c, 0xff, 0x81, 0x00, 0x00, 0x1f, 0xee, 0x05, 0xfb, 0xf1,
    0xab, 0xba, 0x77, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4e, 0x44, 0xae, 0x42, 0x60, 0x82};
// 1x1 GIF, a red pixel.
constexpr std::uint8_t gif[] = {0x47, 0x49, 0x46, 0x38, 0x39, 0x61, 0x01, 0x00, 0x01, 0x00, 0x80, 0x00, 0x00, 0xff, 0x00, 0x00,
                                0x00, 0x00, 0x00, 0x2c, 0x00, 0x00, 0x00, 0x00, 0x01, 0x00, 0x01, 0x00, 0x00, 0x02, 0x02, 0x44,
                                0x01, 0x00, 0x3b};

int failures = 0;
void check(bool ok, std::string_view what) {
    std::println("{} {}", ok ? "ok  " : "FAIL", what);
    failures += !ok;
}

std::vector<std::uint32_t> pixels(const std::uint8_t* p, std::size_t n, std::string& error) {
    wuffs_aux::DecodeImageCallbacks callbacks;
    wuffs_aux::sync_io::MemoryInput input(p, n);
    wuffs_aux::DecodeImageResult res = wuffs_aux::DecodeImage(callbacks, input);
    error = res.error_message;
    std::vector<std::uint32_t> out;
    if (!error.empty()) return out;
    wuffs_base__table_u8 plane = res.pixbuf.plane(0);
    for (std::uint32_t y = 0; y < res.pixbuf.pixcfg.height(); ++y)
        for (std::uint32_t x = 0; x < res.pixbuf.pixcfg.width(); ++x)
            out.push_back(wuffs_base__peek_u32le__no_bounds_check(plane.ptr + y * plane.stride + x * 4));
    return out;
}
}  // namespace

int main() {
    std::string error;
    // BGRA little-endian u32 = 0xAARRGGBB.
    check(pixels(png, sizeof png, error) == std::vector<std::uint32_t>{0xFFFF0000, 0xFF00FF00, 0xFF0000FF, 0xFFFFFFFF},
          "PNG decoded pixel by pixel");
    check(pixels(gif, sizeof gif, error) == std::vector<std::uint32_t>{0xFFFF0000}, "GIF decoded");
    pixels(png, 40, error);
    check(error == "png: truncated input", "a truncated PNG is refused: " + error);
    check(wuffs_base__magic_number_guess_fourcc(wuffs_base__make_slice_u8(const_cast<std::uint8_t*>(png), sizeof png), true) ==
              WUFFS_BASE__FOURCC__PNG,
          "magic number");

    const std::string doc = R"({"a":[1,2,3]})";
    struct Count : wuffs_aux::DecodeJsonCallbacks {
        std::int64_t sum = 0;
        std::string AppendNull() override { return ""; }
        std::string AppendBool(bool) override { return ""; }
        std::string AppendF64(double) override { return ""; }
        std::string AppendI64(std::int64_t v) override { sum += v; return ""; }
        std::string AppendTextString(std::string&&) override { return ""; }
        std::string Push(std::uint32_t) override { return ""; }
        std::string Pop(std::uint32_t) override { return ""; }
    } count;
    wuffs_aux::sync_io::MemoryInput input(doc.data(), doc.size());
    check(wuffs_aux::DecodeJson(count, input).error_message.empty() && count.sum == 6, "JSON walked");
    check(WUFFS_VERSION_MINOR == 3 && std::string_view(WUFFS_VERSION_STRING).starts_with("0.3.6"), "the release");
    return failures ? 1 : 0;
}
