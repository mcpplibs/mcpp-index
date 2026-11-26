# Add `compat.libgit2` (`1.9.7`)

## Summary

Add `compat.libgit2` (`pkgs/c/compat.libgit2.lua`) at upstream tag `v1.9.7` (`https://github.com/libgit2/libgit2`), required by `huxerui.git` (`Lib-Git`).

## Package Shape

- **Form B pure-C static library**:
  - Compiles libgit2 core (`*/src/libgit2/**/*.c`), util (`*/src/util/**/*.c`), bundled `llhttp`, `xdiff`, and PCRE2 (`deps/pcre2/*.c` with generated `config.h`), and SHA-1 CollisionDetect + builtin SHA-256.
  - Platform TLS backends: `compat.mbedtls = "3.6.8"` on Linux (`GIT_MBEDTLS`), Apple `SecureTransport` (`Security` + `CoreFoundation`) on macOS, and Windows `WinHTTP` (`winhttp` + `urlmon` + `secur32` + `crypt32` + `rpcrt4` + `ole32` + `ws2_32` + `advapi32`) on Windows.
  - Compression via `compat.zlib = "1.3.2"` across all three platforms.
- **License**: `GPL-2.0-only WITH GCC-exception-2.0` (`COPYING`), SHA256 verified twice: `1a4fbe7589e814777ae76b64734ad80f4ecad22cd33a22682a2aaea4ae5375e7`.

## Verification

- `mcpp xpkg parse pkgs/c/compat.libgit2.lua`: `parse OK` (`target git2`).
- All CI Lua 5.4 lints (`check_capability_providers`, `check_mirror_urls`, `check_package_name`, `check_reserved_namespace`, `check_mplugin_layout`, `check_cross_package_refs`, `check_platform_version_parity`, `check_duplicate_versions`, `check_quill_install`) and Python tests (`test_check_mplugin.py`, `test_check_installed_template.py`, `test_check_capability_providers.py`, `test_select_members.py`, `test_plan_matrix_shards.py`): passed.
- Cold validation (`bash tests/run_members.sh libgit2`, fresh `MCPP_HOME`, `MCPP_JOBS=3`, `MCPP_INDEX_MIRROR=GLOBAL`): `test result ok. 1 passed; 0 failed; finished in 57.45s (plan 47.49s · build 9.94s · run 0.02s)`, confirming `libgit2 version: 1.9.7`, `GIT_FEATURE_THREADS`, `GIT_FEATURE_HTTPS`, `GIT_FEATURE_COMPRESSION`, repository init/add/commit/lookup, and missing-repo failure.
