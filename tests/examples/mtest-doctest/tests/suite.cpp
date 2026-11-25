#include <doctest/doctest.h>
TEST_SUITE("arithmetic") {
    TEST_CASE("adds") { CHECK(1 + 1 == 2); }
    TEST_CASE("multiplies") { CHECK(2 * 3 == 6); }
}
