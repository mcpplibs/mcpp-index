# Add `huxerui.sqlite` (`0.1.1`)

## Summary

Add `huxerui.sqlite` (`pkgs/h/huxerui.sqlite.lua`) at upstream release `v0.1.1` (`HuxerUI/Lib-SQLite@077b644d`).

## `v0.1.1` Tag Rationale

- Upstream `v0.1.0` (`0b316df4`) predates native `mcpp` and C++23 module support.
- `v0.1.1` (`077b644d`, PR `#8`: `feat(mcpp): add native mcpp and C++23 modules support`) adds `mcpp.toml`, `build.mcpp`, and `modules/sqlite.cppm`, bumps the package version to `0.1.1`, and migrates the dependency floor to `huxerui.huxerui = "0.5.5"` (`standard = "c++23"`).

## Package Architecture

- **Form A (External Native C++23 Module Package)**:
  - Upstream tag archive carries `mcpp.toml` (`Lib-SQLite-0.1.1/mcpp.toml`), `build.mcpp` (`huxerui.rules::configure({.resources = "resources", .resource_namespace = "sqlite"})`), `src/sqlite_backend.c` + C++ implementation sources, vendored SQLite `3.53.4` amalgamation (`third_party/sqlite/sqlite3.c`, `third_party/sqlite/sqlite3.h`), and `modules/sqlite.cppm` (`export module huxerui.sqlite; export import huxerui;`).
  - Upstream `mcpp.toml` declares `huxerui.huxerui = "0.5.5"` (`standard = "c++23"`), `defines` (`SQLITE_DEFAULT_FOREIGN_KEYS=1`, `SQLITE_DQS=0`, `SQLITE_OMIT_DEPRECATED`, `SQLITE_OMIT_LOAD_EXTENSION`, `SQLITE_THREADSAFE=1`), `cflags = ["-Wno-unused-function"]`, and `[target.'cfg(os = "ios")'.build] defines = ["HAVE_GETHOSTUUID=0"]`.
  - No inline `mcpp` build segment is declared in `pkgs/h/huxerui.sqlite.lua`, and no extra `xpm.<platform>.deps` closure is duplicated because transitive Linux GTK4 `xim` dependencies come through `pkgs/h/huxerui.huxerui.lua`.
- **Licenses**: `{"MIT", "LicenseRef-Public-Domain"}`
  - `Lib-SQLite-0.1.1/LICENSE` is the MIT License (`Copyright (c) 2026 HuxerUI`).
  - `third_party/sqlite/` vendors the SQLite `3.53.4` amalgamation (`sqlite3.c` / `sqlite3.h`), which `third_party/sqlite/README.md` documents as public domain (matching `LicenseRef-Public-Domain` in `pkgs/c/compat.sqlite3.lua`).
- **Archive & CN Mirror Status**:
  - `https://github.com/HuxerUI/Lib-SQLite/archive/refs/tags/v0.1.1.tar.gz` (`2,903,305` bytes), SHA256 verified twice: `e4c7a02ae508220a2ef324a0e7cb6830c2b5fb33fa9a5094a6bfabc6829ad8c7`.
  - Plain upstream GitHub URLs are used across `linux`, `macosx`, and `windows` (no local `gitcode.com/mcpp-res` credentials available; maintainers can add CN mirrors later).
- **Features**: None declared upstream.
- **Automatic Updates**: `extensions.autoupdate` tracks `HuxerUI/Lib-SQLite` with `tag = "v${version}"`.

## Workspace Test Member

- `tests/examples/huxerui-sqlite` (`[indices] huxerui = { path = "../../.." }`, `standard = "c++23"`, `huxerui.sqlite = "0.1.1"`):
  - Registered in root `mcpp.toml` right after `tests/examples/huxerui-interaction`.
  - `tests/examples/huxerui-sqlite/tests/sqlite.cpp` imports `std` and `huxerui.sqlite` headlessly via a `HeadlessPlatform` (`huxerui::UiWindow` + `huxerui::Runtime`) and `huxerui::TaskScope`, verifying `Database::OpenAsync`, `InsertAsync`, `InsertManyAsync`, `FindAsync`, typed `Select`/`Where`/`OrderBy`/`AllAsync`, `UpdateFieldsAsync`, parameterized `QueryAsync<std::string>`, `CloseAsync`, and post-close `ErrorCode::Closed` handling against a temporary database file.

## Verification

- Local verification in this isolated worktree (`mcpp 2026.11.23.1`, `Lua 5.4.8`, `gcc@16.2.0`):
  - Syntax check (`lua -e "assert(loadfile('pkgs/h/huxerui.sqlite.lua', 't'))"`), all 8 Lua descriptor lint scripts (`check_capability_providers.lua`, `check_mirror_urls.lua`, `check_package_name.lua`, `check_reserved_namespace.lua`, `check_mplugin_layout.lua`, `check_cross_package_refs.lua`, `check_platform_version_parity.lua`, `check_duplicate_versions.lua`), and `"$MCPP" xpkg parse pkgs/h/huxerui.sqlite.lua` (`form A`, `parse OK`).
  - `tests/select_members.py pkgs/h/huxerui.sqlite.lua` selects `huxerui-sqlite`.
  - Cold `bash tests/run_members.sh huxerui-sqlite` inside isolated `MCPP_HOME="$PWD/target/package-validation-home"` passed (`sqlite ... ok (0.01s)`, `test result ok. 1 passed; 0 failed; finished in 360.08s`), recording `huxerui.sqlite@0.1.1` and `huxerui.huxerui@0.5.5` in `mcpp.lock`.
  - `xpkgindex_update` `inspect --package huxerui:sqlite` and `check --package huxerui:sqlite` reported `"status": "up-to-date"`, `"current": "0.1.1"`.
