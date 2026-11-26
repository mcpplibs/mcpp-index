#include <string>
#include <string_view>
#include <vector>

#include <utf8.h>
#include <utf8/cpp17.h>

int main() {
    bool ok = true;

    // "Hi, 世界!" in UTF-8: 'H','i',',',' ' (4) + U+4E16 (3 bytes) + U+754C (3 bytes) + '!' (1) = 7 code points
    const std::string text = "Hi, \xE4\xB8\x96\xE7\x95\x8C!";
    ok = ok && utf8::is_valid(text.begin(), text.end());
    ok = ok && utf8::distance(text.begin(), text.end()) == 7;

    // UTF-8 <-> UTF-16 round-trip via C++17 string_view helpers
    std::u16string u16 = utf8::utf8to16(std::string_view(text));
    ok = ok && u16.size() == 7;
    ok = ok && u16[4] == u'\u4E16' && u16[5] == u'\u754C';

    std::string back = utf8::utf16to8(std::u16string_view(u16));
    ok = ok && back == text;

    // Invalid UTF-8 detection and replacement
    const std::string bad = "ok\xFF\xFE!";
    ok = ok && !utf8::is_valid(bad.begin(), bad.end());
    auto inv = utf8::find_invalid(bad.begin(), bad.end());
    ok = ok && (inv - bad.begin()) == 2;

    std::string fixed = utf8::replace_invalid(bad, '?');
    ok = ok && utf8::is_valid(fixed.begin(), fixed.end());
    ok = ok && fixed == "ok??!";

    return ok ? 0 : 1;
}
