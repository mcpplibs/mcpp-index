// Behavioral test — compat.doctest gives a working framework AND its main.
//
// No `import std;` here: doctest.h is a textual header that includes the C++
// standard headers itself, and mixing those with the std module is the one
// thing this index's module packages tell consumers not to do.
//
// A failing REQUIRE makes doctest return a non-zero exit code, which is how
// `mcpp test` sees it — so the assertions below are the test, and the runner
// needs no adapter.
#define DOCTEST_CONFIG_IMPLEMENT_WITH_MAIN
#include <doctest/doctest.h>

#include <string>
#include <vector>

static unsigned factorial(unsigned n) { return n <= 1 ? 1 : n * factorial(n - 1); }

TEST_CASE("factorial") {
    CHECK(factorial(0) == 1);
    CHECK(factorial(5) == 120);
}

TEST_CASE("subcases run independently") {
    std::vector<int> v;
    SUBCASE("one element") {
        v.push_back(1);
        CHECK(v.size() == 1);
    }
    SUBCASE("two elements") {
        v.push_back(1);
        v.push_back(2);
        CHECK(v.size() == 2);
    }
    // Each subcase re-enters with a fresh `v`; if doctest's subcase machinery
    // were missing, one of the two CHECKs above would see the other's push.
}

TEST_CASE("string comparison reporting") {
    const std::string s = "doctest";
    REQUIRE(s.size() == 7);
    CHECK(s.substr(0, 3) == "doc");
}
