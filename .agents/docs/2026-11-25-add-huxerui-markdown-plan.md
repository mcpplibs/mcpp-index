# Add `huxerui.markdown` (`0.3.1`)

## Summary

Add `huxerui.markdown` (`pkgs/h/huxerui.markdown.lua`) at upstream release `v0.3.1` (`HuxerUI/Lib-Markdown@3a875ae0`) as an independent single-package PR split from `#893`.

## Package Architecture

- **Form A (External Native C++23 Module Package)**:
  - Upstream tag archive ships `mcpp.toml`, `build.mcpp` (`huxerui.rules`), vendored `md4c` (`c99`), `modules/markdown.cppm`, and `modules/macros.cppm` (`export module huxerui.markdown;`), depending on `huxerui.huxerui = "0.5.5"` (`standard = "c++23"`).
  - No inline `mcpp` build segment is declared in `pkgs/h/huxerui.markdown.lua`, and no extra `xpm.<platform>.deps` closure is duplicated because transitive Linux GTK4 `xim` dependencies come through `pkgs/h/huxerui.huxerui.lua`.
- **License**: `MIT` (verified against `Lib-Markdown-0.3.1/LICENSE` and `Lib-Markdown-0.3.1/mcpp.toml`).
- **Archive & CN Mirror Status**:
  - `https://github.com/HuxerUI/Lib-Markdown/archive/refs/tags/v0.3.1.tar.gz` (`171,647` bytes), SHA256 verified twice: `0e8be37f40b0377bec57e5354dc3dd1114544db92724eadbb027adf53e1a6f2a`.
  - Plain upstream GitHub URLs are used across `linux`, `macosx`, and `windows` (no local `gitcode.com/mcpp-res` credentials available; maintainers can add CN mirrors later).
- **Features**: None declared upstream.
- **Automatic Updates**: `extensions.autoupdate` tracks `HuxerUI/Lib-Markdown` with `tag = "v${version}"`.

## Workspace Test Member

- `tests/examples/huxerui-markdown` (`[indices] huxerui = { path = "../../.." }`, `standard = "c++23"`, `huxerui.markdown = "0.3.1"`):
  - Imports `std` and `huxerui.markdown` headlessly, verifying `macros::HUXERUI_MARKDOWN_SOURCE_MAPPING == 1`, GitHub-flavored AST + source range resolution, incremental parse sessions, streaming output, link policy, and `Markdown(doc)` view construction.

## Verification

- Prior cross-platform CI evidence from combined PR `#893`: `huxerui-markdown` passed `validate / workspace (linux default 0/1)`, `validate / workspace (linux llvm)`, and `validate / workspace (windows default 0/1)` before splitting.
- Local verification in this clean split worktree (`mcpp 2026.11.23.1`, `gcc@16.2.0`): repo lints, `mcpp xpkg parse pkgs/h/huxerui.markdown.lua` (`form A`, `parse OK`), `tests/select_members.py --base upstream/main` (`huxerui-markdown`), `bash tests/run_members.sh huxerui-markdown`, and `xpkgindex-update` `audit`, `inspect`, and `check` (`up-to-date`, `0.3.1`).
