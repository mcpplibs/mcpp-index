# Add xsimd 14.3.0 as compat.xsimd

## Source and shape

- Upstream: <https://github.com/xtensor-stack/xsimd>.
- Version: `14.3.0`, the newest stable tag observed with
  `git ls-remote --tags --refs`.
- License: BSD-3-Clause.
- Shape: Form B, header-only. Upstream's CMake INTERFACE target exposes
  `include/`, where consumers find `<xsimd/xsimd.hpp>`. The package therefore
  uses `include_dirs = { "*/include" }` and a trivial anchor C TU to provide a
  buildable `xsimd` lib target.
- No features: xsimd has no optional compilable library component. The
  optional `xtl::xcomplex` integration is an external dependency plus the
  consumer's `XSIMD_ENABLE_XTL_COMPLEX` define, which a sources-only feature
  cannot express.

Upstream requires C++14. The descriptor compiles its own anchor as C++; the
consumer test uses the workspace default C++23 mode and a direct smoke test
also verifies that the public header compiles in C++14 mode.

## Download and mirror

- GLOBAL:
  `https://github.com/xtensor-stack/xsimd/archive/refs/tags/14.3.0.tar.gz`
- SHA-256:
  `b3d50e7a73fbf4642ceef30131c93414901d69eee41c2a5302db650b03e2c792`
- The archive was downloaded twice and compared byte-for-byte; both copies had
  the same digest.
- No verified `mcpp-res/xsimd` release is available, so the descriptor uses the
  upstream plain-string URL fallback rather than inventing a CN resource.

## Automatic updates

The package meets the automatic-update criteria: it has GitHub numeric tags,
stable archive URLs, identical resources on all declared platforms, and future
versions do not require a build-recipe change. `extensions.autoupdate` uses the
unprefixed `${version}` tag spelling and the GitHub tag-archive URL template.
The initial URL and SHA-256 live once in the `versions` table and all three
platforms reference that entry.

## Test member

`tests/examples/xsimd/` is registered in the root workspace. It asserts:

- the selected default architecture is supported and available;
- runtime architecture discovery contains the default architecture;
- unaligned load, batch addition and unaligned store preserve every lane;
- batch square root and horizontal reduction return the expected scalar.

Every assertion affects the process exit status (`return ok ? 0 : 1`).

## Verification

- Pinned mcpp `2026.10.1.2`:
  `mcpp xpkg parse --all-os pkgs/c/compat.xsimd.lua` reports `parse OK` for
  linux, macosx, and windows.
- Pinned cold GCC run:
  `mcpp test -p xsimd --cache off` reports
  `test result ok. 1 passed; 0 failed`, running
  `xsimd OK width=4 arch=sse2`.
- Pinned cold LLVM run:
  `mcpp test -p xsimd --toolchain llvm@22.1.8 --cache off` reports the same
  successful test with Clang.
- The public header and test compile and run directly under both C++14 and
  C++23 (GCC 16.2.1), covering xsimd's documented language floor.
- Full relevant lint passed: Lua syntax, mirror URL policy, package identity,
  reserved namespaces, cross-package references, platform parity, and
  duplicate versions. All 255 descriptors parse with the pinned mcpp.
- The pinned updater's 11 repository tests pass. Its declaration coverage audit
  reports `All 83 GitHub-direct descriptors declared; all existing versions
  unchanged`, including `compat:xsimd`.
- `xpkgindex_update inspect --package compat:xsimd` accepts the declaration and
  reports the three platform URLs plus the automatic-update template.
- `xpkgindex_update check --package compat:xsimd` reports
  `status = "up-to-date"`, current version `14.3.0`, discovery by upstream
  tags. An earlier attempt hit the unauthenticated GitHub API rate limit; the
  check passed after the documented reset window.
