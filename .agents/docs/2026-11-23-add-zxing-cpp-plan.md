# Add compat.zxing-cpp 3.1.1

## Form and source

- Upstream: [zxing-cpp/zxing-cpp](https://github.com/zxing-cpp/zxing-cpp), latest stable release tag `v3.1.1` (note `v3.2.0-rc1` is a prerelease), licenses `Apache-2.0` + `BSD-3-Clause` (bundled `libzint` and `libzueci`).
- Form A/B compat source package (`pkgs/c/compat.zxing-cpp.lua`): consumes the upstream release asset `https://github.com/zxing-cpp/zxing-cpp/releases/download/v3.1.1/zxing-cpp-3.1.1.tar.gz` (sha256 `c3c02c29c0b519de7bd4e25b376e606e87f0761befd1282815642a2246613d14`), which vendors `core/src/libzint/` inline (unlike the GitHub tag archive).
- Targets all three platforms (`linux`, `macosx`, `windows`) as static library `zxing-cpp` (`kind = "lib"`), compiling all 32 common C++ units, 48 decoder units (readers), `core/src/libzueci/zueci.c`, and all 28 `core/src/libzint/*.c` units (`109` sources total; excludes legacy `ZXING_WRITERS_OLD` units).

## Headers and flags

- Generated `mcpp_generated/Version.h` snapshots upstream `core/Version.h.in` for `3.1.1` (`ZXING_READERS`, `ZXING_WRITERS`, `ZXING_USE_ZINT`, `ZXING_ENABLE_* = 1`).
- Generated `mcpp_generated/ZXing/*.h` forwarding headers (17 public headers using `#include <...>`) allow consumers to include `<ZXing/ZXingCpp.h>` / `<ZXing/ZXingC.h>` without colliding with bare upstream includes.
- `*/core/src/libzint` is exposed in `include_dirs` + `private_include_dirs` per platform (`linux`, `macosx`, `windows`) so `libzint` headers remain private to `compat.zxing-cpp`.
- `license_files = { "*/LICENSE" }` stages upstream license notices.

## Mirror and automatic updates

- No `mcpp-res` write credentials on this machine, so `xpm.<plat>.["3.1.1"].url` uses the plain GitHub release asset URL string (`docs/zh/cn-mirror.md` fallback).
- `extensions.autoupdate` uses `tag = "v${version}"` and `url = "https://github.com/zxing-cpp/zxing-cpp/releases/download/${tag}/zxing-cpp-${version}.tar.gz"`.

## Local verification (mcpp `2026.11.18.1`, `MCPP_INDEX_MIRROR=GLOBAL`)

- `mcpp xpkg parse pkgs/c/compat.zxing-cpp.lua`: `parse OK` (`109` sources, `18` generated files).
- `bash tests/run_members.sh zxing-cpp`: builds and passes `tests/examples/zxing-cpp` (`compat.zxing-cpp 3.1.1 roundtrip test: ok (QR svg=2297 bytes, Code128=MCPP-311)`), verifying C++/C version APIs, QRCode creation/SVG/Image roundtrip, and 1D Code128 creation/decode roundtrip.
- `xpkgindex_update`: `audit`, `inspect --package compat:zxing-cpp`, and `check --package compat:zxing-cpp` (`status = "up-to-date"`).
- macOS and Windows builds rely on CI native runners (untested locally on Linux).
