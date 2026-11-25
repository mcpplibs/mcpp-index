# Add `compat.tinygltf` (`syoyo/tinygltf` v3.0.1 & v3.1.0)

## Summary

Add `compat.tinygltf` (`pkgs/c/compat.tinygltf.lua`) wrapping `syoyo/tinygltf` v3 at release versions `3.0.1` and `3.1.0` (MIT license) in its own branch off `upstream/main`.

## Package Architecture

- **Identity & Versioning**:
  - Adapted from a local `pf.tinygltf` (`3.0.1+pf.1`) draft to `compat.tinygltf` (`namespace = "compat"`, `name = "tinygltf"`) with bare upstream versions `"3.0.1"` and `"3.1.0"` so it follows `mcpp-index` conventions for third-party C/C++ compat packages and satisfies `xpkgindex-update` ordered-release checks.
- **Upstream Archive & Source Layout**:
  - Plain upstream GitHub tag archives (`https://github.com/syoyo/tinygltf/archive/refs/tags/v<ver>.tar.gz`) are used across `linux`, `macosx`, and `windows` (no local `gitcode` `mcpp-res` credentials available; CN mirrors can be added by maintainers later).
  - SHA256 verified twice for stability:
    - `3.0.1`: `b7e953f13a30d7b6fd677e484de35febde954143a265da15dacd92ed171c73e6`
    - `3.1.0`: `6e3043d1353d31daa4a06b17606bc9f4c46bf8f047bddffe1a63a6a79446182e`
  - Three-file archive root layout (`tiny_gltf_v3.h`, `tiny_gltf_v3.c`, `tinygltf_json_c.h`), built as C11 (`c_standard = "c11"`, `sources = { "*/tiny_gltf_v3.c" }`, `include_dirs = { "*" }`, `license_files = { "*/LICENSE" }`).
  - `windows.cflags = { "-D_CRT_SECURE_NO_WARNINGS" }` silences MSVC CRT deprecation warnings on `fopen`.
- **Feature Design**:
  - `features.default = { implies = { "fs" } }`
  - `features.fs = { defines = { "TINYGLTF3_ENABLE_FS" } }`
  - Enabled by default so `tg3_parse_file` and `tg3_write_to_file` use stdio out of the box, while consumers opting out via `default-features = false` compile without stdio filesystem helpers (`TINYGLTF3_ENABLE_FS` omitted).
- **Automatic Updates**:
  - `extensions.autoupdate` tracks `syoyo/tinygltf` releases with `tag = "v${version}"` and `url = "https://github.com/syoyo/tinygltf/archive/refs/tags/${tag}.tar.gz"`.

## Workspace Test Members

1. `tests/examples/tinygltf` (`compat.tinygltf = "3.1.0"`):
   - Compile-time check for `TG3_GLTF21_UNSTABLE` (confirms `3.1.0+` header resolution).
   - Verifies in-memory glTF 2.0 JSON parse (`tg3_parse`), decoded vertex float payload, binary GLB round-trip (`tg3_write_to_memory` + `tg3_parse_auto`), stdio file write/read (`tg3_write_to_file` + `tinygltf3::parse_file`), and out-of-range index validation (`TG3_ERR_INVALID_INDEX`).
2. `tests/examples/tinygltf-v301` (`compat.tinygltf = "3.0.1"`):
   - Compile-time check `#ifdef TG3_GLTF21_UNSTABLE #error ...` (confirms `3.0.1` header resolution).
   - Verifies in-memory glTF 2.0 parse, GLB round-trip, and stdio file write/read.
3. `tests/examples/tinygltf-nofs` (`compat.tinygltf = { version = "3.1.0", default-features = false }`):
   - Negative feature check: confirms in-memory `tg3_parse` succeeds while `tinygltf3::parse_file` without custom callbacks fails because `TINYGLTF3_ENABLE_FS` is not defined.

## Local Verification (`mcpp 2026.11.23.1`)

- Repo lints (`check_mirror_urls.lua`, `check_package_name.lua`, `check_reserved_namespace.lua`, `check_mplugin_layout.lua`, `check_cross_package_refs.lua`, `check_platform_version_parity.lua`, `check_duplicate_versions.lua`, `check_capability_providers.lua`, `check_quill_install.lua`, `tools/platform_rows.py check`, `test_check_mplugin.py`, `test_check_capability_providers.py`, `tests/openkal/compat.py selftest`, `tests/red_members.py selftest`) and `mcpp xpkg parse` across all descriptors passed (`compat.tinygltf`: `versions linux/macosx/windows 3.0.1, 3.1.0`, `features 2`, `parse OK`).
- Cold `MCPP_HOME` `tests/run_members.sh tinygltf tinygltf-v301 tinygltf-nofs` passed under both GCC (`gcc@16.2.0`) and LLVM (`llvm@23.1.6`).
- Verified `compile_commands.json` passes `-std=c11` and `-DTINYGLTF3_ENABLE_FS` for default consumers and omits `-DTINYGLTF3_ENABLE_FS` for `tinygltf-nofs`.
- `tests/select_members.py --base upstream/main pkgs/c/compat.tinygltf.lua` selected `tinygltf tinygltf-v301 tinygltf-nofs`.
- `xpkgindex_update` unit tests (26 + 4 passed), `tests/autoupdate/ci.py audit --base upstream/main` (`111` updateable descriptors), `inspect`, and `check --package compat:tinygltf` (`up-to-date`, `current: "3.1.0"`) all passed.
