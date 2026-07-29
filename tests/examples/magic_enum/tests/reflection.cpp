// Behavioral test: enum_name, enum_cast, enum_values under `mcpp test`.
import std;
import magic_enum;

enum class Color { RED = -10, BLUE = 0, GREEN = 10 };

int main() {
    Color c = Color::RED;
    auto name = magic_enum::enum_name(c);
    bool ok = (name == "RED");

    auto cast = magic_enum::enum_cast<Color>("GREEN");
    ok = ok && cast.has_value() && cast.value() == Color::GREEN;

    auto values = magic_enum::enum_values<Color>();
    ok = ok && values.size() == 3;

    return ok ? 0 : 1;
}