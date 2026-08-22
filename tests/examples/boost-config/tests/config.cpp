// Behavioral test: the compat.boost-config headers are present and identify
// themselves as exactly the pinned 1.92.0 train. If the descriptor ever
// drifts to another release without this member following, this fails loudly.
#include <boost/version.hpp>
#include <boost/config.hpp>
#include <string_view>

int main() {
    // BOOST_VERSION encodes major*100000 + minor*100 + patch -> 1.92.0.
    bool ok = BOOST_VERSION == 109200;
    ok = ok && std::string_view(BOOST_LIB_VERSION) == "1_92";

    // Platform detection must have positively selected THIS platform's header:
    // each platform/*.hpp stamps BOOST_PLATFORM with its own string. A config
    // that silently defaulted everywhere would fail on every branch.
#if defined(_WIN32)
    ok = ok && std::string_view(BOOST_PLATFORM) == "Win32";
#elif defined(__APPLE__) && defined(__MACH__)
    ok = ok && std::string_view(BOOST_PLATFORM) == "Mac OS";
#elif defined(__linux__)
    ok = ok && std::string_view(BOOST_PLATFORM) == "linux";
#else
    ok = false;   // not a platform this index claims
#endif
    return ok ? 0 : 1;
}
