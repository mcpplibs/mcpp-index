# Adding compat.wamr (WebAssembly Micro Runtime 2.4.5)

Shape decision, mirror status, feature evaluation, verification results, and the
things a later reader should not have to rediscover.

## Source and shape

Upstream is [bytecodealliance/wasm-micro-runtime](https://github.com/bytecodealliance/wasm-micro-runtime),
Apache-2.0 WITH LLVM-exception, pure C. Latest tag at time of writing is
`WAMR-2.4.5` (`git ls-remote --tags | sort -V | tail`). It offers no mcpp
support, so this is case (a) — a third-party upstream adapted as `compat`.

Shape is **C-source compat**, the same template as `compat.mbedtls`: a source
glob compiled into one static archive with the public headers exposed. The
tarball wraps everything in `wasm-micro-runtime-WAMR-2.4.5/`, absorbed by the
leading `*/` in every glob.

`sha256 = 1ab09d51099f276ca4a1d6629f6b589aab2bd0caa01445e05031a4bed22c199b`,
computed twice on separate downloads to rule out a repacking archive source.

## The one thing this shape could not express: per-architecture selection

WAMR needs architecture-specific input in two places, and the descriptor schema
has a per-OS hook but no per-architecture one (`archs` is package metadata that
declares support, not a selector).

1. **A `BUILD_TARGET_*` define.** The whole invoke-native section of
   `core/iwasm/common/wasm_runtime_common.c` sits inside
   `#if defined(BUILD_TARGET_X86_64) || defined(BUILD_TARGET_AMD_64) ||
   defined(BUILD_TARGET_AARCH64) || …`. With none defined the file still
   compiles — it just contains no `invokeNative` caller — and the failure
   arrives at link time. Upstream's CMake sets the right one from
   `WAMR_BUILD_TARGET`.
2. **The `invokeNative` implementation**, which is hand-written assembly, one
   file per architecture under `core/iwasm/common/arch/`.

Both are resolved by moving the decision into the preprocessor, which does know
the target:

* `generated_files` emits `mcpp_generated/include/mcpp_wamr_config.h`, mapping
  `__x86_64__`/`__aarch64__` to the matching `BUILD_TARGET_*` and erroring out
  on anything else. It reaches every TU through `cflags = { "-include",
  "mcpp_wamr_config.h" }`, the mechanism `compat.zlib` already uses for
  `Z_HAVE_UNISTD_H`.
* `generated_files` also emits `mcpp_generated/mcpp_wamr_invoke_native.S`,
  which `#include`s the chosen `arch/invokeNative_*.s` as text.

**Why the dispatcher must be `.S` and the upstream files could not simply be
listed.** `compat.libffi` lists `src/x86/unix64.S` and friends directly and lets
each guard itself, because those are uppercase `.S` — clang runs the
preprocessor on them. WAMR's are lowercase `.s`, which clang assembles with no
preprocessing at all, so an `#ifdef` inside them is not evaluated. (They do
contain `#ifndef BH_PLATFORM_DARWIN`, which upstream's build does honour; that
guard starts working again once the file is pulled into a `.S`.) Listing all of
them is also not an option: each defines `invokeNative`, and the aarch64 file
does not assemble on x86_64.

Verified directly, before any mcpp involvement:

```
$ clang -c mcpp_wamr_invoke_native.S -I…/common/arch -o x64.o && nm x64.o | grep -i invokenative
0000000000000000 T invokeNative
$ clang --target=aarch64-unknown-linux-gnu -c mcpp_wamr_invoke_native.S -I…/common/arch -o a64.o && nm a64.o | grep -i invokenative
0000000000000000 T invokeNative
```

## `-std=gnu11` through cflags, not `c_standard`

`core/shared/platform/linux/platform_internal.h` writes the GS base with a bare
`asm volatile`. `c_standard = "c11"` emits `-std=c11`, which defines
`__STRICT_ANSI__`, under which `asm` is not a keyword — only `__asm__` is — and
`wasm_memory.c` and `wasm_interp_fast.c` both fail with *use of undeclared
identifier 'asm'*. Appending `-std=gnu11` via `cflags` wins over the earlier
flag and matches how upstream builds.

The alternative is `-DWASM_DISABLE_WRITE_GS_BASE=1`, a real upstream knob that
also compiles cleanly (both call sites are the only bare-`asm` uses in the
build). It was not chosen: it turns off an x86_64 fast path to work around a
language-mode choice, which is a behaviour change made for a formatting reason.

This is adjacent to the `compat.libaio` lesson — there `-std=c11` hid
`syscall()` and `sigset_t` behind `__STRICT_ANSI__` disabling `_DEFAULT_SOURCE`,
fixed with `-D_GNU_SOURCE`. Same macro, different consequence; `_GNU_SOURCE`
does not help with the `asm` keyword.

## Linux only, on purpose

`xpm` carries a `linux` section and nothing else, and consumers gate with
`[target.'cfg(linux)'.dependencies]` — the `compat.libaio` shape. WAMR itself is
portable: there are `core/shared/platform/darwin` and `…/windows` trees, and the
assembly files carry Darwin guards that this descriptor's `.S` dispatcher would
honour. macOS is likely to be a small delta. But neither macOS nor Windows was
built or run here, and Windows additionally has an unresolved choice between
upstream's MASM `.asm` and the MinGW `.s` variant. Declaring a platform because
it looks symmetric is how a red CI job gets iterated on blind, so the sections
are left for someone who can verify them.

The single-platform `xpm` keeps `check_platform_version_parity.lua` quiet by
design: it only compares platforms that both carry versions.

## What the base is, and why

Interpreter runtime only — classic and fast interpreter, bulk memory and
reference types (both on in upstream's own default configuration), no AOT, no
JIT, no guest-facing libc. That is what an embedder wants when wasm modules are
plugins reached only through host-provided imports, and it keeps AOT's LLVM
dependency out of the index entirely.

Sources follow upstream's cmake fragments: `iwasm/common/*.c`
(`iwasm_common.cmake`), the loader + runtime + one interpreter from
`iwasm_interp.cmake`, `shared/platform/linux/*.c` plus `platform/common/posix`
(`shared_platform.cmake` → `platform_api_posix.cmake`), `mem_alloc.c` + `ems/`
(`mem_alloc.cmake` — its `tlsf/` glob matches nothing in 2.4.5), and
`shared/utils/*.c` (`shared_utils.cmake`).

`wasm_mini_loader.c` and `wasm_interp_classic.c` are deliberately absent: they
are upstream's *alternatives* to `wasm_loader.c` and `wasm_interp_fast.c`, not
additions, and listing both would define the same symbols twice.

## Features

Both were evaluated against the ABI rule that keeps `compat.recastnavigation`'s
`DT_POLYREF64` out of a feature: a feature's `defines` reach only the package's
own TUs, so a macro that changes the layout of a type crossing the library
boundary cannot be a feature. Neither macro here does — `WASM_ENABLE_LIBC_WASI`
and `WASM_ENABLE_LIBC_BUILTIN` appear **zero** times in `core/iwasm/include/`
outside comments, so a consumer compiling without them sees the same
`wasm_export.h` the library was built against.

* **`libc-builtin`** — `libraries/libc-builtin/*.c` plus
  `WASM_ENABLE_LIBC_BUILTIN=1`. One TU.
* **`libc-wasi`** — `libraries/libc-wasi/**/*.c` plus `WASM_ENABLE_LIBC_WASI=1`
  **and `WASM_ENABLE_MODULE_INST_CONTEXT=1`**. The second define is not
  optional and not obvious: `build-scripts/runtime_lib.cmake:97-99` sets
  `WAMR_BUILD_MODULE_INST_CONTEXT` whenever `WAMR_BUILD_LIBC_WASI` is on, and
  without it `wasm_native.c` calls `wasm_native_get_context`,
  `wasm_native_set_context` and the context-key helpers that `wasm_native.h`
  only declares under that macro.

### Two things the feature table cannot do, and what was done instead

**A feature cannot carry `include_dirs`.** With `WASM_ENABLE_LIBC_WASI=1`,
`common/wasm_runtime_common.h` itself opens `#include "posix.h"`, so it is not
only the feature's own sources that need the WASI header roots —
`wasm_loader.c` and `wasm_runtime.c` stop compiling without them. The five
header roots therefore live in the base `include_dirs`, where they cost nothing
when the features are off (they are `-I` paths into directories no base source
includes from).

**An exclusion glob is global and beats a feature's own entry for the same
file.** Upstream's `platform_api_posix.cmake` drops `posix_file.c`,
`posix_clock.c` and `posix_socket.c` (and pulls in `libc-util`) only when WASI
is on, and the natural translation is `!`-exclusions in the base with the
feature adding them back. That produced a build that compiled and then failed
to link:

```
ld.lld: error: undefined symbol: os_file_get_access_mode
ld.lld: error: undefined symbol: os_is_dir_stream_valid
ld.lld: error: undefined symbol: os_closedir
```

Each was referenced from `libc-wasi/sandboxed-system-primitives/src/posix.c`,
i.e. the feature's own sources, while the file defining them stayed excluded.
All four files were then compiled individually **with WASI off** and all four
succeeded, so the base simply carries them unconditionally. The cost is a few KB
of unreferenced objects the linker drops.

## Verification

CI's pinned mcpp (`MCPP_VERSION: 2026.8.27.2`, matching `index.toml`'s
`min_mcpp`) was used throughout, with `MCPP_INDEX_MIRROR=GLOBAL`.

Descriptor:

```
$ mcpp xpkg parse pkgs/c/compat.wamr.lua
package    compat.wamr (namespace 'compat')
versions   linux    2.4.5
sources    11        includes   16
generated  mcpp_generated/include/mcpp_wamr_config.h (679 bytes)
generated  mcpp_generated/mcpp_wamr_invoke_native.S (724 bytes)
target     wamr      features   2
parse OK
```

Lint, reproduced locally: lua syntax, required fields, no leading `v`,
`check_mirror_urls.lua`, `check_package_name.lua`, no `c++fly` — plus
`check_cross_package_refs.lua`, `check_duplicate_versions.lua` and
`check_platform_version_parity.lua`. All pass.

Members, from a cleaned `target/` and `.mcpp/` **and a cleared global build
cache**, so both runs show `Compiling compat.wamr` rather than `Cached`:

```
$ mcpp test -p wamr
compute(6,7) = 42 (expected 42)
expecting env.putchar to be unlinked (libc-builtin is off):
  exception: Exception: failed to call unlinked import function (env, putchar)
libc-builtin gated out: yes
run_module ... ok
 test result ok. 1 passed; 0 failed

$ mcpp test -p wamr-features
libc-builtin load            ok
libc-builtin instantiate     ok
libc-builtin putchar call    ok
libc-wasi load               ok
libc-wasi instantiate        ok
  call=0 exception=Exception: wasi proc exit exit_code=3
libc-wasi proc_exit linked   ok
libc-wasi exit code          ok
libc_features ... ok
 test result ok. 1 passed; 0 failed
```

### What the tests actually assert, and one dead end

Both modules are hand-assembled wasm bytes in the test source, so nothing here
needs a wasm toolchain at build time.

`tests/examples/wamr` runs a module that calls **back into the host**:
`compute(6,7)` returns 42 only because a native `host_mul` was invoked through
`invokeNative`. That is the assertion that notices a missing `BUILD_TARGET_*` or
a mis-dispatched assembly file; a "does it link" test would not.

The feature gate is asserted in both directions — positively in
`wamr-features`, negatively in `wamr`, where the same `env.putchar` module must
be refused.

**The dead end worth recording:** the negative check was first written as *does
the module instantiate*. It does. WAMR does not reject an unresolved import at
load or instantiation — it logs `warning: failed to link import function (env,
putchar)` and carries on, and the refusal only materialises when the guest calls
the import, as `Exception: failed to call unlinked import function`. Any feature
gate test for this package has to call, not instantiate.

Two smaller ones: `putchar_wrapper` returns **1**, not the character written, so
an assertion copied from C's `putchar` contract fails; and WAMR refuses to load
a module importing WASI apis unless it exports a memory (*"a module with WASI
apis must export memory by default"*), so the WASI test module carries a
one-page memory and exports it.

## CN mirror

Not created — no `mcpp-res` write access. `url` uses the plain-string upstream
form, which lint accepts and which makes CN users fall back to GitHub. A
maintainer can promote it to `{ GLOBAL=…, CN=… }` after mirroring the identical
tarball.

## Note on the skill's step 8

`.agents/skills/add-mcpp-index-package` says to add a row to the category table
in `README.md` and `README.zh-CN.md`. Those tables no longer exist — the README
now points at the online index site and keeps only a short "Reference examples"
list. The equivalent record was added to `docs/descriptor-examples.md` and
`docs/zh/descriptor-examples.md` instead, as a new shape row: *C-source compat
whose sources are chosen by architecture*.
