# Design doc: add `huxerui.pdf` (`0.2.1`)

Date: 2026-11-26

Adds `huxerui.pdf` (`0.2.1`) from `HuxerUI/Lib-PDF` as a Form A native `mcpp` C++23 module package in `mcpplibs/mcpp-index`.

## Source and shape

| | |
|---|---|
| Upstream | `https://github.com/HuxerUI/Lib-PDF` |
| Version | `0.2.1` (tag `v0.2.1`) |
| Tarball | `https://github.com/HuxerUI/Lib-PDF/archive/refs/tags/v0.2.1.tar.gz` |
| sha256 (checked twice, stable) | `075cf0a73e51ce722f9404255a3fdf9b95db64fae9ac1948cdf799f587ebcece` |
| Wrap dir | `Lib-PDF-0.2.1/` |
| Form | **Form A** (upstream ships `mcpp.toml`, `build.mcpp`, `modules/pdf.cppm`) |
| License | `MIT` |
| Dependencies | `huxerui.huxerui = "0.5.5"`, `compat.pdfium = "8165"` |
| CN mirror | pending (`mcpp-res` write access unavailable locally; plain-string GLOBAL URL) |
| Auto-update | `extensions.autoupdate` with `tag = "v${version}"` |

## Descriptor and workspace changes

- `pkgs/h/huxerui.pdf.lua`: Form A descriptor covering `linux`, `macosx`, and `windows` for version `0.2.1`.
- `tests/examples/huxerui-pdf/{mcpp.toml,tests/pdf.cpp}`: headless C++23 module consumer importing `huxerui` and `huxerui.pdf`, verifying `Version() == "0.2.1"`, loading/rendering/PNG export of a minimal PDF 1.4 document via `compat.pdfium 8165`, public header types, and `PdfException` (`PdfErrorCode::Format`) on malformed bytes.
- `mcpp.toml`: registered `"tests/examples/huxerui-pdf"` in `[workspace].members`.

## Local verification

- `mcpp xpkg parse pkgs/h/huxerui.pdf.lua` (`mcpp 2026.11.23.1`) -> `parse OK`.
- Lua `5.4.8` index lint checks (`check_mirror_urls`, `check_package_name`, `check_reserved_namespace`, `check_mplugin_layout`, `check_capability_providers`, `check_cross_package_refs`, `check_platform_version_parity`, `check_duplicate_versions`) — clean.
- `bash tests/run_members.sh huxerui-pdf` (Linux `x86_64`, `MCPP_INDEX_MIRROR=GLOBAL`) -> `test result ok`.
