-- compat.concurrentqueue — moodycamel::ConcurrentQueue 1.0.5, Cameron
-- Desrochers' lock-free multi-producer/multi-consumer queue, plus its blocking
-- sibling (BlockingConcurrentQueue, on top of a lightweight semaphore) and the
-- flat C API over both.
--
-- Shape B (header-only), same as compat.gtl / compat.plf-hive: the entire
-- library is `concurrentqueue.h`, `blockingconcurrentqueue.h` and
-- `lightweightsemaphore.h` at the TARBALL ROOT, so `include_dirs = {"*"}` (the
-- `*` absorbs the archive's `concurrentqueue-<ver>/` wrap layer) and a trivial
-- anchor TU are the whole package. Consumers write `#include
-- <concurrentqueue.h>` exactly as upstream's README shows. On Linux the
-- blocking queue's semaphore is POSIX `sem_t` (`<semaphore.h>`), so nothing
-- beyond a C++ compiler is needed — no `_GNU_SOURCE`, no -lpthread dance of
-- its own.
--
-- The one genuinely optional COMPILABLE piece is `c_api/` — two .cpp TUs that
-- wrap the queues behind an `extern "C"` surface
-- (moodycamel_cq_create/enqueue/…). That is exactly the sources-only gate the
-- feature table is for (the compat.cjson `utils` precedent), and it is OFF by
-- default: a consumer that only wants the C++ header does not pay for two
-- TUs. Everything else that upstream leaves out of its library target is
-- header-only (nothing to gate) or carries its own main()/benchmarks (a lib
-- target's objects enter the consumer's link eagerly, so a main() shipped in
-- a package collides with the consumer's — the compat.libaio reasoning).
--
-- WINDOWS AND THE C API. `c_api/concurrentqueue.h` picks its `MOODYCAMEL_EXPORT`
-- spelling on its own: without MOODYCAMEL_STATIC or DLL_EXPORT it assumes a
-- DLL client and declares every function `__declspec(dllimport)`, which is
-- wrong twice here — the package's own .cpp would DEFINE a dllimport function,
-- and a static-archive consumer would try to import what it is about to link.
-- So this package declares MOODYCAMEL_STATIC for both sides: `cxxflags` covers
-- the package's TUs (all two of them are C++; `cflags` would never reach them
-- — the compat.msdfgen lesson), and the feature's `defines` (Feature System
-- v2) covers the consumer's. The macro is only read inside `#ifdef _WIN32`, so
-- defining it unconditionally is inert on linux/macos.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "concurrentqueue",
    description = "moodycamel::ConcurrentQueue — lock-free MPMC queue (header-only)",
    licenses    = {"BSD-2-Clause", "BSL-1.0"},  -- dual-licensed upstream: Simplified BSD or Boost
    repo        = "https://github.com/cameron314/concurrentqueue",
    type        = "package",

    extensions = {
        autoupdate = {
            tag = "v${version}",
            url = "https://github.com/cameron314/concurrentqueue/archive/refs/tags/${tag}.tar.gz",
        },
    },

    xpm = {
        linux = {
            ["1.0.5"] = {
                url    = "https://github.com/cameron314/concurrentqueue/archive/refs/tags/v1.0.5.tar.gz",
                sha256 = "4d6368a27492d86011fde5ca0cf386dce7c49cd425aa3d9b063ca6ec373a6ef3",
            },
        },
        macosx = {
            ["1.0.5"] = {
                url    = "https://github.com/cameron314/concurrentqueue/archive/refs/tags/v1.0.5.tar.gz",
                sha256 = "4d6368a27492d86011fde5ca0cf386dce7c49cd425aa3d9b063ca6ec373a6ef3",
            },
        },
        windows = {
            ["1.0.5"] = {
                url    = "https://github.com/cameron314/concurrentqueue/archive/refs/tags/v1.0.5.tar.gz",
                sha256 = "4d6368a27492d86011fde5ca0cf386dce7c49cd425aa3d9b063ca6ec373a6ef3",
            },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        c_standard   = "c11",

        -- Tarball root: the three public headers live beside the license, so
        -- consumers resolve `<concurrentqueue.h>`, `<blockingconcurrentqueue.h>`
        -- and — with the feature — `<c_api/concurrentqueue.h>`. The root
        -- `concurrentqueue.h` wins over the same-named C API header because
        -- `c_api/` is NOT itself an include dir; the two are reachable only
        -- under distinct paths, so the name overlap never turns into a
        -- shadowing hazard.
        include_dirs = { "*" },

        -- See the header comment: the package's own C++ TUs must not see the
        -- DLL-client default on Windows.
        cxxflags = { "-DMOODYCAMEL_STATIC" },

        -- Header-only: a trivial anchor TU gives mcpp a buildable lib target.
        generated_files = {
            ["mcpp_generated/concurrentqueue_anchor.c"] = "int mcpp_compat_concurrentqueue_anchor(void) { return 0; }\n",
        },
        sources      = { "mcpp_generated/concurrentqueue_anchor.c" },
        targets      = { ["concurrentqueue"] = { kind = "lib" } },

        -- The C API: upstream's two wrapper TUs, compiled into the same lib
        -- target when requested. OFF by default — verified that a consumer
        -- referencing moodycamel_cq_* without the feature fails to LINK
        -- (undefined reference), so the gate is real.
        features     = {
            ["c-api"] = {
                sources = { "*/c_api/*.cpp" },
                -- Consumer side of the MOODYCAMEL_STATIC story above: without
                -- it, Windows consumers inherit the header's dllimport default
                -- and fail at link for a library they are statically linking.
                defines = { "MOODYCAMEL_STATIC" },
            },
        },
        deps         = { },
    },
}
