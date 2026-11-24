# Add `huxerui.interaction`, `huxerui.markdown`, and `huxerui.qrcode`

## Summary

Add three Form A native C++23 module libraries from the `HuxerUI` ecosystem targeting `huxerui.huxerui` `0.5.5`:

| Package | Version | Upstream Tag | Module Interface | Descriptor |
| :--- | :--- | :--- | :--- | :--- |
| `huxerui.interaction` | `0.2.0` | `HuxerUI/Lib-Interaction@v0.2.0` (`ff37a8a6`) | `import huxerui.interaction;` | `pkgs/h/huxerui.interaction.lua` |
| `huxerui.markdown` | `0.3.1` | `HuxerUI/Lib-Markdown@v0.3.1` (`3a875ae0`) | `import huxerui.markdown;` | `pkgs/h/huxerui.markdown.lua` |
| `huxerui.qrcode` | `0.1.0` | `HuxerUI/Lib-QRCode@v0.1.0` (`696ff56b`) | `import huxerui.qrcode;` | `pkgs/h/huxerui.qrcode.lua` |

## Package Architecture

- **Form A (External Native Module Repositories)**:
  - Each upstream tag archive ships its own `mcpp.toml`, `build.mcpp` (`huxerui.rules`), and `modules/*.cppm`, so none of the three descriptors carries an inline `mcpp` build table:
    - `huxerui.interaction` (`0.2.0`): `modules/interaction.cppm` and `modules/operators.cppm` (gesture/press/hover/scroll/overlay/accessibility primitives and pipe/mask operators).
    - `huxerui.markdown` (`0.3.1`): `modules/markdown.cppm` and `modules/macros.cppm`, with vendored `md4c` (`c99`) parser sources and CommonMark/GFM declarative view components.
    - `huxerui.qrcode` (`0.1.0`): `modules/qrcode.cppm`, with `build.mcpp` generating `zxing/Version.h` and compiling vendored ZXing 3.1.1 (C++ and `c99` `libzueci`) encoder/decoder sources.
  - Each package declares `licenses = {"MIT"}`, matching `LICENSE` and `mcpp.toml` in its upstream tag archive.
  - All three upstream `mcpp.toml` manifests declare `[dependencies] huxerui.huxerui = "0.5.5"` (`standard = "c++23"`), so no extra `xpm.<platform>.deps` closures need to be duplicated in these descriptors; transitive Linux GTK4 `xim` dependencies come from `pkgs/h/huxerui.huxerui.lua`.
- **Upstream Archives & CN Mirror Status**:
  - Plain upstream GitHub tag archive URLs are declared across `linux`, `macosx`, and `windows` (local `gitcode.com/mcpp-res` credentials are unavailable; maintainers can populate `CN` mirrors later without altering versions):
    - `Lib-Interaction` `v0.2.0` (`196,811` bytes): `https://github.com/HuxerUI/Lib-Interaction/archive/refs/tags/v0.2.0.tar.gz` — SHA256 verified twice: `9ffff3fa6e8bee09a97a766f84af5b4c7dd61f1db6d321d2256ddcc2b32d968d`
    - `Lib-Markdown` `v0.3.1` (`171,647` bytes): `https://github.com/HuxerUI/Lib-Markdown/archive/refs/tags/v0.3.1.tar.gz` — SHA256 verified twice: `0e8be37f40b0377bec57e5354dc3dd1114544db92724eadbb027adf53e1a6f2a`
    - `Lib-QRCode` `v0.1.0` (`870,446` bytes): `https://github.com/HuxerUI/Lib-QRCode/archive/refs/tags/v0.1.0.tar.gz` — SHA256 verified twice: `8cee876321cdcaa44362342d1990036faf2bd57cea069d9e725f3563907f2d40`
- **Feature Evaluation**:
  - None of the three upstream manifests defines optional `[features]` or `[feature-deps.*]`. Each exposes its single default library/module target cleanly.
- **Automatic Updates**:
  - All three descriptors declare `extensions.autoupdate` with `tag = "v${version}"` and `url = "https://github.com/HuxerUI/<Repo>/archive/refs/tags/${tag}.tar.gz"`.

