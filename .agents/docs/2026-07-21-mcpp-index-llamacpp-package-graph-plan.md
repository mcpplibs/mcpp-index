# mcpp-index llama.cpp Package Graph Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the unpublished monolithic llama.cpp prototype with a five-package `b10069` graph whose only public consumer contract is `import llama;`, with mandatory CPU support and a macOS ARM64 Metal provider selected by `backend = "metal"`.

**Architecture:** Four Form B packages split upstream `ggml-base`, `ggml-cpu`, `ggml` registry/llama, and `ggml-metal` ownership; the public `llamacpp` package is a Form A descriptor for `mcpplibs/llamacpp-m`. The Metal feature is declared only by the macOS implementation overlay, pulls one concrete capability provider, defines `GGML_USE_METAL` only on the registry translation unit, and embeds the Metal source through dependency-owned `build.mcpp`.

**Tech Stack:** xpkg V1 Lua descriptors, mcpp feature forwarding/capabilities/per-OS features/per-glob flags, C11/C++23/Objective-C/Mach-O assembly, dependency `build.mcpp`, Python 3 audit and fixture tools, GitHub Actions on Linux x86-64, macOS ARM64, and Windows x86-64.

---

## Frozen Inputs And Stops

- Fork baseline: `wellwei/mcpp-index@0b0a98f3e82b05328be944bda3f91010344e2840`.
- Upstream llama.cpp: tag `b10069`, commit `178a6c44937154dc4c4eff0d166f4a044c4fceba`.
- Source URL: `https://github.com/ggml-org/llama.cpp/archive/refs/tags/b10069.tar.gz`.
- Source SHA-256: `293a7c65a11e2203c5468a06d0d0e8d21dfff16ad08712b16c61efbe0d93e097`.
- GGUF fixture URL: `https://huggingface.co/ggml-org/models-moved/resolve/499bc8821c6b12b4e53c5bffcb21ec206f212d81/tinyllamas/stories15M-q4_0.gguf`.
- GGUF fixture size: `19077344` bytes; SHA-256: `66967fbece6dbe97886593fdbb73589584927e29119ec31f08090732d1861739`.
- Current index floor and all active workflow pins are `0.0.101`. Replace them with the actually released backend-hard-error version; `0.0.102` is only the frozen-baseline expectation.
- Existing commits `64c5d2e` and `42f36d6`, `pkgs/c/compat.llamacpp.lua`, and `tests/examples/llamacpp/` are prototype evidence. Do not publish or incrementally repair that single-package contract.
- Use plain GLOBAL URLs until an authorized CN mirror is reachable and byte-identical. The prototype's current GitCode URL is not release evidence.
- Stop on a moved upstream tag, checksum mismatch, duplicate upstream PR, missing module release asset, unsupported target, absent model, or a red required platform. Never downgrade an explicitly requested Metal build to CPU.

## File Map

| File | Responsibility |
|---|---|
| `tools/llamacpp/audit_snapshot.py` | Download/verify a candidate archive and report source sets, registry macros, platform libraries, shader inputs, and API hashes without rewriting descriptors. |
| `tools/llamacpp/test_audit_snapshot.py` | Unit-test balanced CMake extraction, marker checks, deterministic ordering, archive validation, and report diffs. |
| `tools/llamacpp/snapshots/b10069.json` | Committed immutable audit report, including all 137 model TUs by name. |
| `tests/check_llamacpp_snapshot.py` | Compare all four internal descriptors with the committed snapshot, exact cohort versions, dependency edges, source ownership, and Metal feature placement. |
| `pkgs/c/compat.ggml-base.lua` | Upstream `ggml-base` sources and public GGML headers. |
| `pkgs/c/compat.ggml-cpu.lua` | Mandatory CPU backend, architecture sources, default llamafile kernel, and Windows `advapi32`. |
| `pkgs/c/compat.llamacpp.lua` | `ggml` registry/dynamic-loader TUs plus llama and explicit model TUs; exact base/CPU dependencies and macOS-only Metal feature. |
| `pkgs/c/compat.ggml-metal.lua` | macOS-only Metal provider, six implementation TUs, frameworks, and embedded shader generator. |
| `pkgs/l/llamacpp.lua` | Public Form A descriptor for the released `llamacpp-m@0.1.0` archive. |
| `tests/examples/llamacpp-internal-cpu/` | Internal header-based implementation smoke; not a documented consumer API. |
| `tests/examples/llamacpp-module-cpu/` | Three-platform default/CPU import-only load and decode contract. |
| `tests/examples/llamacpp-module-metal/` | macOS ARM64 import-only Metal registration, embedded shader, offload, and decode contract. |
| `tests/fetch_llamacpp_model.py` | Fetch the pinned GGUF atomically and reject missing, wrong-size, or wrong-hash bytes. |
| `tests/llamacpp_backend_contract.sh` | Exercise explicit CPU, typo/CUDA, unsupported Metal, capability absence, and cohort mismatch failures. |
| `mcpp.toml` | Replace the prototype workspace member with the three focused llama members. |
| `.github/workflows/validate.yml` | Raise floor/pins together, provision the required model, run negative contracts, and execute targeted cold-cache legs. |
| `README.md` | Document only `llamacpp` plus `import llama;`; keep all `compat.*` identities internal. |

## Task 1: Refresh The Contribution Boundary

**Files:**
- Inspect: `index.toml`
- Inspect: `.github/workflows/validate.yml`
- Inspect: `mcpp.toml`
- Inspect: `pkgs/c/compat.llamacpp.lua`

- [ ] **Step 1: Refresh the fork and inspect duplicate work**

```bash
git fetch origin main
git status --short --branch
git rev-parse origin/main
gh pr list --repo mcpplibs/mcpp-index --state open --limit 100
git log --oneline -20 origin/main -- pkgs/c/compat.llamacpp.lua tests/examples/llamacpp
```

Expected on the frozen baseline: `origin/main` is `0b0a98f`, the prototype is present only in the fork history, and no upstream PR owns the five-package module/provider work. If any fact changed, rerun the audits below before editing.

- [ ] **Step 2: Create the implementation worktree only when execution begins**

```bash
git worktree add ../mcpp-index-llamacpp-provider \
  -b feat/llamacpp-module-provider origin/main
```

Expected: a clean topic worktree based on the refreshed fork main. Planning files from this docs branch must never enter the implementation branch.

- [ ] **Step 3: Record the live client contract**

```bash
sed -n '1,80p' index.toml
rg -n 'MCPP_VERSION|mcpp_version|min_mcpp|latest_mcpp' \
  index.toml .github/workflows/validate.yml
```

