// compat.safeint — assert the C++ class's normal arithmetic, non-throwing cast
// check, and both overflow and divide-by-zero exception paths.
#include <SafeInt.hpp>

#include <cstdint>
#include <cstdio>
#include <limits>

int main() {
    bool ok = true;
    auto check = [&](bool condition, const char* what) {
        if (!condition) {
            std::printf("FAIL: %s\n", what);
            ok = false;
        }
    };

    SafeInt<std::int32_t> lhs = 40;
    SafeInt<std::int32_t> rhs = 2;
    check(static_cast<std::int32_t>(lhs + rhs) == 42,
          "SafeInt addition");
    check(static_cast<std::int32_t>((lhs + rhs) * 2) == 84,
          "SafeInt multiplication");
    check(static_cast<std::int32_t>((lhs + rhs) / rhs) == 21,
          "SafeInt division");

    std::int32_t narrowed = 0;
    check(SafeCast(std::uint64_t{42}, narrowed) && narrowed == 42,
          "SafeCast accepts an in-range value");
    check(!SafeCast(std::numeric_limits<std::uint64_t>::max(), narrowed),
          "SafeCast rejects an out-of-range value");

    bool overflow_reported = false;
    try {
        SafeInt<std::int32_t> maximum =
            std::numeric_limits<std::int32_t>::max();
        maximum += 1;
    } catch (const SafeIntException& error) {
        overflow_reported = error.m_code == SafeIntArithmeticOverflow;
    }
    check(overflow_reported, "overflow throws SafeIntArithmeticOverflow");

    bool div_zero_reported = false;
    try {
        SafeInt<std::int32_t> value = 42;
        value /= 0;
    } catch (const SafeIntException& error) {
        div_zero_reported = error.m_code == SafeIntDivideByZero;
    }
    check(div_zero_reported, "divide by zero throws SafeIntDivideByZero");

    if (ok) {
        std::puts("safeint OK");
    }
    return ok ? 0 : 1;
}
