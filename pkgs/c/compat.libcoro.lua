-- compat.libcoro — C++20 coroutine primitives: tasks, generators, a thread
-- pool, and the synchronisation objects (`event`, `mutex`, `semaphore`,
-- `condition_variable`) that are awaitable rather than blocking.
--
-- Shape A over the eight core TUs. The whole descriptor is one decision:
--
-- ── NETWORKING IS OUT, AND THE TARBALL DECIDES THAT, NOT US ────────────────
--
-- Upstream defaults `LIBCORO_FEATURE_NETWORKING` to ON, and its networking
-- half resolves DNS through c-ares, which it takes from `vendor/c-ares` — a
-- GIT SUBMODULE. A GitHub archive never contains submodules, so in this
-- tarball that directory is EMPTY (measured: `find vendor -type f` → 0 files).
-- Networking cannot be built from the artifact this index pins, full stop.
-- It is the same shape that made `mcpplibs.grpc` need its own repository.
--
-- So the source list is exactly upstream's `LIBCORO_SOURCE_FILES` before the
-- `if(LIBCORO_FEATURE_NETWORKING)` block appends to it, transcribed rather
-- than globbed — a `*/src/**/*.cpp` glob would pull in `scheduler.cpp`,
-- `poll.cpp`, the epoll/kqueue notifiers and all of `net/`, none of which
-- self-guard, and every one of which would fail to compile without the
-- feature's headers and c-ares.
--
-- What that leaves is the half most consumers actually import: `coro::task`,
-- `coro::generator`, `coro::sync_wait`, `coro::when_all`, `coro::thread_pool`
-- and the awaitable synchronisation types. A renderer that wants coroutines
-- for asset loading needs precisely this and no sockets.
--
-- A future `networking` feature is expressible without changing anything here:
-- this index already carries `compat.c-ares`, so the feature would add the
-- `net/` sources plus `scheduler`/`poll`/the per-platform notifier and depend
-- on that package instead of the empty vendor directory. It is not done now
-- because nothing in the index asks for it and it cannot be tested on a CI
-- runner as cheaply as the core can.
--
-- Consumers must NOT define `LIBCORO_FEATURE_NETWORKING`: `coro/coro.hpp`
-- keys its umbrella includes off that macro (`#ifdef LIBCORO_FEATURE_NETWORKING`),
-- and defining it would open headers whose translation units this package
-- deliberately does not build, giving link errors rather than a diagnostic.
--
-- ── One generated header, and it is not optional ───────────────────────────
--
-- `coro/export.hpp` does not exist in the tarball: upstream produces it with
-- `generate_export_header(libcoro BASE_NAME CORO EXPORT_FILE_NAME
-- include/coro/export.hpp)`, and `coro/semaphore.hpp` opens it on line 5. So a
-- build without it dies immediately with
--
--     include/coro/semaphore.hpp:5:10: fatal error: coro/export.hpp: No such file or directory
--
-- The snapshot below is CMake's own output shape for `BASE_NAME CORO`, and
-- `CORO_STATIC_DEFINE` goes in `defines` rather than `cxxflags` because the
-- macro decorates DECLARATIONS a consumer includes — package-private flags
-- would leave every consumer importing symbols from a shared library that is
-- not being built.
--
-- Requires a C++20 coroutine-capable compiler, which every toolchain this
-- index ships is; there is no flag to add on gcc/clang at C++23.
--
-- CN mirror: `gitcode.com/mcpp-res/libcoro`, the upstream tarball re-hosted
-- BYTE-IDENTICALLY (verified: the mirror's sha256 equals the one declared
-- here, which is what lets one `sha256` serve both arms). GLOBAL stays the
-- default; CN is the fallback `mcpp self config --mirror CN` selects.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "libcoro",
    description = "libcoro — C++20 coroutine tasks, generators, thread pool and awaitable synchronisation",
    licenses    = {"Apache-2.0"},
    repo        = "https://github.com/jbaldwin/libcoro",
    type        = "package",

    xpm = {
        linux = {
            ["0.16.0"] = {
                url    = {
                    GLOBAL = "https://github.com/jbaldwin/libcoro/archive/refs/tags/v0.16.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/libcoro/releases/download/0.16.0/libcoro-0.16.0.tar.gz",
                },
                sha256 = "895ca24e6c73b994423fc187c86c635f5c2f20a1def2886b7397c40236f4c33b",
            },
        },
        macosx = {
            ["0.16.0"] = {
                url    = {
                    GLOBAL = "https://github.com/jbaldwin/libcoro/archive/refs/tags/v0.16.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/libcoro/releases/download/0.16.0/libcoro-0.16.0.tar.gz",
                },
                sha256 = "895ca24e6c73b994423fc187c86c635f5c2f20a1def2886b7397c40236f4c33b",
            },
        },
        windows = {
            ["0.16.0"] = {
                url    = {
                    GLOBAL = "https://github.com/jbaldwin/libcoro/archive/refs/tags/v0.16.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/libcoro/releases/download/0.16.0/libcoro-0.16.0.tar.gz",
                },
                sha256 = "895ca24e6c73b994423fc187c86c635f5c2f20a1def2886b7397c40236f4c33b",
            },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        c_standard   = "c11",
        include_dirs = { "*/include", "mcpp_generated" },

        generated_files = {
            ["mcpp_generated/coro/export.hpp"] = [==[
/* generate_export_header(libcoro BASE_NAME CORO), reproduced for a static build. */
#ifndef CORO_EXPORT_H
#define CORO_EXPORT_H

#ifdef CORO_STATIC_DEFINE
#  define CORO_EXPORT
#  define CORO_NO_EXPORT
#else
#  if defined(_MSC_VER)
#    ifdef libcoro_EXPORTS
#      define CORO_EXPORT __declspec(dllexport)
#    else
#      define CORO_EXPORT __declspec(dllimport)
#    endif
#    define CORO_NO_EXPORT
#  else
#    define CORO_EXPORT    __attribute__((visibility("default")))
#    define CORO_NO_EXPORT __attribute__((visibility("hidden")))
#  endif
#endif

#ifndef CORO_DEPRECATED
#  if defined(_MSC_VER)
#    define CORO_DEPRECATED __declspec(deprecated)
#  else
#    define CORO_DEPRECATED __attribute__((__deprecated__))
#  endif
#endif

#ifndef CORO_DEPRECATED_EXPORT
#  define CORO_DEPRECATED_EXPORT CORO_EXPORT CORO_DEPRECATED
#endif

#ifndef CORO_DEPRECATED_NO_EXPORT
#  define CORO_DEPRECATED_NO_EXPORT CORO_NO_EXPORT CORO_DEPRECATED
#endif

#endif /* CORO_EXPORT_H */
]==],
        },

        -- Upstream's LIBCORO_SOURCE_FILES, core half, in its order.
        sources = {
            "*/src/detail/task_self_deleting.cpp",
            "*/src/condition_variable.cpp",
            "*/src/default_executor.cpp",
            "*/src/event.cpp",
            "*/src/mutex.cpp",
            "*/src/semaphore.cpp",
            "*/src/sync_wait.cpp",
            "*/src/thread_pool.cpp",
        },

        targets = { ["libcoro"] = { kind = "lib" } },
        deps    = { },

        defines = { "CORO_STATIC_DEFINE" },

        linux = {
            -- The thread pool and the awaitable primitives are threads.
            ldflags = { "-lpthread" },
        },
    },
}
