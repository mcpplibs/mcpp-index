// compat.sheenbidi — the Unicode bidirectional algorithm, on text that needs it.
//
// WHAT THIS ASSERTS AND WHY
//
// The Unicode tables are most of the package: Source/Data/*Lookup.c encode the
// Unicode Character Database, and a build that compiled none of them would not
// link — but one that compiled stale ones would, and would quietly get new
// scripts wrong. So every check asks the library a question whose answer is in
// a table or in the algorithm over it:
//
//   the version            SBVersionGetString, the linked library's own string
//   bidi types             BidiTypeLookup.c — L, R, AL, EN, AN
//   Unicode 17.0.0         a Sidetic letter (new in 17.0) is R and Sidetic
//   general category       GeneralCategoryLookup.c
//   mirroring, brackets    PairingLookup.c — "(" mirrors to ")"
//   scripts                ScriptLookup.c, the script locator over mixed text
//   paragraphs             the base level from the first strong character
//   lines and runs         UAX #9 itself: runs in visual order, with levels
//   the mirror locator     which characters of a line are drawn mirrored
//   UTF-8 and UTF-16       the same answer whatever the code units
//
// A pass means the tarball's committed tables were compiled, through the unity
// source — the claim that lets this be a descriptor with nothing generated.

#include <SheenBidi/SheenBidi.h>

#include <cstdint>
#include <cstdio>
#include <cstring>
#include <vector>

namespace {

int failures = 0;

void check(bool ok, const char *what)
{
    std::printf("%-62s %s\n", what, ok ? "ok" : "FAILED");
    if (!ok) {
        ++failures;
    }
}

SBCodepointSequence utf32(const std::vector<SBUInt32> &text)
{
    return SBCodepointSequence{SBStringEncodingUTF32, text.data(), text.size()};
}

} // namespace

