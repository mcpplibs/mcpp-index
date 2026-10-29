# Add mcpplibs.mwrap.libvpx (libvpx-m 1.17.0)

## Form

- Third-party upstreams, both BSD-3-Clause with the WebM project's royalty-free patent grant: [libvpx](https://chromium.googlesource.com/webm/libvpx)
  1.17.0 (VP9) and [libwebm](https://github.com/webmproject/libwebm) 1.0.0.32 (the WebM container), the tag archives
  compat.libvpx and compat.libwebm pin (#624).
- Form A external mwrap module repository [mcpplibs/libvpx-m](https://github.com/mcpplibs/libvpx-m), package
  `mcpplibs.mwrap.libvpx`, version 1.17.0 (libvpx's version; the first release of the identity, no revision suffix; libwebm
  1.0.0.32 in `[package.metadata.mwrap]`), tag series `mwrap-${version}`, tagged on the merged main commit (`676fceb`);
  release asset `libvpx-m-1.17.0.tar.gz` (`e6a5a062…9211`). No CN mirror yet (docs/cn-mirror.md: CN users fall back to the
  GitHub release).
- The container is bundled with the codec as libogg is with libopus in opus-m: WebM is how VP9 travels, and libvpx's own
  tree carries libwebm for vpxenc/vpxdec.
- Implementation ownership: the libraries are compat.libvpx and compat.libwebm (static libraries from the tag archives).
  The wrapper vendors no library code. It retains each upstream's README, LICENSE, PATENTS and AUTHORS under
  `upstream/{libvpx,libwebm}/`, with checksums in `upstream/documents.json`, and deploys them with its own LICENSE/NOTICE
  (`runtime.deploy`).

## Modules

- `mcpplibs.mwrap.libvpx`: libvpx — 133 types, 192 enumerators, the 35 functions upstream exports (vpx/exports_* and vp9's
  lists) and the two VP9 interfaces, by `export using`. VP8 is not built (compat.libvpx: `--disable-vp8`): its interfaces,
  which vp8cx.h/vp8dx.h declare, are not exported. The headers' 86 typed controls (static functions made by
  `VPX_CTRL_USE_TYPE`) adapted under the same names in `mcpplibs::mwrap::libvpx`, each calling `vpx_codec_control_` as
  upstream's body does. Re-exports the two below.
- `mcpplibs.mwrap.libvpx.webm`: libwebm — the classes, types, enumerators and free functions of mkvmuxer (29/0/26),
  mkvparser (24/0/11) and libwebm (4/154/9) in their own namespaces; the namespace-scope constants (internal linkage) under
  the same names in `mcpplibs::mwrap::libvpx::mkvmuxer` / `::mkvparser`.
- `mcpplibs.mwrap.libvpx.macros`: 74 macros as `inline constexpr` of their expression's type, `vpx_codec_enc_init`,
  `vpx_codec_enc_init_multi`, `vpx_codec_dec_init`, `vpx_codec_version_major/_minor/_patch` as functions,
  `VPX_VERSION_MAJOR/_MINOR/_PATCH` as constexpr functions.
- Stay macros, in `<mwrap/libvpx/macros.hpp>`: `vpx_codec_control` (token concatenation), `VPX_CTRL_USE_TYPE*`,
  `VPX_CTRL_VOID`, the 86 empty `VPX_CTRL_<id>` feature tests, the declaration annotations, libwebm's
  `LIBWEBM_DISALLOW_COPY_AND_ASSIGN`, the include guards.

`tools/check_exports.py` fails when the generated sources are stale, a declaration is not exported, a control not adapted,
or a macro neither mapped nor accounted for; every mapping is checked against the raw headers in a header-mixing test,
and every exported function and control's address is taken in a link test.

## Verification

Wrapper CI (Linux x86_64 GCC 16.1 and LLVM 23.1.3, Linux arm64 GCC 16.1, macOS LLVM, Windows LLVM, wasm32-emscripten under
node; all required): build, the three test programs in the dev and release profiles — VP9 at good quality, real time, four
threads and lossless, muxed into WebM, parsed and decoded back, each file's FNV-1a pinned and the same on every row —, the
export audit, and the conformance run on Linux and macOS: `examples/vpxwebm`, written against the module, writes the same
IVF bytes as upstream's `vpxenc` (built from the same tag by its own configure) for six settings, and `vpxdec` reads its
WebM files to the same frames as the module reads `vpxenc`'s (18 comparisons). The templates job scaffolds the default
`webm` template as an installed package and runs it.

Here, with the CI-pinned mcpp 2026.10.27.1:

- `bash tests/run_members.sh libvpx-webm`: the real release archive; VP9 frames through the typed controls, muxed with
  mkvmuxer (track UID given: the same bytes twice), parsed with mkvparser and decoded (50.7 dB), and the side header
  beside the import: `test result ok`.
- `python3 tests/mwrap/check_installed_template.py --package mcpplibs.mwrap.libvpx@1.17.0 --deploy`: the unmodified
  template from the real archive (60 frames, 51.8 dB), then a relocated self-contained bundle whose `licenses/libvpx/`
  holds the wrapper's LICENSE/NOTICE and both libraries' README, LICENSE, PATENTS and AUTHORS byte for byte.

## Motivation

openmui's video component (openmui.video, D-86) encodes its frames and sound track into WebM: VP9 through this wrapper and
Opus through mcpplibs.mwrap.opus, both royalty-free and BSD-3-Clause, linked statically under the project's licence policy.
