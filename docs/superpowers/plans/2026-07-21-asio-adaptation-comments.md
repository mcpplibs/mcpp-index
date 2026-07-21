# Asio Adaptation Comments Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add concise Asio module cautions, differences/limitations, and unexported-component notes without changing the descriptor table.

**Architecture:** Replace only the leading comments in `pkgs/a/asio.lua`, compare the table from `package = {` byte-for-byte, and run only Asio validation.

**Tech Stack:** Lua xpkg descriptor, C++23 modules, mcpp 0.0.101, Git.

---

### Task 1: Replace The Leading Comment Block

**Files:**
- Modify: `pkgs/a/asio.lua:1`

- [ ] Save the current table beginning at `package = {` to `/tmp/asio-package-table.before`.
- [ ] Replace the leading comments with this exact block:

```lua
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
```

- [ ] Compare the table after `package = {` with the saved baseline; expect no diff.
- [ ] Confirm the comment contains no `compat.asio`, `chriskohlhoff.asio`, or obsolete short-name warning.

### Task 2: Validate And Commit

**Files:**
- Validate: `pkgs/a/asio.lua`
- Test: `tests/examples/asio-module/**`

- [ ] Run `lua -e "assert(loadfile('pkgs/a/asio.lua', 't'))"`.
- [ ] Run `lua tests/check_mirror_urls.lua pkgs/a/asio.lua`.
- [ ] Confirm `mcpp --version` reports `0.0.101` and run `mcpp xpkg parse pkgs/a/asio.lua`.
- [ ] Run `MCPP_HOME=<isolated-temp-home> MCPP_INDEX_MIRROR=GLOBAL mcpp test -p asio-module`; expect 5 passed and 0 failed.
- [ ] Run `git diff --check` and confirm only the leading `asio.lua` comments changed.
- [ ] Commit `pkgs/a/asio.lua` as `docs(asio): restore module adaptation notes`.
