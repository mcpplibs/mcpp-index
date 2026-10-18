// safe_math.h is the C API. Include it inside extern "C" so its prototype and
// inline definitions share C linkage; it also rejects a translation unit that
// included SafeInt.hpp.
#include <cstdio>

extern "C" {
#include <safe_math.h>
}

int main() {
    bool ok = true;
    auto check = [&](bool condition, const char* what) {
        if (!condition) {
            std::printf("FAIL: %s\n", what);
            ok = false;
        }
    };

    int result = 0;

    check(check_add_int_int(40, 2, &result) && result == 42,
          "checked C addition");
    check(check_sub_int_int(44, 2, &result) && result == 42,
          "checked C subtraction");
    check(check_mul_int_int(21, 2, &result) && result == 42,
          "checked C multiplication");
    check(check_div_int_int(84, 2, &result) && result == 42,
          "checked C division");
    check(!check_mul_int_int(INT32_MAX, 2, &result),
          "checked C multiplication rejects overflow");

    if (ok) {
        std::puts("safeint C API OK");
    }

    return ok ? 0 : 1;
}
