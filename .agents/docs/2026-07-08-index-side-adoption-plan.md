# Index-side adoption plan — mcpp 0.0.85 train (floor, strict lint, scan_overrides, long brackets)

Companion to mcpp repo
`.agents/docs/2026-07-08-descriptor-index-evolution-roadmap.md` (master) and
its two design docs (same date). This doc is the mcpp-index execution detail.

Rule of the whole rollout: **floor first, new grammar/keys after** — enforced
mechanically by lint once P1 lands (lint parses with the pinned mcpp; before
the pin reaches 0.0.85, new-grammar descriptors cannot merge).

---

## P0 — merge PR #63 as-is (pre-train)

fmt 12.2.0 via `generated_files` works on today's 0.0.81 (verified locally
2026-07-08: lint pass, sha256 match, member test green, generated file = 
upstream `src/fmt.cc` minus exactly the `import std;` guard). Don't couple it
to the train; migrate it in P2.

## P1 — floor PR (single atomic PR)

1. `index.toml` at repo root:

   ```toml
   [index]
   spec        = "1"
   min_mcpp    = "0.0.85"
   latest_mcpp = "0.0.85"
   ```

2. `.github/workflows/validate.yml`: `MCPP_VERSION` 0.0.81 → 0.0.85.
3. lint job: add the pinned-mcpp download step (same snippet as the workspace
   job) and run `mcpp xpkg parse --strict` over changed (PR) / all (push,
   nightly) descriptors — **in addition to** the existing `lua5.4 loadfile`
   check (the xim side executes real Lua; both grammars stay guarded).
4. `tools/publish_mcpp_index.sh`: pack `index.toml` into the artifact tree
   (one `cp` next to the existing `pkgs/` copy). Pointer untouched.
5. `docs/repository-and-schema.md`: floor paragraph (what breaks for
   pre-0.0.85 clients, why now).

## P2 — fmt: generated_files → scan_overrides

`pkgs/f/fmtlib.fmt.lua` descriptor `mcpp` segment becomes:

```lua
mcpp = {
    schema       = "0.1",
    language     = "c++23",
    import_std   = true,
    modules      = { "fmt" },
    include_dirs = { "*/include", "*/src" },
    sources      = { "*/src/fmt.cc" },        -- upstream file, verbatim
    cxxflags     = { "-DFMT_IMPORT_STD" },
    scan_overrides = {
        ["*/src/fmt.cc"] = { provides = { "fmt" }, imports = { "std" } },
    },
    targets      = { ["fmt"] = { kind = "lib" } },
}
```

- Deletes the 3.4 KB escaped `generated_files` copy entirely.
- `tests/examples/fmtlib.fmt/` member unchanged — it is the live CI proof
  (also the matrix's first `import_std = true` package build on mac/win).
- mcpp-side reconciliation (mandatory for override files) audits the declared
  `(provides, imports)` against the compiler's `.ddi` every build.

## P3 — long-bracket migrations (one PR per package)

`pkgs/n/nlohmann.json.lua`, `pkgs/c/compat.eigen.lua`: `generated_files`
escaped strings → `[==[ … ]==]`. Mechanical; reviewer checks the parity
oracle output (content via lua5.4 == content via `mcpp xpkg parse --json`),
which the lint step re-verifies anyway.

## P4 — docs refresh

`docs/repository-and-schema.md`:
- replace "`generated_files` … 不支持 `[[…]]`" with: long brackets require
  mcpp ≥ 0.0.85 (index floor guarantees this; lint enforces).
- new row in the case-index table: "guarded-import module unit →
  `scan_overrides`" pointing at `pkgs/f/fmtlib.fmt.lua` post-P2.
- mention `mcpp xpkg parse --strict` as the local reproduction of lint.

## Verification / rollback

- Every PR rides the existing `mcpp test --workspace` 3-OS matrix.
- P1 is the only PR with blast radius (floor + version bump together): if
  0.0.85 misbehaves in CI, revert P1 alone restores the 0.0.81 world; P2/P3
  cannot have merged yet (lint gate).
- CN mirror for fmt (from PR #63 review) remains a separate follow-up via
  gtc/mcpp-res — unrelated to this train.
