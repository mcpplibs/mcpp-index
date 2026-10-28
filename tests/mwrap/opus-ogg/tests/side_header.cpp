// The side header from the installed package, beside the import: the raw
// headers' macros (CTL comma lists, constants, attributes) with the module's
// entities and mappings.
#include <mwrap/opus/macros.hpp>

import std;
import mcpplibs.mwrap.opus;

extern "C" OPUS_EXPORT OPUS_WARN_UNUSED_RESULT int mwrap_opus_consumer(int value);
extern "C" int mwrap_opus_consumer(int value) { return value * 2; }

int main() {
    namespace m = mcpplibs::mwrap::opus::macros;
    int err = 0;
    OpusDecoder* dec = opus_decoder_create(48000, 2, &err);
    if (err != OPUS_OK) return 1;
    // The header's comma list and the mapped request reach the same decoder.
    if (opus_decoder_ctl(dec, OPUS_SET_GAIN(512)) != OPUS_OK) return 2;
    opus_int32 gain = 0;
    if (opus_decoder_ctl(dec, (m::OPUS_GET_GAIN)(&gain)) != OPUS_OK || gain != 512) return 3;
    opus_decoder_destroy(dec);
    if (&::op_open_memory != &op_open_memory) return 4;
    // opus_int64 is a macro or a <stdint.h> typedef, depending on the compiler:
    // set the macro aside to name the module's alias.
    using raw_int64 = opus_int64;
#pragma push_macro("opus_int64")
#undef opus_int64
    static_assert(std::is_same_v<m::opus_int64, raw_int64>);
#pragma pop_macro("opus_int64")
    return mwrap_opus_consumer(21) == 42 ? 0 : 5;
}
