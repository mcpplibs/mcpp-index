#include <cmath>
#include <cstdio>
#include <string>
#include <string_view>

#include <simdjson.h>

#ifndef SIMDJSON_THREADS_ENABLED
#error "expected compat.simdjson default feature `threads` to define SIMDJSON_THREADS_ENABLED"
#endif

int main() {
    bool ok = true;

    const simdjson::padded_string json =
        R"({"name":"mcpp","version":2026,"active":true,"items":[10,20,30],"ratio":1.5})"_padded;

    // 1. On-Demand API
    simdjson::ondemand::parser od_parser;
    simdjson::ondemand::document doc;
    auto err = od_parser.iterate(json).get(doc);
    if (err) {
        std::fprintf(stderr, "simdjson ondemand iterate failed: %s\n", simdjson::error_message(err));
        return 1;
    }

    std::string_view name;
    int64_t version = 0;
    bool active = false;
    double ratio = 0.0;
    ok = ok && doc["name"].get_string().get(name) == simdjson::SUCCESS && name == "mcpp";
    ok = ok && doc["version"].get_int64().get(version) == simdjson::SUCCESS && version == 2026;
    ok = ok && doc["active"].get_bool().get(active) == simdjson::SUCCESS && active;
    ok = ok && doc["ratio"].get_double().get(ratio) == simdjson::SUCCESS && std::fabs(ratio - 1.5) < 1e-9;

    int64_t sum = 0;
    for (auto elem : doc["items"]) {
        int64_t v = 0;
        if (elem.get_int64().get(v) != simdjson::SUCCESS) {
            return 1;
        }
        sum += v;
    }
    ok = ok && sum == 60;

    // 2. DOM API + active implementation check
    simdjson::dom::parser dom_parser;
    simdjson::dom::element root;
    err = dom_parser.parse(json).get(root);
    if (err) {
        std::fprintf(stderr, "simdjson dom parse failed: %s\n", simdjson::error_message(err));
        return 1;
    }
    ok = ok && std::string_view(root["name"]) == "mcpp";
    ok = ok && simdjson::get_active_implementation() != nullptr;

    // 3. Invalid JSON rejection
    const simdjson::padded_string bad_json = R"({"broken": [1, 2,})"_padded;
    simdjson::dom::element bad_root;
    auto bad_err = dom_parser.parse(bad_json).get(bad_root);
    ok = ok && bad_err != simdjson::SUCCESS;

    return ok ? 0 : 1;
}
