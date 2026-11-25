# Add compat.pdfium 8165

## Form and source

- Upstream: [PDFium](https://pdfium.googlesource.com/pdfium/) has no standalone source releases outside Chromium's GN / `depot_tools` build graph.
- Prebuilt SDK compat package (`pkgs/c/compat.pdfium.lua`): consumes the standalone C/C++ binaries published by [bblanchon/pdfium-binaries](https://github.com/bblanchon/pdfium-binaries) at release `chromium/8165` (`PDFium 160.0.8165.0`, V8/XFA disabled, `pdf_is_standalone = true`), version `"8165"`.
- Platform archives (verified sha256 twice, extracted flat at verdir root with `include/`, `lib/`, `bin/`, `LICENSE`, `licenses/`):
  - `linux`: `pdfium-linux-x64.tgz` (`ba7865e16c0271daab75256790be06c26272190afe6e2a70eae0bb39bb99089c`) — `lib/libpdfium.so` (SONAME `libpdfium.so`, links only `libpthread`, `libm`, `libgcc_s`, `libc`, `GLIBC_2.16` max, no `libstdc++`).
  - `macosx`: `pdfium-mac-arm64.tgz` (`112e74d717f3e0310273b70f3c8780e8a61ff11b34834124465c8305c841d350`) — `lib/libpdfium.dylib` (`@rpath/libpdfium.dylib`), consumer link adds `-Wl,-rpath,@loader_path`.
  - `windows`: `pdfium-win-x64.tgz` (`ca7338ae7779b8b1b82f4580305c4d762d214f8df1d54b47647fe3cc75989ded`) — `lib/pdfium.dll.lib` (`libraries = { "pdfium.dll" }`) and `bin/pdfium.dll` (`runtime_search_dirs = { "bin" }`).

## Headers, ABI anchor, and licenses

- `include_dirs = { "include", "include/cpp" }`.
- `generated_files["mcpp_generated/pdfium_anchor.c"]` provides a C11 anchor compiling `<stdlib.h>` + `<fpdfview.h>` and checking architecture (`x86_64` / macOS `arm64`) and C/C++ ABI (`__GLIBC__` on Linux, `_MSC_VER` on Windows). Note `<stdlib.h>` is required before `#if !defined(__GLIBC__)` because `fpdfview.h` only includes `<stddef.h>`.
- `license_files = { "LICENSE", "licenses/*" }` stages the wrapper MIT license and all bundled third-party notices (`licenses/pdfium.txt` and transitive component notices).

## Mirror and automatic updates

- No `mcpp-res` write credentials on this machine, so `xpm.<plat>.["8165"].url` uses the plain GitHub release URLs (`docs/zh/cn-mirror.md` fallback).
- `extensions.autoupdate` uses `tag = "chromium/${version}"` with per-platform `url` entries (`pdfium-linux-x64.tgz`, `pdfium-mac-arm64.tgz`, `pdfium-win-x64.tgz`).

## Local verification (mcpp `2026.11.18.1`, `MCPP_INDEX_MIRROR=GLOBAL`)

- `mcpp xpkg parse pkgs/c/compat.pdfium.lua`: `parse OK`.
- `bash tests/run_members.sh pdfium`: creates a new document and page via `FPDF_CreateNewDocument` / `FPDFPage_New`, saves to memory via `FPDF_SaveAsCopy`, reloads via `FPDF_LoadMemDocument`, renders via `FPDF_RenderPageBitmap`, and tears down cleanly (`compat.pdfium 8165 roundtrip test: ok (pdf=549 bytes, pages=1, 200x100)`).
- Relocated `mcpp build --strict` + `mcpp pack --mode self-contained --pkg-format dir`: bundles `lib/libpdfium.so` and `share/licenses/compat.pdfium/{LICENSE,licenses...}`, runs cleanly from a relocated copy in an isolated `env -i` environment (`ld-linux --list` resolves all shared libraries within the bundle).
- `xpkgindex_update`: `audit`, `inspect --package compat:pdfium`, and `check --package compat:pdfium` (`status = "up-to-date"`).
- macOS and Windows builds rely on CI native runners (untested locally on Linux).
