// compat.eui-neo's SYSTEM TRAY, through the public C++ surface.
//
// This is the shape a consumer should copy. `core::platform` exposes the whole
// tray as six free functions and a two-field options struct, and none of it
// needs a window, a GL context, or the DSL app loop -- a tray-only utility is
// the ten lines in runTray() below. The raw C bridge in
// core/platform/tray_bridge.h is an implementation detail and is not used here.
//
// WHY THIS MEMBER EXISTS, and why the assertion is the shape it is.
//
// tray_bridge.c selects one of four backends at preprocessor level --
// EUI_TRAY_WINAPI, EUI_TRAY_APPKIT, EUI_TRAY_SNI, EUI_TRAY_APPINDICATOR -- and
// falls through to an `#else` stub when none is defined. THE STUB DEFINES ALL
// SIX SYMBOLS and returns 0 from every one of them. A descriptor that lost its
// backend define would still compile, still link, and still pass all six other
// eui-neo members, while the tray silently stopped existing: "no tray" and "not
// tested" would read identically. That is the failure this member is built
// against.
//
// Two criteria were tried and only the second one works:
//
//   * `dlsym(RTLD_DEFAULT, "g_bus_get_sync") != nullptr` -- BLUNT, verified by
//     rebuilding with the define removed and watching it pass anyway. The
//     descriptor's `ldflags` carry `-lgio-2.0` unconditionally, so gio is in
//     DT_NEEDED and its symbols resolve whether or not the SNI arm was
//     compiled. It answered "is gio linked", not "is the backend real".
//
//   * initializeTray() under a session bus -- SHARP. Measured both ways on a
//     bare `dbus-run-session` with no panel and no display: the real backend
//     returns true (it exports its StatusNotifierItem object and waits for a
//     watcher), the stub returns false unconditionally.
//
// So on linux this test supplies its own private bus and asserts the tray comes
// up. It needs no display, no panel, and no desktop session, which is what lets
// it run on an ordinary CI runner.
//
// Windows and macOS get compile-and-link coverage only. Their backends are
// unconditional in the descriptor, and neither has an equivalent cheap probe
// that a headless runner can perform.

#include "core/platform/platform.h"

#if defined(__linux__)
#include <limits.h>
#include <unistd.h>
#endif

import std;

namespace {

// What a consumer actually writes. Everything else in this file is about
// proving the backend is real; this is the feature.
int runTray() {
    core::platform::TrayOptions options;
    options.tooltip  = "EUI NEO tray example";
    options.iconPath = "";   // empty: the panel substitutes a placeholder icon

    if (!core::platform::initializeTray(options)) {
        std::println("tray unavailable (no session bus)");
        return 1;
    }

    std::println("tray is live -- right click it for Show / Exit");
    while (!core::platform::consumeTrayExitRequested()) {
        core::platform::pollTray(false);
        if (core::platform::consumeTrayShowRequested()) std::println("  -> Show");
        std::this_thread::sleep_for(std::chrono::milliseconds(50));
    }

    core::platform::shutdownTray();
    std::println("tray shut down");
    return 0;
}

#if defined(__linux__)
// Re-run this same executable with a private session bus around it. Returns
// only on failure; on success `dbus-run-session` replaces this process and the
// second entry takes the branch below it.
void reexec_under_private_bus(const char* marker) {
    ::setenv(marker, "1", 1);

    char self[PATH_MAX];
    const ssize_t n = ::readlink("/proc/self/exe", self, sizeof(self) - 1);
    if (n <= 0) return;
    self[n] = '\0';

    char* const argv[] = { const_cast<char*>("dbus-run-session"),
                           const_cast<char*>("--"), self, nullptr };
    ::execvp("dbus-run-session", argv);
}
#endif

} // namespace

int main() {
    // Safe on every platform and before any backend has been touched: the state
    // is a plain bool and the stub's eui_tray_is_initialized() also returns 0.
    // This pins the query, not the backend.
    if (core::platform::isTrayInitialized()) {
        std::println(stderr, "isTrayInitialized() is true before initializeTray()");
        return 1;
    }

    if (std::getenv("MCPP_RUN_TRAY") != nullptr) return runTray();

#if defined(__linux__)
    constexpr const char* kMarker = "EUI_TRAY_TEST_HAS_BUS";

    if (std::getenv("DBUS_SESSION_BUS_ADDRESS") == nullptr) {
        if (std::getenv(kMarker) != nullptr) {
            // dbus-run-session ran but produced no bus address. Do not report
            // this as a pass: an unverifiable backend is exactly what this
            // member exists to prevent.
            std::println(stderr,
                         "dbus-run-session left no DBUS_SESSION_BUS_ADDRESS, so "
                         "the linux tray backend could not be verified");
            return 1;
        }
        reexec_under_private_bus(kMarker);
        std::println(stderr,
                     "could not exec dbus-run-session, so the linux tray backend "
                     "could not be verified. It ships with dbus; install that "
                     "package on this runner.");
        return 1;
    }

    // THE ASSERTION. True only when tray_bridge.c compiled a real backend --
    // the EUI_TRAY_HAS_BACKEND=0 stub returns 0 here no matter what the bus is.
    core::platform::TrayOptions options;
    options.tooltip = "compat.eui-neo tray smoke test";
    if (!core::platform::initializeTray(options)) {
        std::println(stderr,
                     "compat.eui-neo was built WITHOUT its linux tray backend: a "
                     "session bus is present, yet initializeTray() failed, which "
                     "is what tray_bridge.c's EUI_TRAY_HAS_BACKEND=0 stub does "
                     "unconditionally. Expected -DEUI_TRAY_SNI=1 and glib on the "
                     "link line (see pkgs/e/compat.eui-neo.lua).");
        return 1;
    }

    if (!core::platform::isTrayInitialized()) {
        std::println(stderr, "initializeTray() succeeded but isTrayInitialized() is false");
        return 1;
    }
    core::platform::shutdownTray();
    std::println("linux tray backend verified over a private session bus");
#else
    std::println("tray path compiled and linked; run with MCPP_RUN_TRAY=1 to show it");
#endif
    return 0;
}
