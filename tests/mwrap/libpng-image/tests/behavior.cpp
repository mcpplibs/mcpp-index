#include <csetjmp>  // setjmp, for png_jmpbuf

import std;
import mcpplibs.mwrap.libpng;

using namespace mcpplibs::mwrap::libpng::macros;

namespace {
struct Source {
    const png_byte* data;
    std::size_t size, at = 0;
};
void read_from(png_structp png, png_bytep out, std::size_t n) {
    auto* s = static_cast<Source*>(png_get_io_ptr(png));
    if (s->at + n > s->size) png_error(png, "truncated");
    std::memcpy(out, s->data + s->at, n);
    s->at += n;
}
// Expand to RGBA and read every row; png_error longjmps back here.
int read_rgba(png_structp png, png_infop info, png_bytep rows, png_uint_32 stride) {
    if (setjmp(png_jmpbuf(png))) return -1;
    png_read_info(png, info);
    png_set_expand(png);
    png_set_filler(png, 0xff, PNG_FILLER_AFTER);
    png_read_update_info(png, info);
    for (png_uint_32 y = 0; y < png_get_image_height(png, info); ++y) png_read_row(png, rows + y * stride, nullptr);
    png_read_end(png, nullptr);
    return 0;
}
}  // namespace

int main() {
    static_assert(PNG_SIMPLIFIED_READ_SUPPORTED && PNG_SETJMP_SUPPORTED && PNG_LIBPNG_VER == 10643);
    // A grey ramp written with the simplified API, to memory.
    constexpr png_uint_32 w = 9, h = 4;
    png_image image{};
    image.version = PNG_IMAGE_VERSION;
    image.width = w;
    image.height = h;
    image.format = PNG_FORMAT_GRAY;
    std::vector<png_byte> grey(PNG_IMAGE_SIZE(image));
    for (std::size_t i = 0; i < grey.size(); ++i) grey[i] = static_cast<png_byte>(i * 7);
    png_alloc_size_t size = 0;
    if (!png_image_write_get_memory_size(image, size, 0, grey.data(), 0, nullptr)) return 1;
    std::vector<png_byte> file(size);
    if (!png_image_write_to_memory(&image, file.data(), &size, 0, grey.data(), 0, nullptr)) return 2;
    if (!png_check_sig(file.data(), 8)) return 3;
    // Read it back with the low-level reader, expanded to RGBA.
    std::vector<png_byte> rgba(w * h * 4);
    Source source{file.data(), size};
    png_structp png = png_create_read_struct(PNG_LIBPNG_VER_STRING, nullptr, nullptr, nullptr);
    png_infop info = png_create_info_struct(png);
    png_set_read_fn(png, &source, read_from);
    png_set_gray_to_rgb(png);
    const int status = read_rgba(png, info, rgba.data(), w * 4);
    png_destroy_read_struct(&png, &info, nullptr);
    if (status != 0) return 4;
    for (std::size_t p = 0; p < grey.size(); ++p)
        if (rgba[p * 4] != grey[p] || rgba[p * 4 + 2] != grey[p] || rgba[p * 4 + 3] != 255) return 5;
    // A truncated file: png_error in the read callback, longjmp to read_rgba.
    Source cut{file.data(), size / 2};
    png = png_create_read_struct(PNG_LIBPNG_VER_STRING, nullptr, nullptr, nullptr);
    info = png_create_info_struct(png);
    png_set_read_fn(png, &cut, read_from);
    const int failed = read_rgba(png, info, rgba.data(), w * 4);
    png_destroy_read_struct(&png, &info, nullptr);
    if (failed != -1) return 6;
    std::println("libpng-image: ok (libpng {}, {} bytes for {}x{})", png_libpng_ver, size, w, h);
    return 0;
}
