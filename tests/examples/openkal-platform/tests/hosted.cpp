import std;
// The arrangement's C++ run-time throws and catches, formats, and the program
// receives the arguments it was started with.
int main(int argc, char** argv) {
    try { throw std::runtime_error("hosted"); }
    catch (const std::exception& e) { std::println("{} ok", e.what()); }
    std::vector<std::string> args(argv, argv + argc);
    if (args.empty() || args.front().empty()) { std::println("no arguments"); return 1; }
    std::println("{} argument(s)", args.size());
    return 0;
}
