// compat.fmt's `c-api` feature: the two entry points of src/fmt-c.cc, called
// through fmt/fmt-c.h's `extern "C"` surface. Both are declared in the header,
// and only this TU (or a consumer's) can provide them — with the feature off
// this file does not link. See this member's mcpp.toml for why the calls are
// spelled this way instead of through the header's C-only fmt_format macro.
//
// Nothing here needs a file on disk: the format side is asserted in memory,
// and fmt_vprint runs against a stream the process owns (tmpfile is unlinked
// on close), so a passing test prints nothing.
#include <fmt/fmt-c.h>

#include <cstdio>
#include <string>

int main() {
    fmt_arg args[2] = {};
    args[0].type = fmt_cstring;
    args[0].value.cstring = "world";
    args[1].type = fmt_int;
    args[1].value.int_value = 42;

    const std::string expected = "hello world #42";
    char buffer[64] = {};
    const int n = fmt_vformat(buffer, sizeof(buffer), "hello {} #{}", args, 2);
    bool ok = n == static_cast<int>(expected.size()) && expected == buffer;

    // Buffer contract, straight out of vformat_to_n: the return value is how
    // much output there would have been, not how much fit, and the buffer is
    // not NUL-terminated.
    char small[6] = {};
    const int m = fmt_vformat(small, sizeof(small), "hello {} #{}", args, 2);
    ok = ok && m == static_cast<int>(expected.size())
        && std::string(small, sizeof(small)) == "hello ";

    // The error contract, both halves: an unknown fmt_type is refused before
    // anything is written, and so is a call with more arguments than the API's
    // fixed 16-slot table.
    fmt_arg unknown[1] = {};
    unknown[0].type = static_cast<fmt_type>(99);
    ok = ok && fmt_vformat(buffer, sizeof(buffer), "{}", unknown, 1)
                   == fmt_error_invalid_arg;

    fmt_arg many[17] = {};
    ok = ok && fmt_vformat(buffer, sizeof(buffer), "{}", many, 17)
                   == fmt_error_invalid_arg;

    // The other entry point the feature compiles.
    std::FILE* f = std::tmpfile();
    ok = ok && f != nullptr;
    if (f != nullptr) {
        ok = ok && fmt_vprint(f, "[{}]", args, 2) == 0;
        std::rewind(f);  // delivers the stream's unwritten data, then seeks back
        char read[64] = {};
        const std::size_t got = std::fread(read, 1, sizeof(read) - 1, f);
        ok = ok && std::string(read, got) == "[world]";
        std::fclose(f);
    }

    return ok ? 0 : 1;
}
