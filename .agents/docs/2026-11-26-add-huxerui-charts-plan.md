# Add `huxerui.charts` (`0.1.1`)

## Summary

Add `huxerui.charts` (`pkgs/h/huxerui.charts.lua`) at upstream release `v0.1.1` (`HuxerUI/Lib-Charts@afda558b`).

## Upstream `v0.1.1` Tag Rationale

- Upstream `HuxerUI/Lib-Charts` already had an existing `v0.1.0` tag (`a0040624`) prior to HuxerUI 0.5 SDK migration and native `mcpp` packaging.
- `PR #4` (`afda558b`, tagged `v0.1.1`) migrated `PopupHandle` anchor usage to HuxerUI 0.5 `ViewHandle` (`2fce926a`), added native `mcpp` and C++23 module support (`dc76381a`: `mcpp.toml`, `build.mcpp`, `modules/charts.cppm`), and bumped the package version to `0.1.1` (`78e6f3c9`).

## Package Architecture

- **Form A (External Native C++23 Module Package)**:
  - Upstream tag archive ships `mcpp.toml`, `build.mcpp` (`huxerui.rules` configuring `resources` under resource namespace `charts`), and `modules/charts.cppm` (`export module huxerui.charts;`, `export import huxerui;`), depending on `huxerui.huxerui = "0.5.5"` (`standard = "c++23"`).
  - No inline `mcpp` build segment is declared in `pkgs/h/huxerui.charts.lua`, and no extra `xpm.<platform>.deps` closure is duplicated because transitive Linux GTK4 `xim` dependencies come through `pkgs/h/huxerui.huxerui.lua`.
- **License**: `MIT` (verified against `Lib-Charts-0.1.1/LICENSE` and `Lib-Charts-0.1.1/mcpp.toml`).
- **Archive & CN Mirror Status**:
  - `https://github.com/HuxerUI/Lib-Charts/archive/refs/tags/v0.1.1.tar.gz` (`280,329` bytes), SHA256 verified twice: `4abc8232a9e029f8028722503db5d40de6f421afd6f0432bdd673aad133c2109`.
  - Plain upstream GitHub URLs are used across `linux`, `macosx`, and `windows` (no CN `mcpp-res` mirror yet; maintainers can add CN mirrors later).
- **Features**: None declared upstream.
- **Automatic Updates**: `extensions.autoupdate` tracks `HuxerUI/Lib-Charts` with `tag = "v${version}"`.

## Workspace Test Member

- `tests/examples/huxerui-charts` (`[indices] huxerui = { path = "../../.." }`, `standard = "c++23"`, `huxerui.charts = "0.1.1"`), registered in root `mcpp.toml`:
  - `tests/examples/huxerui-charts/tests/charts.cpp` imports `std` and `huxerui.charts` headlessly, verifying `XYChartData`/`CategoryChartData`/`ScatterChartData`/`PieChartData` snapshots and `std::invalid_argument` validation, `ChartAxis` fluent builders and domain validation, `ChartTheme::Default()`, and declarative `LineChart`, `AreaChart`, `BarChart`, `ScatterChart`, and `PieChart` view construction.

## Verification

- Local verification in this isolated worktree (`mcpp 2026.11.23.1`, `gcc@16.2.0`, clean `MCPP_HOME="$PWD/target/package-validation-home"`):
  - All 8 Lua 5.4 repo lints (`check_capability_providers.lua`, `check_mirror_urls.lua`, `check_package_name.lua`, `check_reserved_namespace.lua`, `check_mplugin_layout.lua`, `check_cross_package_refs.lua`, `check_platform_version_parity.lua`, `check_duplicate_versions.lua`).
  - `mcpp xpkg parse pkgs/h/huxerui.charts.lua` (`0.1.1` across `linux`/`macosx`/`windows`, `form A`, `parse OK`).
  - Cold `mcpp index update && bash tests/run_members.sh huxerui-charts` downloading `v0.1.1.tar.gz`, building `huxerui.charts v0.1.1` and `huxerui.huxerui v0.5.5`, passing `charts ... ok (0.01s)` (`test result ok. 1 passed; 0 failed`), and recording `huxerui.charts@0.1.1` + `huxerui.huxerui@0.5.5` in `mcpp.lock`.
