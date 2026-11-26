# Add `compat.utfcpp` (`nemtrif/utfcpp` v5.0.0)

## Summary

Add `compat.utfcpp` (`pkgs/c/compat.utfcpp.lua`) wrapping `nemtrif/utfcpp` release `5.0.0` (BSL-1.0) off `upstream/main`.

## Package Architecture

- **Upstream Archive**:
  - Uses stable GitHub tag release archive `https://github.com/nemtrif/utfcpp/archive/refs/tags/v5.0.0.tar.gz` across `linux`, `macosx`, and `windows` (plain string URL; CN mirrors can be added later).
  - SHA256 verified twice for stability: `42c36e1ef1307b1186996e4644f9999970e26325670b99019f3408bf0d3c952a`.
- **Header-Only Layout**:
  - `include_dirs = { "*/source" }`, anchor TU `mcpp_generated/utfcpp_anchor.c`, `license_files = { "*/LICENSE" }`, `targets = { ["utfcpp"] = { kind = "lib" } }`.
- **Automatic Updates**:
  - `extensions.autoupdate` tracks `nemtrif/utfcpp` with `tag = "v${version}"`.

## Workspace Test Member

- `tests/examples/utfcpp`: asserts `utf8::is_valid`, `utf8::distance`, `utf8::utf8to16`/`utf8::utf16to8` round-trip, `utf8::find_invalid`, and `utf8::replace_invalid`.
