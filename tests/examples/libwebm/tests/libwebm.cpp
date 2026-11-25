// compat.libwebm — a WebM file written and read back.
//
// WHAT THIS ASSERTS AND WHY
//
//   the muxer     mkvmuxer::Segment over a writer of our own (memory, seekable):
//                 a VP9 video track with its colour (BT.709, limited range), an
//                 Opus audio track with its codec private data and delay, frames
//                 at their nanosecond timestamps, key frames, cues, the duration
//                 written back at the end (mkvmuxer.cc, mkvmuxerutil.cc)
//   the writer    mkvmuxer::MkvWriter: the same file written to disk
//                 (mkvwriter.cc), byte for byte the memory one
//   the parser    mkvparser over a reader of our own (memory) and over
//                 MkvReader (the file; mkvreader.cc): the EBML header's doc
//                 type, the tracks, their codecs, colour and private data,
//                 every frame in order with its time, track and bytes, the
//                 cues, the duration (mkvparser.cc)
//   hdr_util      the colour read back into mkvmuxer's form (common/hdr_util.cc)
//   reproducible  the same frames and track UIDs twice: the same bytes
//
// A pass means the muxer and the parser agree with one another.

#include <common/hdr_util.h>
#include <mkvmuxer/mkvmuxer.h>
#include <mkvmuxer/mkvwriter.h>
#include <mkvparser/mkvparser.h>
#include <mkvparser/mkvreader.h>

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

class MemoryWriter : public mkvmuxer::IMkvWriter {
public:
    std::vector<unsigned char> bytes;
    std::int64_t at = 0;
    mkvmuxer::int32 Write(const void *buf, mkvmuxer::uint32 len) override
    {
        if (bytes.size() < static_cast<std::size_t>(at) + len) bytes.resize(static_cast<std::size_t>(at) + len);
        std::memcpy(bytes.data() + at, buf, len);
        at += len;
        return 0;
    }
    mkvmuxer::int64 Position() const override { return at; }
    mkvmuxer::int32 Position(mkvmuxer::int64 position) override
    {
        at = position;
        return 0;
    }
    bool Seekable() const override { return true; }
    void ElementStartNotify(mkvmuxer::uint64, mkvmuxer::int64) override {}
};

class MemoryReader : public mkvparser::IMkvReader {
public:
    explicit MemoryReader(const std::vector<unsigned char> &b) : bytes(b) {}
    int Read(long long pos, long len, unsigned char *buf) override
    {
        if (pos < 0 || len < 0 || static_cast<std::size_t>(pos + len) > bytes.size()) return -1;
        std::memcpy(buf, bytes.data() + pos, static_cast<std::size_t>(len));
        return 0;
    }
    int Length(long long *total, long long *available) override
    {
        if (total) *total = static_cast<long long>(bytes.size());
        if (available) *available = static_cast<long long>(bytes.size());
        return 0;
    }
    const std::vector<unsigned char> &bytes;
};

constexpr int FRAMES = 30;                        // a second at 30 fps
constexpr std::uint64_t FRAME_NS = 1000000000ull / 30;
constexpr std::uint64_t PACKET_NS = 20000000ull;  // Opus: 20 ms

std::vector<unsigned char> payload(int track, int i)
{
    std::vector<unsigned char> p(static_cast<std::size_t>(40 + (i * 37) % 200));
    for (std::size_t k = 0; k < p.size(); ++k) p[k] = static_cast<unsigned char>(track * 91 + i * 13 + static_cast<int>(k));
    return p;
}

