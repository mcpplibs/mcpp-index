// compat.fribidi — the Unicode bidirectional algorithm, on text that needs it.
//
// WHAT THIS ASSERTS AND WHY
//
// The tables are the whole package. fribidi's seven `.tab.i` files encode the
// Unicode Character Database, and a build that compiled none of them would
// still link, still run, and quietly treat Arabic as left-to-right. So every
// check below asks the library a question whose answer is IN a table:
//
//   the Unicode version    fribidi-unicode-version.h, generated upstream
//   bidi character types   bidi-type.tab.i
//   base direction         the resolution algorithm over those types
//   visual reordering      UAX #9 itself, the reason pango needs this
//   mirroring              mirroring.tab.i — "(" becomes ")" in an RTL run
//   joining types          joining-type.tab.i, which shapes Arabic
//
// A pass here means the tarball's pre-generated tables really were compiled —
// the claim that lets this be a descriptor instead of a fork.

#ifdef __linux__

// ⚠️ WRAPPED IN extern "C". fribidi's public headers have no `extern "C"` of
// their own — measured, zero occurrences across fribidi.h and the fifteen
// headers it pulls — so a C++ translation unit mangles every declaration and
// the link fails naming symbols the library plainly contains. Same situation
// as compat.libseat in this index, and the same answer: the consumer wraps.
extern "C" {
#include <fribidi.h>
}

