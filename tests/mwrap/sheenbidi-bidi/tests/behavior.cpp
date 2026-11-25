import std;
import mcpplibs.mwrap.sheenbidi;

using namespace mcpplibs::mwrap::sheenbidi::macros;

int main() {
    if (std::string_view(SBVersionGetString()) != "3.0.0") return 1;

    // UAX #9 N0's example in an RTL paragraph: the bracket pairs resolve together.
    const std::u32string s = U"אב(גד[&ef]!)gh";
    const SBCodepointSequence seq{SBStringEncodingUTF32, s.data(), s.size()};
    SBAlgorithmRef algorithm = SBAlgorithmCreate(&seq);
    SBParagraphRef paragraph = SBAlgorithmCreateParagraph(algorithm, 0, s.size(), 1);
    const SBLevel* levels = SBParagraphGetLevelsPtr(paragraph);
    if (std::vector<int>(levels, levels + s.size()) != std::vector<int>{1, 1, 1, 1, 1, 1, 1, 2, 2, 1, 1, 1, 2, 2}) return 2;

    // The line's runs in visual order, and its mirrored brackets.
    SBLineRef line = SBParagraphCreateLine(paragraph, 0, s.size());
    std::u32string visual;
    const SBRun* runs = SBLineGetRunsPtr(line);
    for (SBUInteger r = 0; r < SBLineGetRunCount(line); ++r)
        for (SBUInteger k = 0; k < runs[r].length; ++k) {
            const SBUInteger i = runs[r].level & 1 ? runs[r].offset + runs[r].length - 1 - k : runs[r].offset + k;
            const SBCodepoint mirror = runs[r].level & 1 ? SBCodepointGetMirror(s[i]) : 0;
            visual += static_cast<char32_t>(mirror != 0 ? mirror : s[i]);
        }
    if (visual != U"gh(![ef&]דג)בא") return 3;
    SBMirrorLocatorRef mirrors = SBMirrorLocatorCreate();
    SBMirrorLocatorLoadLine(mirrors, line, s.data());
    int mirrored = 0;
    while (SBMirrorLocatorMoveNext(mirrors)) ++mirrored;
    SBMirrorLocatorRelease(mirrors);
    if (mirrored != 4) return 4;
    SBLineRelease(line);
    SBParagraphRelease(paragraph);
    SBAlgorithmRelease(algorithm);

    // Scripts over UTF-8, and Unicode 17.0's Sidetic.
    const std::string_view utf8 = "abc \xD8\xB9\xD8\xB1\xD8\xA8\xD9\x8A";
    const SBCodepointSequence u8seq{SBStringEncodingUTF8, utf8.data(), utf8.size()};
    SBScriptLocatorRef scripts = SBScriptLocatorCreate();
    SBScriptLocatorLoadCodepoints(scripts, &u8seq);
    std::vector<SBScript> found;
    while (SBScriptLocatorMoveNext(scripts)) found.push_back(SBScriptLocatorGetAgent(scripts)->script);
    SBScriptLocatorRelease(scripts);
    if (found != std::vector<SBScript>{SBScriptLATN, SBScriptARAB}) return 5;
    if (SBCodepointGetBidiType(0x10940) != SBBidiTypeR || SBCodepointGetScript(0x10940) != SBScriptSIDT) return 6;

    // The mapped macros, at compile time.
    static_assert(SBBidiTypeIsStrong(SBBidiTypeAL) && !SBCodepointIsValid(0xD800u) && SBLevelMax == 125);
    return 0;
}
