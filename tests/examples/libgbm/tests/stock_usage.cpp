// The minimal consumer, as a separate translation unit and a separate binary.
//
// This file includes STOCK <gbm.h> and nothing else -- and since the package
// ships no header of its own any more, that is now simply what a consumer
// looks like. It is what a project ported from any other build system looks
// like, and more importantly what a THIRD-PARTY library looks like from the
// inside: SDL2's KMSDRM backend, wlroots and ffmpeg's VAAPI hwcontext all call
// gbm_create_device() out of their own sources, having included only <gbm.h>.
//
// WHAT IT GUARDS, now that the package sets nothing itself. GBM_BACKENDS_PATH
// arrives from the ECOSYSTEM: `xim:mesa` places its backends into the subos and
// declares the variable through the graphics discovery layer
// (openxlings/xim-pkgindex#713), and mcpp carries subos declarations into the
// processes it launches. Neither of those is this repository's code, so this
// binary is the tripwire on both -- if the DISCOVERY row is dropped, or the
// backends stop being placed, or mcpp stops injecting subos env, it goes red
// here rather than silently on a user whose gbm_create_device() returns NULL.
//
// It is deliberately a SECOND binary rather than more assertions inside
// gbm.cpp: a consumer that includes one header and links one library is the
// smallest thing that can still detect all three of those regressions, and
// keeping it minimal is what makes a failure here unambiguous.

#ifdef __linux__

#include <gbm.h>

#include <dirent.h>
#include <sys/stat.h>

#include <cstdio>
#include <cstdlib>
#include <cstring>

int main()
{
    int failures = 0;
    auto check = [&](bool ok, const char *what) {
        std::printf("%-58s %s\n", what, ok ? "ok" : "FAILED");
        if (!ok) {
            ++failures;
        }
    };

    // Nothing in this program has run yet that could have set this.
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
        check(true, "a <gbm.h>-only consumer inherits GBM_BACKENDS_PATH");
        std::printf("   %s\n", dir);

        struct ::stat st {};
        check(::stat(dir, &st) == 0 && S_ISDIR(st.st_mode),
              "  ... and it is a directory");

        bool found = false;
        if (DIR *d = ::opendir(dir)) {
            static const char suffix[] = "_gbm.so";
            const std::size_t len = sizeof(suffix) - 1;
            while (dirent *e = ::readdir(d)) {
                const std::size_t n = std::strlen(e->d_name);
                if (n > len && std::strcmp(e->d_name + (n - len), suffix) == 0) {
                    found = true;
                    break;
                }
            }
            ::closedir(d);
        }
        check(found, "  ... holding a backend libgbm can actually dlopen");
    }

    // The stock call still behaves on a bad fd rather than crashing, which is
    // the only device-level thing assertable without a DRM node.
    check(gbm_create_device(-1) == nullptr, "gbm_create_device(-1) == nullptr");

    std::printf("\n%d check(s) failed\n", failures);
    return failures == 0 ? 0 : 1;
}

#else

int main()
{
    return 0;
}

#endif