Expected on the frozen baseline: every active pin is `0.0.101`. Do not edit these values until the mcpp prerequisite has merged, released, and produced all maintained artifacts.

## Task 2: Freeze A Deterministic Snapshot Report

**Files:**
- Create: `tools/llamacpp/audit_snapshot.py`
- Create: `tools/llamacpp/test_audit_snapshot.py`
- Create: `tools/llamacpp/snapshots/b10069.json`
- Create: `tests/fetch_llamacpp_model.py`

- [ ] **Step 1: Write failing audit-tool tests**

`tools/llamacpp/test_audit_snapshot.py` must build a temporary miniature tree with these exact markers:

```cmake
add_library(ggml-base ggml.c ggml.cpp ggml-backend.cpp)
add_library(ggml ggml-backend-dl.cpp ggml-backend-reg.cpp)
ggml_add_backend_library(ggml-metal
    ggml-metal.cpp
    ggml-metal-device.m
    ggml-metal-device.cpp)
file(GLOB LLAMA_MODELS_SOURCES "models/*.cpp")
add_library(llama llama.cpp ${LLAMA_MODELS_SOURCES})
```

Create two model files, a registry fixture containing both `GGML_USE_CPU`/`ggml_backend_cpu_reg()` and `GGML_USE_METAL`/`ggml_backend_metal_reg()`, and a Metal fixture containing both shader replacement markers. Assert:

```python
self.assertEqual(report["sources"]["ggml_base"], [
    "ggml/src/ggml.c",
    "ggml/src/ggml.cpp",
    "ggml/src/ggml-backend.cpp",
])
self.assertEqual(report["sources"]["models"], [
    "src/models/a.cpp",
    "src/models/z.cpp",
])
self.assertEqual(report["registry"]["GGML_USE_CPU"], "ggml_backend_cpu_reg")
self.assertEqual(report["registry"]["GGML_USE_METAL"], "ggml_backend_metal_reg")
self.assertEqual(report["metal"]["shader_inputs"], [
    "ggml/src/ggml-common.h",
    "ggml/src/ggml-metal/ggml-metal.metal",
    "ggml/src/ggml-metal/ggml-metal-impl.h",
])
```

Also assert that an archive path escaping the extraction directory, a wrong SHA-256, a missing registry guard, a duplicate source, or a missing shader marker raises a hard error.

- [ ] **Step 2: Run the red audit tests**

```bash
python3 -m unittest tools/llamacpp/test_audit_snapshot.py -v
```

Expected before implementation: import/file-not-found failure for `audit_snapshot.py`.

- [ ] **Step 3: Implement the read-only auditor**

The script interface is:

```text
python3 tools/llamacpp/audit_snapshot.py \
  [--upstream DIR | --url URL --sha256 HEX] \
  --tag TAG --commit SHA \
  [--output REPORT | --check REPORT | --compare OLD_REPORT]
```

Implement named, importable functions `sha256_file(path)`,
`safe_extract_tar(archive, destination)`,
`extract_cmake_call(text, callee, first_arg)`,
`collect_snapshot(root, tag, commit, url, archive_sha256)`, and
`compare_reports(old, new)` so the unit tests can exercise each boundary directly.

`extract_cmake_call` must scan balanced parentheses and quoted strings; do not parse CMake with a one-line regex. `collect_snapshot` must sort and deduplicate every path, expand `src/models/*.cpp`, hash `include/llama.h` and GGML public headers, and record:

```json
{
  "schema": 1,
  "upstream": {
    "tag": "b10069",
    "commit": "178a6c44937154dc4c4eff0d166f4a044c4fceba",
    "url": "https://github.com/ggml-org/llama.cpp/archive/refs/tags/b10069.tar.gz",
    "sha256": "293a7c65a11e2203c5468a06d0d0e8d21dfff16ad08712b16c61efbe0d93e097"
  },
  "sources": {"ggml_base": [], "ggml_registry": [], "ggml_cpu_common": [], "ggml_cpu_x86": [], "ggml_cpu_arm": [], "llama_core": [], "models": [], "ggml_metal": []},
  "registry": {"GGML_USE_CPU": "ggml_backend_cpu_reg", "GGML_USE_METAL": "ggml_backend_metal_reg"},
  "metal": {"frameworks": ["Foundation", "Metal", "MetalKit"], "shader_inputs": []},
  "dialect_exceptions": {"c++20": ["src/models/dflash.cpp", "src/models/eagle3.cpp", "src/models/t5.cpp"]},
  "platform_links": {"windows_cpu": ["advapi32"]},
  "public_header_sha256": {}
}
```

The committed report must contain full hashes and complete arrays. `--check` regenerates in memory and exits nonzero on any difference; it never edits a descriptor.

- [ ] **Step 4: Generate and inspect `b10069.json`**

```bash
python3 tools/llamacpp/audit_snapshot.py \
  --upstream /private/tmp/llama.cpp-b10069 \
  --tag b10069 \
  --commit 178a6c44937154dc4c4eff0d166f4a044c4fceba \
  --url https://github.com/ggml-org/llama.cpp/archive/refs/tags/b10069.tar.gz \
  --sha256 293a7c65a11e2203c5468a06d0d0e8d21dfff16ad08712b16c61efbe0d93e097 \
  --output tools/llamacpp/snapshots/b10069.json
python3 -m unittest tools/llamacpp/test_audit_snapshot.py -v
python3 tools/llamacpp/audit_snapshot.py --check tools/llamacpp/snapshots/b10069.json
```

Expected: the report contains 137 explicit model paths, 29 llama core TUs, six Metal TUs, three shader inputs, and the three C++20 exceptions. Review `git diff -- tools/llamacpp/snapshots/b10069.json`; a wildcard is forbidden in every reported source array.

- [ ] **Step 5: Implement atomic GGUF provisioning**

`tests/fetch_llamacpp_model.py --output PATH` uses the frozen URL, byte size,
and SHA at the top of this plan. Implement `sha256_file`, stream download into
`PATH.tmp`, verify size/hash before `os.replace`, reuse an existing valid file,
and delete invalid temporary bytes on failure. It prints the absolute verified
model path and returns nonzero on all network/integrity errors.

Add a self-test mode that creates a local temporary payload, verifies acceptance
with its real size/hash, then verifies size and digest rejection. Run:

```bash
python3 tests/fetch_llamacpp_model.py --self-test
python3 tests/fetch_llamacpp_model.py --output /tmp/stories15M-q4_0.gguf
```

Expected: self-test passes; the real output is exactly 19,077,344 bytes with
SHA `66967fbece6dbe97886593fdbb73589584927e29119ec31f08090732d1861739`.

- [ ] **Step 6: Commit the evidence gate**

