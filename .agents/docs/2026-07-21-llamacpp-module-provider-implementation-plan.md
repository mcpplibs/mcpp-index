# llama.cpp Module Provider Delivery Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Publish a five-package llama.cpp `b10069` graph whose only public consumer surface is `import llama;`, with CPU as the mandatory default and Metal as the single selectable accelerator.

**Architecture:** Deliver three independently testable repository changes in dependency order: mcpp first makes invalid `backend=` selections fatal, `llamacpp-m` owns the generated C++ module facade, and mcpp-index owns the GGML/llama source split plus Metal provider. A release candidate is validated through a pinned staging index before any public tag or index merge, then the public Form A descriptor closes the graph.

**Tech Stack:** C++23 named modules, mcpp `0.0.101+`, xpkg Lua descriptors, `build.mcpp`, Python 3 snapshot/export generators, GGML/llama.cpp `b10069`, GitHub Actions on Linux x86-64, macOS ARM64, and Windows x86-64.

---

## 1. Frozen Baseline

- mcpp-index fork: `wellwei/mcpp-index@0b0a98f3e82b05328be944bda3f91010344e2840`.
- mcpp: `mcpp-community/mcpp@af25d18ee2a97d17fb57bae86232e6f61560343d` (`0.0.101`).
- llama.cpp tag: `b10069`, commit `178a6c44937154dc4c4eff0d166f4a044c4fceba`.
- llama.cpp source archive SHA-256: `293a7c65a11e2203c5468a06d0d0e8d21dfff16ad08712b16c61efbe0d93e097`.
- Test model: `ggml-org/models-moved@499bc8821c6b12b4e53c5bffcb21ec206f212d81/tinyllamas/stories15M-q4_0.gguf`, 19,077,344 bytes, SHA-256 `66967fbece6dbe97886593fdbb73589584927e29119ec31f08090732d1861739`; the original `karpathy/tinyllamas` model card declares MIT.
- Prototype evidence only: mcpp-index commits `64c5d2e` (CPU) and `42f36d6` (Metal). The monolithic `compat.llamacpp` recipe is replaced, not migrated.

Before execution, refresh all three repositories. If a baseline moved, re-run the audits in the child plans and update this section before changing code. Do not silently carry an old source list or mcpp workflow pin forward.

## 2. Plan Suite And Repository Boundaries

| Plan | Repository | Independently testable result |
|---|---|---|
| [mcpp backend selection](2026-07-21-mcpp-backend-selection-hard-error-plan.md) | `mcpp-community/mcpp` | Unknown dependency `backend=` values fail without `--strict`; ordinary unknown features retain current warning behavior. |
| [`llamacpp-m` module facade](2026-07-21-llamacpp-m-module-facade-plan.md) | new `mcpplibs/llamacpp-m` | A Form A package exports the reviewed non-deprecated llama API through `import llama;` and forwards `backend-metal`. |
| [mcpp-index package graph](2026-07-21-mcpp-index-llamacpp-package-graph-plan.md) | `wellwei/mcpp-index`, then upstream | Four internal packages plus public `llamacpp`, self-contained CPU/Metal consumers, negative contracts, cold-cache CI, and release admission. |

Planning documents remain on this docs-only branch. They must not appear in an upstream package PR; package PRs contain only implementation, tests, tools needed to maintain the package, and upstream-facing documentation.

## 3. File Responsibility Map

| Repository/file | Responsibility |
|---|---|
| `mcpp/src/build/prepare.cppm` | Reserve dependency feature names beginning with `backend-` as hard selectors and reject an undeclared selector. |
| `mcpp/tests/e2e/67_features_strict.sh` | Lock backend hard-failure behavior while preserving non-backend warning/strict semantics. |
| `llamacpp-m/mcpp.toml` | Public SemVer, exact `compat.llamacpp@b10069` dependency, CPU default, and Metal feature forwarding. |
| `llamacpp-m/src/llama.cppm` | Global-module-fragment include of `llama.h`, reviewed exported using-declarations, and typed replacements for public constants. |
| `llamacpp-m/tools/gen_exports.py` | Generate and diff the non-deprecated llama API surface plus only the GGML types required by llama signatures. |
| `mcpp-index/tools/llamacpp/audit_snapshot.py` | Produce a reviewable candidate report for source sets, registry macros, frameworks, shader inputs, and API deltas. |
| `mcpp-index/pkgs/c/compat.ggml-base.lua` | Upstream `ggml-base` source set. |
| `mcpp-index/pkgs/c/compat.ggml-cpu.lua` | Mandatory CPU backend, architecture sources, `llamafile`, and Windows `advapi32`. |
| `mcpp-index/pkgs/c/compat.ggml-metal.lua` | macOS ARM64 Metal provider, embedded shader generation, and `provides = { "ggml.accelerator" }`. |
| `mcpp-index/pkgs/c/compat.llamacpp.lua` | GGML registry plus llama/model implementation; registry-only CPU/Metal macros and exact internal dependencies. |
| `mcpp-index/pkgs/l/llamacpp.lua` | Public Form A descriptor for the `llamacpp-m` release. |
| `mcpp-index/tests/examples/llamacpp-internal-cpu` | Header-based implementation-only smoke for the three-package CPU graph. |
| `mcpp-index/tests/examples/llamacpp-module-{cpu,metal}` | Public consumers that contain `import llama;` and no llama/GGML includes. |
| `mcpp-index/tests/llamacpp_backend_contract.sh` | Invalid backend, unsupported platform, and internal snapshot negative checks. |
| `mcpp-index/tests/fetch_llamacpp_model.py` | Mandatory checksum-verified GGUF fixture provision on all release legs. |

