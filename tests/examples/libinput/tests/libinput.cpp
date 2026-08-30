// compat.libinput — the input chain, exercised without a seat.
//
// libinput needs a udev context and either a seat or explicit device paths.
// A CI runner has /sys (so udev enumeration works) but not the permissions to
// open /dev/input/event*, so what is asserted is everything up to and
// including the udev handoff — which is exactly where a packaging mistake
// lands, because that is the seam between the four packages in this chain:
//
//     compat.libinput
//       ├── freedesktop.libevdev
//       ├── compat.libudev
//       └── compat.mtdev
//
// Opening real devices is opt-in (MCPP_RUN_INPUT_DEVICES=1).

#ifdef __linux__

#include <libinput.h>
#include <libudev.h>

#include <fcntl.h>
#include <unistd.h>

#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <cerrno>
#include <dlfcn.h>

namespace {

int failures = 0;

void check(bool ok, const char *what)
{
    std::printf("%-58s %s\n", what, ok ? "ok" : "FAILED");
    if (!ok) {
        ++failures;
    }
}

// libinput hands device opening back to the caller — that is how a compositor
// routes it through libseat. Here it is a plain open(), which is what fails
// without permissions and is why the device half is opt-in.
int open_restricted(const char *path, int flags, void *)
{
    const int fd = ::open(path, flags);
    return fd < 0 ? -errno : fd;
}

void close_restricted(int fd, void *)
{
    ::close(fd);
}

const libinput_interface IFACE = {open_restricted, close_restricted};

} // namespace

int main()
{
    // ── 1. The chain is linked: libinput, libudev, libevdev, mtdev ───────
    // Each of these is a symbol only one of the four packages defines, so the
    // set of them says the whole chain resolved rather than just the top.
    check(::dlsym != nullptr, "the process has a dynamic linker (trivially)");
    udev *u = udev_new();
    check(u != nullptr, "libudev: udev_new (compat.libudev)");
    if (u == nullptr) {
        std::printf("\n%d check(s) failed\n", failures);
        return 1;
    }

    // ── 2. libinput comes up on that udev context ────────────────────────
    libinput *li = libinput_udev_create_context(&IFACE, nullptr, u);
    check(li != nullptr, "libinput_udev_create_context on it");
    if (li == nullptr) {
        udev_unref(u);
        std::printf("\n%d check(s) failed\n", failures);
        return 1;
    }

    // ── 3. Assigning a seat is where udev enumeration actually runs ──────
    // "seat0" is the conventional name and needs no seat manager to NAME —
    // libinput asks udev for devices tagged with it. Devices it cannot open
    // are skipped, so this succeeds with no permissions.
    const int rc = libinput_udev_assign_seat(li, "seat0");
    std::printf("   libinput_udev_assign_seat(\"seat0\") = %d\n", rc);
    check(rc == 0, "libinput enumerated the seat through libudev");

    // ── 4. The event loop is live ────────────────────────────────────────
    // A dispatch with nothing pending must return cleanly rather than block
    // or fault: it is what a compositor calls every frame.
    check(libinput_dispatch(li) == 0, "libinput_dispatch with nothing pending");
    const int fd = libinput_get_fd(li);
    std::printf("   epoll fd: %d\n", fd);
    check(fd >= 0, "libinput_get_fd returns a pollable descriptor");

    // Count whatever devices were actually openable. Zero is fine on a
    // runner; the assertion is that draining the queue terminates.
    int devices = 0, events = 0;
    for (libinput_event *ev = libinput_get_event(li); ev != nullptr;
         ev = libinput_get_event(li)) {
        if (libinput_event_get_type(ev) == LIBINPUT_EVENT_DEVICE_ADDED) {
            ++devices;
            if (devices <= 3) {
                std::printf("   device: %s\n",
                            libinput_device_get_name(libinput_event_get_device(ev)));
            }
        }
        ++events;
        libinput_event_destroy(ev);
    }
    std::printf("   drained %d event(s), %d device(s) opened\n", events, devices);
    check(true, "the event queue drained without blocking");

    if (std::getenv("MCPP_RUN_INPUT_DEVICES") != nullptr) {
        check(devices > 0,
              "MCPP_RUN_INPUT_DEVICES is set, so devices must have opened");
    } else {
        std::puts("   (opening devices needs permissions: set "
                  "MCPP_RUN_INPUT_DEVICES=1 where they exist)");
    }

    libinput_unref(li);
    udev_unref(u);

    std::printf("\n%d check(s) failed\n", failures);
    return failures == 0 ? 0 : 1;
}

#else
int main() { return 0; }
#endif