```bash
git add tools/llamacpp tests/fetch_llamacpp_model.py
git commit -m "test: freeze llama.cpp b10069 package map"
```

## Task 3: Add `compat.ggml-base`

**Files:**
- Create: `pkgs/c/compat.ggml-base.lua`

- [ ] **Step 1: Write the base descriptor**

Use package identity `namespace = "compat"`, `name = "compat.ggml-base"`, MIT license, and the frozen source URL/SHA as a plain string for `b10069` on Linux, macOS, and Windows. Its `mcpp` body is:

```lua
mcpp = {
    c_standard = "c11",
    language = "c++23",
    import_std = false,
    include_dirs = {
        "*/ggml/include",
        "*/ggml/src",
        "mcpp_generated",
    },
    generated_files = {
        ["mcpp_generated/ggml_cpp.cpp"] = "#include \"ggml.cpp\"\n",
        ["mcpp_generated/ggml_build_info.h"] = [=[
#pragma once
#define GGML_VERSION "b10069"
#define GGML_COMMIT "178a6c44937154dc4c4eff0d166f4a044c4fceba"
]=],
    },
    sources = {
        "*/ggml/src/ggml.c",
        "mcpp_generated/ggml_cpp.cpp",
        "*/ggml/src/ggml-alloc.c",
        "*/ggml/src/ggml-backend.cpp",
        "*/ggml/src/ggml-backend-meta.cpp",
        "*/ggml/src/ggml-opt.cpp",
        "*/ggml/src/ggml-threading.cpp",
        "*/ggml/src/ggml-quants.c",
        "*/ggml/src/gguf.cpp",
    },
    targets = { ["ggml_base"] = { kind = "lib" } },
    cflags = { "-w", "-include", "ggml_build_info.h" },
    cxxflags = { "-w" },
    linux = { ldflags = { "-lpthread", "-lm" } },
    macosx = { ldflags = { "-lpthread", "-lm" } },
    deps = {},
}
```

Do not include registry or backend sources. The wrapper retains both `ggml.c` and `ggml.cpp` without an object-basename collision.

- [ ] **Step 2: Run syntax and grammar checks**

```bash
lua5.4 -e 'assert(loadfile("pkgs/c/compat.ggml-base.lua", "t"))'
mcpp xpkg parse --all-os pkgs/c/compat.ggml-base.lua
```

Expected: descriptor parsing passes and reports the exact nine base source entries.

- [ ] **Step 3: Commit the base package**

```bash
git add pkgs/c/compat.ggml-base.lua
git commit -m "feat: add ggml base package"
```

## Task 4: Add The Mandatory CPU Backend

**Files:**
- Create: `pkgs/c/compat.ggml-cpu.lua`

- [ ] **Step 1: Write the CPU descriptor**

Use the same three-platform `b10069` source entries and this build body:

```lua
mcpp = {
    c_standard = "c11",
    language = "c++23",
    import_std = false,
    include_dirs = {
        "*/ggml/include",
        "*/ggml/src",
        "*/ggml/src/ggml-cpu",
        "mcpp_generated",
    },
    generated_files = {
        ["mcpp_generated/ggml-cpu_cpp.cpp"] = "#include \"ggml-cpu.cpp\"\n",
    },
    sources = {
        "*/ggml/src/ggml-cpu/ggml-cpu.c",
        "mcpp_generated/ggml-cpu_cpp.cpp",
        "*/ggml/src/ggml-cpu/binary-ops.cpp",
        "*/ggml/src/ggml-cpu/hbm.cpp",
        "*/ggml/src/ggml-cpu/ops.cpp",
        "*/ggml/src/ggml-cpu/quants.c",
        "*/ggml/src/ggml-cpu/repack.cpp",
        "*/ggml/src/ggml-cpu/traits.cpp",
        "*/ggml/src/ggml-cpu/unary-ops.cpp",
        "*/ggml/src/ggml-cpu/vec.cpp",
        "*/ggml/src/ggml-cpu/amx/amx.cpp",
        "*/ggml/src/ggml-cpu/amx/mmq.cpp",
    },
    targets = { ["ggml_cpu"] = { kind = "lib" } },
    cflags = { "-w", "-DGGML_USE_CPU_REPACK" },
    cxxflags = { "-w", "-DGGML_USE_CPU_REPACK" },
    features = {
        ["default"] = { implies = { "llamafile" } },
        ["llamafile"] = {
            sources = { "*/ggml/src/ggml-cpu/llamafile/sgemm.cpp" },
            flags = {
                {
                    glob = "*/ggml/src/ggml-cpu/**",
                    defines = { "GGML_USE_LLAMAFILE" },
                },
                {
                    glob = "mcpp_generated/ggml-cpu_cpp.cpp",
                    defines = { "GGML_USE_LLAMAFILE" },
                },
            },
        },
    },
    deps = { ["compat.ggml-base"] = "b10069" },
    linux = {
        sources = {
            "*/ggml/src/ggml-cpu/arch/x86/quants.c",
            "*/ggml/src/ggml-cpu/arch/x86/repack.cpp",
        },
        cflags = { "-D_GNU_SOURCE" },
        cxxflags = { "-D_GNU_SOURCE" },
    },
    macosx = {
        sources = {
            "*/ggml/src/ggml-cpu/arch/arm/quants.c",
            "*/ggml/src/ggml-cpu/arch/arm/repack.cpp",
        },
        cflags = { "-D_DARWIN_C_SOURCE" },
        cxxflags = { "-D_DARWIN_C_SOURCE" },
    },
    windows = {
        sources = {
            "*/ggml/src/ggml-cpu/arch/x86/quants.c",
            "*/ggml/src/ggml-cpu/arch/x86/repack.cpp",
        },
        cflags = { "-D_CRT_SECURE_NO_WARNINGS", "-DWIN32_LEAN_AND_MEAN" },
        cxxflags = { "-D_CRT_SECURE_NO_WARNINGS", "-DWIN32_LEAN_AND_MEAN" },
        ldflags = { "-ladvapi32" },
    },
}
```

Do not carry the prototype's unconditional `cpu-feats.cpp`: upstream uses it for dynamic/all-variant probing, while this package is the single static CPU backend. The curated reproducible profile is native ISA flags off, OpenMP off, Accelerate off, CPU repack on, and llamafile on by default. `GGML_USE_LLAMAFILE` is a private per-glob define and must not propagate to core/module consumers. Do not advertise `ggml.accelerator`; CPU is mandatory, not an interchangeable accelerator.

- [ ] **Step 2: Parse and check the CPU ownership**

