# Add mcpplibs.mwrap.dr_libs (dr_libs-m 2026.03.03)

## Form

- Third-party upstream [mackron/dr_libs](https://github.com/mackron/dr_libs), a choice of Unlicense or MIT-0. Upstream
  tags each header on its own; compat.dr_libs 2026.03.03 (the parent change) pins the commit archive of `wav-0.14.5`
  (fa931f3, `b56be593…bb7e`), whose `dr_flac.h` and `dr_mp3.h` are byte-identical to `flac-0.13.3` and `mp3-0.7.3`.
- Form A external mwrap module repository [mcpplibs/dr_libs-m](https://github.com/mcpplibs/dr_libs-m), package
  `mcpplibs.mwrap.dr_libs`, version 2026.03.03 (compat.dr_libs' date version; the three header versions and the commit
  in `[package.metadata.mwrap]`), tag series `mwrap-${version}`, tagged on the merged main commit (0d4c72e); release
  asset `dr_libs-m-2026.03.03.tar.gz` (`0dc7ac0e…dbe2`), CN mirror `gitcode.com/mcpp-res/mwrap-dr_libs` with identical
  bytes.
- One package, as compat.nanosvg packages its two stb-style headers: the three headers share one commit and one
  implementation TU, and a program using one usually uses another (miniaudio embeds all three). Each header is still
  its own module.
- Implementation ownership: the library is compat.dr_libs'. The wrapper vendors no upstream code; it retains
  upstream's README.md and LICENSE under `upstream/dr_libs/` (checksums in `upstream/documents.json`) and deploys them
  with its own LICENSE/NOTICE (`runtime.deploy`).

## Modules

- `mcpplibs.mwrap.dr_libs.wav` / `.flac` / `.mp3`: every type, enumerator and `*_API` function of the header's public
  part by `export using` (wav 42 / 48 / 94, flac 32 / 6 / 31, mp3 28 / 8 / 29), generated from the pinned headers; each
  re-exports `.macros` and is complete on its own. Every enum is named by its typedef, so the enumerators have linkage
  and are exported as they are. The root `mcpplibs.mwrap.dr_libs` re-exports all four.
- `mcpplibs.mwrap.dr_libs.macros`: the 171 object-like macros as `inline constexpr` of the type of their expansion (the
  version strings as references to constexpr char arrays). The headers define no computation macro.
- Stay macros, in `<mwrap/dr_libs/macros.hpp>` (= the three headers): `*_API`, `*_PRIVATE`, `*_DLL_*`,
  `DRFLAC_DEPRECATED`, `DRMP3_INLINE`, `DRMP3_GNUC_INLINE_HINT`, `*_STRINGIFY` / `*_XSTRINGIFY`, `DRFLAC_64BIT`,
  `DRFLAC_X64`, `DRFLAC_X86`, `DRFLAC_ARM` (28). Not mapped: the 3 include guards.

`tools/check_exports.py` fails when the generated sources are stale, a declaration is not exported by its submodule, or
a macro is neither mapped nor listed; every mapping is checked against the raw header in a header-mixing test.

## Verification

Wrapper CI (Linux x86_64 GCC 16.1 and LLVM 23.1.3, Linux arm64 GCC 16.1, macOS LLVM, Windows LLVM, all required): build,
eight test programs (the API through the module — WAV round trips in RIFF / Wave64 / RF64, IEEE float, A-law, mu-law,
a hand-written AIFF, cue metadata, narrow and wide paths; a FLAC fixture sample-exact against the signal of its
STREAMINFO MD5; an MP3 fixture to its LAME-gapless length; each submodule alone; the macros against the headers; header
mixing; compat.miniaudio in the same program decoding the fixtures to identical samples), the export audit, and the
example tool on the fixtures. The templates job scaffolds the default `tone` template as an installed package and runs
it. Until compat.dr_libs is on this index's main, the wrapper's CI resolves the compat namespace from the parent
change's branch (`tools/candidate_index.py`, a no-op once published).

Here, with the CI-pinned mcpp 2026.10.26.1:

- `bash tests/run_members.sh dr_libs-audio`: the real release archive through the candidate index; a WAV written and
  read back, a FLAC stream built in the test (CONSTANT subframes, CRC-8/16) decoded and seeked, the MP3 to 4410 frames
  with its 440 Hz tone, the `.flac` module alone, and the side header beside the import: `test result ok`.
- `python3 tests/mwrap/check_installed_template.py --package mcpplibs.mwrap.dr_libs@2026.03.03 --deploy`: the
  unmodified template from the real archive, then a relocated self-contained bundle whose `licenses/dr_libs/` holds the
  wrapper's LICENSE/NOTICE and dr_libs' README and LICENSE byte for byte.

## Motivation

openmui's coming audio engine (media.audio) decodes WAV, FLAC and MP3 assets; these permissively licensed decoders,
through modules, fit its statically linked framework, beside miniaudio for playback.
