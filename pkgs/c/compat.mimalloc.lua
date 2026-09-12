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
-- The list below is upstream's own `mi_sources` (CMakeLists.txt:75-93), which is
-- the only authoritative answer to "which files are TUs".
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
        },
        macosx = {
            ["3.4.5"] = {
                url = {
                    GLOBAL = "https://github.com/microsoft/mimalloc/archive/refs/tags/v3.4.5.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mimalloc/releases/download/3.4.5/mimalloc-3.4.5.tar.gz",
                },
                sha256 = "19a43af0645c57d348e729d5b31e23e912582911bb1047f795790834d3416221",
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
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        c_standard   = "c11",
        include_dirs = { "*/include" },
        sources = {
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
            "*/src/prim/prim.c",
        },
        targets = { ["mimalloc"] = { kind = "lib" } },
        deps    = {},
        linux = {
            -- CMakeLists.txt:618-626 -- pthread for thread state, rt for
            -- clock_gettime/shm, atomic for the 64-bit atomics on targets
            -- where libatomic is not folded into libgcc.
            ldflags = { "-lpthread", "-lrt", "-latomic" },
        },
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
        },
    },
}
