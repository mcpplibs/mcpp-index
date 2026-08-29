// The whole point of the package, as a separate translation unit.
//
// This file includes STOCK <gbm.h> and nothing else — no mcpp_gbm.h, no helper
// declaration, no knowledge that compat.libgbm exists. It is what a consumer
// ported from any other build system looks like, and more importantly it is
// what a THIRD-PARTY library looks like from the inside: SDL2's KMSDRM
// backend, wlroots and ffmpeg's VAAPI hwcontext all call gbm_create_device()
// out of their own sources and will never call anything of ours.
//
// So if the backend path ever goes back to being something the application has
// to opt into, this file fails while gbm.cpp — which does include the optional
// header — could still pass. That asymmetry is the reason it exists.

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
    const char *dir = std::getenv("GBM_BACKENDS_PATH");
    check(dir != nullptr,
          "a <gbm.h>-only consumer inherits GBM_BACKENDS_PATH");

    if (dir != nullptr) {
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