#include <cstdio>
#include <cstring>

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
    // ── 1. the version, and the Unicode version behind the tables ────────
    std::printf("   %s\n", fribidi_version_info);
    check(std::strstr(fribidi_version_info, "1.0.16") != nullptr,
          "fribidi_version_info names 1.0.16, as the descriptor does");
    std::printf("   Unicode %s\n", FRIBIDI_UNICODE_VERSION);
    check(FRIBIDI_UNICODE_VERSION[0] >= '1',
          "FRIBIDI_UNICODE_VERSION came from the generated header");

    // ── 2. bidi character types — bidi-type.tab.i ────────────────────────
    // 'a' is L (left-to-right). U+0627 ARABIC LETTER ALEF is AL (arabic
    // letter). U+05D0 HEBREW LETTER ALEF is R. Three different answers from
    // one table; a build with no table would give the same answer for all.
    const FriBidiCharType t_a   = fribidi_get_bidi_type(0x0061);
    const FriBidiCharType t_alef = fribidi_get_bidi_type(0x0627);
    const FriBidiCharType t_hebr = fribidi_get_bidi_type(0x05D0);
    std::printf("   types: 'a'=%s  U+0627=%s  U+05D0=%s\n",
                fribidi_get_bidi_type_name(t_a),
                fribidi_get_bidi_type_name(t_alef),
                fribidi_get_bidi_type_name(t_hebr));
    // There is no FRIBIDI_IS_LTR: the header offers FRIBIDI_IS_RTL and the
    // left-to-right case is its negation, which is the honest spelling anyway
    // because "not RTL" is what the algorithm actually decides.
    check(FRIBIDI_IS_LETTER(t_a) && !FRIBIDI_IS_RTL(t_a), "'a' is a left-to-right letter");
    check(FRIBIDI_IS_ARABIC(t_alef), "U+0627 ARABIC ALEF is an Arabic letter");
    check(FRIBIDI_IS_RTL(t_hebr) && !FRIBIDI_IS_ARABIC(t_hebr),
          "U+05D0 HEBREW ALEF is right-to-left but not Arabic");

    // ── 3. base direction of a paragraph ─────────────────────────────────
    // The algorithm scans for the first strong character. A Hebrew-initial
    // paragraph is RTL; a Latin-initial one is LTR. This is what pango calls
    // to decide which way a line runs.
    // ⚠️ fribidi_get_par_direction takes BIDI TYPES, not characters. Passing
    // code points compiles — FriBidiCharType and FriBidiChar are both 32-bit
    // unsigned — and returns a plausible wrong answer, which is why the check
    // below reads the types out of the table first.
    {
        const FriBidiChar rtl[] = {0x05D0, 0x0020, 0x0041};   // ALEF SPACE A
        FriBidiCharType types[3];
        fribidi_get_bidi_types(rtl, 3, types);
        check(FRIBIDI_IS_RTL(fribidi_get_par_direction(types, 3)),
              "a Hebrew-initial paragraph resolves to RTL");

        const FriBidiChar ltr[] = {0x0041, 0x0020, 0x05D0};   // A SPACE ALEF
        fribidi_get_bidi_types(ltr, 3, types);
        check(!FRIBIDI_IS_RTL(fribidi_get_par_direction(types, 3)),
              "…and a Latin-initial one to LTR");
    }

    // ── 4. reordering: the point of the library ──────────────────────────
    // "abc" + Hebrew "אבג" in logical order, in an RTL paragraph. UAX #9 puts
    // the Hebrew run first visually and REVERSES it, because Hebrew is stored
    // in logical order and drawn right to left.
    //
    // This is an INTERMEDIATE QUANTITY, not a rendered image: it says exactly
    // where the algorithm put each character, so a wrong answer points at the
    // reordering rather than at "the text looked odd".
    {
        FriBidiChar logical[] = {0x0061, 0x0062, 0x0063, 0x0020,
                                 0x05D0, 0x05D1, 0x05D2};   // "abc אבג"
        const FriBidiStrIndex len = 7;
        FriBidiCharType types[7];
        FriBidiBracketType brackets[7];
        FriBidiLevel levels[7];
        FriBidiChar visual[7];
        FriBidiParType par = FRIBIDI_PAR_RTL;

        fribidi_get_bidi_types(logical, len, types);
        fribidi_get_bracket_types(logical, len, types, brackets);
        const FriBidiLevel max = fribidi_get_par_embedding_levels_ex(
            types, brackets, len, &par, levels);
        check(max > 0, "fribidi_get_par_embedding_levels_ex resolved levels");

        std::memcpy(visual, logical, sizeof logical);
        FriBidiStrIndex map[7];
        for (FriBidiStrIndex i = 0; i < len; ++i) {
            map[i] = i;
        }
        // warn_unused_result: the return is the maximum level reached, and
        // ignoring it is a warning that CI treats as noise worth removing.
        const FriBidiLevel rmax = fribidi_reorder_line(
            FRIBIDI_FLAGS_DEFAULT, types, len, 0, par, levels, visual, map);
        check(rmax > 0, "fribidi_reorder_line reordered at least one level");

        std::printf("   visual order: ");
        for (FriBidiStrIndex i = 0; i < len; ++i) {
            std::printf("U+%04X ", visual[i]);
        }
        std::printf("\n");

        // In an RTL paragraph the Hebrew run comes first and is reversed:
        // U+05D2 U+05D1 U+05D0, then the space, then "abc" left to right.
        check(visual[0] == 0x05D2 && visual[1] == 0x05D1 && visual[2] == 0x05D0,
              "the Hebrew run is placed first and reversed");
        check(visual[4] == 0x0061 && visual[5] == 0x0062 && visual[6] == 0x0063,
              "…and the Latin run keeps its own order");
    }

    // ── 5. mirroring — mirroring.tab.i ───────────────────────────────────
    // In a right-to-left run, "(" must be DRAWN as ")". The glyph substitution
    // is a table lookup, and a build without the table returns the input.
    {
        FriBidiChar mirrored = 0;
        const bool got = fribidi_get_mirror_char(0x0028, &mirrored) != 0;
        std::printf("   mirror of '(' = U+%04X\n", mirrored);
        check(got && mirrored == 0x0029, "'(' mirrors to ')'");

        FriBidiChar none = 0;
        check(fribidi_get_mirror_char(0x0061, &none) == 0,
              "…and 'a' has no mirror, rather than mirroring to itself");
    }

    // ── 6. joining types — joining-type.tab.i ────────────────────────────
    // Arabic letters change shape by position. ALEF is right-joining (it links
    // to the preceding letter only); BEH is dual-joining. Getting this wrong
    // is what makes Arabic render as disconnected letterforms.
    {
        const FriBidiJoiningType j_alef = fribidi_get_joining_type(0x0627);
        const FriBidiJoiningType j_beh  = fribidi_get_joining_type(0x0628);
        std::printf("   joining: ALEF=%s BEH=%s\n",
                    fribidi_get_joining_type_name(j_alef),
                    fribidi_get_joining_type_name(j_beh));
        check(FRIBIDI_IS_JOINING_TYPE_R(j_alef), "ARABIC ALEF is right-joining");
        check(FRIBIDI_IS_JOINING_TYPE_D(j_beh), "ARABIC BEH is dual-joining");
    }

    std::printf("\n%d check(s) failed\n", failures);
    return failures == 0 ? 0 : 1;
}

#else
int main() { return 0; }
#endif
