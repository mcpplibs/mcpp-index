// The installed liblzma wrapper: buffers one call each way, a BCJ and LZMA2
// filter chain read back by the automatic decoder, and the published CRC-64.
import std;
import mcpplibs.mwrap.xz;

namespace x = mcpplibs::mwrap::xz::macros;

int main() {
    std::string text;
    for (int i = 0; i < 800; ++i) text += std::format("record {} of a journal\n", i % 17);
    const auto* bytes = reinterpret_cast<const std::uint8_t*>(text.data());
    std::vector<std::uint8_t> xz(lzma_stream_buffer_bound(text.size()));
    std::size_t size = 0;
    if (lzma_easy_buffer_encode(x::LZMA_PRESET_DEFAULT, LZMA_CHECK_CRC64, nullptr, bytes, text.size(),
                                xz.data(), &size, xz.size()) != LZMA_OK) return 1;
    std::string back(text.size(), '\0');
    std::uint64_t limit = std::numeric_limits<std::uint64_t>::max();
    std::size_t in_pos = 0, out_pos = 0;
    if (lzma_stream_buffer_decode(&limit, 0, nullptr, xz.data(), &in_pos, size,
                                  reinterpret_cast<std::uint8_t*>(back.data()), &out_pos, back.size()) != LZMA_OK
        || back != text) return 2;

    lzma_options_lzma lzma2{};
    lzma_lzma_preset(&lzma2, 1);
    lzma_filter chain[] = {{x::LZMA_FILTER_X86, nullptr}, {x::LZMA_FILTER_LZMA2, &lzma2}, {x::LZMA_VLI_UNKNOWN, nullptr}};
    std::vector<std::uint8_t> filtered(lzma_stream_buffer_bound(text.size()));
    std::size_t filtered_size = 0;
    if (lzma_stream_buffer_encode(chain, LZMA_CHECK_CRC32, nullptr, bytes, text.size(), filtered.data(),
                                  &filtered_size, filtered.size()) != LZMA_OK) return 3;
    limit = std::numeric_limits<std::uint64_t>::max();
    in_pos = out_pos = 0;
    std::string unfiltered(text.size(), '\0');
    if (lzma_stream_buffer_decode(&limit, 0, nullptr, filtered.data(), &in_pos, filtered_size,
                                  reinterpret_cast<std::uint8_t*>(unfiltered.data()), &out_pos, unfiltered.size()) != LZMA_OK
        || unfiltered != text) return 4;
    if (lzma_crc64(reinterpret_cast<const std::uint8_t*>("123456789"), 9, 0) != 0x995DC9BBDF1939FAull) return 5;
    std::println("liblzma {}: {} -> {} bytes", lzma_version_string(), text.size(), size);
    return 0;
}
