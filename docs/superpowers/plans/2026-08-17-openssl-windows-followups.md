# OpenSSL Windows Follow-ups Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make the existing Asio SSL and libmysqlclient consumer tests execute on Windows with real OpenSSL-backed builds, using the repaired `libmysqlclient@8.4.6` source tag and preserving Unix behavior.

**Architecture:** The Asio descriptor already has a Windows archive and an `ssl` feature that depends on `compat.openssl`; only its consumer member is incorrectly Unix-gated. The repaired libmysqlclient `8.4.6` Form A archive contains the Windows build recipe and vendors OpenSSL 3.5.1's `ms/applink.c` at the include path expected by its Windows configuration. The index publishes that single effective version under `xpm.windows` and enables the current behavior test. Connector/C++ and gRPC remain outside this plan.

**Tech Stack:** Lua xpkg descriptors, mcpp workspace manifests, C++23 consumer tests, Lua repository lints, mcpp `2026.8.10.3`, GitHub Actions Windows x64 with MSVC ABI and LLVM consumer toolchain.

---

## File Map

| File | Responsibility in this plan |
| --- | --- |
| `tests/examples/asio-ssl/mcpp.toml` | Resolve the Asio `ssl` feature and set the consumer assertion flag on all declared platforms. |
| `tests/examples/asio-ssl/tests/ssl.cpp` | Run the TLS loopback handshake; fail compilation if the feature gate is accidentally absent instead of compiling a no-op. |
| `pkgs/c/compat.libmysqlclient.lua` | Publish the repaired `8.4.6` Form A archive for Windows. |
| `tests/examples/libmysqlclient/mcpp.toml` | Resolve `libmysqlclient@8.4.6` and set the consumer assertion flag on Windows. |
| `tests/examples/libmysqlclient/tests/client.cpp` | Assert the client ABI and usable `mysql_init` handle; fail compilation if the dependency gate is absent. |
| `tests/member-timings.tsv` | Do not edit before measured Windows CI output exists; update only if the live timing workflow produces a materially different ranking. |

## Task 1: Enable the real Asio SSL Windows test

**Files:**
- Modify: `tests/examples/asio-ssl/mcpp.toml`
- Modify: `tests/examples/asio-ssl/tests/ssl.cpp`

- [x] **Step 1: Make the test fail loudly when the feature is not wired.**

Keep the existing `#ifdef HAVE_ASIO_SSL` body and replace the no-op fallback at
the end of `tests/examples/asio-ssl/tests/ssl.cpp` with a compile-time failure:

```cpp
#else
#error "HAVE_ASIO_SSL must be enabled for every declared asio-ssl test platform"
#endif
```

Update the file comments to remove the claim that Windows has no OpenSSL
dependency and explain in Chinese that the macro is owned by this consumer:

```cpp
// HAVE_ASIO_SSL 由本测试成员自己的构建配置定义；所有已声明平台都必须运行真实 TLS 测试。
```

Run the focused source check:

```bash
rg -n "no-op|no openssl dep|HAVE_ASIO_SSL must|HAVE_ASIO_SSL" tests/examples/asio-ssl/tests/ssl.cpp tests/examples/asio-ssl/mcpp.toml
```

Expected: the stale Windows/no-op wording is absent, the consumer-owned macro
comment is present, and the `#error` fallback is present.

- [x] **Step 2: Add the Windows dependency and consumer flag.**

Append the Windows sections to `tests/examples/asio-ssl/mcpp.toml`, matching the
Linux and macOS dependency and build flag exactly:

```toml
[target.'cfg(windows)'.dependencies.chriskohlhoff]
asio = { version = "1.38.1", features = ["ssl"] }

[target.'cfg(windows)'.build]
cxxflags = ["-DHAVE_ASIO_SSL=1"]
```

Update the preceding platform comment so it says Linux, macOS, and Windows all
run the real TLS test. Do not add a second `[indices]` table: this member must
continue inheriting the root `compat` path while resolving Asio remotely.

- [x] **Step 3: Run the Asio static and Unix regression checks.**

Run the exact checks that can be proved on the current host:

```bash
git diff --check
MCPP_HOME="$(mktemp -d)" MCPP_BUILD_CACHE=local MCPP_INDEX_MIRROR=GLOBAL mcpp test -p asio-ssl
```

`mcpp test` is the parser for the TOML manifest; do not pass the TOML file to
Lua's `loadfile`. Expected: the manifest parses, the diff is clean, and the
macOS/Linux-host test executes the existing TLS handshake and exits
successfully. Record that this does not prove Windows ABI behavior.

