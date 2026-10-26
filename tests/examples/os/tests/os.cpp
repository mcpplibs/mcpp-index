// mcpplibs.os on this runner: the platform, a published file, a list of directories, and a
// program started and read (this test, started again).
import std;
import mcpplibs.os;

namespace os = mcpplibs::os;

int main(int argc, char** argv) {
    if (argc > 1 && std::string_view(argv[1]) == "--echo") {
        (void)os::stdio::write_output("echoed");
        return 0;
    }
    int failures = 0;
    auto check = [&](bool ok, std::string_view what) { if (!ok) { ++failures; std::println(std::cerr, "FAIL: {}", what); } };

    check(os::host() == os::PLATFORM, "built for a system, the host is that system");
    const auto dir = os::dirs::temp() / std::format("os-tests-{}", os::process::self()->id);
    std::filesystem::create_directories(dir);
    const auto file = dir / "published.txt";
    check(os::fs::publish(file, "first").has_value(), "a free name is published");
    check(!os::fs::publish(file, "second").has_value(), "a published name is not replaced");
    check(os::fs::read(file).value_or("") == "first", "and keeps what was published first");

    const char sep = os::conventions().path_list_separator;
    const auto parts = os::env::split_list(std::string("a") + sep + sep + "b");
    check(parts.size() == 2, "a list of directories splits at the host's separator");

    const auto again = os::env::self_command();
    if (!again.empty()) {
        os::process::spawn_options o;
        o.program = again.front();
        o.args.assign(again.begin() + 1, again.end());
        o.args.push_back("--echo");
        auto r = os::process::run(o);
        check(r && r->status.success() && r->out == "echoed", "a started program's output is read");
    }
    std::error_code ec;
    std::filesystem::remove_all(dir, ec);
    if (failures == 0) std::println("os-tests: held");
    return failures;
}
