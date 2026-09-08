// Behavioral test — compat.gzip-hpp compresses and decompresses through zlib.
//
// Round-trip alone would pass on a library that did nothing, so the test also
// asserts the gzip MAGIC on the compressed bytes and that a compressible
// payload actually shrinks. Both are answers only real deflate can give.
//
// It is also the link-time proof for the package's zlib dependency: every
// function called here bottoms out in `deflate`/`inflate`.
#include <gzip/compress.hpp>
#include <gzip/decompress.hpp>
#include <gzip/utils.hpp>

#include <cstdio>
#include <string>

int main() {
    std::string original;
    for (int i = 0; i < 200; ++i) original += "mcpp-index gzip round trip ";

    const std::string compressed = gzip::compress(original.data(), original.size());

    if (!gzip::is_compressed(compressed.data(), compressed.size())) {
        std::printf("gzip::is_compressed says the output is not gzip data\n");
        return 1;
    }
    // 0x1f 0x8b is the gzip magic; a wrapper that silently passed bytes
    // through would fail here rather than at the round trip.
    if (compressed.size() < 2 ||
        static_cast<unsigned char>(compressed[0]) != 0x1f ||
        static_cast<unsigned char>(compressed[1]) != 0x8b) {
        std::printf("compressed output has no gzip magic\n");
        return 2;
    }
    if (compressed.size() >= original.size()) {
        std::printf("highly repetitive input did not shrink: %zu -> %zu\n",
                    original.size(), compressed.size());
        return 3;
    }

    const std::string restored = gzip::decompress(compressed.data(), compressed.size());
    if (restored != original) {
        std::printf("round trip differs (%zu vs %zu bytes)\n", restored.size(), original.size());
        return 4;
    }

    std::printf("compat.gzip-hpp: ok (%zu -> %zu -> %zu bytes, gzip magic present)\n",
                original.size(), compressed.size(), restored.size());
    return 0;
}
