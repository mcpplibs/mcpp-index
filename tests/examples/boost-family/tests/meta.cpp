// boost-mp11 (list metaprogramming), boost-describe (enum reflection),
// boost-preprocessor (token repetition), boost-type-index (runtime type
// identity) and boost-predef (platform/compiler detection).
#include <boost/describe.hpp>
#include <boost/mp11/algorithm.hpp>
#include <boost/predef.h>
#include <boost/preprocessor/cat.hpp>
#include <boost/preprocessor/repetition/repeat.hpp>
#include <boost/preprocessor/stringize.hpp>
#include <boost/type_index.hpp>

#include <string>

// Enumerators must be visible at global scope for the describe macros.
enum class Color { red = 1, green = 2, blue = 4 };
BOOST_DESCRIBE_ENUM(Color, red, green, blue)

#define FAMILY_INC(z, n, d) + (n)

int main() {
    bool ok = true;

    // mp11: list size and per-type iteration.
    {
        using L = boost::mp11::mp_list<int, long, char>;
        ok = ok && boost::mp11::mp_size<L>::value == 3;

        int total = 0;
        boost::mp11::mp_for_each<L>([&](auto t) { total += sizeof(decltype(t)); });
        ok = ok && total > 0 && total >= 3;
    }

    // describe: enumerate (name, value) pairs without RTTI tricks.
    {
        int count = 0;
        bool blueNamed = false;
        boost::mp11::mp_for_each<boost::describe::describe_enumerators<Color>>(
            [&](auto d) {
                ++count;
                if (d.value == Color::blue)
                    blueNamed = std::string(d.name) == "blue";
            });
        ok = ok && count == 3 && blueNamed;
    }

    // preprocessor: stringize/cat composition and unrolled repetition.
    {
        ok = ok && std::string(BOOST_PP_STRINGIZE(BOOST_PP_CAT(fo, o))) == "foo";

        int total = BOOST_PP_REPEAT(5, FAMILY_INC, 0);  // + 0 + 1 + 2 + 3 + 4
        ok = ok && total == 10;
    }

    // type-index: runtime type identity with a readable name.
    {
        namespace ti = boost::typeindex;
        ok = ok && ti::type_id<int>() == ti::type_id<int>();
        ok = ok && ti::type_id<int>() != ti::type_id<long>();
        ok = ok && std::string(ti::type_id<int>().pretty_name()).find("int") !=
                        std::string::npos;
    }

    // predef: the platform and compiler we run the index's CI on must be
    // detected (predef defines every macro, 0 when not detected).
    {
        ok = ok && (BOOST_OS_LINUX || BOOST_OS_MACOS || BOOST_OS_WINDOWS) != 0;
        ok = ok && (BOOST_COMP_CLANG || BOOST_COMP_GNUC || BOOST_COMP_MSVC) != 0;
    }

    return ok ? 0 : 1;
}
