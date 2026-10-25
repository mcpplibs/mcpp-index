// Exercise the optional upstream mux/demux implementations with an actual
// two-frame lossless stream and an EXIF container chunk. Checks survive NDEBUG.
#include <webp/demux.h>
#include <webp/encode.h>
#include <webp/mux.h>

#include <array>
#include <cstring>
#include <memory>
#include <stdexcept>
#include <vector>

namespace {
void require(bool condition, const char* message) {
    if (!condition) throw std::runtime_error(message);
}
struct Data {
    WebPData value{};
    ~Data() { WebPDataClear(&value); }
};
}

int main() {
    constexpr int width = 8, height = 8;
    const std::array<std::array<uint8_t, 4>, 2> colors{{{20, 80, 160, 255}, {180, 40, 70, 255}}};
    WebPAnimEncoderOptions options;
    require(WebPAnimEncoderOptionsInit(&options), "animation encoder options ABI");
    std::unique_ptr<WebPAnimEncoder, decltype(&WebPAnimEncoderDelete)> encoder(
        WebPAnimEncoderNew(width, height, &options), WebPAnimEncoderDelete);
    require(bool(encoder), "animation encoder construction");
    WebPConfig config;
    require(WebPConfigInit(&config) && WebPConfigLosslessPreset(&config, 6), "lossless configuration");
    for (int frame = 0; frame < 2; ++frame) {
        std::vector<uint8_t> rgba(width * height * 4);
        for (int pixel = 0; pixel < width * height; ++pixel)
            std::memcpy(rgba.data() + pixel * 4, colors[frame].data(), 4);
        WebPPicture picture;
        require(WebPPictureInit(&picture), "picture ABI");
        picture.use_argb = 1;
        picture.width = width;
        picture.height = height;
        require(WebPPictureImportRGBA(&picture, rgba.data(), width * 4), "picture import");
        const bool added = WebPAnimEncoderAdd(encoder.get(), &picture, frame * 80, &config);
        WebPPictureFree(&picture);
        require(added, "animation frame encoding");
    }
    require(WebPAnimEncoderAdd(encoder.get(), nullptr, 200, nullptr), "animation final timestamp");
    Data animated;
    require(WebPAnimEncoderAssemble(encoder.get(), &animated.value), "animation assembly");
    std::unique_ptr<WebPMux, decltype(&WebPMuxDelete)> mux(WebPMuxCreate(&animated.value, 1), WebPMuxDelete);
    require(bool(mux), "mux construction");
    constexpr char metadata[] = "mwrap-webp";
    const WebPData chunk{reinterpret_cast<const uint8_t*>(metadata), sizeof(metadata) - 1};
    require(WebPMuxSetChunk(mux.get(), "EXIF", &chunk, 1) == WEBP_MUX_OK, "metadata mux");
    Data encoded;
    require(WebPMuxAssemble(mux.get(), &encoded.value) == WEBP_MUX_OK, "metadata assembly");

    std::unique_ptr<WebPDemuxer, decltype(&WebPDemuxDelete)> demux(WebPDemux(&encoded.value), WebPDemuxDelete);
    require(bool(demux) && WebPDemuxGetI(demux.get(), WEBP_FF_FRAME_COUNT) == 2, "two-frame demux");
    WebPChunkIterator iterator;
    require(WebPDemuxGetChunk(demux.get(), "EXIF", 1, &iterator), "metadata demux");
    const bool same_chunk = iterator.chunk.size == chunk.size &&
        std::memcmp(iterator.chunk.bytes, chunk.bytes, chunk.size) == 0;
    WebPDemuxReleaseChunkIterator(&iterator);
    require(same_chunk, "metadata payload changed");

    WebPAnimDecoderOptions decode_options;
    require(WebPAnimDecoderOptionsInit(&decode_options), "animation decoder options ABI");
    decode_options.color_mode = MODE_RGBA;
    std::unique_ptr<WebPAnimDecoder, decltype(&WebPAnimDecoderDelete)> decoder(
        WebPAnimDecoderNew(&encoded.value, &decode_options), WebPAnimDecoderDelete);
    require(bool(decoder), "animation decoder construction");
    for (int frame = 0; frame < 2; ++frame) {
        uint8_t* rgba = nullptr;
        int timestamp = -1;
        require(WebPAnimDecoderGetNext(decoder.get(), &rgba, &timestamp), "animation decode");
        require(timestamp == (frame == 0 ? 80 : 200), "frame timing changed");
        for (int pixel = 0; pixel < width * height; ++pixel)
            require(std::memcmp(rgba + pixel * 4, colors[frame].data(), 4) == 0, "lossless pixels changed");
    }
    require(!WebPAnimDecoderHasMoreFrames(decoder.get()), "unexpected extra frame");
}
