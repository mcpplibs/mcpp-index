# Add wolfSSL 5.9.4 as compat.wolfssl

## Source and shape

- Upstream: <https://github.com/wolfSSL/wolfssl>.
- Version: `5.9.4`, released as tag `v5.9.4-stable` on 2026-09-27; this is
  the newest release on the upstream releases page at the time of writing.
- License: GPLv3, with a GPLv2 exception for a listed set of upstream
  projects (`LICENSING` in the archive); a commercial license is available.
  The descriptor records `GPL-3.0-only`.
- Shape: Form B, C-source compat with a generated config header. wolfSSL's
  own build is autotools or CMake and both write `wolfssl/options.h` before
  compiling. An inline descriptor cannot run a configure step, so the two
  outputs of that step are carried literally:
  - `sources` is upstream CMake's default library list, transcribed from
    `generate_lib_src_list()` in `cmake/functions.cmake` with the default
    options. `src/ssl.c` represents `src/`: the `src/ssl_*.c`, `src/bio.c`,
    `src/x509*.c`, `src/pk*.c` and `src/conf.c` files in 5.9.4 are
    `#include`d by it. The same holds for
    `wolfcrypt/src/{evp,evp_pk,asn_tsp,asm,ecc_fp}.c`, which therefore are
    not separate translation units.
  - `generated_files` writes `mcpp_generated/wolfssl/options.h`, a snapshot
    of the header CMake generates with default options, with platform probes
    expressed as branches (`_WIN32`, `__linux__`, `__SIZEOF_INT128__`,
    x86_64/aarch64). Both the library and its consumers compile it because
    the descriptor defines `WOLFSSL_USE_OPTIONS_H` in `cflags` and in a
    default-implied feature (the `compat.curl` `CURL_STATICLIB` pattern).
- Default feature set: TLS 1.3 + 1.2, AES-GCM, ChaCha20-Poly1305, ECC,
  DH, RSA-PSS, SHA-2/SHA-3/SHAKE, ML-KEM; hardened defaults `NO_OLD_TLS`,
  `NO_DES3`, `NO_RC4`, `NO_MD5`, `NO_MD4`, `NO_DSA`, `NO_PSK`.
  Curve25519/Ed25519 and system CA-store loading are off in CMake's default
  configuration and stay off here.

## Automatic updates

`extensions.autoupdate` is declared with `tag = "v${version}-stable"` and
`url = "https://github.com/wolfSSL/wolfssl/archive/refs/tags/${tag}.tar.gz"`.
The suffix is upstream's actual release-tag shape. The recipe also pins
upstream's default source list and an options.h snapshot, so a release can
add or remove translation units or change CMake defaults; candidate CI is
what detects that, and the bump PR then needs a manual recipe update (the
"upgrades requiring recipe changes" case in `docs/automatic-updates.md`).

## Feature evaluation

No source-gated `features` are offered. CMake's optional components would
need different `options.h` values, and a feature's `defines` cannot be
depended on to rebuild the config header; adding one would silently produce
a library and consumers that disagree about its layout. TLS 1.3, which is a
define-only feature, is always on for the same reason.

## Download and mirror

- GLOBAL:
  `https://github.com/wolfSSL/wolfssl/archive/refs/tags/v5.9.4-stable.tar.gz`
- SHA-256:
  `7256bfc89b183a75183806c7debfa203443873b0b4a562e1b80d68e01b45ac57`
- The archive was hashed twice; both computations agree.
- No verified `mcpp-res/wolfssl` release is available (the gitcode probe
  returns 401), so the descriptor uses the repository's plain-string upstream
  URL fallback. A maintainer can add a byte-identical GitCode release later;
  the sha256 stays the same.

## Test member

`tests/examples/wolfssl/` is registered in the root workspace. It asserts:

- compile-time: the consumer inherited `WOLFSSL_TLS13`, `HAVE_AESGCM` and
  `HAVE_ECC` (a configuration mismatch fails at compile time, not on the
  wire);
- runtime: `wolfSSL_lib_version()`/`wolfSSL_lib_version_hex()` match the
  header; the SHA-256 known-answer vector for `"abc"`; an AES-256-GCM
  round trip and rejection of a modified tag; two distinct RNG blocks; and a
  P-256 key pair whose exported public key is the expected uncompressed
  65-byte point.

## Verification

- `mcpp xpkg parse --all-os pkgs/c/compat.wolfssl.lua` reports
  `parse OK` for linux, macosx and windows with 38 sources, 2 include dirs
  and 1 generated file.
- A stock CMake build of the same tag with the default options
  (`BUILD_SHARED_LIBS=OFF`, no examples/tests) compiles this exact source
  list, which is what the descriptor transcribes.
- Cold `mcpp test -p wolfssl` on Windows (mcpp 2026.10.17.1, LLVM
  toolchain, `MCPP_INDEX_MIRROR=GLOBAL`) reports
  `test result ok. 1 passed; 0 failed` (build 8.61 s + run 0.42 s); the
  package itself was downloaded and compiled cold in that run. Linux/macOS
  legs are left to CI.
