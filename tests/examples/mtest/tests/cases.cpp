import std;
import mcpplibs.mtest;
using namespace mcpplibs::mtest;

UTest parsing{"parsing", tag{"fast"}, [] {
    "a comparison holds"_test = [] { expect(eq(1 + 1, 2)); };
    "a failure reports both sides"_test[expect_failure{"shown"}] = [] { expect(eq(std::string("a"), std::string("b"))); };
}};
E2E timed{"a case with a time limit", timeout{std::chrono::seconds{30}}, [] { expect(true); }};
Bench measured{"a metric within its bound", at_most{"ready", 15}, [] { metric("ready", 1.0, "s"); }};

int main() {
    "parameters"_test = values{2, 4, 6} | [](int v) { expect(eq(v % 2, 0)); };
    return report();
}
