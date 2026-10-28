// compat.ogg + compat.opus + compat.opusfile — Opus audio end to end.
//
// WHAT THIS ASSERTS AND WHY
//
// Each check exercises a different part of the three source lists, so a file
// left out of a descriptor shows up as a link error or a wrong answer here:
//
//   the versions           opus_get_version_string, the generated config.h
//   CELT                   48 kHz stereo music at 128 kb/s, decoded back with
//                          a signal-to-noise ratio a correct codec reaches
//   SILK                   16 kHz mono speech mode (OPUS_APPLICATION_VOIP),
//                          the float encoder of silk/float
//   the packet parsers     channels, bandwidth, frames, samples per frame
//   multistream            5.1 surround (mapping family 1) encoded and decoded
//   projection             ambisonics (mapping family 3), the matrix code
//   the repacketizer       two packets merged into one, decoded as one
//   libogg                 an Ogg Opus stream (RFC 7845) paged with ogg_stream_*
//   opusfile               that stream opened from memory: OpusHead, OpusTags,
//                          the exact length, sample-accurate seeking, float PCM
//
// A pass means the codec, the container and the file reader agree with one
// another and with the RFCs, on this platform's build of each.

#include <ogg/ogg.h>
#include <opus.h>
#include <opus_multistream.h>
#include <opus_projection.h>
#include <opusfile.h>

#include <cmath>
#include <cstdint>
#include <cstdio>
#include <cstring>
#include <string>
#include <vector>

