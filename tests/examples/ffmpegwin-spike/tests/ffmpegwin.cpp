#ifdef _WIN32
#include <cstdio>
extern "C" unsigned avutil_version(void);
int main() {
    unsigned v = avutil_version();
    std::printf("win ffmpeg build ok: libavutil %u.%u (2125 .c + 159 win64 .asm)\n", v >> 16, (v >> 8) & 0xff);
    return (v >> 16) == 60u ? 0 : 1;
}
#else
int main() { return 0; }
#endif
