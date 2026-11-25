import std;
import mcpplibs.mwrap.opus;

using namespace mcpplibs::mwrap::opus::macros;

namespace {

void put(std::vector<unsigned char>& v, std::uint32_t x, int n) {
    for (int i = 0; i < n; ++i) v.push_back((x >> (8 * i)) & 0xFF);
}
void append(std::vector<unsigned char>& file, const ogg_page& page) {
    file.insert(file.end(), page.header, page.header + page.header_len);
    file.insert(file.end(), page.body, page.body + page.body_len);
}

}  // namespace

int main() {
    if (std::string_view(opus_get_version_string()) != "libopus 1.6.1") return 1;

    // A chord, encoded at 64 kb/s through the typed CTL requests.
    constexpr int rate = 48000, ch = 2, frame = 960, samples = 48000 + 77;
    int err = 0;
    OpusEncoder* enc = opus_encoder_create(rate, ch, OPUS_APPLICATION_AUDIO, &err);
    if (err != OPUS_OK || opus_encoder_ctl(enc, OPUS_SET_BITRATE(64000)) != OPUS_OK) return 2;
    opus_int32 bitrate = 0, preskip = 0;
    opus_encoder_ctl(enc, OPUS_GET_BITRATE(&bitrate));
    opus_encoder_ctl(enc, OPUS_GET_LOOKAHEAD(&preskip));
    if (bitrate != 64000 || preskip <= 0) return 3;

    // An Ogg Opus stream (RFC 7845), paged with libogg.
    std::vector<unsigned char> file;
    ogg_stream_state os;
    ogg_stream_init(&os, 7);
    ogg_page page;
    std::vector<unsigned char> head = {'O', 'p', 'u', 's', 'H', 'e', 'a', 'd', 1, ch};
    put(head, static_cast<std::uint32_t>(preskip), 2);
    put(head, rate, 4);
    put(head, 0, 3);
    ogg_packet op{head.data(), static_cast<long>(head.size()), 1, 0, 0, 0};
    ogg_stream_packetin(&os, &op);
    while (ogg_stream_flush(&os, &page)) append(file, page);
    std::vector<unsigned char> tags = {'O', 'p', 'u', 's', 'T', 'a', 'g', 's', 2, 0, 0, 0, 'm', 'w', 1, 0, 0, 0, 7, 0, 0, 0};
    for (char c : std::string_view("TITLE=x")) tags.push_back(static_cast<unsigned char>(c));
    op = ogg_packet{tags.data(), static_cast<long>(tags.size()), 0, 0, 0, 1};
    ogg_stream_packetin(&os, &op);
    while (ogg_stream_flush(&os, &page)) append(file, page);
    const int total = samples + preskip, frames = (total + frame - 1) / frame;
    std::vector<float> pcm(static_cast<std::size_t>(frame) * ch);
    unsigned char packet[4000];
    for (int f = 0; f < frames; ++f) {
        for (int i = 0; i < frame; ++i)
            for (int c = 0; c < ch; ++c)
                pcm[static_cast<std::size_t>(i) * ch + c] =
                    static_cast<float>(0.3 * std::sin(2 * std::numbers::pi * (440 + 220 * c) * (f * frame + i) / rate));
        const int n = opus_encode_float(enc, pcm.data(), frame, packet, sizeof packet);
        if (n <= 0) return 4;
        const bool last = f == frames - 1;
        op = ogg_packet{packet, n, 0, last ? 1 : 0, last ? total : static_cast<ogg_int64_t>(f + 1) * frame, 2 + f};
        ogg_stream_packetin(&os, &op);
        while (ogg_stream_pageout(&os, &page)) append(file, page);
    }
    while (ogg_stream_flush(&os, &page)) append(file, page);
    ogg_stream_clear(&os);
    opus_encoder_destroy(enc);

    // Read back with opusfile: headers, tags, the exact length, seeking.
    OggOpusFile* of = op_open_memory(file.data(), file.size(), &err);
    if (!of || err != 0) return 5;
    if (op_channel_count(of, -1) != 2 || op_head(of, -1)->pre_skip != static_cast<unsigned>(preskip)) return 6;
    if (std::string_view(op_tags(of, -1)->vendor) != "mw" || std::string_view(opus_tags_query(op_tags(of, -1), "title", 0)) != "x") return 7;
    if (op_pcm_total(of, -1) != samples) return 8;
    std::vector<float> out(5760 * 2);
    long read = 0;
    for (int n; (n = op_read_float(of, out.data(), static_cast<int>(out.size()), nullptr)) > 0;) read += n;
    if (read != samples) return 9;
    if (op_pcm_seek(of, 12345) != 0 || op_pcm_tell(of) != 12345) return 10;
    op_free(of);
    if (op_open_memory(file.data(), 16, &err) != nullptr || err == 0) return 11;

    // 5.1 surround: four streams, two coupled.
    int streams = 0, coupled = 0;
    unsigned char mapping[6];
    OpusMSEncoder* ms = opus_multistream_surround_encoder_create(rate, 6, 1, &streams, &coupled, mapping, OPUS_APPLICATION_AUDIO, &err);
    if (err != OPUS_OK || streams != 4 || coupled != 2) return 12;
    OpusEncoder* first = nullptr;
    if (opus_multistream_encoder_ctl(ms, OPUS_MULTISTREAM_GET_ENCODER_STATE(0, &first)) != OPUS_OK || !first) return 13;
    opus_multistream_encoder_destroy(ms);

    static_assert(OPUS_SET_BITRATE(OPUS_AUTO).request == OPUS_SET_BITRATE_REQUEST && OP_EOF == -2);
    static_assert(std::is_same_v<decltype(OPUS_GET_FINAL_RANGE(nullptr)), ctl_request<opus_uint32*>>);
    return 0;
}
