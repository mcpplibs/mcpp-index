# Add `huxerui.archive` (`0.1.1`)

## Summary

Add `huxerui.archive` (`pkgs/h/huxerui.archive.lua`) at upstream release `v0.1.1` (`HuxerUI/Lib-Archive@f18b0923`) as a Form A external native C++23 module package.

## Why `v0.1.1`

- Upstream `HuxerUI/Lib-Archive` already had an earlier CMake-only tag `v0.1.0` (`1ab08f03`) before native `mcpp` support existed.
- Upstream PR `#1` (`f18b0923`, `feat(mcpp): add native mcpp and C++23 modules support`) added `mcpp.toml`, `build.mcpp`, and `modules/archive.cppm` (`export module huxerui.archive;`) and bumped `[package].version` to `0.1.1` (`c16a2ad9`), tagged as `v0.1.1` (`566ccd93` -> `f18b0923`).

## Package Architecture

- **Form A (External Native C++23 Module Package)**:
  - Upstream tag archive carries `mcpp.toml`, `build.mcpp` (`huxerui.rules`), and `modules/archive.cppm` (`export module huxerui.archive;`, hand-maintained with `cpp_modules_gen = false` because `HuxerUI`'s `strip_noncode()` misparses the `100'000` C++14 digit separator in `include/huxerui/archive.h:64`).
  - Upstream `Lib-Archive-0.1.1/mcpp.toml` (`standard = "c++23"`) declares dependencies on `huxerui.huxerui = "0.5.5"` and `[dependencies.compat]` (`libarchive = "3.8.7"`, `zlib = "1.3.2"`, `zstd = "1.5.7"`), plus `defines = ["NOMINMAX"]` on Windows. `compat.libarchive` in turn resolves `compat.bzip2 = "1.0.8"`, `compat.lz4 = "1.10.0"`, and `compat.xz = "5.8.3"`.
  - No inline `mcpp` build segment is declared in `pkgs/h/huxerui.archive.lua`, and no extra `xpm.<platform>.deps` closure is duplicated because transitive Linux GTK4 `xim` dependencies arrive through `pkgs/h/huxerui.huxerui.lua`.
- **License**: `MIT` (package metadata in `pkgs/h/huxerui.archive.lua`).
- **Archive & CN Mirror Status**:
  - `https://github.com/HuxerUI/Lib-Archive/archive/refs/tags/v0.1.1.tar.gz` (`231,902` bytes), SHA256 verified twice: `0bc89691c19a84b8879453eb50e4e5f05533539f04527e87b5b231e25358ca6a`.
  - Plain upstream GitHub URLs are used across `linux`, `macosx`, and `windows` (no CN `mcpp-res` mirror yet; maintainers can add CN mirrors later).
- **Features**: None declared upstream.
- **Automatic Updates**: `extensions.autoupdate` tracks `HuxerUI/Lib-Archive` with `tag = "v${version}"`.

## Workspace Test Member

- `tests/examples/huxerui-archive` (`[indices] huxerui = { path = "../../.." }`, `standard = "c++23"`, `huxerui.archive = "0.1.1"`), registered in root `mcpp.toml`:
  - `tests/archive.cpp` imports `std` and `huxerui.archive` headlessly, exercising gzip and Zstandard `CompressStream`/`DecompressStream` round-trips and truncated-stream `ArchiveErrorCode::InvalidData` detection, `ArchiveWriter`/`ArchiveReader` round-trips across `ArchiveFormat::{Zip, Tar, TarGzip, TarZstd}` (`AddEntry`, `AddDirectory`, `AddPath`, `ListEntries`, `ReadEntry`, `ExtractEntry`, `ExtractAll`), and `CreateArchive`/`ExtractArchive` helpers.

## Verification

- Local verification in clean isolated worktree (`mcpp 2026.11.23.1`, `gcc@16.2.0`, cold `MCPP_HOME=$PWD/target/package-validation-home`, `MCPP_INDEX_MIRROR=GLOBAL`):
  - All 8 Lua 5.4 lint scripts passed (`check_capability_providers.lua`, `check_mirror_urls.lua`, `check_package_name.lua`, `check_reserved_namespace.lua`, `check_mplugin_layout.lua`, `check_cross_package_refs.lua`, `check_platform_version_parity.lua`, `check_duplicate_versions.lua`).
  - `mcpp xpkg parse pkgs/h/huxerui.archive.lua`: `form A — no mcpp segment (build info from the source's mcpp.toml)`, `parse OK`.
  - `mcpp index update && bash tests/run_members.sh huxerui-archive`: downloaded `huxerui:archive@0.1.1`, `huxerui.huxerui@0.5.5`, `compat.{libarchive@3.8.7, zlib@1.3.2, zstd@1.5.7, bzip2@1.0.8, lz4@1.10.0, xz@5.8.3}`, ran `bin/archive`, printed `archive module_smoke: ok`, and passed (`test result ok. 1 passed; 0 failed; finished in 362.93s`). Note: the test binary emits a non-fatal mcpp diagnostic about 88 zlib symbols shared between statically linked `compat.zlib@1.3.2` and GTK4's `xim:zlib@1.3.1` (`libz.so.1.3.1`).
