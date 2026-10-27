import std;
import mcpplibs.mwrap.freetype;

using namespace mcpplibs::mwrap::freetype::macros;

namespace {
// A one-glyph BDF font: FreeType's BDF driver parses it from memory.
constexpr std::string_view bdf = R"(STARTFONT 2.1
FONT -mcpp-index-Medium-R-Normal--8-80-75-75-C-80-ISO10646-1
SIZE 8 75 75
FONTBOUNDINGBOX 8 8 0 -1
STARTPROPERTIES 2
FONT_ASCENT 7
FONT_DESCENT 1
ENDPROPERTIES
CHARS 1
STARTCHAR A
ENCODING 65
SWIDTH 500 0
DWIDTH 8 0
BBX 8 8 0 -1
BITMAP
18
24
42
42
7E
42
42
00
ENDCHAR
ENDFONT
)";

int failures = 0;
void expect(bool ok, std::string_view what) {
    if (!ok) {
        std::println("FAIL: {}", what);
        ++failures;
    }
}
}  // namespace

static_assert(FREETYPE_MAJOR == 2 && FREETYPE_MINOR == 13 && FREETYPE_PATCH == 3);
static_assert(FT_MAKE_TAG('g', 'l', 'y', 'f') == TTAG_glyf);
static_assert(FT_LOAD_TARGET_MODE(FT_LOAD_TARGET_LCD) == FT_RENDER_MODE_LCD);
static_assert(FT_CURVE_TAG(FT_CURVE_TAG_CUBIC | 0x10) == FT_CURVE_TAG_CUBIC);
static_assert(FT_ERROR_BASE(FT_Err_Invalid_Argument) == 0x06);

int main() {
    FT_Library lib{};
    if (FT_Init_FreeType(&lib) != FT_Err_Ok) return 1;
    FT_Int major = 0, minor = 0, patch = 0;
    FT_Library_Version(lib, &major, &minor, &patch);
    expect(major == 2 && minor == 13 && patch == 3, "FT_Library_Version");

    // A bitmap font from memory, its properties and its glyph.
    FT_Face face{};
    expect(FT_New_Memory_Face(lib, reinterpret_cast<const FT_Byte*>(bdf.data()), static_cast<FT_Long>(bdf.size()), 0,
                              &face) == FT_Err_Ok,
           "FT_New_Memory_Face (BDF)");
    if (face) {
        expect(std::string_view(FT_Get_Font_Format(face)) == "BDF", "FT_Get_Font_Format");
        expect(FT_HAS_FIXED_SIZES(face) && !FT_IS_SCALABLE(face), "FT_HAS_FIXED_SIZES");
        BDF_PropertyRec ascent{};
        expect(FT_Get_BDF_Property(face, "FONT_ASCENT", &ascent) == FT_Err_Ok && ascent.u.integer == 7,
               "FT_Get_BDF_Property");
        expect(FT_Select_Size(face, 0) == FT_Err_Ok, "FT_Select_Size");
        expect(FT_Load_Char(face, 'A', FT_LOAD_RENDER) == FT_Err_Ok, "FT_Load_Char");
        const FT_Bitmap& b = face->glyph->bitmap;
        expect(b.pixel_mode == FT_PIXEL_MODE_MONO && b.width == 8 && b.rows == 8, "the glyph bitmap");
        expect(b.buffer[0] == 0x18 && b.buffer[4 * b.pitch] == 0x7E, "the glyph's rows");
        FT_Done_Face(face);
    }

    // FreeType's src/tools/test_bbox.c outline #3: its exact box is [0 100 128 128].
    FT_Vector points[4] = {{100 << 16, 127 << 16}, {200 << 16, 127 << 16}, {0, 136 << 16}, {0, 100 << 16}};
    unsigned char tags[4] = {FT_CURVE_TAG_ON, FT_CURVE_TAG_CUBIC, FT_CURVE_TAG_CUBIC, FT_CURVE_TAG_ON};
    unsigned short contours[1] = {3};
    FT_Outline cubic{1, 4, points, tags, contours, FT_OUTLINE_NONE};
    FT_BBox box{};
    expect(FT_Outline_Get_BBox(&cubic, &box) == FT_Err_Ok, "FT_Outline_Get_BBox");
    expect(box.xMin == 0 && box.yMin == 100 << 16 && std::abs(box.xMax - (128 << 16)) <= 1 &&
               std::abs(box.yMax - (128 << 16)) <= 1,
           "the exact box of a cubic");

    // A square stroked 2 px wide, rasterised into a caller's bitmap.
    FT_Vector square[4] = {{4 * 64, 4 * 64}, {12 * 64, 4 * 64}, {12 * 64, 12 * 64}, {4 * 64, 12 * 64}};
    unsigned char on[4] = {FT_CURVE_TAG_ON, FT_CURVE_TAG_ON, FT_CURVE_TAG_ON, FT_CURVE_TAG_ON};
    FT_Outline path{1, 4, square, on, contours, FT_OUTLINE_NONE};
    FT_Stroker stroker{};
    expect(FT_Stroker_New(lib, &stroker) == FT_Err_Ok, "FT_Stroker_New");
    FT_Stroker_Set(stroker, 64, FT_STROKER_LINECAP_BUTT, FT_STROKER_LINEJOIN_MITER, 4 << 16);
    expect(FT_Stroker_ParseOutline(stroker, &path, 0) == FT_Err_Ok, "FT_Stroker_ParseOutline");
    FT_UInt n_points = 0, n_contours = 0;
    FT_Stroker_GetCounts(stroker, &n_points, &n_contours);
    FT_Outline ring{};
    expect(FT_Outline_New(lib, n_points, n_contours, &ring) == FT_Err_Ok, "FT_Outline_New");
    ring.n_points = ring.n_contours = 0;
    FT_Stroker_Export(stroker, &ring);
    FT_Stroker_Done(stroker);
    std::vector<unsigned char> pixels(16 * 16);
    FT_Bitmap target{};
    target.rows = target.width = 16;
    target.pitch = 16;
    target.buffer = pixels.data();
    target.num_grays = 256;
    target.pixel_mode = FT_PIXEL_MODE_GRAY;
    expect(FT_Outline_Get_Bitmap(lib, &ring, &target) == FT_Err_Ok, "FT_Outline_Get_Bitmap");
    FT_Outline_Done(lib, &ring);
    // The ring covers 10 x 10 minus the 6 x 6 hole: 64 pixels.
    long covered = std::ranges::count(pixels, 255);
    expect(covered == 64, std::format("a 2 px ring around an 8 px square covers 64 px, not {}", covered));
    expect(pixels[8 * 16 + 8] == 0, "the hole");

    FT_Done_FreeType(lib);
    if (failures) return 1;
    std::println("mcpplibs.mwrap.freetype: a BDF glyph rendered, an exact cubic box, a stroked ring rasterised");
    return 0;
}
