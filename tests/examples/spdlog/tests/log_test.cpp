// Behavioral test: consume compat.spdlog in its DEFAULT header-only mode. Logs
// through a custom logger wired to an in-memory ostream sink, then asserts the
// formatted output — this exercises the logger, the pattern formatter, and the
// bundled {fmt} formatting all via the header inlines. Returns non-zero on any
// mismatch.
#include <spdlog/spdlog.h>
#include <spdlog/sinks/ostream_sink.h>
#include <sstream>
#include <string>

int main() {
    std::ostringstream captured;
    auto sink = std::make_shared<spdlog::sinks::ostream_sink_mt>(captured);
    spdlog::logger logger("test", sink);
    logger.set_pattern("%v");  // message only, no timestamp/level decoration

    logger.info("hello {}={}", "answer", 42);
    logger.warn("{:#x}", 255);
    logger.flush();

    const std::string out = captured.str();
    const bool ok = out.find("hello answer=42") != std::string::npos
                    && out.find("0xff") != std::string::npos;
    return ok ? 0 : 1;
}