bool mux(mkvmuxer::IMkvWriter &w)
{
    mkvmuxer::Segment segment;
    if (!segment.Init(&w)) return false;
    segment.set_mode(mkvmuxer::Segment::kFile);
    segment.OutputCues(true);
    segment.GetSegmentInfo()->set_writing_app("libwebm-tests");
    segment.GetSegmentInfo()->set_muxing_app("libwebm-tests");
    const mkvmuxer::uint64 video = segment.AddVideoTrack(320, 192, 1);
    const mkvmuxer::uint64 audio = segment.AddAudioTrack(48000, 2, 2);
    auto *v = static_cast<mkvmuxer::VideoTrack *>(segment.GetTrackByNumber(video));
    auto *a = static_cast<mkvmuxer::AudioTrack *>(segment.GetTrackByNumber(audio));
    if (!v || !a) return false;
    // Track UIDs are random (seeded by the time) unless given: given, the bytes are reproducible.
    v->set_uid(0x1234567890abcdull);
    a->set_uid(0x0fedcba0987654ull);
    v->set_codec_id(mkvmuxer::Tracks::kVp9CodecId);
    v->set_frame_rate(30.0);
    mkvmuxer::Colour colour;
    colour.set_matrix_coefficients(mkvmuxer::Colour::kBt709);
    colour.set_range(mkvmuxer::Colour::kBroadcastRange);
    colour.set_transfer_characteristics(mkvmuxer::Colour::kIturBt709Tc);
    colour.set_primaries(mkvmuxer::Colour::kIturBt709P);
    if (!v->SetColour(colour)) return false;
    a->set_codec_id(mkvmuxer::Tracks::kOpusCodecId);
    const unsigned char head[19] = {'O', 'p', 'u', 's', 'H', 'e', 'a', 'd', 1, 2, 0x38, 0x01, 0x80, 0xbb, 0, 0, 0, 0, 0};
    if (!a->SetCodecPrivate(head, sizeof head)) return false;
    a->set_codec_delay(6500000);
    a->set_seek_pre_roll(80000000);
    segment.CuesTrack(video);
    // Interleaved by time, as a muxer must be given them.
    int vi = 0, ai = 0;
    while (vi < FRAMES || ai < 50) {
        const std::uint64_t vt = vi * FRAME_NS, at = ai * PACKET_NS;
        if (vi < FRAMES && (ai >= 50 || vt <= at)) {
            const auto p = payload(1, vi);
            if (!segment.AddFrame(p.data(), p.size(), video, vt, vi % 10 == 0)) return false;
            ++vi;
        } else {
            const auto p = payload(2, ai);
            if (!segment.AddFrame(p.data(), p.size(), audio, at, true)) return false;
            ++ai;
        }
    }
    segment.set_duration(1000.0);  // in the segment's timecode scale: milliseconds
    return segment.Finalize();
}

}  // namespace

