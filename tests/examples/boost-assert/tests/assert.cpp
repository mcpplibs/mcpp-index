// Behavioral test: BOOST_VERIFY's expression is evaluated in ALL build modes
// (unlike BOOST_ASSERT, which compiles away under NDEBUG), and the
// source_location / current_function utilities return live data.
#include <boost/assert.hpp>
#include <boost/assert/source_location.hpp>
#include <boost/current_function.hpp>

static int answer() { return 42; }

int main() {
    bool ran = false;
    BOOST_VERIFY(answer() == 42 && (ran = true));   // must run even under NDEBUG

    const char* fn = BOOST_CURRENT_FUNCTION;
    bool fn_ok = fn != nullptr && *fn != '\0';

    constexpr boost::source_location loc = BOOST_CURRENT_LOCATION;
    bool loc_ok = loc.file_name() != nullptr && loc.line() > 0;

    return (ran && fn_ok && loc_ok) ? 0 : 1;
}
