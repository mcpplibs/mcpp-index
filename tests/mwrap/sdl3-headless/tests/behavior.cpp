import std;
import mcpplibs.mwrap.sdl3;

using namespace mcpplibs::mwrap::sdl3;          // the adapted inline API
using namespace mcpplibs::mwrap::sdl3::macros;  // SDL_INIT_VIDEO, SDL_HINT_*, SDL_BITSPERPIXEL ...

int main() {
    // SDL's headless drivers, over whatever the environment says.
    SDL_SetHintWithPriority(SDL_HINT_VIDEO_DRIVER, "dummy", SDL_HINT_OVERRIDE);
    SDL_SetHintWithPriority(SDL_HINT_AUDIO_DRIVER, "dummy", SDL_HINT_OVERRIDE);
    if (SDL_GetVersion() != SDL_VERSION || !SDL_Init(SDL_INIT_VIDEO | SDL_INIT_AUDIO)) return 1;

    // Properties and a user event, pushed and polled.
    const SDL_PropertiesID props = SDL_CreateProperties();
    SDL_SetStringProperty(props, "name", "sdl3-headless");
    if (std::string_view(SDL_GetStringProperty(props, "name", "")) != "sdl3-headless") return 2;
    SDL_DestroyProperties(props);
    const Uint32 type = SDL_RegisterEvents(1);
    SDL_Event e{};
    e.type = type;
    e.user.code = 42;
    if (!SDL_PushEvent(&e)) return 3;
    int code = 0;
    while (SDL_PollEvent(&e))
        if (e.type == type) code = e.user.code;
    if (code != 42) return 4;

    // A window and the software renderer: a filled square read back.
    SDL_Window* window = nullptr;
    SDL_Renderer* renderer = nullptr;
    if (!SDL_CreateWindowAndRenderer("sdl3-headless", 32, 32, SDL_WINDOW_HIDDEN, &window, &renderer)) return 5;
    SDL_SetRenderDrawColor(renderer, 0, 0, 0, SDL_ALPHA_OPAQUE);
    SDL_RenderClear(renderer);
    SDL_SetRenderDrawColor(renderer, 255, 128, 0, SDL_ALPHA_OPAQUE);
    const SDL_FRect square{8, 8, 16, 16};
    SDL_RenderFillRect(renderer, &square);
    SDL_Surface* frame = SDL_RenderReadPixels(renderer, nullptr);
    Uint8 r = 0, g = 0, b = 0, a = 0;
    if (!frame || !SDL_ReadSurfacePixel(frame, 16, 16, &r, &g, &b, &a) || r != 255 || g != 128 || b != 0) return 6;
    SDL_DestroySurface(frame);
    SDL_DestroyRenderer(renderer);
    SDL_DestroyWindow(window);

    // Pixel-format macros, an inline rectangle function, an audio conversion.
    static_assert(SDL_BITSPERPIXEL(SDL_PIXELFORMAT_ARGB8888) == 32 && SDL_FOURCC('Y', 'V', '1', '2') == SDL_PIXELFORMAT_YV12);
    const SDL_Rect rect{0, 0, 4, 4};
    const SDL_Point inside{1, 2};
    if (!SDL_PointInRect(&inside, &rect)) return 7;
    const SDL_AudioSpec from{SDL_AUDIO_S16, 1, 8000}, to{SDL_AUDIO_F32, 1, 8000};
    SDL_AudioStream* stream = SDL_CreateAudioStream(&from, &to);
    const Sint16 half = 16384;
    float out = 0;
    if (!stream || !SDL_PutAudioStreamData(stream, &half, sizeof half) || !SDL_FlushAudioStream(stream) ||
        SDL_GetAudioStreamData(stream, &out, sizeof out) != sizeof out || out != 0.5f)
        return 8;
    SDL_DestroyAudioStream(stream);
    SDL_Quit();
    std::println("sdl3-headless: ok (SDL {}.{}.{}, {})", SDL_MAJOR_VERSION, SDL_MINOR_VERSION, SDL_MICRO_VERSION, SDL_GetPlatform());
    return 0;
}
