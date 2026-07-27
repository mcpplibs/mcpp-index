// compat.catch2 v2, `main` FEATURE: neither main() nor CATCH_CONFIG_MAIN here
// — both come from the package's generated TU, which reaches this version
// through the ELSE branch of its __has_include(<catch2/catch_all.hpp>) test.
#include <catch2/catch.hpp>

static unsigned int factorial(unsigned int n) {
    return n <= 1 ? 1 : n * factorial(n - 1);
}

TEST_CASE("factorial of 5 is 120", "[math]") {
    REQUIRE(factorial(5) == 120);
}

TEST_CASE("factorial of 0 is 1", "[math]") {
    REQUIRE(factorial(0) == 1);
}
