# Add mcpplibs.cmp 0.1.0

## Scope

- Register `mcpplibs.cmp@0.1.0` for Linux, macOS, and Windows.
- Add one import-only workspace consumer that executes a scheduled coroutine.
- Keep the upstream package manifest authoritative; do not duplicate its build graph in the index.

## Release evidence

- Release: `https://github.com/mcpplibs/cmp/releases/tag/v0.1.0`
- Tag commit: `31db013e85262e9688d69d5abca34d152d7430d2`
- Archive: `https://github.com/mcpplibs/cmp/releases/download/v0.1.0/cmp-0.1.0.tar.gz`
- Size: 207,197 bytes
- SHA-256: `17ab5e1e8fdef278d1e82eb62f0387a04e4e6d01f35408af1295de80304de1b9`

The release archive was downloaded independently twice; both downloads were byte-identical and had the recorded digest.
It contains `mcpp.toml`, `LICENSE`, and the `mcpplibs.cmp` module sources.

## Package shape and mirror

CMP is an external Form A module package: its release owns the C++23 module sources, dependency on
`chriskohlhoff.asio`, and its standalone default LLVM selection. The index descriptor therefore contains only package
metadata and the three-platform release location. There is no index-level optional source component, so no feature is added.

No separately authorized `mcpp-res` mirror exists for this release. Following the repository's documented fallback and
the `tensorvia-cpu` precedent, all platforms use the same plain-string GitHub Release URL. A maintainer can add a
byte-identical CN mirror later without changing the version or digest.

## Consumer and verification

`tests/examples/cmp-module` redirects the default namespace to this checkout, imports `mcpplibs.cmp`, schedules a lazy
`Task<int>` through `RunLoop`, and fails unless the result is 42. It performs no external network access.

Required gates:

- descriptor Lua syntax, mirror policy, package identity, platform parity, duplicate-version lint, and
  `mcpp xpkg parse` with CI-pinned mcpp `2026.8.27.2`;
- a clean `mcpp test -p cmp-module` with the same mcpp version and `MCPP_INDEX_MIRROR=GLOBAL`;
- GitHub Actions lint and Linux, macOS, and Windows selective workspace checks.

Local verification on 2026-08-30:

- all descriptor Lua, mirror, identity, cross-reference, platform-parity, duplicate-version, and CI-pinned resolver
  checks passed;
- the cold GCC 16.1.0 run downloaded the release through this checkout, built CMP and the consumer, and passed
  `runtime` (`1 passed; 0 failed`); its expected fresh-home runtime-binding warning disappeared on the repeat run;
- the matching Linux LLVM leg resolved LLVM 22.1.8, rebuilt CMP and the consumer, and passed `runtime`
  (`1 passed; 0 failed`).

The three-platform GitHub Actions result remains pending until the PR runs.
