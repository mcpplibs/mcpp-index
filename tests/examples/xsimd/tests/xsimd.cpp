// compat.xsimd — assert architecture discovery, unaligned load/store, batch
// arithmetic, math functions and horizontal reduction through the public API.
#include <xsimd/xsimd.hpp>

#include <array>
#include <cmath>
#include <cstddef>
#include <cstdio>

int main() {
    using batch_type = xsimd::batch<float>;
    constexpr std::size_t width = batch_type::size;

    std::array<float, width> left{};
    std::array<float, width> right{};
    std::array<float, width> sum{};
    for (std::size_t i = 0; i < width; ++i) {
        left[i] = static_cast<float>(i + 1);
        right[i] = static_cast<float>(2 * i + 2);
    }

    bool ok = true;
    auto check = [&](bool condition, const char* what) {
        if (!condition) {
            std::printf("FAIL: %s\n", what);
            ok = false;
        }
    };

    check(xsimd::default_arch::supported(),
          "default architecture is supported by the compiler");
    check(xsimd::default_arch::available(),
          "default architecture is available on this CPU");
    check(xsimd::available_architectures().has(xsimd::default_arch{}),
          "runtime discovery includes the default architecture");

    auto lhs = xsimd::load_unaligned(left.data());
    auto rhs = xsimd::load_unaligned(right.data());
    xsimd::store_unaligned(sum.data(), lhs + rhs);
    for (std::size_t i = 0; i < width; ++i) {
        check(sum[i] == left[i] + right[i],
              "unaligned load, batch addition and store");
    }

    auto square_roots = xsimd::sqrt(lhs * lhs);
    const float expected = static_cast<float>(width * (width + 1) / 2);
    check(std::fabs(xsimd::reduce_add(square_roots) - expected) < 0.001f,
          "batch math and horizontal reduction");

    if (ok) {
        std::printf("xsimd OK width=%zu arch=%s\n",
                    width, xsimd::default_arch::name());
    }
    return ok ? 0 : 1;
}
