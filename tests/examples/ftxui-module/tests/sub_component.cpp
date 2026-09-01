// ftxui.component alone: Component/Event/Button and event routing.
import std;
import ftxui.component;

int main() {
    using namespace ftxui;
    int clicked = 0;
    Component button = Button("go", [&] { ++clicked; });

    Component container = Container::Vertical({button});
    if (!container->OnEvent(Event::Return)) return 1;
    if (clicked != 1) return 2;

    const Event a = Event::Character('a');
    if (!a.is_character() || a.character() != "a") return 3;
    if (Event::Return == a) return 4;

    std::println("clicked={}", clicked);
    std::println("ftxui.component OK");
    return 0;
}
