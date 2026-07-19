#if defined(__linux__) || defined(__APPLE__)
#include <cstdio>
extern "C" unsigned avutil_version(void);
int main() {
    unsigned v = avutil_version();
    std::printf("ffmpeg multi-platform build ok: libavutil %u.%u\n", v >> 16, (v >> 8) & 0xff);
    return (v >> 16) == 60u ? 0 : 1;
}
#else
int main() { return 0; }
#endif
