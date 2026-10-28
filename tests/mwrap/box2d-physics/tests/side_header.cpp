// The side header from the installed package, beside the import: the raw
// header's macros and static constants with the module's entities.
#include <mwrap/box2d/macros.hpp>

import std;
import mcpplibs.mwrap.box2d;

B2_API int mwrap_box2d_consumer(int value);
int mwrap_box2d_consumer(int value) { return value * 2; }

int main() {
    namespace m = mcpplibs::mwrap::box2d::macros;
    namespace b = mcpplibs::mwrap::box2d;
    b2BodyId none = B2_NULL_ID;
    if (!B2_IS_NULL(none) || B2_IS_NULL(none) != (m::B2_IS_NULL)(none)) return 1;
    if (std::memcmp(&::b2Rot_identity, &b::b2Rot_identity, sizeof(b2Rot)) != 0) return 2;
    if (&::b2World_Step != &b2World_Step) return 3;
    static_assert(B2_MAX_POLYGON_VERTICES == 8 && std::is_same_v<decltype(b::b2_nullBodyId), const b2BodyId>);
    return mwrap_box2d_consumer(21) == 42 ? 0 : 4;
}
