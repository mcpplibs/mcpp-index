// compat.zlib-ng: zlib's interface, madler's streams, and agreement between the
// library and its consumer.
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

// The text Python's zlib 1.3.1 compressed at level 6 into `known' below.
std::string shard_text() {
    std::string text;
    char line[96];
    for (int i = 0; i < 64; ++i) {
        std::snprintf(line, sizeof line, "shard %05d: the engine's index of src/main.cpp, symbol table and refs\n", i);
        text += line;
    }
    return text;
}

const unsigned char known[] = {
    0x78, 0x9c, 0xad, 0xd2, 0xb9, 0x8d, 0x02, 0x41, 0x14, 0x00, 0x51, 0x9f, 0x28, 0xbe, 0x87, 0x83,
    0x80, 0x7f, 0x35, 0x47, 0x36, 0x03, 0xd3, 0xc0, 0x48, 0xd0, 0xa0, 0x69, 0x0c, 0x36, 0xfb, 0xd5,
    0x3a, 0x9b, 0x00, 0x55, 0x01, 0x94, 0xf5, 0xfa, 0x6d, 0x98, 0x47, 0xd9, 0xfe, 0x75, 0x94, 0xf7,
    0xad, 0x4a, 0x6d, 0xd7, 0xa9, 0xd5, 0x65, 0x97, 0xa9, 0x8d, 0xf5, 0x23, 0xcf, 0x8b, 0xf4, 0xf9,
    0xbc, 0x79, 0x0c, 0x53, 0x5b, 0x9f, 0x5f, 0xaf, 0x95, 0xf4, 0x9f, 0xc7, 0xe9, 0x79, 0x97, 0xf7,
    0x70, 0xba, 0x57, 0x19, 0xda, 0x28, 0x73, 0xbd, 0xf4, 0x45, 0xff, 0xdf, 0x28, 0xb3, 0x31, 0x66,
    0xe3, 0xcc, 0x26, 0x98, 0x4d, 0x32, 0x9b, 0xc2, 0x6c, 0x76, 0xcc, 0x66, 0xcf, 0x6c, 0x0e, 0xc8,
    0x46, 0x19, 0xc5, 0xca, 0x28, 0x56, 0x46, 0xb1, 0x32, 0x8a, 0x95, 0x51, 0xac, 0x8c, 0x62, 0x65,
    0x14, 0x2b, 0xa3, 0x58, 0x19, 0xc5, 0xca, 0x28, 0x36, 0x46, 0xb1, 0x31, 0x8a, 0x8d, 0x51, 0x6c,
    0x8c, 0x62, 0x63, 0x14, 0x1b, 0xa3, 0xd8, 0x18, 0xc5, 0xc6, 0x28, 0x36, 0x46, 0xb1, 0x31, 0x8a,
    0x9d, 0x51, 0xec, 0x8c, 0x62, 0x67, 0x14, 0x3b, 0xa3, 0xd8, 0x19, 0xc5, 0xce, 0x28, 0x76, 0x46,
    0xb1, 0x33, 0x8a, 0x9d, 0x51, 0xec, 0x8c, 0xe2, 0x60, 0x14, 0x07, 0xa3, 0x38, 0x18, 0xc5, 0xc1,
    0x28, 0x0e, 0x46, 0x71, 0x30, 0x8a, 0x83, 0x51, 0x1c, 0x8c, 0xe2, 0x60, 0x14, 0x07, 0xa3, 0x38,
    0x19, 0xc5, 0xc9, 0x28, 0x4e, 0x46, 0x71, 0x32, 0x8a, 0x93, 0x51, 0x9c, 0x8c, 0xe2, 0x64, 0x14,
    0x27, 0xa3, 0x38, 0x19, 0xc5, 0xc9, 0x28, 0x2e, 0x8c, 0xe2, 0xc2, 0x28, 0x2e, 0x8c, 0xe2, 0xf2,
    0x95, 0xe2, 0x5f, 0x40, 0xad, 0x01, 0x9d
};

