# Add `compat.oniguruma` (`6.9.10`)

## Summary

Add `compat.oniguruma` (`pkgs/c/compat.oniguruma.lua`) at upstream tag `v6.9.10` (`https://github.com/kkos/oniguruma`), required as a transitive dependency by `compat.sweetline` (`Lib-RichEditor`).

## Package Shape

- **Form B pure-C static library**:
  - Compiles Oniguruma core engine (`regcomp.c`, `regexec.c`, `regparse.c`, etc.) and built-in character encodings (`utf8.c`, `utf16_*`, `utf32_*`, `ascii.c`, `iso8859_*`, `sjis.c`, `euc_*`, `gb18030.c`, `big5.c`, etc.) matching upstream `CMakeLists.txt` `_SRCS`.
  - Exposes `*/src` (`<oniguruma.h>`, `<oniggnu.h>`) and keeps generated `mcpp_generated/config/config.h` private via `private_include_dirs` to prevent `config.h` header collisions in downstream consumers.
  - Propagates `ONIG_STATIC` via `default -> staticlib`, and keeps legacy GNU regex compat `src/reggnu.c` (`re_compile_pattern`, `re_match`, `re_search`) opt-in behind `gnu-api` to avoid colliding with glibc `libc.so.6`.
- **License**: `BSD-2-Clause` (`COPYING`), SHA256 verified twice: `ad92309d0d13eebc27f6592e875f3efbfa3dda2bf6da5952e00f0a2120c921a8`.

## Verification

- `mcpp xpkg parse pkgs/c/compat.oniguruma.lua`: `parse OK` (47 default sources, 3 features: `default`, `staticlib`, `gnu-api`).
- All CI Lua lints (`check_capability_providers.lua`, `check_mirror_urls.lua`, `check_package_name.lua`, `check_reserved_namespace.lua`, `check_mplugin_layout.lua`, `check_cross_package_refs.lua`, `check_platform_version_parity.lua`, `check_duplicate_versions.lua`, `check_quill_install.lua`) and Python tests (`test_check_mplugin.py` 12, `test_check_installed_template.py` 4, `test_check_capability_providers.py` 8, `test_select_members.py` 9, `test_plan_matrix_shards.py` 3): OK.
- `bash tests/run_members.sh oniguruma --cache local` (clean rebuild after cold home bootstrap): `1.71s` (`1 passed; 0 failed`), zero duplicate symbol warnings.
