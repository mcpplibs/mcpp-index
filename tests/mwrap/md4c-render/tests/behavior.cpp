import std;
import mcpplibs.mwrap.md4c;

namespace macros = mcpplibs::mwrap::md4c::macros;

int main() {
    const std::string_view md = "# Title\n\n- [x] done\n\n| a | b |\n|:-|-:|\n| 1 | 2 |\n\n~~old~~ www.example.com &copy;\n";

    // md_html (md4c-html, vendored by the wrapper) with GitHub's dialect.
    std::string html;
    if (md_html(md.data(), static_cast<MD_SIZE>(md.size()),
                [](const MD_CHAR* s, MD_SIZE n, void* out) { static_cast<std::string*>(out)->append(s, n); }, &html,
                macros::MD_DIALECT_GITHUB, 0) != 0)
        return 1;
    for (std::string_view want : {"<h1>Title</h1>", "checked", "<th align=\"left\">a</th>", "<td align=\"right\">2</td>", "<del>old</del>",
                                  "<a href=\"http://www.example.com\">", "\xC2\xA9"})
        if (!html.contains(want)) return 2;

    // md_parse (compat.md4c's parser) with callbacks and details.
    struct Seen {
        unsigned heading = 0, cells = 0;
        int      task = 0;
    } seen;
    MD_PARSER p{};
    p.flags = macros::MD_DIALECT_GITHUB;
    p.enter_block = [](MD_BLOCKTYPE t, void* d, void* u) {
        auto& s = *static_cast<Seen*>(u);
        if (t == MD_BLOCK_H) s.heading = static_cast<MD_BLOCK_H_DETAIL*>(d)->level;
        if (t == MD_BLOCK_TD || t == MD_BLOCK_TH) ++s.cells;
        if (t == MD_BLOCK_LI) s.task = static_cast<MD_BLOCK_LI_DETAIL*>(d)->is_task;
        return 0;
    };
    p.leave_block = [](MD_BLOCKTYPE, void*, void*) { return 0; };
    p.enter_span = [](MD_SPANTYPE, void*, void*) { return 0; };
    p.leave_span = [](MD_SPANTYPE, void*, void*) { return 0; };
    p.text = [](MD_TEXTTYPE, const MD_CHAR*, MD_SIZE, void*) { return 0; };
    if (md_parse(md.data(), static_cast<MD_SIZE>(md.size()), &p, &seen) != 0) return 3;
    if (seen.heading != 1 || seen.cells != 4 || seen.task != 1) return 4;

    std::println("md4c 0.5.3 through import mcpplibs.mwrap.md4c: {} bytes of HTML, {} table cells", html.size(), seen.cells);
    return 0;
}
