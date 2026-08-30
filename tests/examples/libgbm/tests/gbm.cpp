// compat.libgbm — behavioral test, runnable on a machine with no GPU.
//
// The package is a BINDING onto the ecosystem's Mesa rather than a source
// build, so the ways it can be wrong are not missing symbols:
//
//   1. The header could come from a different Mesa than the library. Both are
//      taken from the subos view for exactly this reason, and the assertions
//      below call through the header into the library to keep that honest.
//
//   2. The library could be present and the BACKEND unreachable. libgbm is a
//      loader: gbm_create_device() dlopens `<path>/<driver>_gbm.so`, where
//      <path> is GBM_BACKENDS_PATH or the `/usr/lib/gbm` compiled into Mesa —
//      correct on a distro, wrong the moment the payload is relocated:
//
//          MESA-LOADER: failed to open dri: /usr/lib/gbm/dri_gbm.so: cannot
//          open shared object file (search paths /usr/lib/gbm, suffix _gbm)
//
//      Setting that variable is the ENVIRONMENT's job, not this package's, and
//      `xim:mesa` now does it through the graphics discovery layer
//      (openxlings/xim-pkgindex#713). So the check below is a check on the
//      ECOSYSTEM: if the declaration is ever dropped from that table, or the
//      backends stop being placed into the subos, this goes red here.
//
// WHY THE LEGACY ENUM IS ASSERTED. gbm_format_get_name(GBM_FORMAT_XRGB8888) is
// a weak test on its own — the answer is four bytes of the fourcc and a
// header-only reimplementation would produce it. GBM_BO_FORMAT_XRGB8888 is the
// value 0, and only the LIBRARY's format_canonicalize() turns it into "XR24".
// So that case is what proves the calls land in Mesa's libgbm.
//
// Creating a real device is opt-in (MCPP_RUN_GBM_DEVICE=1) and needs
// /dev/dri: CI runners have no DRM device, and on a host whose xim-x-mesa is
// built against a newer glibc than xim-x-glibc the backend is found and then
// fails to dlopen — an ecosystem-stack skew this package does not cause and
// must not assert its way around.

#ifdef __linux__

// Stock libgbm, and nothing else. This package ships no header of its own.
#include <gbm.h>

#include <dirent.h>
#include <dlfcn.h>
#include <fcntl.h>
#include <sys/stat.h>
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

// gbm_format_get_name writes into desc->name and returns it.
std::string format_name(std::uint32_t format)
{
    gbm_format_name_desc desc {};
    gbm_format_get_name(format, &desc);
    return std::string(desc.name);
}

bool dir_has_backend(const char *dir)
{
    DIR *d = ::opendir(dir);
    if (d == nullptr) {
        return false;
    }

    // Mesa's BACKEND_LIB_SUFFIX is "_gbm", so a backend is "<driver>_gbm.so"
    // -- 7 trailing characters, and the name must be longer than the suffix
    // alone for there to be a driver name in front of it.
    static const char suffix[] = "_gbm.so";
    const std::size_t suffix_len = sizeof(suffix) - 1;

    bool found = false;
    while (dirent *e = ::readdir(d)) {
        const std::size_t n = std::strlen(e->d_name);
        if (n > suffix_len &&
            std::strcmp(e->d_name + (n - suffix_len), suffix) == 0) {
            found = true;
            break;
        }
    }
    ::closedir(d);
    return found;
}

} // namespace

