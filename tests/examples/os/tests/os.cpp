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
    if (argc > 1 && std::string_view(argv[1]) == "--both") {
        (void)os::stdio::write_output("out ");
        (void)os::stdio::write_error("err");
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

    // 0.1.1: a name the Windows code page cannot spell, both ways (UTF-8 throughout).
    const std::string name = "\xE4\xB8\xAD\xE6\x96\x87 \xD0\xBA\xD0\xB8\xD1\x80.txt";
    const auto wide = dir / os::fs::from_utf8(name);
    check(os::fs::write(wide, "ok").has_value() && os::fs::read(wide).value_or("") == "ok", "a file whose name is not ASCII");
    check(os::fs::utf8(wide.filename()) == name, "and its name reads back as UTF-8");

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

        // 0.2.0: one pipe carries the output and the error output in the order written.
        o.args.back() = "--both";
        o.out = os::process::stdio::pipe;
        o.err = os::process::stdio::output;
        std::string merged;
        auto p = os::process::process::spawn(o);
        if (p) {
            for (;;) { auto c = p->read_output(); if (!c || c->empty()) break; merged += *c; }
            auto st = p->wait();
            check(st && st->success() && merged == "out err", "both outputs arrive on one pipe in order");
        } else {
            check(false, "a program with both outputs on one pipe starts");
        }
    }
    // 0.1.2: a symbol of the program resolves as the loader resolves it.
    if (os::library::supported())
        check(os::library::process_symbol(os::is_windows ? "GetCurrentProcessId" : "getpid") != nullptr, "a program symbol resolves");
    std::error_code ec;
    std::filesystem::remove_all(dir, ec);
    if (failures == 0) std::println("os-tests: held");
    return failures;
}
