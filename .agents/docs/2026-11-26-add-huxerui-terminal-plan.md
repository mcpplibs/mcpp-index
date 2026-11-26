# Add `huxerui.terminal` (`0.1.0`)

## Summary

Add `huxerui.terminal` (`pkgs/h/huxerui.terminal.lua`) at upstream tag `v0.1.0` (`https://github.com/HuxerUI/Lib-Terminal`), unblocked after `compat.utf8proc 2.10.0` (#913) merged.

## Package Shape

- **Form A** native `mcpp` package (`Lib-Terminal-0.1.0/mcpp.toml`, `build.mcpp` via `huxerui.rules`, hand-maintained `modules/terminal.cppm` exporting `huxerui.terminal`).
- Depends on `huxerui.huxerui = "0.5.5"` and `compat.utf8proc = "2.10.0"`, with scrollback-patched `libvterm 0.3.3` subset in `third_party/libvterm`.
- SHA256 verified twice: `f9723074d6908ed33a510a0a060f5b98c40e390ad5388488aa4f8c830349a1e7`.

## Verification

- `mcpp xpkg parse pkgs/h/huxerui.terminal.lua`: `parse OK` (Form A).
- Cold validation `bash tests/run_members.sh huxerui-terminal` (fresh `MCPP_HOME`): `1 passed; 0 failed` (`263.16s`).
