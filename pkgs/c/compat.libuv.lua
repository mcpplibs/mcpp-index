-- compat.libuv — libuv 1.48.0, multi-platform async I/O library.
--
-- Shape A (C-source compat): the exact per-OS source sets from upstream's own
-- CMakeLists (`uv_sources` + the platform blocks), listed explicitly because
-- `src/unix/*.c` is NOT a safe glob — it holds one file per OS (aix.c, linux.c,
-- darwin.c, …) and compiling a foreign one fails. The 12 common files in
-- `src/*.c` are shared by every platform; each platform block adds its own.
-- `*/src` is on the include path for the package's own compile because
-- src/unix/internal.h does `#include "uv-common.h"` (lives in src/).
--
-- VERSION. 1.48.0 (2024-04) is the classic, widely-shipped release — it is
-- the libuv of the Ubuntu 24.04 LTS line and was the long-standing vcpkg
-- default before the 2025 releases; redis-plus-plus's async interface only
-- needs "libuv 1.x", so the battle-tested LTS-era pick is the right one.
--
-- Windows: link libs and defines mirror upstream CMakeLists verbatim
-- (psapi user32 advapi32 iphlpapi userenv ws2_32 dbghelp ole32 shell32).
--
-- No CN mirror yet: plain-string upstream URL (see compat.hiredis).
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "libuv",
    description = "Multi-platform asynchronous I/O library (static, upstream per-OS source sets)",
    licenses    = {"MIT"},
    repo        = "https://github.com/libuv/libuv",
    type        = "package",

    extensions = {
        autoupdate = {
            tag = "v${version}",
            url = "https://github.com/libuv/libuv/archive/refs/tags/${tag}.tar.gz",
        },
    },

    xpm = {
        linux = {
            ["1.48.0"] = {
                url    = "https://github.com/libuv/libuv/archive/refs/tags/v1.48.0.tar.gz",
                sha256 = "8c253adb0f800926a6cbd1c6576abae0bc8eb86a4f891049b72f9e5b7dc58f33",
            },
        },
        macosx = {
            ["1.48.0"] = {
                url    = "https://github.com/libuv/libuv/archive/refs/tags/v1.48.0.tar.gz",
                sha256 = "8c253adb0f800926a6cbd1c6576abae0bc8eb86a4f891049b72f9e5b7dc58f33",
            },
        },
        windows = {
            ["1.48.0"] = {
                url    = "https://github.com/libuv/libuv/archive/refs/tags/v1.48.0.tar.gz",
                sha256 = "8c253adb0f800926a6cbd1c6576abae0bc8eb86a4f891049b72f9e5b7dc58f33",
            },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        c_standard   = "c99",   -- upstream CMake's C_STANDARD floor is 90; c99 is a safe superset

        include_dirs = { "*/include", "*/src" },

        -- Common 12 TUs (upstream `uv_sources`), every platform.
        sources = { "*/src/*.c" },

        targets = { ["uv"] = { kind = "lib" } },
        deps    = {},

        -- Linux: 18 unix TUs + proctitle.c + the linux block. Defines and link
        -- libs mirror upstream CMakeLists' Linux block.
        linux = {
            sources = {
                "*/src/unix/async.c", "*/src/unix/core.c", "*/src/unix/dl.c",
                "*/src/unix/fs.c", "*/src/unix/getaddrinfo.c", "*/src/unix/getnameinfo.c",
                "*/src/unix/loop-watcher.c", "*/src/unix/loop.c", "*/src/unix/pipe.c",
                "*/src/unix/poll.c", "*/src/unix/process.c", "*/src/unix/random-devurandom.c",
                "*/src/unix/signal.c", "*/src/unix/stream.c", "*/src/unix/tcp.c",
                "*/src/unix/thread.c", "*/src/unix/tty.c", "*/src/unix/udp.c",
                "*/src/unix/proctitle.c",
                "*/src/unix/linux.c", "*/src/unix/procfs-exepath.c",
                "*/src/unix/random-getrandom.c", "*/src/unix/random-sysctl-linux.c",
            },
            cflags  = { "-D_FILE_OFFSET_BITS=64", "-D_LARGEFILE_SOURCE", "-D_GNU_SOURCE", "-D_POSIX_C_SOURCE=200112" },
            ldflags = { "-lpthread", "-ldl", "-lrt" },
        },

        -- macOS: 18 unix TUs + proctitle + the APPLE-or-BSD extras + darwin set.
        macosx = {
            sources = {
                "*/src/unix/async.c", "*/src/unix/core.c", "*/src/unix/dl.c",
                "*/src/unix/fs.c", "*/src/unix/getaddrinfo.c", "*/src/unix/getnameinfo.c",
                "*/src/unix/loop-watcher.c", "*/src/unix/loop.c", "*/src/unix/pipe.c",
                "*/src/unix/poll.c", "*/src/unix/process.c", "*/src/unix/random-devurandom.c",
                "*/src/unix/signal.c", "*/src/unix/stream.c", "*/src/unix/tcp.c",
                "*/src/unix/thread.c", "*/src/unix/tty.c", "*/src/unix/udp.c",
                "*/src/unix/proctitle.c", "*/src/unix/bsd-ifaddrs.c", "*/src/unix/kqueue.c",
                "*/src/unix/random-getentropy.c", "*/src/unix/darwin-proctitle.c",
                "*/src/unix/darwin.c", "*/src/unix/fsevents.c",
            },
            cflags  = { "-D_FILE_OFFSET_BITS=64", "-D_LARGEFILE_SOURCE", "-D_DARWIN_UNLIMITED_SELECT=1", "-D_DARWIN_USE_64_BIT_INODE=1" },
            ldflags = { "-lpthread" },
        },

        -- Windows: the 25 src/win/*.c TUs (the glob is safe — every .c under
        -- src/win/ is library code; tests live in test/).
        windows = {
            sources = { "*/src/win/*.c" },
            -- NDEBUG: upstream redis-plus-plus#575 — EventLoop::LoopDeleter's
            -- uv_walk re-closes handles already uv_close'd by hiredis's libuv
            -- adapter cleanup (on Windows they are still in the loop's handle
            -- queue at teardown, unlike unix where the closing phase runs
            -- first). uv_close has a UV_HANDLE_CLOSING guard that makes the
            -- second call a harmless no-op; only the assert(0) aborts, so a
            -- release-style build (NDEBUG, matching vcpkg/conan libuv) fixes
            -- it. Unfixable package-side otherwise without shadowing
            -- event_loop.cpp. Regression: PR #195 windows workspace leg.
            cflags  = { "-DWIN32_LEAN_AND_MEAN", "-D_WIN32_WINNT=0x0602", "-D_CRT_DECLARE_NONSTDC_NAMES=0", "-DNDEBUG" },
            -- libuv 1.53 uses WaitOnAddress/WakeByAddressSingle; match its
            -- upstream synchronization.lib dependency. Also safe for 1.48.
            ldflags = { "-lpsapi", "-luser32", "-ladvapi32", "-liphlpapi", "-luserenv", "-lws2_32", "-ldbghelp", "-lole32", "-lshell32", "-lsynchronization" },
        },
    },
}
