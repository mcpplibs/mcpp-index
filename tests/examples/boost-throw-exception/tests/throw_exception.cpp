// Behavioral test: BOOST_THROW_EXCEPTION raises an exception catchable as its
// own std::exception base, carrying the original message through what().
#include <boost/throw_exception.hpp>
#include <stdexcept>
#include <cstring>

int main() {
    bool caught = false;
    try {
        BOOST_THROW_EXCEPTION(std::runtime_error("compat probe"));
    } catch (const std::exception& e) {
        caught = std::strstr(e.what(), "compat probe") != nullptr;
    }
    return caught ? 0 : 1;
}
