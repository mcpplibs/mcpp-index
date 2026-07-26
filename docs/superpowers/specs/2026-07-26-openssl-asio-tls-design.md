# Add OpenSSL package + Asio SSL support

> Created: 2026-07-26 · Status: design
> Repo: `mcpplibs/mcpp-index` · Branch: `feat/add-openssl-asio-tls`

## 1. Motivation

The mcpp ecosystem needs TLS support. `chriskohlhoff.asio@1.38.1` (C++23
module wrapper) already ships Asio's full source tree but explicitly excludes
`asio/ssl/*.hpp` because SSL requires an external crypto library. This design
adds `compat.openssl` as a new static library package and extends
`chriskohlhoff.asio` with an opt-in `ssl` feature.

mbedTLS (`compat.mbedtls@3.6.1`) already exists in the index but **cannot**
serve as asio's SSL dependency: asio::ssl is hard-coded against the OpenSSL C
API (~95 distinct identifiers across SSL_CTX, SSL, BIO, ERR, X509, EVP, PEM,
DH, RSA, CRYPTO), and mbedTLS provides no OpenSSL compatibility layer
(its native API is entirely different: `mbedtls_ssl_*`, `mbedtls_x509_*`, etc.).

## 2. Scope

### In scope
- New package `compat.openssl@3.5.1` (latest LTS, supported to 2030-04-08)
- Opt-in `ssl` feature on `chriskohlhoff.asio@1.38.1`
- Consumer test for asio SSL (TCP echo over TLS)

### Out of scope
- TLS as an abstract capability (like `blas`) — deferred until a second TLS
  provider exists
- wolfSSL, BoringSSL, LibreSSL packages
- QUIC or TLS 1.3-only API exposure in the module wrapper
- Changes to `index.toml` or `min_mcpp` version
- Windows support (requires prebuilt MSVC binaries, not yet prepared)

## 3. Package: compat.openssl

### 3.1 Identity

| Field | Value |
|---|---|
| namespace | `compat` |
| name | `compat.openssl` |
| version | `3.5.1` |
| license | `Apache-2.0` |
| repo | `https://github.com/openssl/openssl` |
| type | Form B (inline, install()-driven build) |

### 3.2 Build strategy

OpenSSL's build system (Perl `Configure` + GNU Make) cannot be expressed as a
flat source glob. Follow the `compat.openblas` pattern: an `install()` Lua hook
drives the external build and emits an anchor `.c` TU whose absence triggers
mcpp to run `install()` before compilation.

```
install() flow:
  1. perl Configure no-shared no-dso no-tests no-apps no-engine
     --prefix=<prefix> --openssldir=<prefix>/ssl
  2. make -j$(nproc)
  3. make install_sw
  4. Emit mcpp_openssl_anchor.c
```

### 3.3 Platform strategy

| Platform | Approach | Notes |
|---|---|---|
| Linux | Source build via install() | Build dep `xim:make@latest`; system Perl expected at `/usr/bin/perl` |
| macOS | Source build via install() | Same as Linux; static libs only (`no-shared`) |
| Windows | Deferred | Prebuilt zip (follow `compat.openblas` precedent) requires preparing MSVC static builds for xlings-res; not in initial scope |

The `./config` convenience wrapper auto-detects the target platform (equivalent
to `perl Configure <auto-detected-target>`).

### 3.4 Build artifacts

| File | Content |
|---|---|
| `lib/libcrypto.a` | EVP, X509, ASN1, BIO, ERR, RSA, EC, SHA, AES, RAND, ... |
| `lib/libssl.a` | TLS/DTLS protocol (depends on libcrypto) |
| `include/openssl/*.h` | Public API headers |

### 3.5 Descriptor skeleton

```lua
package = {
    spec = "1", namespace = "compat", name = "compat.openssl",
    description = "OpenSSL — TLS/crypto library (static, install()-driven build)",
    licenses = {"Apache-2.0"},
    repo = "https://github.com/openssl/openssl",
    type = "package",
    xpm = {
        linux   = { deps = { "xim:make@latest" }, ["3.5.1"] = { url = {...}, sha256 = "529043b15cffa5f36077a4d0af83f3de399807181d607441d734196d889b641f" } },
        macosx  = { deps = { "xim:make@latest" }, ["3.5.1"] = { url = {...}, sha256 = "529043b15cffa5f36077a4d0af83f3de399807181d607441d734196d889b641f" } },
        -- windows deferred (prebuilt zip not yet prepared)
    },
    mcpp = {
        language = "c++23", import_std = false, c_standard = "c11",
        sources = { "mcpp_openssl_anchor.c" },
        targets = { ["openssl"] = { kind = "lib" } },
        include_dirs = { "include" },
        deps = {},
        linux   = { ldflags = { "-Llib", "-lssl", "-lcrypto" } },
        macosx  = { ldflags = { "-Llib", "-lssl", "-lcrypto" } },
    },
}
```

