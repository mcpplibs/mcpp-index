-- chriskohlhoff.asio -- Asio 1.38.1 暴露为 C++23 模块 `asio` (Form B inline)
--
-- 消费者引入:
--     mcpp add chriskohlhoff.asio@1.38.1
--
-- 注意: 不要使用简写 mcpp add asio@1.38.1。
-- 简写 "asio" 已在默认注册表中匹配多个包 (compat.asio, mcpplibs.asio 等),
-- 会导致解析冲突或解析到错误的包。
--
-- 本包是 compat.asio (header-only: #include <asio.hpp>) 的模块伴侣包。
-- 采用 ASIO_SEPARATE_COMPILATION 模式 (编译 */src/asio.cpp),
-- 上层叠加生成的模块接口单元 (.cppm wrapper), 使用者只需:
--     import std; import asio;
--
-- 为何用 generated_files: upstream 1.38.x 未提供模块接口单元,
-- wrapper 在 mcpp-index 内手工编写, 先以 docs/asio.lua 本地验证。
--
-- ========== 基本用法 ==========
--     import std;        -- 必须, 模块版不会自动拉入标准库
--     import asio;
--
--     using namespace std::chrono_literals;
--     asio::io_context io;
--     auto strand = asio::make_strand(io);
--     asio::steady_timer timer(io, 100ms);
--     asio::co_spawn(io, my_coro(), asio::detached);
--
-- ========== 必须写 import std; ==========
-- 与 header-only 的 compat.asio 不同, 本模块不会隐式拉入任何标准库头文件。
-- 要使用 std::vector, std::error_code, std::thread, std::mutex,
-- std::chrono 等, 必须写 `import std;`。省略则标准库不可见。
--
-- ========== 与 compat.asio(header-only) 的主要差异 ==========
--
--  1. 构建模型 (HEADER_ONLY -> SEPARATE_COMPILATION)
--     compat.asio:   ASIO_HEADER_ONLY -- asio 模板在每个消费者 TU 中实例化,
--                    编译系统只需一个锚定 .c 文件。
--     chriskohlhoff.asio: ASIO_SEPARATE_COMPILATION -- 每次构建只编译一次
--                    */src/asio.cpp; BMI (模块) 缓存模板实例化。
--                    首次构建较慢 (编译 asio 实现), 增量构建更快
--                    (消费者 TU 变更时无需重解析 asio 头文件)。
--
--  2. 宏 (宏定义) 不可见
--     `import asio;` 后, 模块边界隔离了预处理状态。使用者不能写:
--        #ifdef ASIO_HAS_THREADS      -- 不可见
--        #ifndef ASIO_HEADER_ONLY     -- 不可见
--        #ifdef ASIO_HAS_PTHREADS     -- 不可见
--        #ifdef ASIO_HAS_PIPE         -- 不可见
--        #ifdef ASIO_HAS_FILE         -- 不可见
--        #ifdef ASIO_HAS_SERIAL_PORT  -- 不可见
--        #ifdef ASIO_HAS_BOOST_*      -- 不可见
--     只有 ASIO_STANDALONE 和 ASIO_SEPARATE_COMPILATION 通过 feature defines
--     暴露 (见下方 "features" 块)。需要平台检测时, 请使用 C++ 标准宏或
--     操作系统级宏 (#ifdef __linux__ 等)。
--
--  3. error_code 类型一致性
--     asio::error_code = std::error_code。模块导出了类型别名, 两者可互换。
--     定时器回调签名 (const std::error_code&) 和 asio::error::* 枚举值
--     均正常工作。
--
--  4. 完成令牌 (Completion Token) 的模板类型
--     模块使用者可以写 asio::detached / asio::detached_t / asio::deferred /
--     asio::deferred_t 作为类型。但 asio::use_future_t<Alloc> 是类模板,
--     未导出。请直接使用 asio::use_future 变量, 无需命名其类型。
--
--  5. 禁止混合 #include 和 import
--     不要在同一个 TU 中混用 #include <asio.hpp> 和 import asio; --
--     头文件的 inline 实例化与模块 BMI 之间可能存在 ODR 差异。选一种。
--     需要 #include 方式时, 请依赖 compat.asio。同理, 不要在同一 TU 中
--     混合 #include <vector> 和 import std;。
--
--  6. import_std = false
--     mcpp schema "0.1" 要求自身提供模块接口的包必须设置 import_std = false
--     (由使用者显式写 `import std; import asio;`)。chriskohlhoff.asio 不会
--     在包级别自动引入 import std;。
--
-- ========== 本模块不可用的 API 组件 ==========
--
--  以下组件在 compat.asio (header-only) 中可用, 但本模块未导出:
--
--  组件                     头文件 / 路径                  原因 / 替代方案
--  ------------------------+----------------------------+----------------------
--  SSL/TLS                  asio/ssl/*.hpp                需 OpenSSL/wolfSSL
--                          (ssl::context,                 (外部依赖), 本包不包含
--                           ssl::stream,
--                           ssl::host_name_verify)
--  Unix 域套接字            asio/local/*.hpp              未导出。改用 TCP loopback,
--                          (local::stream_protocol,       或在你的代码中 #include
--                           local::datagram_proto)
--  POSIX 流描述符           asio/posix/*.hpp              未导出。
--                          (posix::stream_descriptor,
--                           posix::descriptor_base)
--  Windows 句柄             asio/windows/*.hpp            Windows 专用, 未导出。
--                          (stream_handle, object_handle,
--                           overlapped_ptr)
--  串口                     asio/serial_port.hpp          平台相关
--                                                         (ASIO_HAS_SERIAL_PORT)。
--                                                         未导出。
--  Pipe (管道)              asio/*able_pipe.hpp           需 ASIO_HAS_PIPE。
--                          (readable_pipe, writable_pipe) 未导出。
--  文件 I/O                 asio/stream_file.hpp          需 ASIO_HAS_FILE。
--                           asio/random_access_file       未导出。
--  spawn() 有栈协程         asio/spawn.hpp                需 Boost.Context
--                          (spawn, yield_context)         (ASIO_HAS_BOOST_CONTEXT
--                                                         _FIBER)。我们定义了
--                                                         ASIO_DISABLE_BOOST_
--                                                         CONTEXT_FIBER, 因此
--                                                         spawn() 给出编译期
--                                                         #error。
--                                                         -> 改用 co_spawn +
--                                                            awaitable (C++20
--                                                            无栈协程)
--  Boost.Date_Time 定时器   asio/deadline_timer.hpp       已废弃。改用
--                                                         steady_timer /
--                                                         system_timer
--                                                         (使用 std::chrono)
--  通用套接字协议           asio/generic/*.hpp            较少使用, 未导出。
--  执行器属性框架           asio/execution/*.hpp          高级执行器框架, 暂未导出。
--  自定义点检测特质         asio/traits/*.hpp             检测特质, 最终用户
--                                                         价值较低, 未导出。
--  遗留宏式协程             <asio/yield.hpp>              已过时。改用 awaitable。
--                          <asio/coroutine.hpp>
--  asio::streambuf          asio/streambuf.hpp            改用 mutable_buffer +
--                                                         asio::buffer()。
--
-- ========== Boost 淘汰说明 ==========
--
--  独立版 asio (定义了 ASIO_STANDALONE) 已从所有核心和网络 API 中移除
--  Boost 依赖:
--
--  * Boost.DateTime -- 已完全移除。ASIO_STANDALONE 在 config.hpp 中设置
--    ASIO_DISABLE_BOOST_DATE_TIME, 导致 deadline_timer (依赖
--    boost::posix_time) 完全不可编译。所有现代 asio 定时器
--    (steady_timer, system_timer, high_resolution_timer) 直接使用
--    std::chrono。
--
--  * Boost.Context -- 已从核心库移除, 但 spawn() 仍需要。
--    spawn() / basic_yield_context API 使用 boost::context::fiber 实现
--    有栈协程。由于我们定义了 ASIO_DISABLE_BOOST_CONTEXT_FIBER,
--    任何使用 spawn() 的代码都会产生编译期 #error。
--    -> 改用 C++20 无栈协程, 功能完全等价:
--         // 之前 (Boost.Context 有栈):
--         asio::spawn(io, [](asio::yield_context yield) {
--           timer.async_wait(yield);
--         });
--         // 之后 (C++20 无栈, 零 Boost):
--         asio::co_spawn(io, coro(), asio::detached);
--         asio::awaitable<void> coro() {
--           co_await timer.async_wait(asio::use_awaitable);
--         }
--
--  * Boost.Regex -- ASIO_STANDALONE 禁用了 ASIO_HAS_BOOST_REGEX。
--  * Boost.Config, Boost.Array, Boost.Bind, Boost.Limits, Boost.Chrono,
--    Boost.ThrowException 等 -- 全部已禁用。
--
--  * 陷阱提示: ASIO_HAS_BOOST_CONTEXT_FIBER 会针对任意 C++11 兼容编译器
--    (clang/GCC/MSVC) 自动检测并设置自身, 即使你从未要求过 Boost。
--    如果 Boost 头文件碰巧在 include path 中, spawn() 看起来能编译,
--    但会在链接时报错 (除非链接了 libboost_context)。
--    ASIO_DISABLE_BOOST_CONTEXT_FIBER 防护了这一点: 我们主动抑制自动检测,
--    使结果是明确的编译期错误, 而非运行时崩溃。
--
-- ========== 迁移指南 (header-only -> 模块) ==========
--
--  将项目从 compat.asio (#include <asio.hpp>) 切换到
--  chriskohlhoff.asio (import asio;) 时, 请检查以下断点:
--
--  [ ] 在每一个使用 asio 的 TU 顶部添加 import std;
--      (标准库类型不再隐式可用)
--  [ ] 删除所有 #include <asio/*.hpp> -- 替换为 import asio;
--  [ ] 删除 #include <asio.hpp> (如果有)
--  [ ] 检查 #ifdef ASIO_HAS_THREADS / ASIO_HAS_PIPE / 等
--      -> 替换为操作系统级宏或 if-constexpr 检测
--  [ ] 检查 asio::spawn() / yield_context 用法
--      -> 重写为 co_spawn + awaitable + use_awaitable
--  [ ] 检查 deadline_timer -> 替换为 steady_timer
--  [ ] 检查 asio::ssl::* -> 需要单独的 OpenSSL 集成包
--  [ ] 检查 asio::local::* / posix::* -> 如确实需要, 添加 #include
--      (但同一 TU 中混用 #include 和 import 有风险; 要么对这类文件
--       继续使用 compat.asio, 要么在 .cppm 文件的模块前导区
--       仅添加全局性 #include)
--  [ ] 构建时间: 首次构建较慢 (编译 asio.cpp), 增量构建更快
--      (BMI 缓存)。总体上更大的目标文件被跨 TU 更少的模板实例化抵消。
package = {
    spec        = "1",
    namespace   = "chriskohlhoff",
    name        = "chriskohlhoff.asio",
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
            -- Same symlink-free repack as compat.asio: upstream's tag archives
            -- carry two POSIX symlinks (asio/include -> ../include,
            -- asio/src -> ../src) that tar.exe cannot materialize on the
            -- Windows runner. Provenance: xlings-res/asio README.
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
        -- ASIO_HAS_THREADS: same rationale as compat.asio -- asio's thread
        -- detection keys off CRT macros (_MT/_REENTRANT/_POSIX_THREADS) the
        -- workspace's llvm-on-Windows toolchain does not define, silently
        -- selecting null_thread; pin the detection result. asio only ever
        -- tests defined(ASIO_HAS_THREADS), and on POSIX the pthread selection
        -- beneath it still runs, so this is a no-op where detection works.
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
