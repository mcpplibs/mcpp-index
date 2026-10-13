# Add compat.openmp

LLVM libomp 22.1.8 is a separable CMake project inside llvm-project.
The descriptor downloads the full official llvm-project-22.1.8.src.tar.xz,
whose SHA-256 was checked twice; license Apache-2.0 WITH LLVM-exception.
The install hook builds upstream openmp/ and installs the generated omp.h
and real runtime. It writes the C anchor only after installation succeeds.

Unix uses static libomp.a, which implements both Clang and GCC OpenMP ABIs
without a C++ standard-library ABI dependency. The hook uses the system C/C++
SDK explicitly because installation precedes mcpp consumer toolchain selection.
Windows uses the upstream-supported DLL/import library with Visual Studio 2022;
the DLL is declared as a runtime artifact directory for consumer deployment.
CMake and Python are declared build dependencies. Offloading and OMPT tools
are disabled; there is no misleading sources-only feature for these builds.

No mirror upload was performed. Plain-string GLOBAL URLs provide CN fallback.
The example redirects compat to this checkout. It enables OpenMP with normal
GCC/Clang flags (Apple Clang uses -Xclang -fopenmp), links the package runtime,
launches two threads, and checks thread identity plus a reduction sum. The
header never defines _OPENMP: a missing compiler flag is a compile error.

Local validation with CI-pinned mcpp 2026.10.1.2 and gcc 16.1.0:
`mcpp test -p openmp`: `test result ok. 1 passed; 0 failed`.
An independent upstream CMake build also succeeded. Cross-platform behavior
is validated by the PR CI matrix rather than inferred from a SIMD-only test.
