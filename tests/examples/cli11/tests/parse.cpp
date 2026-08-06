// Behavioral test: parse synthetic argv with CLI11 and assert what came out.
// Covers the four things a parser has to get right — values and defaults,
// flags, a multi-value option, a subcommand — plus the two failure paths
// (unknown option, failed validator), which is what proves the parse actually
// ran rather than silently doing nothing. Returns non-zero on any mismatch.
//
// It also calls the package's anchor symbol. compat.CLI11 is header-only, so
// its lib target holds exactly that one translation unit: if the reference
// resolves, the package really was built and linked, not just included.
#include <CLI/CLI.hpp>

#include <string>
#include <vector>

int mcpp_compat_cli11_headers_anchor(void);

namespace {

// Values, default, flag, multi-value option and a subcommand, in one parse.
bool parses_a_full_command_line() {
    CLI::App app{"mcpp-index CLI11 member"};

    std::string name;
    app.add_option("-n,--name", name, "a name")->required();

    int count = 1;  // left alone by the argv below: asserts the default holds
    app.add_option("-c,--count", count, "how many");

    bool verbose = false;
    app.add_flag("-v,--verbose", verbose, "chatty");

    std::vector<int> nums;
    app.add_option("--nums", nums, "numbers")->expected(3);

    auto *sub = app.add_subcommand("run", "do the thing");
    std::string target;
    sub->add_option("target", target, "what to run")->required();

    const char *argv[] = {"prog", "--name", "mcpp", "-v",
                          "--nums", "1", "2", "3", "run", "index"};
    try {
        app.parse(static_cast<int>(sizeof(argv) / sizeof(argv[0])), argv);
    } catch (const CLI::ParseError &) {
        return false;
    }

    return name == "mcpp" && count == 1 && verbose
           && nums == std::vector<int>{1, 2, 3}
           && app.got_subcommand(sub) && target == "index";
}

// An option nobody declared must be rejected, not ignored.
bool rejects_an_unknown_option() {
    CLI::App app;
    int count = 0;
    app.add_option("-c,--count", count);

    const char *argv[] = {"prog", "--nope"};
    try {
        app.parse(2, argv);
    } catch (const CLI::ParseError &) {
        return true;
    }
    return false;
}

// Validators live in their own header; a value outside the range must throw.
bool enforces_a_validator() {
    CLI::App app;
    int count = 0;
    app.add_option("-c,--count", count)->check(CLI::Range(1, 10));

    const char *argv[] = {"prog", "-c", "99"};
    try {
        app.parse(3, argv);
    } catch (const CLI::ValidationError &) {
        return true;
    } catch (const CLI::ParseError &) {
        return false;
    }
    return false;
}

}  // namespace

int main() {
    const bool ok = parses_a_full_command_line()
                    && rejects_an_unknown_option()
                    && enforces_a_validator()
                    && std::string(CLI11_VERSION) == "2.7.2"
                    && mcpp_compat_cli11_headers_anchor() == 0;
    return ok ? 0 : 1;
}
