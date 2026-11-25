// Runtime test — verify compat.md4c 0.6.0 parses CommonMark + 0.6.0 extensions
#include "md4c.h"
import std;

int main() {
    constexpr std::string_view md = "# Title\n\n==marked==\n\n> [!NOTE]\n> body\n";
    struct Seen {
        unsigned heading = 0;
        unsigned marks = 0;
        unsigned admonitions = 0;
    } seen;

    MD_PARSER parser{};
    parser.flags = MD_DIALECT_GITHUB | MD_FLAG_HIGHLIGHT;
    parser.enter_block = [](MD_BLOCKTYPE type, void* detail, void* userdata) -> int {
        auto& s = *static_cast<Seen*>(userdata);
        if (type == MD_BLOCK_H) s.heading = static_cast<MD_BLOCK_H_DETAIL*>(detail)->level;
        if (type == MD_BLOCK_ADMONITION) ++s.admonitions;
        return 0;
    };
    parser.leave_block = [](MD_BLOCKTYPE, void*, void*) -> int { return 0; };
    parser.enter_span = [](MD_SPANTYPE type, void*, void* userdata) -> int {
        auto& s = *static_cast<Seen*>(userdata);
        if (type == MD_SPAN_MARK) ++s.marks;
        return 0;
    };
    parser.leave_span = [](MD_SPANTYPE, void*, void*) -> int { return 0; };
    parser.text = [](MD_TEXTTYPE, const MD_CHAR*, MD_SIZE, void*) -> int { return 0; };

    if (md_parse(md.data(), static_cast<MD_SIZE>(md.size()), &parser, &seen) != 0) return 1;
    if (seen.heading != 1 || seen.marks != 1 || seen.admonitions != 1) return 2;

    std::println("compat.md4c 0.6.0 parse test: ok (h={}, marks={}, admonitions={})",
                 seen.heading, seen.marks, seen.admonitions);
    return 0;
}
