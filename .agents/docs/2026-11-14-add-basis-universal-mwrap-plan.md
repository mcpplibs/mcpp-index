# Add mcpplibs.mwrap.basis_universal (basis-universal-m 2.50)

## Form

- Third-party upstream [BinomialLLC/basis_universal](https://github.com/BinomialLLC/basis_universal), release v2_50,
  Apache-2.0 (the Zstandard decoder it ships beside the transcoder is BSD-licensed).
- Form A external mwrap module repository [mcpplibs/basis-universal-m](https://github.com/mcpplibs/basis-universal-m),
  package `mcpplibs.mwrap.basis_universal`, version 2.50, tag `mwrap-2.50`; release asset
  `basis-universal-m-2.50.tar.gz` (`eb114f20…8921`), CN mirror `gitcode.com/mcpp-res/mwrap-basis-universal` with
  identical bytes.
- Implementation ownership: the index has no KTX2 or Basis Universal package, so the wrapper vendors the transcoder
  (`transcoder/`: one source file with its headers and tables) and the Zstandard decoder upstream ships beside it
  (`zstd/zstddeclib.c`, `zstd.h`, `zstd_errors.h`) — 33 files, checksums in `upstream/documents.json` — and builds
  them as upstream's default build does (every format, KTX2, Zstandard), with one choice: floating-point contraction
  off. The encoder, the command line tool and the bindings are not vendored. It deploys upstream's README, LICENSE
  and NOTICE and Zstandard's LICENSE with its own LICENSE/NOTICE (`runtime.deploy`). No dependencies.

## Module

- `mcpplibs.mwrap.basis_universal`: every name `<transcoder/basisu_transcoder.h>` declares at namespace scope in
  `basist`, `basisu` and the namespaces inside them — 148 types, 273 functions, 70 objects, 112 enumerators of
  unscoped enumerations (603 names) — the upstream entities by `using`, in upstream's namespaces. The header brings
  upstream's internal header with it, so the tables and helpers are there as they are for a program that includes it.
- Adaptation: a module cannot export a name of internal linkage. The header's 139 scalar constants that are `const`
  and not `inline` are declared again, with their names, types and values, under
  `mcpplibs::mwrap::basis_universal::<their namespace>`. 11 names cannot be given again (five `static` functions, a
  constant table, five `const float`s that are no constant expressions) and are left to the header; a translation
  unit may include it beside the import (`tests/header_mix_test.cpp`).
- The export list is derived by `tools/surface.py` from the header as clang reads it (its JSON AST) and audited in CI
  (`tools/check_exports.py`; derived again on the Linux LLVM row).

## Verification

- Wrapper CI (Linux x86_64 GCC 16.1 and LLVM 23.1.3, macOS LLVM, Windows LLVM): upstream's own KTX2 test files —
  what each is (size, levels, codec, alpha); an ETC1S photograph as RGBA pixels and as BC7, ETC2 and ASTC blocks, each
  pinned by a hash that holds on every row; one XUASTC picture packed by Zstandard and by the arithmetic coder is one
  picture; noise, a file cut at four places and a changed identifier refused; header and module in one translation
  unit; the export audit; the default template from an installed copy with a strict build.
- This index: consumer `tests/mwrap/basis-universal-transcode` (the transcoder made ready, what it writes, block
  sizes, refusals, the adapted constants; it carries no texture file); the installed-template check with `--deploy`
  (`STATIC_NOTICES`).