```bash
lua5.4 -e 'assert(loadfile("pkgs/c/compat.ggml-cpu.lua", "t"))'
mcpp xpkg parse --all-os pkgs/c/compat.ggml-cpu.lua
```

Expected: x86 sources appear only on Linux/Windows, ARM sources only on macOS, `llamafile` is default, and the exact base dependency is present.

- [ ] **Step 3: Commit the CPU package**

```bash
git add pkgs/c/compat.ggml-cpu.lua
git commit -m "feat: add mandatory ggml cpu backend"
```

## Task 5: Replace The Core Prototype

**Files:**
- Modify: `pkgs/c/compat.llamacpp.lua`
- Delete: `tests/examples/llamacpp/`
- Create: `tests/examples/llamacpp-internal-cpu/mcpp.toml`
- Create: `tests/examples/llamacpp-internal-cpu/tests/decode.cpp`
- Modify: `mcpp.toml`

- [ ] **Step 1: Write a failing internal graph consumer**

Create a workspace member named `llamacpp-internal-cpu`. Its manifest uses only the compat redirect and exact internal dependency:

```toml
[package]
name = "llamacpp-internal-cpu-tests"
version = "0.1.0"

[indices]
compat = { path = "../../.." }

[dependencies.compat]
llamacpp = "b10069"
```

`tests/decode.cpp` is explicitly an implementation test and may include `<llama.h>`. It must fail when `LLAMACPP_TEST_MODEL` is absent/unreadable, call `llama_backend_init`, load with `n_gpu_layers = 0`, create a 64-token context, decode `{1, 2, 3}`, sample once, validate the token range, and release sampler/context/model/backend on every return path.

Replace the `tests/examples/llamacpp` member in root `mcpp.toml` with `tests/examples/llamacpp-internal-cpu`, then run:

```bash
mcpp test -p llamacpp-internal-cpu --no-cache
```

Expected before replacing the descriptor: failure is acceptable but must be attributable to the old monolithic graph or the deliberately required model, never a success-through-skip.

- [ ] **Step 2: Replace `compat.llamacpp` with the registry/llama owner**

Keep the exact package identity and three-platform source URL/SHA, but replace the old `mcpp` body. It must contain:

```lua
mcpp = {
    c_standard = "c11",
    language = "c++23",
    import_std = false,
    include_dirs = {
        "*/include",
        "*/ggml/include",
        "*/ggml/src",
        "*/ggml/src/ggml-cpu",
        "*/src",
    },
    sources = {
        "*/ggml/src/ggml-backend-dl.cpp",
        "*/ggml/src/ggml-backend-reg.cpp",
        "*/src/llama.cpp",
        "*/src/llama-adapter.cpp",
        "*/src/llama-arch.cpp",
        "*/src/llama-batch.cpp",
        "*/src/llama-chat.cpp",
        "*/src/llama-context.cpp",
        "*/src/llama-cparams.cpp",
        "*/src/llama-grammar.cpp",
        "*/src/llama-graph.cpp",
        "*/src/llama-hparams.cpp",
        "*/src/llama-impl.cpp",
        "*/src/llama-io.cpp",
        "*/src/llama-kv-cache.cpp",
        "*/src/llama-kv-cache-iswa.cpp",
        "*/src/llama-kv-cache-dsa.cpp",
        "*/src/llama-kv-cache-dsv4.cpp",
        "*/src/llama-memory.cpp",
        "*/src/llama-memory-hybrid.cpp",
        "*/src/llama-memory-hybrid-iswa.cpp",
        "*/src/llama-memory-recurrent.cpp",
        "*/src/llama-mmap.cpp",
        "*/src/llama-model-loader.cpp",
        "*/src/llama-model-saver.cpp",
        "*/src/llama-model.cpp",
        "*/src/llama-quant.cpp",
        "*/src/llama-sampler.cpp",
        "*/src/llama-vocab.cpp",
        "*/src/unicode-data.cpp",
        "*/src/unicode.cpp",
    },
    targets = { ["llama"] = { kind = "lib" } },
    cflags = { "-w" },
    cxxflags = { "-w" },
    flags = {
        { glob = "*/ggml/src/ggml-backend-reg.cpp", defines = { "GGML_USE_CPU" } },
        { glob = "*/src/models/t5.cpp", cxxflags = { "-std=c++20" } },
        { glob = "*/src/models/eagle3.cpp", cxxflags = { "-std=c++20" } },
        { glob = "*/src/models/dflash.cpp", cxxflags = { "-std=c++20" } },
    },
    deps = {
        ["compat.ggml-base"] = "b10069",
        ["compat.ggml-cpu"] = "b10069",
    },
    linux = { ldflags = { "-ldl" } },
}
```

Append every `sources.models` entry from `tools/llamacpp/snapshots/b10069.json` to the Lua `sources` array as `"*/src/models/<name>.cpp"`. Generate the review aid with:

```bash
python3 -c 'import json,sys; d=json.load(open(sys.argv[1])); print("\n".join(f"        \"*/{p}\"," for p in d["sources"]["models"]))' \
  tools/llamacpp/snapshots/b10069.json > /tmp/llamacpp-model-sources.lua
wc -l /tmp/llamacpp-model-sources.lua
```

Expected: exactly `137` lines. Paste and review the complete result; do not introduce `src/models/*.cpp`.

- [ ] **Step 3: Remove the prototype consumer files**

Delete all ten files under `tests/examples/llamacpp/`. No public test or documentation may retain `mcpp add compat.llamacpp`, `features = ["metal"]`, runtime `default.metallib`, or `GGML_METAL_PATH_RESOURCES` instructions.

- [ ] **Step 4: Run the internal CPU smoke with the pinned model**

```bash
python3 tests/fetch_llamacpp_model.py --output /tmp/stories15M-q4_0.gguf
LLAMACPP_TEST_MODEL=/tmp/stories15M-q4_0.gguf \
  mcpp test -p llamacpp-internal-cpu --no-cache
```

Expected on the current macOS host: model load, one decode, and valid sample pass. Linux and Windows remain required CI evidence, including the `advapi32` link.

- [ ] **Step 5: Commit the CPU split**

```bash
git add pkgs/c/compat.llamacpp.lua tests/examples/llamacpp-internal-cpu mcpp.toml
git add -u tests/examples/llamacpp
git commit -m "refactor: split llama cpu implementation packages"
```

## Task 6: Add The Metal Provider And Registry Binding

**Files:**
- Create: `pkgs/c/compat.ggml-metal.lua`
- Modify: `pkgs/c/compat.llamacpp.lua`
- Modify: `tools/llamacpp/test_audit_snapshot.py`
- Create: `tests/check_llamacpp_snapshot.py`

