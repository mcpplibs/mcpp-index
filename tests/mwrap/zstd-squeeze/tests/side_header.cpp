// The side header from the installed package: ZSTD_COMPRESSBOUND is a constant
// expression, reading ZSTD_MAX_INPUT_SIZE from the macros module.
#include <mwrap/zstd/macros.hpp>
import std.compat;
import mcpplibs.mwrap.zstd;

int main() {
    constexpr std::size_t bound = ZSTD_COMPRESSBOUND(1 << 20);
    std::array<char, ZSTD_COMPRESSBOUND(64)> small{};
    return bound == ZSTD_compressBound(1 << 20) && small.size() == ZSTD_compressBound(64) ? 0 : 1;
}
