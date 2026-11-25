import std;
import mcpplibs.mwrap.fribidi;

using namespace mcpplibs::mwrap::fribidi::macros;

namespace {
std::vector<FriBidiChar> text(std::u32string_view s) { return {s.begin(), s.end()}; }
std::u32string chars(const std::vector<FriBidiChar>& v) {
    std::u32string out;
    for (auto c : v) out.push_back(static_cast<char32_t>(c));
    return out;
}
}  // namespace

int main() {
    // UAX #9 N0's example in an RTL paragraph: a bracket pair resolves together.
    auto s = text(U"אב(גד[&ef]!)gh");
    const auto n = static_cast<FriBidiStrIndex>(s.size());
    std::vector<FriBidiCharType> types(s.size());
    std::vector<FriBidiBracketType> brackets(s.size());
    std::vector<FriBidiLevel> levels(s.size());
    fribidi_get_bidi_types(s.data(), n, types.data());
    fribidi_get_bracket_types(s.data(), n, types.data(), brackets.data());
    FriBidiParType base = FRIBIDI_PAR_RTL;
    if (fribidi_get_par_embedding_levels_ex(types.data(), brackets.data(), n, &base, levels.data()) != 3) return 1;
    if (std::vector<int>(levels.begin(), levels.end()) != std::vector<int>{1, 1, 1, 1, 1, 1, 1, 2, 2, 1, 1, 1, 2, 2}) return 2;

    // A line to visual order, with mirrored brackets.
    auto logical = text(U"abc אב(ג) def");
    const auto len = static_cast<FriBidiStrIndex>(logical.size());
    std::vector<FriBidiChar> visual(logical.size());
    FriBidiParType dir = FRIBIDI_PAR_ON;
    if (fribidi_log2vis(logical.data(), len, &dir, visual.data(), nullptr, nullptr, nullptr) == 0) return 3;
    if (dir != FRIBIDI_PAR_LTR || chars(visual) != U"abc (ג)בא def") return 4;

    // Arabic joining and shaping to presentation forms.
    auto arabic = text(U"بب");
    std::vector<FriBidiCharType> atypes(2);
    std::vector<FriBidiLevel> alevels(2);
    std::vector<FriBidiArabicProp> props(2);
    fribidi_get_bidi_types(arabic.data(), 2, atypes.data());
    FriBidiParType abase = FRIBIDI_PAR_ON;
    if (!fribidi_get_par_embedding_levels_ex(atypes.data(), nullptr, 2, &abase, alevels.data())) return 5;
    fribidi_get_joining_types(arabic.data(), 2, props.data());
    fribidi_join_arabic(atypes.data(), 2, alevels.data(), props.data());
    fribidi_shape(FRIBIDI_FLAGS_DEFAULT | FRIBIDI_FLAGS_ARABIC, alevels.data(), 2, props.data(), arabic.data());
    if (chars(arabic) != U"\uFE91\uFE90") return 6;

    // Macros as constants and constexpr functions; the adapted debug function.
    static_assert(FRIBIDI_IS_RTL(FRIBIDI_TYPE_AL) && FRIBIDI_DIR_TO_LEVEL(FRIBIDI_PAR_RTL) == 1);
    static_assert(std::string_view(FRIBIDI_VERSION) == "1.0.16");
    if (mcpplibs::mwrap::fribidi::fribidi_set_debug(0) != 0) return 7;
    if (std::string_view(fribidi_unicode_version) != "16.0.0") return 8;
    if (fribidi_parse_charset("UTF-8") != FRIBIDI_CHAR_SET_UTF8) return 9;
    std::println("fribidi-bidi: levels, reordering, shaping and macros ok");
    return 0;
}
