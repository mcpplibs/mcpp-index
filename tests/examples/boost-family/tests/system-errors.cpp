// boost-system (error_code/system_error), boost-compat (invoke backport)
// and boost-bind (bind/mem_fn with placeholders).
#include <boost/bind/bind.hpp>
#include <boost/compat/invoke.hpp>
#include <boost/system/error_code.hpp>
#include <boost/system/system_error.hpp>

#include <string>

int family_sub(int a, int b) { return a - b; }

struct Point {
    int x = 31;
    int get() const { return x; }
};

int main() {
    bool ok = true;

    // system: generic errc mapping, category identity, throwing with a code.
    {
        namespace sys = boost::system;
        sys::error_code ec = sys::errc::make_error_code(sys::errc::invalid_argument);
        ok = ok && static_cast<bool>(ec);
        ok = ok && ec == sys::errc::invalid_argument;
        ok = ok && ec.category() == sys::generic_category();

        bool caught = false;
        try {
            throw sys::system_error(ec);
        } catch (const sys::system_error& e) {
            caught = e.code() == sys::errc::invalid_argument;
        }
        ok = ok && caught;
    }

    // compat: C++11-17 std::invoke backport, including member-object access.
    {
        struct Inc {
            int operator()(int x) const { return x + 1; }
        };
        ok = ok && boost::compat::invoke(Inc{}, 41) == 42;
        ok = ok && boost::compat::invoke([](int a, int b) { return a * b; }, 6, 7) == 42;

        Point p;
        ok = ok && boost::compat::invoke(&Point::x, p) == 31;
        ok = ok && boost::compat::invoke(&Point::get, p) == 31;
    }

    // bind: partial application through placeholders, plus mem_fn.
    {
        namespace ph = boost::placeholders;
        auto f = boost::bind(family_sub, ph::_1, 3);
        ok = ok && f(10) == 7;

        Point p;
        auto byName = boost::bind(&Point::x, ph::_1);
        ok = ok && byName(p) == 31;

        auto m = boost::mem_fn(&Point::get);
        ok = ok && m(p) == 31;
    }

    return ok ? 0 : 1;
}
