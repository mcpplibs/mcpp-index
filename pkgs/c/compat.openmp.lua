-- compat.openmp — the compiler-facing OpenMP API entry point.
--
-- OpenMP is not a standalone portable library: the compiler supplies the
-- implementation and its ABI runtime (libgomp, libomp or another equivalent).
-- This package deliberately does not vendor one of those runtimes, because
-- selecting a runtime independently of the compiler can mix incompatible
-- OpenMP ABIs. It provides the standard header through a stable package-owned
-- forwarding directory and an anchor target so projects can depend on the
-- OpenMP API explicitly.
--
-- A project still needs to select OpenMP in its toolchain (for example
-- `-fopenmp` with GCC/Clang). The compiler's own omp.h and runtime remain the
-- source of truth.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "openmp",
    description = "OpenMP API package — forwards the selected compiler's omp.h without bundling an ABI-specific runtime",
    licenses    = {"Apache-2.0 WITH LLVM-exception"},
    repo        = "https://github.com/llvm/llvm-project/tree/main/openmp",
    type        = "package",

    xpm = {
        linux = {
            ["22.1.8"] = {
                url    = "https://raw.githubusercontent.com/llvm/llvm-project/llvmorg-22.1.8/openmp/LICENSE.TXT",
                sha256 = "fdad1758a9e1f9d5a81e18879b3406772115edc92c24bfa36b70c654f325e8e4",
            },
        },
        macosx = {
            ["22.1.8"] = {
                url    = "https://raw.githubusercontent.com/llvm/llvm-project/llvmorg-22.1.8/openmp/LICENSE.TXT",
                sha256 = "fdad1758a9e1f9d5a81e18879b3406772115edc92c24bfa36b70c654f325e8e4",
            },
        },
        windows = {
            ["22.1.8"] = {
                url    = "https://raw.githubusercontent.com/llvm/llvm-project/llvmorg-22.1.8/openmp/LICENSE.TXT",
                sha256 = "fdad1758a9e1f9d5a81e18879b3406772115edc92c24bfa36b70c654f325e8e4",
            },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        c_standard   = "c11",
        include_dirs = {"mcpp_generated"},
        generated_files = {
            ["mcpp_generated/omp.h"] = [==[
/* Use the compiler/runtime header when the toolchain ships one. */
#if defined(__has_include_next)
#  if __has_include_next(<omp.h>)
#include_next <omp.h>
#  else
#    define MCPP_OPENMP_HEADER_FALLBACK
#  endif
#else
#  define MCPP_OPENMP_HEADER_FALLBACK
#endif

/*
 * Apple Clang does not ship omp.h unless a separate OpenMP runtime is
 * installed. Keep the standard API usable for source that only needs the
 * OpenMP language interface; a compiler/runtime package can provide the
 * complete header and takes the include_next path above.
 */
#ifdef MCPP_OPENMP_HEADER_FALLBACK
#  define _OPENMP 202011
#  ifdef __cplusplus
extern "C" {
#  endif
int omp_get_max_threads(void);
int omp_get_num_threads(void);
int omp_get_thread_num(void);
#  ifdef __cplusplus
}
#  endif
#endif
]==],
            ["mcpp_generated/openmp_anchor.c"] =
                "int mcpp_compat_openmp_anchor(void) { return 0; }\n",
        },
        sources = {"mcpp_generated/openmp_anchor.c"},
        targets = {["openmp"] = {kind = "lib"}},
        deps = {},
    },
}
