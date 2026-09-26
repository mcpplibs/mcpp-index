# Design doc: bump `compat.eui-neo` to 0.6.0

Date: 2026-09-26

Follow-up to `.agents/docs/2026-09-04-bump-eui-neo-0.5.9-plan.md` and commit `1cf5768` (0.5.9),
plus the index-side re-release `0.5.9.1` (vulkan loader re-pin). Upstream released 0.6.0;
this bumps the index from 0.5.9.1 to 0.6.0.

## Source and version

| | |
|---|---|
| Upstream | `https://github.com/sudoevolve/EUI-NEO` |
| Version | `0.6.0` (latest release) |
| Tarball | `archive/refs/tags/v0.6.0.tar.gz` |
| sha256 | `11d0725bcc6f16abbbea6052b58c6949008cf78ceaa1645002ba1b3abf9772a1` (derived from the tag tarball) |
| Wrap dir | `EUI-NEO-0.6.0/` — absorbed by the existing `install()` hook (`normalise_layout`) |
| CN mirror | **pending** — no `mcpp-res` write access on this machine; plain-string url fallback per SOP |
| License | Apache-2.0 (unchanged) |

## What changed upstream (0.5.9 → 0.6.0)

- `CORE_SOURCES` gains exactly one TU: `core/audio/audio.cpp` — a streaming audio `Player`
  behind the new `include/eui/audio.h` (`eui::audio`, surfaced through the umbrella header).
- The TU vendors **miniaudio 0.11.21** as a single header at `3rd/miniaudio.h` and carries
  `#define MINIAUDIO_IMPLEMENTATION` itself; no other TU in the lib touches it. Upstream adds
  `${EUI_MINIAUDIO_DIR}` (= `3rd/`) as a **PRIVATE** include dir because audio.cpp includes it
  by bare name `"miniaudio.h"`.
- Upstream link additions for miniaudio: `${CMAKE_DL_LIBS} m` PUBLIC on Linux;
  `CoreAudio + AudioToolbox + CoreFoundation` frameworks on macOS; nothing on Windows (the
  WASAPI backend binds its APIs at runtime).
- `core/audio/audio.h` is a pimpl header (only `<memory>`, `<string>`) — consumers never need
  the `3rd/` search path.
- Everything else is app- or CMake-level: `EUI_ENABLE_MODULES` default, an INTERFACE
  `EUI_DEBUG_BUILD=1` tied to CMake Debug config, new example targets (`promo`, `vcd_viewer`),
  probe test properties. `tray_bridge.c` differs from 0.5.9 only in comment language + EOF
  newline (verified by diff). `3rd/` dependency pins, features, and flags carry over unchanged.
- `-fno-char8_t` remains required.

## Descriptor changes (`pkgs/e/compat.eui-neo.lua`)

- `xpm.<linux|macosx|windows>["0.6.0"]`: plain-string GLOBAL url (no CN mirror), sha256 above.
- `sources += */core/audio/audio.cpp`.
- `*/3rd` added to the platform-level `include_dirs` + `private_include_dirs` pair on all
  three legs (linux: extended beside the glib path) — the miniaudio bare include, package-side
  only. ⚠️ A BASE-level `private_include_dirs` was tried first and is **inert**: measured, not
  assumed — audio.cpp's dependency scan failed with `'miniaudio.h' file not found` while every
  base-level `include_dirs` entry took effect normally. The platform-level pair is the shape
  the glib leg already established from emitted `compile_commands.json` (the -I lands on the
  package's own TUs and not on consumers'). Publishing `*/3rd` would expose bare
  `stb_image.h`/`nanosvg.h`/`miniaudio.h` and shadowed vendored copies of index packages in
  every consumer TU.
- linux `ldflags += -lm`; macosx `ldflags += -framework CoreAudio -framework AudioToolbox
  -framework CoreFoundation`; windows unchanged.
- Header comment: recipe now tracks `CMakeLists.txt` v0.6.0; `3rd/` note counts miniaudio as
  the fourth vendored single-file header; new 0.6.0 paragraph.

## Test members

All seven `tests/examples/eui-neo*` members bumped to `0.6.0` (the vulkan member moves from
`0.5.9.1`; the rest from `0.5.9`). No test source changes: the 0.6.0 surface this workspace
exercises (backends, app-mains, tray, markdown, network) is unchanged; the audio Player is
new API that no member reaches yet.

## Verification

Locally, mcpp 2026.9.26.2 (upgraded for this run — the index floor moved to 2026.9.18.3),
Linux x86_64:

- Index lint: `check_mirror_urls`, `check_platform_version_parity`, `check_duplicate_versions`,
  `check_package_name`, `check_cross_package_refs` — all clean on the descriptor.
- First revision used a BASE-level `private_include_dirs = { "*/3rd" }`; audio.cpp's dependency
  scan failed (`'miniaudio.h' file not found`) — the finding recorded in the descriptor. The
  platform-level pair replaced it.
- All seven members `mcpp test` green: eui-neo (headless), eui-neo-window, eui-neo-app-main,
  eui-neo-markdown, eui-neo-sdl2 (sdl2+network), eui-neo-vulkan, eui-neo-tray.
- Interface check on the emitted `compile_commands.json`: the package's `core/audio/audio.cpp`
  TU carries `-I …/eui-neo-0.6.0/3rd`; the member's consumer TU carries neither the 3rd path
  nor the glib path — private pairing behaves the same as the glib leg.

Windows/macOS legs rest on CI: the descriptor changes there are additive (source list + the
same private include pair + frameworks), and upstream's own CMake pins the same link model
(nothing extra on Windows; three frameworks on macOS).
