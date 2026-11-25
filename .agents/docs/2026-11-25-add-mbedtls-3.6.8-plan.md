# Add `compat.mbedtls` 3.6.8

## Background & Root Cause
`compat.mbedtls` 3.6.1 triggers a GCC 15/16 union zero-initialization bug in Mbed TLS `library/psa_crypto_mac.c` (`mbedtls_psa_mac_compute()`): `MBEDTLS_PSA_MAC_OPERATION_INIT` leaves union bytes inside `operation.ctx.hmac.hash_ctx` uninitialized on the stack, causing `psa_hash_setup()` to return `PSA_ERROR_BAD_STATE (-137)` and TLS 1.3 `ServerFinished` (`mbedtls_ssl_tls13_calculate_verify_data()`) to fail with `MBEDTLS_ERR_SSL_INTERNAL_ERROR (-0x6C00)`.

Upstream Mbed TLS 3.6.2+ fixed this with an explicit `memset(&operation, 0, sizeof(operation));` before calling `psa_mac_setup()`. Adding `3.6.8` (latest 3.6 LTS) resolves TLS 1.3 handshakes under GCC 16 while preserving existing `3.6.1` entries, mirrors, comments, and `library/*.c` Form B recipe (`109` C files including `psa_crypto_random.c`).

## Archive Verification & Mirror Policy
- Upstream release tag: `mbedtls-3.6.8`
- URL: `https://github.com/Mbed-TLS/mbedtls/archive/refs/tags/mbedtls-3.6.8.tar.gz` (plain GitHub string URL fallback since `mcpp-res` write access is not present; maintainers may convert to `{ GLOBAL = ..., CN = ... }` later with identical bytes)
- SHA256 (verified twice): `245c192db137c25224b02f72c06f77144d1f2f29823648a022e20fc159b45260`
- Top-level wrap directory: `mbedtls-mbedtls-3.6.8/`

## Autoupdate Policy
- Declares `extensions.autoupdate` with `tag = "mbedtls-${version}"` and `url = "https://github.com/Mbed-TLS/mbedtls/archive/refs/tags/${tag}.tar.gz"` to satisfy `tests/autoupdate/ci.py audit` for direct GitHub tag URLs.
- Note: Mbed TLS 4.x (`tf-psa-crypto`) changed source layout compared to the 3.6 LTS Form B `*/library/*.c` recipe; per `docs/automatic-updates.md`, future 4.x bot candidates will remain unmerged until adapted manually or pinned to the 3.x line.

## Verification
- Updated `tests/examples/core` to consume `compat.mbedtls = "3.6.8"` and added an RFC 4231 Test Case 2 (`psa_crypto_init()` + `psa_import_key()` + `psa_mac_compute()` + `psa_destroy_key()`) assertion in `tests/examples/core/tests/runtime.cpp` to prevent regression of the `PSA_ERROR_BAD_STATE` bug.
- Verified with pinned `mcpp 2026.11.23.1` (`mcpp xpkg parse`, `tests/run_members.sh core`, full repository lints, `ci.py audit`, `ci.py selection`, and `xpkgindex_update inspect`).
