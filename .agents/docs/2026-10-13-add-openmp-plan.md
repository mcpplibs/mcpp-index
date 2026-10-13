# Add `compat.openmp`

## Shape and source

OpenMP is a compiler language/runtime interface rather than an independently
portable library. GCC and Clang provide `omp.h` and select an ABI runtime
(`libgomp` or `libomp`) when OpenMP is enabled. Shipping a separately built
runtime from the index would allow a project to combine an incompatible runtime
with its compiler, so this entry is a compiler-facing API package rather than a
vendored runtime package.

The descriptor uses a generated forwarding header and a C anchor target. The
forwarder reaches the `omp.h` supplied by the selected compiler with
`#include_next`; the package does not claim to replace the compiler's runtime.
Consumers enable OpenMP in their own build flags, as the test member does with
`-fopenmp`.

The package is pinned to the LLVM 22.1.8 OpenMP source revision for licensing
and version identity. The downloaded license is only an integrity anchor; no
LLVM runtime sources are unpacked or compiled by this descriptor.

## Mirror

No `mcpp-res` upload was performed. The descriptor therefore uses the
plain-string upstream license URL, which is the documented fallback when the
index contributor does not have mirror write access.

## Feature assessment

There are no optional package sources to gate. Runtime selection belongs to the
consumer's compiler/toolchain and cannot be represented safely as a package
feature.

## Test and verification

`tests/examples/openmp` depends on `compat:openmp`, enables `-fopenmp`, includes
`omp.h`, executes an OpenMP SIMD directive, and checks the compiler's `_OPENMP`
macro. It intentionally does not launch a parallel region: the package does not
vendor or select `libgomp`/`libomp`, so linking an ABI-specific runtime is the
consumer toolchain's responsibility. The descriptor passes the package-name,
mirror-url, reserved-namespace, and `mcpp xpkg parse` checks.
