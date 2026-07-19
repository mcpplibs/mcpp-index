// compat.ffmpeg end-to-end assertion: the full-profile source build must
// expose its major decoders and demuxers, and library versions must match the
// vendored 8.1.2 release. Linux-only (see mcpp.toml).
#if defined(__linux__) || defined(__APPLE__) || defined(_WIN32)
extern "C" {
#include <libavcodec/avcodec.h>
#include <libavformat/avformat.h>
}

int main() {
    if ((avutil_version() >> 16) != 60) return 1;   // n8.1.x: libavutil major 60
    if ((avcodec_version() >> 16) != 62) return 2;
    if ((avformat_version() >> 16) != 62) return 3;

    const char* decoders[] { "h264", "hevc", "av1", "aac" };
    for (const char* name : decoders)
        if (!avcodec_find_decoder_by_name(name)) return 4;

    void* it { nullptr };
    int demuxers { 0 };
    while (av_demuxer_iterate(&it)) ++demuxers;
    if (demuxers <= 300) return 5;                  // full profile registers 358

    return 0;
}
#else
int main() { return 0; }
#endif
