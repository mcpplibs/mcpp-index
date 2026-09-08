// Behavioral test — compat.libassert decomposes an expression and reports the
// values in it, which is the whole reason to use it over <cassert>.
//
// A passing assertion proves almost nothing, so the test drives the FAILING
// path: it installs a failure handler, provokes a failed assertion, and reads
// what libassert produced. `LIBASSERT_ASSERT` carries `LIBASSERT_NOP_ACTION`,
// so a handler that returns lets execution continue — which is what makes this
// testable in-process rather than through an abort.
//
// It is also the proof that the transitive dependency arrives: the failure
// object hands back a `cpptrace::stacktrace`, and this project declares only
// libassert.
//
// No `import std;` — libassert's headers are textual over the standard library.
#include <libassert/assert.hpp>
#include <libassert/version.hpp>
// libassert's own header only FORWARD-declares cpptrace::stacktrace
// (cpptrace/forward.hpp), so calling .frames on it needs the complete type.
// Including cpptrace's public header here works only because compat.cpptrace's
// include directory reaches this project transitively through libassert — this
// project declares no cpptrace dependency of its own. The include is therefore
// part of the assertion, not incidental.
#include <cpptrace/cpptrace.hpp>

#include <cstdio>
#include <string>

#if LIBASSERT_VERSION != LIBASSERT_TO_VERSION(2, 2, 1)
#  error "libassert/version.hpp does not describe 2.2.1 — the generated header drifted from the tarball"
#endif

static std::string captured;
static std::size_t trace_frames = 0;
static int failures = 0;

static void record(const libassert::assertion_info& info) {
    ++failures;
    captured = info.to_string(0, libassert::color_scheme::blank);
    trace_frames = info.get_stacktrace().frames.size();
}

int main() {
    libassert::set_failure_handler(record);

    const int limit = 3;
    const int index = 7;

    // A true assertion must not reach the handler.
    LIBASSERT_ASSERT(limit < index);
    if (failures != 0) {
        std::printf("a true assertion fired the handler\n");
        return 1;
    }

    // A false one must, exactly once.
    LIBASSERT_ASSERT(index < limit, "index out of range", index, limit);
    if (failures != 1) {
        std::printf("failure handler fired %d times, expected 1\n", failures);
        return 2;
    }

    // The report has to carry the EXPRESSION TEXT — that is the part a plain
    // `assert` also manages — and then the two things it does not: the message
    // and the decomposed operand values.
    if (captured.find("index < limit") == std::string::npos) {
        std::printf("report does not carry the expression text:\n%s\n", captured.c_str());
        return 3;
    }
    if (captured.find("index out of range") == std::string::npos) {
        std::printf("report does not carry the message:\n%s\n", captured.c_str());
        return 4;
    }
    if (captured.find("7") == std::string::npos || captured.find("3") == std::string::npos) {
        std::printf("report does not carry the decomposed values:\n%s\n", captured.c_str());
        return 5;
    }

    // cpptrace, reached transitively. Frame COUNT rather than symbol names:
    // compat.cpptrace resolves symbols with dladdr and documents that it
    // carries no file:line, so asserting on names would be testing the
    // backend choice rather than the dependency edge.
    if (trace_frames == 0) {
        std::printf("assertion carried no stack trace — cpptrace did not arrive\n");
        return 6;
    }

    std::printf("compat.libassert: ok (expression, message and values decomposed; %zu trace frames)\n",
                trace_frames);
    return 0;
}
