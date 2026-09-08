// Behavioral test — compat.sdl3 builds a working SDL3, not just headers.
//
// SDL is a library where "it compiled" is especially weak evidence: most of it
// is backends selected by a config header, and a wrong config produces a
// library that links and then has no video driver at all. So the assertions
// below are about what the BUILD CONFIG decided:
//
//   * the runtime version matches the headers (one tarball, not two)
//   * the compiled-in video driver list contains dummy AND offscreen, which
//     are exactly what a config that fell through to SDL_build_config_minimal.h
//     would NOT have
//   * the dummy driver actually initialises, creates a window, and gives back
//     a surface of the requested size
//   * the timer subsystem advances
//
// No `import std;` — SDL's headers are textual C over the standard headers.
// SDL_MAIN_HANDLED + SDL_main.h: this test brings its own main(), so SDL must
// not rename it. SDL_SetMainReady() is declared in SDL_main.h, not SDL.h.
#define SDL_MAIN_HANDLED
#include <SDL3/SDL.h>
#include <SDL3/SDL_main.h>

#include <cstdio>
#include <cstring>

int main() {
    // Header/runtime agreement. SDL_VERSION is the compile-time constant from
    // the headers; SDL_GetVersion() is what the linked objects report.
    const int compiled = SDL_VERSION;
    const int linked   = SDL_GetVersion();
    if (compiled != linked) {
        std::printf("header says %d, library says %d — two different SDLs\n", compiled, linked);
        return 1;
    }
    if (linked != SDL_VERSIONNUM(3, 4, 2)) {
        std::printf("SDL version is %d, expected 3.4.2\n", linked);
        return 2;
    }

    SDL_SetMainReady();

    // The compiled-in driver list. A minimal config has none of these.
    const int drivers = SDL_GetNumVideoDrivers();
    if (drivers <= 0) {
        std::printf("no video drivers compiled in — the build config did not take\n");
        return 3;
    }
    bool haveDummy = false, haveOffscreen = false;
    for (int i = 0; i < drivers; ++i) {
        const char* name = SDL_GetVideoDriver(i);
        if (!name) continue;
        if (std::strcmp(name, "dummy") == 0) haveDummy = true;
        if (std::strcmp(name, "offscreen") == 0) haveOffscreen = true;
    }
    if (!haveDummy || !haveOffscreen) {
        std::printf("driver list is missing dummy/offscreen (%d drivers):", drivers);
        for (int i = 0; i < drivers; ++i) std::printf(" %s", SDL_GetVideoDriver(i));
        std::printf("\n");
        return 4;
    }

    // Force dummy so this works with no display on any platform.
    SDL_SetHint(SDL_HINT_VIDEO_DRIVER, "dummy");
    if (!SDL_Init(SDL_INIT_VIDEO)) {
        std::printf("SDL_Init(VIDEO) failed: %s\n", SDL_GetError());
        return 5;
    }

    const char* current = SDL_GetCurrentVideoDriver();
    if (!current || std::strcmp(current, "dummy") != 0) {
        std::printf("current video driver is %s, expected dummy\n", current ? current : "(null)");
        SDL_Quit();
        return 6;
    }

    SDL_Window* window = SDL_CreateWindow("mcpp-index sdl3", 320, 240, 0);
    if (!window) {
        std::printf("SDL_CreateWindow failed: %s\n", SDL_GetError());
        SDL_Quit();
        return 7;
    }
    int w = 0, h = 0;
    SDL_GetWindowSize(window, &w, &h);
    if (w != 320 || h != 240) {
        std::printf("window is %dx%d, asked for 320x240\n", w, h);
        SDL_DestroyWindow(window);
        SDL_Quit();
        return 8;
    }

    // The dummy driver still backs a window with a real surface, so this
    // exercises the surface/pixel code rather than only the window bookkeeping.
    SDL_Surface* surface = SDL_GetWindowSurface(window);
    if (!surface || surface->w != 320 || surface->h != 240) {
        std::printf("window surface missing or wrong size: %s\n", SDL_GetError());
        SDL_DestroyWindow(window);
        SDL_Quit();
        return 9;
    }
    if (!SDL_FillSurfaceRect(surface, nullptr, SDL_MapSurfaceRGB(surface, 0, 0, 0))) {
        std::printf("SDL_FillSurfaceRect failed: %s\n", SDL_GetError());
        SDL_DestroyWindow(window);
        SDL_Quit();
        return 10;
    }

    // Timer subsystem: SDL_GetTicks must advance across a delay.
    const Uint64 before = SDL_GetTicks();
    SDL_Delay(20);
    const Uint64 after = SDL_GetTicks();
    if (after < before + 10) {
        std::printf("SDL_GetTicks did not advance (%llu -> %llu)\n",
                    (unsigned long long)before, (unsigned long long)after);
        SDL_DestroyWindow(window);
        SDL_Quit();
        return 11;
    }

    SDL_DestroyWindow(window);
    SDL_Quit();

    std::printf("compat.sdl3: ok (version 3.4.2, %d video drivers, dummy window 320x240, timer advances)\n",
                drivers);
    return 0;
}
