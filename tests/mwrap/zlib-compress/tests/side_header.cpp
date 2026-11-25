// The side header from the installed package, beside the import: inflateInit
// and deflateInit are macros that pass ZLIB_VERSION from the macros module.
#include <mwrap/zlib/macros.hpp>
import std;
import mcpplibs.mwrap.zlib;

namespace z = mcpplibs::mwrap::zlib::macros;

int main() {
    std::string text(5000, 'z');
    z_stream out{};
    if (deflateInit(&out, z::Z_DEFAULT_COMPRESSION) != z::Z_OK) return 1;
    std::vector<Bytef> packed(deflateBound(&out, text.size()));
    out.next_in = reinterpret_cast<Bytef*>(text.data());
    out.avail_in = static_cast<uInt>(text.size());
    out.next_out = packed.data();
    out.avail_out = static_cast<uInt>(packed.size());
    if (deflate(&out, z::Z_FINISH) != z::Z_STREAM_END) return 2;
    const auto packed_size = out.total_out;
    deflateEnd(&out);
    z_stream in{};
    if (inflateInit(&in) != z::Z_OK) return 3;
    std::string back(text.size(), '\0');
    in.next_in = packed.data();
    in.avail_in = static_cast<uInt>(packed_size);
    in.next_out = reinterpret_cast<Bytef*>(back.data());
    in.avail_out = static_cast<uInt>(back.size());
    const int rc = inflate(&in, z::Z_FINISH);
    inflateEnd(&in);
    return rc == z::Z_STREAM_END && back == text ? 0 : 4;
}
