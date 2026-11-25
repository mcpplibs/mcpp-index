# Add mcpplibs.mwrap.libwebp (libwebp-m 1.5.0)

## Form

- Third-party upstream [webmproject/libwebp](https://github.com/webmproject/libwebp), tag `v1.5.0`, BSD-3-Clause
  with Google's additional patent grant. The tarball (`668c9aba…7f37`) is the one compat.libwebp 1.5.0 pins.
- Form A external mwrap module repository [mcpplibs/libwebp-m](https://github.com/mcpplibs/libwebp-m), package
  `mcpplibs.mwrap.libwebp`, version 1.5.0 (first release of the identity, no revision suffix), tag series
  `mwrap-${version}` on the merged main commit (`0252b65`); release asset `libwebp-m-1.5.0.tar.gz` (`2a085e5e…f6a0`).
  No CN mirror yet (docs/cn-mirror.md fallback).
- Implementation ownership: the codec is compat.libwebp's (dec, enc, dsp, utils and sharpyuv in one archive; src/demux
  and src/mux with its `demux` and `mux` features; SSE2/NEON, SSE4.1 off, no `WEBP_USE_THREAD`). The wrapper vendors no
  upstream code. It retains upstream's README.md, COPYING, PATENTS and AUTHORS under `upstream/libwebp/`, with checksums
  in `upstream/documents.json`, and deploys them with its own LICENSE/NOTICE (`runtime.deploy`).

## Modules

- `mcpplibs.mwrap.libwebp`: by `export using`, generated from the pinned public headers (`webp/types.h`, `decode.h`,
  `encode.h`, `mux_types.h`): 23 types, 59 enumerators, 72 functions; re-exports `.sharpyuv` (6 types, 25 enumerators,
  6 functions) and `.macros`.
- `mcpplibs.mwrap.libwebp.demux` (`webp/demux.h`: 8 / 10 / 20) and `mcpplibs.mwrap.libwebp.mux` (`webp/mux.h`:
  7 / 17 / 27), with the `demux` and `mux` features (each adds its module's sources and forwards
  `compat.libwebp/<feature>`); each re-exports the root, as its header includes the root's. Each entity has one export
  owner.
- The 22 `static inline` functions (internal linkage) are adapted in `mcpplibs::mwrap::libwebp` under the same names
  and signatures (`[[nodiscard]]` where the header has `WEBP_NODISCARD`), defined out of line by calling upstream's body.
- `mcpplibs.mwrap.libwebp.macros`: 11 of the 24 macros (the ABI versions, `WEBP_MAX_DIMENSION`, sharpyuv's version as
  `inline constexpr int`; `WEBP_ABI_IS_INCOMPATIBLE` and `SHARPYUV_MAKE_VERSION` as constexpr functions); the rest are
  declaration annotations and include guards, excluded with reasons. No side header is needed.

`tools/check_exports.py` fails when a generated module is stale, a declaration is not exported or exported twice, a
static inline function is not adapted, or a macro is neither mapped nor excluded.

## Verification

Wrapper CI (Linux x86_64 GCC 16.1 and LLVM 23.1.3, Linux arm64 GCC 16.1, macOS LLVM, Windows LLVM, wasm32-emscripten
under node; dev and release profiles; default features and `demux`+`mux`): the API through the modules, the constants,
the headers beside the import, the animation tests, the export audit; FNV-1a hashes of lossy and lossless files, of
decoded pixels and of animations, the same on every row; and, but on Windows, `tools/run_conformance.py`:
`examples/webpcodec` (written against the module) against upstream's `cwebp`/`dwebp` 1.5.0 built by its makefile.unix,
76 comparisons, all byte-identical.

Here, with the CI-pinned mcpp 2026.10.27.1:

- `bash tests/run_members.sh libwebp-image`: the real release archive through the candidate index, with both features:
  lossy and lossless RGBA round trips with alpha, the advanced API with its pinned bytes, an animation encoded and
  played back frame by frame, the error paths.
- `python3 tests/mwrap/check_installed_template.py --package mcpplibs.mwrap.libwebp@1.5.0 --deploy`: the unmodified
  default `image` template from the real archive, then a relocated bundle whose `licenses/libwebp/` holds the wrapper's
  LICENSE/NOTICE and libwebp's README, COPYING, PATENTS and AUTHORS byte for byte.

## Motivation

openmui decodes and encodes images through C++ module imports (libpng so far); libwebp adds WebP with the same shape:
RGBA in and out from memory, lossy at a quality and lossless, alpha, animated WebP through WebPAnimEncoder and
WebPAnimDecoder, and the same bytes for the same input on every platform, the Web included.
