-- asio -- 将独立版 Asio 1.38.1 暴露为 C++23 模块 `asio`
-- (Form B inline descriptor, separate-compilation mode)。
--
-- 注意事项
--   * 使用 `mcpp add asio@1.38.1` 引入；消费者需显式写
--     `import std; import asio;`，因为本包设置 import_std = false。
--   * 本包只支持模块方式消费。同一 translation unit 不要混用
--     `#include <asio.hpp>` 和 `import asio;`，避免 inline 定义与模块 BMI
--     的 separate-compilation 定义产生 ODR 差异。
--   * 默认 feature 显式传播 ASIO_STANDALONE、ASIO_SEPARATE_COMPILATION、
--     ASIO_DISABLE_BOOST_CONTEXT_FIBER 和 ASIO_HAS_THREADS。Asio 头文件内部
--     自动检测的其他 ASIO_HAS_* 宏不会由 `import asio;` 导出。
--
-- 与 header-only Asio 的区别/限制
--   * 上游 1.38.x 没有模块接口单元。本描述生成 `asio.cppm`，并只编译一次
--     `*/src/asio.cpp` 中的非模板实现；首次构建需生成 BMI，增量构建可避免
--     每个消费者 translation unit 重复解析整组 Asio 头文件。
--   * 模块只暴露 wrapper 中明确 export 的声明，不等同于
--     `#include <asio.hpp>` 的完整 API 表面。
--   * asio::error_code 是 std::error_code 的别名；wrapper 导出
--     asio::use_future 变量，但未导出 asio::use_future_t<Alloc> 类模板。
--   * 依赖未导出 ASIO_HAS_* 宏、平台专用头文件或 Boost 扩展的代码，需要
--     改用标准/操作系统能力检测或另行扩展模块 wrapper。
--
-- 未导出的组件
--   * SSL/TLS (`asio/ssl/*.hpp`)：需要 OpenSSL/wolfSSL 等外部依赖。
--   * Unix 域套接字、POSIX 描述符和 Windows 句柄：
--     `asio/local/*.hpp`、`asio/posix/*.hpp`、`asio/windows/*.hpp`。
--   * 串口、pipe 和文件 I/O：`asio/serial_port.hpp`、
--     `asio/*able_pipe.hpp`、`asio/stream_file.hpp`、
--     `asio/random_access_file.hpp`。
--   * spawn()/yield_context 有栈协程：需要 Boost.Context；本包禁用其自动
--     检测，应改用 co_spawn + awaitable + use_awaitable。
--   * deadline_timer、generic protocol、execution、traits、遗留宏式协程和
--     streambuf：对应 `asio/deadline_timer.hpp`、`asio/generic/*.hpp`、
--     `asio/execution/*.hpp`、`asio/traits/*.hpp`、`asio/yield.hpp`、
--     `asio/coroutine.hpp`、`asio/streambuf.hpp`。
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
