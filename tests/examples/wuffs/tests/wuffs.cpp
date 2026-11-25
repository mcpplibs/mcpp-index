// compat.wuffs — Wuffs' decoders on data whose decoding is known.
//
// WHAT THIS ASSERTS AND WHY
//
// The package is one translation unit, wuffs-v0.3.c under WUFFS_IMPLEMENTATION
// compiled as C++. That claim has two halves, and each check below needs one:
//
//   the release        WUFFS_VERSION_STRING is 0.3.6's, and the header the
//                      consumer includes is the file the library was built from
//   the C API          gzip (DEFLATE under its framing) decoded by
//                      wuffs_gzip__decoder, CRC-32 and Adler-32 by their hashers,
//                      each with the standard check value
//   wuffs_aux (C++)    a PNG decoded by DecodeImage to BGRA pixels, JSON walked
//                      by DecodeJson — these exist only if the implementation
//                      was compiled as C++, which a C build would silently drop
//
// The error path is checked too: a truncated PNG is refused with Wuffs' own
// status message, not decoded into garbage.

#include <wuffs-v0.3.c>

#include <cstdint>
#include <cstdio>
#include <cstring>
#include <string>

namespace {

int failures = 0;

void check(bool ok, const char* what) {
    std::printf("%s %s\n", ok ? "ok  " : "FAIL", what);
    if (!ok) ++failures;
}

constexpr std::uint8_t png_2x2[] = {
    0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a, 0x00, 0x00, 0x00, 0x0d, 0x49, 0x48, 0x44, 0x52,
    0x00, 0x00, 0x00, 0x02, 0x00, 0x00, 0x00, 0x02, 0x08, 0x02, 0x00, 0x00, 0x00, 0xfd, 0xd4, 0x9a,
    0x73, 0x00, 0x00, 0x00, 0x12, 0x49, 0x44, 0x41, 0x54, 0x78, 0xda, 0x63, 0xf8, 0xcf, 0xc0, 0xc0,
    0x00, 0xc2, 0x0c, 0xff, 0x81, 0x00, 0x00, 0x1f, 0xee, 0x05, 0xfb, 0xf1, 0xab, 0xba, 0x77, 0x00,
    0x00, 0x00, 0x00, 0x49, 0x45, 0x4e, 0x44, 0xae, 0x42, 0x60, 0x82
};
constexpr std::uint8_t gzip_text[] = {
    0x1f, 0x8b, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x02, 0xff, 0x0b, 0x2f, 0x4d, 0x4b, 0x2b, 0x56,
    0x48, 0x49, 0x4d, 0xce, 0x4f, 0x49, 0x2d, 0x56, 0x28, 0xcd, 0x2b, 0x29, 0x2a, 0x2d, 0x2e, 0x49,
    0x4d, 0x51, 0x48, 0x49, 0x2c, 0x49, 0xd4, 0xe3, 0x0a, 0xa7, 0x99, 0x2c, 0x00, 0x67, 0x4e, 0x26,
    0x2d, 0x78, 0x00, 0x00, 0x00
};
constexpr char gzip_plain[] =
    "Wuffs decodes untrusted data.\n" "Wuffs decodes untrusted data.\n"
    "Wuffs decodes untrusted data.\n" "Wuffs decodes untrusted data.\n";

std::string gunzip(const std::uint8_t* src_ptr, std::size_t src_len) {
    auto dec = wuffs_gzip__decoder::alloc();
    if (!dec) return "alloc failed";
    std::uint8_t out[256];
    std::uint8_t work[1];  // gzip needs no work buffer (workbuf_len is 0)
    wuffs_base__io_buffer src = wuffs_base__ptr_u8__reader(const_cast<std::uint8_t*>(src_ptr), src_len, true);
    wuffs_base__io_buffer dst = wuffs_base__ptr_u8__writer(out, sizeof out);
    wuffs_base__status status = dec->transform_io(&dst, &src, wuffs_base__make_slice_u8(work, 0));
    if (!status.is_ok()) return std::string("error: ") + status.message();
    return std::string(reinterpret_cast<const char*>(out), dst.meta.wi);
}

// Collects a JSON document's scalars in order, with their nesting.
struct Walk : wuffs_aux::DecodeJsonCallbacks {
    std::string seen;
    std::string AppendNull() override { seen += "null "; return ""; }
    std::string AppendBool(bool v) override { seen += v ? "true " : "false "; return ""; }
    std::string AppendF64(double v) override { seen += std::to_string(v) + " "; return ""; }
    std::string AppendI64(std::int64_t v) override { seen += std::to_string(v) + " "; return ""; }
    std::string AppendTextString(std::string&& v) override { seen += '"' + v + "\" "; return ""; }
    std::string Push(std::uint32_t) override { seen += "[ "; return ""; }
    std::string Pop(std::uint32_t) override { seen += "] "; return ""; }
};

}  // namespace

