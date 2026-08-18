-- asio -- 将独立版 Asio 1.38.1 暴露为 C++23 模块 `asio`
-- (Form B inline descriptor, separate-compilation mode)。
--
-- 注意事项
--   * 使用 `mcpp add chriskohlhoff.asio@1.38.1` 引入；消费者需显式写
--     `import std; import asio;`，因为本包设置 import_std = false。
--   * 本包只支持模块方式消费。同一 translation unit 不要混用
--     `#include <asio.hpp>` 和 `import asio;`，避免 inline 定义与模块 BMI
--     的 separate-compilation 定义产生 ODR 差异。
--   * 默认 feature 显式传播 ASIO_STANDALONE、ASIO_SEPARATE_COMPILATION、
--     ASIO_DISABLE_BOOST_CONTEXT_FIBER、ASIO_HAS_THREADS 和 ASIO_NO_IOSTREAM。
--     Asio 头文件内部自动检测的其他 ASIO_HAS_* 宏不会由 `import asio;` 导出。
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
-- 平台条件导出：文件 I/O
--   * `asio::stream_file` / `asio::random_access_file` / `asio::file_base`
--     （及其 basic_ 模板）在 `ASIO_HAS_FILE` 成立时导出。这是 Asio 自己的
--     能力宏：Windows 下由 IOCP 提供，Linux 下需要 io_uring，macOS 下无后端
--     （见 `asio/detail/config.hpp` 的 "// Files." 一节）。用 Asio 的宏而不是
--     在描述符里维护一张平台清单，是为了让它随上游一起演进。
--   * 消费端**不能**用 `#if defined(ASIO_HAS_FILE)` 判断：宏不跨模块边界，
--     而模块消费者不 include Asio 头文件，那个宏在它的 TU 里永远为假。
--     就本包的配置而言判据是确定的 —— 未开启 io_uring，所以
--     `ASIO_HAS_FILE` ⇔ Windows。跨平台消费者按 `_WIN32` 分支即可
--     (tests/examples/asio-module/tests/file.cpp 就是这么写的)。
--
-- 未导出的组件
--   * SSL/TLS (`asio/ssl/*.hpp`)：需要 OpenSSL/wolfSSL 等外部依赖。
--   * Unix 域套接字、POSIX 描述符和 Windows 句柄：
--     `asio/local/*.hpp`、`asio/posix/*.hpp`、`asio/windows/*.hpp`。
--   * 串口和 pipe：`asio/serial_port.hpp`、`asio/*able_pipe.hpp`。
--   * spawn()/yield_context 有栈协程：需要 Boost.Context；本包禁用其自动
--     检测，应改用 co_spawn + awaitable + use_awaitable。
--   * deadline_timer、generic protocol、execution、traits、遗留宏式协程和
--     streambuf：对应 `asio/deadline_timer.hpp`、`asio/generic/*.hpp`、
--     `asio/execution/*.hpp`、`asio/traits/*.hpp`、`asio/yield.hpp`、
--     `asio/coroutine.hpp`、`asio/streambuf.hpp`。
--   * iostream/streambuf 适配：模块禁用 ASIO 的 iostream 表面，避免 libc++
--     `<print>` 同时进入 `std` 与 `asio` 两个 BMI 后破坏 `std::println`；
--     因此基于 streambuf 的 read_at/write_at 重载也不可用。
package = {
    spec        = "1",
    namespace   = "chriskohlhoff",
    -- `name` MUST be the fully-qualified `<namespace>.<short>`: xlings keys its
    -- index on this literal (libxpkg build_index → entries[package.name]),
    -- while mcpp asks for the FQN it reconstructs from the consumer's
    -- `[dependencies.<ns>] <short>`. Writing the split form ("asio") is legal
    -- per mcpp's own descriptor spec (manifest/xpkg.cppm canonical_xpkg_
    -- identity normalizes both spellings) but registers the index entry under
    -- `asio`, which no consumer request can ever hit → E_NOT_FOUND at install.
    -- See mcpp-community/mcpp#278; the lint in validate.yml enforces this.
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
#include <asio/error.hpp>
// File I/O exists only where Asio has a backend for it: IOCP on Windows, or
// io_uring on Linux (asio/detail/config.hpp, "// Files."). ASIO_HAS_FILE is
// Asio's own answer to that question, so the guard here is the library's, not
// a platform list this descriptor would have to keep in sync.
#if defined(ASIO_HAS_FILE)
#include <asio/file_base.hpp>
#include <asio/stream_file.hpp>
#include <asio/random_access_file.hpp>
#endif
#include <asio/experimental/promise.hpp>
#include <asio/experimental/channel_error.hpp>
#include <asio/experimental/channel.hpp>
#include <asio/experimental/concurrent_channel.hpp>
#include <asio/experimental/use_promise.hpp>
#include <asio/experimental/parallel_group.hpp>
#include <asio/experimental/awaitable_operators.hpp>
#ifdef MCPP_FEATURE_SSL
#include <asio/ssl.hpp>
#include <asio/ssl/context.hpp>
#include <asio/ssl/stream.hpp>
#include <asio/ssl/error.hpp>
#endif

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
// The four error enums and their enumerators. Exporting `operation_aborted`
// alone made every OTHER condition unreachable through the module — a consumer
// that wants to tell a connection refusal from a DNS failure had no name to
// compare against. `using enum` keeps that from becoming a hand-maintained
// list of ~40 enumerators that drifts on the next Asio release.
using ::asio::error::basic_errors;
using ::asio::error::netdb_errors;
using ::asio::error::addrinfo_errors;
using ::asio::error::misc_errors;
using enum ::asio::error::basic_errors;
using enum ::asio::error::netdb_errors;
using enum ::asio::error::addrinfo_errors;
using enum ::asio::error::misc_errors;
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
using ::asio::async_connect;
using ::asio::async_read;
using ::asio::async_write;
using ::asio::read;
using ::asio::write;
using ::asio::read_until;
}

#if defined(ASIO_HAS_FILE)
export namespace asio {
using ::asio::file_base;
using ::asio::basic_file;
using ::asio::basic_stream_file;
using ::asio::basic_random_access_file;
using ::asio::stream_file;
using ::asio::random_access_file;
}
#endif

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
using ::asio::ip::make_address;
using ::asio::ip::make_address_v4;
using ::asio::ip::make_address_v6;
}

export namespace asio::this_coro {
using ::asio::this_coro::executor;
using ::asio::this_coro::cancellation_state;
using ::asio::this_coro::throw_if_cancelled;
using ::asio::this_coro::reset_cancellation_state;
}

#ifdef MCPP_FEATURE_SSL
export namespace asio::ssl {
using ::asio::ssl::context;
using ::asio::ssl::context_base;
using ::asio::ssl::stream;
using ::asio::ssl::stream_base;
using ::asio::ssl::verify_context;
using ::asio::ssl::verify_mode;
using ::asio::ssl::host_name_verification;
}

export namespace asio::ssl::error {
using ::asio::ssl::error::stream_errors;
using ::asio::ssl::error::make_error_code;
// stream_category is static const ref (internal linkage) — can't export.
}
#endif

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
                    "ASIO_NO_IOSTREAM",
                },
            },
            ["ssl"] = {
                defines = { "MCPP_FEATURE_SSL" },
                deps    = { ["compat.openssl"] = "3.5.1" },
                sources = { "*/src/asio_ssl.cpp" },
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
