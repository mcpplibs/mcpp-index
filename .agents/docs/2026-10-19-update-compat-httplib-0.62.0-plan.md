# Update compat:httplib to 0.62.0

## Scope and source

- Upstream: <https://github.com/yhirose/cpp-httplib/releases/tag/v0.62.0>.
- Add `0.62.0` to Linux, macOS and Windows; retain the existing `0.53.1` entries.
- Keep the Form B header-only recipe unchanged: the archive still ships one
  `httplib.h` at its root (the leading `*` in `include_dirs` absorbs the
  `cpp-httplib-0.62.0/` wrapper), and the generated anchor TU still gives the
  package a lib target for consumers to link.
- Update the six example members (`httplib`, `httplib-tls`, `httplib-zlib`,
  `httplib-brotli`, `httplib-zstd`, `httplib-no-exceptions`) to `0.62.0`.
  Feature names and dependency shapes are unchanged.

## Archives and mirrors

The GitHub tag archive was downloaded twice and each copy hashed; both
downloads produced the same SHA-256:

| Version | SHA-256 |
| --- | --- |
| 0.62.0 | `7bba5949c56e772236432f69da03197fd4c12dc443455b9d81f6a05575431fc8` |

No GitCode configuration or token is available in this environment. The new
entries use plain upstream URLs, as allowed by `docs/cn-mirror.md`; the
existing 0.53.1 entries are untouched.

## Automatic updates

The descriptor declares `package.extensions.autoupdate` with the
`v${version}` tag template and the GitHub tag-archive URL, so future releases
are proposed by `openxlings/xpkgindex-update` without manual descriptor edits.
Since all three platforms use the same archive, the new version's URL and
SHA-256 live once in a leading `local versions` table and each platform
references `versions["0.62.0"]`, matching the updater's append-only layout.
The historical `0.53.1` entries remain byte-for-byte unchanged.

## Recipe and compatibility

- The upstream CMake `option(...)` set is byte-for-byte the same in 0.53.1 and
  0.62.0 (diffed the two files). There is no new build switch to encode in
  the descriptor.
- Upstream `target_link_libraries` is also unchanged: Threads on all
  platforms, `ws2_32`/`crypt32` on Windows, and
  CFNetwork/CoreFoundation/Security on Darwin. The descriptor already carries
  those in `linux`/`macosx`/`windows` `ldflags`.
- The header grew from 747,115 to 846,648 bytes. The additions (SSE client,
  WebSocket helpers, hardening) live entirely inside `httplib.h`: they add no
  defines, no extra sources and no link requirements, so the recipe needs no
  new feature entry.
- 0.62.0's own release note is a runtime fix: on Windows a pong timeout now
  also wakes a blocked `read()`, and `read()` returns `Fail` rather than
  `Timeout` for a connection that has closed. No descriptor impact.
- 0.62.0 upstream also understands wolfSSL and MbedTLS
  (`CPPHTTPLIB_WOLFSSL_SUPPORT` / `CPPHTTPLIB_MBEDTLS_SUPPORT`). This index
  has no `compat.wolfssl` or `compat.mbedtls`, so no feature is added; `tls`
  remains OpenSSL-only, exactly as before.
- Feature set unchanged: `tls`, `zlib`, `brotli`, `zstd`, `no-exceptions`.

## Validation

- `mcpp xpkg parse --all-os pkgs/c/compat.httplib.lua` -> `parse OK` for
  linux, macosx and windows with `0.62.0` and `0.53.1` resolved on each.
- Windows, local mcpp 2026.10.11.1 (CI pins 2026.10.1.2 in
  `.github/workflows/validate.yml`), LLVM 23.1.3 / MSVC 14.44.35207:
  - `mcpp test -p httplib` -> 1 passed; 0 failed.
  - `mcpp test -p httplib-zlib` -> 1 passed; 0 failed.
  - `mcpp test -p httplib-brotli` -> 1 passed; 0 failed.
  - `mcpp test -p httplib-no-exceptions` -> 1 passed; 0 failed.
  - `mcpp test -p httplib-tls` -> blocked before compiling `compat.httplib`:
    the `compat.openssl` 3.5.1 install hook on Windows needs a Perl with
    `Locale::Maketext::Simple` (upstream's Configure), and this host has no
    Perl at all. Environmental, not caused by this update; the mirror was
    forced to GLOBAL because `mirror = "auto"` otherwise hangs trying the CN
    source. CI decides this leg.
  - `mcpp test -p httplib-zstd` -> blocked before compiling `compat.httplib`:
    `compat.zstd` 1.5.7 unpacking fails on Windows because the upstream tag
    archive contains the symlink `tests/cli-tests/bin/unzstd -> zstd`, which
    xlings cannot materialise. The package and this member's dependency shape
    are unchanged by this update, so the failure is pre-existing and
    environmental; CI decides this leg.
- The Linux and macOS legs are left to CI.
