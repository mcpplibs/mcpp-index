# Add `huxerui.interaction` (`0.2.0`)

## Summary

Add `huxerui.interaction` (`pkgs/h/huxerui.interaction.lua`) at upstream release `v0.2.0` (`HuxerUI/Lib-Interaction@ff37a8a6`) as an independent single-package PR split from `#893`.

## Package Architecture

- **Form A (External Native C++23 Module Package)**:
  - Upstream tag archive carries its own `mcpp.toml`, `build.mcpp` (`huxerui.rules`), `modules/interaction.cppm`, and `modules/operators.cppm` (`export module huxerui.interaction;`), depending on `huxerui.huxerui = "0.5.5"` (`standard = "c++23"`).
  - No inline `mcpp` build segment is declared in `pkgs/h/huxerui.interaction.lua`, and no extra `xpm.<platform>.deps` closure is duplicated because transitive Linux GTK4 `xim` dependencies come through `pkgs/h/huxerui.huxerui.lua`.
- **License**: `MIT` (verified against `Lib-Interaction-0.2.0/LICENSE` and `Lib-Interaction-0.2.0/mcpp.toml`).
- **Archive & CN Mirror Status**:
  - `https://github.com/HuxerUI/Lib-Interaction/archive/refs/tags/v0.2.0.tar.gz` (`196,811` bytes), SHA256 verified twice: `9ffff3fa6e8bee09a97a766f84af5b4c7dd61f1db6d321d2256ddcc2b32d968d`.
  - Plain upstream GitHub URLs are used across `linux`, `macosx`, and `windows` (no local `gitcode.com/mcpp-res` credentials available; maintainers can add CN mirrors later).
- **Features**: None declared upstream.
- **Automatic Updates**: `extensions.autoupdate` tracks `HuxerUI/Lib-Interaction` with `tag = "v${version}"`.

## Workspace Test Member

- `tests/examples/huxerui-interaction` (`[indices] huxerui = { path = "../../.." }`, `standard = "c++23"`, `huxerui.interaction = "0.2.0"`):
  - Imports `std` and `huxerui.interaction` headlessly, verifying unbound controllers, pipeable `ViewAdaptor`s (`operator|` and `operator&` via `huxerui.interaction.operators`), and out-of-line `std::invalid_argument` validation paths.

## Verification

- Prior cross-platform CI evidence from combined PR `#893`: `huxerui-interaction` passed `validate / workspace (linux default 0/1)`, `validate / workspace (linux llvm)`, and `validate / workspace (windows default 0/1)` before splitting.
- Local verification in this clean split worktree (`mcpp 2026.11.23.1`, `gcc@16.2.0`): repo lints, `mcpp xpkg parse pkgs/h/huxerui.interaction.lua` (`form A`, `parse OK`), `tests/select_members.py --base upstream/main` (`huxerui-interaction`), `bash tests/run_members.sh huxerui-interaction`, and `xpkgindex-update` `audit`, `inspect`, and `check` (`up-to-date`, `0.2.0`).
