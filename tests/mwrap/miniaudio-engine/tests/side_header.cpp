// The side header from the installed package, beside the import: the raw
// header's macros with the module's entities.
#include <mwrap/miniaudio/macros.hpp>

import std;
import mcpplibs.mwrap.miniaudio;

extern "C" {
MA_API int mwrap_miniaudio_consumer(int value);
}
int mwrap_miniaudio_consumer(int value) { return value * 2; }

int main() {
    static_assert(std::is_same_v<decltype(::MA_SUCCESS), ma_result>);
#if !defined(MA_HAS_NULL) || !defined(MA_SUPPORT_CUSTOM)
    return 1;
#endif
    if (&::ma_engine_init != &ma_engine_init) return 2;
    if (ma_is_backend_enabled(ma_backend_null) != MA_TRUE) return 3;
    if (std::string_view(MA_XSTRINGIFY(MA_VERSION_REVISION)) != "25") return 4;
    if (::ma_get_bytes_per_frame(ma_format_f32, 2) != mcpplibs::mwrap::miniaudio::ma_get_bytes_per_frame(ma_format_f32, 2)) return 5;
    return mwrap_miniaudio_consumer(21) == 42 ? 0 : 6;
}
