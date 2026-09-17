// compat.zlib: behaviour, and agreement between the library and its consumer.
#include <zlib.h>

#include <cstdio>
#include <cstring>
#include <string>

namespace {

int failures = 0;

void check(bool held, const char* what) {
    if (!held) { std::printf("FAIL: %s\n", what); ++failures; }
}

// zlibCompileFlags() bits 6 and 7 state the size of z_off_t the library was
// compiled with: 0 is 2 bytes, 1 is 4, 2 is 8, 3 is another size.
unsigned long library_off_t_size() {
    switch ((zlibCompileFlags() >> 6) & 3u) {
        case 0: return 2;
        case 1: return 4;
        case 2: return 8;
        default: return 0;
    }
}

}  // namespace

int main() {
    check(library_off_t_size() == sizeof(z_off_t),
          "the library and this consumer agree on the width of z_off_t");

    const std::string text(4096, 'z');
    uLongf bound = compressBound(static_cast<uLong>(text.size()));
    std::string packed(bound, '\0');
    check(compress(reinterpret_cast<Bytef*>(packed.data()), &bound,
                   reinterpret_cast<const Bytef*>(text.data()),
                   static_cast<uLong>(text.size())) == Z_OK,
          "a buffer is compressed");
    std::string unpacked(text.size(), '\0');
    uLongf size = static_cast<uLongf>(unpacked.size());
    check(uncompress(reinterpret_cast<Bytef*>(unpacked.data()), &size,
                     reinterpret_cast<const Bytef*>(packed.data()), bound) == Z_OK
              && size == text.size() && unpacked == text,
          "and decompresses to what it was");

    const char* name = "zlib-test.gz";
    gzFile out = gzopen(name, "wb");
    check(out != nullptr, "a gz file is opened for writing");
    if (out) {
        check(gzwrite(out, text.data(), static_cast<unsigned>(text.size()))
                  == static_cast<int>(text.size()), "the gz file is written");
        gzclose(out);
    }
    gzFile in = gzopen(name, "rb");
    check(in != nullptr, "the gz file is opened for reading");
    if (in) {
        std::string back(text.size(), '\0');
        check(gzread(in, back.data(), static_cast<unsigned>(back.size()))
                  == static_cast<int>(text.size()) && back == text,
              "and reads back what was written");
        check(gzseek(in, 10, SEEK_SET) == 10 && gztell(in) == 10,
              "a gz file seeks and reports its offset through z_off_t");
        gzclose(in);
    }
    std::remove(name);

    if (failures == 0) std::printf("compat.zlib: every observation held\n");
    return failures == 0 ? 0 : 1;
}
