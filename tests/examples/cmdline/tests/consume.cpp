// Consuming `mcpplibs.cmdline` through the published index.
//
// `parse_from` rather than `run(argc, argv)`: a test whose only assertion is
// "it linked" passes for a package that parses nothing. Parsing a string and
// checking what came out is the difference between testing the dependency
// edge and testing the dependency.
//
// The chains end in `.end()`, which is what commits the pending item and
// hands back the App — a builder is not an App, and the compiler says so.
import std;
import mcpplibs.cmdline;

using namespace mcpplibs;

int main() {
    int failures = 0;
    auto check = [&](bool ok, std::string_view what) {
        if (!ok) { std::println("FAIL: {}", what); ++failures; }
    };

    auto app = cmdline::App("tool")
        .version("1.0")
        .arg("cmd").required()
        .option("verbose").short_name('v')
        .option("config").short_name('c').takes_value().value_name("FILE")
        .end();

    auto parsed = app.parse_from("tool add --verbose --config=out.toml");
    check(parsed.has_value(), "a well-formed command line parses");
    if (parsed) {
        check(parsed->positional(0) == "add", "positional survives parsing");
        check(parsed->is_flag_set("verbose"), "long flag is seen");
        auto cfg = parsed->value("config");
        check(cfg.has_value() && *cfg == "out.toml", "--opt=value is captured");
    }

    // A required positional that is absent must be refused. Without this, the
    // assertions above are all satisfiable by a parser that accepts anything.
    auto strict  = cmdline::App("tool").arg("cmd").required().end();
    auto missing = strict.parse_from("tool");
    check(!missing.has_value() || missing.error().is_error(),
          "a missing required argument is refused");

    // 0.0.3: a numeric option is checked by the parse and read back typed.
    auto numbers = cmdline::App("tool").option(cmdline::Option("rate").value_type<double>()).option(cmdline::Option("count").value_type<int>());
    auto typed = numbers.parse_from("tool --rate 2.5 --count=3");
    check(typed && typed->value_as<double>("rate") == 2.5 && typed->value_as<int>("count") == 3, "numbers read back as their types");
    auto wrong = numbers.parse_from("tool --count 3px");
    check(!wrong && wrong.error().is_error(), "a value that is not a number of the type is refused");

    if (failures == 0) std::println("cmdline: ok");
    return failures == 0 ? 0 : 1;
}
