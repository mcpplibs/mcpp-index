// compat.catch2 v3, `main` FEATURE: no main() here on purpose — the entry
// point comes from the package's generated TU. Catch2 prints the assertion
// count on exit, so an empty binary cannot pass quietly.
#include <catch2/catch_all.hpp>

static unsigned int factorial(unsigned int n) {
    return n <= 1 ? 1 : n * factorial(n - 1);
}

TEST_CASE("factorial of 5 is 120", "[math]") {
    REQUIRE(factorial(5) == 120);
}

TEST_CASE("factorial of 0 is 1", "[math]") {
    REQUIRE(factorial(0) == 1);
}
