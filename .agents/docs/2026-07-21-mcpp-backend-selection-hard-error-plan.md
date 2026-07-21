# mcpp Backend Selection Hard Error Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make an undeclared dependency backend selector fail unconditionally while leaving ordinary unknown-feature warnings controlled by `--strict`.

**Architecture:** Keep `backend = "metal"` as the existing `backend-metal` feature sugar. Reserve the `backend-` feature namespace at dependency activation, where the target package's complete feature table is available, and turn only undeclared dependency backend features into hard errors.

**Tech Stack:** C++23 modules, mcpp build preparation, Bash E2E tests, GitHub Actions.

---

## File Map

| File | Change |
|---|---|
| `tests/e2e/67_features_strict.sh` | Change the unknown-backend case from warning-success to unconditional failure; add no-feature-table and ordinary-feature controls. |
| `src/build/prepare.cppm` | Validate every dependency request; hard-fail missing names beginning with `backend-`, even when the dependency has no `[features]` table. |
| `CHANGELOG.md` | Document the dependency backend contract in the release section. |
| `mcpp.toml` | Bump the release version after the feature PR merges. |
| `src/toolchain/fingerprint.cppm` | Keep the compiled version string identical to `mcpp.toml`. |

## Task 1: Establish The Contribution Boundary

**Files:**
- Inspect: `AGENTS.md`
- Inspect: `.github/workflows/ci*.yml`
- Inspect: `tests/e2e/run_all.sh`

- [ ] **Step 1: Refresh without touching the existing checkout**

Run:

```bash
git fetch origin main
git status --short --branch
git rev-parse origin/main
gh issue list -R mcpp-community/mcpp --state open --search "backend unknown feature" --limit 20
gh pr list -R mcpp-community/mcpp --state open --search "backend unknown feature" --limit 20
```

Expected: local changes are preserved and no duplicate issue/PR owns the same behavior.

- [ ] **Step 2: Create an isolated worktree**

Run:

```bash
git worktree add ../mcpp-backend-hard-error -b fix/backend-selection-hard-error origin/main
```

Expected: `../mcpp-backend-hard-error` is clean and based on current `origin/main`.

- [ ] **Step 3: Create the issue only with explicit authorization**

Use this issue body:

```markdown
## Problem

`backend = "metal"` is parsed as a request for feature `backend-metal`. When the dependency does not declare that feature, normal builds only warn and continue, which silently turns an invalid accelerator request into the dependency's default build.

## Expected behavior

An undeclared dependency feature in the reserved `backend-*` namespace is always an error, with or without `--strict`. Ordinary undeclared feature requests keep their current warning behavior unless `--strict` is used.

## Coverage

- declared backend succeeds;
- undeclared backend fails;
- backend on a package with no feature table fails;
- ordinary unknown feature still warns by default and fails under `--strict`.
```

Do not create the issue during plan authoring.

## Task 2: Write The Failing Backend Contract

**Files:**
- Modify: `tests/e2e/67_features_strict.sh`

- [ ] **Step 1: Replace case 4 with an unconditional failure assertion**

Use:

```bash
# 4. Unknown backend is a configuration error even without --strict.
sed 's/backend = "a"/backend = "zzz"/' mcpp.toml > mcpp.toml.tmp && mv mcpp.toml.tmp mcpp.toml
rm -rf target
if "$MCPP" build > b5.log 2>&1; then
    cat b5.log; echo "unknown backend must fail without --strict"; exit 1
fi
grep -q "dependency 'widget' does not support backend 'zzz'" b5.log \
    || { cat b5.log; echo "missing backend error"; exit 1; }
sed 's/backend = "zzz"/backend = "a"/' mcpp.toml > mcpp.toml.tmp && mv mcpp.toml.tmp mcpp.toml
```

- [ ] **Step 2: Add a dependency with no feature table**

Before entering `app`, create:

```bash
mkdir -p plain/src
cat > plain/mcpp.toml <<'EOF'
[package]
name = "plain"
version = "0.1.0"

[targets.plain]
kind = "lib"
EOF
cat > plain/src/plain.cppm <<'EOF'
export module plain;
export int plain_value() { return 1; }
EOF
```

After case 4, add:

```bash
# 5. backend= on a dependency with no feature table must also fail.
cat >> mcpp.toml <<'EOF'
plain = { path = "../plain", backend = "cuda" }
EOF
rm -rf target
if "$MCPP" build > b6.log 2>&1; then
    cat b6.log; echo "backend on a featureless dependency must fail"; exit 1
fi
grep -q "dependency 'plain' does not support backend 'cuda'" b6.log \
    || { cat b6.log; echo "missing featureless-backend error"; exit 1; }
sed '/plain = { path = "..\/plain", backend = "cuda" }/d' mcpp.toml > mcpp.toml.tmp
mv mcpp.toml.tmp mcpp.toml
```

- [ ] **Step 3: Keep the non-backend control explicit**

Use a separate manifest rewrite so `backend = "a"` remains selected while the ordinary unknown feature is requested:

```bash
# 6. An ordinary unknown dependency feature keeps warning/--strict behavior.
sed 's/backend = "a"/backend = "a", features = ["nosuch"]/' \
    mcpp.toml > mcpp.toml.tmp
mv mcpp.toml.tmp mcpp.toml
rm -rf target
"$MCPP" build > b7.log 2>&1 \
    || { cat b7.log; echo "ordinary unknown feature must warn, not fail"; exit 1; }
grep -q "does not declare requested feature 'nosuch'" b7.log \
    || { cat b7.log; echo "missing ordinary-feature warning"; exit 1; }
if "$MCPP" build --strict > b8.log 2>&1; then
    cat b8.log; echo "--strict must reject ordinary unknown dependency feature"; exit 1
fi
grep -q "does not declare requested feature 'nosuch'" b8.log \
    || { cat b8.log; echo "missing strict ordinary-feature error"; exit 1; }
sed 's/backend = "a", features = \["nosuch"\]/backend = "a"/' \
    mcpp.toml > mcpp.toml.tmp
mv mcpp.toml.tmp mcpp.toml
```

Change the existing unknown-platform case to case 7 and its two log files to
`b9.log` (warning path) and `b10.log` (`--strict` path). This distinguishes the
reserved backend namespace from general feature validation.

- [ ] **Step 4: Run the red test**

Run:

```bash
bash tests/e2e/67_features_strict.sh
```

Expected before implementation: failure at case 4 because `mcpp build` returns success after printing the old warning.

- [ ] **Step 5: Commit the red test**

```bash
git add tests/e2e/67_features_strict.sh
git commit -m "test: require invalid dependency backends to fail"
```

## Task 3: Implement The Narrow Validation Rule

**Files:**
- Modify: `src/build/prepare.cppm` near dependency feature activation (`aggregatedRequest` loop)

- [ ] **Step 1: Replace the current feature-table-gated validation**

Use this structure:

```cpp
for (std::size_t i = 1; i < packages.size(); ++i) {
    auto& pname = packages[i].manifest.package.name;
    auto [req, depDefaultFeatures] = aggregatedRequest(i);
    for (auto& f : req) {
        if (packages[i].manifest.featuresMap.contains(f)) continue;

        constexpr std::string_view backendPrefix = "backend-";
        if (std::string_view(f).starts_with(backendPrefix)) {
            return std::unexpected(std::format(
                "dependency '{}' does not support backend '{}' "
                "(missing feature '{}')",
                pname, std::string_view(f).substr(backendPrefix.size()), f));
        }

        // Preserve the historical pure-define behavior for packages with no
        // feature table; only the reserved backend namespace is always strict.
        if (packages[i].manifest.featuresMap.empty()) continue;

        auto msg = std::format(
            "dependency '{}' does not declare requested feature '{}' "
            "in its [features] table", pname, f);
        if (overrides.strict) return std::unexpected(msg);
        std::println(stderr, "warning: {}", msg);
    }
    apply(packages[i], req, depDefaultFeatures);
}
```

Do not change root `--features` behavior and do not add a new manifest field. Both `backend = "cuda"` and an explicit dependency `features = ["backend-cuda"]` use the same reserved selector contract.

- [ ] **Step 2: Run the targeted test**

```bash
bash tests/e2e/67_features_strict.sh
```

Expected: `OK`.

- [ ] **Step 3: Run adjacent feature/capability regressions**

```bash
bash tests/e2e/81_capability_binding.sh
bash tests/e2e/82_feature_optional_deps.sh
bash tests/e2e/128_feature_forwarding.sh
bash tests/e2e/146_feature_flags.sh
bash tests/e2e/147_per_os_features_xpkg.sh
```

Expected: every script prints `OK`.

- [ ] **Step 4: Build mcpp**

```bash
mcpp build
```

Expected: exit `0` and a fresh mcpp binary under `target/<triple>/release/bin/mcpp`.

- [ ] **Step 5: Commit the implementation**

```bash
git add src/build/prepare.cppm
git commit -m "fix: reject undeclared dependency backends"
```

## Task 4: PR And Release Gate

**Files:**
- Modify after feature merge: `CHANGELOG.md`
- Modify after feature merge: `mcpp.toml`
- Modify after feature merge: `src/toolchain/fingerprint.cppm`

- [ ] **Step 1: Rebase, rerun, and inspect the feature PR**

```bash
git fetch origin main
git rebase origin/main
bash tests/e2e/67_features_strict.sh
mcpp build
git diff --check origin/main...HEAD
git log --oneline origin/main..HEAD
```

Expected: two focused commits, clean whitespace, no documentation from the mcpp-index planning branch.

- [ ] **Step 2: Push/open the PR only with explicit authorization**

Use title `fix: reject undeclared dependency backends` and include the exact targeted test commands in the PR body. Wait for Linux, macOS, and Windows required checks.

- [ ] **Step 3: Prepare the patch release through a second PR**

After the feature PR merges and `main` CI is green, add a `0.0.102` CHANGELOG section and change both version locations:

```toml
# mcpp.toml
version = "0.0.102"
```

```cpp
// src/toolchain/fingerprint.cppm
inline constexpr std::string_view MCPP_VERSION = "0.0.102";
```

If `0.0.102` already exists at execution time, use the next patch consistently. Verify with:

```bash
mcpp build
target/*/release/bin/mcpp --version
```

Expected: the binary reports exactly the release version.

- [ ] **Step 4: Tag only from merged main and verify artifacts**

Set `MCPP_RELEASE` to the concrete patch selected in Step 3 (`0.0.102` on the
frozen baseline). With explicit release authorization, trigger the live
`release.yml` for `v${MCPP_RELEASE}` and verify at least the Linux x86-64,
macOS ARM64, and Windows x86-64 archives plus checksums. Do not advance the
mcpp-index floor until all maintained artifacts exist and their smoke tests
passed.
