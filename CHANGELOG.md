# Changelog

维护说明：未发版的变更记录在 `## [Unreleased]` 下；准备发版时，按
`vX.Y.Z` 标题格式将累计条目整理到对应版本节，并按改动性质归入
`Added`、`Changed`、`Fixed`、`Docs` 或 `Chore`。每条记录只保留用户和维护者
需要知道的主线变化，不逐行复制提交差异。

## [Unreleased]

### Added

- 收录 `mcpplibs.rules-cuda` 0.1.0 —— 把「怎么编一个 CUDA 设备翻译单元」收成一条
  可 import 的构建规则(`host-module = true`)。⭐ **一个仓库都不用新建**,与
  `grpcgen` 同形:描述符指向 mcpp 自己**源码 tarball** 的一个子路径
  (`*/examples/09-cuda-kernel/rules-cuda/mcpp.toml`)。规则与它所讲的协议
  (构建程序协议 v7)由同一次发布产出,指向同一份 tarball 因而不是权宜之计,
  而是让两者不可能错配。需要 mcpp >= 2026.9.5.2。
  实测:示例工程去掉 path 依赖、改写一行 `[dependencies.mcpplibs]` 后,
  在 RTX 4080 上构建并跑出 `12 24 36 48`。

- 收录 CUDA 设备侧的六个适配包:`compat.cudart`(CUDA Runtime)与
  `compat.cublas` / `cufft` / `curand` / `cusolver` / `cusparse`(五个算子库)。
  载荷一律来自 xim(`xpm.linux.deps` 接线),本仓库只回答「怎么对它构建」:
  install() 把载荷的 `include/` 与 `lib/*.so*` 链进包自己的目录,
  `include_dirs` / `-L` / `runtime.library_dirs` 因而全部落在包内。
  一律走 12.x 线 —— 设备运行时不得新于它将遇到的驱动,而 `xpm.<platform>.deps`
  按 OS 读取而非按版本,所以一份描述符只指一条线。
  ⚠️ 两处上游造成的耦合写在配方里:`compat.cudart` 额外依赖 `xim:cuda-nvcc`,
  因为 12.x 线的 `crt/host_config.h` 在编译器组件里而 `cuda_runtime.h` 无条件
  include 它;以及 NVIDIA 的 `.so` 带 `RUNPATH = $ORIGIN`,它会**关掉**可执行
  文件继承来的 DT_RPATH,所以 glibc 2.34 合并进 libc 的三个存根
  (`librt.so.1` / `libpthread.so.0` / `libdl.so.2`)必须一并链进同一个目录 ——
  否则程序在 `main` 之前就以 `librt.so.1: cannot open shared object file` 退出。
- 新增工作区成员 `tests/examples/cuda-curand`:无设备的机器上断言库能加载并
  应答(即上面那条 `$ORIGIN` 缺陷的判据),有设备时再断言生成值落在 [0,1]
  且均值接近 0.5。五个算子库包由同一模板生成,`-l` 名逐个读自上游归档;
  cuRAND 载荷最小(85 MB,对比 cuBLAS 的 933 MB),因此它是每个 PR 都跑的那个。

### Changed

- `compat.cuda-runtime` 改名为 `compat.cuda-driver`,并改正 `repo` 字段。
  NVIDIA 词汇里 "CUDA Runtime" 专指 `libcudart`,而本包 farm 的是驱动的
  `libcuda.so.1`;它的 `capabilities` / `provides` 从第一版起就写作 `cuda.driver`,
  只有包名不一致。旧条目冻结保留,`compat.cuda-runtime@2026.09.05` 继续解析到
  同一份实现;工作区成员 `tests/examples/cuda-driver`(原 `cuda-runtime`)同时
  依赖新旧两个名字,让这条过渡承诺有判据。

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
  header-only。新增 `boost-beast`、`boost-asio`、`boost-family` 三个工作区
  成员；其中 `boost-family` 为大测试成员，一个工程 6 个测试文件覆盖全部
  23 个没有专属成员的小依赖包（core/smart-ptr、container/intrusive/
  optional/static-string、mp11/describe/preprocessor/type-index/predef、
  system/compat/bind、endian/container-hash/logic/align、io/utility/
  winapi）。
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
