// openkal-posix through the index, observed through the C surface.
#include <cstdio>
#include <cstring>
#if defined(__linux__) || defined(__APPLE__)
#include <openkal.h>

int main() {
    int failures = 0;
    auto check = [&](bool held, const char* what) {
        if (!held) { std::printf("FAIL: %s\n", what); ++failures; }
    };
    const kal_u64 stated = kal_interfaces();
    check((stated & KAL_IFACE_FS) && (stated & KAL_IFACE_PROCESS) && (stated & KAL_IFACE_TASK),
          "the interfaces it provides are stated");
    check(!(stated & KAL_IFACE_NET) && !(stated & KAL_IFACE_PROF), "and those it does not are not");
    check(kal_stream_write(kal_stdout(), "openkal-posix\n", 14) == 14, "a stream is written");
    char sys[32] = {};
    const kal_intptr n = kal_env_system(sys, sizeof sys - 1);
    check(n > 0, "the system is named");
    kal_dir here{};
    check(kal_fs_preopen_count() > 0 && kal_fs_preopen(0, &here, nullptr, 0, nullptr) == kal_ok,
          "a directory is granted");
    kal_file f{};
    if (kal_fs_open(here, "okp-index.tmp", 13,
                    KAL_OPEN_WRITE | KAL_OPEN_CREATE | KAL_OPEN_TRUNCATE, &f) == kal_ok) {
        kal_stream_write(kal_fs_stream(f), "abc", 3);
        kal_fs_close_file(f);
        char b[4] = {};
        kal_file g{};
        check(kal_fs_open(here, "okp-index.tmp", 13, KAL_OPEN_READ, &g) == kal_ok
                  && kal_stream_read(kal_fs_stream(g), b, 3) == 3 && std::memcmp(b, "abc", 3) == 0,
              "a file is written and read back");
        if (g.h) kal_fs_close_file(g);
        kal_fs_remove(here, "okp-index.tmp", 13);
    } else {
        check(false, "a file is created");
    }
    if (failures == 0) std::printf("openkal-posix: the C surface answers\n");
    return failures == 0 ? 0 : 1;
}
#else
int main() { std::printf("openkal-posix: no POSIX C library is named on this system\n"); return 0; }
#endif
