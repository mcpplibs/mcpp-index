// The installed Zstandard wrapper: a one-shot round trip, a stream, and a
// damaged checksum refused with its error code.
import std;
import mcpplibs.mwrap.zstd;

namespace z = mcpplibs::mwrap::zstd::macros;

int main() {
    std::string text;
    for (int i = 0; i < 500; ++i) text += std::format("entry {} of a log\n", i % 13);
    std::string frame(ZSTD_compressBound(text.size()), '\0');
    const auto size = ZSTD_compress(frame.data(), frame.size(), text.data(), text.size(), z::ZSTD_CLEVEL_DEFAULT);
    if (ZSTD_isError(size)) return 1;
    frame.resize(size);
    if (ZSTD_getFrameContentSize(frame.data(), frame.size()) != text.size()) return 2;
    std::string back(text.size(), '\0');
    if (ZSTD_decompress(back.data(), back.size(), frame.data(), frame.size()) != text.size() || back != text) return 3;

    ZSTD_CCtx* c = ZSTD_createCCtx();
    ZSTD_CCtx_setParameter(c, ZSTD_c_checksumFlag, 1);
    std::string streamed(ZSTD_compressBound(text.size()), '\0');
    ZSTD_inBuffer in{text.data(), text.size(), 0};
    ZSTD_outBuffer out{streamed.data(), streamed.size(), 0};
    if (ZSTD_compressStream2(c, &out, &in, ZSTD_e_end) != 0) return 4;
    ZSTD_freeCCtx(c);
    streamed.resize(out.pos);
    streamed.back() ^= 1;
    const auto damaged = ZSTD_decompress(back.data(), back.size(), streamed.data(), streamed.size());
    if (!ZSTD_isError(damaged) || ZSTD_getErrorCode(damaged) != ZSTD_error_checksum_wrong) return 5;
    std::println("zstd {}: {} -> {} bytes", ZSTD_versionString(), text.size(), size);
    return 0;
}