- [ ] **Step 1: Add red graph and build-program contracts**

`tests/check_llamacpp_snapshot.py` loads the committed report and invokes
`lua5.4` to load each pure descriptor table. The Lua subprocess emits
tab-separated scalar/list rows; Python compares structured rows rather than
scraping Lua source text. Assert all of these invariants:

1. every internal package uses the exact tag, URL, and SHA from the report;
2. base/CPU/core versions exist on Linux, macOS, and Windows; Metal exists only on macOS;
3. every internal dependency is exactly `b10069` and the graph has no cycle;
4. each compiled upstream TU has exactly one owner, except headers copied in each source archive;
5. `compat.llamacpp` contains no `src/models/*.cpp` glob and lists the report's 137 models exactly;
6. only `compat.llamacpp` owns registry TUs and only its registry glob gets `GGML_USE_CPU`/`GGML_USE_METAL`;
7. only `compat.ggml-metal` provides `ggml.accelerator` and its generated `build.mcpp` contains all three rerun inputs;
8. `backend-metal` is absent from Linux/Windows synthesis and present in the macOS overlay with exact provider dependency plus capability requirement.
9. CPU repack is a private base flag, llamafile is default-on with private feature-scoped flags, and neither implementation macro appears as an interface define.

Before the provider exists, the checker must fail specifically on the missing
Metal descriptor rather than accepting the monolithic prototype shape.

Extend the Python tests to extract the descriptor's generated `build.mcpp`, compile it with the host C++ compiler, and run it with a temporary `MCPP_MANIFEST_DIR`/`MCPP_OUT_DIR`. Assert:

- `MCPP_TARGET_OS=linux`, `MCPP_TARGET_ARCH=x86_64` fails with `requires target_os=macos`;
- `MCPP_TARGET_OS=macos`, `MCPP_TARGET_ARCH=x86_64` fails with `requires target_arch=aarch64`;
- macOS/aarch64 plus all three inputs emits one `mcpp:generated=<absolute-out>/ggml-metal-embed.s`, one `mcpp:cfg=GGML_METAL_EMBED_LIBRARY`, and three `mcpp:rerun-if-changed=` directives;
- the merged Metal output contains each input exactly once and the assembly contains `_ggml_metallib_start`, `.incbin`, and `_ggml_metallib_end`.

Expected before the provider exists: missing descriptor/build program failure.

- [ ] **Step 2: Write the macOS-only provider descriptor**

`compat.ggml-metal` has only `xpm.macosx.b10069`, depends exactly on `compat.ggml-base@b10069`, and uses:

```lua
mcpp = {
    c_standard = "c11",
    language = "c++23",
    import_std = false,
    include_dirs = {
        "*/ggml/include",
        "*/ggml/src",
        "*/ggml/src/ggml-metal",
        "mcpp_generated",
    },
    generated_files = {
        ["mcpp_generated/ggml_metal_device_m.m"] = "#include \"ggml-metal-device.m\"\n",
    },
    sources = {
        "*/ggml/src/ggml-metal/ggml-metal.cpp",
        "mcpp_generated/ggml_metal_device_m.m",
        "*/ggml/src/ggml-metal/ggml-metal-device.cpp",
        "*/ggml/src/ggml-metal/ggml-metal-common.cpp",
        "*/ggml/src/ggml-metal/ggml-metal-context.m",
        "*/ggml/src/ggml-metal/ggml-metal-ops.cpp",
    },
    targets = { ["ggml_metal"] = { kind = "lib" } },
    flags = {
        { glob = "mcpp_generated/ggml_metal_device_m.m", cflags = { "-fno-objc-arc" } },
        { glob = "*/ggml/src/ggml-metal/ggml-metal-context.m", cflags = { "-fno-objc-arc" } },
        { glob = "*/ggml/src/ggml-metal/ggml-metal.cpp", cxxflags = { "-include", "memory" } },
    },
    ldflags = {
        "-framework", "Foundation",
        "-framework", "Metal",
        "-framework", "MetalKit",
    },
    provides = { "ggml.accelerator" },
    deps = { ["compat.ggml-base"] = "b10069" },
}
```

This is the red descriptor shape before the generator is added. Step 3 adds
`generated_files["build.mcpp"]` with the complete program shown there; do not
commit or test the provider between these two steps.

- [ ] **Step 3: Embed the complete dependency `build.mcpp`**

Use only the C++ standard library and the mcpp stdout protocol. The program must implement this exact control flow:

```cpp
#include <algorithm>
#include <cstdio>
#include <cstdlib>
#include <filesystem>
#include <fstream>
#include <iterator>
#include <sstream>
#include <stdexcept>
#include <string>

namespace fs = std::filesystem;

static std::string read_all(const fs::path & path) {
    std::ifstream in(path, std::ios::binary);
    if (!in) throw std::runtime_error("cannot read " + path.string());
    return {std::istreambuf_iterator<char>(in), std::istreambuf_iterator<char>()};
}

static void write_all(const fs::path & path, const std::string & value) {
    fs::create_directories(path.parent_path());
    std::ofstream out(path, std::ios::binary | std::ios::trunc);
    out.write(value.data(), static_cast<std::streamsize>(value.size()));
    if (!out) throw std::runtime_error("cannot write " + path.string());
}

static void replace_once(std::string & value, const std::string & marker,
                         const std::string & replacement) {
    const auto first = value.find(marker);
    if (first == std::string::npos || value.find(marker, first + marker.size()) != std::string::npos) {
        throw std::runtime_error("expected exactly one marker: " + marker);
    }
    value.replace(first, marker.size(), replacement);
}

static std::string asm_quote(std::string value) {
    std::string out;
    for (char c : value) {
        if (c == '\\' || c == '"') out.push_back('\\');
        out.push_back(c);
    }
    return out;
}

int main() try {
    const char * os = std::getenv("MCPP_TARGET_OS");
    const char * arch = std::getenv("MCPP_TARGET_ARCH");
    const char * manifest = std::getenv("MCPP_MANIFEST_DIR");
    const char * out_env = std::getenv("MCPP_OUT_DIR");
    if (!os || std::string(os) != "macos") {
        std::fprintf(stderr, "compat.ggml-metal requires target_os=macos\n");
        return 2;
    }
    if (!arch || std::string(arch) != "aarch64") {
        std::fprintf(stderr, "compat.ggml-metal requires target_arch=aarch64\n");
        return 2;
    }
    if (!manifest || !out_env) {
        std::fprintf(stderr, "compat.ggml-metal requires MCPP_MANIFEST_DIR and MCPP_OUT_DIR\n");
        return 2;
    }

    fs::path root;
    for (const auto & entry : fs::directory_iterator(manifest)) {
        const fs::path candidate = entry.path();
        if (entry.is_directory() && fs::exists(candidate / "ggml/src/ggml-common.h") &&
            fs::exists(candidate / "ggml/src/ggml-metal/ggml-metal.metal")) {
            if (!root.empty()) throw std::runtime_error("multiple llama.cpp source roots");
            root = candidate;
        }
    }
    if (root.empty()) throw std::runtime_error("llama.cpp source root not found");

    const fs::path common = root / "ggml/src/ggml-common.h";
    const fs::path metal = root / "ggml/src/ggml-metal/ggml-metal.metal";
    const fs::path impl = root / "ggml/src/ggml-metal/ggml-metal-impl.h";
    const fs::path out = out_env;
    const fs::path merged = out / "ggml-metal-embed.metal";
    const fs::path assembly = out / "ggml-metal-embed.s";

    std::string source = read_all(metal);
    replace_once(source, "__embed_ggml-common.h__", read_all(common));
    replace_once(source, "#include \"ggml-metal-impl.h\"", read_all(impl));
    write_all(merged, source);

    std::ostringstream body;
    body << ".section __DATA,__ggml_metallib\n"
         << ".globl _ggml_metallib_start\n"
         << "_ggml_metallib_start:\n"
         << ".incbin \"" << asm_quote(merged.string()) << "\"\n"
         << ".globl _ggml_metallib_end\n"
         << "_ggml_metallib_end:\n";
    write_all(assembly, body.str());

    std::printf("mcpp:generated=%s\n", assembly.string().c_str());
    std::printf("mcpp:cfg=GGML_METAL_EMBED_LIBRARY\n");
    for (const fs::path & input : {common, metal, impl}) {
        std::printf("mcpp:rerun-if-changed=%s\n", input.string().c_str());
    }
    std::fflush(stdout);
    return 0;
} catch (const std::exception & error) {
    std::fprintf(stderr, "compat.ggml-metal build.mcpp: %s\n", error.what());
    return 1;
}
```

