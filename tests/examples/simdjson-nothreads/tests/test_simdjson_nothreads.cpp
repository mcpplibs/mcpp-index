#include <cstdio>
#include <string_view>

#include <simdjson.h>

// Note: on Windows MSVC/clang-cl `/MD` defines `_MT`, which simdjson.h maps
// to SIMDJSON_THREADS_ENABLED internally. On POSIX targets without `-pthread`,
// `default-features = false` must leave SIMDJSON_THREADS_ENABLED undefined.
#if !defined(_WIN32) && defined(SIMDJSON_THREADS_ENABLED)
#error "expected default-features = false to omit SIMDJSON_THREADS_ENABLED on non-Windows targets"
#endif

int main() {
    const simdjson::padded_string json = R"({"ok":true,"count":3})"_padded;
    simdjson::ondemand::parser parser;
    simdjson::ondemand::document doc;
    if (parser.iterate(json).get(doc) != simdjson::SUCCESS) {
        return 1;
    }
    bool flag = false;
    int64_t count = 0;
    bool ok = doc["ok"].get_bool().get(flag) == simdjson::SUCCESS && flag;
    ok = ok && doc["count"].get_int64().get(count) == simdjson::SUCCESS && count == 3;
    return ok ? 0 : 1;
}
