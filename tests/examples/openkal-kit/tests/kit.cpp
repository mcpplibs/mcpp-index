// openkal-kit through the index: an endpoint parsed, written back and refused
// when malformed, which is the kit's behaviour and not only its declarations.
#include <cstdio>
#include <cstring>
import openkal.types;
import openkal.kit.endpoint;

int main() {
    using namespace kal::kit;
    int failures = 0;
    auto check = [&](bool held, const char* what) {
        if (!held) { std::printf("FAIL: %s\n", what); ++failures; }
    };
    const auto r = parse_v4("127.0.0.1:8080", 14);
    check(r.ok && r.ep.addr_len == 4 && r.ep.port == 8080, "an address with a port parses");
    char out[32];
    const auto f = format_v4(r.ep, out, sizeof out);
    check(f.ok && f.n == 14 && std::memcmp(out, "127.0.0.1:8080", 14) == 0,
          "and is written back as it was given");
    check(!parse_v4("256.0.0.1", 9).ok, "an octet past 255 is refused");
    check(!parse_v4("1.2.3", 5).ok, "three octets are refused");
    if (failures == 0) std::printf("openkal-kit: an endpoint parsed, written back and refused\n");
    return failures == 0 ? 0 : 1;
}
