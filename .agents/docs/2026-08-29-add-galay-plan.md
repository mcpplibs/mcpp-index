# Add Galay 5.0.0 (`gzj-creator.galay`)

Date: 2026-08-29
Upstream: <https://github.com/gzj-creator/galay>
Tag: `v5.0.0` (`a9e81ce8239695a8dae68314ee991339839d5409`)
Status: local Linux validation passed with mcpp 2026.8.27.1 and the CI-pinned 2026.8.27.2 check.

## 1. Shape and identity

Galay is source type (b), a library already developed for mcpp. Its v5.0.0
release carries a complete `mcpp.toml`, so the index entry is Form A and does
not duplicate its build recipe.

- Package identity: `namespace = "gzj-creator"`, `name = "galay"`. The
  namespace names the upstream owner; the package name remains one atomic
  segment.
- The upstream manifest builds the default `galay.utils` and `galay.kernel`
  named modules plus their C++ implementations. SSL, HTTP, WebSocket, HTTP/2,
  database, RPC, MCP, and tracing sources remain opt-in features in that
  manifest, with the corresponding feature dependencies preserved.
- The release manifest declares `platforms = ["linux", "macos"]`. The index
  therefore publishes `linux` and `macosx` entries only; Windows is omitted
  until the upstream manifest gains a Windows-compatible build.
- License and description are taken from the upstream manifest: Apache-2.0,
  C++23 coroutine networking and protocol framework.

## 2. Source and hash

Both platform entries use the immutable GitHub tag archive:

    https://github.com/gzj-creator/galay/archive/refs/tags/v5.0.0.tar.gz

The archive is 5,227,585 bytes. `sha256sum` was run twice on the complete
archive and returned:

    8e410d97b0615333c92192633f9495acdc8eb1d56dd94f1eeecd8e68e5a4f73e

`tar -tzf` succeeds and confirms the root `mcpp.toml`, the tracked include
layout, and the fifteen named C++23 module interfaces are present.

## 3. CN mirror

`gtc` is not installed in this environment and no GitCode write credential is
available. Following `docs/cn-mirror.md`, the descriptor uses the plain GLOBAL
URL rather than inventing a mirror table. CN consumers fall back to GitHub;
the `mcpp-res/galay` mirror can be added later without changing the package
identity or version.

## 4. Workspace member

`tests/examples/galay` is a Unix-gated public-package consumer. Its member
manifest has exactly one project index redirect:

    [indices]
    gzj-creator = { path = "../../.." }

The test imports `galay.utils` and `galay.kernel`, checks Base64 and string
helpers, links the out-of-line `kernel::Buffer` implementation, and validates
IPv4 `kernel::Host` construction. Windows compiles a no-op `main()` because
the upstream package has no Windows platform entry.

The first RED run failed as expected before the descriptor existed:

    error: dependency 'gzj-creator.galay': no package found for exact selector

After adding the descriptor, the first executable run caught an incorrect
assumption about `Buffer::clear()` retaining its length; the assertion was
changed to require the documented empty state. The corrected test then passed.

## 5. Validation

- `mcpp xpkg parse pkgs/g/gzj-creator.galay.lua` passed with the Form-A result
  and Linux/macOS version lists.
- `mcpp test -p galay` passed with mcpp 2026.8.27.1 after a cold build:
  `test result ok. 1 passed; 0 failed`.
- The CI-pinned `mcpp 2026.8.27.2` test also passed offline:
  `test result ok. 1 passed; 0 failed`.
- The build compiled 26 Galay units, including both default module interfaces,
  the kernel implementation units, and the transitive libaio package.
- All six descriptor lint checks passed, and all 134 package descriptors passed
  `mcpp xpkg parse` with the CI-pinned binary.
- Optional Galay features are intentionally not enabled by this minimal
  member. They remain upstream-owned feature/dependency decisions and need
  dedicated protocol/database environments before being advertised as tested.

## 6. Follow-up

When upstream publishes Windows support or a maintainer creates the
`mcpp-res/galay` release asset, add the platform/mirror entry with the same
archive bytes and keep the version at `5.0.0` only if the bytes remain
identical; otherwise publish a new upstream version/tag.
