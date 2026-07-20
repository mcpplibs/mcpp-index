# Asio Module-Only Package Migration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 删除 `compat.asio` header-only 包，将现有 Asio module recipe 改为唯一根包 `asio@1.38.1`，并通过 `mcpp add asio@1.38.1` 消费。

**Architecture:** 先精确 revert PR #73 的 squash commit，再把 PR #80 的 Form B descriptor 从 `chriskohlhoff.asio` 身份迁移为默认根身份 `asio`。保留原 module wrapper、archive、mirror、hash、三平台配置和五个 module 行为测试；不保留旧全名 alias，不修改 mcpp core。

**Tech Stack:** Git, Lua xpkg descriptor, workflow-pinned mcpp (currently 0.0.101), C++23 modules, GitHub Actions workspace validation.

---

**Design reference:** `.agents/docs/2026-07-20-retire-compat-asio-and-bare-module-design.md`

**Remote topology:** `origin` is the writable fork `wellwei/mcpp-index`; `upstream` is the canonical `mcpplibs/mcpp-index`. Refresh and diff against `upstream/main`; publish the topic branch to `origin` only after local approval.

**External-action boundary:** 本计划实施阶段只产生本地提交。不要执行 `git push`、`gh pr create`、mirror 上传、tag、release 或手工 index 发布。完成后停止并等待用户审批；获批后才把 `refactor/asio-module` 推到 `origin`，并从 `wellwei:refactor/asio-module` 向 `mcpplibs:main` 创建 PR。

## File map

| Path | Action | Responsibility |
| --- | --- | --- |
| `.agents/docs/2026-07-17-add-asio-plan.md` | Delete via revert | PR #73 的 header-only 设计记录 |
| `pkgs/c/compat.asio.lua` | Delete via revert | 退役的 header-only package |
| `tests/examples/asio/` | Delete via revert | 退役的六项 header-only consumer tests |
| `mcpp.toml` | Modify via revert conflict resolution | 删除 `tests/examples/asio`，保留 `asio-module` 和所有后续 members |
| `pkgs/c/chriskohlhoff.asio.lua` | Rename/delete | PR #80 的旧 namespaced module descriptor |
| `pkgs/a/asio.lua` | Create by `git mv`, then modify | 唯一 canonical `asio@1.38.1` module descriptor |
| `tests/examples/asio-module/mcpp.toml` | Modify | 使用 default local index 和 bare `asio` dependency |
| `tests/examples/asio-module/tests/experimental.cpp` | Modify comments only | 删除指向已退役 header test 的说明 |
| `tests/examples/asio-module/tests/network.cpp` | Modify comments only | 删除指向已退役 header test 的说明 |

### Task 1: Refresh the baseline and prove the current module package is green

**Files:**
- Read: `.github/workflows/validate.yml`
- Read: `index.toml`
- Test: `tests/examples/asio-module/`

- [ ] **Step 1: Confirm branch and worktree state**

Run:

```bash
git branch --show-current
git status --short --branch
```

Expected:

```text
refactor/asio-module
## refactor/asio-module...upstream/main [ahead 4]
```

The exact ahead count may increase only by approved plan/doc commits. There must be no unstaged or staged implementation files.

- [ ] **Step 2: Refresh `upstream/main` and check for duplicate Asio work**

Run:

```bash
git fetch upstream main
git log --oneline HEAD..upstream/main
gh pr list --repo mcpplibs/mcpp-index --state open --search "asio in:title" --json number,title,headRefName,url
```

Expected: no unreviewed upstream Asio change and no duplicate open Asio PR. If `HEAD..upstream/main` contains only unrelated commits, rebase the unpushed branch with the one-shot repository identity:

```bash
git -c user.name=wellwei \
    -c user.email=96378453+wellwei@users.noreply.github.com \
    -c core.editor=true \
    rebase upstream/main
```

If upstream changes any Asio path, `mcpp.toml`, `index.toml`, or the validation contract, stop and update this plan before implementation.

- [ ] **Step 3: Obtain the exact workflow-pinned mcpp client**

On the current macOS arm64 workspace, run:

```bash
PIN=$(sed -n 's/^[[:space:]]*MCPP_VERSION: "\([^"]*\)"/\1/p' .github/workflows/validate.yml | head -1)
TOOLS="/private/tmp/mcpp-index-asio-tools-${PIN}"
mkdir -p "$TOOLS"
curl -L -fsS -o "$TOOLS/mcpp.tar.gz" \
  "https://github.com/mcpp-community/mcpp/releases/download/v${PIN}/mcpp-${PIN}-macosx-arm64.tar.gz"
tar -xzf "$TOOLS/mcpp.tar.gz" -C "$TOOLS"
MCPP="$TOOLS/mcpp-${PIN}-macosx-arm64/bin/mcpp"
"$MCPP" --version
```

