-- compat.dr_libs — dr_wav, dr_flac and dr_mp3: single-file audio decoders
-- (and a WAV encoder) in C, no dependencies, MIT-0 OR Unlicense.
--
--   dr_wav.h   0.14.5   WAV / RIFF, RIFX, RF64, Sony Wave64 and AIFF: PCM,
--                       IEEE float, A-law, mu-law, MS and IMA ADPCM; reading,
--                       writing, metadata chunks (smpl, cue, acid, bext, ...).
--   dr_flac.h  0.13.3   FLAC (native and Ogg-encapsulated) decoding.
--   dr_mp3.h   0.7.3    MPEG-1/2 Layer III decoding (built on minimp3).
--
-- SHAPE: three single-file libraries in the stb tradition, as compat.nanosvg
-- packages two: each header holds the declarations and, behind
-- DR_WAV_IMPLEMENTATION / DR_FLAC_IMPLEMENTATION / DR_MP3_IMPLEMENTATION, the
-- implementation. Upstream ships no implementation .c, so this package
-- generates one TU that instantiates all three, once, into one static library.
-- A consumer writes `#include <dr_wav.h>` (`<dr_flac.h>`, `<dr_mp3.h>`) and
-- links -- the spelling upstream's own documentation uses.
--
-- CONSEQUENCE FOR CONSUMERS: do NOT also define DR_WAV_IMPLEMENTATION,
-- DR_FLAC_IMPLEMENTATION or DR_MP3_IMPLEMENTATION (or their DRWAV_ / DRFLAC_ /
-- DRMP3_ spellings). The implementations are already compiled into this
-- package's lib; defining one again duplicates its symbols, a LINK error that
-- surfaces late.
--
-- miniaudio embeds its own copies of the three, renamed (ma_dr_wav_*,
-- ma_dr_flac_*, ma_dr_mp3_*), so compat.miniaudio and compat.dr_libs link
-- into one program without a symbol in common.
--
-- VERSIONING: upstream tags each header on its own (wav-*, flac-*, mp3-*) in
-- one repository, and no tag names the three together. This pins the commit
-- archive of wav-0.14.5, fa931f3285ced10ace628f7f1ac951e1951e7ea6
-- (2026-03-03), whose dr_flac.h and dr_mp3.h are byte-identical to the
-- flac-0.13.3 and mp3-0.7.3 tags: the newest commit at which all three headers
-- are tagged releases (later commits carry untagged dr_wav/dr_mp3 changes).
-- Following compat.nanosvg and compat.khrplatform, the version is the commit's
-- DATE, 2026.03.03. No extensions.autoupdate: there is no single tag series to
-- follow; a bump re-checks the three headers' tags by hand.
--
-- CONFIGURATION: upstream's defaults, nothing defined. The stdio APIs stay on
-- (drwav_init_file, drflac_open_file, drmp3_init_file and their _w wide-path
-- forms: _wfopen_s / _wfopen on Windows, wcsrtombs + fopen elsewhere), as do
-- the conversion APIs (drwav_s16_to_f32 ...). SIMD is chosen by each header
-- at compile time from the compiler's own predefined macros (SSE2 / SSE4.1
-- when the target enables them, NEON on arm64); there is no runtime dispatch
-- to configure.
--
-- kind = "lib": a static library. DRWAV_API / DRFLAC_API / DRMP3_API are
-- `extern` unless DRWAV_DLL / DRFLAC_DLL / DRMP3_DLL is defined, and neither
-- side defines it, so the consumer's declarations match on every platform.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "dr_libs",
    description = "dr_libs (2026.03.03: dr_wav 0.14.5, dr_flac 0.13.3, dr_mp3 0.7.3) — single-file WAV/AIFF, FLAC and MP3 decoders and a WAV encoder in C, no dependencies",
    licenses    = {"MIT-0", "Unlicense"},
    repo        = "https://github.com/mackron/dr_libs",
    type        = "package",

    -- One source archive for every platform: portable C whose platform
    -- choices are made by the compiler's own predefined macros.
    xpm = {
        linux = {
            ["2026.03.03"] = {
                url = {
                    GLOBAL = "https://github.com/mackron/dr_libs/archive/fa931f3285ced10ace628f7f1ac951e1951e7ea6.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/dr_libs/releases/download/2026.03.03/dr_libs-2026.03.03.tar.gz",
                },
                sha256 = "b56be5930399b9ea81591a837e0c9ee959a5d57e90dac96e0af37dde1fa0bb7e",
            },
        },
        macosx = {
            ["2026.03.03"] = {
                url = {
                    GLOBAL = "https://github.com/mackron/dr_libs/archive/fa931f3285ced10ace628f7f1ac951e1951e7ea6.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/dr_libs/releases/download/2026.03.03/dr_libs-2026.03.03.tar.gz",
                },
                sha256 = "b56be5930399b9ea81591a837e0c9ee959a5d57e90dac96e0af37dde1fa0bb7e",
            },
        },
        windows = {
            ["2026.03.03"] = {
                url = {
                    GLOBAL = "https://github.com/mackron/dr_libs/archive/fa931f3285ced10ace628f7f1ac951e1951e7ea6.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/dr_libs/releases/download/2026.03.03/dr_libs-2026.03.03.tar.gz",
                },
                sha256 = "b56be5930399b9ea81591a837e0c9ee959a5d57e90dac96e0af37dde1fa0bb7e",
            },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        c_standard   = "c11",
        -- Upstream's spelling: `<dr_wav.h>`, `<dr_flac.h>`, `<dr_mp3.h>`.
        -- The headers carry their own extern "C" under __cplusplus.
        include_dirs = { "*" },
        -- Upstream ships no implementation TU, so supply one: the three
        -- single-file libraries instantiated here, once, for the package.
        generated_files = {
            ["mcpp_generated/dr_libs_impl.c"] = [==[
#define DR_WAV_IMPLEMENTATION
#include <dr_wav.h>

#define DR_FLAC_IMPLEMENTATION
#include <dr_flac.h>

#define DR_MP3_IMPLEMENTATION
#include <dr_mp3.h>
]==],
        },
        sources = { "mcpp_generated/dr_libs_impl.c" },
        -- Linked into shared objects by its consumers: position independent.
        linux   = { cflags = { "-fPIC" } },
        macosx  = { cflags = { "-fPIC" } },
        -- No -fPIC on Windows: PE/COFF has no such distinction, and clang
        -- rejects it for the MSVC target.
        targets = { dr_libs = { kind = "lib" } },
        deps    = {},
    },
}
