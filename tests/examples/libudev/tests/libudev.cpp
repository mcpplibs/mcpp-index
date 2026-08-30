// compat.libudev — behavioral test against /sys, no daemon.
//
// libudev-zero reads /sys directly instead of talking to udevd, which is the
// whole reason it is here: a subos has no udev daemon, and an implementation
// that needed one would work on a developer's machine and nowhere else. So the
// test enumerates REAL devices — that is the thing that would silently return
// nothing if the package were built wrong.

#ifdef __linux__

#include <libudev.h>

#include <dlfcn.h>
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
    // ── 1. The context comes up without a daemon ─────────────────────────
    udev *ctx = udev_new();
    check(ctx != nullptr, "udev_new without a running udevd");
    if (ctx == nullptr) {
        std::printf("\n%d check(s) failed\n", failures);
        return 1;
    }

    // ── 2. …and it is THIS build, not the host's libudev ─────────────────
    // systemd's libudev carries the same soname. Only one is ever mapped and
    // nothing warns about the other, so the identity has to be pinned.
    {
        void *sym = ::dlsym(RTLD_DEFAULT, "udev_new");
        Dl_info info{};
        if (sym != nullptr && ::dladdr(sym, &info) != 0 && info.dli_fname != nullptr) {
            const std::string from = info.dli_fname;
            std::printf("   udev_new came from: %s\n", from.c_str());
            check(from.find("/usr/lib") == std::string::npos
                  && from.find("/lib/x86_64") == std::string::npos,
                  "the loaded libudev is not the host's");
        }
    }

    // ── 3. Real enumeration off /sys ─────────────────────────────────────
    // Every Linux machine has input devices under /sys/class/input, including
    // a container: the kernel exposes them regardless of who may open them.
    // Finding none means the /sys walk is broken, which is the failure this
    // package can actually have.
    udev_enumerate *e = udev_enumerate_new(ctx);
    check(e != nullptr, "udev_enumerate_new");
    if (e != nullptr) {
        udev_enumerate_add_match_subsystem(e, "input");
        check(udev_enumerate_scan_devices(e) == 0, "udev_enumerate_scan_devices(input)");

        int n = 0;
        const char *first = nullptr;
        for (udev_list_entry *le = udev_enumerate_get_list_entry(e);
             le != nullptr; le = udev_list_entry_get_next(le)) {
            if (first == nullptr) {
                first = udev_list_entry_get_name(le);
            }
            ++n;
        }
        std::printf("   %d input device node(s); first: %s\n", n, first ? first : "(none)");
        check(n > 0, "the /sys walk found input devices");

        // A device object out of that path, with its subsystem read back —
        // this is the call libinput makes for every device it opens.
        if (first != nullptr) {
            udev_device *d = udev_device_new_from_syspath(ctx, first);
            check(d != nullptr, "udev_device_new_from_syspath");
            if (d != nullptr) {
                const char *sub = udev_device_get_subsystem(d);
                std::printf("   subsystem: %s\n", sub ? sub : "(null)");
                check(sub != nullptr && std::strcmp(sub, "input") == 0,
                      "…and its subsystem reads back as \"input\"");
                udev_device_unref(d);
            }
        }
        udev_enumerate_unref(e);
    }

    udev_unref(ctx);
    std::printf("\n%d check(s) failed\n", failures);
    return failures == 0 ? 0 : 1;
}

#else
int main() { return 0; }
#endif
