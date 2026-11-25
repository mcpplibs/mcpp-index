# Add mcpplibs.mwrap.freetype (freetype-m 2.13.3)

## Form

- **Upstream:** [freetype/freetype](https://gitlab.freedesktop.org/freetype/freetype), tag `VER-2-13-3`. The tarball (`bc5c898e…c4103`) is the one compat.freetype 2.13.3 already pins.
- **Licence:** FreeType is dual-licensed. The package uses it under the FreeType License (FTL); the GPLv2 alternative is not elected.
- **Repository:** Form A external mwrap module repository [mcpplibs/freetype-m](https://github.com/mcpplibs/freetype-m), package `mcpplibs.mwrap.freetype`. The version is the upstream one (first release of the identity, no revision suffix), tag series `mwrap-${version}`.
- **Implementation ownership:** the library is compat.freetype's, and no implementation is linked twice. The wrapper vendors no upstream code. It retains upstream's README, the license selector `LICENSE.TXT`, `docs/FTL.TXT` and the BDF/PCF driver notices under `upstream/freetype/`, with checksums in `upstream/documents.json`. `runtime.deploy` places them, together with the wrapper's LICENSE and NOTICE, under `licenses/freetype/` at distinct paths.
- **Prerequisite (#589, #591):** compat.freetype now builds the rest of upstream's base extensions: the stroker, gasp, Type 1 / CID / BDF / PFR / WinFNT queries, fsType, the validation entry points and bzip2. Packaging revision 1 refreshes existing installs.

## Modules

- **`mcpplibs.mwrap.freetype`** exports, by `export using`, every function (218), type (231), struct/union/enum tag (126) and named-enum enumerator (209) of the public headers: `include/freetype/*.h` and `config/integer-types.h`.
  - `tools/gen_exports.py` generates the list from the pinned headers and normalises `FT_EXPORT( type )`.
  - The inventory matches a clang AST dump of the same headers.
  - **Left out, with reasons:**
    - `ftmac.h`: the Carbon API, built only under `FT_MACINTOSH`;
    - `ftchapters.h`: documentation only;
    - `fterrdef.h`: the X-macro list.
- **`mcpplibs.mwrap.freetype.macros`**, in `mcpplibs::mwrap::freetype::macros`, holds:
  - 1013 constants, each of its macro's type (generated partition `:constants`);
  - 22 type aliases;
  - the `FT_Err_*` / `FT_Mod_Err_*` codes as `FT_Error` constants (unnamed enums are TU-local);
  - 28 functions with the macros' semantics (`:functions`): `FT_HAS_*` / `FT_IS_*`, `FT_LOAD_TARGET_`, `FT_LOAD_TARGET_MODE`, `FT_MAKE_TAG`, `FT_CURVE_TAG` …
- **`<mwrap/freetype/macros.hpp>`** (the public headers) keeps the macros a constant or function cannot be:
  - the include names;
  - `FT_ENC_TAG` / `FT_IMAGE_TAG`;
  - token pasting;
  - the error-table X-macros;
  - `FT_UNUSED`;
  - the casts taking a type;
  - the `#ifdef` switches.

`tools/check_exports.py` fails on an unexported declaration, or on any of the 1274 macros that is neither mapped nor listed with its reason. It was negative-checked by removing an export and an `#undef`.

## Verification

Wrapper CI runs on four rows, all required: Linux GCC 16.1, Linux LLVM 23.1.3, macOS LLVM and Windows LLVM. It covers:

- **The build.**
- **The gtest suites:**
  - the API on JetBrains Mono (OFL) and on purpose-made TrueType/CFF fonts with `kern`, COLR v0/v1, CPAL, SVG, cmap 14 and vmtx. The fonts are reproduced byte for byte in CI.
  - The suites cover:
    - every render mode;
    - outlines, glyph objects, the stroker, bitmaps and synthesis;
    - COLR paint graphs and OT-SVG hooks;
    - the cache;
    - variable fonts, kerning and BDF;
    - gzip / LZW streams.
  - the macros at compile time;
  - the headers mixed with the import;
  - a generated test that names the whole surface through the import and takes every function's address.
- **The export audit.**
- **Conformance:** FreeType's own `tests/issue-1063` (on the font from upstream's `download-test-fonts.py`, digest-checked), `src/tools/test_trig.c` and `src/tools/test_bbox.c`, ported onto the module. The boxes are compared with exactly solved ones. Upstream's `src/tools/apinames.c`, compiled unchanged, lists 224 API names; all are exported except the six of `ftmac.h`.
- **The `ftdump` example** on the test fonts.

The templates job scaffolds the default `banner` template as an installed package, builds it with `--strict` and runs it.

Local checks, with the CI-pinned mcpp 2026.10.26.1:

- `bash tests/run_members.sh freetype-render` installs the real release archive through the candidate index. The consumer:
  - renders a BDF glyph parsed from memory;
  - checks test_bbox's exact cubic box [0 100 128 128];
  - strokes a square into a ring and rasterises it (64 covered pixels).

  Result: `test result ok`.
- `python3 tests/mwrap/check_installed_template.py --package mcpplibs.mwrap.freetype@2.13.3 --toolchain gcc@16.1.0 --deploy` (also run in CI with `--deploy`; its FreeType contract is added here) reports:
  - "Verified real indexed archive installation and unmodified template consumer";
  - "Verified 7 byte-identical wrapper/FreeType license files": `licenses/freetype/{LICENSE,NOTICE}` and `upstream/freetype/{README,LICENSE.TXT,docs/FTL.TXT,src/bdf/README,src/pcf/README}` in the relocated self-contained bundle;
  - "Verified relocated application bundle and byte-identical notices".

## Mirror and updates

This change has no `mcpp-res` access. The descriptor therefore uses the GitHub release URL as a plain string, and CN users fall back to it. A maintainer can add the GitCode mirror with identical bytes. `extensions.autoupdate` follows the repository's own `mwrap-${version}` tags.

## Motivation

openmui's text engine plans FreeType for glyph rasterisation (the architecture's raster row), beside HarfBuzz and FriBidi. Its native implementation units import `mcpplibs.mwrap.freetype` instead of including the headers.
