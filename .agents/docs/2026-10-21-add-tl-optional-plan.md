# Add tl::optional 1.1.0 as compat.tl-optional

## Source and shape

- Upstream: <https://github.com/TartanLlama/optional>.
- Version: `1.1.0`, the newest stable tag observed with
  `git ls-remote --tags --refs`.
- License: CC0-1.0.
- Shape: Form B, header-only. The single public header is
  `include/tl/optional.hpp`; upstream's CMake INTERFACE target exposes
  `include/`. The package uses `include_dirs = { "*/include" }` and a trivial
  anchor C TU to provide a buildable `optional` lib target.
- No features: the library has no optional compilable source component.
  Upstream's Catch2 tests are not part of the library.

The header supports C++11/14/17. The package's own anchor is compiled as C++;
consumers choose their language mode. The workspace test uses C++23, and a
direct smoke test also compiles and runs the same API in C++14.

## Download and mirror

- GLOBAL:
  `https://github.com/TartanLlama/optional/archive/refs/tags/v1.1.0.tar.gz`
- SHA-256:
  `88ece79f3de5ccaec4191951a222f95cc80c4381dafd3163bdb1ff87cedf3118`
- The archive was downloaded twice and compared byte-for-byte; both copies had
  the same digest.
- No verified `mcpp-res` release is available, so the descriptor uses the
  upstream plain-string URL fallback rather than inventing a CN mirror.

## Automatic updates

The package meets the automatic-update criteria: it has GitHub numeric tags,
stable archive URLs, identical resources on all declared platforms, and future
versions do not require a build-recipe change. `extensions.autoupdate` uses the
prefixed `v${version}` tag spelling and the GitHub tag-archive URL template.

## Test member

`tests/examples/tl-optional/` is registered in the root workspace. It asserts:

- value and empty construction, `value_or`, reset and emplace;
- constexpr construction;
- `map`, `and_then`, `or_else` and `map_or`;
- reference optional binding, rebinding and mutation;
- `take()` moving the value out and emptying the source;
- `make_optional` preserving reference optionals.

Every assertion affects the process exit status (`return ok ? 0 : 1`).

## Verification

Pending local validation and updater declaration checks.
