#if defined(_WIN32)
#ifndef NOMINMAX
#define NOMINMAX
#endif
#ifndef WIN32_LEAN_AND_MEAN
#define WIN32_LEAN_AND_MEAN
#endif
#endif

#include <modules/plot/export.h>
#include <modules/plot/plot.h>
#include <modules/plot/session.h>
#include <modules/plot/waveform.h>

#include <stdexcept>
#include <utility>
#include <vector>

int main() {
    bool ok = true;

    modules::plot::PlotSession session;
    auto plot = session.make<modules::plot::Plot>();
    auto incoming = session.mailbox<std::vector<modules::plot::Series>>();

    modules::plot::Series line;
    line.data = modules::plot::Data({0, 1}, {-2, 3});
    incoming->publish({line});
    plot->setSeries(std::move(*incoming->take()));
    ok = ok && plot->axes().y.range().min == -2 && plot->axes().y.range().max == 3;

    modules::plot::WaveformBuffer buffer(
        modules::plot::WaveformBuffer::Config::forDuration(2, 1000, 1)
    );
    ok = ok && buffer.reservedBytes() > 0 && buffer.reservedBytes() < 1024 * 1024;
    session.shutdownHandler()();

    modules::plot::ExportScene badScene;
    badScene.width = 0;
    badScene.height = 0;
    bool threwInvalidArgument = false;
    try {
        modules::plot::writeSvg(badScene, "__mcpp_eui_neo_plot_unused__.svg");
    } catch (const std::invalid_argument&) {
        threwInvalidArgument = true;
    }
    ok = ok && threwInvalidArgument;

    return ok ? 0 : 1;
}
