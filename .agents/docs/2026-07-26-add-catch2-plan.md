# Design doc: add Catch2 to mcpp-index

Date: 2026-07-26 (revised 2026-07-27 — single package, see §"Revision")

## Source

- Repo: [catchorg/Catch2](https://github.com/catchorg/Catch2)
- License: BSL-1.0 (Boost Software License 1.0)

Catch2 has two major versions with incompatible APIs and source layouts:

| Version | Source layout | Resulting shape |
|---------|--------------|-----------------|
| 2.13.10 | `single_include/catch2/catch.hpp` (single amalgamated header) | **header-only** |
| 3.15.2 | `src/catch2/**/*.{hpp,cpp}` (individual source files) | **static library** |

## Revision: one package, not two

The first draft of this design shipped **two** packages, `compat.catch2` (v3)
and `compat.catch2-v2` (v2), on the reasoning that "the v2→v3 jump changed the
repo layout completely, so the two versions cannot share a single `mcpp`
block."

The premise is right; the conclusion was not. The two layouts' globs are
**disjoint**, so a single `mcpp` block can carry the **union** of both and let
each version light up exactly one half:

| glob | 2.13.10 | 3.15.2 |
|---|---|---|
| `*/single_include` | exists | absent |
| `*/src/catch2/**/*.cpp` | **0 matches** — v2's only `src/` file is `src/catch_with_main.cpp`, *not* under `src/catch2/` | 107 |
| `catch2/catch_all.hpp` | absent | exists |

An `include_dirs` entry whose glob matches nothing is not an error, and a
`sources` glob that matches nothing simply contributes no TUs — which is what
makes the union safe. At 2.13.10 the package degenerates to header-only
(`single_include` + an anchor TU); at 3.15.2 it is a 106-TU static library.

The last row doubles as a compile-time major discriminator:
`__has_include(<catch2/catch_all.hpp>)`.

### Why one package is the better shape regardless

- **A version does not belong in `name`.** `catch2-v2` smuggles a major into
  the atomic name segment that SPEC-001 identity reserves for the name alone —
  the same anti-pattern the `compat.openssl` → `openssl` rename removed.
- **Semver stops working across the split.** With two packages a consumer
  cannot write `catch2 = "^3"`, and version resolution cannot see v2 and v3 as
  the same library.
- **Discovery.** One library should not answer to two package names.
- **It is a one-way door.** Once `compat.catch2-v2` ships in a published index
  artifact, withdrawing it is a breaking change. The decision had to be made
  before merge, not after.

### Relationship to mcpp#290

[mcpp-community/mcpp#290](https://github.com/mcpp-community/mcpp/issues/290)
asks for per-version `mcpp` build blocks. It is **not** a prerequisite here —
the merge works on mcpp 0.0.109 today.

Nor is Catch2 the case #290 argues from. That issue's motivating example
(llama.cpp b10069 vs b10107) shares ~95% of its build rules and differs in a
few source files. Catch2 v2/v3 share essentially *nothing* but boilerplate
(`language`, `import_std`, `c_standard`, `targets`, `deps`); they merge only
because their globs happen not to overlap.

That "happen not to" is the weak point, and it is exactly what #290 would fix:
the disjointness is a property of two upstream trees, not something this
descriptor can enforce. When #290 lands, this collapses into explicit
`["2.x"]` / `["3.x"]` blocks and the implicit assumption disappears. Until
then the premise is documented in the descriptor header and must be re-checked
whenever a version is added.

## Package shape

- **Sources**: anchor TU + `*/src/catch2/**/*.cpp` minus
  `!*/src/catch2/internal/catch_main.cpp` (107 files, 106 compiled).
- **include_dirs**: `{ "*/single_include", "*/src", "mcpp_generated" }`.
- **Anchor** (`mcpp_generated/catch2_anchor.c`): required at v2, where the
  sources glob matches nothing and a lib target still needs a TU. Same shape
  as compat.eigen / compat.khrplatform. Inert at v3.
- **catch_user_config.hpp**: materialised via `generated_files` (upstream ships
  only `catch_user_config.hpp.in` and lets CMake fill it). Only the two VALUE
  defines are mandatory — `CATCH_CONFIG_DEFAULT_REPORTER` and
  `CATCH_CONFIG_CONSOLE_WIDTH`; every other entry in the `.in` is a
  `#cmakedefine`, i.e. absent means "use the compiler-detected default". Both
  are `#ifndef`-guarded so a consumer can override via `-D`. v2 never includes
  this file. **Re-read the upstream `.in` when bumping v3** — a newly added
  mandatory value-define would break silently here.

## The `main` feature

`features = ["main"]` compiles a **generated** TU that supplies a default entry
point, branching on `__has_include(<catch2/catch_all.hpp>)` to pick the v3
(`Catch::Session`) or v2 (`CATCH_CONFIG_MAIN`) spelling.

It deliberately does **not** point at upstream's
`src/catch2/internal/catch_main.cpp`. That was the first draft's approach and
it does not work. Measured on mcpp 0.0.109:

| descriptor form | default path | `features = ["main"]` |
|---|---|---|
| glob + `!` negation, feature → the negated path | ok | **FAIL** `undefined reference to 'main'` |
| glob, no negation, feature → the globbed path | **FAIL** `multiple definition of 'main'` | ok |
| glob + `!` negation + explicit re-add, feature → that path | ok | **FAIL** `undefined reference to 'main'` |
| glob + `!` negation, feature → **generated TU** | ok | ok |

Two mechanics behind that table:

1. A `!` negation in `sources` is an **absolute** exclusion applied to the
   final source set. A feature cannot add the path back — not even if the path
   is also listed explicitly afterwards.
2. Feature gating matches **literal** `sources` entries. A file pulled in by a
   glob is not gated at all, so it lands in the default build.

Together these mean the `compat.gtest` pattern does **not** transfer:
`gtest_main.cc` is a literal `sources` entry, so listing it under a feature
gates it. Under a glob the same idea silently breaks in one direction or the
other. A generated TU sidesteps the conflict.

Cost of not reusing upstream's file: no `LeakDetector` registration (a Windows
CRT-debug nicety) and no `wmain` variant (reachable only under `_UNICODE` on
Windows). Consumers needing either write their own `main()`.

## Why this needs four workspace members

Features are resolved **per consuming project**, so one project cannot hold
`catch2` both with and without `main` (same constraint that forces `asio-ssl`
to be separate from `asio-module`). Two majors × {default, `main` feature} = 4:

| member | version | requests | what it would catch |
|---|---|---|---|
| `catch2` | 3.15.2 | — (own `main()`) | negation stops working → `multiple definition of 'main'` |
| `catch2-main` | 3.15.2 | `features = ["main"]` | feature stops gating the TU in → `undefined reference to 'main'` |
| `catch2-v2` | 2.13.10 | — (own `CATCH_CONFIG_MAIN`) | union bleeds across versions; `single_include` unresolved |
| `catch2-v2-main` | 2.13.10 | `features = ["main"]` | the `__has_include` ELSE branch (v3 members only take THEN) |

The first draft declared a `main` feature on both packages and covered
**neither** — which is precisely why the broken feature passed CI. Every test
body keeps a real `REQUIRE`, and Catch2 prints its assertion count on exit, so
a TU that compiles to nothing cannot pass quietly.

## Download URLs and mirrors

GitHub tag archive tarballs (not the individual amalgamated release assets):
xpm takes one URL per version, and the tag archive is the only form that
carries both layouts. Neither archive contains symlinks, so the Windows
extraction path is safe.

| Version | GLOBAL | CN | SHA256 |
|---|---|---|---|
| 2.13.10 | `github.com/catchorg/Catch2/archive/refs/tags/v2.13.10.tar.gz` | `gitcode.com/mcpp-res/catch2/releases/download/2.13.10/catch2-2.13.10.tar.gz` | `d54a712b…9943` |
| 3.15.2 | `github.com/catchorg/Catch2/archive/refs/tags/v3.15.2.tar.gz` | `gitcode.com/mcpp-res/catch2/releases/download/3.15.2/catch2-3.15.2.tar.gz` | `acfae120…0420` |

CN assets were uploaded to the `mcpp-res` gitcode org and re-downloaded: both
are byte-identical to the upstream archives (same sha256, same size), so the
single recorded `sha256` covers either source.

## Verification

Local, mcpp 0.0.109 (matching CI `MCPP_VERSION`), gcc@16.1.0, linux-x86_64:

- `mcpp xpkg parse` on the descriptor: OK
- `tests/check_mirror_urls.lua`: OK
- All four members via `mcpp test -p`: ok
- **Negative controls** (not committed): dropping `features = ["main"]` from
  each `-main` member fails with `undefined reference to 'main'`, confirming
  the feature is what supplies the entry point rather than something else.
- Both tarballs re-downloaded from GLOBAL and CN and sha256-checked.

CI covers linux / macOS / windows.

## Notes

- Catch2 v3 requires C++14, v2 requires C++11; both build under
  `language = "c++23"`.
- `c_standard = "c11"` is for the anchor TU.
