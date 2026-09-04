// boost-core (addressof / empty_value / ref), boost-smart-ptr
// (shared_ptr/weak_ptr/make_shared) and boost-move (movelib::unique_ptr).
#include <boost/core/addressof.hpp>
#include <boost/core/empty_value.hpp>
#include <boost/core/ref.hpp>
#include <boost/make_shared.hpp>
#include <boost/move/make_unique.hpp>
#include <boost/move/unique_ptr.hpp>
#include <boost/shared_ptr.hpp>
#include <boost/weak_ptr.hpp>

int main() {
    bool ok = true;

    // core: addressof survives overloaded operator&, ref wraps without copies.
    {
        struct Tricky {
            int v = 7;
            Tricky* operator&() const { return nullptr; }
        } tricky;
        ok = ok && boost::addressof(tricky) != nullptr;
        ok = ok && boost::addressof(tricky)->v == 7;

        auto r = boost::cref(tricky.v);
        ok = ok && r.get() == 7;
    }

    // core: empty_value with a non-empty payload stores and returns it.
    {
        boost::empty_value<int> ev(boost::empty_init_t(), 42);
        ok = ok && ev.get() == 42;
    }

    // smart-ptr: reference counting across shared/weak.
    {
        boost::shared_ptr<int> sp = boost::make_shared<int>(5);
        boost::weak_ptr<int> wp = sp;
        ok = ok && sp.use_count() == 1 && *sp == 5 && !wp.expired();

        sp.reset();
        ok = ok && wp.expired() && wp.lock() == boost::shared_ptr<int>();
    }

    // move: movelib::unique_ptr transfers sole ownership.
    {
        boost::movelib::unique_ptr<int> up = boost::movelib::make_unique<int>(11);
        boost::movelib::unique_ptr<int> up2 = boost::move(up);
        ok = ok && !up && up2 && *up2 == 11;
    }

    return ok ? 0 : 1;
}
