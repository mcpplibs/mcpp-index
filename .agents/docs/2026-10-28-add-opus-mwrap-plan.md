# Add mcpplibs.mwrap.opus (opus-m 1.6.1)

## Form

- Third-party upstreams, all BSD-3-Clause: [libopus](https://opus-codec.org) 1.6.1, [opusfile](https://github.com/xiph/opusfile) 0.12
  and [libogg](https://github.com/xiph/ogg) 1.3.6, the release tarballs compat.opus, compat.opusfile and compat.ogg pin (the
  parent change).
- Form A external mwrap module repository [mcpplibs/opus-m](https://github.com/mcpplibs/opus-m), package `mcpplibs.mwrap.opus`,
  version 1.6.1 (libopus's version; the first release of the identity, no revision suffix; opusfile 0.12 and libogg 1.3.6 in
  `[package.metadata.mwrap]`), tag series `mwrap-${version}`, tagged on the merged main commit (`96fb761`); release asset
  `opus-m-1.6.1.tar.gz` (`b20d3991…8dd6`), CN mirror `gitcode.com/mcpp-res/mwrap-opus` with identical bytes.
- Implementation ownership: the libraries are compat.opus, compat.opusfile and compat.ogg (static libraries from the release
  tarballs; their configuration and ABI are sufficient). The wrapper vendors no library code. It retains each upstream's
  README and COPYING under `upstream/{opus,opusfile,ogg}/`, with checksums in `upstream/documents.json`, and deploys them with
  its own LICENSE/NOTICE (`runtime.deploy`). Its conformance example compiles libopus's `src/opus_compare.c`, unchanged and
  checked byte for byte against the tarball.

## Modules

- `mcpplibs.mwrap.opus`: libopus — 13 types and 87 functions of `<opus.h>`, `<opus_multistream.h>`, `<opus_projection.h>`
  (with `<opus_defines.h>` and `<opus_types.h>`), by `export using`; re-exports the three modules below.
- `mcpplibs.mwrap.opus.file`: opusfile — 10 types and 54 functions of `<opusfile.h>`. Not exported: libopusurl's 9
  declarations (HTTP over OpenSSL; compat.opusfile builds libopusfile only) and its 16 macros.
- `mcpplibs.mwrap.opus.ogg`: libogg — 12 types and 71 functions of `<ogg/ogg.h>` and `<ogg/os_types.h>`.
- `mcpplibs.mwrap.opus.macros`: 115 integer macros as `inline constexpr int`; the 6 type macros of `<opus_types.h>`
  (`opus_int`, `opus_uint`, and `opus_int8` / `opus_uint8` / `opus_int64` / `opus_uint64`, which the header leaves macros or
  replaces with `<stdint.h>` typedefs depending on the compiler) as type aliases; the 54 CTL macros as constexpr functions
  returning a `ctl_request` of the request and the arguments the macro's checks require, with a `ctl_request` overload of
  each of the 7 variadic `*_ctl` functions (found by argument-dependent lookup).
- Stay macros, in `<mwrap/opus/macros.hpp>` (`<stdint.h>`, then the headers, in the modules' order): attributes and keyword
  spellings (`OPUS_EXPORT`, `OPUS_WARN_UNUSED_RESULT`, `OPUS_ARG_NONNULL`, `OPUS_RESTRICT`, `OPUS_INLINE`, `OP_*`), the
  compiler-version tests, `OPUS_HAVE_OPUS_PROJECTION_H`, the 8 `opus_check_*` argument checks, libogg's `_ogg_*` allocator
  names. Not mapped: 8 include guards.

`tools/check_exports.py` fails when the generated sources are stale, a declaration is not exported, a macro is neither mapped
nor listed, or a variadic `*_ctl` function lacks its overload; every mapping is checked against the raw headers in a
header-mixing test, and every exported function's address is taken in a link test.

## Verification

Wrapper CI (Linux x86_64 GCC 16.1 and LLVM 23.1.3, Linux arm64 GCC 16.1, macOS LLVM, Windows LLVM, all required): build,
the five test programs, the export audit, and RFC 8251's decoder test vectors on `examples/opus` (programs written against
the module): 12 vectors × 5 output rates × mono/stereo = 120 decodes, the range decoder's final state checked against the
encoder's after every packet, each output passing libopus's own `opus_compare` against the reference (`.dec` or RFC 8251's
`m.dec`); 120 passed, 0 failed on every row. Then the Ogg Opus tool encodes, describes and decodes a 48 kHz stereo and a
16 kHz mono WAV, each decode exactly the input's length. The templates job scaffolds the default `tone` template as an
installed package and runs it. Until compat.opus is on this index's main, the wrapper's CI resolves the compat namespace
from the parent change's branch (`tools/candidate_index.py`, a no-op once published).

Here, with the CI-pinned mcpp 2026.10.26.1:

- `bash tests/run_members.sh opus-ogg`: the real release archive through the candidate index; a chord encoded through the
  typed CTL requests, paged with libogg, read back with opusfile from memory (headers, tags, the exact length, seeking),
  a 5.1 multistream encoder's per-stream state, and the side header beside the import: `test result ok`.
- `python3 tests/mwrap/check_installed_template.py --package mcpplibs.mwrap.opus@1.6.1 --deploy`: the unmodified template
  from the real archive (38.6 dB SNR, 96000 samples in and out), then a relocated self-contained bundle whose
  `licenses/opus/` holds the wrapper's LICENSE/NOTICE and the three libraries' READMEs and COPYINGs byte for byte.

## Motivation

openmui's coming audio engine (media.audio) decodes Opus; libopus, opusfile and libogg are BSD-3-Clause and link
statically under the project's licence policy.
