// A `.slint` source compiled at run time by slint::interpreter, instantiated
// on a headless platform (Slint's own software renderer) and driven through
// its properties and callbacks -- no generated code, no display.
#if !defined(__clang__)
#include <slint-platform.h>  // GCC 16: the platform module is Clang's (tools/gen_exports.py)
#endif

import std;
import mcpplibs.mwrap.slint;
import mcpplibs.mwrap.slint.interpreter;
#if defined(__clang__)
import mcpplibs.mwrap.slint.platform;
#endif

namespace {
int failures = 0;
void check(bool ok, std::string_view what) {
    std::println("{} {}", ok ? "ok  " : "FAIL", what);
    failures += !ok;
}

struct HeadlessWindow : slint::platform::WindowAdapter {
    slint::platform::SoftwareRenderer renderer_{slint::platform::SoftwareRenderer::RepaintBufferType::NewBuffer};
    slint::platform::AbstractRenderer& renderer() override { return renderer_; }
    slint::PhysicalSize size() override { return slint::PhysicalSize({ .width = 200, .height = 100 }); }
};
struct HeadlessPlatform : slint::platform::Platform {
    std::unique_ptr<slint::platform::WindowAdapter> create_window_adapter() override {
        return std::make_unique<HeadlessWindow>();
    }
};

constexpr std::string_view source = R"(
export component Counter inherits Window {
    in-out property <int> count: 1;
    in property <string> label: "clicks";
    callback bump(int) -> int;
    bump(n) => { count += n; return count; }
    Text { text: "\{label}: \{count}"; }
}
)";
}  // namespace

int main() {
    slint::platform::set_platform(std::make_unique<HeadlessPlatform>());
    slint::interpreter::ComponentCompiler compiler;
    auto definition = compiler.build_from_source(std::string(source), "");
    for (auto const& d : compiler.diagnostics()) std::println("diagnostic: {}", std::string_view(d.message));
    check(definition.has_value(), "the source compiles");
    if (!definition) return 1;
    auto instance = definition->create();
    check(instance->get_property("count")->to_number() == 1.0, "the property's initial value");
    check(instance->set_property("label", slint::SharedString("taps")), "a property is set");
    auto result = instance->invoke("bump", std::array{slint::interpreter::Value(41.0)});
    check(result && result->to_number() == 42.0, "a callback runs and returns");
    check(instance->get_property("count")->to_number() == 42.0, "the callback changed the property");
    check(*instance->get_property("label")->to_string() == "taps", "the string property");
    return failures ? 1 : 0;
}
