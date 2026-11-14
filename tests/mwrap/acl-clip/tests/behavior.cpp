// The installed ACL wrapper: a chain of five joints turning and moving over two seconds at 30 samples a second,
// compressed with ACL's default settings twice to the same bytes, its error measured against the raw clip, and
// played back at five times. The compressed bytes and the poses are pinned, as the wrapper's CI pins them on every
// platform; the adapted constants.
import std;
import mcpplibs.mwrap.acl;

namespace {

int failures = 0;
void check(bool held) { failures += held ? 0 : 1; }

constexpr std::uint32_t joints = 5, samples = 61;
constexpr float rate = 30.0f;

std::uint64_t fnv(const void* data, std::size_t size, std::uint64_t hash = 0xcbf29ce484222325ull) {
    const auto* bytes = static_cast<const unsigned char*>(data);
    for (std::size_t index = 0; index < size; ++index) hash = (hash ^ bytes[index]) * 0x100000001b3ull;
    return hash;
}

// Each joint's rotation a normalised quaternion of polynomials in time, its translation along its parent's x.
acl::track_array_qvvf raw(acl::iallocator& allocator) {
    acl::track_array_qvvf tracks(allocator, joints);
    for (std::uint32_t joint = 0; joint < joints; ++joint) {
        acl::track_desc_transformf desc;
        desc.output_index = joint;
        desc.parent_index = joint == 0 ? mcpplibs::mwrap::acl::k_invalid_track_index : joint - 1;
        desc.precision = 0.0001f;
        desc.shell_distance = 0.03f;
        acl::track_qvvf track = acl::track_qvvf::make_reserve(desc, allocator, samples, rate);
        for (std::uint32_t sample = 0; sample < samples; ++sample) {
            const float time = static_cast<float>(sample) / rate, turn = 0.3f * time - 0.1f * time * time + 0.05f * static_cast<float>(joint);
            const rtm::quatf rotation = rtm::quat_normalize(rtm::quat_set(turn, 0.2f * turn * turn, 0.1f * static_cast<float>(joint), 1.0f));
            const rtm::vector4f translation = rtm::vector_set(joint == 0 ? 0.5f * time : 0.25f, joint == 0 ? 0.1f * time * time : 0.0f, 0.0f);
            track[sample] = rtm::qvv_set(rotation, translation, rtm::vector_set(1.0f));
        }
        tracks[joint] = std::move(track);
    }
    return tracks;
}

struct Pose : acl::track_writer {
    std::array<float, joints * 10> values{};
    void write_rotation(std::uint32_t joint, rtm::quatf_arg0 rotation) { rtm::quat_store(rotation, &values[joint * 10]); }
    void write_translation(std::uint32_t joint, rtm::vector4f_arg0 translation) { rtm::vector_store3(translation, &values[joint * 10 + 4]); }
    void write_scale(std::uint32_t joint, rtm::vector4f_arg0 scale) { rtm::vector_store3(scale, &values[joint * 10 + 7]); }
};

}  // namespace

int main() {
    acl::ansi_allocator allocator;
    const acl::track_array_qvvf tracks = raw(allocator);
    acl::compression_settings settings = acl::get_default_compression_settings();
    acl::qvvf_transform_error_metric metric;
    settings.error_metric = &metric;
    const auto compress = [&] {
        acl::output_stats stats;
        acl::compressed_tracks* compressed = nullptr;
        check(acl::compress_track_list(allocator, tracks, settings, compressed, stats).empty() && compressed);
        return compressed;
    };
    acl::compressed_tracks* compressed = compress();
    acl::compressed_tracks* again = compress();
    if (!compressed || !again) return 1;
    check(compressed->is_valid(true).empty());
    check(compressed->get_size() == again->get_size() && std::memcmp(compressed, again, compressed->get_size()) == 0);

    acl::decompression_context<acl::default_transform_decompression_settings> context;
    check(context.initialize(*compressed));
    const acl::track_error error = acl::calculate_compression_error(allocator, tracks, context, metric);
    check(error.error < 0.00015f);
    std::uint64_t poses = 0xcbf29ce484222325ull;
    for (const float time : {0.0f, 0.37f, 1.0f, 1.5f, 2.0f}) {
        Pose pose;
        context.seek(time, acl::sample_rounding_policy::none);
        context.decompress_tracks(pose);
        poses = fnv(pose.values.data(), sizeof(pose.values), poses);
    }
    const std::uint64_t bytes = fnv(compressed, compressed->get_size());
    check(bytes == 0x7bbb0daa9b0e5fa6ull && poses == 0x0c6e1a02a38a29a5ull);
    check(mcpplibs::mwrap::acl::k_invalid_track_index == 0xFFFFFFFFu && mcpplibs::mwrap::acl::k_num_quality_tiers == 3u);
    std::println("ACL 2.1.0 through import mcpplibs.mwrap.acl: {} raw bytes compressed to {} within {:.3f} mm; the bytes {:#018x}, the poses {:#018x}{}",
                 joints * samples * 10 * sizeof(float), compressed->get_size(), error.error * 1000.0f, bytes, poses,
                 failures ? std::format(" — {} checks failed", failures) : "");
    allocator.deallocate(compressed, compressed->get_size());
    allocator.deallocate(again, again->get_size());
    return failures;
}