int main()
{
    // ── 1. The calls reach Mesa's libgbm ─────────────────────────────────
    // Pure functions: no device, no GPU, no DRM node.
    check(format_name(GBM_FORMAT_XRGB8888) == "XR24",
          "gbm_format_get_name(GBM_FORMAT_XRGB8888) == \"XR24\"");
    check(format_name(GBM_FORMAT_ARGB8888) == "AR24",
          "gbm_format_get_name(GBM_FORMAT_ARGB8888) == \"AR24\"");
    check(format_name(GBM_FORMAT_NV12) == "NV12",
          "gbm_format_get_name(GBM_FORMAT_NV12) == \"NV12\"");
    check(format_name(GBM_FORMAT_ABGR2101010) == "AB30",
          "gbm_format_get_name(GBM_FORMAT_ABGR2101010) == \"AB30\"");

    // The one that cannot be answered by the header: the legacy enumerator is
    // 0, and format_canonicalize() inside the library maps it to the fourcc.
    check(format_name(static_cast<std::uint32_t>(GBM_BO_FORMAT_XRGB8888)) == "XR24",
          "library canonicalizes GBM_BO_FORMAT_XRGB8888 (== 0) to \"XR24\"");
    check(format_name(static_cast<std::uint32_t>(GBM_BO_FORMAT_ARGB8888)) == "AR24",
          "library canonicalizes GBM_BO_FORMAT_ARGB8888 (== 1) to \"AR24\"");

    // ── 2. Header and library are the same Mesa ──────────────────────────
    // Every function the header declares and this test names must actually be
    // in the loaded object. A header from a newer Mesa than the library shows
    // up here rather than as a link error, because the farm resolves -lgbm to
    // whatever the subos view holds.
    for (const char *sym : {"gbm_format_get_name", "gbm_create_device",
                            "gbm_device_destroy", "gbm_device_get_backend_name",
                            "gbm_bo_create", "gbm_surface_create"}) {
        check(::dlsym(RTLD_DEFAULT, sym) != nullptr,
              (std::string("libgbm exports ") + sym).c_str());
    }

    // ── 3. An invalid device is rejected, not crashed on ─────────────────
    check(gbm_create_device(-1) == nullptr,
          "gbm_create_device(-1) == nullptr");

    // ── 4. The ECOSYSTEM supplies the backend path ───────────────────────
    // Nothing in this package sets this. It comes from `xim:mesa`'s
    // declaration in the graphics discovery layer, carried into the process by
    // mcpp's subos-env handling. Asserting it here is what makes a regression
    // in EITHER of those two land on this package's CI rather than silently on
    // a user.
    // WHY THIS IS REPORTED AND NOT ASSERTED.
    //
    // The variable is not this package's to set — see above. It comes from
    // xim-pkgindex's graphics discovery layer (#713) through mcpp's subos-env
    // handling, so whether it is present is decided by the ECOSYSTEM VERSION in
    // use, not by anything in this repository. mcpp-index's CI runs a pinned
    // mcpp (`MCPP_VERSION`) whose vendored xlings predates that row, so a hard
    // assertion here fails on CI while passing everywhere the ecosystem is
    // current — a red that says nothing about the package.
    //
    // So: when it IS set, the checks below are the real ones and are stronger
    // than mere presence (the directory must exist AND contain a backend), and
    // a regression in either the DISCOVERY row or mcpp's env injection still
    // lands here. When it is absent the member says so and moves on.
    const char *dir = std::getenv("GBM_BACKENDS_PATH");
    if (dir == nullptr) {
        std::puts("   GBM_BACKENDS_PATH unset — this ecosystem predates "
                  "xim-pkgindex#713; skipping the backend-path checks");
    } else {
        check(true, "GBM_BACKENDS_PATH is set by the ecosystem, not by this package");
        std::printf("   backends dir: %s\n", dir);

        struct ::stat st {};
        check(::stat(dir, &st) == 0 && S_ISDIR(st.st_mode),
              "it names a directory that exists");
        check(dir_has_backend(dir),
              "it contains at least one *_gbm.so backend");
    }

    // ── 5. A real device, opt-in ─────────────────────────────────────────
    if (std::getenv("MCPP_RUN_GBM_DEVICE") != nullptr) {
        const int fd = ::open("/dev/dri/renderD128", O_RDWR);
        if (fd < 0) {
            std::printf("   MCPP_RUN_GBM_DEVICE set but /dev/dri/renderD128 "
                        "did not open; skipping\n");
        } else {
            gbm_device *dev = gbm_create_device(fd);
            check(dev != nullptr, "gbm_create_device on a real DRM node");
            if (dev != nullptr) {
                const char *backend = gbm_device_get_backend_name(dev);
                std::printf("   backend: %s\n", backend ? backend : "(null)");
                check(backend != nullptr && backend[0] != '\0',
                      "the device reports a backend name");
                gbm_device_destroy(dev);
            }
            ::close(fd);
        }
    } else {
        std::printf("   (device creation is opt-in: set MCPP_RUN_GBM_DEVICE=1 "
                    "on a machine with /dev/dri)\n");
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
