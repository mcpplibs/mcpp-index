// Behavioral test — compat.argparse parses a command line, it does not merely
// include.
//
// argv is written by hand rather than taken from the runner, so the assertions
// are about argparse's behaviour and not about how `mcpp test` invokes a
// binary. No `import std;`: argparse.hpp is a textual header over the standard
// library.
#include <argparse/argparse.hpp>

#include <iostream>
#include <string>
#include <vector>

int main() {
    argparse::ArgumentParser program("renderer", "0.1.0");
    program.add_argument("model").help("path to the glTF model");
    program.add_argument("--width").default_value(1280).scan<'i', int>();
    program.add_argument("--validate").default_value(false).implicit_value(true);

    const std::vector<std::string> argv{"renderer", "scene.gltf", "--width", "1920", "--validate"};
    try {
        program.parse_args(argv);
    } catch (const std::exception& e) {
        std::cerr << "parse_args threw: " << e.what() << "\n";
        return 1;
    }

    if (program.get<std::string>("model") != "scene.gltf") { std::cerr << "positional wrong\n"; return 2; }
    if (program.get<int>("--width") != 1920)               { std::cerr << "typed scan wrong\n";  return 3; }
    if (!program.get<bool>("--validate"))                  { std::cerr << "implicit flag wrong\n"; return 4; }

    // The default has to survive an argv that never mentions the option.
    argparse::ArgumentParser defaults("renderer");
    defaults.add_argument("--width").default_value(1280).scan<'i', int>();
    defaults.parse_args(std::vector<std::string>{"renderer"});
    if (defaults.get<int>("--width") != 1280) { std::cerr << "default_value wrong\n"; return 5; }

    // A missing required positional must be an error, not a silent empty
    // string — that is the half of a parser a "compiles fine" test misses.
    argparse::ArgumentParser required("renderer");
    required.add_argument("model");
    bool threw = false;
    try {
        required.parse_args(std::vector<std::string>{"renderer"});
    } catch (const std::exception&) {
        threw = true;
    }
    if (!threw) { std::cerr << "missing positional did not throw\n"; return 6; }

    std::cout << "compat.argparse: ok (positional, typed scan, implicit flag, default, error path)\n";
    return 0;
}