- [x] **Step 4: Commit the Asio change independently.**

```bash
git add tests/examples/asio-ssl/mcpp.toml tests/examples/asio-ssl/tests/ssl.cpp
git commit -m "test(asio-ssl): exercise Windows TLS support"
```

## Task 2: Publish libmysqlclient for Windows and run its real test

**Files:**
- Modify: `pkgs/c/compat.libmysqlclient.lua`
- Modify: `tests/examples/libmysqlclient/mcpp.toml`
- Modify: `tests/examples/libmysqlclient/tests/client.cpp`

- [x] **Step 1: Make the consumer test fail loudly when its dependency gate is absent.**

Replace the no-op fallback in `tests/examples/libmysqlclient/tests/client.cpp`
with:

```cpp
#else
#error "HAVE_LIBMYSQLCLIENT must be enabled for every declared libmysqlclient test platform"
#endif
```

Add a concise Chinese comment above the assertion block explaining that the
test checks both the published client ABI and a usable runtime handle. Keep
the existing `MYSQL_VERSION_ID == 80406`, `mysql_get_client_version()`, and
`mysql_init` assertions unchanged.

Run:

```bash
rg -n "no-op|HAVE_LIBMYSQLCLIENT must|MYSQL_VERSION_ID|mysql_init" tests/examples/libmysqlclient/tests/client.cpp
```

Expected: no no-op fallback remains and all three runtime assertions are still
present.

- [x] **Step 2: Publish the repaired `8.4.6` source in `xpm.windows`.**

Add the repaired archive to the Windows block in
`pkgs/c/compat.libmysqlclient.lua`:

```lua
        windows = {
            ["8.4.6"] = {
                url = "https://github.com/wellwei/libmysqlclient/archive/refs/tags/8.4.6.tar.gz",
                sha256 = "0c2d4b1b25d828bc40f760c50f7d49a3b6377073ac352ed5a52c2de45c7a2cad",
            },
        },
```

The SHA is taken from the current `8.4.6` tag, which resolves to source commit
`52a26090e360817850dd41e88056c98599fda6b7`. The superseded `8.4.6.1` tag is
retired rather than retained as a second package revision.

- [x] **Step 3: Enable the Windows consumer dependency.**

Append to `tests/examples/libmysqlclient/mcpp.toml`:

```toml
# Windows 也必须执行真实客户端 ABI 和运行时句柄断言。
[target.'cfg(windows)'.dependencies.compat]
libmysqlclient = "8.4.6"

[target.'cfg(windows)'.build]
cxxflags = ["-DHAVE_LIBMYSQLCLIENT=1"]
```

Update the platform comment from Linux/macOS-only to Linux/macOS/Windows.
Do not modify the archive's embedded Form A manifest in this task; it is the
source of the Windows compile and link recipe.

- [x] **Step 4: Run descriptor and parity checks before building.**

```bash
LUA_BIN="$(command -v lua5.4 || command -v lua5.5 || command -v lua)"
"$LUA_BIN" -e "assert(loadfile('pkgs/c/compat.libmysqlclient.lua', 't'))"
"$LUA_BIN" tests/check_mirror_urls.lua pkgs/c/compat.libmysqlclient.lua
"$LUA_BIN" tests/check_package_name.lua pkgs/c/compat.libmysqlclient.lua
"$LUA_BIN" tests/check_platform_version_parity.lua pkgs/c/compat.libmysqlclient.lua
git diff --check
```

Expected: all commands exit 0. The parity check must see the repaired `8.4.6`
entry in Linux, macOS, and Windows.

- [x] **Step 5: Parse the changed descriptor with the workflow-pinned client.**

Use the same release pin as `.github/workflows/validate.yml`:

```bash
MCPP_VERSION=2026.8.10.3
case "$(uname -s)" in
  Darwin) MCPP_ARCHIVE="mcpp-${MCPP_VERSION}-macosx-arm64.tar.gz"; MCPP_ROOT="mcpp-${MCPP_VERSION}-macosx-arm64" ;;
  Linux) MCPP_ARCHIVE="mcpp-${MCPP_VERSION}-linux-x86_64.tar.gz"; MCPP_ROOT="mcpp-${MCPP_VERSION}-linux-x86_64" ;;
  *) echo "Use the matching workflow asset for this host before running xpkg parse" >&2; exit 2 ;;
esac
curl -L -fsS -o "$MCPP_ARCHIVE" "https://github.com/mcpp-community/mcpp/releases/download/v${MCPP_VERSION}/${MCPP_ARCHIVE}"
tar -xzf "$MCPP_ARCHIVE"
"$PWD/$MCPP_ROOT/bin/mcpp" xpkg parse pkgs/c/compat.libmysqlclient.lua
```

