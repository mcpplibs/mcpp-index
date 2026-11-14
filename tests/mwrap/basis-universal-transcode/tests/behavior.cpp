// The installed Basis Universal wrapper: the transcoder made ready, what this
// build of it can write, how large a block of each format is, what is no KTX2
// file refused at each step, and the header's constants of internal linkage
// under their adapted names. (Pictures themselves are read in the wrapper's
// own CI, from upstream's test files: this consumer carries no file.)
import std;
import mcpplibs.mwrap.basis_universal;

namespace adapted = mcpplibs::mwrap::basis_universal;

int main() {
    static_assert(adapted::basist::KTX2_KHR_DF_TRANSFER_LINEAR == 1 && adapted::basist::KTX2_KHR_DF_TRANSFER_SRGB == 2);
    basist::basisu_transcoder_init();
    if (!basist::basisu_transcoder_supports_ktx2() || !basist::basisu_transcoder_supports_ktx2_zstd()) return 1;
    using format = basist::transcoder_texture_format;
    if (basist::basis_get_bytes_per_block_or_pixel(format::cTFRGBA32) != 4 || basist::basis_get_bytes_per_block_or_pixel(format::cTFBC7_RGBA) != 16 ||
        basist::basis_get_bytes_per_block_or_pixel(format::cTFETC1_RGB) != 8)
        return 2;
    if (!basist::basis_transcoder_format_is_uncompressed(format::cTFRGBA32) || basist::basis_transcoder_format_is_uncompressed(format::cTFASTC_4x4_RGBA)) return 3;
    if (std::string_view(basist::basis_get_format_name(format::cTFBC7_RGBA)) != "BC7_RGBA") return 4;
    if (!basist::basis_is_format_supported(format::cTFBC7_RGBA, basist::basis_tex_format::cETC1S) || !basist::basis_is_format_supported(format::cTFRGBA32, basist::basis_tex_format::cUASTC_LDR_4x4))
        return 5;

    // Noise, and the twelve bytes of KTX2's identifier with nothing after them: refused, and nothing read past the end.
    basist::ktx2_transcoder transcoder;
    const std::vector<std::uint8_t> noise(4096, 0x5a);
    if (transcoder.init(noise.data(), static_cast<std::uint32_t>(noise.size()))) return 6;
    const std::array<std::uint8_t, 12> identifier{0xAB, 0x4B, 0x54, 0x58, 0x20, 0x32, 0x30, 0xBB, 0x0D, 0x0A, 0x1A, 0x0A};
    if (transcoder.init(identifier.data(), static_cast<std::uint32_t>(identifier.size()))) return 7;
    if (transcoder.start_transcoding()) return 8;
    std::array<std::uint8_t, 64> out{};
    if (transcoder.transcode_image_level(0, 0, 0, out.data(), 16, format::cTFRGBA32)) return 9;
    std::println("Basis Universal transcoder: KTX2 with Zstandard; {} is {} bytes a block", basist::basis_get_format_name(format::cTFBC7_RGBA), basist::basis_get_bytes_per_block_or_pixel(format::cTFBC7_RGBA));
    return 0;
}