Expected: the printed mcpp version exactly equals `PIN` (currently `0.0.101`). Do not use the host's older `mcpp 0.0.96` binary.

- [ ] **Step 4: Run the current qualified-token baseline**

Run:

```bash
PIN=$(sed -n 's/^[[:space:]]*MCPP_VERSION: "\([^"]*\)"/\1/p' .github/workflows/validate.yml | head -1)
MCPP="/private/tmp/mcpp-index-asio-tools-${PIN}/mcpp-${PIN}-macosx-arm64/bin/mcpp"
git clean -fdX tests/examples/asio-module
MCPP_INDEX_MIRROR=GLOBAL "$MCPP" test -p asio-module
```

Expected: `5 passed; 0 failed`. The network test must remain enabled. If sandboxed loopback fails with `bind: Operation not permitted`, rerun this same command with local-network permission; do not weaken or remove the test.

### Task 2: Revert the header-only package from PR #73

**Files:**
- Delete: `.agents/docs/2026-07-17-add-asio-plan.md`
- Delete: `pkgs/c/compat.asio.lua`
- Delete: `tests/examples/asio/mcpp.toml`
- Delete: `tests/examples/asio/tests/core.cpp`
- Delete: `tests/examples/asio/tests/coroutine.cpp`
- Delete: `tests/examples/asio/tests/experimental.cpp`
- Delete: `tests/examples/asio/tests/network.cpp`
- Delete: `tests/examples/asio/tests/platform.cpp`
- Delete: `tests/examples/asio/tests/surface.cpp`
- Modify: `mcpp.toml:9`

- [ ] **Step 1: Verify the revert target is the single-parent squash commit**

Run:

```bash
git show -s --format='%H%n%P%n%s' b3ebdd15bc3b56dc61cb91ab5b592200f713709f
```

Expected: commit `b3ebdd15...`, exactly one parent, subject `feat(pkgs): add standalone asio 1.38.1 (#73)`.

- [ ] **Step 2: Start the revert and confirm the only conflict**

Run:

```bash
git revert --no-edit b3ebdd15bc3b56dc61cb91ab5b592200f713709f
```

Expected: nonzero exit with one content conflict in `mcpp.toml`.

Run:

```bash
git diff --name-only --diff-filter=U
```

Expected:

```text
mcpp.toml
```

If any other file conflicts, stop and re-evaluate the current upstream baseline.

- [ ] **Step 3: Resolve `mcpp.toml` to the exact member list**

Use `apply_patch` to replace the conflicted `[workspace]` block with:

```toml
[workspace]
members = [
    "tests/examples/archive",
    "tests/examples/asio-module",
    "tests/examples/build-mcpp",
    "tests/examples/cjson",
    "tests/examples/core",
    "tests/examples/eigen",
    "tests/examples/ffmpeg",
    "tests/examples/ffmpeg-module",
    "tests/examples/fmtlib.fmt",
    "tests/examples/gui-stack",
    "tests/examples/imgui",
    "tests/examples/imgui-module",
    "tests/examples/imgui-window",
    "tests/examples/marzer.tomlplusplus",
    "tests/examples/nlohmann.json",
    "tests/examples/openblas",
    "tests/examples/opencv",
    "tests/examples/opencv-win",
    "tests/examples/opencv-unifont",
    "tests/examples/opencv-dnn",
    "tests/examples/opencv-module",
    "tests/examples/opencv-module-dnn",
    "tests/examples/opencv-module-unifont",
    "tests/examples/spdlog",
    "tests/examples/spdlog-compiled",
    "tests/examples/tinyhttps",
]
```

Before continuing, compare this block with the latest `upstream/main:mcpp.toml`. The only removed member must be `tests/examples/asio`.

- [ ] **Step 4: Complete the revert commit**

Run:

```bash
git add mcpp.toml
git -c user.name=wellwei \
    -c user.email=96378453+wellwei@users.noreply.github.com \
    -c core.editor=true \
    revert --continue
```

Expected: one new revert commit.

- [ ] **Step 5: Verify the removal boundary**

Run:

