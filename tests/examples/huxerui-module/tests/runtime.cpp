// HuxerUI is a GUI framework, and this test opens no window: a CI runner has
// no display, and the point here is that the PACKAGE resolves, builds and
// links, not that GTK can paint.
//
// The last assertion is the one that carries that weight. Rect/Color are
// header-attached entities that `import huxerui;` re-exports, so on their own
// they would still compile if libhuxerui had never been built.
// FlatLightThemeSpec/FlatDarkThemeSpec are out-of-line definitions living in
// the library itself, so reaching them is what proves the link.
import std;
import huxerui;

using huxerui::Color;
using huxerui::Point;
using huxerui::Rect;

int main() {
    const Rect bounds{10.0F, 20.0F, 100.0F, 50.0F};
    const bool inside  = bounds.Contains(Point{60.0F, 40.0F});
    const bool outside = !bounds.Contains(Point{5.0F, 40.0F});

    // Rgba32 decodes 0xRRGGBBAA, so this is opaque orange.
    const Color orange  = Color::Rgba32(0xFF8000FFU);
    const bool  decoded = orange == Color::Rgb(255, 128, 0);

    const bool themes_differ =
        !(huxerui::FlatLightThemeSpec() == huxerui::FlatDarkThemeSpec());

    return (inside && outside && decoded && themes_differ) ? 0 : 1;
}
