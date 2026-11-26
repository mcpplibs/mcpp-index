# Add `compat.pugixml` (`zeux/pugixml` v1.16)

## Summary

Add `compat.pugixml` (`pkgs/c/compat.pugixml.lua`) wrapping `zeux/pugixml` release `1.16` (MIT license) off `upstream/main`.

## Package Architecture

- **Upstream Archive**:
  - Uses stable GitHub tag release archive `https://github.com/zeux/pugixml/archive/refs/tags/v1.16.tar.gz` across `linux`, `macosx`, and `windows` (plain string URL; CN mirrors can be added later).
  - SHA256 verified twice for stability: `357bcab8877dc9943f355d3a72daba1b053238ba955f50fa81586afb65090219`.
- **Source Build**:
  - `include_dirs = { "*/src" }`, `sources = { "*/src/pugixml.cpp" }`, `license_files = { "*/LICENSE.md" }`, `targets = { ["pugixml"] = { kind = "lib" } }`.
- **Automatic Updates**:
  - `extensions.autoupdate` tracks `zeux/pugixml` with `tag = "v${version}"`.

## Workspace Test Member

- `tests/examples/pugixml`: asserts `PUGIXML_VERSION == 1160`, DOM traversal, XPath query (`/catalog/book[@id='2']/title`), node mutation + serialization, and malformed XML rejection.