```bash
test ! -e pkgs/c/compat.asio.lua
test ! -e tests/examples/asio
test ! -e .agents/docs/2026-07-17-add-asio-plan.md
test -e pkgs/c/chriskohlhoff.asio.lua
test -e tests/examples/asio-module/mcpp.toml
git show --stat --oneline HEAD
```

Expected: only PR #73 content is removed; PR #80 module files remain.

### Task 3: Create the bare-token Red through the real `mcpp add` command

**Files:**
- Modify: `tests/examples/asio-module/mcpp.toml`
- Test: `tests/examples/asio-module/tests/*.cpp`

- [ ] **Step 1: Change only the local index routing and remove the old dependency**

Use `apply_patch` to make `tests/examples/asio-module/mcpp.toml` exactly:

```toml
# Asio C++23-module consumer test project: `import std; import asio;`.
# The public package is the default-root module-only `asio@1.38.1` package.
[package]
name = "asio-module-tests"
version = "0.1.0"

[indices]
default = { path = "../../.." }
```

- [ ] **Step 2: Add the dependency through the requested CLI surface**

Run:

```bash
PIN=$(sed -n 's/^[[:space:]]*MCPP_VERSION: "\([^"]*\)"/\1/p' .github/workflows/validate.yml | head -1)
MCPP="/private/tmp/mcpp-index-asio-tools-${PIN}/mcpp-${PIN}-macosx-arm64/bin/mcpp"
cd tests/examples/asio-module
"$MCPP" add asio@1.38.1
cd ../../..
```

Expected: `mcpp add` reports `Adding asio v1.38.1 to dependencies`, and the manifest ends with:

```toml
[dependencies]
asio = "1.38.1"
```

- [ ] **Step 3: Run the consumer test and verify the expected Red**

Run:

```bash
PIN=$(sed -n 's/^[[:space:]]*MCPP_VERSION: "\([^"]*\)"/\1/p' .github/workflows/validate.yml | head -1)
MCPP="/private/tmp/mcpp-index-asio-tools-${PIN}/mcpp-${PIN}-macosx-arm64/bin/mcpp"
git clean -fdX tests/examples/asio-module
set +e
MCPP_INDEX_MIRROR=GLOBAL "$MCPP" test -p asio-module \
  > /private/tmp/asio-module-bare-red.log 2>&1
rc=$?
set -e
test "$rc" -ne 0
rg -n "asio|not found" /private/tmp/asio-module-bare-red.log
```

Expected: failure because the local index has neither `pkgs/a/asio.lua` nor a remaining `compat.asio` fallback. Do not commit the failing state yet.

### Task 4: Make the descriptor identity canonical and restore Green

**Files:**
- Rename: `pkgs/c/chriskohlhoff.asio.lua` -> `pkgs/a/asio.lua`
- Modify: `pkgs/a/asio.lua:1`
- Modify: `tests/examples/asio-module/tests/experimental.cpp:1`
- Modify: `tests/examples/asio-module/tests/network.cpp:1`

- [ ] **Step 1: Move the descriptor to its canonical root-package path**

Run:

```bash
git mv pkgs/c/chriskohlhoff.asio.lua pkgs/a/asio.lua
```

- [ ] **Step 2: Replace the stale descriptor preamble and package identity**

Use `apply_patch` to replace everything before `package = {` with this exact preamble:

