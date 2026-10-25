# Update compat:imgui to 1.93.0

## Scope and source

- Upstream: <https://github.com/ocornut/imgui/releases/tag/v1.93.0>, released 2026-10-14.
- Add `1.93.0` and `1.93.0-docking` to Linux, macOS and Windows; retain both 1.92.8 entries.
- Keep the existing Form B recipe: four core C++ sources, public headers and backend include directory.
- Update the `imgui` and `imgui-window` example dependencies to `1.93.0`.
- The separate `ocornut:imgui` module package is outside this update.

## Archives and mirrors

The GitHub tag archives were downloaded and each SHA-256 was calculated twice:

| Version | SHA-256 |
| --- | --- |
| 1.93.0 | `f7bf6bc76e5d79d40d751096663e6c5d18daf08129dd52e7f7b09e4251c8eeee` |
| 1.93.0-docking | `746c265540bd3aa109570f29492ef4d8f5b421dd9fd0049c35ca35f21496f1a5` |

No GitCode configuration or token is available in this environment. The new entries use plain upstream URLs,
as allowed by `docs/zh/cn-mirror.md`; the existing 1.92.8 mirror entries are retained.

## Recipe and compatibility

There are no new sources to gate behind a feature. Docking remains an upstream archive variant.
The existing rendering test exercises context creation, font atlas generation and valid draw data without a display.
1.93.0 changes custom draw-list rendering; see upstream's release notes for stroke and pixel-alignment changes.

## Validation

- Lua syntax, mirror URL rules, package identity, reserved namespaces, platform version parity and duplicate-version checks passed.
- `mcpp xpkg parse pkgs/c/compat.imgui.lua` passed with both the CI-pinned mcpp 2026.10.1.2 and local mcpp 2026.10.11.1,
  listing both new versions on all three platforms.
- `mcpp test -p imgui --cache local` passed on Windows with the CI-pinned mcpp 2026.10.1.2 and LLVM 23.1.3 / system MSVC:
  the 1.93.0 core sources were recompiled, and the rendering test passed (one test, zero failures).
- The verified `1.93.0-docking` archive's four core sources were compiled directly with `clang++ -std=c++23`, together
  with the existing `tests/examples/imgui/tests/render.cpp`. The resulting executable passed (exit code 0).
  A separate mcpp docking test was stopped after spending over three minutes waiting on another archive download;
  the docking check therefore covers the downloaded source build and rendering, not a completed mcpp install.
- `imgui-window` is Linux-only; Windows does not exercise its backend build or window rendering.