int main()
{
    // ── 1. the version ────────────────────────────────────────────────────
    std::printf("   SheenBidi %s\n", SBVersionGetString());
    check(std::strcmp(SBVersionGetString(), "3.0.0") == 0,
          "SBVersionGetString is 3.0.0, as the descriptor is");
    check(std::strcmp(SBVersionGetString(), SHEENBIDI_VERSION_STRING) == 0,
          "...and agrees with the header it was compiled against");

    // ── 2. bidi types — BidiTypeLookup.c ──────────────────────────────────
    check(SBCodepointGetBidiType('a') == SBBidiTypeL, "'a' is L");
    check(SBCodepointGetBidiType(0x05D0) == SBBidiTypeR, "U+05D0 HEBREW ALEF is R");
    check(SBCodepointGetBidiType(0x0627) == SBBidiTypeAL, "U+0627 ARABIC ALEF is AL");
    check(SBCodepointGetBidiType('1') == SBBidiTypeEN, "'1' is EN");
    check(SBCodepointGetBidiType(0x0661) == SBBidiTypeAN, "U+0661 ARABIC-INDIC ONE is AN");
    check(SBBidiTypeIsStrong(SBCodepointGetBidiType(0x05D0)), "SBBidiTypeIsStrong(R)");

    // ── 3. Unicode 17.0.0 — the tables are this release's ─────────────────
    // U+10940 SIDETIC LETTER N01 was added in Unicode 17.0: right-to-left,
    // script Sidetic. Tables older than 17.0 answer L (unassigned) and Zzzz.
    check(SBCodepointGetBidiType(0x10940) == SBBidiTypeR,
          "U+10940 SIDETIC LETTER N01 (Unicode 17.0) is R");
    check(SBCodepointGetScript(0x10940) == SBScriptSIDT, "...and its script is Sidetic");

    // ── 4. general category, mirroring, scripts ───────────────────────────
    check(SBCodepointGetGeneralCategory('A') == SBGeneralCategoryLU, "'A' is Lu");
    check(SBCodepointGetGeneralCategory(0x0627) == SBGeneralCategoryLO, "U+0627 is Lo");
    check(SBCodepointGetMirror('(') == ')', "'(' mirrors to ')'");
    check(SBCodepointGetMirror('a') == 0, "'a' has no mirror (0, not itself)");
    check(SBCodepointGetScript(0x0627) == SBScriptARAB, "U+0627 is Arabic script");
    check(SBScriptGetUnicodeTag(SBScriptHEBR) == 0x48656272u /* 'Hebr' */,
          "the ISO 15924 tag of Hebrew is 'Hebr'");

    // ── 5. paragraphs: the base level from the first strong character ─────
    {
        const std::vector<SBUInt32> hebrew_first = {0x05D0, ' ', 'A'};
        const std::vector<SBUInt32> latin_first  = {'A', ' ', 0x05D0};
        for (int i = 0; i < 2; ++i) {
            const auto seq = utf32(i == 0 ? hebrew_first : latin_first);
            SBAlgorithmRef algorithm = SBAlgorithmCreate(&seq);
            SBParagraphRef paragraph =
                SBAlgorithmCreateParagraph(algorithm, 0, seq.stringLength, SBLevelDefaultLTR);
            const SBLevel base = SBParagraphGetBaseLevel(paragraph);
            check(i == 0 ? base == 1 : base == 0,
                  i == 0 ? "a Hebrew-initial paragraph has base level 1"
                         : "...and a Latin-initial one base level 0");
            SBParagraphRelease(paragraph);
            SBAlgorithmRelease(algorithm);
        }
    }

    // ── 6. lines and runs: UAX #9 itself ──────────────────────────────────
    // "abc אבג" in a right-to-left paragraph. The Latin run is at level 2, the
    // space and the Hebrew at level 1. A line's runs come in VISUAL order, left
    // to right: the space and Hebrew (offset 3, length 4, level 1) first, then
    // "abc" (offset 0, length 3, level 2).
    {
        const std::vector<SBUInt32> text = {'a', 'b', 'c', ' ', 0x05D0, 0x05D1, 0x05D2};
        const auto seq = utf32(text);
        SBAlgorithmRef algorithm = SBAlgorithmCreate(&seq);
        SBParagraphRef paragraph = SBAlgorithmCreateParagraph(algorithm, 0, text.size(), 1);
        check(SBParagraphGetLength(paragraph) == text.size(), "the paragraph covers the text");

        const SBLevel *levels = SBParagraphGetLevelsPtr(paragraph);
        check(levels[0] == 2 && levels[2] == 2 && levels[3] == 1 && levels[4] == 1,
              "levels: Latin 2, space 1, Hebrew 1");

        SBLineRef line = SBParagraphCreateLine(paragraph, 0, text.size());
        const SBUInteger count = SBLineGetRunCount(line);
        const SBRun *runs = SBLineGetRunsPtr(line);
        std::printf("   runs:");
        for (SBUInteger r = 0; r < count; ++r) {
            std::printf(" {%zu,%zu,L%u}", static_cast<size_t>(runs[r].offset),
                        static_cast<size_t>(runs[r].length), static_cast<unsigned>(runs[r].level));
        }
        std::printf("\n");
        check(count == 2, "the line has two runs");
        check(count == 2 && runs[0].offset == 3 && runs[0].length == 4 && runs[0].level == 1,
              "the first visual run is the space and the Hebrew, at level 1");
        check(count == 2 && runs[1].offset == 0 && runs[1].length == 3 && runs[1].level == 2,
              "...and the second is \"abc\", at level 2");

        SBLineRelease(line);
        SBParagraphRelease(paragraph);
        SBAlgorithmRelease(algorithm);
    }

    // ── 7. the mirror locator — what a line draws mirrored ────────────────
    // "אב(ג)" right to left: both parentheses resolve to level 1, so both are
    // drawn as their mirrors.
    {
        const std::vector<SBUInt32> text = {0x05D0, 0x05D1, '(', 0x05D2, ')'};
        const auto seq = utf32(text);
        SBAlgorithmRef algorithm = SBAlgorithmCreate(&seq);
        SBParagraphRef paragraph =
            SBAlgorithmCreateParagraph(algorithm, 0, text.size(), SBLevelDefaultLTR);
        SBLineRef line = SBParagraphCreateLine(paragraph, 0, text.size());
        SBMirrorLocatorRef locator = SBMirrorLocatorCreate();
        SBMirrorLocatorLoadLine(locator, line, text.data());
        std::vector<SBMirrorAgent> agents;
        while (SBMirrorLocatorMoveNext(locator)) {
            agents.push_back(*SBMirrorLocatorGetAgent(locator));
        }
        check(agents.size() == 2, "two characters are drawn mirrored");
        check(agents.size() == 2 && agents[0].index == 2 && agents[0].mirror == ')' &&
                  agents[1].index == 4 && agents[1].mirror == '(',
              "...'(' at 2 as ')' and ')' at 4 as '('");
        SBMirrorLocatorRelease(locator);
        SBLineRelease(line);
        SBParagraphRelease(paragraph);
        SBAlgorithmRelease(algorithm);
    }

    // ── 8. scripts over mixed text, from UTF-8 ────────────────────────────
    // "abc عربي": Latin, then (the space joins the run before it) Arabic.
    {
        const char *utf8 = "abc \xD8\xB9\xD8\xB1\xD8\xA8\xD9\x8A";
        const SBCodepointSequence seq{SBStringEncodingUTF8, utf8, std::strlen(utf8)};
        SBScriptLocatorRef locator = SBScriptLocatorCreate();
        SBScriptLocatorLoadCodepoints(locator, &seq);
        std::vector<SBScriptAgent> runs;
        while (SBScriptLocatorMoveNext(locator)) {
            runs.push_back(*SBScriptLocatorGetAgent(locator));
        }
        check(runs.size() == 2 && runs[0].script == SBScriptLATN && runs[0].offset == 0 &&
                  runs[1].script == SBScriptARAB && runs[1].offset + runs[1].length == seq.stringLength,
              "script runs over UTF-8: Latin, then Arabic to the end");
        SBScriptLocatorRelease(locator);
    }

    // ── 9. the same paragraph from UTF-16 code units ──────────────────────
    {
        const SBUInt16 utf16[] = {'a', ' ', 0x05D0, 0x05D1};
        const SBCodepointSequence seq{SBStringEncodingUTF16, utf16, 4};
        SBAlgorithmRef algorithm = SBAlgorithmCreate(&seq);
        SBParagraphRef paragraph = SBAlgorithmCreateParagraph(algorithm, 0, 4, SBLevelDefaultRTL);
        const SBLevel *levels = SBParagraphGetLevelsPtr(paragraph);
        check(SBParagraphGetBaseLevel(paragraph) == 0 && levels[0] == 0 && levels[2] == 1,
              "UTF-16: base 0 (first strong is 'a'), Hebrew at level 1");
        SBParagraphRelease(paragraph);
        SBAlgorithmRelease(algorithm);
    }

    std::printf("\n%d check(s) failed\n", failures);
    return failures == 0 ? 0 : 1;
}
