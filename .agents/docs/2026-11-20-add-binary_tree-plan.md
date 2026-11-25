# Add yandere-chan.binary_tree 0.1.4

## Source and shape

- Upstream: <https://github.com/YandereChan2/binary_tree>.
- Version: `0.1.4`, tagged on the commit that exports the global
  `operator new` / `operator delete` using-declarations from the module
  interfaces (namespace `yandere-chan` was introduced in 0.1.3).
- License: MIT.
- Shape: Form A (mcpp-native library). The tarball carries
  `binary_tree-0.1.4/mcpp.toml`; that manifest is the build. It declares:
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
`Yc.binary_tree` and `Yc.parent_aware_binary_tree`; module names are
independent of the package namespace.

## The libc++ placement-new problem and the export fix

The Linux LLVM run (clang + libc++) failed on 0.1.0 with:

```
libc++ __memory/allocator_traits.h:362: error: no matching function for call to '__construct_at'
construct_at.h:43: ... no matching 'operator new' function
                   for non-allocating placement new expression; include <new>
```

`std::allocator_traits::construct` instantiates libc++'s `__construct_at`,
whose default template argument uses placement new. Adding `<new>` to the
module's global module fragment is not enough: clang's combined
single-invocation module build (`-x c++-module -fmodule-output=... -c`, the
mode mcpp uses) does not make the GMF declaration **visible** to the importer,
even though it is reachable. The lookup happens when the consumer instantiates
the template, so `import binary_tree;` alone failed. See
llvm/llvm-project#218246 (and the earlier #59601), which lists the same two
workarounds: instantiate in the defining module, or re-declare the missing
declaration in the importing TU.

0.1.4 takes a third route that keeps the consumer clean: each module interface
exports a using-declaration for the global placement `operator new` and its
matching `operator delete`:

```cpp
export module Yc.binary_tree;

import Yc.intrusive_binary_tree;

export using ::operator new;
export using ::operator delete;
```

The using-declarations are exported names (not declarations of new entities),
so an importer can look placement new up without including `<new>`, and a
consumer that *does* include `<new>` still compiles. The declarations must
come after the imports: GCC requires post-module imports to be contiguous.
Clang, MSVC and GCC 16.1 all accept the form; the umbrella module re-exports
it through `export import`.

0.1.0-0.1.3 are not listed: all carry the old `YandereChan2` namespace and
predate this export.

## Download and mirror

- GLOBAL:
  `https://github.com/YandereChan2/binary_tree/releases/download/0.1.4/binary_tree-0.1.4.tar.gz`
  (a `git archive` of tag `0.1.4`, uploaded as the release asset; the tarball
  root is `binary_tree-0.1.4/`)
- SHA-256:
  `e7bd88adaa156219d87db05cbe4bc0dd5447ee7c7736f138f0870ebdfa706853`
- No `mcpp-res` mirror is available, so the descriptor uses the repository's
  plain-string upstream URL fallback. No CN mirror is invented; a maintainer
  can add a byte-identical GitCode release later.
- `extensions.autoupdate` uses the bare tag and the tag-archive template
  (`archive/refs/tags/${tag}.tar.gz`), so a future release needs no uploaded
  asset for the updater to compute its sha.

## Test member

- `tests/examples/binary_tree-module/` has two test files:
  - `binary_tree_module.cpp` imports the lib root and each wrapper and asserts
    insert / in-order `for_each` / copy / `parent_of_cnroot` / intrusive-node
    behavior;
  - `binary_tree_umbrella.cpp` imports only `binary_tree` (umbrella-only) and
    asserts the same construction path, which proves the re-exported
    placement-new declarations reach an importer that never includes `<new>`.

  Neither file includes `<new>` or any library header. Every check affects the
  process exit status.
- The member carries its own
  `[indices] yandere-chan = { path = "../../.." }` so the dependency resolves
  to the checked-in descriptor rather than the published remote index.

## Verification

- Pinned mcpp `2026.11.18.1`, the version in `validate.yml`:
  `mcpp xpkg parse pkgs/y/yandere-chan.binary_tree.lua` reports `parse OK`
  for linux, macosx and windows, and recognizes Form A.
- `mcpp test -p binary_tree-module --cache off` downloads the 0.1.4 asset,
  compiles both tests without `<new>`, and both pass.
- The same manifest builds with `mcpp build` (clang + MSVC STL),
  `mcpp build --toolchain msvc@system`; all four `.cppm` compile with GCC
  16.1 (`-fmodules`).
- A minimal clang 23.1.3 combined-mode repro of the placement-new bug
  (`module; #include <new>` + direct placement new) fails without the export
  and passes with it; MSVC 14.51 and GCC 16.1 accept the exported form.

## Notes

- The export is a workaround for the clang module bug, not a permanent API
  requirement. If a future clang makes GMF scopes visible to importers, the
  using-declarations can be dropped.
- The POC set headers `rb_set.h` / `avl_set.h` import
  `parent_aware_binary_tree.h` as a header unit on MSVC; that path is not part
  of this package.
- The package is platform-independent: the same tarball and sha are used for
  linux, macosx and windows.
