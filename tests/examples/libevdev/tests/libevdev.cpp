// libevdev, exercised without an input device.
//
// The package's whole reason to be a fork is `event-names.h` — 1,692 lines of
// generated tables mapping every kernel input constant to its string. So that
// is what the test asks about: a package that linked but whose tables were
// generated from the WRONG headers (the host's rather than the bundled ones,
// which produces a measurably different file) answers these differently.
//
// No device is opened. libevdev's name lookups are pure functions of the
// tables, which is exactly why they are testable anywhere.

#ifdef __linux__

#include <libevdev.h>
#include <linux/input.h>

#include <cstdio>
#include <cstring>
#include <string>

namespace {
int failures = 0;
void check(bool ok, const char *what)
{
    std::printf("%-58s %s\n", what, ok ? "ok" : "FAILED");
    if (!ok) ++failures;
}
} // namespace

int main()
{
    // ── 1. The generated tables are linked in ────────────────────────────
    // Each of these reads a different table in event-names.h.
    struct { unsigned int type; unsigned int code; const char *want; } names[] = {
        {EV_KEY, KEY_A,             "KEY_A"},
        {EV_KEY, KEY_LEFTCTRL,      "KEY_LEFTCTRL"},
        {EV_ABS, ABS_MT_POSITION_X, "ABS_MT_POSITION_X"},
        {EV_REL, REL_WHEEL,         "REL_WHEEL"},
        {EV_SW,  SW_LID,            "SW_LID"},
    };
    for (auto &n : names) {
        const char *got = libevdev_event_code_get_name(n.type, n.code);
        std::printf("   %-20s -> %s\n", n.want, got ? got : "(null)");
        check(got != nullptr && std::strcmp(got, n.want) == 0,
              (std::string("libevdev names ") + n.want).c_str());
    }

    // ── 2. …and the type table too ───────────────────────────────────────
    const char *t = libevdev_event_type_get_name(EV_ABS);
    check(t != nullptr && std::strcmp(t, "EV_ABS") == 0,
          "libevdev names the event TYPE table as well");

    // ── 3. The reverse direction, which uses a different table ───────────
    // Name -> code is what libinput's quirks parser does with a config file.
    check(libevdev_event_code_from_name(EV_KEY, "KEY_ESC") == KEY_ESC,
          "libevdev resolves a name back to its code");
    check(libevdev_event_code_from_name(EV_KEY, "KEY_NO_SUCH_THING") == -1,
          "…and a name that does not exist resolves to -1");

    // ── 4. A device object with no fd ────────────────────────────────────
    // libevdev_new is the allocation path libinput takes before it has an fd;
    // it must work with none.
    libevdev *dev = libevdev_new();
    check(dev != nullptr, "libevdev_new with no file descriptor");
    if (dev != nullptr) {
        libevdev_set_name(dev, "mcpp test device");
        check(std::strcmp(libevdev_get_name(dev), "mcpp test device") == 0,
              "…and its name round-trips");
        libevdev_free(dev);
    }

    std::printf("\n%d check(s) failed\n", failures);
    return failures == 0 ? 0 : 1;
}

#else
int main() { return 0; }
#endif
