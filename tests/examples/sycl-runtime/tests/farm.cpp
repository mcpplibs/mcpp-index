// What compat.sycl-runtime is asserted to do.
//
// A machine with no GPU is a legitimate configuration and is what every runner
// in this repository is, so the test cannot require a device. It asserts the
// properties that hold on both kinds of machine.
//
//   1. The package resolves, builds and links. The failure this package exists
//      to prevent is a RUNTIME one -- `libsycl.so.9 not found on the search
//      path this artifact will actually use` -- so linking alone is not the
//      whole assertion, which is why (2) exists.
//
//   2. `libsycl.so.9` loads from inside mcpp's own loader. That is the entire
//      job of the farm, and it is a property of this package rather than of the
//      machine: the payload is installed by the dependency edge, so a runner
//      with no GPU must still get this far.
//
//   3. Its chain loads too. `libsycl.so.9` needs `libur_loader.so.0`, which
//      needs `libumf.so.1`, and both are in the payload. A farm holding
//      `libsycl.so.9` alone would satisfy (2) and then enumerate no devices --
//      the failure that looks like "this machine has no GPU". dlopen of the
//      leaf is what separates the two.
//
// Which devices exist is deliberately NOT asserted: that is the machine's
// answer, not this package's.
#include <cstdio>

#ifndef __linux__
int main() {
    std::printf("not applicable on this platform\n");
    return 0;
}
#else
#include <dlfcn.h>

namespace {

// Returns 0 when the library loads and carries the symbol, 1 otherwise. The
// symbol matters: a farm that linked a stale or wrong-class file would resolve
// the library and fail here, which is the difference between "found something"
// and "found the runtime".
int must_load(const char* soname, const char* symbol) {
    void* h = dlopen(soname, RTLD_LAZY);
    if (!h) {
        std::printf("FAIL %s: %s\n", soname, dlerror());
        return 1;
    }
    void* sym = symbol ? dlsym(h, symbol) : reinterpret_cast<void*>(h);
    std::printf("%s %s%s%s\n", sym ? "ok  " : "FAIL", soname,
                symbol ? " symbol=" : "", symbol ? symbol : "");
    return sym ? 0 : 1;
}

} // namespace

int main() {
    int bad = 0;
    // The SYCL runtime, by soname, and the C entry point every SYCL program
    // reaches it through.
    bad += must_load("libsycl.so.9", "__sycl_register_lib");
    // The chain. `libumf.so.1` is the leaf the adapters need, and the one a
    // farm of `libsycl.so.9` alone would leave unreachable.
    bad += must_load("libur_loader.so.0", nullptr);
    bad += must_load("libumf.so.1", nullptr);
    return bad ? 1 : 0;
}
#endif
