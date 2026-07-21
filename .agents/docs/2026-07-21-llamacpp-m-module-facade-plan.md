# llamacpp-m Module Facade Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create the Form A `llamacpp-m` package that exposes llama.cpp `b10069` only as `import llama;` and forwards the selected accelerator to the internal implementation package.

**Architecture:** The module's global module fragment includes upstream `llama.h`; generated `export using` declarations re-export reviewed names without attaching the C implementation to the named module. Public macro constants become typed C++ constants, while deprecated functions, `llama-cpp.h`, and unrelated GGML API remain outside the module.

**Tech Stack:** C++23 modules, mcpp manifest features/forwarding, Clang JSON AST, Python 3 export generation, Bash/Python fixture tooling, GitHub Actions.

---

## File Map

| File | Responsibility |
|---|---|
| `mcpp.toml` | Form A package metadata, exact internal dependency, public backend features, module target, dev dependency. |
| `src/llama.cppm` | Public `llama` module and typed macro replacements. |
| `src/gen_exports/llama.inc` | Generated llama types, enum values, callbacks, structs, and non-deprecated `LLAMA_API` functions. |
| `src/gen_exports/required_ggml.inc` | Only GGML types/enumerators required to spell llama public signatures. |
| `src/gen_exports/llama.skipped.txt` | Deprecated declarations, macros, inline/header-only surfaces, and rejected names for review. |
| `tools/upstream.lock` | Tag, commit, source URL, source SHA-256, and module version mapping. |
| `tools/fetch_upstream.sh` | Fetch and verify the exact llama.cpp archive. |
| `tools/gen_exports.py` | Deterministically regenerate the three API review artifacts. |
| `tools/test_with_local_index.py` | Test an unmodified release manifest against a checked-out staging mcpp-index. |
| `tests/api_surface.cpp` | Compile/runtime proof for imports, types, enums, constants, and no macro leakage. |
| `tests/decode.cpp` | Required model load, context creation, decode, and sampler proof. |
| `.github/workflows/ci.yml` | Linux/macOS/Windows tests against the staging index. |
| `.github/workflows/release.yml` | Tagged-commit verification and GitHub release creation. |
| `UPSTREAM.md` | Public module version to llama.cpp snapshot/backend mapping. |

## Task 1: Create The Local Repository Skeleton

**Files:**
- Create: `LICENSE`
- Create: `.gitignore`
- Create: `mcpp.toml`
- Create: `UPSTREAM.md`

- [ ] **Step 1: Initialize locally without creating a remote**

```bash
mkdir -p /Users/cltx/projects/mcpp/llamacpp-m
git init -b main /Users/cltx/projects/mcpp/llamacpp-m
mkdir -p /Users/cltx/projects/mcpp/llamacpp-m/src/gen_exports
mkdir -p /Users/cltx/projects/mcpp/llamacpp-m/tests
mkdir -p /Users/cltx/projects/mcpp/llamacpp-m/tools
mkdir -p /Users/cltx/projects/mcpp/llamacpp-m/.github/workflows
```

Expected: a local-only repository exists; no GitHub repository, tag, release, or push has occurred.

- [ ] **Step 2: Write the public manifest**

Create `mcpp.toml`:

```toml
[package]
name        = "llamacpp"
version     = "0.1.0"
description = "C++23 module facade for llama.cpp (import llama;)"
license     = "MIT"
repo        = "https://github.com/mcpplibs/llamacpp-m"
platforms   = ["linux", "macos", "windows"]

[targets.llama]
kind = "lib"

[build]
sources = ["src/llama.cppm"]

[dependencies]
compat.llamacpp = "b10069"

[dev-dependencies]
compat.gtest = "1.15.2"

[features]
default       = ["backend-cpu"]
backend-cpu   = []
backend-metal = { forward = ["compat.llamacpp/backend-metal"] }
```

The bare non-SemVer `b10069` is an exact mcpp dependency version. Do not write `=b10069`, which enters the SemVer constraint parser.

- [ ] **Step 3: Write the snapshot mapping**

Create `UPSTREAM.md`:

```markdown
# Upstream Mapping

| llamacpp-m | llama.cpp | Commit | Backends |
|---|---|---|---|
| 0.1.0 | b10069 | 178a6c44937154dc4c4eff0d166f4a044c4fceba | CPU, Metal |

The public contract is `import llama;`. Header consumption and direct `compat.*`
dependencies are not part of this package's compatibility promise.
```

- [ ] **Step 4: Commit the skeleton**

```bash
git add LICENSE .gitignore mcpp.toml UPSTREAM.md
git commit -m "chore: scaffold llamacpp module package"
```

