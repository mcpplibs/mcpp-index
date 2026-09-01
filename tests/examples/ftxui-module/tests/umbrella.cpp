// `import ftxui;` — the umbrella module — plus a real dom render.
import std;
import ftxui;

int main() {
    using namespace ftxui;
    Element document = hbox({text("compat"), separator(), text("ftxui")});
    auto screen = Screen::Create(Dimension::Fit(document), Dimension::Fit(document));
    Render(screen, document);
    const std::string rendered = screen.ToString();
    std::println("rendered: [{}]", rendered);
    if (rendered.find("compat") == std::string::npos) return 1;
    if (rendered.find("ftxui")  == std::string::npos) return 2;
    // the separator must actually have drawn something between them
    if (rendered.find("compat") > rendered.find("ftxui")) return 3;
    std::println("umbrella OK");
    return 0;
}
