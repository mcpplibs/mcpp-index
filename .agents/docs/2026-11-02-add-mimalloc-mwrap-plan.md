# Add mcpplibs.mwrap.mimalloc (mimalloc-m 3.6.1)

## Form

- Third-party upstream [microsoft/mimalloc](https://github.com/microsoft/mimalloc), release v3.6.1, MIT. The library is
  `compat.mimalloc` 3.6.1 of this index (`pkgs/c/compat.mimalloc.lua`), the archive openkal-musl 0.26.0 embeds.
- Form A external mwrap module repository [mcpplibs/mimalloc-m](https://github.com/mcpplibs/mimalloc-m), package
  `mcpplibs.mwrap.mimalloc`, version 3.6.1 (first release of the identity), tag `mwrap-3.6.1` on the merged main commit
  (`0582ff7`); release asset `mimalloc-m-3.6.1.tar.gz` (`62ae5121…9abe`), CN mirror `gitcode.com/mcpp-res/mwrap-mimalloc`
  with identical bytes.
- Implementation ownership: the library is compat.mimalloc's. The wrapper vendors no upstream code; it retains upstream's
  README.md and LICENSE under `upstream/mimalloc/` with checksums in `upstream/documents.json`, and deploys them with its
  own LICENSE/NOTICE (`runtime.deploy`). The adaptation a C library needs to embed mimalloc is in that C library
  (openkal-musl `port/src/mimalloc`), not here (mcpp design 2026-11-02 part 3 §7.1).

## Modules

- `mcpplibs.mwrap.mimalloc`: the functions, heaps, arenas, sub-processes, options and STL allocators of `<mimalloc.h>`
  by `export using`, in the global namespace where upstream declares them; it re-exports the three below.
- `mcpplibs.mwrap.mimalloc.stats` (`<mimalloc-stats.h>`) and `mcpplibs.mwrap.mimalloc.profile` (`<mimalloc-profile.h>`);
  upstream's `static inline` helpers (`mi_malloc_csize`, `mi_zalloc_csize`, `mi_free_csize`, `mi_stats_init`,
  `mi_stats_header_init`) adapted under their names in `mcpplibs::mwrap::mimalloc`.
- `mcpplibs.mwrap.mimalloc.macros`: the value macros (`MI_MALLOC_VERSION`, `MI_STAT_VERSION`, `MI_SMALL_SIZE_MAX` …)
  as constants. The macros that take a type (`mi_malloc_tp` and its eleven companions) and `mi_stats_t_decl` stay
  macros, in `<mwrap/mimalloc/macros.hpp>`.

## Verification

- Wrapper CI (Linux x86_64 GCC 16.1 and LLVM 23.1.3, macOS LLVM, Windows LLVM): the module tests, the export check
  (`tools/check_exports.py`) and upstream's `test-api` and `test-stress` over the same library; the default template in
  a workflow of its own.
- `tests/mwrap/mimalloc-heap`: the real release archive through the candidate index; a block that grows and keeps its
  bytes, alignments to 64 KiB, a private heap visited and destroyed, a container over `mi_stl_allocator`, an option,
  blocks freed by another thread, the statistics; and the side header's typed macros beside the import.
- `python3 tests/mwrap/check_installed_template.py --package mcpplibs.mwrap.mimalloc@3.6.1 --deploy`: the unmodified
  default `allocate` template from the real archive, then a relocated bundle whose `licenses/mimalloc/` holds the
  wrapper's LICENSE/NOTICE and mimalloc's README and LICENSE byte for byte.

## Motivation

mcpp design 2026-11-02 part 3 (§7, §7.1): openkal-musl 0.26 embeds mimalloc as the allocator of the ok image, and a
program that wants mimalloc's own interface (heaps, options, statistics) imports it through this module, over the same
`compat.mimalloc`.
