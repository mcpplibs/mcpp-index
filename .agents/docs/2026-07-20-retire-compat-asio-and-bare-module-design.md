# Retire `compat.asio` and make `asio@1.38.1` module-only

Date: 2026-07-20

## 1. Decision

Retire the transitional header-only Asio package introduced by
mcpplibs/mcpp-index PR #73. The index will publish one Asio 1.38.1 package,
consumed only as a C++23 module:

```bash
mcpp add asio@1.38.1
```

```cpp
import std;
import asio;
```

The current module recipe introduced by PR #80 remains the implementation, but
its package identity changes from `chriskohlhoff.asio@1.38.1` to the default
root package `asio@1.38.1`.

The old qualified token `mcpp add chriskohlhoff.asio@1.38.1` is not retained as
an alias and is not part of the new compatibility contract.

## 2. Goals and non-goals

Goals:

- remove `compat.asio@1.38.1` and all header-only consumer coverage;
- preserve the existing `import asio;` module implementation and behavior;
- make `asio@1.38.1` the only supported dependency identity and CLI token;
- keep one descriptor, one package identity, one lockfile identity, and one
  module test member;
- preserve the existing archives, mirrors, hashes, platforms, generated module
  wrapper, and separate-compilation build configuration.

Non-goals:

- supporting `#include <asio.hpp>` through mcpp-index;
- selecting header-only/module behavior through `features`;
- retaining `chriskohlhoff.asio` through an alias, redirect, forwarding package,
  or non-canonical filename fallback;
- changing mcpp core package resolution;
- publishing a new Asio upstream version or changing source bytes.

## 3. Revert PR #73

PR #73 was squash-merged as the single-parent commit
`b3ebdd15bc3b56dc61cb91ab5b592200f713709f`. Revert it with:

```bash
git revert b3ebdd15bc3b56dc61cb91ab5b592200f713709f
```

Do not use `git revert -m 1`; the commit is not a merge commit.

The reverse patch removes:

- `.agents/docs/2026-07-17-add-asio-plan.md`;
- `pkgs/c/compat.asio.lua`;
- `tests/examples/asio/mcpp.toml`;
- all six header-only tests under `tests/examples/asio/tests/`;
- `tests/examples/asio` from the root workspace.

On the current `origin/main`, the revert conflicts only in the root
`mcpp.toml`. Resolve it by removing only `tests/examples/asio`; retain
`tests/examples/asio-module` and every workspace member added after PR #73.

Keep the resolved revert as its own commit so the removal remains traceable to
PR #73.

## 4. Rename the module package identity

Move the descriptor:

```text
pkgs/c/chriskohlhoff.asio.lua
    -> pkgs/a/asio.lua
```

Change its identity fields from:

```lua
namespace = "chriskohlhoff"
name      = "chriskohlhoff.asio"
```

to:

```lua
namespace = ""
name      = "asio"
```

This is a canonical default-root package shape already used by module packages
such as `imgui`, `ffmpeg`, and `opencv`. The descriptor filename, declared
identity, dependency key, install target, and lockfile identity all become the
same bare name. No package alias or compatibility fallback is involved.

Do not change the following parts of the descriptor:

- version `1.38.1`;
- Linux/macOS upstream archive and SHA-256;
- Windows symlink-free archive and SHA-256;
- GLOBAL/CN mirror tables;
- `generated_files` module wrapper;
- `modules = { "asio" }`;
- `*/src/asio.cpp` separate-compilation source;
- `ASIO_STANDALONE`, `ASIO_SEPARATE_COMPILATION`,
  `ASIO_DISABLE_BOOST_CONTEXT_FIBER`, and `ASIO_HAS_THREADS`;
- platform link settings.

## 5. Consumer contract

Update `tests/examples/asio-module/mcpp.toml` from the qualified local index:

```toml
[indices]
chriskohlhoff = { path = "../../.." }

[dependencies.chriskohlhoff]
asio = "1.38.1"
```

to the default-root local index:

```toml
[indices]
default = { path = "../../.." }

[dependencies]
asio = "1.38.1"
```

Keep the existing five module consumer tests. They already cover core runtime
behavior, coroutines, networking, experimental APIs, and the exported surface.
No second alias-specific member is needed because there is only one supported
package token.

The resulting lockfile contract is:

```toml
[package."asio"]
version = "1.38.1"
```

It must not contain `namespace = "compat"` or
`namespace = "chriskohlhoff"` for Asio.

## 6. Documentation cleanup

The module descriptor currently describes `compat.asio` as a header-only
companion and tells users to select it for APIs outside the wrapper. Remove or
rewrite those statements.

The retained documentation must state:

