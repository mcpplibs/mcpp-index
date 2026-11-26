# Add `compat.utf8proc` (`2.10.0`)

## Summary

Add `compat.utf8proc` (`pkgs/c/compat.utf8proc.lua`) at upstream tag `v2.10.0` (`https://github.com/JuliaStrings/utf8proc`). Required by `huxerui.terminal` (`Lib-Terminal`) and general Unicode normalization / grapheme segmentation consumers.

## Package Shape

- **Form B pure-C static library**:
  - Compiles `*/utf8proc.c` (which includes `utf8proc_data.c`) with `c_standard = "c11"` and exposes `include_dirs = { "*" }` (`#include <utf8proc.h>`).
  - `utf8proc.h` marks public APIs `__declspec(dllimport)` on Windows unless `UTF8PROC_STATIC` is defined; `default` feature implies `staticlib` (`defines = { "UTF8PROC_STATIC" }`) so `UTF8PROC_STATIC` reaches every consumer automatically (matching `compat.curl` / `compat.libarchive` / `compat.thorvg`), while `cflags = { "-DUTF8PROC_STATIC" }` keeps package objects static-clean.
- **Licenses**: `MIT` + `Unicode-3.0` (`LICENSE.md`), matching upstream.
- **Archive & SHA256**: `https://github.com/JuliaStrings/utf8proc/archive/refs/tags/v2.10.0.tar.gz` (`199,045` bytes), SHA256 verified twice: `6f4f1b639daa6dca9f80bc5db1233e9cbaa31a67790887106160b33ef743f136`.
- **Automatic updates**: `extensions.autoupdate` tracks `v${version}`.

## Verification

- Workspace member `tests/examples/utf8proc` exercises `utf8proc_version()`, UTF-8 decode/encode (`utf8proc_iterate`, `utf8proc_encode_char`), display width (`utf8proc_charwidth`), NFC normalization (`utf8proc_NFC`), stateful grapheme segmentation (`utf8proc_grapheme_break_stateful`), and invalid UTF-8 negative error reporting.
- All 8 Lua 5.4 lint scripts passed; `mcpp xpkg parse pkgs/c/compat.utf8proc.lua` reported `parse OK` (`target utf8proc`, `features 2`); `unittest tests/test_select_members.py tests/test_plan_matrix_shards.py` ran 12 tests (`OK`).
- Cold validation (`bash tests/run_members.sh utf8proc` in isolated `target/package-validation-home` with `MCPP_INDEX_MIRROR=GLOBAL`): downloaded `compat.utf8proc v2.10.0`, compiled `utf8proc.c` + `utf8proc (test)`, ran `utf8proc_version: 2.10.0`, exited `test result ok. 1 passed; 0 failed; finished in 56.17s`.

