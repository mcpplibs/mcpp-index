// compat.mtdev — behavioral test, no input device required.
//
// mtdev translates kernel multitouch protocol A into protocol B. The test
// exercises the translator's own state machine rather than a device: the
// interesting failure is a package that links but whose slot machinery was
// compiled out, and that shows up here rather than on a touchscreen.

#ifdef __linux__

#include <mtdev.h>
#include <mtdev-plumbing.h>
#include <linux/input.h>

#include <cstdio>
#include <cstring>

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
    // ── 1. A device object can be created and configured ─────────────────
    // mtdev_new/mtdev_init are the plumbing entry points: they set up the
    // slot state without needing an fd, which is what makes this testable.
    mtdev *dev = mtdev_new();
    check(dev != nullptr, "mtdev_new allocates a translator");
    if (dev == nullptr) {
        std::printf("\n%d check(s) failed\n", failures);
        return 1;
    }
    check(mtdev_init(dev) == 0, "mtdev_init sets up the slot state machine");

    // ── 2. It reports what it can translate ──────────────────────────────
    // ABS_MT_POSITION_X is the axis every protocol-A device carries; asking
    // about it exercises the capability table the translator is built from.
    mtdev_set_mt_event(dev, ABS_MT_POSITION_X, 1);
    check(mtdev_has_mt_event(dev, ABS_MT_POSITION_X) != 0,
          "a multitouch axis can be declared and read back");
    mtdev_set_mt_event(dev, ABS_MT_POSITION_X, 0);
    check(mtdev_has_mt_event(dev, ABS_MT_POSITION_X) == 0,
          "…and cleared again");

    // ── 3. With nothing fed in, nothing comes out ────────────────────────
    // mtdev_empty is the drain check libinput calls in its read loop. On a
    // fresh translator it must be true — a package whose buffers were
    // compiled wrong tends to report data that was never written.
    check(mtdev_empty(dev) != 0, "a fresh translator has no pending events");

    mtdev_close(dev);
    mtdev_delete(dev);
    check(true, "mtdev_close and mtdev_delete complete");

    std::printf("\n%d check(s) failed\n", failures);
    return failures == 0 ? 0 : 1;
}

#else
int main() { return 0; }
#endif