## Workspace Test Members

All three members use `[indices] huxerui = { path = "../../.." }` and `standard = "c++23"`, matching `tests/examples/huxerui-module` (`huxerui.huxerui = "0.5.5"`), and run headless C++23 module tests without opening a GUI window:

1. `tests/examples/huxerui-interaction` (`huxerui.interaction = "0.2.0"`):
   - Verifies unbound controllers, pipeable `ViewAdaptor`s (`operator|`, `operator&` via `huxerui.interaction.operators`), and out-of-line `std::invalid_argument` validation across subgroups.
2. `tests/examples/huxerui-markdown` (`huxerui.markdown = "0.3.1"`):
   - Verifies `macros::HUXERUI_MARKDOWN_SOURCE_MAPPING == 1` (`modules/macros.cppm`), GitHub-flavored AST + source range resolution, incremental parse sessions, streaming output, link policy, and `Markdown(doc)` view construction.
3. `tests/examples/huxerui-qrcode` (`huxerui.qrcode = "0.1.0"`):
   - Verifies `Encode`/`ToSvg`/`Rasterize`/`Decode`/`DecodeAll` round-trips across QR Code, Code128, DataMatrix, Aztec, and PDF417, declarative `QRCode`/`Barcode` views, and out-of-line `std::invalid_argument` exception paths.

## Local Verification (`mcpp 2026.11.23.1`, `gcc@16.2.0`)

- **Descriptor Lints & Parser**:
  - Passed `lua5.4` syntax checks (with a temporary `lua5.4 -> /usr/bin/lua` 5.4.8 symlink on `PATH`), `check_mirror_urls.lua`, `check_package_name.lua`, `check_reserved_namespace.lua`, `check_mplugin_layout.lua`, `check_capability_providers.lua`, `check_cross_package_refs.lua`, `check_platform_version_parity.lua`, `check_duplicate_versions.lua`, `check_quill_install.lua`, `tools/platform_rows.py check`, `test_check_mplugin.py` (12/12), `test_check_capability_providers.py` (8/8), `tests/openkal/compat.py selftest` (32/32), `tests/red_members.py selftest` (6/6), and `mcpp xpkg parse` across all `pkgs/*/*.lua` (all three new descriptors report `form A`, `parse OK`).
- **Selective Member Selection**:
  - `python3 tests/select_members.py --base upstream/main pkgs/h/huxerui.interaction.lua pkgs/h/huxerui.markdown.lua pkgs/h/huxerui.qrcode.lua` selected `huxerui-interaction huxerui-markdown huxerui-qrcode`.
- **Consumer Member Runs (`tests/run_members.sh`)**:
  - `huxerui-interaction`: `runtime ... ok (0.01s)`, `1 passed; 0 failed` (`42.85s` total; downloaded directly from `github.com` with `XLINGS_MIRROR_FALLBACK=off`, `XLINGS_ADAPTIVE_MIRROR=off`, `XLINGS_DOWNLOAD_CONNECT_TIMEOUT=5` to bypass stalled CN ghproxy/kkgithub endpoints).
  - `huxerui-markdown`: `module_smoke: ok`, `runtime ... ok (0.01s)`, `1 passed; 0 failed` (`33.27s` total).
  - `huxerui-qrcode`: `qrcode module_smoke: ok`, `runtime ... ok (0.06s)`, `1 passed; 0 failed` (`133.38s` total).
  - Workspace lockfile verified resolution of `huxerui.huxerui@0.5.5`, `huxerui.interaction@0.2.0`, `huxerui.markdown@0.3.1`, and `huxerui.qrcode@0.1.0`.
- **Autoupdate Verification (`openxlings/xpkgindex-update` @ `6c0bee29`)**:
  - `tests/autoupdate` unit tests (26/26 OK) and `test_mwrap_tag_selection.py` (4/4 OK).
  - `tests/autoupdate/ci.py audit --base upstream/main`: `115` updateable GitHub-direct descriptors declared, all existing versions preserved.
  - `xpkgindex_update inspect` and authenticated `check` verified `up-to-date` (`0.2.0`, `0.3.1`, `0.1.0`).
