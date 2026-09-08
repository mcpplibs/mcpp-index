// Behavioral test — compat.cpptrace unwinds a real call stack.
//
// What is asserted is deliberately what the CHOSEN BACKENDS can answer on a
// bare CI runner. The package selects `_Unwind_Backtrace` + `dladdr` on unix
// and DbgHelp on windows, all dependency-free, and the documented cost of that
// choice is that frames carry no file:line (dladdr does not read DWARF). So
// this test asserts the unwinder — frame count and distinct return addresses —
// and never asserts on line numbers, which would be testing libdwarf's absence
// rather than this package.
#include <cpptrace/cpptrace.hpp>
#include <cpptrace/version.hpp>

#include <cstdio>
#include <cstdint>

#if CPPTRACE_VERSION != CPPTRACE_TO_VERSION(1, 0, 4)
#  error "cpptrace/version.hpp does not describe 1.0.4 — the generated header drifted from the tarball"
#endif

// The package builds objects, not a shared library, so every cpptrace
// declaration this TU sees must be plain — not dllimport, not
// visibility("default"). The package delivers that with a shim in front of
// cpptrace/basic.hpp, because no descriptor key carries a define to a
// consumer's TUs.
//
// This check exists because the failure it guards is invisible on Linux: there
// the difference is only a visibility attribute and everything still links. On
// the MSVC ABI it is `dllimport` versus nothing, and the link fails with
// "undefined symbol: __declspec(dllimport) ...". Asserting the macro at COMPILE
// time fails on every platform the moment the shim stops being reached.
#if !defined(CPPTRACE_STATIC_DEFINE)
#  error "CPPTRACE_STATIC_DEFINE is not set for this consumer TU — the compat.cpptrace basic.hpp shim was not reached (include_dirs order?)"
#endif

// noinline so the three frames cannot be collapsed into one by the optimiser;
// the test is about the unwinder seeing depth.
#if defined(_MSC_VER)
#  define NOINLINE __declspec(noinline)
#else
#  define NOINLINE __attribute__((noinline))
#endif

static NOINLINE cpptrace::stacktrace level_three() { return cpptrace::generate_trace(); }
static NOINLINE cpptrace::stacktrace level_two()   { return level_three(); }
static NOINLINE cpptrace::stacktrace level_one()   { return level_two(); }

int main() {
    const cpptrace::stacktrace trace = level_one();

    if (trace.frames.empty()) {
        std::printf("generate_trace returned no frames — the unwinder produced nothing\n");
        return 1;
    }
    // main + three levels, minus whatever the runtime trims. Four is the
    // number the chain above must at least reach for the unwind to be real
    // rather than a single-frame stub.
    if (trace.frames.size() < 4) {
        std::printf("only %zu frames; expected the four-deep chain to survive\n", trace.frames.size());
        return 2;
    }

    // Distinct return addresses: a stub that filled the vector with one
    // repeated address would pass the count check but not this one.
    std::uintptr_t distinct = 0;
    for (std::size_t i = 1; i < trace.frames.size(); ++i) {
        if (trace.frames[i].raw_address != trace.frames[i - 1].raw_address) ++distinct;
    }
    if (distinct == 0) {
        std::printf("every frame has the same address\n");
        return 3;
    }
    if (trace.frames[0].raw_address == 0) {
        std::printf("top frame has a null address\n");
        return 4;
    }

    std::printf("compat.cpptrace: ok (%zu frames, %ju distinct addresses, version %d)\n",
                trace.frames.size(), static_cast<std::uintmax_t>(distinct), CPPTRACE_VERSION);
    return 0;
}
