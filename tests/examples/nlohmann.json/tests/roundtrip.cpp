// Behavioral test: build → dump → parse round-trip + the ordered_json variant.
import std;
import nlohmann.json;
using namespace nlohmann::literals;

int main() {
    nlohmann::json j = { {"answer", 42}, {"list", {1, 2, 3}} };
    nlohmann::json parsed = nlohmann::json::parse(j.dump());
    auto lit = R"({"k":true})"_json;
    nlohmann::ordered_json oj; oj["z"] = 1; oj["a"] = 2;
    bool ok = parsed["answer"] == 42 && parsed["list"][2] == 3
              && lit["k"] == true && oj.dump() == R"({"z":1,"a":2})";
    return ok ? 0 : 1;
}
