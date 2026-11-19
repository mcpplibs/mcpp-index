# Add YandereChan2.binary_tree 0.1.2

## Source and shape

- Upstream: <https://github.com/YandereChan2/binary_tree>.
- Version: `0.1.2`, tagged on the commit that adds the package's own
  `mcpp.toml`, the module root and the libc++-correct `<new>` include order.
- License: MIT.
- Shape: Form A (mcpp-native library). The tarball carries
  `binary_tree-0.1.2/mcpp.toml`; that manifest is the build. It declares:
  - `include_dirs = ["."]` — the header library (`binary_tree.h`,
    `parent_aware_binary_tree.h`, `intrusive_binary_tree.h`, `union_data.h`,
    and the POC sets) stays a normal header interface;
  - sources `Yc.intrusive_binary_tree.cppm`, `Yc.binary_tree.cppm`,
    `Yc.parent_aware_binary_tree.cppm` and `src/binary_tree.cppm`;
  - `[lib] path = "src/binary_tree.cppm"` — the lib root re-exports the three
    wrappers, so `import binary_tree;` reaches all of them and `mcpp pack` has
    a module interface to publish.
- No features and no dependencies: the library is header/module only.

The four public modules are `binary_tree`, `Yc.intrusive_binary_tree`,
`Yc.binary_tree` and `Yc.parent_aware_binary_tree`.

## 0.1.2 vs 0.1.0/0.1.1 — the libc++ fix

0.1.0 passed the Windows (MSVC STL) and GCC builds, but the Linux LLVM run
(clang + libc++) failed to instantiate `insert`/`emplace`:

```
libc++ __memory/allocator_traits.h:362: error: no matching function for call to '__construct_at'
construct_at.h:43: candidate template ignored: ... no matching 'operator new' function
                   for non-allocating placement new expression; include <new>
```

`std::allocator_traits::construct` uses placement new. MSVC STL and libstdc++
pull `<new>` in transitively; libc++ does not. 0.1.1 added `#include <new>`
but placed it after `<memory>`, which is too late: libc++'s
`allocator_traits`/`construct_at` is parsed while `<memory>` is being read,
and the placement-new lookup happens at that definition point. 0.1.2 includes
`<new>` **before** `<memory>` in `binary_tree.h`, `parent_aware_binary_tree.h`,
`intrusive_binary_tree.h` and `cookie_allocator.h`, and in the global module
fragments of the three module interfaces. 0.1.0 and 0.1.1 are therefore not
listed in the index descriptor.

## Download and mirror

- GLOBAL:
  `https://github.com/YandereChan2/binary_tree/releases/download/0.1.2/binary_tree-0.1.2.tar.gz`
  (a `git archive` of tag `0.1.2`, uploaded as the release asset; the tarball
  root is `binary_tree-0.1.2/`)
- SHA-256:
  `4c537f68af5cddd0e6e3c28aae5663414cd68c609eeb26513694c5e2c1e8fa21`
- The asset was downloaded again after upload and the digest compared; both
  bytes and digest match.
- No `mcpp-res` mirror is available, so the descriptor uses the repository's
  plain-string upstream URL fallback. No CN mirror is invented; a maintainer
  can add a byte-identical GitCode release later.
- `extensions.autoupdate` uses the bare tag and the tag-archive template
  (`archive/refs/tags/${tag}.tar.gz`), so a future release needs no uploaded
  asset for the updater to compute its sha.

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
- `mcpp test -p binary_tree-module --cache off` downloads the 0.1.2 asset,
  compiles the package and the member, and passes.
- The same manifest in the upstream checkout builds with `mcpp build`
  (clang + MSVC STL), `mcpp build --toolchain msvc@system`, and all four
  module interface units compile with GCC 16.1.
- The prior Linux LLVM failure reported `include <new>`; 0.1.2 is the
  corrected include order for that failure. The libc++ environment itself is
  not available on the packaging machine, so the final proof is the index CI
  Linux run.

## Notes

- The POC set headers `rb_set.h` / `avl_set.h` import
  `parent_aware_binary_tree.h` as a header unit on MSVC. That is a header-only
  consumer path and is not exercised by this package's mcpp build, which
  compiles the module wrappers and the lib root.
- The package is platform-independent: the same tarball and sha are used for
  linux, macosx and windows.
