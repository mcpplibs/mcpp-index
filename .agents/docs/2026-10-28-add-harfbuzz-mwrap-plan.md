# Add mcpplibs.mwrap.harfbuzz (harfbuzz-m 14.3.0)

## Form

- Third-party upstream [harfbuzz/harfbuzz](https://github.com/harfbuzz/harfbuzz), release 14.3.0, "Old MIT".
  The tarball (`566e996a…acea4a`) is the one compat.harfbuzz 14.3.0 already pins.
- Form A external mwrap module repository [mcpplibs/harfbuzz-m](https://github.com/mcpplibs/harfbuzz-m), package
  `mcpplibs.mwrap.harfbuzz`, version 14.3.0 (first release of the identity, no revision suffix), tag series
  `mwrap-${version}`.
- Implementation ownership: the library is compat.harfbuzz's (upstream's amalgamation `src/harfbuzz.cc` with the
  FreeType backend over compat.freetype 2.13.3). Its configuration lacked the `HAVE_FT_*` defines upstream's
  meson sets for FreeType, so hb-ft compiled out variation and transform support; #590 added them (packaging
  revision 1). The wrapper depends on compat.harfbuzz and compat.freetype directly (not on another wrapper) and
  vendors no upstream code. It retains upstream's README.md, COPYING and AUTHORS under `upstream/`, with
  checksums in `upstream/documents.json`, and deploys them with its own LICENSE/NOTICE (`runtime.deploy`).

## Modules

- `mcpplibs.mwrap.harfbuzz`: every type (142: typedef names and the struct/union tags), enumerator (805) and
  function (533, deprecated included) of `<hb.h>`, `<hb-ot.h>` and `<hb-aat.h>` by `export using`, generated
  from the pinned headers; the C++ helpers of `<hb-cplusplus.hh>` (`hb::shared_ptr`, `hb::unique_ptr`,
  `hb::vtable`, `hb::vtable_t`, `hb::is_shared_ptr`, `hb::is_unique_ptr`; `std::hash` for both pointers).
  Re-exports the two below.
- `mcpplibs.mwrap.harfbuzz.ft`: the 16 functions of `<hb-ft.h>`. FreeType's types stay FreeType's: `FT_Face`
  from `mcpplibs.mwrap.freetype` or `<ft2build.h>` is the same entity. No feature: compat.harfbuzz always builds
  hb-ft, so a feature would gate nothing.
- `mcpplibs.mwrap.harfbuzz.macros`: 64 macros: constants of each macro's type (`HB_OT_TAG_*`,
  `HB_LANGUAGE_INVALID`, `HB_FEATURE_GLOBAL_END`, `HB_VERSION_*` …), the initialisers
  `HB_SEGMENT_PROPERTIES_DEFAULT` / `HB_DRAW_STATE_DEFAULT`, constexpr functions converting their arguments as
  the macros cast them (`HB_TAG`, `HB_COLOR`, `HB_DIRECTION_IS_*`, `HB_BUFFER_CLUSTER_LEVEL_IS_*`,
  `HB_VERSION_ATLEAST`) and the deprecated aliases as `[[deprecated]]`. Five lowercase macros are macros over
  exported functions of the same names (`hb_color_get_*`, `hb_glyph_info_get_glyph_flags`).
- Stay macros, in `<mwrap/harfbuzz/macros.hpp>` (= `<hb.h>`, `<hb-ot.h>`, `<hb-aat.h>`): `HB_UNTAG` (four call
  arguments) and `HB_VERSION_ATLEAST` for `#if`. Not mapped: the declaration annotations, the umbrellas'
  `HB_*_H_IN`, `HB_DEFINE_VTABLE` and the include guards.
- Not wrapped, each with its reason in the repository: hb-subset*, hb-raster, hb-vector, hb-gpu, hb-cairo,
  hb-icu, hb-glib, hb-gobject*, hb-coretext, hb-directwrite, hb-gdi, hb-uniscribe, hb-graphite2, hb-fontations,
  hb-wasm-api (libraries and backends compat.harfbuzz does not build) and `hb_shape_justify`
  (`HB_EXPERIMENTAL_API` only).

`tools/check_exports.py` fails when the generated sources are stale, a declaration is not exported, a public
header is neither wrapped nor listed, or a macro is neither mapped nor listed. The inventory parser was
cross-checked against clang's AST of the same headers (549 functions, 142 types, 805 enumerators, identical).

## Verification

Wrapper CI (Linux GCC 16.1 and LLVM 23.1.3, macOS LLVM, Windows LLVM, all required): build, seven test programs
(shaping Latin, Arabic and Devanagari against an independent HarfBuzz build's output, buffers and
serialisation, faces/fonts/variations, draw and paint functions, OpenType/AAT/colour queries, hb-ft with
FreeType's variations, the C++ helpers, the macros, the side header beside the import), the export audit, and
HarfBuzz's own shaping suites: upstream's `test/shape/run-tests.py` with every `.tests` file `in-house`, `aots`
and `text-rendering-tests` list, on `examples/hb-shape` (upstream's `hb-shape` ported to the module), with the
`ot` and `ft` font functions: 7,549 pass (7,577 on macOS), none fail; absent macOS system fonts are skipped as
upstream skips them. The templates job scaffolds the default `shape` template as an installed package and runs
it.

Here, with the CI-pinned mcpp 2026.10.26.1 and `MCPP_INDEX_MIRROR=GLOBAL`:

- `bash tests/run_members.sh harfbuzz-shape`: the real release archive through the candidate index; a ligature
  and kern pairs of a font embedded in the test, the same with `-liga,-kern`, an outline through draw functions,
  the FreeType font functions and face loader, an `FT_Face` of `mcpplibs.mwrap.freetype` (#594) shaped through
  `hb_ft_font_create_referenced` (one type whichever module names it), the macros and `hb::unique_ptr`:
  `test result ok`.
- `python3 tests/mwrap/check_installed_template.py --package mcpplibs.mwrap.harfbuzz@14.3.0 --deploy`: the
  unmodified template from the real archive, then a relocated self-contained bundle whose `licenses/harfbuzz/`
  holds the wrapper's LICENSE/NOTICE and HarfBuzz's COPYING, AUTHORS and README byte for byte.

## Mirror and updates

No `mcpp-res` access in this change, so the descriptor uses the GitHub release URL as a plain string (CN users
fall back to it); a maintainer can add the GitCode mirror with identical bytes. `extensions.autoupdate`
follows the repository's own `mwrap-${version}` tags.

## Motivation

openmui's text engine (openmui.text) shapes with HarfBuzz; through this module its native units (fonts, glyph
outlines and colour layers, shaping) import the library instead of including C headers. Verified: those units
build and their tests pass with `import mcpplibs.mwrap.harfbuzz;` and
`using namespace mcpplibs::mwrap::harfbuzz::macros;` in place of the includes.
