# OpenSSL Windows Follow-ups: Asio SSL and libmysqlclient

> Created: 2026-08-17
> Status: design
> Repository: `mcpplibs/mcpp-index`
> Branch: `codex/windows-openssl-followups`

## 1. Goal

Extend the Windows support that landed for `compat.openssl@3.5.1` to the two
downstream packages that can be completed within `mcpp-index` in this round:

1. `chriskohlhoff.asio@1.38.1` with its opt-in `ssl` feature.
2. `compat.libmysqlclient@8.4.6`, using the repaired source tag as the sole
   effective package revision.

The result is complete only when Windows resolves the package, builds the
consumer, links the expected static libraries, and runs a non-trivial test.
Selecting a member while compiling a no-op test is not support evidence.

## 2. Scope

### In scope

- Enable the existing Asio SSL consumer test on `cfg(windows)`.
- Publish the repaired `libmysqlclient@8.4.6` archive on Windows.
- Enable the existing libmysqlclient consumer test on `cfg(windows)`.
- Keep the client ABI and Unix build behavior unchanged. The source tag was
  explicitly reissued after the Windows configuration repair; the superseded
  `8.4.6.1` tag is no longer valid.
- Validate descriptor grammar, platform-version parity, cold resolution, and
  real consumer behavior with the workflow-pinned mcpp client.

### Out of scope

- `compat.mysql-connector-cpp`: its Unix-only install hook needs a separate
  Windows build design and is intentionally deferred.
- gRPC and the external `mcpplibs/grpc-m` repository.
- `compat.curl` or `compat.eui-neo` TLS behavior, which intentionally uses
  Schannel on Windows.
- Windows ARM64, MinGW/GCC, shared OpenSSL, or NASM-accelerated builds.
- Publishing, pushing, opening, or merging a remote PR without authorization.

## 3. Current evidence and constraints

- PR #211 is merged at `upstream/main` and adds Windows x64 OpenSSL 3.5.1
  built by `VC-WIN64A` plus `cl`/`nmake`, consumed by the Windows LLVM toolchain.
- The Asio descriptor already has a Windows archive and an `ssl` feature whose
  dependency is `compat.openssl`; only the test member is Unix-gated.
- The libmysqlclient Form A archive contains Windows source, flags,
  system-library, and OpenSSL dependency data. Its Windows configuration
  enables `HAVE_OPENSSL_APPLINK_C`; the repaired source archive now carries the
  OpenSSL 3.5.1 `ms/applink.c` implementation at `include/openssl/applink.c`,
  because the static OpenSSL package does not install that source file.
- The repaired `8.4.6` archive has SHA-256
  `0c2d4b1b25d828bc40f760c50f7d49a3b6377073ac352ed5a52c2de45c7a2cad` and
  resolves to source commit `52a26090e360817850dd41e88056c98599fda6b7`.

## 4. Design

### 4.1 Asio SSL

Change only `tests/examples/asio-ssl/mcpp.toml` and stale test comments in
`tests/examples/asio-ssl/tests/ssl.cpp`:

- Add the same `chriskohlhoff.asio` feature dependency under
  `cfg(windows)` as under Linux and macOS.
- Add the same `HAVE_ASIO_SSL=1` build flag under `cfg(windows)`.
- Remove wording that describes Windows as a no-op or as lacking OpenSSL.
- Keep the TLS loopback handshake test unchanged in behavior. It must continue
  to assert certificate loading, handshake, encrypted write/read, and timeout
  handling on every declared platform.

No change is needed to the Asio descriptor or its `ssl` feature.

### 4.2 libmysqlclient

Change `pkgs/c/compat.libmysqlclient.lua` and
`tests/examples/libmysqlclient/mcpp.toml`:

- Add the repaired `8.4.6` source archive to `xpm.windows`.
- Use the reissued tag URL and its verified SHA-256. The old `8.4.6.1` tag and
  index entry are intentionally retired by explicit maintainer direction.
- Keep the vendored `include/openssl/applink.c` byte-identical to OpenSSL
  3.5.1 `ms/applink.c`; `tools/check-layout.sh` guards this required layout.
- Add the `8.4.6` dependency and `HAVE_LIBMYSQLCLIENT=1` flag under
  `cfg(windows)`.
- Update the test comment so it describes all three declared platforms.
- Keep the behavior assertion in `tests/client.cpp`: the client version must
  be `80406`, `mysql_init` must return a usable handle, and `mysql_close` must
  succeed. This catches missing headers, wrong library selection, and a link
  that only contains an empty anchor.

The archive's own Form A `mcpp.toml` remains the source of the Windows build
recipe. The index descriptor only publishes the platform/version mapping.

## 5. Verification contract

Run the cheapest checks first, then the affected members:

1. Lua syntax, descriptor-name, mirror, and platform-version parity checks.
2. Parse changed descriptors with mcpp `2026.8.10.3` or the exact pin from the
   live workflow.
3. Run the Asio SSL and libmysqlclient members from a cold package/build cache
   where the host permits it.
4. On Windows CI, confirm the logs show OpenSSL and libmysqlclient materialized,
   compiled, linked, and the test executable returned success. A selected
   member with a no-op executable is a failure of the test contract.
5. Run `git diff --check` and preserve command output and the observed test
   assertions in the task progress record.

Local macOS validation can prove descriptor parsing and the existing Unix
regressions, but it cannot prove Windows ABI or runner-tool availability.

## 6. Change grouping

Implement and verify the two packages independently:

1. Asio SSL test gate and comments.
2. libmysqlclient Windows publication and test gate.

If the Windows build exposes an archive-specific defect, stop and report it as
an upstream Form A recipe issue rather than silently changing the index shape.

## 7. Acceptance criteria

- No no-op Windows path remains in either affected consumer test.
- Windows platform parity passes for `compat.libmysqlclient`.
- Existing Linux and macOS tests remain unchanged and pass.
- Windows CI provides actual build/link/run evidence for both tests.
- Connector/C++ and gRPC remain untouched and are explicitly reported as
  deferred.
