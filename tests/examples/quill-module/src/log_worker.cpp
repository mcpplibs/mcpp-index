import std;
import quill;

bool log_from_worker(quill::Logger* expected) {
    auto* logger = quill::Frontend::get_logger("quill-module-test");
    if (logger != expected) return false;
    quill::info(logger, "worker values={}", std::vector<int>{1, 2, 3});
    quill::log(logger, quill::LogLevel::Warning, "runtime answer={}", 43);
    quill::debug(logger, "filtered worker message");
    return true;
}
