import std;
import mp_units;

#include "../src/quantity_bridge.h"

using namespace mp_units;
using namespace mp_units::si::unit_symbols;

template<class Left, class Right>
concept Addable = requires(Left left, Right right) { left + right; };

static_assert(1 * km == 1000 * m);
static_assert(!Addable<decltype(1 * m), decltype(1 * s)>);
static_assert((120 * km / (2 * h)).numerical_value_in(km / h) == 60);
static_assert(quantity{std::chrono::minutes{2}} == 120 * s);

int main() {
    if (add_distance(20 * m, 22 * m) != 42 * m) return 1;
    if (std::format("{}", 42 * m) != "42 m") return 2;
    if (std::format("{}", 2 * ohm) != "2 \xce\xa9") return 3;
    return 0;
}
