// boost-endian (byte-order conversion), boost-container-hash (hashing),
// boost-logic (tribool) and boost-align (pointer alignment helpers).
#include <boost/align/align_down.hpp>
#include <boost/align/align_up.hpp>
#include <boost/align/is_aligned.hpp>
#include <boost/container_hash/hash.hpp>
#include <boost/endian/conversion.hpp>
#include <boost/logic/tribool.hpp>

#include <cstdint>
#include <vector>

int main() {
    bool ok = true;

    // endian: reversing is an involution with byte-exact results.
    {
        std::uint32_t x = 0x01020304u;
        ok = ok && boost::endian::endian_reverse(x) == 0x04030201u;
        ok = ok &&
             boost::endian::endian_reverse(boost::endian::endian_reverse(x)) == x;
    }

    // container-hash: deterministic within a process; combining is stable.
    {
        boost::hash<std::string> hs;
        ok = ok && hs("abc") == hs("abc");

        const std::vector<int> v1{1, 2, 3}, v2{1, 2, 3};
        std::size_t seed = 0;
        boost::hash_range(seed, v1.begin(), v1.end());
        std::size_t seed2 = 0;
        boost::hash_range(seed2, v2.begin(), v2.end());
        ok = ok && seed == seed2 && seed != 0;
    }

    // logic: three-valued truth table entry points used by beast::detect_ssl.
    // Every operator (including !) returns tribool; the explicit conversion
    // and the indeterminate() free function are the way back to bool.
    {
        using boost::logic::indeterminate;
        using boost::logic::tribool;
        tribool t = true, f = false, i = indeterminate;

        ok = ok && static_cast<bool>(t) && !static_cast<bool>(f);
        ok = ok && indeterminate(i);
        ok = ok && indeterminate(t && i);
        ok = ok && static_cast<bool>(t || i);          // true dominates OR
        ok = ok && !static_cast<bool>(f && i);         // false dominates AND
        ok = ok && indeterminate(i || f) && indeterminate(i && t);
    }

    // align: round-tripping through align_up lands on the boundary and
    // align_down undoes it.
    {
        alignas(64) char raw[128];
        ok = ok && boost::alignment::is_aligned(boost::alignment::align_up(raw, 64), 64);
        ok = ok && boost::alignment::align_down(
                        boost::alignment::align_up(raw, 64), 64) ==
                        boost::alignment::align_up(raw, 64);
    }

    return ok ? 0 : 1;
}
