// Round-trip compress→decompress per codec, asserting byte-for-byte recovery.
#include <bzlib.h>
#include <lz4.h>
#include <lzma.h>
#include <zlib.h>
#include <zstd.h>
#include <cstdint>
#include <cstring>
#include <limits>
#include <vector>

static bool same_bytes(const void* a, size_t an, const void* b, size_t bn) {
    return an == bn && std::memcmp(a, b, bn) == 0;
}

int main() {
    const uint8_t input[] = "mcpp compat compression smoke";
    const size_t input_size = sizeof(input) - 1;

    uint8_t zc[256] = {}; uLongf zcs = sizeof(zc);
    if (compress2(zc, &zcs, input, (uLong)input_size, Z_BEST_SPEED) != Z_OK) return 1;
    uint8_t zo[sizeof(input)] = {}; uLongf zos = input_size;
    if (uncompress(zo, &zos, zc, zcs) != Z_OK || !same_bytes(zo, zos, input, input_size)) return 2;

    char bc[256] = {}; unsigned int bcs = sizeof(bc);
    if (BZ2_bzBuffToBuffCompress(bc, &bcs, const_cast<char*>(reinterpret_cast<const char*>(input)),
                                 (unsigned)input_size, 1, 0, 30) != BZ_OK) return 3;
    char bo[sizeof(input)] = {}; unsigned int bos = input_size;
    if (BZ2_bzBuffToBuffDecompress(bo, &bos, bc, bcs, 0, 0) != BZ_OK ||
        !same_bytes(bo, bos, input, input_size)) return 4;

    char lc[256] = {};
    const int lcs = LZ4_compress_default(reinterpret_cast<const char*>(input), lc, (int)input_size, sizeof(lc));
    if (lcs <= 0) return 5;
    char lo[sizeof(input)] = {};
    const int los = LZ4_decompress_safe(lc, lo, lcs, sizeof(lo));
    if (los < 0 || !same_bytes(lo, (size_t)los, input, input_size)) return 6;

    std::vector<char> sc(ZSTD_compressBound(input_size));
    const size_t scs = ZSTD_compress(sc.data(), sc.size(), input, input_size, 1);
    if (ZSTD_isError(scs)) return 7;
    std::vector<char> so(input_size);
    const size_t sos = ZSTD_decompress(so.data(), so.size(), sc.data(), scs);
    if (ZSTD_isError(sos) || !same_bytes(so.data(), sos, input, input_size)) return 8;

    std::vector<uint8_t> xc(lzma_stream_buffer_bound(input_size)); size_t xcp = 0;
    if (lzma_easy_buffer_encode(0, LZMA_CHECK_CRC64, nullptr, input, input_size,
                                xc.data(), &xcp, xc.size()) != LZMA_OK) return 9;
    uint64_t xm = (std::numeric_limits<uint64_t>::max)(); size_t xip = 0, xop = 0;
    std::vector<uint8_t> xo(input_size);
    if (lzma_stream_buffer_decode(&xm, 0, nullptr, xc.data(), &xip, xcp, xo.data(), &xop, xo.size()) != LZMA_OK ||
        !same_bytes(xo.data(), xop, input, input_size)) return 10;
    return 0;
}
