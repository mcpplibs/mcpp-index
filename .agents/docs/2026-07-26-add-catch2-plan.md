# Design doc: add Catch2 to mcpp-index

Date: 2026-07-26

## Source

- Repo: [catchorg/Catch2](https://github.com/catchorg/Catch2)
- License: BSL-1.0 (Boost Software License 1.0)
- Upstream release model: amalgamated files published as GitHub release assets

Catch2 has two major versions with incompatible APIs and source layouts:

| Version | Source layout | Shape |
|---------|--------------|-------|
| v2.13.10 | `single_include/catch2/catch.hpp` (single amalgamated header) | **header-only** |
| v3.15.2 | `src/catch2/**/*.{hpp,cpp}` (individual source files) | **C-source compat (static lib)** |

The v2→v3 jump changed the repo layout completely (`single_include/` → `src/catch2/`),
so the two versions cannot share a single `mcpp` block. Two separate packages are used:

- `compat.catch2` — v3, C-source compat (static library from individual source files)
- `compat.catch2-v2` — v2, header-only

## Package shape decision

### compat.catch2 (v3)

- **Shape**: C-source compat static library (same as compat.cjson / compat.gtest)
- **Sources**: `*/src/catch2/**/*.cpp` — all Catch2 implementation files (107 TUs)
- **include_dirs**: `{ "*/src", "mcpp_generated" }` — exposes `<catch2/catch_all.hpp>`
  etc. from the source tree, and `catch2/catch_user_config.hpp` from generated files
- **catch_user_config.hpp**: materialised via `generated_files` (normally
  CMake-generated; provides `CATCH_CONFIG_DEFAULT_REPORTER` and
  `CATCH_CONFIG_CONSOLE_WIDTH`). Both value-defines use `#ifndef` guards so
  users can override them via `cxxflags = ["-DCATCH_CONFIG_DEFAULT_REPORTER=xml"]`
  in their own `mcpp.toml`. Other boolean toggles (e.g. `CATCH_CONFIG_WCHAR`)
  are auto-detected by `catch_compiler_capabilities.hpp` and can likewise be
  forced on/off via `-D` flags.
- **catch_main.cpp**: provides a default `main()`. Excluded from the default
  source set via `!` negation (`"!*/src/catch2/internal/catch_main.cpp"`);
  only compiled when `features = ["main"]` is requested (same pattern as
  `compat.gtest`'s `main` feature gating `gtest_main.cc`)

### compat.catch2-v2 (v2)

- **Shape**: header-only (same as compat.eigen / compat.opengl)
- **include_dirs**: `{ "*/single_include" }` — consumers `#include <catch2/catch.hpp>`
- **Anchor**: trivial `.c` TU (`mcpp_generated/catch2_v2_anchor.c`) to give mcpp
  a buildable lib target
- **`main` feature**: gates a generated `main.cpp` that defines
  `CATCH_CONFIG_MAIN` and includes `<catch2/catch.hpp>`, providing a ready-made
  `main()`. Excluded by default

## Download URLs

Both packages use GitHub tag archive tarballs (not individual release assets)
because xpm supports one URL per version.

| Package | Version | GitHub archive URL | SHA256 |
|---------|---------|--------------------|--------|
| compat.catch2 | 3.15.2 | `https://github.com/catchorg/Catch2/archive/refs/tags/v3.15.2.tar.gz` | `acfae120892c2b67a74142d36d060c0caa96f1c3aaa8aabd96e19961163d0420` |
| compat.catch2-v2 | 2.13.10 | `https://github.com/catchorg/Catch2/archive/refs/tags/v2.13.10.tar.gz` | `d54a712b7b1d7708bc7a819a8e6e47b2fde9536f487b89ccbca295072a7d9943` |

### Individual release asset SHAs (for reference)

| File | Release URL | SHA256 |
|------|------------|--------|
| catch.hpp (v2.13.10) | `https://github.com/catchorg/Catch2/releases/download/v2.13.10/catch.hpp` | `3725c0f0a75f376a5005dde31ead0feb8f7da7507644c201b814443de8355170` |
| catch_amalgamated.cpp (v3.15.2) | `https://github.com/catchorg/Catch2/releases/download/v3.15.2/catch_amalgamated.cpp` | `1ec0b0c0d6133f76fea521295be3e69e3aa5464ab92972897414ca59b7f674d5` |
| catch_amalgamated.hpp (v3.15.2) | `https://github.com/catchorg/Catch2/releases/download/v3.15.2/catch_amalgamated.hpp` | `f0573f46ac989896a20c524085307b633f01c8e1cdbbe6d9b39f63827c2d6c5e` |

## CN mirror

Not configured yet — no `mcpp-res` write access. Using plain-string upstream URLs
(no `{ GLOBAL=…, CN=… }` table). CN users will fall back to the upstream source.
Mirrors can be added later by a maintainer.

## Test examples

- **tests/examples/catch2/**: v3 static library build. Includes
  `<catch2/catch_all.hpp>`, provides own `main()` using
  `Catch::Session().run()`, runs two `TEST_CASE`s.
- **tests/examples/catch2-v2/**: v2 header-only. Defines `CATCH_CONFIG_MAIN` to
  get a built-in main, includes `<catch2/catch.hpp>`, runs two `TEST_CASE`s
  within a single TU.

## Verification

- SHA256 computed twice (confirmed stable) via `sha256sum` on the codeload tarballs
- File paths confirmed by `tar -tzf` against tag archives
- Both packages pass `mcpp xpkg parse` lint
- `mcpp test -p catch2` → **test result ok** (2 assertions in 2 test cases)
- `mcpp test -p catch2-v2` → **test result ok** (2 assertions in 2 test cases)
- Tested with mcpp 0.0.108 (matching CI `MCPP_VERSION`) on x86_64-windows-msvc

## Notes

- Catch2 v3 static library requires `catch_user_config.hpp` (normally
  CMake-generated). A minimal version is materialised via `generated_files` at
  `mcpp_generated/catch2/catch_user_config.hpp` with `#ifndef` guards on the
  two value-defines (`CATCH_CONFIG_DEFAULT_REPORTER` and
  `CATCH_CONFIG_CONSOLE_WIDTH`), allowing users to override them via `-D` flags.
- `catch_main.cpp` is gated via `!` negation in `sources` + feature listing,
  following the exact `compat.gtest` pattern. No `-DCATCH_AMALGAMATED_CUSTOM_MAIN`
  needed.
- Catch2 v3 requires C++14 or later; v2 requires C++11; both compatible with
  mcpp's `language = "c++23"`.
- No `c_standard` needed for v3 (pure C++); anchor for v2 uses
  `c_standard = "c11"`.