## Task 2: Build A Deterministic API Generator

**Files:**
- Create: `tools/upstream.lock`
- Create: `tools/fetch_upstream.sh`
- Create: `tools/gen_exports.py`
- Create: `tools/test_gen_exports.py`
- Generate: `src/gen_exports/llama.inc`
- Generate: `src/gen_exports/required_ggml.inc`
- Generate: `src/gen_exports/llama.skipped.txt`

- [ ] **Step 1: Add the immutable upstream lock**

Create `tools/upstream.lock`:

```text
tag=b10069
commit=178a6c44937154dc4c4eff0d166f4a044c4fceba
url=https://github.com/ggml-org/llama.cpp/archive/refs/tags/b10069.tar.gz
sha256=293a7c65a11e2203c5468a06d0d0e8d21dfff16ad08712b16c61efbe0d93e097
```

- [ ] **Step 2: Write generator unit fixtures first**

`tools/test_gen_exports.py` must construct a temporary header containing:

```cpp
#define LLAMA_API
#define DEPRECATED(func, hint) func [[deprecated(hint)]]
struct llama_model;
enum llama_mode { LLAMA_MODE_A, LLAMA_MODE_B };
LLAMA_API void llama_live(struct llama_model *);
DEPRECATED(LLAMA_API void llama_old(void), "old");
#define LLAMA_NUMBER 7
enum ggml_log_level { GGML_LOG_LEVEL_NONE, GGML_LOG_LEVEL_INFO };
typedef void (*ggml_log_callback)(enum ggml_log_level, const char *, void *);
```

Assertions:

```python
assert "export using ::llama_model;" in llama_exports
assert "export using ::LLAMA_MODE_A;" in llama_exports
assert "export using ::llama_live;" in llama_exports
assert "llama_old" not in llama_exports
assert "macro LLAMA_NUMBER" in skipped
assert "export using ::ggml_log_level;" in ggml_exports
assert "export using ::GGML_LOG_LEVEL_INFO;" in ggml_exports
assert "export using ::ggml_log_callback;" in ggml_exports
```

- [ ] **Step 3: Run the red generator test**

```bash
python3 -m unittest tools/test_gen_exports.py -v
```

Expected before `gen_exports.py` exists: import/file-not-found failure.

- [ ] **Step 4: Implement the generator with a closed Clang-AST policy**

`tools/gen_exports.py` must:

1. resolve the parser from `CLANG` or `clang++`, create a temporary probe that includes only `llama.h`, and run `-std=c++20 -fsyntax-only -Xclang -ast-dump=json` with the upstream `include/` and `ggml/include/` paths;
2. parse the JSON with Python's `json` module and retain declaration nodes whose source location belongs to `include/llama.h` or one of the required GGML public headers; do not parse C/C++ declarations with regex or brace counting;
3. sort output by original file offset, then name, so Clang traversal-order changes do not rewrite the committed artifacts;
4. accept `RecordDecl`, `TypedefDecl`, `EnumDecl`/`EnumConstantDecl`, and `FunctionDecl`; export llama names beginning with `llama_` and enum values beginning with `LLAMA_`;
5. reject a declaration carrying `DeprecatedAttr` or whose original source range is wrapped by `DEPRECATED(`;
6. accept functions only when the original source line contains `LLAMA_API`;
7. invoke the preprocessor separately with `-dM -E`, record every `LLAMA_*` macro in the skip report, and emit typed replacements only from the reviewed allowlist in Task 3;
8. export this closed GGML type set because those names occur in llama public signatures:

```python
REQUIRED_GGML_TYPES = {
    "ggml_abort_callback",
    "ggml_backend_buffer_type_t",
    "ggml_backend_dev_t",
    "ggml_backend_sched_eval_callback",
    "ggml_cgraph",
    "ggml_context",
    "ggml_log_callback",
    "ggml_log_level",
    "ggml_numa_strategy",
    "ggml_opt_dataset_t",
    "ggml_opt_epoch_callback",
    "ggml_opt_get_optimizer_params",
    "ggml_opt_optimizer_type",
    "ggml_opt_result_t",
    "ggml_tensor",
    "ggml_threadpool_t",
    "ggml_type",
}
```

For the four required GGML enum types (`ggml_log_level`, `ggml_numa_strategy`, `ggml_opt_optimizer_type`, `ggml_type`), also emit their enumerators. Emit no `ggml_*` function. Fail if a llama public signature refers to a GGML type outside the closed set; adding that type requires review rather than silent export. `ggml_log_level` is required so an import-only Metal consumer can provide the callback accepted by `llama_log_set` and assert runtime logs without importing a GGML module.

