# Retire `compat.asio` and expose the Asio module through the bare package token

Date: 2026-07-20

## 1. Decision

Retire the transitional header-only package introduced by mcpplibs/mcpp-index
PR #73. The public Asio integration will be module-only:

```cpp
import std;
import asio;
```

Keep one published package identity and one implementation descriptor:

- package identity: `chriskohlhoff.asio@1.38.1`;
- qualified dependency token: `chriskohlhoff.asio@1.38.1`;
- bare dependency token: `asio@1.38.1`;
- C++ module name: `asio`.

Both dependency tokens must resolve to the same descriptor and the same locked
package identity. No forwarding package, second recipe, or header-only feature
will remain. Achieving that contract requires a narrowly scoped mcpp resolver
fix before the index change is published; moving the descriptor alone is not
sufficient.

## 2. Scope

This change will:

1. canonicalize peer-root descriptor hits in mcpp to their declared package
   identity;
2. release that resolver behavior and adopt the release in mcpp-index;
3. revert the repository content introduced by PR #73;
4. preserve the module package introduced by PR #80;
5. move the module descriptor from
   `pkgs/c/chriskohlhoff.asio.lua` to `pkgs/a/asio.lua`;
6. retain `package.namespace = "chriskohlhoff"` and
   `package.name = "chriskohlhoff.asio"` inside that descriptor;
7. remove module documentation that still describes `compat.asio` as a
   companion or fallback;
8. add consumer coverage for both qualified and bare dependency tokens.

This change will not:

- retain `#include <asio.hpp>` as a supported package contract;
- add `features` for header-only/module selection;
- add a meta-package or forwarding dependency;
- change the Asio 1.38.1 source archives, mirrors, SHA-256 values, module
  wrapper, supported platforms, or separate-compilation defines;
- add a general-purpose package alias schema or change qualified-selector
  semantics unrelated to peer-root identity canonicalization.

## 3. Revert boundary

PR #73 was squash-merged as the single-parent commit
`b3ebdd15bc3b56dc61cb91ab5b592200f713709f`. The implementation must therefore
start with:

```bash
git revert b3ebdd15bc3b56dc61cb91ab5b592200f713709f
```

It must not use `git revert -m 1`; `-m` is only for reverting a merge commit.

The reverse patch removes:

- `.agents/docs/2026-07-17-add-asio-plan.md`;
- `pkgs/c/compat.asio.lua`;
- `tests/examples/asio/mcpp.toml`;
- the six header-only tests under `tests/examples/asio/tests/`;
- the `tests/examples/asio` workspace member.

Applying the revert to the current `origin/main` conflicts only in the root
`mcpp.toml`, because later PRs added adjacent workspace members. Resolve that
conflict by removing only `tests/examples/asio`; retain
`tests/examples/asio-module` and every later member.

The implementation PR should keep the generated revert commit as the first
commit, then add the module-token migration as a second commit. This preserves
the provenance of the retired package while keeping the new behavior reviewable.

## 4. Descriptor identity and lookup

The descriptor moves as follows:

```text
pkgs/c/chriskohlhoff.asio.lua
    -> pkgs/a/asio.lua
```

Only the repository path changes. These descriptor fields remain unchanged:

```lua
namespace = "chriskohlhoff"
name      = "chriskohlhoff.asio"
```

The current mcpp resolver treats descriptor filenames as lookup hints and the
declared `(namespace, short name)` as the package identity. The new filename
lets the current lookup layer find both requested spellings:

1. A bare `asio` selector produces default and peer-root candidates. The
   peer-root lookup checks `asio.lua`, then accepts the descriptor by its
   declared short name `asio`.
2. A qualified `chriskohlhoff.asio` selector first checks the qualified
   filename and then the supported bare-filename fallback. It finds
   `asio.lua` and verifies the declared namespace `chriskohlhoff`.
3. The selected dependency coordinate must then be canonicalized to the
   descriptor identity before installation, graph deduplication, and lockfile
   generation.

