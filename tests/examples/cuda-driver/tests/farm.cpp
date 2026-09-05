// What compat.cuda-driver is asserted to do, and what it is not.
//
// A machine with no NVIDIA driver is a legitimate configuration and is what
// every runner in this repository is, so the test cannot require a device. It
// asserts the two properties that hold on both kinds of machine:
//
//   1. The package resolves, builds and links. That alone covers the failure
//      this package exists to prevent, because the failure is a LINK-time one:
//      an unversioned libcuda.so harvested into a directory mcpp puts on the
//      link line would be picked up by -lcuda and bind the build to one
//      machine's driver. The patterns are versioned precisely so that cannot
//      happen, and a build that links proves it did not.
//
//   2. Where a driver is present, the farm reaches it. Guarded on the driver
//      actually being there rather than skipped by a marker, so the assertion
//      is real on a machine with a GPU and vacuous on one without, and neither
//      case is reported as a pass of the other.
#include <cstdio>

// The adapter under test exists only on Linux, so the assertion does too. The
// file still compiles everywhere, which is what keeps it from rotting silently
// on the two platforms that do not exercise it.
#ifndef __linux__
int main() {
    std::printf("not applicable on this platform\n");
    return 0;
}
#else
#include <dlfcn.h>

int main() {
    // The driver's userspace library, by soname. The farm's whole job is to
    // make this resolve from inside mcpp's own loader, which does not search
    // the host's library path.
    void* h = dlopen("libcuda.so.1", RTLD_LAZY);
    if (!h) {
        // No driver on this machine. The farm is empty, which is correct.
        std::printf("no host driver: %s\n", dlerror());
        return 0;
    }
    // Present: then the symbol every CUDA runtime looks for must be there too.
    // A farm that linked a stale or wrong-class file would resolve the library
    // and fail here, which is the difference between "found something" and
    // "found the driver".
    void* sym = dlsym(h, "cuInit");
    std::printf("host driver present, cuInit=%p\n", sym);
    dlclose(h);
    return sym ? 0 : 1;
}
#endif