The CLI is:

```text
python3 tools/gen_exports.py [--upstream DIR] [--check]
```

Without `--upstream`, call `tools/fetch_upstream.sh`. With `--check`, generate into a temporary directory and exit nonzero if any committed artifact differs.

- [ ] **Step 5: Implement checksum-verified fetching**

`tools/fetch_upstream.sh` must use `set -euo pipefail`, cache under `${TMPDIR:-/tmp}/llamacpp-m-upstream`, verify the locked SHA-256 before extraction, and print only the extracted `llama.cpp-b10069` path on stdout. Select `sha256sum` when available and `shasum -a 256` on macOS.

- [ ] **Step 6: Run and review generation**

```bash
python3 -m unittest tools/test_gen_exports.py -v
python3 tools/gen_exports.py
python3 tools/gen_exports.py --check
```

Expected: tests pass, `--check` exits `0`, and the skip report includes every `LLAMA_*` macro plus deprecated `llama_*` declarations.

- [ ] **Step 7: Commit generator and generated API together**

```bash
git add tools/upstream.lock tools/fetch_upstream.sh tools/gen_exports.py tools/test_gen_exports.py src/gen_exports
git commit -m "feat: generate reviewed llama module exports"
```

## Task 3: Implement The Module Unit

**Files:**
- Create: `src/llama.cppm`

- [ ] **Step 1: Write the module global fragment and macro cleanup**

Use this exact shape:

```cpp
module;

#include <cstdint>
#include <llama.h>

#undef LLAMA_DEFAULT_SEED
#undef LLAMA_TOKEN_NULL
#undef LLAMA_FILE_MAGIC_GGLA
#undef LLAMA_FILE_MAGIC_GGSN
#undef LLAMA_FILE_MAGIC_GGSQ
#undef LLAMA_SESSION_MAGIC
#undef LLAMA_SESSION_VERSION
#undef LLAMA_STATE_SEQ_MAGIC
#undef LLAMA_STATE_SEQ_VERSION
#undef LLAMA_STATE_SEQ_FLAGS_NONE
#undef LLAMA_STATE_SEQ_FLAGS_SWA_ONLY
#undef LLAMA_STATE_SEQ_FLAGS_PARTIAL_ONLY
#undef LLAMA_STATE_SEQ_FLAGS_ON_DEVICE

export module llama;

#include "gen_exports/required_ggml.inc"
#include "gen_exports/llama.inc"
```

- [ ] **Step 2: Add typed constant replacements**

Append:

```cpp
export inline constexpr std::uint32_t LLAMA_DEFAULT_SEED = 0xFFFFFFFFu;
export inline constexpr llama_token LLAMA_TOKEN_NULL = -1;

export inline constexpr std::uint32_t LLAMA_FILE_MAGIC_GGLA = 0x67676c61u;
export inline constexpr std::uint32_t LLAMA_FILE_MAGIC_GGSN = 0x6767736eu;
export inline constexpr std::uint32_t LLAMA_FILE_MAGIC_GGSQ = 0x67677371u;
export inline constexpr std::uint32_t LLAMA_SESSION_MAGIC = 0x6767736eu;
export inline constexpr std::uint32_t LLAMA_SESSION_VERSION = 9u;
export inline constexpr std::uint32_t LLAMA_STATE_SEQ_MAGIC = 0x67677371u;
export inline constexpr std::uint32_t LLAMA_STATE_SEQ_VERSION = 2u;

export inline constexpr llama_state_seq_flags LLAMA_STATE_SEQ_FLAGS_NONE = 0u;
export inline constexpr llama_state_seq_flags LLAMA_STATE_SEQ_FLAGS_SWA_ONLY = 1u;
export inline constexpr llama_state_seq_flags LLAMA_STATE_SEQ_FLAGS_PARTIAL_ONLY = 1u;
export inline constexpr llama_state_seq_flags LLAMA_STATE_SEQ_FLAGS_ON_DEVICE = 2u;
```

Do not include `llama-cpp.h` and do not create a header fallback.

- [ ] **Step 3: Compile the module through the staged implementation graph**

```bash
python3 tools/test_with_local_index.py /Users/cltx/projects/mcpp/mcpp-index -- mcpp build --no-cache
```

Expected: `llama.cppm` compiles and links against `compat.llamacpp@b10069`.

- [ ] **Step 4: Commit the module**

```bash
git add src/llama.cppm
git commit -m "feat: export the llama C API as a C++ module"
```

## Task 4: Add Public Consumer Tests

**Files:**
- Create: `tests/api_surface.cpp`
- Create: `tests/decode.cpp`
- Create: `tools/test_with_local_index.py`

