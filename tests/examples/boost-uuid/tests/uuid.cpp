// Behavioral test: RFC 4122 shape of generated UUIDs, string round-trip,
// deterministic name generation, and the std::hash specialization.
#include <boost/uuid/uuid.hpp>
#include <boost/uuid/uuid_io.hpp>
#include <boost/uuid/string_generator.hpp>
#include <boost/uuid/nil_generator.hpp>
#include <boost/uuid/random_generator.hpp>
#include <boost/uuid/name_generator_sha1.hpp>
#include <boost/uuid/namespaces.hpp>
#include <functional>
#include <sstream>
#include <string>

int main() {
    namespace uuids = boost::uuids;
    bool ok = true;

    // Nil UUID round-trips through the canonical textual form.
    std::ostringstream nil_out;
    nil_out << uuids::nil_uuid();
    ok = ok && nil_out.str() == "00000000-0000-0000-0000-000000000000";

    // Parse -> print reproduces the canonical spelling byte for byte.
    uuids::string_generator parse;
    const uuids::uuid fixed =
        parse("f81d4fae-7dec-11d0-a765-00a0c91e6bf6");
    std::ostringstream fixed_out;
    fixed_out << fixed;
    ok = ok && fixed_out.str() == "f81d4fae-7dec-11d0-a765-00a0c91e6bf6";

    // Random generator emits RFC 4122 version 4 / variant 1 shapes, and two
    // draws differ (collision odds are negligible by construction).
    uuids::random_generator rand;
    const uuids::uuid a = rand();
    const uuids::uuid b = rand();
    ok = ok && ((a.data[6] >> 4) == 4) && ((a.data[8] >> 6) == 0b10);
    ok = ok && a != b;

    // Name generator is deterministic per input and sensitive across inputs.
    uuids::name_generator_sha1 namegen(uuids::ns::dns());
    ok = ok && namegen("example.com") == namegen("example.com");
    ok = ok && namegen("example.com") != namegen("other.example.com");

    // The std::hash specialization agrees on equal values.
    ok = ok && std::hash<uuids::uuid>{}(fixed) == std::hash<uuids::uuid>{}(fixed);

    return ok ? 0 : 1;
}
