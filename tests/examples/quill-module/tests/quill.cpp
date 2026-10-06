import std;
import quill;

#define QUILL_USE_MODULE
#include <quill/LogMacros.h>

bool log_from_worker(quill::Logger* expected);

bool check_logging(std::filesystem::path const& filename) {
    quill::Backend::start();
    quill::FileSinkConfig config;
    config.set_open_mode('w');
    auto sink = quill::Frontend::create_or_get_sink<quill::FileSink>(filename.string(), config);
    auto* logger = quill::Frontend::create_or_get_logger(
        "quill-module-test", sink, quill::PatternFormatterOptions{"%(message)"});
    logger->set_log_level(quill::LogLevel::Info);

    LOG_INFO(logger, "macro answer={} text={}", 42, std::string{"hello"});
    LOG_DEBUG(logger, "filtered main message");
    bool worker_ok = false;
    {
        std::jthread worker([&] { worker_ok = log_from_worker(logger); });
    }
    logger->flush_log();
    quill::Backend::stop();

    std::ifstream file(filename);
    std::string text((std::istreambuf_iterator<char>(file)), {});
    return worker_ok && file.is_open()
        && text.find("macro answer=42 text=hello") != std::string::npos
        && text.find("worker values=[1, 2, 3]") != std::string::npos
        && text.find("runtime answer=43") != std::string::npos
        && text.find("filtered") == std::string::npos
        && std::count(text.begin(), text.end(), '\n') == 3;
}

int main() {
    auto directory = std::filesystem::temp_directory_path()
        / ("mcpp-quill-" + std::to_string(std::random_device{}()));
    if (!std::filesystem::create_directory(directory)) return 1;
    bool ok = false;
    try {
        ok = check_logging(directory / "output.log");
    } catch (std::exception const& error) {
        std::cerr << error.what() << '\n';
    }
    quill::Backend::stop();
    std::error_code error;
    std::filesystem::remove_all(directory, error);
    if (!ok) std::cerr << "Quill module logging assertions failed\n";
    return ok && !error ? 0 : 1;
}
