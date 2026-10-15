// compat.fmt — the compiled core. `fmt::vformat` is defined in format-inl.h,
// which only src/format.cc compiles into a library TU (a consumer sees it as a
// declaration unless FMT_HEADER_ONLY is defined, which this member must not
// do), and the runtime format string is what makes that the path actually
// taken: a literal argument would let the compiler fold the call away, and
// without the package's format.cc on the link line nothing here would link at
// all. The rest below is upstream's documented surface, asserted rather than
// printed.
//
// Nothing here reads a file or the network.
#include <fmt/format.h>

#include <iterator>
#include <string>

int main() {
    bool ok = fmt::format("{} + {} = {}", 2, 3, 2 + 3) == "2 + 3 = 5";

    // Runtime format string through the compiled vformat.
    ok = ok && fmt::vformat("{0}-{1}-{0}", fmt::make_format_args("x", "y")) == "x-y-x";

    // Padding/precision/width and alternate form.
    ok = ok && fmt::format("{:08.3f}", 3.14159) == "0003.142";
    ok = ok && fmt::format("{:>8}", "fmt") == "     fmt";
    ok = ok && fmt::format("{:#x}", 255) == "0xff";

    // format_to writes through an output iterator and returns it, so a second
    // call on the result appends rather than restarts.
    std::string out;
    auto it = fmt::format_to(std::back_inserter(out), "{}-{}", 1, 2);
    fmt::format_to(it, "!");
    ok = ok && out == "1-2!";

    // Deliberately NOT asserted here: fmt/chrono.h. Its micro-sign duration
    // literal (chrono.h:581) is the one non-ASCII byte sequence reachable in
    // the package, and on MSVC it is only read correctly under a source charset
    // the descriptor cannot impose on a consumer, so a chrono assertion would
    // be a statement about this member's toolchain rather than about the
    // package. See pkgs/c/compat.fmt.lua.

    return ok ? 0 : 1;
}
