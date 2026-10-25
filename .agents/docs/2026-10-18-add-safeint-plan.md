# Add SafeInt 3.0.28a as compat.safeint

## Source and shape

- Upstream: <https://github.com/dcleblanc/SafeInt>.
- Version: `3.0.28a`, the newest upstream tag. The local checkout is 25
  commits past that tag, so the package pins the release rather than an
  untagged development snapshot.
- License: MIT.
- Shape: Form B, header-only. `SafeInt.hpp`, `safe_math.h`, and
  `safe_math_impl.h` are at the archive root, so `include_dirs = { "*" }`
  matches upstream's CMake INTERFACE include directory. A trivial anchor C TU
  supplies mcpp's buildable `safeint` lib target.
- No features: the archive has no optional compilable library component.
  Upstream's tests are intentionally excluded.

Upstream provides two public APIs. `SafeInt.hpp` implements the C++
`SafeInt<T>` class. `safe_math.h` provides checked C arithmetic for 32- and
64-bit integers. `safe_math.h` raises `#error` when `SafeInt.hpp` has already
been included, so the test project exercises them from separate translation
units.

## Download and mirror

- GLOBAL:
  `https://github.com/dcleblanc/SafeInt/archive/refs/tags/3.0.28a.tar.gz`
- SHA-256:
  `9e652d065a3cef80623287d5dc61edcf6a95ddab38a9dfeb34f155261fc9cef7`
- The archive was downloaded twice and the bytes compared; both downloads had
  the same digest.
- No verified `mcpp-res/safeint` release is available, so the descriptor uses
  the repository's plain-string upstream URL fallback. It does not invent a CN
  mirror. A maintainer can add a byte-identical GitCode release later.

## Test member

Two members are registered in the root workspace because mcpp builds every
`tests/*.cpp` as an independent executable (they are tests, not object files
linked into one binary):

- `tests/examples/safeint/`: SafeInt addition, subtraction, multiplication and
  division; successful and rejected `SafeCast`; and overflow and
  divide-by-zero exception codes.
- `tests/examples/safeint-c-api/`: checked add/subtract/multiply/divide through
  `safe_math.h`, including rejection of `INT32_MAX * 2`. The header is wrapped
  in `extern "C"` here because upstream's own C++ linkage spelling is
  inconsistent, while the intended consumer is C.

Every assertion affects the process exit status (`return ok ? 0 : 1`).

## Verification

- Pinned mcpp `2026.10.1.2`, the version in `validate.yml`:
  `mcpp xpkg parse --all-os pkgs/c/compat.safeint.lua` reports `parse OK` for
  linux, macosx, and windows.
- Pinned cold test:
  `mcpp test -p safeint -p safeint-c-api --cache off` reports
  `workspace result ok. 2 member(s); 2 passed; 0 failed`.
- Full relevant lint passed: Lua syntax, mirror URL policy, package identity,
  reserved namespaces, cross-package references, platform parity, and
  duplicate versions.
- A direct GCC 16.2.1 compile against the local checkout also ran both tests:
  `safeint OK` and `safeint C API OK`.
