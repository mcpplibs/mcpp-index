// The side header from the installed package, beside the import: the raw
// macros and the X-macro tables with the module's entities.
#include <mwrap/fribidi/macros.hpp>

import std;
import mcpplibs.mwrap.fribidi;

constexpr std::pair<FriBidiCharSet, const char*> sets[] = {
#define _FRIBIDI_ADD_CHAR_SET(CHAR_SET, char_set) {FRIBIDI_CHAR_SET_##CHAR_SET, #char_set},
#include <fribidi-char-sets-list.h>
#undef _FRIBIDI_ADD_CHAR_SET
};

int main() {
    if (std::size(sets) != static_cast<std::size_t>(FRIBIDI_CHAR_SETS_NUM)) return 1;
    for (auto [set, name] : sets)
        if (fribidi_parse_charset(fribidi_char_set_name(set)) != set) return 2;
    if (FRIBIDI_IS_RTL(::fribidi_get_bidi_type(0x05D0)) != (mcpplibs::mwrap::fribidi::macros::FRIBIDI_IS_RTL)(FRIBIDI_TYPE_RTL)) return 3;
    return 0;
}
