# Design doc: bump `compat.eui-neo` to 0.6.5 (including 0.6.4)

Date: 2026-11-26

Follow-up to `.agents/docs/2026-11-15-bump-eui-neo-0.6.3-plan.md` and commit `91c0bbb1` (`0.6.3`).
Upstream published `v0.6.4` (Hotfix) and `v0.6.5`; this adds both `0.6.4` and `0.6.5` to `compat.eui-neo` and exposes upstream's optional scientific plotting module (`modules/plot/`) as the `plot` feature.

## Source and versions

| | `0.6.4` (Hotfix) | `0.6.5` (Latest) |
|---|---|---|
| Upstream | `https://github.com/sudoevolve/EUI-NEO` | `https://github.com/sudoevolve/EUI-NEO` |
| Tarball | `archive/refs/tags/v0.6.4.tar.gz` | `archive/refs/tags/v0.6.5.tar.gz` |
| sha256 (checked twice, stable) | `d99b25600b996f1a03e3b06dfa6e0f620a50f20b281c842a0b68d7a82d92e5c1` | `b77b40341e4f6089bc3ad19dc9be723f461a83436d3b580a7ef50c2cd4d4e587` |
| Wrap dir | `EUI-NEO-0.6.4/` | `EUI-NEO-0.6.5/` |
| CN mirror | pending (`mcpp-res` write access unavailable locally; plain-string GLOBAL fallback) | pending (plain-string GLOBAL fallback) |
| License | Apache-2.0 (unchanged) | Apache-2.0 (unchanged) |

## What changed upstream

- **`0.6.3` -> `0.6.4`**: Hotfix for focus-ring visibility on mouse/touch vs keyboard input plus two MSVC C4996 cleanups in example apps (`calgary_gallery`, `serial_tool`). `CORE_SOURCES`, `VULKAN_SOURCES`, dependencies, and link flags are unchanged (`CMakeLists.txt` diff is version bump only).
- **`0.6.4` -> `0.6.5`** (`docs/releases/v0.6.5.md`):
  - Desktop UI components (`Form`, `MenuBar`, `layout.h`, `logicalWindowSize`, `DataTable` selection, `Slider` stepping, `Dropdown` z-order/focus). All header-only under `include/` / `components/` / `core/`.
  - Touch and multi-finger gesture bridge (`CORE_SOURCES` under GLFW):
    - Adds `core/platform/gesture_bridge.c` cross-platform:
      - Windows links `-lcomctl32` (`SetWindowSubclass`, `GetWindowSubclass`, `RemoveWindowSubclass`, `DefSubclassProc`).
      - macOS compiles `gesture_bridge.c` with `-x objective-c` (`NSEvent` monitor).
    - Linux GLFW adds `core/platform/linux_touch.cpp` and defines `EUI_LINUX_TOUCH_X11=1`, riding on `compat.glfw`'s transitive `compat.x11` + `compat.xi` (`XInput2`) dependencies. `EUI_LINUX_TOUCH_WAYLAND` remains disabled (`compat.glfw` is X11-only; upstream's bundled-GLFW Wayland patch does not apply).
  - Optional `modules/plot/` (`eui::module_plot`, 16 translation units: `data.cpp`, `waveform.cpp`, `axes.cpp`, `field.cpp`, `contour.cpp`, `geometry.cpp`, `vector.cpp`, `export.cpp`, `renderer.cpp`, `vulkan_renderer.cpp`, `plot.cpp`, `figure.cpp`, `scene3d.cpp`, `volume.cpp`, `plot3d.cpp`, `gpu_scene3d.cpp`). Exposed as the source-gated `plot` feature; reuses `compat.libpng`, `compat.freetype`, and the active render backend (`compat.glad` or `compat.vulkan`) already present in `deps` with no new third-party dependencies.

## Descriptor and workspace changes