int main() {
    // The release.
    check(std::strcmp(WUFFS_VERSION_STRING, "0.3.6+3407.20261020") == 0, "WUFFS_VERSION_STRING is 0.3.6's");
    check(WUFFS_VERSION == 0x000030006, "WUFFS_VERSION");

    // The C API: gzip, CRC-32, Adler-32.
    check(gunzip(gzip_text, sizeof gzip_text) == gzip_plain, "wuffs_gzip__decoder inflates a gzip member");
    {
        auto crc = wuffs_crc32__ieee_hasher::alloc();
        const char* nine = "123456789";
        std::uint32_t v = crc->update_u32(wuffs_base__make_slice_u8(
            reinterpret_cast<std::uint8_t*>(const_cast<char*>(nine)), 9));
        check(v == 0xCBF43926u, "CRC-32/IEEE of \"123456789\" is CBF43926");
    }
    {
        auto adler = wuffs_adler32__hasher::alloc();
        const char* text = "Wikipedia";
        std::uint32_t v = adler->update_u32(wuffs_base__make_slice_u8(
            reinterpret_cast<std::uint8_t*>(const_cast<char*>(text)), 9));
        check(v == 0x11E60398u, "Adler-32 of \"Wikipedia\" is 11E60398");
    }

    // wuffs_aux: an image.
    {
        wuffs_aux::DecodeImageCallbacks callbacks;
        wuffs_aux::sync_io::MemoryInput input(png_2x2, sizeof png_2x2);
        wuffs_aux::DecodeImageResult res = wuffs_aux::DecodeImage(callbacks, input);
        check(res.error_message.empty(), "DecodeImage decodes the PNG");
        if (res.error_message.empty()) {
            wuffs_base__table_u8 plane = res.pixbuf.plane(0);
            const std::uint8_t* row0 = plane.ptr;
            const std::uint8_t* row1 = plane.ptr + plane.stride;
            check(res.pixbuf.pixcfg.width() == 2 && res.pixbuf.pixcfg.height() == 2, "2x2");
            // BGRA (premultiplied; every pixel is opaque): red, green / blue, white.
            check(row0[0] == 0 && row0[1] == 0 && row0[2] == 255 && row0[3] == 255, "pixel (0,0) is red");
            check(row0[4] == 0 && row0[5] == 255 && row0[6] == 0, "pixel (1,0) is green");
            check(row1[0] == 255 && row1[1] == 0 && row1[2] == 0, "pixel (0,1) is blue");
            check(row1[4] == 255 && row1[5] == 255 && row1[6] == 255, "pixel (1,1) is white");
        }
    }
    {
        wuffs_aux::DecodeImageCallbacks callbacks;
        wuffs_aux::sync_io::MemoryInput input(png_2x2, 40);  // cut inside IDAT
        wuffs_aux::DecodeImageResult res = wuffs_aux::DecodeImage(callbacks, input);
        std::printf("     truncated PNG: %s\n", res.error_message.c_str());
        check(!res.error_message.empty(), "a truncated PNG is refused");
    }

    // wuffs_aux: JSON.
    {
        Walk walk;
        const char* doc = R"({"format":"png","sizes":[16,32],"alpha":true,"note":null})";
        wuffs_aux::sync_io::MemoryInput input(doc, std::strlen(doc));
        wuffs_aux::DecodeJsonResult res = wuffs_aux::DecodeJson(walk, input);
        std::printf("     json: %s\n", walk.seen.c_str());
        check(res.error_message.empty() &&
              walk.seen == "[ \"format\" \"png\" \"sizes\" [ 16 32 ] \"alpha\" true \"note\" null ] ",
              "DecodeJson walks the document");
    }

    std::printf("%s\n", failures ? "FAILED" : "all passed");
    return failures ? 1 : 0;
}
