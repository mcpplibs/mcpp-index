// The component and its types through `import app.ui;` (the module the rule
// writes beside the header); Slint's own software renderer behind a headless
// platform, so the program runs on every host without a display.
#include <cstdio>
#include <memory>
#include <slint-platform.h>  // textual, before the import: GCC 16 refuses SoftwareRenderer in a module

import app.ui;

namespace {
struct HeadlessWindow : slint::platform::WindowAdapter {
    slint::platform::SoftwareRenderer renderer_{slint::platform::SoftwareRenderer::RepaintBufferType::NewBuffer};
    slint::platform::AbstractRenderer& renderer() override { return renderer_; }
    slint::PhysicalSize size() override { return slint::PhysicalSize({ .width = 320, .height = 240 }); }
};
struct HeadlessPlatform : slint::platform::Platform {
    std::unique_ptr<slint::platform::WindowAdapter> create_window_adapter() override {
        return std::make_unique<HeadlessWindow>();
    }
};
}  // namespace

int main() {
    slint::platform::set_platform(std::make_unique<HeadlessPlatform>());
    auto ui = AppWindow::create();
    int calls = 0;
    ui->on_request_increase_value([&] { ui->set_counter(ui->get_counter() + 1); ++calls; });
    ui->invoke_request_increase_value();
    ui->set_origin(Point{3, 4});
    ui->global<Settings>().set_title("changed");
    const bool dark = ui->global<Colors>().get_background() == slint::Color::from_rgb_uint8(0x20, 0x20, 0x20);
    const Mode mode = Mode::Dark;
    std::printf("counter=%d calls=%d origin=%d,%d title=%s background=%s mode=%d\n", ui->get_counter(), calls,
                ui->get_origin().x, ui->get_origin().y, ui->global<Settings>().get_title().data(),
                dark ? "#202020" : "other", static_cast<int>(mode));
    return (ui->get_counter() == 43 && calls == 1 && ui->get_origin().y == 4 && dark) ? 0 : 1;
}
