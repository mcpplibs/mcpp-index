import std;
import mcpplibs.mtest;
using namespace mcpplibs::mtest;
int main() {
    "a comparison holds"_test = [] { expect(eq(1 + 1, 2)); };
    "a failure reports both sides"_test[expect_failure{"shown"}] = [] { expect(eq(std::string("a"), std::string("b"))); };
    "parameters"_test = values{2, 4, 6} | [](int v) { expect(eq(v % 2, 0)); };
    return report();
}
