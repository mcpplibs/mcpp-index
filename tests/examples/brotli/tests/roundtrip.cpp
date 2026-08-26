#include <brotli/decode.h>
#include <brotli/encode.h>

#include <cstddef>
#include <cstring>
#include <vector>

int main() {
    static constexpr unsigned char original[] =
        "Brotli round-trip payload. Brotli round-trip payload. "
        "Brotli round-trip payload. Brotli round-trip payload.";
    constexpr std::size_t original_size = sizeof(original) - 1;

    const std::size_t encoded_capacity = BrotliEncoderMaxCompressedSize(original_size);
    if (original_size == 0 || encoded_capacity == 0) return 1;

    std::vector<unsigned char> encoded(encoded_capacity);
    std::size_t encoded_size = encoded.size();
    const BROTLI_BOOL encoded_ok = BrotliEncoderCompress(
        BROTLI_DEFAULT_QUALITY,
        BROTLI_DEFAULT_WINDOW,
        BROTLI_MODE_GENERIC,
        original_size,
        original,
        &encoded_size,
        encoded.data());
    if (encoded_ok != BROTLI_TRUE || encoded_size == 0) return 2;

    std::vector<unsigned char> decoded(original_size);
    std::size_t decoded_size = decoded.size();
    const BrotliDecoderResult decoded_result = BrotliDecoderDecompress(
        encoded_size,
        encoded.data(),
        &decoded_size,
        decoded.data());
    if (decoded_result != BROTLI_DECODER_RESULT_SUCCESS) return 3;
    if (decoded_size != original_size) return 4;

    for (std::size_t i = 0; i < original_size; ++i) {
        if (decoded[i] != original[i]) return 5;
    }
    return std::memcmp(decoded.data(), original, original_size) == 0 ? 0 : 6;
}
