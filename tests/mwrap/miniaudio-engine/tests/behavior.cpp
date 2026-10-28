// The miniaudio API through the installed wrapper, without an audio device.
import std;
import mcpplibs.mwrap.miniaudio;

using namespace mcpplibs::mwrap::miniaudio::macros;

namespace {
float peak(std::span<const float> s) {
    float p = 0;
    for (float v : s) p = std::max(p, std::abs(v));
    return p;
}
}  // namespace

int main() {
    if (std::string_view(ma_version_string()) != MA_VERSION_STRING || MA_VERSION_MINOR != 11) return 1;

    // The engine mixes into a caller's buffer when it has no device; its
    // resource manager runs without job threads.
    ma_resource_manager_config rmConfig = ma_resource_manager_config_init();
    rmConfig.flags = MA_RESOURCE_MANAGER_FLAG_NO_THREADING;
    rmConfig.jobThreadCount = 0;
    ma_resource_manager rm;
    if (ma_resource_manager_init(&rmConfig, &rm) != MA_SUCCESS) return 2;
    ma_engine_config config = ma_engine_config_init();
    config.noDevice = MA_TRUE;
    config.channels = 2;
    config.sampleRate = 48000;
    config.pResourceManager = &rm;
    ma_engine engine;
    if (ma_engine_init(&config, &engine) != MA_SUCCESS) return 3;
    const ma_waveform_config wc = ma_waveform_config_init(ma_format_f32, 2, 48000, ma_waveform_type_square, 0.5, 100);
    ma_waveform wave;
    ma_waveform_init(&wc, &wave);
    ma_sound_group group;
    ma_sound_group_init(&engine, 0, nullptr, &group);
    ma_sound sound;
    if (ma_sound_init_from_data_source(&engine, &wave, MA_SOUND_FLAG_NO_SPATIALIZATION, &group, &sound) != MA_SUCCESS) return 4;
    ma_sound_start(&sound);
    std::vector<float> mix(2 * 480);
    ma_uint64 read = 0;
    ma_engine_read_pcm_frames(&engine, mix.data(), 480, &read);
    if (read != 480 || std::abs(peak(mix) - 0.5f) > 1e-3f) return 5;
    ma_sound_group_set_volume(&group, 0.5f);
    ma_engine_read_pcm_frames(&engine, mix.data(), 480, &read);
    if (std::abs(peak(mix) - 0.25f) > 1e-3f) return 6;
    ma_sound_uninit(&sound);
    ma_sound_group_uninit(&group);
    ma_waveform_uninit(&wave);
    ma_engine_uninit(&engine);
    ma_resource_manager_uninit(&rm);

    // A tone encoded as WAV in memory and decoded back, sample for sample.
    struct Sink {
        std::vector<unsigned char> bytes;
        std::size_t at = 0;
    } sink;
    const auto write = [](ma_encoder* e, const void* data, std::size_t n, std::size_t* written) -> ma_result {
        auto& s = *static_cast<Sink*>(e->pUserData);
        if (s.bytes.size() < s.at + n) s.bytes.resize(s.at + n);
        std::memcpy(s.bytes.data() + s.at, data, n);
        s.at += n;
        *written = n;
        return MA_SUCCESS;
    };
    const auto seek = [](ma_encoder* e, ma_int64 offset, ma_seek_origin origin) -> ma_result {
        auto& s = *static_cast<Sink*>(e->pUserData);
        s.at = static_cast<std::size_t>((origin == ma_seek_origin_start ? 0 : static_cast<ma_int64>(s.at)) + offset);
        return MA_SUCCESS;
    };
    std::vector<ma_int16> pcm(4410);
    const ma_waveform_config tc = ma_waveform_config_init(ma_format_s16, 1, 44100, ma_waveform_type_sine, 0.5, 440);
    ma_waveform tone;
    ma_waveform_init(&tc, &tone);
    ma_waveform_read_pcm_frames(&tone, pcm.data(), pcm.size(), nullptr);
    const ma_encoder_config ec = ma_encoder_config_init(ma_encoding_format_wav, ma_format_s16, 1, 44100);
    ma_encoder encoder;
    if (ma_encoder_init(write, seek, &sink, &ec, &encoder) != MA_SUCCESS) return 7;
    ma_encoder_write_pcm_frames(&encoder, pcm.data(), pcm.size(), nullptr);
    ma_encoder_uninit(&encoder);
    const ma_decoder_config dc = ma_decoder_config_init(ma_format_s16, 0, 0);
    ma_decoder decoder;
    if (ma_decoder_init_memory(sink.bytes.data(), sink.bytes.size(), &dc, &decoder) != MA_SUCCESS) return 8;
    std::vector<ma_int16> back(pcm.size());
    ma_decoder_read_pcm_frames(&decoder, back.data(), back.size(), &read);
    const ma_uint32 rate = decoder.outputSampleRate;
    ma_decoder_uninit(&decoder);
    if (read != pcm.size() || back != pcm || rate != 44100) return 9;

    // A device on the Null backend runs in real time without hardware.
    ma_backend null = ma_backend_null;
    ma_context context;
    if (ma_context_init(&null, 1, nullptr, &context) != MA_SUCCESS) return 10;
    ma_device_config dconfig = ma_device_config_init(ma_device_type_playback);
    dconfig.playback.format = ma_format_f32;
    dconfig.playback.channels = 2;
    dconfig.sampleRate = 48000;
    static std::atomic<ma_uint64> frames{0};
    dconfig.dataCallback = [](ma_device*, void* out, const void*, ma_uint32 n) {
        std::memset(out, 0, n * 2 * sizeof(float));
        frames += n;
    };
    ma_device device;
    if (ma_device_init(&context, &dconfig, &device) != MA_SUCCESS || ma_device_start(&device) != MA_SUCCESS) return 11;
    for (int i = 0; i < 1000 && frames < 2400; ++i) std::this_thread::sleep_for(std::chrono::milliseconds(5));
    ma_device_uninit(&device);
    ma_context_uninit(&context);
    if (frames < 2400) return 12;

    // The adapted inline helper and a constant at compile time.
    static_assert(MA_MAX_CHANNELS == 254 && MA_ENGINE_MAX_LISTENERS == 4);
    return mcpplibs::mwrap::miniaudio::ma_get_bytes_per_frame(ma_format_s16, 2) == 4 ? 0 : 13;
}