namespace {

int failures = 0;

void check(bool ok, const char *what)
{
    std::printf("%-64s %s\n", what, ok ? "ok" : "FAILED");
    if (!ok) ++failures;
}

constexpr double kPi = 3.14159265358979323846;

std::vector<float> tone(int rate, int channels, int samples, double f0)
{
    std::vector<float> pcm(static_cast<std::size_t>(samples) * channels);
    for (int i = 0; i < samples; ++i)
        for (int c = 0; c < channels; ++c)
            pcm[static_cast<std::size_t>(i) * channels + c] =
                static_cast<float>(0.5 * std::sin(2 * kPi * f0 * (c + 1) * i / rate));
    return pcm;
}

// SNR in dB of `out` against `in`, `out` delayed by `delay` samples.
double snr(const std::vector<float> &in, const std::vector<float> &out, int channels, int delay, int from, int to)
{
    double sig = 0, err = 0;
    for (int i = from; i < to; ++i)
        for (int c = 0; c < channels; ++c) {
            double a = in[static_cast<std::size_t>(i) * channels + c];
            double b = out[static_cast<std::size_t>(i + delay) * channels + c];
            sig += a * a;
            err += (a - b) * (a - b);
        }
    return 10 * std::log10(sig / (err + 1e-30));
}

void put_le16(std::vector<unsigned char> &v, unsigned x) { v.push_back(x & 0xFF); v.push_back((x >> 8) & 0xFF); }
void put_le32(std::vector<unsigned char> &v, std::uint32_t x) { for (int i = 0; i < 4; ++i) v.push_back((x >> (8 * i)) & 0xFF); }

void append_page(std::vector<unsigned char> &file, const ogg_page &page)
{
    file.insert(file.end(), page.header, page.header + page.header_len);
    file.insert(file.end(), page.body, page.body + page.body_len);
}

void versions()
{
    check(std::strcmp(opus_get_version_string(), "libopus 1.6.1") == 0, "opus_get_version_string() is \"libopus 1.6.1\"");
    check(std::strcmp(opus_strerror(OPUS_BAD_ARG), "invalid argument") == 0, "opus_strerror(OPUS_BAD_ARG)");
}

void celt_music()
{
    constexpr int rate = 48000, ch = 2, frame = 960, frames = 50;
    auto in = tone(rate, ch, frame * frames, 440.0);
    int err = 0;
    OpusEncoder *enc = opus_encoder_create(rate, ch, OPUS_APPLICATION_AUDIO, &err);
    OpusDecoder *dec = opus_decoder_create(rate, ch, &err);
    check(enc && dec && err == OPUS_OK, "48 kHz stereo encoder and decoder created");
    opus_encoder_ctl(enc, OPUS_SET_BITRATE(128000));
    opus_int32 lookahead = 0, bitrate = 0;
    opus_encoder_ctl(enc, OPUS_GET_LOOKAHEAD(&lookahead));
    opus_encoder_ctl(enc, OPUS_GET_BITRATE(&bitrate));
    check(bitrate == 128000, "OPUS_SET_BITRATE / OPUS_GET_BITRATE round trip");

    std::vector<float> out(in.size() + static_cast<std::size_t>(frame) * ch);
    unsigned char packet[4000];
    int decoded = 0, first_len = 0;
    for (int f = 0; f < frames; ++f) {
        int n = opus_encode_float(enc, in.data() + static_cast<std::size_t>(f) * frame * ch, frame, packet, sizeof packet);
        if (f == 0) {
            first_len = n;
            // TOC config 16..31 is CELT-only (RFC 6716 §3.1).
            check((packet[0] >> 3) >= 16, "48 kHz stereo music at 128 kb/s is CELT-only (TOC config >= 16)");
            check(opus_packet_get_nb_channels(packet) == 2, "opus_packet_get_nb_channels: 2");
            check(opus_packet_get_bandwidth(packet) == OPUS_BANDWIDTH_FULLBAND, "opus_packet_get_bandwidth: fullband");
            check(opus_packet_get_nb_frames(packet, n) == 1, "opus_packet_get_nb_frames: 1");
            check(opus_packet_get_samples_per_frame(packet, rate) == frame, "opus_packet_get_samples_per_frame: 960 (20 ms)");
            check(opus_decoder_get_nb_samples(dec, packet, n) == frame, "opus_decoder_get_nb_samples: 960");
        }
        decoded += opus_decode_float(dec, packet, n, out.data() + static_cast<std::size_t>(decoded) * ch, frame, 0);
    }
    check(first_len > 0, "opus_encode_float produced a packet");
    check(decoded == frame * frames, "every frame decoded to 960 samples");
    double s = snr(in, out, ch, lookahead, frame * 5, frame * frames - lookahead);
    std::printf("    CELT 128 kb/s, lookahead %d samples: SNR %.1f dB\n", static_cast<int>(lookahead), s);
    check(s > 20.0, "CELT round trip: SNR above 20 dB");
    opus_encoder_destroy(enc);
    opus_decoder_destroy(dec);
}

void silk_speech()
{
    constexpr int rate = 16000, frame = 320, frames = 25;
    auto in = tone(rate, 1, frame * frames, 300.0);
    int err = 0;
    OpusEncoder *enc = opus_encoder_create(rate, 1, OPUS_APPLICATION_VOIP, &err);
    OpusDecoder *dec = opus_decoder_create(rate, 1, &err);
    opus_encoder_ctl(enc, OPUS_SET_BITRATE(24000));
    opus_encoder_ctl(enc, OPUS_SET_SIGNAL(OPUS_SIGNAL_VOICE));
    std::vector<float> out(static_cast<std::size_t>(frame) * frames);
    unsigned char packet[1500];
    int decoded = 0;
    bool silk = true;
    for (int f = 0; f < frames; ++f) {
        int n = opus_encode_float(enc, in.data() + static_cast<std::size_t>(f) * frame, frame, packet, sizeof packet);
        // TOC config 0..11 is SILK-only (RFC 6716 §3.1).
        if (n <= 0 || (packet[0] >> 3) > 11) silk = false;
        decoded += opus_decode_float(dec, packet, n, out.data() + decoded, frame, 0);
    }
    check(silk, "16 kHz VOIP at 24 kb/s is SILK-only (TOC config <= 11)");
    check(decoded == frame * frames, "SILK frames decoded to 320 samples each");
    // Packet loss concealment: a missing packet still yields a frame.
    check(opus_decode_float(dec, nullptr, 0, out.data(), frame, 0) == frame, "packet loss concealment yields a frame");
    opus_encoder_destroy(enc);
    opus_decoder_destroy(dec);
}

void surround()
{
    constexpr int rate = 48000, ch = 6, frame = 960;
    int err = 0, streams = 0, coupled = 0;
    unsigned char mapping[8] = {};
    OpusMSEncoder *enc = opus_multistream_surround_encoder_create(rate, ch, 1, &streams, &coupled, mapping, OPUS_APPLICATION_AUDIO, &err);
    check(enc && err == OPUS_OK && streams == 4 && coupled == 2, "5.1 surround: 4 streams, 2 coupled (mapping family 1)");
    OpusMSDecoder *dec = opus_multistream_decoder_create(rate, ch, streams, coupled, mapping, &err);
    auto in = tone(rate, ch, frame, 220.0);
    std::vector<float> out(in.size());
    unsigned char packet[8000];
    int n = opus_multistream_encode_float(enc, in.data(), frame, packet, sizeof packet);
    check(n > 0 && opus_multistream_decode_float(dec, packet, n, out.data(), frame, 0) == frame, "5.1 frame encoded and decoded");
    opus_multistream_encoder_destroy(enc);
    opus_multistream_decoder_destroy(dec);
}

void ambisonics()
{
    constexpr int rate = 48000, ch = 4, frame = 960;
    int err = 0, streams = 0, coupled = 0;
    OpusProjectionEncoder *enc = opus_projection_ambisonics_encoder_create(rate, ch, 3, &streams, &coupled, OPUS_APPLICATION_AUDIO, &err);
    check(enc && err == OPUS_OK, "first-order ambisonics projection encoder (mapping family 3)");
    opus_int32 size = 0;
    opus_projection_encoder_ctl(enc, OPUS_PROJECTION_GET_DEMIXING_MATRIX_SIZE(&size));
    std::vector<unsigned char> matrix(static_cast<std::size_t>(size));
    opus_projection_encoder_ctl(enc, OPUS_PROJECTION_GET_DEMIXING_MATRIX(matrix.data(), size));
    OpusProjectionDecoder *dec = opus_projection_decoder_create(rate, ch, streams, coupled, matrix.data(), size, &err);
    auto in = tone(rate, ch, frame, 330.0);
    std::vector<float> out(in.size());
    unsigned char packet[8000];
    int n = opus_projection_encode_float(enc, in.data(), frame, packet, sizeof packet);
    check(dec && n > 0 && opus_projection_decode_float(dec, packet, n, out.data(), frame, 0) == frame, "ambisonics frame through the demixing matrix");
    opus_projection_encoder_destroy(enc);
    opus_projection_decoder_destroy(dec);
}

void repacketize()
{
    int err = 0;
    OpusEncoder *enc = opus_encoder_create(48000, 1, OPUS_APPLICATION_AUDIO, &err);
    auto in = tone(48000, 1, 960, 500.0);
    unsigned char a[1500], b[1500], merged[3000];
    int na = opus_encode_float(enc, in.data(), 480, a, sizeof a);
    int nb = opus_encode_float(enc, in.data() + 480, 480, b, sizeof b);
    OpusRepacketizer *rp = opus_repacketizer_create();
    opus_repacketizer_cat(rp, a, na);
    opus_repacketizer_cat(rp, b, nb);
    int n = opus_repacketizer_out(rp, merged, sizeof merged);
    check(opus_repacketizer_get_nb_frames(rp) == 2 && opus_packet_get_nb_frames(merged, n) == 2, "repacketizer: two 10 ms packets into one of two frames");
    opus_repacketizer_destroy(rp);
    opus_encoder_destroy(enc);
}

// An Ogg Opus stream (RFC 7845): OpusHead on the first page, OpusTags on the
// second, then 20 ms packets whose pages carry the granule position.
std::vector<unsigned char> ogg_opus(int samples, int &preskip_out)
{
    constexpr int rate = 48000, ch = 2, frame = 960;
    int err = 0;
    OpusEncoder *enc = opus_encoder_create(rate, ch, OPUS_APPLICATION_AUDIO, &err);
    opus_int32 preskip = 0;
    opus_encoder_ctl(enc, OPUS_GET_LOOKAHEAD(&preskip));
    preskip_out = preskip;

    ogg_stream_state os;
    ogg_stream_init(&os, 0x6d637070);
    std::vector<unsigned char> file;
    ogg_page page;

    std::vector<unsigned char> head = {'O', 'p', 'u', 's', 'H', 'e', 'a', 'd', 1, ch};
    put_le16(head, static_cast<unsigned>(preskip));
    put_le32(head, rate);
    put_le16(head, 0);
    head.push_back(0);
    ogg_packet op{head.data(), static_cast<long>(head.size()), 1, 0, 0, 0};
    ogg_stream_packetin(&os, &op);
    while (ogg_stream_flush(&os, &page)) append_page(file, page);

    const std::string vendor = "mcpp compat.opus test", comment = "TITLE=A440";
    std::vector<unsigned char> tags = {'O', 'p', 'u', 's', 'T', 'a', 'g', 's'};
    put_le32(tags, static_cast<std::uint32_t>(vendor.size()));
    tags.insert(tags.end(), vendor.begin(), vendor.end());
    put_le32(tags, 1);
    put_le32(tags, static_cast<std::uint32_t>(comment.size()));
    tags.insert(tags.end(), comment.begin(), comment.end());
    op = ogg_packet{tags.data(), static_cast<long>(tags.size()), 0, 0, 0, 1};
    ogg_stream_packetin(&os, &op);
    while (ogg_stream_flush(&os, &page)) append_page(file, page);

    auto in = tone(rate, ch, samples + frame + preskip, 440.0);
    const int total = samples + preskip;
    const int frames = (total + frame - 1) / frame;
    unsigned char packet[4000];
    for (int f = 0; f < frames; ++f) {
        int n = opus_encode_float(enc, in.data() + static_cast<std::size_t>(f) * frame * ch, frame, packet, sizeof packet);
        bool last = f == frames - 1;
        // The last page's granule position ends the stream at exactly
        // `samples` after the pre-skip (RFC 7845 §4.4 end trimming).
        ogg_int64_t granule = last ? total : static_cast<ogg_int64_t>(f + 1) * frame;
        op = ogg_packet{packet, n, 0, last ? 1 : 0, granule, 2 + f};
        ogg_stream_packetin(&os, &op);
        while (ogg_stream_pageout(&os, &page)) append_page(file, page);
    }
    while (ogg_stream_flush(&os, &page)) append_page(file, page);
    ogg_stream_clear(&os);
    opus_encoder_destroy(enc);
    return file;
}

void opusfile_reads_it()
{
    constexpr int samples = 48000 + 123;   // a length that is not whole frames
    int preskip = 0;
    auto file = ogg_opus(samples, preskip);
    check(op_test(nullptr, file.data(), file.size()) == 0, "op_test recognises the Ogg Opus stream");

    int err = 0;
    OggOpusFile *of = op_open_memory(file.data(), file.size(), &err);
    check(of && err == 0, "op_open_memory");
    if (!of) return;
    const OpusHead *head = op_head(of, -1);
    check(head && head->channel_count == 2 && head->pre_skip == preskip && head->input_sample_rate == 48000, "OpusHead: 2 channels, the pre-skip, 48 kHz");
    const OpusTags *tags = op_tags(of, -1);
    check(tags && std::strcmp(tags->vendor, "mcpp compat.opus test") == 0, "OpusTags: the vendor string");
    const char *title = opus_tags_query(tags, "TITLE", 0);
    check(title && std::strcmp(title, "A440") == 0, "opus_tags_query(TITLE) = A440");
    check(op_seekable(of) && op_link_count(of) == 1, "seekable, one link");
    check(op_pcm_total(of, -1) == samples, "op_pcm_total: exactly the samples encoded");

    std::vector<float> pcm(static_cast<std::size_t>(5760) * 2);
    long total = 0;
    for (;;) {
        int n = op_read_float(of, pcm.data(), static_cast<int>(pcm.size()), nullptr);
        if (n <= 0) { check(n == 0, "op_read_float ends without an error"); break; }
        total += n;
    }
    check(total == samples, "op_read_float returns every sample, end-trimmed");

    check(op_pcm_seek(of, 24000) == 0 && op_pcm_tell(of) == 24000, "op_pcm_seek / op_pcm_tell, sample accurate");
    opus_int16 pcm16[5760 * 2];
    int n = op_read_stereo(of, pcm16, 5760 * 2);
    check(n > 0 && op_pcm_tell(of) == 24000 + n, "op_read_stereo after the seek");
    op_free(of);
}

}  // namespace

int main()
{
    versions();
    celt_music();
    silk_speech();
    surround();
    ambisonics();
    repacketize();
    opusfile_reads_it();
    std::printf("%s: %d failure(s)\n", failures ? "FAILED" : "PASSED", failures);
    return failures ? 1 : 0;
}