- installation: `mcpp add asio@1.38.1`;
- consumption: `import std; import asio;`;
- the package is module-only;
- APIs not exported by the wrapper are unavailable through this package;
- textual inclusion with `#include <asio.hpp>` is outside the supported
  mcpp-index contract;
- `chriskohlhoff.asio@1.38.1` was the retired pre-rename package token and is
  not a supported alias.

Remove comparison comments in `tests/examples/asio-module` that refer to the
deleted `tests/examples/asio` member. Do not rewrite unrelated package docs.

## 7. Compatibility impact

This is an intentional package-identity replacement:

| Old dependency | New state |
| --- | --- |
| `compat.asio@1.38.1` | removed; header-only consumption unsupported |
| `chriskohlhoff.asio@1.38.1` | removed; no alias retained |
| `asio@1.38.1` | canonical module package |

Existing module consumers migrate with:

```bash
mcpp remove chriskohlhoff.asio
mcpp add asio@1.38.1
```

Their C++ source remains `import std; import asio;`. They must regenerate the
lockfile/build state so the retired namespace does not remain pinned.

Historical index artifacts remain historical; do not rewrite or manually
republish them. The new rolling index simply stops advertising the two retired
identities.

## 8. Test-first implementation sequence

1. Create a topic branch from the latest `origin/main`.
2. Revert PR #73 and resolve only the root workspace conflict.
3. Change `tests/examples/asio-module` to the bare dependency while the module
   descriptor still has the qualified identity. Run the targeted test and
   record the expected package-not-found failure.
4. Move the descriptor to `pkgs/a/asio.lua` and change its declared identity to
   root `asio`.
5. Update stale descriptor and test comments.
6. Run the targeted test again and inspect its generated lockfile.
7. Run descriptor, mirror, workspace, and diff validation.
8. Commit the module identity migration separately from the PR #73 revert.
9. Push a topic branch and open a focused PR only after explicit authorization.

The Red/Green boundary is the dependency identity: the same module test must
fail before the descriptor rename and pass after it. Do not weaken the module
behavior assertions to make the migration pass.

## 9. Validation

Use the mcpp version pinned by the live `origin/main` workflow. The descriptor
uses existing grammar, so this change does not raise `index.toml`'s client floor
or the workflow pin.

Required local evidence, in order:

1. `git diff --check`;
2. Lua syntax and repository descriptor lint for `pkgs/a/asio.lua`;
3. strict `mcpp xpkg parse pkgs/a/asio.lua`;
4. repository mirror validation, confirming the move did not alter URL/SHA
   tables;
5. the recorded bare-dependency Red before the identity change;
6. `mcpp test -p asio-module` after the identity change;
7. inspection of `tests/examples/asio-module/mcpp.lock`, confirming root package
   `asio` at version `1.38.1` and no retired namespace;
8. a search proving that no active descriptor, workspace dependency, or
   consumer instruction still advertises `compat.asio` or
   `chriskohlhoff.asio`;
9. the workspace scope selected by the current validation workflow.

The implementation PR must pass every Linux, macOS, and Windows job created by
the live workflow. One local platform is not evidence for all declared
platforms.

## 10. Risks and mitigations

| Risk | Mitigation |
| --- | --- |
| The revert removes later workspace members | Resolve `mcpp.toml` manually and review the complete final member list |
| The recipe changes during the identity move | Review the move with whitespace-insensitive diff and compare archive/hash/build blocks |
| A stale qualified dependency survives | Search active manifests and inspect the generated lockfile |
| Header-only support is accidentally retained | Require both the descriptor and `tests/examples/asio` tree to be absent |
| Existing qualified-token consumers break unexpectedly | State the breaking migration explicitly in the PR and package comments |
| Module behavior regresses | Keep and run all five existing module tests on the three-platform CI matrix |

## 11. Acceptance criteria

- `pkgs/c/compat.asio.lua` and `tests/examples/asio` no longer exist;
- `pkgs/c/chriskohlhoff.asio.lua` no longer exists;
- exactly one Asio descriptor exists at `pkgs/a/asio.lua`;
- that descriptor declares root package `asio@1.38.1`;
- `mcpp add asio@1.38.1` followed by a build imports module `asio`;
- `mcpp add chriskohlhoff.asio@1.38.1` is not claimed or tested as supported;
- the generated lockfile contains only the root Asio identity;
- all five existing module tests pass without reduced assertions;
- all active `compat.asio` and qualified-token instructions are removed;
- archives, hashes, mirrors, platforms, module wrapper, and build defines are
  unchanged;
- no mcpp core change, alias package, forwarding package, feature split, mirror
  upload, or manual index publication is included.
