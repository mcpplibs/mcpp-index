# Add `compat.simdjson` (`simdjson/simdjson` v5.3.0)

## Summary

Add `compat.simdjson` (`pkgs/c/compat.simdjson.lua`) wrapping `simdjson/simdjson` release `5.3.0` (Apache-2.0 / MIT) off `upstream/main`.

## Package Architecture

- **Upstream Archive**:
  - Uses stable GitHub tag release archive `https://github.com/simdjson/simdjson/archive/refs/tags/v5.3.0.tar.gz` across `linux`, `macosx`, and `windows` (plain string URL; CN mirrors can be added later).
  - SHA256 verified twice for stability: `5e59df8bd3fa760937e6a2ca68193399c85b52b5042716700b149a734737dced`.
- **Source Build & Features**:
  - Uses upstream's official amalgamation (`*/singleheader/simdjson.cpp`, `include_dirs = { "*/singleheader" }`, `license_files = { "*/LICENSE", "*/LICENSE-MIT" }`) so internal `src/` headers are not exposed.
  - `features.default` implies `threads` (`defines = { "SIMDJSON_THREADS_ENABLED=1" }`, `linux.ldflags = { "-lpthread" }`), matching upstream CMake's `SIMDJSON_ENABLE_THREADS=ON` and keeping `dom::parser` / `stage1_worker` layout ODR-consistent across TUs.
  - Consumers passing `default-features = false` build without `SIMDJSON_THREADS_ENABLED=1`.
- **Automatic Updates**:
  - `extensions.autoupdate` tracks `simdjson/simdjson` with `tag = "v${version}"`.

## Workspace Test Members

- `tests/examples/simdjson`: verifies `-DSIMDJSON_THREADS_ENABLED=1` arrives via `default` -> `threads` (accounting for Apple `-O0` `#undef SIMDJSON_THREADS_ENABLED` inside `simdjson.h`), On-Demand parser, DOM parser, active implementation, and invalid JSON rejection.
- `tests/examples/simdjson-nothreads`: `default-features = false`, verifies `SIMDJSON_THREADS_ENABLED` is omitted on non-Windows targets and On-Demand parsing succeeds.
