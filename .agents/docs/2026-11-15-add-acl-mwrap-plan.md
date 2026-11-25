# Add mcpplibs.mwrap.acl (acl-m 2.1.0)

## Form

- Third-party upstreams [nfrechette/acl](https://github.com/nfrechette/acl), release v2.1.0, MIT, and the
  [nfrechette/rtm](https://github.com/nfrechette/rtm) v2.2.0 it pins (its submodule at that tag), MIT. Both are
  header-only.
- Form A external mwrap module repository [mcpplibs/acl-m](https://github.com/mcpplibs/acl-m), package
  `mcpplibs.mwrap.acl`, version 2.1.0 (the first indexed release of the identity), tag `mwrap-2.1.0`; release asset
  `acl-m-2.1.0.tar.gz` (`b974ddb9…11a4`), CN mirror `gitcode.com/mcpp-res/mwrap-acl` with identical bytes.
- Implementation ownership: this index has no `compat` package of ACL or RTM. The wrapper vendors the headers of both
  from their release archives (checksums of every file in `upstream/documents.json`), ACL's `io` directory included
  only because `acl/fwd.h` includes its forward declarations (it is not in the module). One upstream fix is applied
  (`patches/0001-move-deprecated-attribute.patch`, upstream commit 0b06bd1: an attribute clang 23 refuses where 2.1.0
  places it). It deploys both upstreams' README and LICENSE with its own LICENSE/NOTICE (`runtime.deploy`).
- Configuration: `RTM_NO_INTRINSICS` and `ACL_NO_INTRINSICS`, `-ffp-contract=off`, no fast math, in every profile.
  RTM's NEON paths fuse multiply and add and its SSE paths use approximate reciprocals, so a SIMD build gives other
  bits on other platforms; the scalar build gives the same compressed bytes and the same poses everywhere. Measured
  cost on x86-64 (GCC 16, `-O2`): 26.8 ns a joint to decompress a 64-joint pose, against 17.2 ns with SSE.

## Module

- `mcpplibs.mwrap.acl`: every name of the public headers under `acl/` (compression, decompression, core, math) and
  `rtm/`, in the namespaces upstream declares them in (`acl`, `rtm`, `rtm::constants`), by `export using` (197 types,
  454 functions). Implementation namespaces (`*_impl`) are not exported.
- Internal-linkage adaptation: 15 `constexpr` objects (`k_invalid_track_index`, `k_num_quality_tiers`,
  `k_highest_bit_rate`, `k_bit_rate_num_bits` …) are declared again under their names, with their types and values,
  in `mcpplibs::mwrap::acl`.
- No `.macros` module: neither library has macros a program spells.
- The export list is derived by `tools/surface.py` from the headers as clang reads them (its JSON AST), recorded in
  `tools/surface.json`, and audited in CI: the module is the record on every row, and on the Linux LLVM row the record
  is derived again and compared.

## Verification

- Wrapper CI (Linux x86_64 and arm64 with GCC 16.1 and LLVM 23.1.3, macOS LLVM, Windows LLVM, each in the dev and
  release profiles; wasm32-emscripten under node): a five-joint chain compressed twice to the same bytes, its error
  measured against the raw clip (below 0.15 mm for a precision of 0.1 mm at 3 cm), poses at five times; the
  compressed bytes and the poses pinned and the same on every row; the adapted constants; the export audit; the
  default template from an installed copy with a strict build.
- This index: consumer `tests/mwrap/acl-clip` (the same pinned hashes); the installed-template check with
  `--deploy` (`STATIC_NOTICES`).
