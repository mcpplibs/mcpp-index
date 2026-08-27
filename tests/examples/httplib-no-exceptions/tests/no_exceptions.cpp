#ifndef CPPHTTPLIB_NO_EXCEPTIONS
#error "compat.httplib[no-exceptions] must define CPPHTTPLIB_NO_EXCEPTIONS in consumers"
#endif

#include <httplib.h>

#include <string>

int main() {
    // Without CPPHTTPLIB_NO_EXCEPTIONS this constructor throws for an invalid
    // scheme. The feature changes it into a normal invalid client result.
    httplib::Client invalid("ftp://127.0.0.1:1");
    if (invalid.is_valid()) return 1;

    httplib::Headers headers;
    const char *prohibited = httplib::detail::get_header_value(
        headers, "REMOTE_ADDR", "missing", 0);
    return prohibited != nullptr && prohibited[0] == '\0' ? 0 : 2;
}