Do not invoke `sed`, `xcrun`, a shell, or write into the immutable package root.

- [ ] **Step 4: Add the macOS-only core feature**

Add this under `mcpp.macosx`, not the common body:

```lua
macosx = {
    features = {
        ["backend-metal"] = {
            deps = { ["compat.ggml-metal"] = "b10069" },
            requires = { "ggml.accelerator" },
            flags = {
                {
                    glob = "*/ggml/src/ggml-backend-reg.cpp",
                    defines = { "GGML_USE_METAL" },
                },
            },
        },
    },
}
```

Do not put `GGML_USE_METAL` on the provider package. Linux/Windows must synthesize no `backend-metal` feature; the released mcpp hard-error rule turns a forwarded request into a configuration error before CPU-only output is accepted.

- [ ] **Step 5: Run provider contracts**

```bash
python3 -m unittest tools/llamacpp/test_audit_snapshot.py -v
lua5.4 -e 'assert(loadfile("pkgs/c/compat.ggml-metal.lua", "t"))'
mcpp xpkg parse --all-os pkgs/c/compat.ggml-metal.lua
mcpp xpkg parse --all-os pkgs/c/compat.llamacpp.lua
python3 tests/check_llamacpp_snapshot.py
```

Expected: all checks pass; the report/checker shows one accelerator provider, exact cohort edges, and registry-only Metal define ownership.

- [ ] **Step 6: Commit Metal as one graph change**

```bash
git add pkgs/c/compat.ggml-metal.lua pkgs/c/compat.llamacpp.lua \
  tools/llamacpp/test_audit_snapshot.py tests/check_llamacpp_snapshot.py
git commit -m "feat: add ggml metal provider"
```

## Task 7: Admit The Public Form A Package

**Files:**
- Create: `pkgs/l/llamacpp.lua`
- Create: `tests/examples/llamacpp-module-cpu/mcpp.toml`
- Create: `tests/examples/llamacpp-module-cpu/tests/decode.cpp`
- Create: `tests/examples/llamacpp-module-metal/mcpp.toml`
- Create: `tests/examples/llamacpp-module-metal/tests/metal_decode.cpp`
- Modify: `mcpp.toml`

- [ ] **Step 1: Verify the authorized `llamacpp-m` release bytes**

Do not create the descriptor from an untagged branch. After the complete staging graph passes and `v0.1.0` is authorized:

```bash
curl -L -fsS -o /tmp/llamacpp-m-0.1.0.tar.gz \
  https://github.com/mcpplibs/llamacpp-m/archive/refs/tags/v0.1.0.tar.gz
shasum -a 256 /tmp/llamacpp-m-0.1.0.tar.gz
tar -tzf /tmp/llamacpp-m-0.1.0.tar.gz | rg '/mcpp.toml$|/src/llama.cppm$|/UPSTREAM.md$'
```

Download twice and compare hashes. Inspect the archived `mcpp.toml`: package version is `0.1.0`, exact dependency is `compat.llamacpp = "b10069"`, default/CPU/Metal features match the module child plan, and the only module is `llama`.

- [ ] **Step 2: Add the public Form A descriptor**

Create `pkgs/l/llamacpp.lua` with `namespace = ""`, `name = "llamacpp"`, MIT license for the facade, repository `https://github.com/mcpplibs/llamacpp-m`, and no `mcpp` field. Declare `0.1.0` on Linux, macOS, and Windows with the exact verified archive SHA and this plain URL:

```text
https://github.com/mcpplibs/llamacpp-m/archive/refs/tags/v0.1.0.tar.gz
```

The SHA value must be the output of Step 1; do not reuse a GitHub API digest.

- [ ] **Step 3: Add the import-only CPU consumer**

Use two local redirects because the public descriptor and its transitive compat dependency must both resolve from this checkout:

```toml
[package]
name = "llamacpp-module-cpu-tests"
version = "0.1.0"

[indices]
default = { path = "../../.." }
compat = { path = "../../.." }

[dependencies]
llamacpp = "0.1.0"
```

`tests/decode.cpp` starts with only:

```cpp
import std;
import llama;
```

It must fail loudly without `LLAMACPP_TEST_MODEL`, load with `n_gpu_layers = 0`, decode `{1, 2, 3}`, sample once, validate vocabulary bounds, and clean up. It must contain no `#include`, `compat.*`, GGML name, platform branch, or skip path. A separate manifest rewrite in the backend contract tests `backend = "cpu"`; this member covers the omitted/default spelling.

- [ ] **Step 4: Add the import-only Metal consumer**

Use the same two redirects and gate the dependency to the supported target:

```toml
[package]
name = "llamacpp-module-metal-tests"
version = "0.1.0"

[indices]
default = { path = "../../.." }
compat = { path = "../../.." }

[target.'cfg(all(macos, arch = "aarch64"))'.dependencies]
llamacpp = { version = "0.1.0", backend = "metal" }
```

On macOS ARM64, `metal_decode.cpp` starts with `import std; import llama;`, installs a `llama_log_set` callback, requires `llama_supports_gpu_offload()`, loads with `n_gpu_layers = 99`, completes one decode, and asserts logs contain both `using embedded metal library` and a positive `offloaded N/M layers to GPU`. A successful model/context/decode also proves the mandatory CPU path is present; do not import GGML APIs to inspect it. On other targets the file compiles a no-op `main` without importing `llama`.

- [ ] **Step 5: Register the focused members**

Add these members to root `mcpp.toml`:

```toml
"tests/examples/llamacpp-internal-cpu",
"tests/examples/llamacpp-module-cpu",
"tests/examples/llamacpp-module-metal",
```

Before running expensive builds, verify the two-redirect path can resolve both package identities from the checkout:

```bash
mcpp build -p llamacpp-module-cpu --no-cache
find tests/examples/llamacpp-module-cpu -name mcpp.lock -print -exec \
  rg -n 'llamacpp|compat\.llamacpp' {} \;
```

Expected: the lockfile records the local default and compat indices; no released GLOBAL `compat.llamacpp` is silently selected.

- [ ] **Step 6: Run public consumers**

```bash
LLAMACPP_TEST_MODEL=/tmp/stories15M-q4_0.gguf \
  mcpp test -p llamacpp-module-cpu --no-cache
LLAMACPP_TEST_MODEL=/tmp/stories15M-q4_0.gguf \
  mcpp test -p llamacpp-module-metal --no-cache
```

Expected on macOS ARM64: both pass, Metal logs prove embedded source and positive offload, and no runtime shader file/environment variable is present. On Linux/Windows, CPU passes and the Metal member is an intentional no-op; unsupported selection is covered separately.

- [ ] **Step 7: Commit the public contract**

```bash
git add pkgs/l/llamacpp.lua tests/examples/llamacpp-module-cpu \
  tests/examples/llamacpp-module-metal mcpp.toml
git commit -m "feat: add llama module package"
```

## Task 8: Make Backend Failure Contracts Mandatory

**Files:**
- Create: `tests/llamacpp_backend_contract.sh`

- [ ] **Step 1: Implement backend selection cases**

`tests/llamacpp_backend_contract.sh` creates a temporary import-only consumer with both local index redirects and rewrites only this dependency line between cases:

```toml
llamacpp = { version = "0.1.0", backend = "cpu" }
```

Run and assert:

| Case | Platforms | Expected result |
|---|---|---|
| explicit `cpu` | all | build succeeds |
| `cuda` | all | failure naming unsupported backend `cuda` |
| `metla` | all | failure naming unsupported backend `metla` |
| `metal` | Linux/Windows | failure naming `compat.llamacpp`/backend `metal`, with no successful CPU binary |
| `metal` | macOS ARM64 | build succeeds; runtime proof remains in the Metal member |

After every expected failure, assert no executable exists under the temporary `target/` tree.

- [ ] **Step 2: Exercise provider and cohort failures on macOS**

For each case, copy the index to a temporary directory and use a Python exact-string replacement that asserts replacement count `1`:

1. remove the `compat.ggml-metal` feature dependency while keeping `requires = { "ggml.accelerator" }`; expect the capability resolver to report no provider;
2. change only that dependency version from `b10069` to nonexistent `b10070`; expect dependency resolution to fail before compilation.

Point both local redirects at the mutated copy. Never edit the working descriptor in place. Do not fabricate a second accelerator for the first release; ambiguity/one-of coverage begins when a second real provider is designed.

- [ ] **Step 3: Lock the current macOS x86-64 limitation honestly**

Current mcpp marks `x86_64-macos` as a planned target, so it cannot yet provide a trustworthy end-to-end cross build. Keep the direct `build.mcpp` unit case from Task 6 as the release gate: `MCPP_TARGET_OS=macos` plus `MCPP_TARGET_ARCH=x86_64` must fail with the provider's architecture message. Add a native E2E case when mcpp promotes that target from planned to supported.

- [ ] **Step 4: Commit mandatory failure coverage**

```bash
git add tests/llamacpp_backend_contract.sh
git commit -m "test: cover llama backend failure contracts"
```

## Task 9: Raise The Floor And Add Release Admission

**Files:**
- Modify: `index.toml`
- Modify: `.github/workflows/validate.yml`
- Modify: `README.md`

- [ ] **Step 1: Verify the released mcpp prerequisite**

Resolve the concrete version from the merged mcpp release and save it in
`MCPP_RELEASE`. On the frozen baseline the expected tag is `v0.0.102`; if that
number was consumed, use the later tag that actually contains the backend hard
error. Verify its Linux/macOS/Windows archives and rerun
`67_features_strict.sh` with its binary. Only then set both `index.toml` values,
workflow `MCPP_VERSION`, and every matrix `mcpp_version` to the exact value of
`$MCPP_RELEASE`; shell variables must not be written literally into TOML/YAML.
Verify no old pin remains:

```bash
rg -n '0\.0\.101|MCPP_VERSION|mcpp_version|min_mcpp|latest_mcpp' \
  index.toml .github/workflows/validate.yml
```

- [ ] **Step 2: Run snapshot and descriptor gates in lint**

After Lua installation and pinned mcpp download, add:

```bash
python3 -m unittest tools/llamacpp/test_audit_snapshot.py -v
python3 tools/llamacpp/audit_snapshot.py --check tools/llamacpp/snapshots/b10069.json
python3 tests/check_llamacpp_snapshot.py
for f in pkgs/c/compat.ggml-base.lua pkgs/c/compat.ggml-cpu.lua \
         pkgs/c/compat.llamacpp.lua pkgs/c/compat.ggml-metal.lua \
         pkgs/l/llamacpp.lua; do
  "$MCPP" xpkg parse --all-os "$f"
done
```

Expected: every descriptor parses for all OS overlays and the snapshot checker passes.

- [ ] **Step 3: Provision the model only for affected llama members**

After member selection, when `MEMBERS=__ALL__` or contains a llama member, run:

```bash
model="$RUNNER_TEMP/stories15M-q4_0.gguf"
python3 tests/fetch_llamacpp_model.py --output "$model"
echo "LLAMACPP_TEST_MODEL=$model" >> "$GITHUB_ENV"
```

Then run `bash tests/llamacpp_backend_contract.sh` on all three native runners. Model download or checksum failure fails the job; required tests never print `SKIP`.

