// ftxui.screen alone: Screen/Pixel/Color/Terminal and the _rgb literal.
import std;
import ftxui.screen;

int main() {
    using namespace ftxui;
    auto screen = Screen::Create(Dimensions{4, 2});
    screen.PixelAt(0, 0).character = "X";
    screen.PixelAt(3, 1).character = "Y";
    const std::string s = screen.ToString();
    std::println("screen: [{}]", s);
    if (s.find('X') == std::string::npos) return 1;
    if (s.find('Y') == std::string::npos) return 2;

    const Color red = Color::Red;
    const Color rgb = Color::RGB(1, 2, 3);
    if (red == rgb) return 3;
    using namespace ftxui::literals;
    const Color lit = 0x0102ff_rgb;
    if (lit == red) return 4;

    if (string_width("abc") != 3) return 5;
    if (to_string(to_wstring(std::string("mcpp"))) != "mcpp") return 6;
    std::println("ftxui.screen OK");
    return 0;
}
