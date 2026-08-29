// compat.egl — behavioral test, runnable with no GPU and no display.
//
// What can be wrong here, in order of how quietly it fails:
//
//   1. THE HEADER DOES NOT PARSE. `EGL/eglplatform.h` opens with
//      `#include <KHR/khrplatform.h>`, and this package deliberately does not
//      ship KHR/ — it takes it from compat.khrplatform rather than becoming a
//      third provider of that directory. So compilation itself is the first
//      assertion, and it is the one that breaks if the dependency edge goes.
//
//   2. THE DISPATCH LIBRARY IS ABSENT while headers are present. The dlsym
//      checks pin that.
//
//   3. THE GBM PLATFORM TOKEN IS MISSING. `EGL_PLATFORM_GBM_KHR` is what makes
//      compat.libgbm useful for rendering rather than only allocation --
//      eglGetPlatformDisplay(EGL_PLATFORM_GBM_KHR, gbm_device, NULL) is the
//      whole headless-GPU entry point. A libglvnd built without that extension
//      would leave the GBM package able to allocate and unable to render.
//
// Creating a display needs a real GPU, so that is opt-in
// (MCPP_RUN_EGL_DISPLAY=1). Everything else runs on a bare CI runner.

#ifdef __linux__

#include <EGL/egl.h>
#include <EGL/eglext.h>

#include <dlfcn.h>

#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <string>

namespace {

int failures = 0;

void check(bool ok, const char *what)
{
    std::printf("%-58s %s\n", what, ok ? "ok" : "FAILED");
    if (!ok) {
        ++failures;
    }
}

} // namespace

int main()
{
    // ── 1. The headers parsed, and KHR came from compat.khrplatform ──────
    // Reaching this line means <KHR/khrplatform.h> resolved. Assert a type
    // that comes from it so the dependency is explicit rather than implied.
    check(sizeof(khronos_int32_t) == 4,
          "KHR/khrplatform.h resolved (via compat.khrplatform)");
    check(EGL_SUCCESS == 0x3000, "EGL/egl.h provides the EGL_SUCCESS token");

    // ── 2. The GBM platform token exists ─────────────────────────────────
    // This is the seam with compat.libgbm. Without it the two packages cannot
    // be combined, which is most of the reason to want EGL here at all.
    check(EGL_PLATFORM_GBM_KHR == 0x31D7,
          "EGL_PLATFORM_GBM_KHR is present (the compat.libgbm seam)");

    // ── 3. The dispatch library is really linked ─────────────────────────
    for (const char *sym : {"eglGetPlatformDisplay", "eglInitialize",
                            "eglCreateContext", "eglMakeCurrent",
                            "eglQueryString", "eglGetProcAddress"}) {
        check(::dlsym(RTLD_DEFAULT, sym) != nullptr,
              (std::string("libEGL exports ") + sym).c_str());
    }

    // ── 4. The client-extension query answers without a display ──────────
    // EGL_EXT_client_extensions makes this legal on EGL_NO_DISPLAY, and it is
    // the one call that exercises the dispatch layer without hardware.
    const char *ext = eglQueryString(EGL_NO_DISPLAY, EGL_EXTENSIONS);
    std::printf("   client extensions: %s\n",
                ext ? (ext[0] ? ext : "(empty)") : "(null)");
    check(ext != nullptr,
          "eglQueryString(EGL_NO_DISPLAY, EGL_EXTENSIONS) answers");

    // ── 5. A real display, opt-in ────────────────────────────────────────
    if (std::getenv("MCPP_RUN_EGL_DISPLAY") != nullptr) {
        EGLDisplay dpy = eglGetDisplay(EGL_DEFAULT_DISPLAY);
        std::printf("   eglGetDisplay = %p\n", (void *)dpy);
        if (dpy != EGL_NO_DISPLAY) {
            EGLint major = 0, minor = 0;
            const EGLBoolean ok = eglInitialize(dpy, &major, &minor);
            std::printf("   eglInitialize = %d (EGL %d.%d)\n", (int)ok, major, minor);
            check(ok == EGL_TRUE, "eglInitialize on the default display");
            if (ok) eglTerminate(dpy);
        }
    } else {
        std::printf("   (display creation is opt-in: set MCPP_RUN_EGL_DISPLAY=1)\n");
    }

    std::printf("\n%d check(s) failed\n", failures);
    return failures == 0 ? 0 : 1;
}

#else

int main()
{
    return 0;
}

#endif
