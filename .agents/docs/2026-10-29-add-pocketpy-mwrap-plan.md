# Add mcpplibs.mwrap.pocketpy (pocketpy-m 2.2.0)

## Form

- Third-party upstream [pocketpy/pocketpy](https://github.com/pocketpy/pocketpy), release v2.2.0 (2026-09-04), MIT.
  The tag archive (`c67cb6a1…e8b3`) is the one compat.pocketpy 2.2.0 pins (#620).
- Form A external mwrap module repository [mcpplibs/pocketpy-m](https://github.com/mcpplibs/pocketpy-m), package
  `mcpplibs.mwrap.pocketpy`, version 2.2.0 (first release of the identity, no revision suffix), tag series
  `mwrap-${version}` on the merged main commit (`9bd4c52`); release asset `pocketpy-m-2.2.0.tar.gz` (`bcc3174f…5024`).
  No CN mirror yet (docs/cn-mirror.md fallback).
- Implementation ownership: the interpreter is compat.pocketpy's (one unity translation unit of every src/**/*.c, as
  upstream's CMake builds it; PK_ENABLE_OS 1, THREADS 0, DLL 0, DETERMINISM 1 with `-ffp-contract=off`, WATCHDOG 1;
  upstream's fix de8351ed applied in install()). The wrapper vendors no upstream code. It retains upstream's README.md
  and LICENSE under `upstream/pocketpy/`, with checksums in `upstream/documents.json`, and deploys them with its own
  LICENSE/NOTICE (`runtime.deploy`).

## Modules

- `mcpplibs.mwrap.pocketpy`: by `export using`, generated from the pinned public header (`pocketpy.h` with config.h,
  export.h, vmath.h): 29 types, 91 enumerators, 246 functions. pocketpy.h has no `static inline` API.
- `mcpplibs.mwrap.pocketpy.macros`: 65 of the 82 macros: constants (`PK_VERSION`, `PK_ENABLE_*` as the library is
  built, limits, platform), functions (type tests, registers, `py_offset`, `py_assign`, `PK_MALLOC`/`PK_REALLOC`/
  `PK_FREE`, `py_callcfunc` for either NDEBUG state) and the exception helpers (`TypeError` … as variadic templates
  over `py_exception`).
- Stay macros, in `<mwrap/pocketpy/macros.hpp>` (= `<pocketpy.h>`): `PY_CHECK_ARGC`, `PY_CHECK_ARG_TYPE`, `py_arg`.
  Excluded with reasons: the annotations (`PK_API`, `PY_RAISE` …) and the `PK_ENABLE_OS=0` debugger forms.

`tools/check_exports.py` fails when the generated module is stale, a declaration is not exported, or a macro is neither
mapped nor listed; the mappings are checked against the raw header in a header-mixing test.

## Verification

Wrapper CI (Linux x86_64 GCC 16.1 and LLVM 23.1.3, Linux arm64 GCC 16.1, macOS LLVM, Windows LLVM, wasm32-emscripten
under node; dev and release profiles): the embedding API through the module, the constants against
`pkpy.configmacros`, the header beside the import, the export audit, and upstream's 92 `tests/*.py` from source and
compiled to `.pyc` on examples/pkpy (all pass; the lz4, msgpack and thread tests skip themselves).

Here, with the CI-pinned mcpp 2026.10.27.1:

- `bash tests/run_members.sh pocketpy-embed`: the real release archive through the candidate index; exec and eval read
  back, a dict walked, a C function called from Python, errors with their messages and the VM going on, code re-run,
  the watchdog; and the side header beside the import: `test result ok`.
- `python3 tests/mwrap/check_installed_template.py --package mcpplibs.mwrap.pocketpy@2.2.0 --deploy`: the unmodified
  default `script` template from the real archive, then a relocated bundle whose `licenses/pocketpy/` holds the
  wrapper's LICENSE/NOTICE and PocketPy's README and LICENSE byte for byte.

## Motivation

openmui embeds scripts as a C++ module import (Lua and QuickJS-ng so far); PocketPy adds Python with the same shape:
a VM to create and reset, source to exec and eval, results to read back, native functions to register, errors as
messages and never aborts, and deterministic floats on every platform, the Web included.
