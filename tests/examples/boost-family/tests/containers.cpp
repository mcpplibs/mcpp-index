// boost-container (vector), boost-intrusive (list), boost-optional
// and boost-static-string.
#include <boost/container/vector.hpp>
#include <boost/intrusive/list.hpp>
#include <boost/optional.hpp>
#include <boost/static_string/static_string.hpp>

int main() {
    bool ok = true;

    // container: an STL-compatible vector that is not std::vector.
    {
        boost::container::vector<int> vec;
        for (int i = 0; i < 100; ++i) vec.push_back(i);
        ok = ok && vec.size() == 100 && vec.back() == 99 && vec[42] == 42;
    }

    // intrusive: the list only links; ownership stays with the nodes.
    {
        namespace intr = boost::intrusive;
        struct Node : intr::list_base_hook<> {
            int v;
            explicit Node(int x) : v(x) {}
        };
        intr::list<Node> lst;
        Node a(1), b(2), c(3);
        lst.push_back(a);
        lst.push_back(b);
        lst.push_back(c);
        ok = ok && lst.size() == 3 && lst.front().v == 1 && lst.back().v == 3;

        lst.pop_front();
        ok = ok && lst.front().v == 2 && a.v == 1;  // a outlives its unlinking

        lst.clear();  // unlink everything: hooks must not die while linked
        ok = ok && lst.empty();
    }

    // optional: empty/engaged lifecycle and value_or fallback.
    {
        boost::optional<int> o;
        ok = ok && !o && o.value_or(-1) == -1;

        o = 9;
        ok = ok && o && *o == 9 && o.value() == 9;

        o.reset();
        ok = ok && !o;
    }

    // static-string: fixed-capacity string with a compile-time bound.
    {
        boost::static_strings::static_string<8> s("abc");
        s += "def";
        ok = ok && s == "abcdef" && s.size() == 6;
        ok = ok && s.compare(0, 3, "abc") == 0;
    }

    return ok ? 0 : 1;
}
