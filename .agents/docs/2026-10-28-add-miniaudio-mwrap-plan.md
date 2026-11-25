# Add mcpplibs.mwrap.miniaudio (miniaudio-m 0.11.25)

## Form

- Third-party upstream [mackron/miniaudio](https://github.com/mackron/miniaudio), release 0.11.25 (2026-03-03), a
  choice of MIT No Attribution or the Unlicense (`MIT-0 OR Unlicense`). The tag archive (`b900edcf…0274`) is the one
  compat.miniaudio 0.11.25 pins. The parent change (#609) compiles it at gnu11, which Emscripten's `EM_ASM` (the Web
  Audio backend) requires; nothing else of the descriptor changes.
- Form A external mwrap module repository [mcpplibs/miniaudio-m](https://github.com/mcpplibs/miniaudio-m), package
  `mcpplibs.mwrap.miniaudio`, version 0.11.25 (first release of the identity, no revision suffix), tag series
  `mwrap-${version}` (`mwrap-0.11.25` on the merged main commit `4d338e4`); release asset `miniaudio-m-0.11.25.tar.gz`
  (`81fb7a80…7eb2`), CN mirror `gitcode.com/mcpp-res/mwrap-miniaudio` with identical bytes.
- Implementation ownership: the library is compat.miniaudio's (upstream's `miniaudio.c`, the header with
  `MINIAUDIO_IMPLEMENTATION`, compiled once). The wrapper vendors no upstream code; the module includes the header
  without the implementation. It retains upstream's README.md and LICENSE under `upstream/miniaudio/`, with checksums
  in `upstream/documents.json`, and deploys them with its own LICENSE/NOTICE (`runtime.deploy`).

## Modules

- `mcpplibs.mwrap.miniaudio`: every type and struct tag (266), enumerator (368) and `MA_API` function (931) of the
  API section of `miniaudio.h`, by `export using`, generated from the pinned header, each under the preprocessor
  condition the header declares it under (the POSIX thread types, `ma_IMMNotificationClient` under WASAPI, the
  `MA_NO_*` sections). miniaudio's enums are typedef'd, so their enumerators have linkage and are exported as they
  are. The three `static MA_INLINE` helpers (`ma_get_bytes_per_frame`, `ma_offset_pcm_frames_ptr_f32`,
  `ma_offset_pcm_frames_const_ptr_f32`) are adapted in `mcpplibs::mwrap::miniaudio`, each calling upstream's.
- `mcpplibs.mwrap.miniaudio.macros`: 27 value macros as `inline constexpr` of the type of their expansion; the
  header's compatibility names (`ma_resource_manager_job*`) as 3 type aliases and 8 constexpr function references.
- Stay macros, in `<mwrap/miniaudio/macros.hpp>` (= `<miniaudio.h>`): 69 — stringification, attributes and storage
  classes (`MA_API` …), the token-pasting atomic declarations, the platform tests (`MA_WIN32` …) and the backend tests
  (`MA_SUPPORT_*`, `MA_HAS_*`). Not mapped: `NULL` and the include guard.

`tools/check_exports.py` fails when the generated sources are stale, a declaration of any branch is not exported, a
macro is neither mapped nor listed, or a mapping is not checked against the raw header; and on each CI row, from the
compiler's own preprocessing with the module's compile command, when a declaration of that target is not exported
there or a macro defined there is unaccounted for.

## Verification

Wrapper CI (Linux x86_64 GCC 16.1 and LLVM 23.1.3, Linux arm64 GCC 16.1, macOS LLVM, Windows LLVM, and the Web:
wasm32-emscripten with emsdk 6.0.9 through mcpp, tests under node; all required): build, the four test programs (a
device on the Null backend, the engine without a device or threads, WAV encoding into memory, WAV/FLAC/MP3 decoding
from memory and from a file, converters, a filter, the ring buffer, every macro mapping, header mixing), the export
audit, and the audio file tool `examples/miniaudio` (tone, info, convert on WAV/FLAC/MP3; devices and playback on
the default backend: Null on Linux, Core Audio on macOS, WASAPI on Windows). On the Web row the Null backend does not
exist upstream and the Web Audio probe reports `MA_NO_BACKEND` under node (no `AudioContext`); every other test runs.
This index's CI has no wasm32-emscripten row, so the Web is the wrapper's to cover. The templates job scaffolds the
default `tone` template as an installed package and runs it. Until #609 is on this index's main, the wrapper's CI
resolves the compat namespace from that branch (`tools/candidate_index.py`, a no-op once published).

Here, with the CI-pinned mcpp 2026.10.26.1:

- `bash tests/run_members.sh miniaudio-engine`: the real release archive through the candidate index; the engine
  mixing a sound through a group, a WAV round trip in memory, the Null device, the macros, the inline adaptation and
  the side header beside the import: `test result ok`.
- `python3 tests/mwrap/check_installed_template.py --package mcpplibs.mwrap.miniaudio@0.11.25 --deploy`: the
  unmodified template from the real archive, then a relocated self-contained bundle whose `licenses/miniaudio/` holds
  the wrapper's LICENSE/NOTICE and miniaudio's README and LICENSE byte for byte.

## Motivation

openmui's audio engine (media.audio) plays, mixes and decodes through miniaudio on every platform it targets,
the Web included.
