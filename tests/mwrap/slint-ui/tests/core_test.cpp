// Slint's runtime types through `import mcpplibs.mwrap.slint;` alone: strings,
// vectors, models, colours, brushes and geometry are the library's (every call
// below reaches libslint_cpp), and the SDK's features are constants.
import std;
import mcpplibs.mwrap.slint;

namespace {
int failures = 0;
void check(bool ok, std::string_view what) {
    std::println("{} {}", ok ? "ok  " : "FAIL", what);
    failures += !ok;
}
}  // namespace

int main() {
    slint::SharedString s("Hello");
    s += ", Slint";
    check(std::string_view(s) == "Hello, Slint", "SharedString concatenates");
    check(slint::SharedString::from_number(42.5) == "42.5", "SharedString::from_number");

    slint::SharedVector<int> v{1, 2, 3};
    v.push_back(4);
    check(v.size() == 4 && v[3] == 4, "SharedVector grows");

    auto model = std::make_shared<slint::VectorModel<slint::SharedString>>();
    model->push_back("a");
    model->push_back("b");
    model->set_row_data(1, "c");
    check(model->row_count() == 2 && *model->row_data(1) == "c", "VectorModel rows");

    auto red = slint::Color::from_rgb_uint8(255, 0, 0);
    auto blue = slint::Color::from_rgb_uint8(0, 0, 255);
    auto purple = red.mix(blue, 0.5f);
    check(red.red() == 255 && purple.red() > 100 && purple.blue() > 100, "Color mixes");
    check(red.brighter(0.5f).red() == 255, "Color::brighter");
    check(slint::Brush(red).color() == red, "Brush of a colour");

    slint::LogicalSize size({ .width = 3.f, .height = 4.f });
    check(size.width == 3.f && size.height == 4.f, "LogicalSize");

    namespace m = mcpplibs::mwrap::slint::macros;
    check(m::SLINT_FEATURE_INTERPRETER && m::SLINT_FEATURE_RENDERER_SOFTWARE && m::SLINT_FEATURE_BACKEND_WINIT,
          "the default features are on");
    check(!m::SLINT_FEATURE_RENDERER_SKIA && !m::SLINT_FEATURE_EXPERIMENTAL, "Skia and the experimental API are off");
    return failures ? 1 : 0;
}
