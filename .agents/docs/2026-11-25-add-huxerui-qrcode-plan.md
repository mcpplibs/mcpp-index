# Add `huxerui.qrcode` (`0.1.1`)

## Summary

Add `huxerui.qrcode` (`pkgs/h/huxerui.qrcode.lua`) at upstream release `v0.1.1` (`HuxerUI/Lib-QRCode@1ee15d9c`) as an independent single-package PR split from `#893`.

## Upstream `0.1.1` Fix for `libc++ 23`

- In combined PR `#893`, `huxerui.qrcode` `0.1.0` passed `linux default` and `windows default` but failed `validate / workspace (linux llvm 2/3)` because vendored `third_party/zxing/core/src/librscpp/poly.h:131` called `std::abs(trimDeg)` without `#include <cstdlib>` (the same `libc++ 23` header omission documented in `pkgs/c/compat.zxing-cpp.lua`).
- Fixed upstream in `HuxerUI/Lib-QRCode` commit `1ee15d9c` (tagged `v0.1.1`) by adding `#include <cstdlib>` directly to `third_party/zxing/core/src/librscpp/poly.h`.

## Package Architecture

- **Form A (External Native C++23 Module Package)**:
  - Upstream tag archive carries `mcpp.toml`, `build.mcpp` (`huxerui.rules` + `zxing/Version.h` generation), vendored ZXing 3.1.1 sources (`c99` for `libzueci.c`), and `modules/qrcode.cppm` (`export module huxerui.qrcode;`), depending on `huxerui.huxerui = "0.5.5"` (`standard = "c++23"`).
  - No inline `mcpp` build segment is declared in `pkgs/h/huxerui.qrcode.lua`, and no extra `xpm.<platform>.deps` closure is duplicated because transitive Linux GTK4 `xim` dependencies come through `pkgs/h/huxerui.huxerui.lua`.
- **License**: `MIT` (verified against `Lib-QRCode-0.1.1/LICENSE` and `Lib-QRCode-0.1.1/mcpp.toml`).
- **Archive & CN Mirror Status**:
  - `https://github.com/HuxerUI/Lib-QRCode/archive/refs/tags/v0.1.1.tar.gz` (`870,420` bytes), SHA256 verified twice: `14fb81089e30cdd7e782cf7e971c52ace42c2da201632665010989fe6d057692`.
  - Plain upstream GitHub URLs are used across `linux`, `macosx`, and `windows` (no local `gitcode.com/mcpp-res` credentials available; maintainers can add CN mirrors later).
- **Features**: None declared upstream.
- **Automatic Updates**: `extensions.autoupdate` tracks `HuxerUI/Lib-QRCode` with `tag = "v${version}"`.

## Workspace Test Member

- `tests/examples/huxerui-qrcode` (`[indices] huxerui = { path = "../../.." }`, `standard = "c++23"`, `huxerui.qrcode = "0.1.1"`):
  - Imports `std` and `huxerui.qrcode` headlessly, verifying `Encode`/`ToSvg`/`Rasterize`/`Decode`/`DecodeAll` round-trips across QR Code, Code128, DataMatrix, Aztec, and PDF417, declarative `QRCode`/`Barcode` views, and out-of-line `std::invalid_argument` exception paths.

## Verification

- Local verification in this clean split worktree (`mcpp 2026.11.23.1`, `gcc@16.2.0`):
  - Repo lints and `mcpp xpkg parse pkgs/h/huxerui.qrcode.lua` (`0.1.1`, `form A`, `parse OK`).
  - `tests/select_members.py --base upstream/main` (`huxerui-qrcode`).
  - `bash tests/run_members.sh huxerui-qrcode` downloading `v0.1.1.tar.gz`, passing `qrcode module_smoke: ok` (`1 passed; 0 failed`), and recording `huxerui.qrcode@0.1.1` + `huxerui.huxerui@0.5.5` in `mcpp.lock`.
  - `xpkgindex-update` `audit`, `inspect`, and authenticated `check` (`up-to-date`, `0.1.1`).
