# Add mcpplibs.mwrap.libjpeg_turbo (libjpeg-turbo-m 3.2.1)

## Form

- Third-party upstream [libjpeg-turbo/libjpeg-turbo](https://github.com/libjpeg-turbo/libjpeg-turbo), release 3.2.1,
  under the IJG License and the Modified (3-clause) BSD License (zlib License for parts; the in-tree libspng is BSD
  2-Clause).
- Form A external mwrap module repository [mcpplibs/libjpeg-turbo-m](https://github.com/mcpplibs/libjpeg-turbo-m),
  package `mcpplibs.mwrap.libjpeg_turbo`, version 3.2.1, tag `mwrap-3.2.1`; release asset
  `libjpeg-turbo-m-3.2.1.tar.gz` (`83cfc60f…e8ca`), CN mirror `gitcode.com/mcpp-res/mwrap-libjpeg-turbo` with identical
  bytes.
- Implementation ownership: the index has no JPEG package, so the wrapper vendors what upstream's TurboJPEG static
  library is built from (upstream's `TURBOJPEG_SOURCES`: the libjpeg and TurboJPEG sources, the 8/12/16-bit precision
  wrappers, the image-file readers and writers `tj3LoadImage*` and `tj3SaveImage*` use, the in-tree libspng; 188 files,
  checksums in `upstream/documents.json`) and builds them with three choices: no SIMD extensions (the x86 ones are
  NASM assembly; the C code gives the same results on the default path), libspng against `compat.zlib` instead of the
  in-tree zlib (upstream's `WITH_SYSTEM_ZLIB`), and floating-point contraction off. The three headers upstream's build
  configures (`jconfig.h`, `jconfigint.h`, `jversion.h`) are written out under `port/include` for GCC and Clang on the
  three platforms; that directory, with forwarding headers to the public ones, is the only include directory consumers
  see. It deploys upstream's README, LICENSE.md, README.ijg and libspng's license files with its own LICENSE/NOTICE
  (`runtime.deploy`).

## Module

- `mcpplibs.mwrap.libjpeg_turbo`: every name of `<turbojpeg.h>` — 7 enumerations, 68 enumerators, 4 types, 80
  functions (the TurboJPEG 3 API and the 2.x functions upstream still declares) — the upstream globals by `using`.
- Adaptation: a module cannot export a macro nor an internal-linkage constant, so the header's 43 constant macros, its 9
  `static const` tables and values (`tjPixelSize`, `tjRedOffset`, …, `TJUNSCALED`, `TJUNCROPPED`) and its 3 macros that
  take arguments (`tj3Init`, `TJSCALED`, `TJPAD`) are declared under their names, with the header's values, in
  `mcpplibs::mwrap::libjpeg_turbo`.
- The libjpeg API (`<jpeglib.h>`) is built and linked but not exported as a module: it is used through macros and
  `setjmp`. Its headers are on the include path.
- The export list is derived by `tools/surface.py` from the header and audited in CI (`tools/check_exports.py`).

## Verification

- Wrapper CI (Linux x86_64 GCC 16.1 and LLVM 23.1.3, macOS LLVM, Windows LLVM): upstream's `testorig.jpg` decodes to
  the MD5 upstream's regression test expects (`MD5_PPM_EXAMPLE_DECOMPRESS`, `dea1d7bb…6641`) on every row; a picture
  compressed, its bytes and its decoded pixels pinned by MD5 (the same on every row); a scaled decode into another
  pixel format; a quarter turn and back without decoding; refusal of what is no JPEG; the adapted constants against the
  header's; the export audit; the default template from an installed copy with a strict build.
- This index: consumer `tests/mwrap/libjpeg-turbo-decode`; the installed-template check with `--deploy`
  (`STATIC_NOTICES`).
