// The C++ library under clang is libstdc++ (gcc.libstdcxx): `import std` comes
// from its `bits/std.cc`, a typed catch matches what its runtime threw, and the
// program carries no libc++. `<version>` is included for the one macro a
// module does not export: the library's own name.
#include <version>
import std;

int main() {
#if defined(__linux__)
#  if !defined(__GLIBCXX__) || !defined(__clang__)
    std::println("expected clang over libstdc++");
    return 1;
#  endif
#endif
    std::vector<int> v{3, 1, 2};
    std::ranges::sort(v);
    try {
        throw std::runtime_error(std::format("{}", v));
    } catch (const std::exception& e) {
        if (std::string_view(e.what()) != "[1, 2, 3]") return 2;
    } catch (...) {
        return 3;
    }
    std::println("ok");
    return 0;
}
