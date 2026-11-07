// The side header from the installed package: va_* and offsetof are the C
// library's macros, and the mapped names still work in the same unit.
#include <mwrap/libc/macros.hpp>
import mcpplibs.mwrap.libc;

namespace c = mcpplibs::mwrap::libc::macros;

static int sum(int count, ...) {
    va_list args;
    va_start(args, count);
    int total = 0;
    for (int i = 0; i < count; ++i) total += va_arg(args, int);
    va_end(args);
    return total;
}

struct pair { char tag; double value; };

int main() {
    c::errno() = 0;
    return sum(3, 4, 5, 6) == 15 && offsetof(pair, tag) == 0 && c::errno() == 0
        && c::SIZE_MAX == std::numeric_limits<std::size_t>::max() ? 0 : 1;
}
