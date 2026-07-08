// Behavioral test: consume {fmt}'s compiled implementation through the C++23
// module `fmt` (`import fmt;`, no #include) and assert the results. Exercises
// src/format.cc via the module unit's tail includes — not just header inlines.
// Returns non-zero on any mismatch.
import std;
import fmt;

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
