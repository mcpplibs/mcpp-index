// The image's functions, called from this program through the binding
// openkal-bind generated, including a function of this program the image calls.
#include "twice.h"
#include <cstdio>

namespace { int64_t plus_one(int64_t v) { return v + 1; } }

int main() {
    const int64_t a = twice(21), b = twice_apply(&plus_one, 20);
    std::printf("openkal-bind-tests: twice(21) = %lld, twice_apply(plus_one, 20) = %lld\n",
                static_cast<long long>(a), static_cast<long long>(b));
    return a == 42 && b == 42 ? 0 : 1;
}
