// The side header from the installed package: LZMA_STREAM_INIT, an initializer
// macro, and lzma_vli_is_valid, which reads LZMA_VLI_MAX from the macros module.
#include <mwrap/xz/macros.hpp>
import std;
import mcpplibs.mwrap.xz;

namespace x = mcpplibs::mwrap::xz::macros;

int main() {
    lzma_stream s = LZMA_STREAM_INIT;
    if (lzma_alone_decoder(&s, std::numeric_limits<std::uint64_t>::max()) != LZMA_OK) return 1;
    lzma_end(&s);
    return lzma_vli_is_valid(x::LZMA_VLI_MAX) && !lzma_vli_is_valid(x::LZMA_VLI_MAX + 1) ? 0 : 2;
}