- `pkgs/e/compat.eui-neo.lua`:
  - Added `["0.6.4"]` and `["0.6.5"]` to `xpm.linux`, `xpm.macosx`, and `xpm.windows` (plain-string GLOBAL URLs, retaining all prior entries).
  - Added `"*/core/platform/gesture_bridge.c"` to base `mcpp.sources` (safe 0-match glob on `<=0.6.4`).
  - Added `["plot"]` feature listing the 16 `modules/plot/*.cpp` TUs.
  - Added `"-lcomctl32"` to `mcpp.windows.ldflags`, `{ glob = "*/core/platform/gesture_bridge.c", cflags = { "-x", "objective-c" } }` to `mcpp.macosx.flags`, and `sources = { "*/core/platform/linux_touch.cpp" }` + `-DEUI_LINUX_TOUCH_X11=1` in `mcpp.linux.cxxflags`.
- Test members (`tests/examples/eui-neo*/mcpp.toml`): updated all 8 existing `eui-neo*` members to `"0.6.5"`.
- Added `tests/examples/eui-neo-plot` (`mcpp.toml` + `tests/plot.cpp`) and registered it in root `mcpp.toml`.

## Verification

Local Linux `x86_64` with CI-pinned `mcpp 2026.11.23.1`, isolated `package-validation-home`, `MCPP_INDEX_MIRROR=GLOBAL`:

- **Lint & parser** (Lua `5.4.8` + `mcpp xpkg parse`):
  - `check_mirror_urls`, `check_package_name`, `check_reserved_namespace`, `check_mplugin_layout`, `check_capability_providers`, `check_cross_package_refs`, `check_platform_version_parity`, `check_duplicate_versions` — all clean (no findings on `compat.eui-neo.lua`).
  - `mcpp xpkg parse pkgs/e/compat.eui-neo.lua` -> `features 8`, `parse OK`.
- **Workspace members (`0.6.5`, `tests/run_members.sh`)** — 9/9 passed:
  - `eui-neo`: `ok` (`compat.eui-neo smoke test: ok (parsed eui-neo v3, markdown gated off)`)
  - `eui-neo-app-main`: `ok` (`compat.eui-neo[app-main]: linked, main() supplied by the package; window run is opt-in`)
  - `eui-neo-markdown`: `ok` (`compat.eui-neo[markdown]: ok (2 blocks, h1 = 'Heading')`)
  - `eui-neo-plot`: `ok` (`PlotSession` + `Plot` + `WaveformBuffer` + `std::invalid_argument` on invalid `ExportScene`)
  - `eui-neo-sdl2`: `ok` (`compat.eui-neo[sdl2,network]: ok (SDL driver=dummy, curl 8.21.0-DEV ssl=OpenSSL/3.5.9)`)
  - `eui-neo-serial`: `ok` (`SerialPort` open/move assertions)
  - `eui-neo-tray`: `ok` (`linux tray backend verified over a private session bus`)
  - `eui-neo-vulkan`: `ok` (`compat.eui-neo[vulkan]: ok (backend=vulkan, loader api 1.4.357)`)
  - `eui-neo-window`: `ok` (`compat.eui-neo[own main]: linked; window run is opt-in`)
- **Negative check (`plot` feature)**: removing `features = ["plot"]` in `tests/examples/eui-neo-plot/mcpp.toml` failed link (`collect2: error: ld returned 1 exit status`, `undefined reference` to `modules::plot::Data::Data`, `Plot::setSeries`, `Plot::axes`); restoring `features = ["plot"]` returned `test result ok`.
- **Backward compatibility (`0.6.4`)**: verified `eui-neo` builds and passes (`test result ok`) when pinned to `0.6.4`, then restored to `0.6.5` and re-verified (`test result ok`).

## Notes

- macOS (`gesture_bridge.c` `-x objective-c`) and Windows (`-lcomctl32` for Win32 `WM_TOUCH`/`WM_GESTURE` subclassing) are unverified locally and rely on the PR's GitHub Actions `workspace` and `candidate` CI legs.