- [ ] **Step 4: Add targeted cold package-cache verification**

For llama changes, create a temporary `MCPP_HOME`, copy the workflow-pinned
registry/toolchain state into it, then remove only store entries whose basename
contains `llama` or `ggml`. Do not delete the shared toolchain/runtime roots.
Run:

```bash
cold="$RUNNER_TEMP/llamacpp-mcpp-home"
mkdir -p "$cold"
cp -a "$HOME/.mcpp/registry" "$cold/registry"
find "$cold/registry/data/xpkgs" -mindepth 1 -maxdepth 1 \
  \( -iname '*llama*' -o -iname '*ggml*' \) -exec rm -rf {} +
MCPP_HOME="$RUNNER_TEMP/llamacpp-mcpp-home" \
MCPP_INDEX_MIRROR=GLOBAL \
LLAMACPP_TEST_MODEL="$LLAMACPP_TEST_MODEL" \
  "$MCPP" test -p llamacpp-module-cpu --no-cache
```

On macOS ARM64 also run the Metal member from the same cold package state. On Windows use the existing bash runner and normalized `$MCPP`; do not claim a Windows pass from Linux cross compilation. Preserve logs showing archive fetch, descriptor resolution, compile/link, model load, and decode/offload assertions.

Extend `on.pull_request.paths` with `index.toml` and `tools/llamacpp/**`, so a
future floor or snapshot-tool-only change cannot bypass validation. The existing
member selector's `tools/*` arm continues to request a full run.

- [ ] **Step 5: Update public documentation**

Add `llamacpp` to the Form A module list with exactly this consumer surface:

```toml
[dependencies]
llamacpp = "0.1.0"
# or: llamacpp = { version = "0.1.0", backend = "metal" } # macOS ARM64
```

```cpp
import llama;
```

Do not document `compat.*`, `#include <llama.h>`, Metal resource files, CUDA, or simultaneous accelerator selection.

- [ ] **Step 6: Run the complete local admission set**

```bash
python3 -m unittest tools/llamacpp/test_audit_snapshot.py -v
python3 tools/llamacpp/audit_snapshot.py --check tools/llamacpp/snapshots/b10069.json
python3 tests/check_llamacpp_snapshot.py
python3 tests/fetch_llamacpp_model.py --self-test
for f in pkgs/c/compat.ggml-base.lua pkgs/c/compat.ggml-cpu.lua \
         pkgs/c/compat.llamacpp.lua pkgs/c/compat.ggml-metal.lua \
         pkgs/l/llamacpp.lua; do
  lua5.4 -e "assert(loadfile('$f', 't'))"
  mcpp xpkg parse --all-os "$f"
done
bash tests/llamacpp_backend_contract.sh
LLAMACPP_TEST_MODEL=/tmp/stories15M-q4_0.gguf mcpp test -p llamacpp-internal-cpu --no-cache
LLAMACPP_TEST_MODEL=/tmp/stories15M-q4_0.gguf mcpp test -p llamacpp-module-cpu --no-cache
LLAMACPP_TEST_MODEL=/tmp/stories15M-q4_0.gguf mcpp test -p llamacpp-module-metal --no-cache
git diff --check origin/main...HEAD
```

Expected on macOS ARM64: all commands exit `0`, negative cases fail internally for the asserted reason, CPU decodes, and Metal reports embedded shader use plus positive offload. Other platforms are accepted only from their native CI legs.

- [ ] **Step 7: Commit floor, CI, and docs together**

```bash
git add index.toml .github/workflows/validate.yml README.md
git commit -m "ci: admit llama module provider packages"
```

## Task 10: PR Boundary And Future Upstream Updates

**Files:**
- Inspect: complete implementation diff/history
- Future reports: `tools/llamacpp/snapshots/<tag>.json`

- [ ] **Step 1: Audit the upstream-facing branch**

```bash
git fetch origin main
git rebase origin/main
git diff --stat origin/main...HEAD
git diff --check origin/main...HEAD
git log --oneline origin/main..HEAD
git ls-files | rg '^\.agents/docs/2026-07-21-llamacpp'
```

Expected: implementation/tests/tools/README only; the final command prints nothing. Re-run the focused and required workflow-equivalent tests after rebase.

- [ ] **Step 2: Stop before external actions**

Pushing the branch, creating/uploading a CN mirror, tagging `llamacpp-m`, or opening a PR requires explicit authorization at that point. Never push to upstream `main`; maintainers merge after all required checks pass.

- [ ] **Step 3: Audit every future llama.cpp candidate before editing recipes**

For a candidate tag, verify its Git tag/commit and archive bytes, then run:

```bash
python3 tools/llamacpp/audit_snapshot.py \
  --url "https://github.com/ggml-org/llama.cpp/archive/refs/tags/${TAG}.tar.gz" \
  --sha256 "$ARCHIVE_SHA256" --tag "$TAG" --commit "$COMMIT" \
  --output "/tmp/${TAG}.json" \
  --compare tools/llamacpp/snapshots/b10069.json
```

Review API/header hashes, `GGML_BACKEND_API_VERSION`, every source-set delta, registry guards/calls, platform libraries, Metal inputs, and dialect exceptions. The tool reports only; a human updates all internal packages, generated module exports, tests, and version mapping together.

- [ ] **Step 4: Enforce the current versioned-recipe limitation**

As of mcpp `0.0.101`, an xpkg descriptor has one package-level `mcpp` body and one package-level dependency map for every listed xpm version. It cannot express “`compat.llamacpp@b10069` depends on `compat.ggml-base@b10069`, while `@b10120` depends on `@b10120`” when both versions remain in one descriptor.

Therefore the first release may contain only the `b10069` internal cohort. Before admitting a second internal snapshot, land and release one of these in a separately approved design:

1. version-scoped xpkg `mcpp`/dependency overlays, preferred because package identities remain stable; or
2. snapshot-qualified internal package identities, with the public Form A release depending on the correct cohort.

Do not append a second `xpm` version while silently changing the shared dependency map or source recipe; that would make fresh resolution of the historical cohort ABI-incoherent. Public `llamacpp` SemVer history remains append-only, but historical internal rollback is not claimed until this gate is solved.

- [ ] **Step 5: Apply public version rules after the gate**

When the cohort mechanism exists and the full supported matrix passes atomically:

- implementation/performance-only update with unchanged exported module API: patch;
- additive exported API or a newly supported backend: minor;
- removed/changed exported API: major.

Update `UPSTREAM.md`, the public descriptor, all internal cohort entries, the snapshot report, model/provider tests, and mirror records in one release train. If any supported platform/backend is red, publish none of the new cohort.
