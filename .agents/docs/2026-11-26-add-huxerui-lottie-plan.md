# Add `huxerui.lottie` (`0.1.0`)

## Summary

Add `huxerui.lottie` (`pkgs/h/huxerui.lottie.lua`) at upstream release `v0.1.0` (`HuxerUI/Lib-Lottie@19370344`) in an isolated single-package PR.

## Package Architecture

- **Form A (External Native C++23 Module Package)**:
  - Upstream tag archive carries its own `mcpp.toml` (`Lib-Lottie-0.1.0/mcpp.toml`), `build.mcpp` (`huxerui.rules`), platform work queue / frame presenter sources, and `modules/lottie.cppm` (`export module huxerui.lottie;`, `export import huxerui;`), depending on `huxerui.huxerui = "0.5.5"` and `compat.thorvg = "1.1.3"` (`standard = "c++23"`).
  - No inline `mcpp` build segment is declared in `pkgs/h/huxerui.lottie.lua`, and no extra `xpm.<platform>.deps` closure is duplicated because transitive SDK / platform `xim` dependencies resolve through `huxerui.huxerui = "0.5.5"` and ThorVG CPU rasterizer + Lottie loader support resolves through `compat.thorvg = "1.1.3"`.
- **License**: `MIT` (verified against `Lib-Lottie-0.1.0/LICENSE` and `Lib-Lottie-0.1.0/mcpp.toml`).
- **Archive & CN Mirror Status**:
  - `https://github.com/HuxerUI/Lib-Lottie/archive/refs/tags/v0.1.0.tar.gz` (`292,189` bytes), SHA256 verified twice: `d4c122867e3b002c71012d1d46c84bc1409d571f847d59636bb3808a997457ce`.
  - Plain upstream GitHub URLs are used across `linux`, `macosx`, and `windows` (no CN `mcpp-res` mirror yet; maintainers can add CN mirrors later).
- **Features**: None declared upstream.
- **Automatic Updates**: `extensions.autoupdate` tracks `HuxerUI/Lib-Lottie` with `tag = "v${version}"`.

## Workspace Test Member

- `tests/examples/huxerui-lottie` (`[indices] huxerui = { path = "../../.." }`, `standard = "c++23"`, `huxerui.lottie = "0.1.0"`):
  - `tests/lottie.cpp` imports `std`, `huxerui`, and `huxerui.lottie` headlessly, verifying `LottiePlayback` / `LottieProgress` / `LottieSource` / `LottieControl` public types, negative validation (`missing Install` throws `std::logic_error`, invalid speed and non-finite progress throw `std::invalid_argument`), full ThorVG-backed async decode, frame rendering, completion, and seek (`LottieEvents::Loaded`, `LottieEvents::Completed`, `ExternalTexture` revision advancement), plus negative decode/resource failure paths (`LottieError::Stage::Decode` and `LottieError::Stage::Resource`).

## Verification

- Local verification in isolated worktree (`mcpp 2026.11.23.1`, isolated `MCPP_HOME="$PWD/target/package-validation-home"`, `MCPP_INDEX_MIRROR=GLOBAL`, `gcc@16.2.0`):
  - All 8 Lua 5.4 lint scripts passed (`check_capability_providers.lua`, `check_mirror_urls.lua`, `check_package_name.lua`, `check_reserved_namespace.lua`, `check_mplugin_layout.lua`, `check_cross_package_refs.lua`, `check_platform_version_parity.lua`, `check_duplicate_versions.lua`).
  - `mcpp xpkg parse pkgs/h/huxerui.lottie.lua` succeeded (`0.1.0` across `linux`/`macosx`/`windows`, `form A — no mcpp segment`, `parse OK`).
  - Cold `bash tests/run_members.sh huxerui-lottie` passed: built `compat.thorvg v1.1.3`, `huxerui.huxerui v0.5.5`, and `huxerui.lottie v0.1.0`, ran `bin/lottie` (`lottie-consumer: all checks passed`, `test result ok. 1 passed; 0 failed; finished in 343.39s`), and recorded `huxerui.lottie@0.1.0`, `huxerui.huxerui@0.5.5`, and `compat.thorvg@1.1.3` in `mcpp.lock`.
