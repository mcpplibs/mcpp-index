import std;
import mcpplibs.mwrap.ffmpeg.av;

int main() {
    if (std::string_view(av_version_info()) != "8.1.2") return 1;
    const auto* codec = avcodec_find_decoder(AV_CODEC_ID_RAWVIDEO);
    if (!codec) return 2;
    struct Decoder {
        AVCodecContext* context = nullptr;
        AVPacket* packet = nullptr;
        AVFrame* frame = nullptr;
        ~Decoder() { av_frame_free(&frame); av_packet_free(&packet); avcodec_free_context(&context); }
    } decoder;
    decoder.context = avcodec_alloc_context3(codec);
    decoder.packet = av_packet_alloc();
    decoder.frame = av_frame_alloc();
    if (!decoder.context || !decoder.packet || !decoder.frame) return 3;
    decoder.context->width = 16;
    decoder.context->height = 16;
    decoder.context->pix_fmt = AV_PIX_FMT_YUV420P;
    if (avcodec_open2(decoder.context, codec, nullptr) < 0) return 4;
    if (av_new_packet(decoder.packet, 16 * 16 * 3 / 2) < 0) return 5;
    std::fill_n(decoder.packet->data, 16 * 16, 64);
    std::fill_n(decoder.packet->data + 16 * 16, 2 * 8 * 8, 128);
    if (avcodec_send_packet(decoder.context, decoder.packet) < 0 ||
        avcodec_receive_frame(decoder.context, decoder.frame) < 0) return 6;
    if (decoder.frame->width != 16 || decoder.frame->height != 16 ||
        decoder.frame->data[0][0] != 64 || decoder.frame->data[1][0] != 128 ||
        decoder.frame->data[2][0] != 128) return 7;
    std::println("FFmpeg {} decoded a 16x16 YUV420 frame", av_version_info());
    return 0;
}
