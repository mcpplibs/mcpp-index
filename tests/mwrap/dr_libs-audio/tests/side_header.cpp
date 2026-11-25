// The side header from the installed package, beside the import: the raw
// headers' macros with the module's entities.
#include <mwrap/dr_libs/macros.hpp>

import std;
import mcpplibs.mwrap.dr_libs;

extern "C" {
DRWAV_API int mwrap_dr_libs_consumer(int value);
}
int mwrap_dr_libs_consumer(int value) { return value * 2; }

int main() {
    namespace m = mcpplibs::mwrap::dr_libs::macros;
    constexpr auto raw = DRWAV_INVALID_FILE;
#pragma push_macro("DRWAV_INVALID_FILE")
#undef DRWAV_INVALID_FILE
    static_assert(m::DRWAV_INVALID_FILE == raw && std::is_same_v<decltype(m::DRWAV_INVALID_FILE), const int>);
#pragma pop_macro("DRWAV_INVALID_FILE")
    if (std::string_view(DRMP3_XSTRINGIFY(DRMP3_VERSION_MINOR)) != "7") return 1;
    if (&::drwav_init_memory != &drwav_init_memory) return 2;
    static_assert(drwav_container_w64 == ::drwav_container_w64);
    return mwrap_dr_libs_consumer(21) == 42 ? 0 : 3;
}
