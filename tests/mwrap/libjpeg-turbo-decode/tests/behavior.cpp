// The installed libjpeg-turbo wrapper: a picture compressed in memory, its
// header read back, decoded whole and at half size, turned a quarter without
// decoding, and the header's macros and tables under their adapted names.
import std;
import mcpplibs.mwrap.libjpeg_turbo;

namespace jpeg = mcpplibs::mwrap::libjpeg_turbo;

int main() {
    static_assert(jpeg::TJ_NUMPF == 12 && jpeg::tjPixelSize[TJPF_RGBA] == 4 && jpeg::TJPAD(5) == 8);
    constexpr int width = 80, height = 48;
    std::vector<unsigned char> pixels(static_cast<std::size_t>(width) * height * 3);
    for (int row = 0; row < height; ++row)
        for (int column = 0; column < width; ++column) {
            pixels[(static_cast<std::size_t>(row) * width + column) * 3 + 0] = static_cast<unsigned char>(column * 3);
            pixels[(static_cast<std::size_t>(row) * width + column) * 3 + 1] = static_cast<unsigned char>(row * 5);
            pixels[(static_cast<std::size_t>(row) * width + column) * 3 + 2] = 100;
        }
    tjhandle encoder = jpeg::tj3Init(TJINIT_COMPRESS);
    if (!encoder || tj3Set(encoder, TJPARAM_QUALITY, 92) != 0 || tj3Set(encoder, TJPARAM_SUBSAMP, TJSAMP_444) != 0) return 1;
    unsigned char* file = nullptr;
    std::size_t size = 0;
    if (tj3Compress8(encoder, pixels.data(), width, 0, height, TJPF_RGB, &file, &size) != 0 || size == 0 || size > tj3JPEGBufSize(width, height, TJSAMP_444)) return 2;
    tj3Destroy(encoder);

    tjhandle decoder = jpeg::tj3Init(TJINIT_DECOMPRESS);
    if (tj3DecompressHeader(decoder, file, size) != 0) return 3;
    if (tj3Get(decoder, TJPARAM_JPEGWIDTH) != width || tj3Get(decoder, TJPARAM_JPEGHEIGHT) != height || tj3Get(decoder, TJPARAM_SUBSAMP) != TJSAMP_444) return 4;
    std::vector<unsigned char> back(pixels.size());
    if (tj3Decompress8(decoder, file, size, back.data(), 0, TJPF_RGB) != 0) return 5;
    int worst = 0;
    for (std::size_t index = 0; index < pixels.size(); ++index) worst = std::max(worst, std::abs(int(pixels[index]) - int(back[index])));
    if (worst > 12) return 6;

    const tjscalingfactor half{1, 2};
    if (tj3SetScalingFactor(decoder, half) != 0 || jpeg::TJSCALED(width, half) != 40) return 7;
    std::vector<unsigned char> small(static_cast<std::size_t>(40) * 24 * jpeg::tjPixelSize[TJPF_BGRA]);
    if (tj3Decompress8(decoder, file, size, small.data(), 0, TJPF_BGRA) != 0 || small[jpeg::tjAlphaOffset[TJPF_BGRA]] != 255) return 8;

    tjhandle turner = jpeg::tj3Init(TJINIT_TRANSFORM);
    tjtransform turn{};
    turn.op = TJXOP_ROT90;
    turn.options = jpeg::TJXOPT_PERFECT;
    unsigned char* turned = nullptr;
    std::size_t turned_size = 0;
    if (tj3Transform(turner, file, size, 1, &turned, &turned_size, &turn) != 0) return 9;
    if (tj3DecompressHeader(decoder, turned, turned_size) != 0 || tj3Get(decoder, TJPARAM_JPEGWIDTH) != height || tj3Get(decoder, TJPARAM_JPEGHEIGHT) != width) return 10;

    const std::array<unsigned char, 4> nothing{1, 2, 3, 4};
    if (tj3DecompressHeader(decoder, nothing.data(), nothing.size()) != -1 || tj3GetErrorCode(decoder) != TJERR_FATAL) return 11;
    tj3Free(turned);
    tj3Free(file);
    tj3Destroy(turner);
    tj3Destroy(decoder);
    std::println("libjpeg-turbo {}: {} bytes for {} x {}, worst difference {}", jpeg::TURBOJPEG_VERSION_NUMBER, size, width, height, worst);
    return 0;
}
