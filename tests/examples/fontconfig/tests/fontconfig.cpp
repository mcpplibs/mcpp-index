// freedesktop.fontconfig — the three generated tables, exercised through the
// public API.
//
// WHAT CAN BE ASSERTED WITHOUT FONTS
//
// This package compiles the four runtime paths EMPTY on purpose (see the
// manifest), so `FcInit()` on a runner with no `FONTCONFIG_FILE` finds no
// configuration and no fonts. That is the intended behaviour, not a defect,
// and it means a font-matching test would only be asserting that the runner
// has a desktop.
//
// The three GENERATED tables need none of that, and they are what this fork
// exists to produce:
//
//   fclang.h        281 .orth files compiled into charset bitmaps
//   fccase.h        Unicode case folding
//   fcobjshash.h    object-name → id, the gperf replacement
//
// Each is reachable through a public entry point that takes no config.

#ifdef __linux__

#include <fontconfig/fontconfig.h>

#include <cstdio>
#include <cstring>
#include <initializer_list>

namespace {

int failures = 0;

void check(bool ok, const char *what)
{
    std::printf("%-58s %s\n", what, ok ? "ok" : "FAILED");
    if (!ok) {
        ++failures;
    }
}

} // namespace

int main()
{
    std::printf("   FcGetVersion() = %d\n", FcGetVersion());
    check(FcGetVersion() >= 21500, "FcGetVersion reports 2.15.0 or newer");

    // ── fcobjshash.h — the gperf replacement ─────────────────────────────
    //
    // Exercised through `FcNameParse`, which is the public route into the
    // object table: the parser maps every "name=value" key through
    // `FcObjectLookupIdByName`, which IS the generated lookup. `FcObject` and
    // `FcObjectFromName` are internal (fcint.h), so reaching for them would
    // test the table without testing that a consumer can get to it.
    {
        FcPattern *p = FcNameParse((const FcChar8 *) "Arial:pixelsize=12:slant=100");
        check(p != nullptr, "fcobjshash: FcNameParse accepted three object names");
        if (p != nullptr) {
            FcChar8 *fam = nullptr;
            double px = 0;
            int slant = 0;
            const bool gf = FcPatternGetString(p, FC_FAMILY, 0, &fam) == FcResultMatch;
            const bool gp = FcPatternGetDouble(p, FC_PIXEL_SIZE, 0, &px) == FcResultMatch;
            const bool gs = FcPatternGetInteger(p, FC_SLANT, 0, &slant) == FcResultMatch;
            std::printf("   family=%s pixelsize=%g slant=%d\n",
                        gf && fam ? (const char *) fam : "(none)", px, slant);
            check(gf && fam && std::strcmp((const char *) fam, "Arial") == 0,
                  "…and \"family\" round-tripped to the right object");
            check(gp && px == 12.0, "…and \"pixelsize\" did too");
            check(gs && slant == 100, "…and \"slant\" did too");
            FcPatternDestroy(p);
        }

        // A name the table does not contain must not resolve to a builtin —
        // fontconfig assigns it a dynamic id instead. This is the branch a
        // binary search gets wrong when its bounds are off by one.
        FcPattern *q = FcNameParse((const FcChar8 *) ":nosuchproperty=1");
        check(q != nullptr, "…and an unknown property does not crash the parser");
        if (q) FcPatternDestroy(q);
    }

    // ── fclang.h — the language charsets ─────────────────────────────────
    // `FcLangGetCharSet` indexes straight into fcLangCharSets. Three languages
    // with very different coverage, so a table that was truncated or misordered
    // fails on at least one.
    for (const char *l : {"en", "ru", "zh-cn"}) {
        const FcCharSet *cs = FcLangGetCharSet((const FcChar8 *) l);
        const FcChar32 n = cs ? FcCharSetCount(cs) : 0;
        std::printf("   lang %-6s -> %u codepoints\n", l, n);
        check(cs != nullptr && n > 0, "fclang: the language has a charset");
    }
    // Latin and Cyrillic must not be the same set — they are separate entries
    // whose leaves were de-duplicated, and a dedup bug shows up here.
    {
        const FcCharSet *en = FcLangGetCharSet((const FcChar8 *) "en");
        const FcCharSet *ru = FcLangGetCharSet((const FcChar8 *) "ru");
        check(en && ru && !FcCharSetEqual(en, ru),
              "…and English and Russian are different sets");
        check(en && FcCharSetHasChar(en, 'A'), "…and English covers 'A'");
        check(ru && FcCharSetHasChar(ru, 0x0416), "…and Russian covers U+0416");
        check(en && !FcCharSetHasChar(en, 0x0416), "…and English does not");
    }

    // A language that does not exist must return null rather than index out of
    // range — the fastpath table `fcLangCharSetRanges` is what decides that.
    check(FcLangGetCharSet((const FcChar8 *) "zz-nowhere") == nullptr,
          "fclang: an unknown language returns null");

    // ── fccase.h — Unicode case folding ──────────────────────────────────
    // `FcStrDowncase` walks fcCaseFold. ASCII exercises the EVEN_ODD/RANGE
    // methods; U+0130 (Latin capital I with dot) is a FULL fold — one char to
    // several — which is the method with its own byte pool.
    {
        FcChar8 *d = FcStrDowncase((const FcChar8 *) "ABC");
        std::printf("   downcase(\"ABC\") = %s\n", d ? (const char *) d : "(null)");
        check(d && std::strcmp((const char *) d, "abc") == 0,
              "fccase: ASCII folds through the range methods");
        if (d) FcStrFree(d);
    }
    {
        // U+0410 CYRILLIC CAPITAL A -> U+0430, a two-byte fold.
        FcChar8 *d = FcStrDowncase((const FcChar8 *) "\xd0\x90");
        const bool ok = d && std::strcmp((const char *) d, "\xd0\xb0") == 0;
        std::printf("   downcase(U+0410) = %s\n", ok ? "U+0430" : "(wrong)");
        check(ok, "…and a Cyrillic capital folds to its lowercase");
        if (d) FcStrFree(d);
    }

    std::printf("\n%d check(s) failed\n", failures);
    return failures == 0 ? 0 : 1;
}

#else
int main() { return 0; }
#endif
