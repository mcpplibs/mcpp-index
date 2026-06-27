// Idiomatic usage: import std + the nlohmann.json module. Do NOT mix the
// module import with textual `#include <string>` etc. — GCC's module
// implementation clashes on the standard headers the module already attaches.
import std;
import nlohmann.json;

using namespace nlohmann::literals;  // enables the operator""_json UDL

int main() {
    nlohmann::json j = { {"answer", 42}, {"list", {1, 2, 3}} };
    std::string s = j.dump();
    nlohmann::json parsed = nlohmann::json::parse(s);
    auto lit = R"({"k":true})"_json;

    nlohmann::ordered_json oj;  // insertion-ordered variant (exported)
    oj["z"] = 1;
    oj["a"] = 2;

    bool ok = parsed["answer"] == 42 && parsed["list"][2] == 3
              && lit["k"] == true && oj.dump() == R"({"z":1,"a":2})";

    std::println("nlohmann.json ok={} dump={}", ok, s);
    return ok ? 0 : 1;
}