## 4. Delivery Order

### P0: Freeze Evidence And Land The mcpp Prerequisite

- [ ] **Step 1: Record the prototype delta without editing the old recipe**

Run the snapshot tool specified by the mcpp-index child plan against `b10069` and commit its deterministic JSON report. The report must list every model TU explicitly; `src/models/*.cpp` is not accepted as frozen evidence.

Expected: the report records the three C++20 exceptions (`t5.cpp`, `eagle3.cpp`, `dflash.cpp`), the Windows `advapi32` need, six Metal TUs, three shader inputs, and the registry calls guarded by `GGML_USE_CPU`/`GGML_USE_METAL`.

- [ ] **Step 2: Implement and release the backend hard-error prerequisite**

Execute the mcpp child plan. Release only after the feature PR is merged and current `main` CI is green. With the baseline above the intended release is `0.0.102`; if another release wins that number, use the next patch and update every downstream floor/pin together.

Expected: `backend = "cuda"` and `backend = "metla"` fail even without `--strict`, including when the dependency declares no feature table.

- [ ] **Step 3: Establish a cross-repository staging branch**

Create `feat/llamacpp-module-provider` from refreshed `origin/main` in the mcpp-index fork. The module repository's pre-release CI checks out this exact branch as its local `compat` index until the package graph merges. Do not tag the module package while any staging check is red.

### P1: Split The CPU Graph

- [ ] **Step 1: Add the three CPU internal packages**

Execute Tasks 2-4 of the mcpp-index child plan. The source ownership must match upstream CMake:

```text
compat.ggml-base  = ggml-base
compat.ggml-cpu   = ggml-cpu, always present
compat.llamacpp   = ggml registry + llama + explicit model TUs
```

- [ ] **Step 2: Prove the internal graph before adding the module**

Run the internal header-based smoke only as a package implementation test. It must load the pinned GGUF and complete one `llama_decode`; a missing model is a failure.

Expected: Linux x86-64, macOS ARM64, and Windows x86-64 pass from an isolated `MCPP_HOME`. Windows links `advapi32`; all three compile `t5.cpp` rather than silently dropping the architecture.

### P2: Build The Public Module Facade

- [ ] **Step 1: Create and verify `llamacpp-m` locally**

Execute the module child plan against the staging index. Its tests must have no textual llama/GGML include and must prove that importing the module does not leak `LLAMA_*` macros.

- [ ] **Step 2: Review the generated API diff**

Review `src/gen_exports/llama.inc`, `src/gen_exports/required_ggml.inc`, and `src/gen_exports/llama.skipped.txt` as source code. Deprecated llama functions, `llama-cpp.h`, unrelated GGML functions, and preprocessor macros must not enter the module.

- [ ] **Step 3: Keep the release candidate untagged**

The module's CPU tests may run against the staging index branch, but the `v0.1.0` tag waits until P3 Metal and the final mcpp-index graph are green.

### P3: Add The Metal Provider

- [ ] **Step 1: Add `compat.ggml-metal`**

Execute the Metal tasks in the mcpp-index child plan. Its `build.mcpp` must mechanically reproduce upstream `GGML_METAL_EMBED_LIBRARY`: merge `ggml-common.h` and `ggml-metal-impl.h` into the Metal source, emit a Mach-O data-section assembly source, register that generated source, and define `GGML_METAL_EMBED_LIBRARY`.

- [ ] **Step 2: Wire feature forwarding and capability validation**

The exact path is:

```text
llamacpp/backend-metal
  -> compat.llamacpp/backend-metal
  -> exact compat.ggml-metal@b10069 dependency
  -> provides ggml.accelerator
  -> requires ggml.accelerator
  -> GGML_USE_METAL only on ggml-backend-reg.cpp
  -> strong call to ggml_backend_metal_reg()
```

- [ ] **Step 3: Prove real Metal execution**

The macOS ARM64 consumer must assert `llama_supports_gpu_offload()`, capture the `using embedded metal library` log, request all layers with `n_gpu_layers = 99`, observe a positive `offloaded N/M layers to GPU` log, and complete one decode. A successful model load also exercises the mandatory CPU fallback path that upstream requires.

### P4: Release And Admit The Package Group

- [ ] **Step 1: Run the complete staging matrix from cold state**

Required legs:

| OS/arch | CPU import/decode | Metal import/decode | Negative backend |
|---|---:|---:|---:|
| Linux x86-64 | required | unsupported must fail | typo/CUDA/Metal fail |
| macOS ARM64 | required | required | typo/CUDA fail |
| Windows x86-64 | required | unsupported must fail | typo/CUDA/Metal fail |
| macOS x86-64 guard | target currently planned, not claimed | direct provider build-program contract must fail | Metal fail |

- [ ] **Step 2: Tag `llamacpp-m` only after staging is green**

With explicit authorization, create `v0.1.0`, let release CI rebuild/test the tagged commit against the pinned staging graph, and verify the GitHub source archive. Record its exact SHA-256 in `pkgs/l/llamacpp.lua`.

- [ ] **Step 3: Complete the final mcpp-index commit**

Add the public Form A descriptor, replace the monolithic prototype tests, update `index.toml` and every live workflow mcpp pin to the released prerequisite, and use plain upstream URLs until an authorized byte-identical CN mirror is available.

- [ ] **Step 4: Run release admission**

Run descriptor Lua syntax, `mcpp xpkg parse --all-os`, snapshot consistency, model checksum, targeted cold CPU/Metal, negative backend, and full affected workspace tests. Inspect produced logs for actual assertions; download/configure success alone is not acceptance.

- [ ] **Step 5: Commit and stop at the external-action boundary**

The package branch should contain small commits matching the child plan. Before any push or PR, audit both `git diff origin/main...HEAD` and `git log origin/main..HEAD` and remove no user work. Request explicit authorization before pushing, creating releases/mirrors, or opening PRs.

## 5. Cross-Repository Invariants

1. The only documented dependency/import pair is `llamacpp` plus `import llama;`.
2. `#include <llama.h>` is used only by internal implementation tests and the module's global module fragment.
3. CPU cannot be disabled. `backend = "metal"` means CPU plus Metal.
4. The registry macro lives on `compat.llamacpp`'s `ggml-backend-reg.cpp`, not on the provider.
5. Provider discovery scans only the resolved graph; the feature must pull the concrete provider.
6. All four internal packages use the same upstream tag and archive bytes. A committed snapshot-cohort check runs before build tests; a second cohort is blocked until xpkg can preserve version-scoped recipes or internal identities become snapshot-qualified.
7. Metal has no runtime shader-file contract and no CPU fallback when Metal was explicitly requested but failed to build.
8. No required model test may return success because the fixture is absent.
9. A public release is not created from a partially green platform matrix.

Current mcpp `0.0.101` synthesizes one descriptor-level `mcpp` body and dependency
map for every xpm version. Therefore P0-P4 admit only `b10069`; appending a later
tag while changing shared exact dependencies would make fresh resolution of the
historical cohort inconsistent. Resolve that schema/identity decision before the
first upstream snapshot update, while keeping public `llamacpp` SemVer history
append-only.

## 6. CUDA Entry Criteria

CUDA is excluded from P0-P4. Start a separate design only when all of these are evidenced:

- a reproducible NVCC/CMake package build or first-class mcpp CUDA-source support;
- hermetic CUDA SDK and compiler discovery on Linux and Windows;
- a non-bypassable one-of accelerator constraint that rejects two linked providers even when `[capabilities]` is pinned;
- registry macro/link-retention tests for CUDA;
- checksum-pinned model tests that prove real CUDA offload on both supported operating systems.

Until then, `backend = "cuda"` is intentionally undeclared and must fail through the mcpp backend hard-error path.

## 7. Final Verification Commands

Run these at the end of the implementation, from their respective worktrees:

```bash
# mcpp
bash tests/e2e/67_features_strict.sh
mcpp build

# llamacpp-m (against the staging index configured by its CI helper)
python3 tools/gen_exports.py --check
mcpp test --no-cache

# mcpp-index
python3 tools/llamacpp/audit_snapshot.py --check tools/llamacpp/snapshots/b10069.json
python3 tests/fetch_llamacpp_model.py --output /tmp/stories15M-q4_0.gguf
mcpp xpkg parse --all-os pkgs/c/compat.ggml-base.lua
mcpp xpkg parse --all-os pkgs/c/compat.ggml-cpu.lua
mcpp xpkg parse --all-os pkgs/c/compat.llamacpp.lua
mcpp xpkg parse --all-os pkgs/c/compat.ggml-metal.lua
mcpp xpkg parse --all-os pkgs/l/llamacpp.lua
bash tests/llamacpp_backend_contract.sh
LLAMACPP_TEST_MODEL=/tmp/stories15M-q4_0.gguf mcpp test -p llamacpp-internal-cpu --no-cache
LLAMACPP_TEST_MODEL=/tmp/stories15M-q4_0.gguf mcpp test -p llamacpp-module-cpu --no-cache
LLAMACPP_TEST_MODEL=/tmp/stories15M-q4_0.gguf mcpp test -p llamacpp-module-metal --no-cache
```

Expected: every command exits `0`; negative cases print the expected hard error internally; Metal test output proves embedded shader use and positive GPU layer offload.
