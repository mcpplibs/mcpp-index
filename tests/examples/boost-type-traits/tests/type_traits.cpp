// Behavioral test: core traits give the right answers, cross-checked against
// the standard library where an equivalent exists.
#include <boost/type_traits/is_same.hpp>
#include <boost/type_traits/add_pointer.hpp>
#include <boost/type_traits/remove_cv.hpp>
#include <type_traits>

int main() {
    static_assert(boost::is_same<int, int>::value, "same type must match");
    static_assert(!boost::is_same<int, long>::value, "distinct types must differ");
    static_assert(std::is_same<boost::add_pointer<int>::type, int*>::value,
                  "add_pointer must yield int*");
    static_assert(std::is_same<boost::remove_cv<const volatile int>::type, int>::value,
                  "remove_cv must strip const/volatile");

    bool ok = boost::is_same<double, double>::value;   // runtime-visible path
    return ok ? 0 : 1;
}
