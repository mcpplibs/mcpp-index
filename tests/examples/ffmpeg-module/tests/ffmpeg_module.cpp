// Public ffmpeg module package end-to-end assertion: import-only consumption
// (`import ffmpeg.av;`), libavutil version of the FFmpeg 8.1.x train, core
// decoders present, demuxer registry populated. Builds on linux+macOS+windows.
import std;
import ffmpeg.av;

int main() {
    unsigned v { avutil_version() };
    std::println("libavutil {}.{} module package ok", v >> 16, (v >> 8) & 0xff);
    if ((v >> 16) != 60u) {   // libavutil major of the FFmpeg 8.1.x train
        return 1;
    }

    for (auto name : { "h264", "hevc", "av1", "aac" }) {
        const AVCodec* dec { avcodec_find_decoder_by_name(name) };
        if (dec == nullptr) {
            std::println("decoder {} MISSING", name);
            return 2;
        }
    }

    void* it { nullptr };
    long demuxers { 0 };
    while (av_demuxer_iterate(&it)) ++demuxers;
    std::println("{} demuxers registered", demuxers);
    return demuxers > 300 ? 0 : 3;
}
