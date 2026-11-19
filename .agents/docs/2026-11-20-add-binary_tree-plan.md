# Add YandereChan2.binary_tree 0.1.0

## Source and shape

- Upstream: <https://github.com/YandereChan2/binary_tree>.
- Version: `0.1.0`, tagged on the commit that adds the package's own
  `mcpp.toml` and the module root.
- License: MIT.
- Shape: Form A (mcpp-native library). The tag tarball carries
  `binary_tree-0.1.0/mcpp.toml`; that manifest is the build. It declares:
  - `include_dirs = ["."]` — the header library (`binary_tree.h`,
    `parent_aware_binary_tree.h`, `intrusive_binary_tree.h`, `union_data.h`,
    and the POC sets) stays a normal header interface;
  - sources `Yc.intrusive_binary_tree.cppm`, `Yc.binary_tree.cppm`,
    `Yc.parent_aware_binary_tree.cppm` and `src/binary_tree.cppm`;
  - `[lib] path = "src/binary_tree.cppm"` — the lib root re-exports the three
    wrappers, so `import binary_tree;` reaches all of them and `mcpp pack` has
    a module interface to publish.
- No features: the library has no optional compilable component.
- No dependencies: the library is header/module only.

The four public modules are `binary_tree`, `Yc.intrusive_binary_tree`,
`Yc.binary_tree` and `Yc.parent_aware_binary_tree`.

## Download and mirror

- GLOBAL:
  `https://github.com/YandereChan2/binary_tree/archive/refs/tags/0.1.0.tar.gz`
- SHA-256:
  `30bf78e87e958b2147de62e154ea01d3149efafa47ae17b67395e8ae3faf7937`
- The archive was downloaded twice and the digests compared; both downloads
  had the same digest.
- No `mcpp-res` mirror is available, so the descriptor uses the repository's
  plain-string upstream URL fallback. No CN mirror is invented; a maintainer
  can add a byte-identical GitCode release later.

## Test member

- `tests/examples/binary_tree-module/`: imports the lib root `binary_tree`
  and each wrapper module (`Yc.intrusive_binary_tree`, `Yc.binary_tree`,
  `Yc.parent_aware_binary_tree`) with no `#include` and no include path, and
  asserts insert / in-order `for_each` / copy / `parent_of_cnroot` /
  intrusive-node behavior. Every check increments a failure counter, and the
  process exits non-zero if any check fails.
- The member carries its own `[indices] YandereChan2 = { path = "../../.." }`
  so the dependency resolves to the checked-in descriptor rather than the
  published remote index; the key is the dependency namespace.

## Verification

- Pinned mcpp `2026.11.18.1`, the version in `validate.yml`:
  `mcpp xpkg parse pkgs/y/YandereChan2.binary_tree.lua` reports `parse OK`
  for linux, macosx and windows, and recognizes Form A (the `mcpp` pointer,
  no inline segment).
- `mcpp test -p binary_tree-module` builds the package from its tag tarball,
  compiles the member against the imported modules, and passes.
- `mcpp build` and `mcpp build --toolchain msvc@system` in the upstream
  checkout both succeed with the same manifest (validated before tagging).

## Notes

- The POC set headers `rb_set.h` / `avl_set.h` import
  `parent_aware_binary_tree.h` as a header unit on MSVC. That is a header-only
  consumer path and is not exercised by this package's mcpp build, which
  compiles the module wrappers and the lib root.
- The package is platform-independent: the same tarball and sha are used for
  linux, macosx and windows.
