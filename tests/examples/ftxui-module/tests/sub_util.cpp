// ftxui.util alone: Ref/ConstRef/StringRef and AutoReset.
import std;
import ftxui.util;

int main() {
    using namespace ftxui;
    int backing = 7;
    Ref<int> r(&backing);
    *r = 9;
    if (backing != 9) return 1;

    ConstRef<int> cr(5);
    if (*cr != 5) return 2;

    std::string text = "abc";
    StringRef sr(&text);
    *sr = "xyz";
    if (text != "xyz") return 3;

    int guarded = 1;
    { AutoReset<int> reset(&guarded, 42); if (guarded != 42) return 4; }
    if (guarded != 1) return 5;

    std::println("ftxui.util OK");
    return 0;
}
