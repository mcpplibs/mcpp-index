// The side header from the installed package, beside the import: the raw
// header's enumerators and macros with the module's entities.
#include <mwrap/sheenbidi/macros.hpp>

import std;
import mcpplibs.mwrap.sheenbidi;

SB_EXTERN_C_BEGIN
SB_PUBLIC int mwrap_sheenbidi_consumer(int value);
SB_EXTERN_C_END
int mwrap_sheenbidi_consumer(int value) { return value * 2; }

int main() {
    namespace m = mcpplibs::mwrap::sheenbidi::macros;
    static_assert(m::SBBidiTypeR == ::SBBidiTypeR && std::is_same_v<decltype(m::SBBidiTypeR), const SBBidiType>);
    if (::SBCodepointGetBidiType(0x05D0) != SBBidiTypeR) return 1;
    if (SBBidiTypeIsStrong(SBBidiTypeR) != (m::SBBidiTypeIsStrong)(SBBidiTypeR)) return 2;
    if (&::SBAlgorithmCreate != &SBAlgorithmCreate) return 3;
    return mwrap_sheenbidi_consumer(21) == 42 ? 0 : 4;
}