- [ ] **Step 1: Write the API surface test**

The file starts with only:

```cpp
import llama;

#ifdef LLAMA_H
#error "import llama must not leak the llama.h include guard"
#endif
#ifdef LLAMA_API
#error "import llama must not leak LLAMA_API"
#endif

static_assert(LLAMA_DEFAULT_SEED == 0xFFFFFFFFu);
static_assert(LLAMA_TOKEN_NULL == -1);
static_assert(LLAMA_STATE_SEQ_FLAGS_ON_DEVICE == 2u);

static void log_sink(ggml_log_level, const char *, void *) {}

int main() {
    llama_log_set(log_sink, nullptr);
    llama_backend_init();
    auto model = llama_model_default_params();
    auto context = llama_context_default_params();
    const bool ok = model.n_gpu_layers == -1 && context.n_ctx != 0;
    llama_backend_free();
    return ok ? 0 : 1;
}
```

- [ ] **Step 2: Write the mandatory decode test**

`tests/decode.cpp` starts with `import std; import llama;` and must fail when `LLAMACPP_TEST_MODEL` is absent or unreadable. It must:

1. call `llama_backend_init()`;
2. load the model with `n_gpu_layers = 0`;
3. create a 64-token context;
4. decode `{1, 2, 3}` through `llama_batch_get_one`;
5. sample once with a greedy sampler;
6. require the sampled token to be within the vocabulary;
7. free sampler, context, model, and backend on every path.

Use `std::getenv`, `std::fopen`, and a small RAII cleanup struct; do not include llama/GGML headers.

- [ ] **Step 3: Implement the local-index test helper**

`tools/test_with_local_index.py` accepts `INDEX -- COMMAND...`, copies the repository to a temporary directory excluding `.git` and `target`, appends:

```toml
[indices]
compat = { path = "<absolute normalized index path>" }
```

to the copied `mcpp.toml`, then executes the command in the copy and returns its exit code. Escape backslashes and quotes as TOML requires. The checked-in release manifest remains unchanged.

- [ ] **Step 4: Run tests with the pinned model**

```bash
export LLAMACPP_TEST_MODEL=/absolute/path/to/stories15M-q4_0.gguf
python3 tools/test_with_local_index.py /Users/cltx/projects/mcpp/mcpp-index -- mcpp test --no-cache
```

Expected: both tests pass. Unset the variable and rerun `decode`; expected: nonzero with `LLAMACPP_TEST_MODEL is required`.

- [ ] **Step 5: Commit tests**

```bash
git add tests tools/test_with_local_index.py
git commit -m "test: cover import-only llama consumers"
```

## Task 5: CI, Release Candidate, And Tag

**Files:**
- Create: `.github/workflows/ci.yml`
- Create: `.github/workflows/release.yml`

- [ ] **Step 1: Add the three-platform CI matrix**

The workflow must:

- install the released mcpp version required by the staging index (`0.0.102` on the frozen baseline);
- check out `wellwei/mcpp-index` ref `feat/llamacpp-module-provider` into `${{ github.workspace }}/_index`;
- run `python3 tools/gen_exports.py --check` on Linux;
- fetch the model at the pinned Hugging Face commit and verify SHA-256;
- set `LLAMACPP_TEST_MODEL`;
- run `python3 tools/test_with_local_index.py "$GITHUB_WORKSPACE/_index" -- mcpp test --no-cache` on Linux x86-64, macOS ARM64, and Windows x86-64.

Expected: all three jobs execute the decode assertion; none reports a model skip.

- [ ] **Step 2: Add tagged release verification**

`release.yml` triggers on `v*`, verifies `${GITHUB_REF_NAME#v}` equals `[package].version`, repeats the same three-platform test matrix, then creates the GitHub release only after all test jobs succeed.

- [ ] **Step 3: Create the remote only with explicit authorization**

Create `mcpplibs/llamacpp-m`, push `main`, and wait for CI. Do not create `v0.1.0` yet.

- [ ] **Step 4: Tag after the complete mcpp-index staging graph passes**

After CPU, Metal, negative, and cold-cache staging checks pass, create and push `v0.1.0` with explicit authorization. Verify the release source archive, download it twice, and record its SHA-256 for `mcpp-index/pkgs/l/llamacpp.lua`.

- [ ] **Step 5: Switch future CI from staging to canonical index**

After the final mcpp-index PR merges, change the CI checkout from the fork feature branch to `mcpplibs/mcpp-index@main`. This follow-up changes only CI routing; `mcpp.toml` and the released module API remain byte-for-byte unchanged.
