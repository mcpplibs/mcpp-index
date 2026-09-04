# Changelog

维护说明：未发版的变更记录在 `## [Unreleased]` 下；准备发版时，按
`vX.Y.Z` 标题格式将累计条目整理到对应版本节，并按改动性质归入
`Added`、`Changed`、`Fixed`、`Docs` 或 `Chore`。每条记录只保留用户和维护者
需要知道的主线变化，不逐行复制提交差异。

## [Unreleased]

### Added

- 收录 `compat.boost-beast` 1.92.0（Boost.Beast，HTTP/WebSocket），沿 modular-boost
  拆包路线一次性补齐其 24 个传递依赖：`boost-asio`、`boost-align`、`boost-bind`、
  `boost-compat`、`boost-container`、`boost-container-hash`、`boost-core`、
  `boost-describe`、`boost-endian`、`boost-intrusive`、`boost-io`、`boost-logic`、
  `boost-move`、`boost-mp11`、`boost-optional`、`boost-predef`、
  `boost-preprocessor`、`boost-smart-ptr`、`boost-static-string`、`boost-system`、
  `boost-type-index`、`boost-utility`、`boost-variant2`、`boost-winapi`。
  29 包 include 树两两不相交、闭包逐 include 核实；`boost-asio` 经 default
  feature 携带 `BOOST_ASIO_DISABLE_BOOST_CONTEXT_FIBER` / `..._DATE_TIME`
  与 `BOOST_ASIO_HAS_THREADS`（llvm-on-Windows 无 `_MT`/`BOOST_HAS_THREADS`，
  不钉定会静默退化为 null_thread 且 VERSION_TAG 跨 TU 漂移），保持家族
  header-only。新增 `boost-beast` 与 `boost-asio` 两个工作区成员。
- 收录 `gzj-creator.galay` 5.0.2 原生 Form-A 模块包，覆盖 `galay.utils` 与
  `galay.kernel` 默认模块，并加入 Unix 示例工程和索引文档。

### Fixed

- 跟进 Galay 5.0.1 对 C++23 module prelude 的跨平台 intrinsic 头文件守卫修复，
  避免 Clang 在 Linux/macOS 上错误转发 `intrin.h`。
- 跟进 Galay 5.0.2 将 `AioCommitAwaitable::await_suspend` 的类外模板定义放回
  `galay::async` 命名空间，修复 Clang 22 导出 `galay.kernel` 时的模块语义错误，
  同时保留 Linux `USE_EPOLL` AIO 后端行为。

### Docs

- 记录 Galay 5.0.2 归档的双下载 SHA256 校验，以及 PR #285 的全平台 CI 验证结果。
