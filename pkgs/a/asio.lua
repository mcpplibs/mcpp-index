-- asio -- standalone Asio 1.38.1 exposed as the C++23 module `asio`
-- (Form B inline descriptor, separate-compilation mode).
--
-- Install and consume:
--     mcpp add asio@1.38.1
--     import std;
--     import asio;
--
-- The upstream 1.38.x release has no module interface unit. This descriptor
-- generates a reviewed `asio.cppm` wrapper and compiles upstream `src/asio.cpp`
-- with ASIO_SEPARATE_COMPILATION. `import std;` is required because this package
-- does not inject the standard library through the module boundary.
--
-- This package is module-only. Textual `#include <asio.hpp>` consumption and
-- APIs not exported by the wrapper are outside its mcpp-index contract. The
-- wrapper intentionally excludes SSL/TLS, local/POSIX/Windows handle APIs,
-- serial ports, pipes, file I/O, stackful spawn, and other surfaces listed by
-- headers that it does not include.
--
-- ASIO_STANDALONE and ASIO_SEPARATE_COMPILATION are public build defines, but
-- preprocessor macros do not cross `import asio;`. Consumers should use C++ or
-- operating-system facilities instead of testing ASIO_HAS_* macros.
package = {
    spec        = "1",
    namespace   = "",
    name        = "asio",
    description = "Standalone asio exposed as the C++23 module `asio` (separate compilation)",
    licenses    = {"BSL-1.0"},
    repo        = "https://github.com/chriskohlhoff/asio",
    type        = "package",

    xpm = {
        linux = {
            ["1.38.1"] = {
                url = {
                    GLOBAL = "https://github.com/chriskohlhoff/asio/archive/refs/tags/asio-1-38-1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/asio/releases/download/1.38.1/asio-1.38.1.tar.gz",
                },
                sha256 = "2827b229972be80cdb14e5497962fa393d1adf036b5869e2b9c99f644daadacc",
            },
        },
        macosx = {
            ["1.38.1"] = {
                url = {
                    GLOBAL = "https://github.com/chriskohlhoff/asio/archive/refs/tags/asio-1-38-1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/asio/releases/download/1.38.1/asio-1.38.1.tar.gz",
                },
                sha256 = "2827b229972be80cdb14e5497962fa393d1adf036b5869e2b9c99f644daadacc",
            },
        },
        windows = {
            -- Upstream tag archives carry two POSIX symlinks
            -- (asio/include -> ../include, asio/src -> ../src) that tar.exe
            -- cannot materialize on the Windows runner. This uses the existing
            -- symlink-free repack documented by xlings-res/asio.
            ["1.38.1"] = {
                url = {
                    GLOBAL = "https://github.com/xlings-res/asio/releases/download/1.38.1/asio-1.38.1-nosymlinks.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/asio/releases/download/1.38.1/asio-1.38.1-nosymlinks.tar.gz",
                },
                sha256 = "77f74094bb12cd867a6edbf5736bbed816c6ce0906e880de8573097a81714d89",
            },
        },
    },

    mcpp = {
        schema       = "0.1",
        language     = "c++23",
        import_std   = false,
        modules      = { "asio" },
        -- GitHub wraps the tag as asio-asio-1-38-1/; expose its include root
        -- so the wrapper's `#include <asio/*.hpp>` resolve.
        include_dirs = { "*/include" },
        generated_files = {
            ["mcpp_generated/asio.cppm"] = [==[
module;
#include <asio/io_context.hpp>
#include <asio/post.hpp>
#include <asio/executor_work_guard.hpp>
#include <asio/dispatch.hpp>
#include <asio/defer.hpp>
#include <asio/steady_timer.hpp>
#include <asio/thread_pool.hpp>
#include <asio/strand.hpp>
#include <asio/ip/tcp.hpp>
#include <asio/ip/address_v4.hpp>
#include <asio/buffer.hpp>
#include <asio/awaitable.hpp>
#include <asio/this_coro.hpp>
#include <asio/use_awaitable.hpp>
#include <asio/co_spawn.hpp>
#include <asio/cancellation_signal.hpp>
#include <asio/cancellation_type.hpp>
#include <asio/bind_cancellation_slot.hpp>
#include <asio/execution_context.hpp>
#include <asio/any_io_executor.hpp>
#include <asio/system_executor.hpp>
#include <asio/system_context.hpp>
#include <asio/associated_executor.hpp>
#include <asio/associated_allocator.hpp>
#include <asio/associated_cancellation_slot.hpp>
#include <asio/error_code.hpp>
#include <asio/detached.hpp>
#include <asio/use_future.hpp>
#include <asio/deferred.hpp>
#include <asio/redirect_error.hpp>
#include <asio/bind_executor.hpp>
#include <asio/signal_set.hpp>
#include <asio/system_timer.hpp>
#include <asio/bind_allocator.hpp>
#include <asio/append.hpp>
#include <asio/prepend.hpp>
#include <asio/consign.hpp>
#include <asio/as_tuple.hpp>
#include <asio/socket_base.hpp>
#include <asio/connect.hpp>
#include <asio/read.hpp>
#include <asio/write.hpp>
#include <asio/read_until.hpp>
#include <asio/ip/udp.hpp>
#include <asio/ip/address.hpp>
#include <asio/ip/address_v6.hpp>
#include <asio/experimental/promise.hpp>
#include <asio/experimental/channel_error.hpp>
#include <asio/experimental/channel.hpp>
#include <asio/experimental/concurrent_channel.hpp>
#include <asio/experimental/use_promise.hpp>
#include <asio/experimental/parallel_group.hpp>
#include <asio/experimental/awaitable_operators.hpp>

export module asio;

export namespace asio::detail {
using ::std::chrono::operator==;
using ::std::chrono::operator<;
using ::std::chrono::operator>=;
using ::std::chrono::operator+;
using ::std::chrono::operator-;
using ::std::coroutine_traits;
}

export namespace asio::error {
using ::asio::error::make_error_code;
using ::asio::error::operation_aborted;
}

export namespace asio {
using ::asio::io_context;
using ::asio::post;
using ::asio::make_work_guard;
using ::asio::dispatch;
using ::asio::defer;
using ::asio::steady_timer;
using ::asio::thread_pool;
using ::asio::make_strand;
using ::asio::mutable_buffer;
using ::asio::const_buffer;
using ::asio::buffer;
using ::asio::awaitable;
using ::asio::use_awaitable;
using ::asio::co_spawn;
using ::asio::cancellation_signal;
using ::asio::cancellation_type;
using ::asio::bind_cancellation_slot;
using ::asio::execution_context;
using ::asio::any_io_executor;
using ::asio::system_executor;
using ::asio::system_context;
using ::asio::associated_executor;
using ::asio::associated_allocator;
using ::asio::associated_cancellation_slot;
using ::asio::error_code;
using ::asio::detached;
using ::asio::detached_t;
using ::asio::use_future;
using ::asio::deferred;
using ::asio::deferred_t;
using ::asio::redirect_error;
using ::asio::bind_executor;
using ::asio::signal_set;
using ::asio::system_timer;
using ::asio::bind_allocator;
using ::asio::append;
using ::asio::prepend;
using ::asio::consign;
using ::asio::as_tuple;
using ::asio::socket_base;
using ::asio::connect;
using ::asio::async_read;
using ::asio::async_write;
using ::asio::read;
using ::asio::write;
using ::asio::read_until;
}

export namespace asio::experimental {
using ::asio::experimental::channel;
using ::asio::experimental::concurrent_channel;
using ::asio::experimental::use_promise;
}

export namespace asio::experimental::error {
using ::asio::experimental::error::make_error_code;
}

export namespace asio::ip {
using ::asio::ip::tcp;
using ::asio::ip::udp;
using ::asio::ip::address;
using ::asio::ip::address_v4;
using ::asio::ip::address_v6;
}

export namespace asio::this_coro {
using ::asio::this_coro::executor;
using ::asio::this_coro::cancellation_state;
using ::asio::this_coro::throw_if_cancelled;
using ::asio::this_coro::reset_cancellation_state;
}

]==],
        },
        sources = {
            "mcpp_generated/asio.cppm",
            "*/src/asio.cpp",
        },
        targets = { ["asio"] = { kind = "lib" } },
        -- `separate-compilation` is a default feature so its defines propagate
        -- to every consumer TU (the module BMI and the consumer must agree on
        -- ASIO_SEPARATE_COMPILATION or the inline/extern split miscompiles).
        --
        -- ASIO_HAS_THREADS: asio's detection keys off CRT macros
        -- (_MT/_REENTRANT/_POSIX_THREADS) that the workspace's llvm-on-Windows
        -- toolchain does not define, otherwise silently selecting null_thread.
        -- Pin the known multithreaded package contract; POSIX pthread selection
        -- still runs beneath this define where applicable.
        features = {
            ["default"] = { implies = { "separate-compilation" } },
            ["separate-compilation"] = {
                defines = {
                    "ASIO_STANDALONE",
                    "ASIO_SEPARATE_COMPILATION",
                    "ASIO_DISABLE_BOOST_CONTEXT_FIBER",
                    "ASIO_HAS_THREADS",
                },
            },
        },
        deps = {},
        -- POSIX threading is detected by asio from unistd.h feature macros;
        -- retain the portable driver-level thread link contract on Linux.
        linux = {
            ldflags = { "-pthread" },
        },
        -- On the supported desktop MSVC-ABI route, asio autolinks ws2_32.lib
        -- and mswsock.lib. Do not inject GNU -l flags into native link.exe.
    },
}
