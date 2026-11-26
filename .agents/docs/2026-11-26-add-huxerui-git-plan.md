# Add `huxerui.git` (`0.1.0`)

## Summary

Add `huxerui.git` (`pkgs/h/huxerui.git.lua`) at upstream tag `v0.1.0` (`https://github.com/HuxerUI/Lib-Git`), unblocked after `compat.libgit2 1.9.7` (#914) merged.

## Package Shape

- **Form A** native `mcpp` package (`Lib-Git-0.1.0/mcpp.toml`, `build.mcpp` via `huxerui.rules`, `modules/git.cppm` exporting `huxerui.git`).
- Depends on `huxerui.huxerui = "0.5.5"` and `compat.libgit2 = "1.9.7"`.
- SHA256 verified twice: `4e49e70b5e3f88b87a3e3fe7505e79e340a8e968ad8ad827c549416a25889608`.

## Verification

- `mcpp xpkg parse pkgs/h/huxerui.git.lua`: `parse OK` (Form A).
- Cold validation `bash tests/run_members.sh huxerui-git` (fresh `MCPP_HOME`): `1 passed; 0 failed` (`293.64s`).
