// boost-io (stream state savers), boost-utility (compressed_pair) and
// boost-winapi (WinAPI type shims — compilable only where Win32 exists).
#include <boost/compressed_pair.hpp>
#include <boost/io/ios_state.hpp>

#include <sstream>
#include <string>
#include <type_traits>

#ifdef _WIN32
#include <boost/winapi/basic_types.hpp>
#endif

int main() {
    bool ok = true;

    // io: RAII flag saver restores the stream's formatting state.
    {
        std::ostringstream os;
        os << 255;
        ok = ok && os.str() == "255";

        os.str("");
        {
            boost::io::ios_flags_saver fs(os);
            os << std::hex << 255;
            ok = ok && os.str() == "ff";
        }

        os.str("");
        os << 255;
        ok = ok && os.str() == "255";  // hex did not leak
    }

    // utility: compressed_pair — empty-base-optimized pair with accessors.
    {
        boost::compressed_pair<int, std::string> cp(3, "three");
        ok = ok && cp.first() == 3 && cp.second() == "three";

        // Both members empty: compiles and stays stateless in practice.
        struct Nothing {};
        boost::compressed_pair<Nothing, Nothing> empty_pair{};
        ok = ok && sizeof(empty_pair) <= sizeof(Nothing) * 2;
    }

    // winapi: the shims declare the Win32 surface themselves, but the
    // headers are Windows-only to compile (they #error elsewhere), so real
    // assertions run under the Windows CI leg only.
    {
#ifdef _WIN32
        ok = ok && std::is_pointer<boost::winapi::HANDLE_>::value;
        ok = ok && std::is_integral<boost::winapi::DWORD_>::value;
        ok = ok && sizeof(boost::winapi::DWORD_) >= 4;
#endif
    }

    return ok ? 0 : 1;
}
