// compat.fmt — the package's second TU, src/os.cc, which is what <fmt/os.h>
// declares and nothing else in the library defines. `fmt::getpagesize()` is
// the cheapest proof of that: a pure function, no descriptor, no file, no
// output. The pipe round trip then exercises the same TU's file objects
// behaviorally (a pipe rather than a path: no artifact is left behind, and
// nothing outside the process is touched).
#include <fmt/os.h>

#include <string>

int main() {
    // Defined in src/os.cc only -- if that TU were not linked, this fails at
    // LINK, not here.
    bool ok = fmt::getpagesize() > 0;

    fmt::pipe p;
    const std::string sent = "fmt/os.h";
    const auto written = p.write_end.write(sent.data(), sent.size());
    ok = ok && written == sent.size();

    char buf[64] = {};
    const auto got = p.read_end.read(buf, sizeof(buf));
    ok = ok && got == sent.size() && std::string(buf, got) == sent;

    return ok ? 0 : 1;
}
