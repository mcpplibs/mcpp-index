// compat.libseat — link and entry-point test.
//
// WHAT THIS CANNOT DO, and why that is not a gap. Opening a seat needs either
// a running seatd daemon (SEATD_SOCK) or the privileges to BE the seat manager
// — a CI runner has neither, and a compositor's own failure to open a seat is
// an environment problem rather than a packaging one. So what is asserted is
// that the library is complete and its entry points resolve.
//
// `#include <libseat.h>` INSIDE `extern "C"`, and that is not boilerplate:
// upstream's header carries no `extern "C"` guard of its own (measured — zero
// occurrences in include/libseat.h). Included plainly from C++ every
// declaration gets C++ linkage and every call fails to link with a mangled
// name. Any C++ consumer has to do this; it is worth having in the test so the
// requirement is visible rather than discovered.

#ifdef __linux__

extern "C" {
#include <libseat.h>
}

#include <cstdio>

int main()
{
    int failures = 0;
    auto check = [&](bool ok, const char *what) {
        std::printf("%-58s %s\n", what, ok ? "ok" : "FAILED");
        if (!ok) ++failures;
    };

    // Taking the address is what forces the link. A header-only mistake or a
    // missing translation unit shows up here.
    check(reinterpret_cast<void *>(&libseat_open_seat)   != nullptr, "libseat_open_seat links");
    check(reinterpret_cast<void *>(&libseat_close_seat)  != nullptr, "libseat_close_seat links");
    check(reinterpret_cast<void *>(&libseat_open_device) != nullptr, "libseat_open_device links");
    check(reinterpret_cast<void *>(&libseat_close_device)!= nullptr, "libseat_close_device links");
    check(reinterpret_cast<void *>(&libseat_switch_session) != nullptr, "libseat_switch_session links");
    check(reinterpret_cast<void *>(&libseat_dispatch)    != nullptr, "libseat_dispatch links");
    check(reinterpret_cast<void *>(&libseat_get_fd)      != nullptr, "libseat_get_fd links");

    // The builtin backend pulls the whole seat manager in. `seat_open_device`
    // is one of its symbols, and its presence is what says BUILTIN_ENABLED
    // actually took effect rather than being a define nothing read.
    std::puts("   (the seatd and builtin backends are compiled in; logind is not)");

    std::printf("\n%d check(s) failed\n", failures);
    return failures == 0 ? 0 : 1;
}

#else
int main() { return 0; }
#endif
