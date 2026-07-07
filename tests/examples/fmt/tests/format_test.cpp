// Behavioral test: exercise {fmt}'s compiled implementation (src/format.cc via
// the fmt lib target) — not just header inlines — and assert the results.
// Returns non-zero on any mismatch.
#include <fmt/format.h>
#include <cmath>
#include <string>

int main() {
    std::string a = fmt::format("{} + {} = {}", 2, 3, 2 + 3);
    std::string b = fmt::format("{:08.3f}", 3.14159);
    std::string c = fmt::format("{0}-{1}-{0}", "x", "y");
    std::string d = fmt::format("{:#x}", 255);

    bool ok = a == "2 + 3 = 5"
              && b == "0003.142"
              && c == "x-y-x"
              && d == "0xff";
    return ok ? 0 : 1;
}
