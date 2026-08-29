// compat.libdrm — behavioral test, runnable with no GPU and no DRM node.
//
// Three things can be wrong with this package and none is a missing symbol.
//
//   1. THE INCLUDE LAYOUT. libdrm splits its headers across two roots — the
//      public ones (`xf86drm.h`) at the include root, the uapi ones (`drm.h`,
//      `drm_mode.h`, `drm_fourcc.h`) under `libdrm/` — and `xf86drm.h` itself
//      does `#include <drm.h>`. Exposing one root fails at line 40 of the
//      header, before any of this code exists. So the fact that this file
//      COMPILES is the first assertion, and it is not a trivial one.
//
//   2. THE LIBRARY COULD BE ABSENT while the headers are present. The dlsym
//      checks below pin that: the farm resolves `-ldrm` out of the subos view,
//      and a header-only package would sail past compilation and fail here.
//
//   3. THE UAPI CONSTANTS COULD DISAGREE with the library's. drm_fourcc.h is
//      the kernel's, and DRM_FORMAT_XRGB8888 must be the same fourcc GBM calls
//      GBM_FORMAT_XRGB8888 — the two APIs exchange exactly these values across
//      the gbm_bo -> drmModeAddFB2 boundary, so a mismatch would surface as a
//      display that shows the wrong colours rather than as an error.
//
// Opening a real DRM device is opt-in (MCPP_RUN_DRM_DEVICE=1): CI runners have
// no /dev/dri at all.

#ifdef __linux__

#include <xf86drm.h>        // public API; pulls <drm.h> from the second root
#include <xf86drmMode.h>    // the KMS family
#include <drm_fourcc.h>     // uapi, from the libdrm/ root

#include <dlfcn.h>
#include <fcntl.h>
#include <unistd.h>

#include <cstdint>
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
    // ── 1. Both include roots resolved ───────────────────────────────────
    // Reaching this line at all means <xf86drm.h> found the <drm.h> it
    // includes. Assert a constant from each root so the check is explicit
    // rather than implied by compilation succeeding.
    check(DRM_MODE_TYPE_PREFERRED != 0,
          "xf86drmMode.h (public root) provides DRM_MODE_TYPE_PREFERRED");
    check(DRM_FORMAT_XRGB8888 != 0,
          "drm_fourcc.h (libdrm/ root) provides DRM_FORMAT_XRGB8888");

    // ── 2. The fourcc agrees with GBM's ──────────────────────────────────
    // gbm_bo_get_format() returns a value handed straight to drmModeAddFB2.
    // 'X','R','2','4' little-endian — the same number compat.libgbm asserts as
    // "XR24". If these ever diverge, a KMS consumer shows wrong colours and
    // nothing reports an error.
    check(DRM_FORMAT_XRGB8888 == ((std::uint32_t)'X' | ((std::uint32_t)'R' << 8)
                                  | ((std::uint32_t)'2' << 16)
                                  | ((std::uint32_t)'4' << 24)),
          "DRM_FORMAT_XRGB8888 is the 'XR24' fourcc GBM also uses");

    // ── 3. The library is really linked ──────────────────────────────────
    for (const char *sym : {"drmGetVersion", "drmFreeVersion", "drmModeGetResources",
                            "drmModeAddFB2", "drmModeSetCrtc", "drmPrimeHandleToFD"}) {
        check(::dlsym(RTLD_DEFAULT, sym) != nullptr,
              (std::string("libdrm exports ") + sym).c_str());
    }

    // ── 4. An invalid fd is rejected, not crashed on ─────────────────────
    check(drmGetVersion(-1) == nullptr, "drmGetVersion(-1) == nullptr");

    // ── 5. A real device, opt-in ─────────────────────────────────────────
    if (std::getenv("MCPP_RUN_DRM_DEVICE") != nullptr) {
        const int fd = ::open("/dev/dri/card0", O_RDWR);
        if (fd < 0) {
            std::printf("   MCPP_RUN_DRM_DEVICE set but /dev/dri/card0 did not "
                        "open; skipping\n");
        } else {
            drmVersionPtr v = drmGetVersion(fd);
            check(v != nullptr, "drmGetVersion on a real DRM node");
            if (v != nullptr) {
                std::printf("   driver: %s\n", v->name ? v->name : "(null)");
                drmFreeVersion(v);
            }
            ::close(fd);
        }
    } else {
        std::printf("   (device access is opt-in: set MCPP_RUN_DRM_DEVICE=1 on "
                    "a machine with /dev/dri)\n");
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
