// compat.slint — the SDK through <slint.h>, as upstream's CMake target gives it.
//
// WHAT THIS ASSERTS AND WHY
//
// The package is a binding: the library, headers and slint-compiler are
// xim:slint's, built from the release tag with upstream CMake's default
// features. So the checks ask the LINKED library, not the headers:
//
//   the features      the headers define upstream CMake's defaults and the
//                     library implements the interpreter (it compiles a source)
//   the runtime       SharedString, models, colours: calls into libslint_cpp
//   a component       a `.slint` source compiled at run time, instantiated on
//                     a headless platform (Slint's software renderer, no
//                     display), driven through a property and a callback
//
// That the program starts at all is the run-time closure: libslint_cpp and,
// on Linux, the fontconfig xim:slint declares.
#include <slint.h>
#include <slint-interpreter.h>
#include <slint-platform.h>

#include <array>
#include <cstdio>
#include <memory>
#include <string>

#if !defined(SLINT_FEATURE_INTERPRETER) || !defined(SLINT_FEATURE_RENDERER_SOFTWARE) || \
    !defined(SLINT_FEATURE_BACKEND_WINIT) || defined(SLINT_FEATURE_RENDERER_SKIA)
#error "not upstream CMake's default feature set"
#endif

namespace {
int failures = 0;
void check(bool ok, const char* what) {
    std::printf("%s %s\n", ok ? "ok  " : "FAIL", what);
    failures += !ok;
}
struct HeadlessWindow : slint::platform::WindowAdapter {
    slint::platform::SoftwareRenderer renderer_{slint::platform::SoftwareRenderer::RepaintBufferType::NewBuffer};
    slint::platform::AbstractRenderer& renderer() override { return renderer_; }
    slint::PhysicalSize size() override { return slint::PhysicalSize({ .width = 160, .height = 90 }); }
};
struct HeadlessPlatform : slint::platform::Platform {
    std::unique_ptr<slint::platform::WindowAdapter> create_window_adapter() override {
        return std::make_unique<HeadlessWindow>();
    }
};
}  // namespace

int main() {
    slint::SharedString s("compat");
    s += ".slint";
    check(std::string_view(s) == "compat.slint", "SharedString");
    auto model = std::make_shared<slint::VectorModel<int>>(std::vector<int>{1, 2, 3});
    check(model->row_count() == 3 && *model->row_data(2) == 3, "VectorModel");
    check(slint::Color::from_rgb_uint8(10, 20, 30).green() == 20, "Color");

    slint::platform::set_platform(std::make_unique<HeadlessPlatform>());
    slint::interpreter::ComponentCompiler compiler;
    auto definition = compiler.build_from_source(R"(
        export component Probe inherits Window {
            in-out property <int> value: 2;
            callback twice() -> int;
            twice() => { value *= 2; return value; }
        })", "");
    check(definition.has_value(), "the interpreter compiles a source");
    if (definition) {
        auto instance = definition->create();
        auto r = instance->invoke("twice", std::span<const slint::interpreter::Value>{});
        check(r && r->to_number() == 4.0 && instance->get_property("value")->to_number() == 4.0,
              "a component runs headless: callback and property");
    }
    std::printf("%s\n", failures ? "FAILED" : "all passed");
    return failures ? 1 : 0;
}