Expected: `xpkg parse` exits 0 using `2026.8.10.3`, independent of the newer
developer-installed mcpp on the host.

- [x] **Step 6: Run the libmysqlclient Unix regression test from a cold cache.**

```bash
MCPP_HOME="$(mktemp -d)" MCPP_BUILD_CACHE=local MCPP_INDEX_MIRROR=GLOBAL mcpp test -p libmysqlclient
```

Expected: the test compiles against `mysql.h`, observes client version `80406`,
obtains a non-null `MYSQL*`, calls `mysql_close`, and exits 0. Record any
OpenSSL/system-library failure separately from an index resolution failure.

- [x] **Step 7: Commit the libmysqlclient change independently.**

```bash
git add pkgs/c/compat.libmysqlclient.lua tests/examples/libmysqlclient/mcpp.toml tests/examples/libmysqlclient/tests/client.cpp
git commit -m "feat(libmysqlclient): publish Windows package entries"
```

## Task 3: Cross-platform validation and handoff

- [x] **Step 1: Run the repository-wide cheap checks.**

```bash
LUA_BIN="$(command -v lua5.4 || command -v lua5.5 || command -v lua)"
"$LUA_BIN" tests/check_cross_package_refs.lua pkgs/*/*.lua
"$LUA_BIN" tests/check_platform_version_parity.lua pkgs/*/*.lua
git diff --check
git status --short --branch
```

Expected: cross-package references and platform parity exit 0; the working tree
contains only the two feature commits (or later verification-only artifacts
that are ignored by Git).

- [x] **Step 2: Verify the affected members are registered.**

```bash
rg -n 'tests/examples/(asio-ssl|libmysqlclient)' mcpp.toml
```

Expected: both members remain listed exactly once in the root workspace.

- [ ] **Step 3: Obtain Windows CI evidence before claiming completion.**

The Windows workflow must show, for both `asio-ssl` and `libmysqlclient`, a
real package resolution, OpenSSL-backed compile/link, and a test executable
that returns success. A green selector or a member that only compiles the new
`#error`-guarded fallback is insufficient. Do not edit `tests/member-timings.tsv`
unless the workflow's measured artifact proves a material ranking change.

Current status: pending an authorized push or pull request run. Local macOS
tests and Linux/macOS descriptor checks cannot prove the Windows ABI.

- [x] **Step 4: Record the final boundary.**

Document the exact commands, client version, observed assertions, and Windows
CI job URL in the task handoff. State explicitly that Connector/C++ Windows
hook design and gRPC remain deferred.

### Local Wine evidence (2026-08-17)

- The authoritative mcpp release was queried from `xlings-res/mcpp` with
  `gh api repos/xlings-res/mcpp/releases/tags/2026.8.17.1`: tag
  `2026.8.17.1`, published `2026-08-16T22:02:47Z`. The downloaded Windows
  asset `mcpp-2026.8.17.1-windows-x86_64.zip` matched both the GitHub asset
  digest and its `.sha256` file:
  `35520f09b4c87d855711e172390ea0ecd0a7fd58c739e9a17d329d0fb6335c08`.
- Under Wine `11.14`, the Windows binary reported `mcpp 2026.8.17.1` and,
  with an isolated `MCPP_HOME` plus the simulated VS/SDK paths, resolved
  `llvm@20.1.7` as `x86_64-pc-windows-msvc`. The initial unisolated run
  correctly exposed the MinGW fallback separately: GNU ld cannot consume the
  MSVC-style `-llibssl/-llibcrypto` names.
- A cold `asio-ssl` project reached the Windows `compat.openssl` install hook,
  but Wine's MSVC wrapper stalled OpenSSL `Configure` while probing
  `cl -dM -E -x c /dev/null`; no `libssl.lib` or `libcrypto.lib` was produced.
  Strawberry Perl `5.40.4.1` was independently verified under Wine with
  `Locale::Maketext::Simple` and the required core modules, so Perl discovery
  was not the remaining blocker.
- A cold `libmysqlclient` project reached the same OpenSSL hook and stopped at
  the same Wine compiler-probe boundary, before the Form A client archive
  could compile or link. Therefore both local Windows results are **blocked**,
  not passes or package regressions; native Windows CI is still required for
  final ABI and runtime evidence.
