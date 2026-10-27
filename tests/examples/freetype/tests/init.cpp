// Smoke test — verify compat.freetype builds, links, and basic API works,
// including the base extensions every distribution builds (ftstroke.c,
// ftgasp.c, fttype1.c, ftbdf.c, ftcid.c, ftpfr.c, ftwinfnt.c, ftfstype.c,
// ftpatent.c, ftgxval.c, ftotval.c, ftbzip2.c): each is called once.
#include <ft2build.h>
#include FT_FREETYPE_H
#include FT_STROKER_H
#include FT_GASP_H
#include FT_TYPE1_TABLES_H
#include FT_BDF_H
#include FT_CID_H
#include FT_PFR_H
#include FT_WINFONTS_H
#include FT_GX_VALIDATE_H
#include FT_OPENTYPE_VALIDATE_H
#include FT_BZIP2_H
import std;

int main() {
    FT_Library library{};
    FT_Error error = FT_Init_FreeType(&library);
    if (error) {
        std::println("FT_Init_FreeType failed: {}", error);
        return 1;
    }
    int failures = 0;
    auto expect = [&](bool ok, std::string_view what) {
        if (!ok) {
            std::println("FAIL: {}", what);
            ++failures;
        }
    };

    // ftstroke.c: a stroker strokes a two-point path into a closed border.
    FT_Stroker stroker{};
    expect(FT_Stroker_New(library, &stroker) == FT_Err_Ok, "FT_Stroker_New");
    FT_Stroker_Set(stroker, 64, FT_STROKER_LINECAP_ROUND, FT_STROKER_LINEJOIN_ROUND, 0);
    FT_Vector from{0, 0}, to{640, 0};
    expect(FT_Stroker_BeginSubPath(stroker, &from, 0) == FT_Err_Ok, "FT_Stroker_BeginSubPath");
    expect(FT_Stroker_LineTo(stroker, &to) == FT_Err_Ok, "FT_Stroker_LineTo");
    expect(FT_Stroker_EndSubPath(stroker) == FT_Err_Ok, "FT_Stroker_EndSubPath");
    FT_UInt points = 0, contours = 0;
    expect(FT_Stroker_GetCounts(stroker, &points, &contours) == FT_Err_Ok && points > 0 && contours > 0,
           "FT_Stroker_GetCounts");
    FT_Stroker_Done(stroker);

    // The face-level extensions reject a null face rather than failing to link.
    FT_Face none = nullptr;
    expect(FT_Get_Gasp(none, 12) == FT_GASP_NO_TABLE, "FT_Get_Gasp");
    expect(FT_Get_FSType_Flags(none) == 0, "FT_Get_FSType_Flags");
    expect(FT_Has_PS_Glyph_Names(none) == 0, "FT_Has_PS_Glyph_Names");
    PS_FontInfoRec info{};
    expect(FT_Get_PS_Font_Info(none, &info) == FT_Err_Invalid_Face_Handle, "FT_Get_PS_Font_Info");
    const char *encoding = nullptr, *registry = nullptr;
    expect(FT_Get_BDF_Charset_ID(none, &encoding, &registry) == FT_Err_Invalid_Face_Handle, "FT_Get_BDF_Charset_ID");
    FT_Bool cid_keyed = 0;
    expect(FT_Get_CID_Is_Internally_CID_Keyed(none, &cid_keyed) == FT_Err_Invalid_Argument,
           "FT_Get_CID_Is_Internally_CID_Keyed");
    FT_UInt outline_resolution = 0, metrics_resolution = 0;
    expect(FT_Get_PFR_Metrics(none, &outline_resolution, &metrics_resolution, nullptr, nullptr) ==
               FT_Err_Invalid_Face_Handle,
           "FT_Get_PFR_Metrics");
    FT_WinFNT_HeaderRec header{};
    expect(FT_Get_WinFNT_Header(none, &header) == FT_Err_Invalid_Face_Handle, "FT_Get_WinFNT_Header");
    expect(FT_Face_CheckTrueTypePatents(none) == 0, "FT_Face_CheckTrueTypePatents");
    FT_Bytes tables[FT_VALIDATE_GX_LENGTH]{};
    expect(FT_TrueTypeGX_Validate(none, FT_VALIDATE_GX, tables, FT_VALIDATE_GX_LENGTH) != FT_Err_Ok,
           "FT_TrueTypeGX_Validate");
    FT_Bytes base{}, gdef{}, gpos{}, gsub{}, jstf{};
    expect(FT_OpenType_Validate(none, FT_VALIDATE_OT, &base, &gdef, &gpos, &gsub, &jstf) != FT_Err_Ok,
           "FT_OpenType_Validate");

    // ftbzip2.c without libbz2: the entry point exists and says so.
    FT_StreamRec stream{}, source{};
    expect(FT_Stream_OpenBzip2(&stream, &source) == FT_Err_Unimplemented_Feature, "FT_Stream_OpenBzip2");

    FT_Done_FreeType(library);
    if (failures)
        return 1;
    std::println("compat.freetype smoke test: ok");
    return 0;
}