```lua
-- asio -- standalone Asio 1.38.1 exposed as the C++23 module `asio`
-- (Form B inline descriptor, separate-compilation mode).
--
-- Install and consume:
--     mcpp add asio@1.38.1
--     import std;
--     import asio;
--
-- The upstream 1.38.x release has no module interface unit. This descriptor
-- generates a reviewed `asio.cppm` wrapper and compiles upstream `src/asio.cpp`
-- with ASIO_SEPARATE_COMPILATION. `import std;` is required because this package
-- does not inject the standard library through the module boundary.
--
-- This package is module-only. Textual `#include <asio.hpp>` consumption and
-- APIs not exported by the wrapper are outside its mcpp-index contract. The
-- wrapper intentionally excludes SSL/TLS, local/POSIX/Windows handle APIs,
-- serial ports, pipes, file I/O, stackful spawn, and other surfaces listed by
-- headers that it does not include.
--
-- ASIO_STANDALONE and ASIO_SEPARATE_COMPILATION are public build defines, but
-- preprocessor macros do not cross `import asio;`. Consumers should use C++ or
-- operating-system facilities instead of testing ASIO_HAS_* macros.
```

Then make the package table begin exactly:

```lua
package = {
    spec        = "1",
    namespace   = "",
    name        = "asio",
    description = "Standalone asio exposed as the C++23 module `asio` (separate compilation)",
    licenses    = {"BSL-1.0"},
    repo        = "https://github.com/chriskohlhoff/asio",
    type        = "package",
```

Preserve the complete `xpm` and `mcpp` tables after this header.

- [ ] **Step 3: Make the two remaining recipe comments self-contained**

Replace the Windows archive comment with:

```lua
            -- Upstream tag archives carry two POSIX symlinks
            -- (asio/include -> ../include, asio/src -> ../src) that tar.exe
            -- cannot materialize on the Windows runner. This uses the existing
            -- symlink-free repack documented by xlings-res/asio.
```

Replace the `ASIO_HAS_THREADS` comment with:

```lua
        -- ASIO_HAS_THREADS: asio's detection keys off CRT macros
        -- (_MT/_REENTRANT/_POSIX_THREADS) that the workspace's llvm-on-Windows
        -- toolchain does not define, otherwise silently selecting null_thread.
        -- Pin the known multithreaded package contract; POSIX pthread selection
        -- still runs beneath this define where applicable.
```

Do not change the associated URLs, hashes, sources, features, or flags.

- [ ] **Step 4: Remove stale header-test comparisons from module tests**

Make the opening of `tests/examples/asio-module/tests/experimental.cpp` exactly:

```cpp
// Experimental channel/concurrent_channel/use_promise over the module surface.
import std;
import asio;
```

Make the opening of `tests/examples/asio-module/tests/network.cpp` exactly:

```cpp
// TCP (acceptor/socket, async_read/async_write) and UDP (datagram send/receive)
// over the imported module surface.
import std;
import asio;
```

- [ ] **Step 5: Prove the recipe body did not change**

Run both commands and compare the hashes:

```bash
git show HEAD:pkgs/c/chriskohlhoff.asio.lua \
  | sed -E '/^[[:space:]]*--/d;/^[[:space:]]*$/d;/^[[:space:]]*namespace[[:space:]]*=/d;/^[[:space:]]*name[[:space:]]*=/d' \
  | shasum -a 256
sed -E '/^[[:space:]]*--/d;/^[[:space:]]*$/d;/^[[:space:]]*namespace[[:space:]]*=/d;/^[[:space:]]*name[[:space:]]*=/d' pkgs/a/asio.lua \
  | shasum -a 256
```

Expected: identical SHA-256 values. A mismatch means a non-comment recipe field changed; inspect and restore it before continuing.

- [ ] **Step 6: Parse the descriptor and run the Green test**

Run:

```bash
PIN=$(sed -n 's/^[[:space:]]*MCPP_VERSION: "\([^"]*\)"/\1/p' .github/workflows/validate.yml | head -1)
MCPP="/private/tmp/mcpp-index-asio-tools-${PIN}/mcpp-${PIN}-macosx-arm64/bin/mcpp"
lua -e "assert(loadfile('pkgs/a/asio.lua', 't'))"
lua tests/check_mirror_urls.lua pkgs/a/asio.lua
"$MCPP" xpkg parse pkgs/a/asio.lua
git clean -fdX tests/examples/asio-module
MCPP_INDEX_MIRROR=GLOBAL "$MCPP" test -p asio-module
```

Expected: Lua syntax success, mirror check success, strict parse success, and `5 passed; 0 failed`.

- [ ] **Step 7: Inspect the generated lock identity**

Run:

```bash
LOCK=tests/examples/asio-module/mcpp.lock
test -f "$LOCK"
rg -n '^\[package\."asio"\]$|^namespace[[:space:]]*=|^version[[:space:]]*=' "$LOCK"
```

Expected: `[package."asio"]` with version `1.38.1`; there must be no Asio namespace line for `compat` or `chriskohlhoff`.

### Task 5: Validate the complete local change

**Files:**
- Test: `pkgs/a/asio.lua`
- Test: `tests/examples/asio-module/`
- Test: root workspace

- [ ] **Step 1: Verify the active-tree cleanup**

Run:

```bash
test ! -e pkgs/c/compat.asio.lua
test ! -e pkgs/c/chriskohlhoff.asio.lua
test ! -e tests/examples/asio
test -e pkgs/a/asio.lua
set +e
rg -n "compat\.asio|chriskohlhoff\.asio|tests/examples/asio([^\-]|$)" \
  mcpp.toml pkgs tests README.md
rc=$?
set -e
test "$rc" -eq 1
```

Expected: the three absence checks pass and `rg` exits 1 because it finds no active package, workspace, test, or user-instruction references. The upstream repository URL `github.com/chriskohlhoff/asio` is allowed because it is not a package token.

- [ ] **Step 2: Run whitespace, descriptor, and mirror checks**

Run:

```bash
PIN=$(sed -n 's/^[[:space:]]*MCPP_VERSION: "\([^"]*\)"/\1/p' .github/workflows/validate.yml | head -1)
MCPP="/private/tmp/mcpp-index-asio-tools-${PIN}/mcpp-${PIN}-macosx-arm64/bin/mcpp"
git diff --check
lua -e "assert(loadfile('pkgs/a/asio.lua', 't'))"
lua tests/check_mirror_urls.lua pkgs/a/asio.lua
"$MCPP" xpkg parse pkgs/a/asio.lua
```

Expected: all commands exit 0.

- [ ] **Step 3: Re-run the targeted module suite from clean member state**

Run:

```bash
PIN=$(sed -n 's/^[[:space:]]*MCPP_VERSION: "\([^"]*\)"/\1/p' .github/workflows/validate.yml | head -1)
MCPP="/private/tmp/mcpp-index-asio-tools-${PIN}/mcpp-${PIN}-macosx-arm64/bin/mcpp"
git clean -fdX tests/examples/asio-module
MCPP_INDEX_MIRROR=GLOBAL "$MCPP" test -p asio-module
```

Expected: `5 passed; 0 failed`.

- [ ] **Step 4: Run the full local workspace suite**

Run:

```bash
PIN=$(sed -n 's/^[[:space:]]*MCPP_VERSION: "\([^"]*\)"/\1/p' .github/workflows/validate.yml | head -1)
MCPP="/private/tmp/mcpp-index-asio-tools-${PIN}/mcpp-${PIN}-macosx-arm64/bin/mcpp"
MCPP_INDEX_MIRROR=GLOBAL "$MCPP" test --workspace
```

Expected: every member selected for macOS passes. Record the exact passed/failed totals. Linux and Windows matrix validation remains unverified until the user authorizes a push/PR; do not claim three-platform completion locally.

### Task 6: Commit the module identity migration

**Files:**
- Add: `pkgs/a/asio.lua`
- Delete: `pkgs/c/chriskohlhoff.asio.lua`
- Modify: `tests/examples/asio-module/mcpp.toml`
- Modify: `tests/examples/asio-module/tests/experimental.cpp`
- Modify: `tests/examples/asio-module/tests/network.cpp`

- [ ] **Step 1: Review the exact implementation diff**

Run:

```bash
git status --short
git diff --find-renames --stat
git diff --find-renames -- \
  pkgs/a/asio.lua \
  pkgs/c/chriskohlhoff.asio.lua \
  tests/examples/asio-module
git diff --check
```

Expected: one descriptor rename with comment/identity changes, one manifest change, and two comment-only test changes. No archive, hash, generated wrapper, source, feature, or platform flag change.

- [ ] **Step 2: Commit the Green implementation**

Run:

```bash
git add \
  pkgs/a/asio.lua \
  pkgs/c/chriskohlhoff.asio.lua \
  tests/examples/asio-module/mcpp.toml \
  tests/examples/asio-module/tests/experimental.cpp \
  tests/examples/asio-module/tests/network.cpp
git diff --cached --check
git -c user.name=wellwei \
    -c user.email=96378453+wellwei@users.noreply.github.com \
    commit -m "refactor(asio): make module package canonical"
```

Expected: one focused implementation commit after the separate PR #73 revert commit.

### Task 7: Prepare the local approval handoff and stop

**Files:**
- Read: all branch changes against `upstream/main`

- [ ] **Step 1: Verify final repository state**

Run:

```bash
git status --short --branch
git log --oneline --decorate upstream/main..HEAD
git diff --stat upstream/main...HEAD
git diff upstream/main...HEAD --check
```

Expected: clean worktree; design/plan commits, one PR #73 revert commit, and one module migration commit. No uncommitted files.

- [ ] **Step 2: Report evidence without external actions**

Report to the user:

- local branch name and commit list;
- deleted package/test paths;
- final descriptor identity and path;
- Red failure summary and Green targeted/full-workspace totals;
- descriptor/mirror/lockfile verification;
- Linux/Windows CI still pending because no PR was created.

Stop here. Do not push the branch and do not create a PR until the user explicitly approves the reviewed local diff and verification evidence. After that approval, publish with `git push -u origin refactor/asio-module` and create the PR against `mcpplibs/mcpp-index:main`; required checks must pass before maintainers merge it.
