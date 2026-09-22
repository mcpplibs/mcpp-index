// Public boost.boost module-package end-to-end assertion: consume the Boost
// named-modules wrapper by import only (no `#include <boost/...>` at all).
//
//   * `import boost.optional;` — a classic header-only library
//   * `import boost.json;`     — a compiled library (library TU linked in)
//   * `import boost.version;`  — the version constants module
//   * `import boost;`          — the umbrella, re-exporting the active set

import std;

import boost.optional;
import boost.json;
import boost.version;
import boost;

int main() {
    int failures = 0;
    auto check = [&failures](bool ok, const char* what) {
        if (!ok) {
            std::println("FAIL: {}", what);
            ++failures;
        }
    };

    // optional (header-only module)
    boost::optional<int> empty;
    check(!empty.has_value(), "optional: empty has no value");
    boost::optional<int> v(42);
    check(v.has_value() && *v == 42, "optional: value round-trip");
    check(v.value_or(0) == 42, "optional: value_or hits the value");
    empty = 7;
    check(empty.value_or(0) == 7, "optional: assignment activates");

    // json (compiled library)
    boost::json::value j = boost::json::parse(R"({"lib":"boost","ok":true})");
    check(j.is_object(), "json: parsed to an object");
    boost::json::object& o = j.as_object();
    check(o["lib"].as_string() == "boost", "json: string member");
    check(o["ok"].as_bool(), "json: bool member");
    const std::string ser = boost::json::serialize(j);
    check(boost::json::parse(ser).as_object()["lib"].as_string() == "boost",
          "json: serialize/parse round-trip");

    // version constants
    check(boost::BOOST_VERSION == 109100, "version: BOOST_VERSION == 109100");
    check(boost::BOOST_LIB_VERSION[0] == '1', "version: BOOST_LIB_VERSION");

    // type_traits (reached through the umbrella's active set as well)
    check(boost::is_same<int, int>::value, "type_traits: is_same");

    if (failures == 0) {
        std::println("boost.boost modules ok: BOOST_VERSION={}", boost::BOOST_VERSION);
    }
    return failures == 0 ? 0 : 1;
}