int main()
{
    MemoryWriter w;
    check(mux(w) && !w.bytes.empty(), "mkvmuxer: a VP9 and an Opus track, 30 frames and 50 packets");
    MemoryWriter again;
    check(mux(again) && again.bytes == w.bytes, "the same frames twice: the same bytes");

    const std::string file = "libwebm-test.webm";
    {
        mkvmuxer::MkvWriter disk;
        check(disk.Open(file.c_str()) && mux(disk), "mkvmuxer::MkvWriter: the same file on disk");
        disk.Close();
    }
    {
        std::FILE *f = std::fopen(file.c_str(), "rb");
        std::vector<unsigned char> b;
        if (f) {
            unsigned char buf[4096];
            std::size_t n;
            while ((n = std::fread(buf, 1, sizeof buf, f)) > 0) b.insert(b.end(), buf, buf + n);
            std::fclose(f);
        }
        check(b == w.bytes, "the file is byte for byte the memory one");
    }

    MemoryReader reader(w.bytes);
    long long pos = 0;
    mkvparser::EBMLHeader ebml;
    check(ebml.Parse(&reader, pos) == 0 && std::string(ebml.m_docType) == "webm", "mkvparser: the EBML header, doc type webm");
    mkvparser::Segment *segment = nullptr;
    check(mkvparser::Segment::CreateInstance(&reader, pos, segment) == 0 && segment && segment->Load() == 0, "the segment loads");
    if (!segment) return 1;
    const mkvparser::Tracks *tracks = segment->GetTracks();
    check(tracks && tracks->GetTracksCount() == 2, "two tracks");
    const auto *v = static_cast<const mkvparser::VideoTrack *>(tracks->GetTrackByNumber(1));
    const auto *a = static_cast<const mkvparser::AudioTrack *>(tracks->GetTrackByNumber(2));
    check(v && std::string(v->GetCodecId()) == "V_VP9" && v->GetWidth() == 320 && v->GetHeight() == 192, "the video track: V_VP9, 320 x 192");
    check(v && v->GetColour() && v->GetColour()->matrix_coefficients == mkvmuxer::Colour::kBt709 &&
              v->GetColour()->range == mkvmuxer::Colour::kBroadcastRange,
          "its colour: BT.709, broadcast range");
    mkvmuxer::Colour back;
    check(v && v->GetColour() && libwebm::CopyColour(*v->GetColour(), &back) && back.matrix_coefficients() == mkvmuxer::Colour::kBt709,
          "hdr_util: the colour copied back into the muxer's form");
    size_t private_size = 0;
    const unsigned char *priv = a ? a->GetCodecPrivate(private_size) : nullptr;
    check(a && std::string(a->GetCodecId()) == "A_OPUS" && a->GetSamplingRate() == 48000 && a->GetChannels() == 2 && private_size == 19 &&
              std::memcmp(priv, "OpusHead", 8) == 0 && a->GetCodecDelay() == 6500000,
          "the audio track: A_OPUS, 48 kHz stereo, OpusHead, the codec delay");

    int vframes = 0, aframes = 0, keys = 0;
    bool payloads = true, order = true;
    long long last = -1;
    for (const mkvparser::Cluster *c = segment->GetFirst(); c && !c->EOS(); c = segment->GetNext(c)) {
        const mkvparser::BlockEntry *e = nullptr;
        if (c->GetFirst(e) != 0) break;
        while (e && !e->EOS()) {
            const mkvparser::Block *b = e->GetBlock();
            const long long t = b->GetTime(c);
            order = order && t >= last;
            last = t;
            const int n = b->GetTrackNumber() == 1 ? vframes++ : aframes++;
            if (b->GetTrackNumber() == 1 && b->IsKey()) ++keys;
            const mkvparser::Block::Frame &f = b->GetFrame(0);
            std::vector<unsigned char> data(static_cast<std::size_t>(f.len));
            payloads = payloads && f.Read(&reader, data.data()) == 0 && data == payload(static_cast<int>(b->GetTrackNumber()), n) &&
                       t == static_cast<long long>(b->GetTrackNumber() == 1 ? n * FRAME_NS : n * PACKET_NS) / 1000000 * 1000000;
            if (c->GetNext(e, e) != 0) break;
        }
    }
    check(vframes == FRAMES && aframes == 50, "every frame and packet read back");
    check(payloads, "each with its bytes and its time (milliseconds)");
    check(order && keys == 3, "in time order, the key frames where they were");
    check(segment->GetCues() && segment->GetInfo()->GetDuration() > 0, "the cues and the duration");
    delete segment;

    mkvparser::MkvReader disk;
    long long pos2 = 0;
    mkvparser::EBMLHeader h2;
    mkvparser::Segment *s2 = nullptr;
    check(disk.Open(file.c_str()) == 0 && h2.Parse(&disk, pos2) == 0 && mkvparser::Segment::CreateInstance(&disk, pos2, s2) == 0 && s2 && s2->Load() == 0 &&
              s2->GetTracks()->GetTracksCount() == 2,
          "mkvparser::MkvReader: the file read back");
    delete s2;
    disk.Close();
    std::remove(file.c_str());

    std::printf("%s\n", failures ? "FAILED" : "all passed");
    return failures ? 1 : 0;
}
