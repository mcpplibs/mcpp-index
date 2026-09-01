// ftxui.dom alone: elements + Render + Screen, no umbrella, no headers.
import std;
import ftxui.dom;

int main() {
    using namespace ftxui;
    Element document = vbox({text("dom-only"), separator(), text("row2")});
    auto screen = Screen::Create(Dimension::Fit(document), Dimension::Fit(document));
    Render(screen, document);
    const std::string rendered = screen.ToString();
    std::println("dom rendered: [{}]", rendered);
    if (rendered.find("dom-only") == std::string::npos) return 1;
    if (rendered.find("row2")     == std::string::npos) return 2;
    std::println("ftxui.dom OK");
    return 0;
}