Step 3 is not true in the current mcpp implementation. When the peer-root
candidate has an empty namespace, `selectDependencyCandidate` keeps that empty
namespace even after reading a descriptor that explicitly declares
`chriskohlhoff`. The immediate effects are:

- the bare dependency is installed and locked as a root `asio` coordinate;
- the qualified dependency is installed and locked as
  `chriskohlhoff.asio`;
- a graph containing both spellings can treat them as two package instances
  and encounter duplicate exported module `asio` definitions.

The mcpp prerequisite must fix the source of that divergence. When an empty
peer-root candidate matches a descriptor with an explicit namespace,
candidate selection must replace the selected coordinate with the descriptor's
canonical `(namespace, short name)`. For this package, both inputs then become
`(chriskohlhoff, asio)` before fetch, deduplication, and lock serialization.

This rule is intentionally narrower than a general alias facility:

- it applies only after an existing peer-root lookup has found and
  identity-verified a descriptor;
- it does not add new filename candidates or scan arbitrary descriptors;
- root packages whose descriptors declare no namespace remain root packages;
- qualified selectors continue to require an exact declared namespace.

`mcpp add` itself only writes the dependency token to `mcpp.toml`; resolution
happens during the subsequent build or test. Validation must therefore run a
consumer build and inspect the resulting lockfile rather than treating a
successful `mcpp add` command as proof.

## 5. Compatibility lifetime

The index-only solution intentionally uses mcpp's non-canonical descriptor
filename fallback. The current resolver source marks this compatibility path
for removal in mcpp 1.0.0.

Consequences:

- the design is valid for the current workflow-pinned mcpp and current index;
- a new mcpp release containing peer-root identity canonicalization is required
  before the retirement PR can merge;
- `index.toml` and every active workflow pin must adopt that release together;
- before mcpp 1.0.0 removes the fallback, the ecosystem must either introduce
  a first-class package alias mechanism or choose one canonical dependency
  token;
- the retirement PR must state this migration obligation explicitly instead
  of presenting the bare filename as a permanent alias contract.

The descriptor must not omit or falsify its declared identity to make lookup
easier. Identity verification remains authoritative.

## 6. Consumer tests

Keep `tests/examples/asio-module` as the qualified-token consumer. It continues
to declare:

```toml
[dependencies.chriskohlhoff]
asio = "1.38.1"
```

Add a small second workspace member, `tests/examples/asio-short`, for the bare
token. It redirects the default index to this checkout and declares:

```toml
[indices]
default = { path = "../../.." }

[dependencies]
asio = "1.38.1"
```

The short-token member needs one focused test that imports `std` and `asio`,
constructs an `asio::io_context`, runs a posted operation, and returns nonzero
if the operation did not execute. The existing `asio-module` member remains
the comprehensive module API suite; duplicating its five tests in the alias
member would add maintenance without increasing selector coverage.

The regression contract is:

| Consumer | Dependency spelling | Required result |
| --- | --- | --- |
| `asio-module` | `chriskohlhoff.asio@1.38.1` | imports and exercises module `asio` |
| `asio-short` | `asio@1.38.1` | imports and exercises the same module |
| both | generated `mcpp.lock` | namespace is `chriskohlhoff`; version is `1.38.1` |

The implementation should first add the bare-token consumer while the
descriptor still has the qualified filename and record the expected lookup
failure. After moving the descriptor but before applying the mcpp fix, record
the namespace/duplicate-identity failure. The mcpp canonicalization change is
the Green condition for the complete two-token contract.

## 7. Documentation cleanup

The current module descriptor still calls `compat.asio` its header-only
companion and recommends it for unsupported module APIs. Those statements
become false once PR #73 is reverted.

Update the descriptor comments to state:

- the package is module-only;
- consumers use `import std; import asio;`;
- `mcpp add asio@1.38.1` and
  `mcpp add chriskohlhoff.asio@1.38.1` currently select the same package;
- APIs not exported by the wrapper are unavailable through this package;
- `#include <asio.hpp>` is outside the supported mcpp-index contract.

