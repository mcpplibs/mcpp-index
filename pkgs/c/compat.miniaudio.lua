-- Form B inline descriptor for miniaudio — a single-file audio playback and
-- capture library that wraps every platform's native backend (WASAPI/DirectSound/
-- WinMM, Core Audio, ALSA/PulseAudio/JACK, OSS, AAudio/OpenSL, Web Audio) behind
-- one API, plus decoding for WAV/FLAC/MP3 and a mixing/resampling engine.
--
-- SHAPE: header-only WITH an upstream-supplied implementation TU. `miniaudio.h`
-- carries both the declarations and, behind MINIAUDIO_IMPLEMENTATION, the whole
-- implementation; `miniaudio.c` at the tarball root is upstream's own two-line
-- driver for it:
--
--     #define MINIAUDIO_IMPLEMENTATION
--     #include "miniaudio.h"
--
-- Compiling that file here is what makes this a linkable package rather than a
-- pile of headers, and it is upstream's supported way to do it (CMakeLists.txt
-- builds the `miniaudio` library target from exactly this source).
--
-- CONSEQUENCE FOR CONSUMERS: do NOT also define MINIAUDIO_IMPLEMENTATION in your
-- own code. The implementation is already compiled into this package's lib, and
-- defining the macro a second time gives you every miniaudio symbol twice --
-- a LINK error, not a compile error, so it surfaces late. Just
-- `#include <miniaudio.h>` and link.
--
-- THE WEB: on wasm32-emscripten miniaudio enables its Web Audio backend (and
-- the custom one; the null backend needs threads and is not built there). It
-- needs no flag of its own beyond the GNU C dialect below (`c_standard`).
--
-- SYSTEM LIBRARIES: miniaudio dlopen()s its backends rather than linking them,
-- which is why the Linux link line is `-ldl -lpthread -lm` and NOT -lasound /
-- -lpulse -- ALSA and PulseAudio are resolved at runtime if present, so the
-- package builds on a machine that has neither. (CMakeLists.txt: THREADS,
-- ${CMAKE_DL_LIBS}, m.)
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "miniaudio",
    description = "Single-file audio playback and capture library with native backends and WAV/FLAC/MP3 decoding",
    licenses    = {"MIT-0", "Unlicense"},
    repo        = "https://github.com/mackron/miniaudio",
    type        = "package",

    xpm = {
        linux = {
            ["0.11.25"] = {
                url    = {
                    GLOBAL = "https://github.com/mackron/miniaudio/archive/refs/tags/0.11.25.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/miniaudio/releases/download/0.11.25/miniaudio-0.11.25.tar.gz",
                },
                sha256 = "b900edcffe979816e2560a0580b9b1216d674b4f17fbadeca8f777a7f8ab0274",
            },
        },
        macosx = {
            ["0.11.25"] = {
                url    = {
                    GLOBAL = "https://github.com/mackron/miniaudio/archive/refs/tags/0.11.25.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/miniaudio/releases/download/0.11.25/miniaudio-0.11.25.tar.gz",
                },
                sha256 = "b900edcffe979816e2560a0580b9b1216d674b4f17fbadeca8f777a7f8ab0274",
            },
        },
        windows = {
            ["0.11.25"] = {
                url    = {
                    GLOBAL = "https://github.com/mackron/miniaudio/archive/refs/tags/0.11.25.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/miniaudio/releases/download/0.11.25/miniaudio-0.11.25.tar.gz",
                },
                sha256 = "b900edcffe979816e2560a0580b9b1216d674b4f17fbadeca8f777a7f8ab0274",
            },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        -- gnu11, not c11: on wasm32-emscripten the Web Audio backend is
        -- JavaScript emitted through EM_ASM, which Emscripten refuses under a
        -- strict -std=c* mode ("EM_ASM does not work in -std=c* modes, use
        -- -std=gnu* modes instead"; miniaudio.h §2.6: "You cannot use -std=c*
        -- compiler flags"). The GNU dialect changes nothing miniaudio relies on
        -- elsewhere: upstream's CMake build sets no standard, so GCC and Clang
        -- compile it at their gnu17 default on every platform.
        c_standard   = "gnu11",
        -- Tarball root: `#include <miniaudio.h>`.
        include_dirs = { "*" },
        sources      = { "*/miniaudio.c" },
        targets      = { ["miniaudio"] = { kind = "lib" } },
        deps         = { },
        linux = {
            -- Backends are dlopen()ed, so no -lasound / -lpulse here.
            ldflags = { "-ldl", "-lpthread", "-lm" },
        },
        macosx = {
            ldflags = { "-lpthread", "-lm" },
        },
    },
}
