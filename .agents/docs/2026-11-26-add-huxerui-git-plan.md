# Add `huxerui.git` (`0.1.1`)

## Summary

Add `huxerui.git` (`pkgs/h/huxerui.git.lua`) at upstream tag `v0.1.1` (`https://github.com/HuxerUI/Lib-Git`), unblocked after `compat.libgit2 1.9.7` (#914) merged (includes Windows `git_tree_entry_filemode` narrowing fix).

## Package Shape

- **Form A** native `mcpp` package (`Lib-Git-0.1.1/mcpp.toml`, `build.mcpp` via `huxerui.rules`, `modules/git.cppm` exporting `huxerui.git`).
- Depends on `huxerui.huxerui = "0.5.5"` and `compat.libgit2 = "1.9.7"`.
- SHA256 verified twice: `43eb826f58d61f6b6788b50615ef3278a4155e1fa4be7917cab55721d2c23778`.

## Verification

- `mcpp xpkg parse pkgs/h/huxerui.git.lua`: `parse OK` (Form A).
- Cold validation `bash tests/run_members.sh huxerui-git` (fresh `MCPP_HOME`): `1 passed; 0 failed` (`293.64s`).
