// freedesktop.egl — behavioral test, runnable with no GPU and no display.
//
// Every FUNCTION and TYPE below comes from `import khronos.egl;`. <EGL/egl.h> is
// included for the EGL_* CONSTANTS only: they are macros, and no module can
// export a macro. So the file compiling is itself the first assertion — the
// module's export list has to cover everything used here — and the file
// linking is the second.
//
// ─────────────────────────────────────────────────────────────────────────
// EVERY ASSERTION HOLDS WITH ZERO VENDOR DRIVERS INSTALLED.
//
// libEGL is a DISPATCH: with no vendor it can answer questions about itself
// and nothing else. Upstream returns the empty string outright when the vendor
// list is empty (`libegl.c:928`), so an "it lists some EGL_EXT_ extension"
// check measures whether the MACHINE has a driver, not whether this package
// built libEGL. Vendor-dependent facts are reported below, or asserted only
// once their precondition is visibly met.
//
// ─────────────────────────────────────────────────────────────────────────
// THE PART THAT IS EASY TO GET FALSELY GREEN
//
// The ecosystem payload `xim:libglvnd` carries its own `libEGL.so.1` with the
// SAME soname, and on a machine with the graphics stack installed it is
// reachable. Only ONE library with a given soname is ever mapped, and nothing
// warns about the other — so a test that merely calls EGL functions can pass
// while this package's build is never loaded at all. Checks 2 and 3 pin the
// identity from both directions: what the library says it is, and what path
// its code actually came from. compat.libdrm's test does the same thing for
// the same reason.

#ifdef __linux__

#include <EGL/egl.h>   // the EGL_* macros only

#include <dlfcn.h>

#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <string>

import khronos.egl;

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
    // ── 1. The module carries the API ────────────────────────────────────
    EGLDisplay none = EGL_NO_DISPLAY;
    check(none == EGL_NO_DISPLAY, "EGLDisplay and EGL_NO_DISPLAY agree");

    // ── 2. It is GLVND's libEGL ──────────────────────────────────────────
    // EGL_VERSION on EGL_NO_DISPLAY is answered by libglvnd before any vendor
    // is consulted — a literal "1.5 libglvnd" — so it needs no driver and no
    // display, and a different implementation would answer differently.
    const char *version = eglQueryString(EGL_NO_DISPLAY, EGL_VERSION);
    check(version != nullptr && std::strcmp(version, "1.5 libglvnd") == 0,
          "eglQueryString(EGL_NO_DISPLAY, EGL_VERSION) is libglvnd's");
    std::printf("   EGL_VERSION: %s\n", version ? version : "(null)");

    // ── 3. …and it is THIS package's build, not the payload's ────────────
    // Same soname, so only one libEGL.so.1 is mapped and the loser is silent.
    // dladdr reports the object a symbol actually came from; if the path names
    // the ecosystem payload, this package built a library nobody loads.
    {
        Dl_info info{};
        const bool located =
            ::dladdr(reinterpret_cast<void *>(&eglQueryString), &info) != 0
            && info.dli_fname != nullptr;
        check(located, "dladdr locates the loaded libEGL");
        if (located) {
            const std::string from = info.dli_fname;
            std::printf("   loaded from: %s\n", from.c_str());
            check(from.find("xim-x-libglvnd") == std::string::npos,
                  "the loaded libEGL is not the ecosystem payload's copy");
        }
    }

    // ── 4. The error path works, with no driver ──────────────────────────
    // EGL_VENDOR without a display is invalid; libglvnd must report
    // EGL_BAD_DISPLAY rather than crash or silently answer. This exercises
    // __eglReportError and the thread-local error state.
    check(eglQueryString(EGL_NO_DISPLAY, EGL_VENDOR) == nullptr,
          "an invalid no-display query returns null");
    check(eglGetError() == EGL_BAD_DISPLAY,
          "…and leaves EGL_BAD_DISPLAY in the thread's error state");

    // ── 5. libEGL reaches libGLdispatch ──────────────────────────────────
    // Resolving a CORE entry point runs the path from libEGL into
    // libGLdispatch. That library is built by a sibling member of the same
    // fork and reached by PATH rather than through the index — so this is also
    // the check that the intra-package edge survived publication.
    check(eglGetProcAddress("eglInitialize") != nullptr,
          "eglGetProcAddress(\"eglInitialize\") resolves");
    check(eglGetProcAddress("eglNoSuchFunctionEXT") == nullptr,
          "…and a name that does not exist resolves to null");

    // ── 6. What the environment supplies, reported ───────────────────────
    // The package compiles in an EMPTY vendor-config default on purpose, so a
    // driver is only ever found through `__EGL_VENDOR_LIBRARY_DIRS`, which
    // `xim:mesa` declares (xim-pkgindex#713) exactly as it declares
    // GBM_BACKENDS_PATH for compat.libgbm. A runner with no GPU stack is not a
    // defect in this package, so none of this is asserted — but when a vendor
    // IS found, the extension list must look like one.
    std::puts("");
    const char *dirs = std::getenv("__EGL_VENDOR_LIBRARY_DIRS");
    std::printf("   __EGL_VENDOR_LIBRARY_DIRS = %s\n",
                dirs ? dirs : "(unset — the ecosystem declares it)");

    const char *client_exts = eglQueryString(EGL_NO_DISPLAY, EGL_EXTENSIONS);
    check(client_exts != nullptr,
          "eglQueryString(EGL_NO_DISPLAY, EGL_EXTENSIONS) answers");
    if (client_exts != nullptr && client_exts[0] != '\0') {
        std::printf("   client extensions: %.90s%s\n",
                    client_exts, std::strlen(client_exts) > 90 ? "…" : "");
        check(std::strstr(client_exts, "EGL_EXT_client_extensions") != nullptr,
              "a vendor was found, so the client extension list is populated");
    } else {
        std::puts("   client extensions: (none — no vendor driver here; the "
                  "dispatch itself is fine)");
    }

    std::printf("\n%d check(s) failed\n", failures);
    return failures == 0 ? 0 : 1;
}

#else

int main() { return 0; }

#endif
