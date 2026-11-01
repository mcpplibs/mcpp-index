-- compat.mimalloc — Microsoft's general-purpose allocator, built as a static lib.
--
-- Shape A (C-source compat): the user writes `#include <mimalloc.h>` and calls
-- mi_malloc / mi_free / mi_heap_* directly.
--
-- WHY THE SOURCE LIST IS ENUMERATED AND NOT A GLOB.
-- `src/*.c` would be wrong three times over, and each way is a link error
-- rather than a compile error:
--
--   src/static.c          is an amalgamation -- it #includes the whole library
--                         into one TU, so globbing it alongside the others
--                         duplicates every symbol.
--   src/free.c            is #included BY alloc.c (`#include "free.c"`, alloc.c:22),
--   src/alloc-override.c   likewise (alloc.c:21). Neither is a standalone TU.
--
-- The list below is upstream's own `mi_sources` (CMakeLists.txt:75-93 in 3.4.5,
-- 107-135 in 3.6.1), which is the only authoritative answer to "which files are
-- TUs". The two releases lay the same library out differently, and one list
-- names both layouts: a name that is not in a release's tree selects nothing
-- there.
--
-- `src/prim/prim.c` is a dispatcher: it #includes the platform implementation
-- (prim/unix, prim/windows, prim/osx, …) for the host it is compiled on, so one
-- entry covers all three platforms with no per-platform source lists.
--
-- OVERRIDE IS OFF, which is the right default for a package. mimalloc can
-- replace the global malloc/free, but only when MI_MALLOC_OVERRIDE is defined
-- (alloc-override.c:13) -- and a dependency silently taking over the process
-- allocator is not something an index package should decide for its consumer.
-- The mi_* API is unaffected.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "mimalloc",
    description = "mimalloc — compact general-purpose allocator with excellent performance",
    licenses    = {"MIT"},
    repo        = "https://github.com/microsoft/mimalloc",
    type        = "package",

    xpm = {
        linux = {
            ["3.4.5"] = {
                url = {
                    GLOBAL = "https://github.com/microsoft/mimalloc/archive/refs/tags/v3.4.5.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mimalloc/releases/download/3.4.5/mimalloc-3.4.5.tar.gz",
                },
                sha256 = "19a43af0645c57d348e729d5b31e23e912582911bb1047f795790834d3416221",
            },
            ["3.6.1"] = {
                url = {
                    GLOBAL = "https://github.com/microsoft/mimalloc/archive/refs/tags/v3.6.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mimalloc/releases/download/3.6.1/mimalloc-3.6.1.tar.gz",
                },
                sha256 = "2672e6a99d4579fb4bb32d9de0d63aa424ce600d31fbfaf06eb74d940d2e07a6",
            },
        },
        macosx = {
            ["3.4.5"] = {
                url = {
                    GLOBAL = "https://github.com/microsoft/mimalloc/archive/refs/tags/v3.4.5.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mimalloc/releases/download/3.4.5/mimalloc-3.4.5.tar.gz",
                },
                sha256 = "19a43af0645c57d348e729d5b31e23e912582911bb1047f795790834d3416221",
            },
            ["3.6.1"] = {
                url = {
                    GLOBAL = "https://github.com/microsoft/mimalloc/archive/refs/tags/v3.6.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mimalloc/releases/download/3.6.1/mimalloc-3.6.1.tar.gz",
                },
                sha256 = "2672e6a99d4579fb4bb32d9de0d63aa424ce600d31fbfaf06eb74d940d2e07a6",
            },
        },
        windows = {
            ["3.4.5"] = {
                url = {
                    GLOBAL = "https://github.com/microsoft/mimalloc/archive/refs/tags/v3.4.5.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mimalloc/releases/download/3.4.5/mimalloc-3.4.5.tar.gz",
                },
                sha256 = "19a43af0645c57d348e729d5b31e23e912582911bb1047f795790834d3416221",
            },
            ["3.6.1"] = {
                url = {
                    GLOBAL = "https://github.com/microsoft/mimalloc/archive/refs/tags/v3.6.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mimalloc/releases/download/3.6.1/mimalloc-3.6.1.tar.gz",
                },
                sha256 = "2672e6a99d4579fb4bb32d9de0d63aa424ce600d31fbfaf06eb74d940d2e07a6",
            },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        c_standard   = "c11",
        include_dirs = { "*/include" },
        -- Upstream builds as gnu11; this recipe builds as c11, under which a C
        -- library declares nothing beyond ISO C unless asked. 3.6.1's
        -- `prim/prim.c' includes headers before `prim/unix/prim.c' states
        -- `_DEFAULT_SOURCE' for itself, so `syscall' and `madvise' arrive
        -- undeclared; stating it for every unit is what gnu11 did.
        cflags = { "-D_DEFAULT_SOURCE" },
        sources = {
            -- 3.4.5: one directory.
            "*/src/alloc.c",
            "*/src/alloc-aligned.c",
            "*/src/alloc-posix.c",
            "*/src/arena.c",
            "*/src/arena-meta.c",
            "*/src/bitmap.c",
            "*/src/heap.c",
            "*/src/init.c",
            "*/src/libc.c",
            "*/src/options.c",
            "*/src/os.c",
            "*/src/page.c",
            "*/src/page-map.c",
            "*/src/random.c",
            "*/src/stats.c",
            "*/src/theap.c",
            "*/src/threadlocal.c",
            -- 3.6.1: the same library in seven directories, and three units
            -- the earlier layout did not have (profile/). `alloc/free.c' and
            -- `alloc/alloc-override.c' are included by `alloc/alloc.c', as
            -- `free.c' was by `alloc.c'.
            "*/src/prim/os.c",
            "*/src/prim/prim-tls.c",
            "*/src/util/libc.c",
            "*/src/util/options.c",
            "*/src/util/random.c",
            "*/src/util/stats.c",
            "*/src/util/threadlocal.c",
            "*/src/arena/arena.c",
            "*/src/arena/arena-alloc.c",
            "*/src/arena/arena-page.c",
            "*/src/arena/bitmap.c",
            "*/src/arena/bitmap-chunk.c",
            "*/src/alloc/alloc.c",
            "*/src/alloc/alloc-generic.c",
            "*/src/alloc/alloc-aligned.c",
            "*/src/alloc/alloc-posix.c",
            "*/src/alloc/page.c",
            "*/src/alloc/page-queue.c",
            "*/src/heap/heap.c",
            "*/src/heap/process.c",
            "*/src/heap/page-map.c",
            "*/src/heap/subproc.c",
            "*/src/heap/theap.c",
            "*/src/profile/sample-guarded.c",
            "*/src/profile/sample-profile.c",
            "*/src/profile/pprof.c",
            -- Both.
            "*/src/prim/prim.c",
        },
        targets = { ["mimalloc"] = { kind = "lib" } },
        deps    = {},
        linux = {
            -- CMakeLists.txt (3.6.1: 886-898) -- pthread for thread state, rt
            -- for clock_gettime/shm.
            --
            -- NOT `-latomic`, which upstream links only where it finds the
            -- library ("detected automatically"): mimalloc's atomics are
            -- lock-free on every architecture this index builds for, and a
            -- toolchain without the archive (the LLVM one, above a C library
            -- of the graph) failed the link on its name alone.
            ldflags = { "-lpthread", "-lrt" },
        },
        -- AN OK IMAGE (openkal SPEC 12) NAMES NOTHING AT ITS LINK. Its C library
        -- supplies threads and clocks, and an image imports `kal_*` alone; an
        -- ok target otherwise reads the `linux` block, whose `-lpthread` and
        -- `-lrt` name archives an image's link does not have. The key is
        -- written out: a block with no key is read as no block.
        openkal = { ldflags = {} },
        macosx = {
            ldflags = { "-lpthread" },
        },
        windows = {
            -- CMakeLists.txt:614 -- psapi/bcrypt for process memory info and
            -- the RNG seed, the rest for the Win32 primitives.
            --
            -- `runtime.libraries` rather than `ldflags`: ldflags reach the
            -- linker verbatim, and link.exe drops a GNU `-lpsapi` with
            -- "LNK4044: unrecognized option; ignored" -- silently, until the
            -- consumer's link ends in unresolved externals. This spelling is
            -- rendered per dialect (psapi.lib / -lpsapi).
            runtime = {
                libraries = { "psapi", "shell32", "user32", "advapi32", "bcrypt" },
            },

            -- `__builtin_thread_pointer()` IS NOT AVAILABLE FOR EVERY OS THE
            -- TRIPLE CAN NAME, AND THE FAILURE IS A BACKEND CRASH.
            --
            -- prim-tls.h:176 turns the builtin on for x86_64 with clang >= 14
            -- unless `__APPLE__`, `__CYGWIN__` or `MI_LIBC_MUSL` says
            -- otherwise. Two of those three would have excluded this target
            -- and neither reaches it: mcpp suppresses `__CYGWIN__` on purpose,
            -- because source must not read the realisation triple as a
            -- statement about Cygwin, and `MI_LIBC_MUSL` is a build option
            -- upstream expects the packager to set ("Enable this when linking
            -- with musl libc", CMakeLists.txt:39) rather than something it
            -- detects. So the guard passes, and LLVM has no lowering for the
            -- builtin on this OS:
            --
            --     fatal error: error in backend: Target OS doesn't support
            --                  __builtin_thread_pointer() yet.
            --
            -- prim-tls.h:176 opens with `#if !defined(...) /* allow user
            -- override */`, so the answer is to give it one. This is the
            -- Windows branch, and on a Win32 target the setting is not read at
            -- all --- `_WIN32` selects `NtCurrentTeb()` three arms earlier ---
            -- so it changes only the target that has no `_WIN32`.
            --
            -- WHAT THIS FIXES AND WHAT IT DOES NOT. The cell goes from
            -- `fails: error: build failed` to `builds`: the backend crash is
            -- gone and the member compiles and links for this target. Its
            -- `alloc` test then passes under one Wine and exits 1 under the
            -- one this repository's CI installs, so the published reading is
            -- `builds` rather than `runs`. That remainder is a separate
            -- question about the TLS path the override falls back to, and it
            -- is recorded here rather than folded into this one so the next
            -- reader does not take a green build for a green test.
            cflags = { "-DMI_USE_BUILTIN_THREAD_POINTER=0" },
        },
    },
}
