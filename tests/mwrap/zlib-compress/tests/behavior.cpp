// The installed zlib wrapper: one call each way, the published CRC-32, and a
// gzip file written and read back.
import std;
import mcpplibs.mwrap.zlib;

namespace z = mcpplibs::mwrap::zlib::macros;

int main() {
    std::string text;
    for (int i = 0; i < 300; ++i) text += std::format("row {} of a table\n", i % 11);
    const auto* bytes = reinterpret_cast<const Bytef*>(text.data());
    std::vector<Bytef> packed(compressBound(text.size()));
    uLongf size = packed.size();
    if (compress2(packed.data(), &size, bytes, text.size(), z::Z_BEST_COMPRESSION) != z::Z_OK) return 1;
    std::string back(text.size(), '\0');
    uLongf back_size = back.size();
    if (uncompress(reinterpret_cast<Bytef*>(back.data()), &back_size, packed.data(), size) != z::Z_OK || back != text) return 2;
    if (crc32(0, reinterpret_cast<const Bytef*>("123456789"), 9) != 0xCBF43926u) return 3;
    const auto path = (std::filesystem::temp_directory_path() / "zlib-compress-member.gz").string();
    gzFile out = gzopen(path.c_str(), "wb");
    if (!out || gzputs(out, "gzip through a module\n") < 0 || gzclose(out) != z::Z_OK) return 4;
    gzFile in = gzopen(path.c_str(), "rb");
    char line[64] = {};
    const bool read = in && gzgets(in, line, sizeof line) && std::string_view(line) == "gzip through a module\n";
    if (in) gzclose(in);
    std::filesystem::remove(path);
    std::println("zlib {}: {} -> {} bytes", zlibVersion(), text.size(), size);
    return read ? 0 : 5;
}
