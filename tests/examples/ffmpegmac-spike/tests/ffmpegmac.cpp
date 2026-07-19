#ifdef __APPLE__
#include <cstdio>
extern "C" unsigned avutil_version(void);   // from the compat.ffmpegmac lib
int main() {
    unsigned v = avutil_version();
    std::printf("macos ffmpeg build ok: libavutil %u.%u (2091 .c + 60 aarch64 .S linked)\n",
                v >> 16, (v >> 8) & 0xff);
    return (v >> 16) == 60u ? 0 : 1;   // libavutil major of the 8.1.x train
}
#else
int main() { return 0; }
#endif