// Bytes that compress neither to nothing nor not at all: runs, repeats at
// varying distances and noise, so inflate copies matches of every length the
// vector paths handle (chunkmemset) and literals between them.
std::string mixed(std::size_t size) {
    std::string out;
    out.reserve(size);
    unsigned state = 2463534242u;
    while (out.size() < size) {
        state ^= state << 13; state ^= state >> 17; state ^= state << 5;
        const unsigned kind = state % 4;
        if (kind == 0) out.append(1 + state % 300, static_cast<char>('a' + state % 26));
        else if (kind == 1 && out.size() > 64) {
            const std::size_t distance = 1 + (state >> 8) % (out.size() < 32768 ? out.size() : 32768);
            const std::size_t length = 3 + (state >> 4) % 258;
            for (std::size_t i = 0; i < length; ++i) out.push_back(out[out.size() - distance]);
        } else out.push_back(static_cast<char>(state >> 24));
    }
    out.resize(size);
    return out;
}

bool round_trip(const std::string& text, int level) {
    uLongf bound = compressBound(static_cast<uLong>(text.size()));
    std::string packed(bound, '\0');
    if (compress2(reinterpret_cast<Bytef*>(packed.data()), &bound,
                  reinterpret_cast<const Bytef*>(text.data()), static_cast<uLong>(text.size()), level) != Z_OK)
        return false;
    std::string unpacked(text.size(), '\0');
    uLongf size = static_cast<uLongf>(unpacked.size());
    return uncompress(reinterpret_cast<Bytef*>(unpacked.data()), &size,
                      reinterpret_cast<const Bytef*>(packed.data()), bound) == Z_OK
           && size == text.size() && unpacked == text;
}

}  // namespace

int main() {
    check(library_off_t_size() == sizeof(z_off_t),
          "the library and this consumer agree on the width of z_off_t");
    check(std::strstr(zlibVersion(), "zlib-ng") != nullptr && std::strcmp(zlibVersion(), ZLIB_VERSION) == 0,
          "the library is zlib-ng, of the version its header names");

    const std::string text = shard_text();
    std::string unpacked(text.size(), '\0');
    uLongf size = static_cast<uLongf>(unpacked.size());
    check(uncompress(reinterpret_cast<Bytef*>(unpacked.data()), &size, known, sizeof known) == Z_OK
              && size == text.size() && unpacked == text,
          "a stream madler's zlib wrote decompresses to its text");

    check(adler32(1, reinterpret_cast<const Bytef*>("Wikipedia"), 9) == 0x11e60398ul,
          "adler32 of \"Wikipedia\" is 0x11e60398");
    check(crc32(0, reinterpret_cast<const Bytef*>("123456789"), 9) == 0xcbf43926ul,
          "crc32 of \"123456789\" is 0xcbf43926");
    check(adler32(1, reinterpret_cast<const Bytef*>(text.data()), static_cast<uInt>(text.size())) == 0x40ad019dul
              && crc32(0, reinterpret_cast<const Bytef*>(text.data()), static_cast<uInt>(text.size())) == 0xbea69a54ul,
          "and of the shard text, the values madler's zlib gives");

    const std::string data = mixed(1 << 20);
    for (int level : {1, 6, 9})
        check(round_trip(data, level), "a mebibyte of mixed bytes round-trips at levels 1, 6 and 9");
    check(round_trip(std::string(1 << 16, 'z'), 6), "and a run of one byte");
    check(round_trip(std::string(), 6), "and nothing");

    const char* name = "zlib-ng-test.gz";
    gzFile out = gzopen(name, "wb");
    check(out != nullptr, "a gz file is opened for writing");
    if (out) {
        check(gzwrite(out, data.data(), static_cast<unsigned>(data.size())) == static_cast<int>(data.size()),
              "the gz file is written");
        gzclose(out);
    }
    gzFile in = gzopen(name, "rb");
    check(in != nullptr, "the gz file is opened for reading");
    if (in) {
        std::string back(data.size(), '\0');
        check(gzread(in, back.data(), static_cast<unsigned>(back.size())) == static_cast<int>(data.size())
                  && back == data,
              "and reads back what was written");
        check(gzseek(in, 10, SEEK_SET) == 10 && gztell(in) == 10,
              "a gz file seeks and reports its offset through z_off_t");
        check(gzgetc(in) == static_cast<unsigned char>(data[10]), "and gzgetc reads the byte there");
        gzclose(in);
    }
    std::remove(name);

    if (failures == 0) std::printf("compat.zlib-ng: every observation held\n");
    return failures == 0 ? 0 : 1;
}
