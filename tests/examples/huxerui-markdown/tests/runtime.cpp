// Headless C++23 module consumer test for huxerui.markdown.
// Verifies mapped macros (modules/macros.cppm), md4c C99 compilation, CommonMark/GFM
// AST + incremental parsing, source range mapping, and HuxerUI declarative Markdown views.
import std;
import huxerui.markdown;

int main() {
    using namespace huxerui::markdown;

    int failures = 0;
    const auto check = [&](bool cond, std::string_view label) {
        if (!cond) {
            std::cerr << "FAILED: " << label << '\n';
            ++failures;
        }
    };

    // Mapped public macro from modules/macros.cppm (re-exported by huxerui.markdown).
    check(macros::HUXERUI_MARKDOWN_SOURCE_MAPPING == 1, "macro HUXERUI_MARKDOWN_SOURCE_MAPPING == 1");

    // Out-of-line ParseMarkdown + ParseOptions::GitHub + AST / source mapping verification.
    auto opts = ParseOptions::GitHub();
    opts.track_source_positions = true;
    opts.highlight = true;

    const std::string_view source =
        "# Title\n\n"
        "Hello **world** ==mark== [link](https://example.com).\n\n"
        "- [x] Done\n"
        "- [ ] Todo\n\n"
        "| A | B |\n"
        "|---|---|\n"
        "| 1 | 2 |\n";

    const MarkdownDocument doc = ParseMarkdown(source, opts);
    const MarkdownNode& root = doc.Root();
    check(root.kind == NodeKind::Document, "root is Document");
    check(root.children.size() == 4, "4 top-level blocks");
    check(root.children[0].kind == NodeKind::Heading, "block 0 is Heading");
    check(root.children[0].heading_level == 1, "heading_level == 1");
    check(PlainText(root.children[0]) == "Title", "heading PlainText");
    check(root.children[1].kind == NodeKind::Paragraph, "block 1 is Paragraph");
    check(root.children[2].kind == NodeKind::UnorderedList, "block 2 is UnorderedList");
    check(root.children[2].children.size() == 2, "2 list items");
    check(root.children[2].children[0].task_checked == true, "task 0 checked");
    check(root.children[2].children[1].task_checked == false, "task 1 unchecked");
    check(root.children[3].kind == NodeKind::Table, "block 3 is Table");

    const std::string plain = doc.PlainText();
    check(plain.find("Title") != std::string::npos, "PlainText contains Title");
    check(plain.find("world") != std::string::npos, "PlainText contains world");

    const MarkdownMappedText mapped = PlainTextWithSource(root.children[0]);
    check(mapped.text == "Title", "PlainTextWithSource heading");
    const auto ranges = ResolveMarkdownSourceRanges(mapped.text, mapped.source_segments, 0, mapped.text.size());
    check(ranges.has_value() && !ranges->empty(), "ResolveMarkdownSourceRanges non-empty");

    // Out-of-line incremental parse session & streaming APIs.
    std::string large;
    for (int i = 0; i < 60; ++i)
        large += "## Section " + std::to_string(i) + "\n\nParagraph **bold**.\n\n";
    MarkdownParseSession session(ParseOptions::CommonMark());
    (void)session.Update(large);
    check(session.LastParseStats().mode == MarkdownParseMode::Full, "initial session update is Full");
    (void)session.Append("New tail text\n");
    check(session.LastParseStats().mode == MarkdownParseMode::Incremental, "append on large doc is Incremental");
    check(session.Document().PlainText().ends_with("New tail text"), "session tail text matches");

    MarkdownStream stream;
    (void)stream.Append("Stream ");
    const MarkdownDocument finished = stream.Finish();
    check(stream.IsFinished(), "stream finished");
    check(finished.PlainText() == "Stream", "stream PlainText matches");

    // Out-of-line link policy & HuxerUI theme/view integration (also verifies export import huxerui).
    check(IsDefaultLinkAllowed("https://example.com"), "https link allowed");
    check(!IsDefaultLinkAllowed("javascript:alert(1)"), "javascript link rejected");

    const MarkdownStyle style = MarkdownStyle::FromTheme(huxerui::MaterialDarkThemeSpec());
    check(style.body.foreground == huxerui::MaterialDarkThemeSpec().colors.on_surface, "FromTheme matches surface");

    const huxerui::View rendered = Markdown(doc);
    check(static_cast<bool>(rendered), "Markdown(doc) valid view");

    std::cout << "module_smoke: " << (failures == 0 ? "ok" : "FAILED") << '\n';
    return failures == 0 ? 0 : 1;
}
