# Add `huxerui.datatable` (`0.1.0`)

## Summary

Add `huxerui.datatable` (`pkgs/h/huxerui.datatable.lua`) at upstream release `v0.1.0` (`HuxerUI/Lib-DataTable@a959fad9`).

## Package Architecture

- **Form A (External Native C++23 Module Package)**:
  - Upstream tag archive carries its own `mcpp.toml` (`Lib-DataTable-0.1.0/mcpp.toml`), `build.mcpp` (`huxerui.rules`), `include/huxerui/datatable.h`, `src/lib_data_table.cpp`, `src/table_layout.cpp`, and `modules/datatable.cppm` (`export module huxerui.datatable;`), depending on `huxerui.huxerui = "0.5.5"` (`standard = "c++23"`).
  - No inline `mcpp` build segment is declared in `pkgs/h/huxerui.datatable.lua`, and no extra `xpm.<platform>.deps` closure is duplicated because transitive Linux GTK4 `xim` dependencies come through `pkgs/h/huxerui.huxerui.lua`.
- **License**: `MIT` (verified against `Lib-DataTable-0.1.0/LICENSE` and `Lib-DataTable-0.1.0/mcpp.toml`).
- **Archive & CN Mirror Status**:
  - `https://github.com/HuxerUI/Lib-DataTable/archive/refs/tags/v0.1.0.tar.gz` (`225,346` bytes), SHA256 verified twice: `592214822fd848af181cc076c07cae16634f8e5483fa3bdafef5443cab311351`.
  - Plain upstream GitHub URLs (`v0.1.0`) are used across `linux`, `macosx`, and `windows` (no local `gitcode.com/mcpp-res` credentials available; maintainers can add CN mirrors later).
- **Features**: None declared upstream.
- **Automatic Updates**: `extensions.autoupdate` tracks `HuxerUI/Lib-DataTable` with `tag = "v${version}"`.

## Workspace Test Member

- `tests/examples/huxerui-datatable` (`[indices] huxerui = { path = "../../.." }`, `standard = "c++23"`, `huxerui.datatable = "0.1.0"`), registered in root `mcpp.toml`:
  - `tests/examples/huxerui-datatable/tests/datatable.cpp` imports `std` and `huxerui.datatable` headlessly, verifying `DataTableCellId` / `DataTableSort` value equality, out-of-line `std::invalid_argument` validation paths (non-positive `row_height`, duplicate column IDs, missing row callbacks), and declarative `DataTable(...)` view construction with sorting, frozen columns, inline editor, and event handlers.

## Verification

- Local verification in isolated worktree (`mcpp 2026.11.23.1`, `gcc@16.2.0`, `MCPP_INDEX_MIRROR=GLOBAL`):
  - All 8 Lua 5.4 lint scripts (`check_capability_providers.lua`, `check_mirror_urls.lua`, `check_package_name.lua`, `check_reserved_namespace.lua`, `check_mplugin_layout.lua`, `check_cross_package_refs.lua`, `check_platform_version_parity.lua`, `check_duplicate_versions.lua`), plus `check_quill_install.lua` and `tools/platform_rows.py check`, passed.
  - `mcpp xpkg parse pkgs/h/huxerui.datatable.lua` (`0.1.0`, `form A`, `parse OK`).
  - `tests/select_members.py --base upstream/main pkgs/h/huxerui.datatable.lua` selected `huxerui-datatable`.
  - Cold `bash tests/run_members.sh huxerui-datatable` in clean `target/package-validation-home` downloaded `v0.1.0.tar.gz`, built `huxerui.datatable v0.1.0` and `huxerui.huxerui v0.5.5`, passed `datatable ... ok (0.02s)` (`test result ok. 1 passed; 0 failed; finished in 377.64s`), and locked `huxerui.datatable@0.1.0` + `huxerui.huxerui@0.5.5` in `mcpp.lock`.