Also remove comparison comments in `tests/examples/asio-module` that point to
the deleted header-only member. Do not rewrite unrelated package documentation.

## 8. Delivery sequence

Deliver the work in two repositories and do not merge the index change against
an unreleased mcpp commit.

### Phase A: mcpp resolver

1. Add a failing e2e case based on the existing custom-namespace,
   non-canonical-filename fixture. Request the package once by its bare short
   name and once by its qualified name in the same graph.
2. Assert that the current resolver produces different coordinates or a
   duplicate-module failure.
3. Canonicalize an identity-verified empty peer-root hit to the descriptor's
   declared identity.
4. Assert one resolved package instance, one exported module, and a lockfile
   namespace matching the descriptor.
5. Run the relevant unit/e2e suites and the complete mcpp verification required
   by its contribution workflow.
6. Merge and release mcpp through the normal release process.

### Phase B: mcpp-index retirement

1. Raise `index.toml`'s `min_mcpp` and every active validation pin to the new
   release in the same commit.
2. Revert PR #73 and resolve only the root workspace conflict.
3. Move the module descriptor to `pkgs/a/asio.lua` without changing its recipe.
4. Add the bare-token member and update stale module comments.
5. Run targeted and workspace validation on all workflow platforms.
6. Open a focused revert/migration PR; maintainers merge it.

## 9. Validation

Use the newly released mcpp version after Phase A. Required index-side local
evidence, in order:

1. `git diff --check`;
2. Lua syntax and repository descriptor lint for `pkgs/a/asio.lua`;
3. strict `mcpp xpkg parse pkgs/a/asio.lua`;
4. repository mirror validation, proving URL/SHA tables were not damaged by
   the move;
5. preserved mcpp-side Red/Green evidence for peer-root canonicalization;
6. `mcpp test -p asio-short` after the move;
7. inspection of `tests/examples/asio-short/mcpp.lock` for
   `namespace = "chriskohlhoff"` and `version = "1.38.1"`;
8. `mcpp test -p asio-module` to preserve qualified-token behavior;
9. the workspace scope selected by the current validation workflow.

The PR must pass every Linux, macOS, and Windows job instantiated by the live
workflow. One local host is not evidence for all declared platforms.

## 10. Risks and mitigations

| Risk | Mitigation |
| --- | --- |
| The revert deletes the module workspace member | Resolve `mcpp.toml` manually and review the final member list |
| Bare lookup keeps an empty namespace | Require the mcpp canonicalization release before raising the index floor |
| Both spellings produce duplicate module instances | Add a mixed-spelling graph test in mcpp and assert one resolved identity |
| Qualified lookup breaks after the filename move | Keep the existing qualified consumer unchanged and run it after the move |
| Stale comments advertise header-only support | Search the changed tree for `compat.asio`, `header-only`, and `#include <asio.hpp>` |
| The fallback disappears in mcpp 1.0.0 | Record a release-blocking alias/canonical-name migration follow-up before 1.0.0 |
| Archive or platform behavior changes accidentally | Move the descriptor without changing its xpm, hashes, recipe, or platform blocks |

## 11. Acceptance criteria

- the prerequisite mcpp release canonicalizes an identity-verified peer-root
  hit to the descriptor's declared namespace;
- `index.toml` and every active workflow use that release or newer;
- `pkgs/c/compat.asio.lua` and `tests/examples/asio` no longer exist;
- no header-only Asio package is published by this index;
- exactly one Asio 1.38.1 implementation descriptor exists at
  `pkgs/a/asio.lua`;
- that descriptor still declares `chriskohlhoff.asio`;
- both dependency spellings build and import module `asio`;
- both lockfiles identify the package as `chriskohlhoff.asio@1.38.1`;
- existing module behavior and three-platform coverage remain green;
- the PR documents that bare-filename fallback is temporary through the
  pre-1.0 compatibility window;
- no forwarding package, mirror upload, or unrelated resolver change is
  included.
