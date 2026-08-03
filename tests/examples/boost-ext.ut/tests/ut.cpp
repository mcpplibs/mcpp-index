// Behavioral test: build two tests under [Boost::ext].UT via `import boost.ut;`,
// then exercise the UDL ("..."_test) and function-call (test("...")) syntaxes.
// Counts test registration by reading ut's `tests_runner` directly is awkward,
// so the test instead just RUNS a passing assertion in each style; if the
// module fails to import or any expect() fails, [Boost::ext].UT reports the
// failure through its test runner and `mcpp test` returns non-zero.
import std;
import boost.ut;

using namespace boost::ut;

int main() {
    "UDL syntax"_test = [] {
        expect(42_i == 42);
    };

    test("function syntax") = [] {
        expect(0_i == 0);
        expect(1u == 1_u);
    };

    return 0;
}
