// Behavioral test: consume compat.spdlog in COMPILED mode. Asserts both halves
// of what the `compiled` feature promises:
//
//   1. the interface define reached this TU (SPDLOG_COMPILED_LIB defined, and
//      spdlog's headers therefore did NOT flip on SPDLOG_HEADER_ONLY) — a
//      static check, so a regression is a compile error, not a silent fallback
//      to the header-only path that would still pass the runtime assertions;
//   2. spdlog's src/*.cpp really were compiled and linked — the calls below
//      resolve to out-of-line symbols (default_logger_raw, log_msg's ctor,
//      logger::log_it_, and bundled fmt's vformat), which is exactly what fails
//      to link when the engine skips a feature's sources.
#include <spdlog/spdlog.h>
#include <spdlog/sinks/ostream_sink.h>
#include <sstream>
#include <string>

#ifndef SPDLOG_COMPILED_LIB
#error "compiled feature did not propagate SPDLOG_COMPILED_LIB to the consumer"
#endif
#ifdef SPDLOG_HEADER_ONLY
#error "SPDLOG_HEADER_ONLY is on in compiled mode — headers took the inline path"
#endif

int main() {
    std::ostringstream captured;
    auto sink = std::make_shared<spdlog::sinks::ostream_sink_mt>(captured);
    spdlog::logger logger("test", sink);
    logger.set_pattern("%v");  // message only, no timestamp/level decoration

    logger.info("hello {}={}", "answer", 42);
    logger.warn("{:#x}", 255);
    logger.flush();

    // Exercises the global registry too — default_logger_raw() is one of the
    // out-of-line symbols that only exists once src/spdlog.cpp is compiled.
    spdlog::set_level(spdlog::level::info);

    const std::string out = captured.str();
    const bool ok = out.find("hello answer=42") != std::string::npos
                    && out.find("0xff") != std::string::npos;
    return ok ? 0 : 1;
}