### 3.6 URL / mirror

Canonical upstream tarball:
- GLOBAL: `https://github.com/openssl/openssl/releases/download/openssl-3.5.1/openssl-3.5.1.tar.gz`
- CN: `https://gitcode.com/mcpp-res/openssl/releases/download/3.5.1/openssl-3.5.1.tar.gz`

Windows prebuilt zip — deferred (requires preparing MSVC static builds for xlings-res; not in initial scope).

## 4. Package: chriskohlhoff.asio (modified)

### 4.1 New feature: `ssl`

```lua
features = {
    ["default"] = { implies = { "separate-compilation" } },
    ["separate-compilation"] = { ... unchanged ... },
    ["ssl"] = {
        defines = { "MCPP_FEATURE_SSL" },
        deps    = { ["compat.openssl"] = "3.5.1" },
        sources = { "*/src/asio_ssl.cpp" },
    },
},
```

`ssl` is NOT in the `default` feature set. Consumers opt in explicitly:
```toml
[dependencies.chriskohlhoff]
asio = { version = "1.38.1", features = ["ssl"] }
```

When `ssl` is active:
- `MCPP_FEATURE_SSL` is defined (propagated to consumer TUs)
- `compat.openssl@3.5.1` is pulled in as a dependency
- `#ifdef MCPP_FEATURE_SSL` guards in `asio.cppm` activate SSL includes + exports

### 4.2 Feature-gated .cppm strategy

`generated_files` cannot be placed inside a feature block (xpkg features support
`sources`, `defines`, `flags`, `implies`, `deps`, `requires`, `provides` — not
`generated_files`). Instead, the single `.cppm` uses `#ifdef MCPP_FEATURE_SSL`
guards. When the `ssl` feature is disabled, the preprocessor strips the SSL
blocks and OpenSSL headers are never included. When enabled, `compat.openssl`
provides the headers and the guards activate.

### 4.3 Module wrapper additions (guarded by MCPP_FEATURE_SSL)

Added to `asio.cppm` after the existing includes:
```cpp
#ifdef MCPP_FEATURE_SSL
#include <asio/ssl.hpp>
#include <asio/ssl/context.hpp>
#include <asio/ssl/stream.hpp>
#include <asio/ssl/error.hpp>
#endif
```

Added to the export block:
```cpp
#ifdef MCPP_FEATURE_SSL
export namespace asio::ssl {
using ::asio::ssl::context;
using ::asio::ssl::context_base;
using ::asio::ssl::stream;
using ::asio::ssl::verify_mode;
using ::asio::ssl::verify_none;
using ::asio::ssl::verify_peer;
using ::asio::ssl::verify_fail_if_no_peer_cert;
using ::asio::ssl::rfc2818_verification;
using ::asio::ssl::host_name_verification;
}
#endif
```

## 5. Consumer test

New test file: `tests/examples/asio-module/tests/ssl.cpp`

Pattern: TCP echo over TLS — a `stream<ip::tcp::socket>` wrapped around a
plain socket. PEM cert+key embedded as C++ string literals, loaded via
`context::use_certificate(const_buffer, pem)` + `context::use_private_key(const_buffer, pem)`.

The test is feature-gated: only compiled when the `ssl` feature is active.
The existing `mcpp.toml` in `tests/examples/asio-module/` adds the `ssl`
feature to its dependency declaration.

## 6. Validation contract

Before PR:
1. `compat.openssl` descriptor passes local Lua lint
2. `compat.openssl` builds from source on macOS (GLOBAL mirror)
3. `chriskohlhoff.asio` with `ssl` feature resolves and builds
4. `mcpp test -p asio-module` passes all existing tests
5. New `ssl.cpp` test passes (TLS echo)
6. `git diff --check` clean

## 7. Implementation order

| Step | Description |
|---|---|
| 1 | Create `pkgs/c/compat.openssl.lua` |
| 2 | Local build test of `compat.openssl` |
| 3 | Modify `pkgs/c/chriskohlhoff.asio.lua` — add ssl feature |
| 4 | Add `tests/examples/asio-module/tests/ssl.cpp` |
| 5 | Update `tests/examples/asio-module/mcpp.toml` |
| 6 | Full `mcpp test -p asio-module` verification |

## 8. Future: TLS capability

When a second TLS provider exists (e.g., `compat.wolfssl`), extract an abstract
`tls` capability following the `blas` pattern:

```lua
-- compat.openssl
provides = { "tls" }

-- chriskohlhoff.asio ssl feature
["ssl"] = { requires = { "tls" }, deps = { ... } }
```

Consumers select via `[capabilities] tls = "compat.openssl"`. Not in scope now.
