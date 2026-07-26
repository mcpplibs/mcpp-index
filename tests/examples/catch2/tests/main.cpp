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

int main(int argc, char* argv[]) {
    return Catch::Session().run(argc, argv);
}
