# Changelog

维护说明：未发版的变更记录在 `## [Unreleased]` 下；准备发版时，按
`vX.Y.Z` 标题格式将累计条目整理到对应版本节，并按改动性质归入
`Added`、`Changed`、`Fixed`、`Docs` 或 `Chore`。每条记录只保留用户和维护者
需要知道的主线变化，不逐行复制提交差异。

## [Unreleased]

### Added

- 收录 **vulkan-rt 依赖的八个通用库**,一次补齐:`compat.glm` 1.0.2、
  `compat.doctest` 2.4.12、`compat.argparse` 3.2、`compat.mio` 2023.3.3、
  `compat.gzip-hpp` 0.1.0、`compat.cpptrace` 1.0.4、`compat.libassert` 2.2.1、
  `compat.libcoro` 0.16.0。八个都带**已验证的 CN 镜像**
  (`gitcode.com/mcpp-res/<slug>`,逐个比对 sha256 与 GLOBAL **逐字节相同**,
  8/8),八个都带 workspace 成员做行为断言。
  四个不是「拉个头文件就完事」,记在配方里:
  ⚠️ **`compat.gzip-hpp`** 冻结在一个已经编不过的点上:`utils.hpp` 六处、
  `decompress.hpp` 一处用 `uint8_t` 却不 include `<cstdint>`(实测 gcc 16.1.0)。
  而且它是**消费者侧**失败 —— 本包一个 C++ TU 都没有,`cxxflags = {"-include",
  "cstdint"}`(`compat.redis-plus-plus` 的修法)到不了出错的 TU。唯一可用的杠杆是
  同名遮蔽头 + `#include_next`,与 `compat.catch2` 修 `<new>` 是同一招;
  `include_dirs` 因此必须 `mcpp_generated` 在前,调换两行会静默失效。
  ⭐ **`compat.cpptrace`** 是形态 E 去掉 config 头:六个符号后端、六个 unwinder、
  三个 demangler **每个文件自己 `#ifdef`**,所以源列表是一条 glob,配置全在 defines。
  选的后端一律**零外部依赖**:unix 走 libgcc 的 `_Unwind_Backtrace` + `dladdr` +
  `__cxa_demangle`,windows 走 DbgHelp。⚠️ 代价写在配方里:`dladdr` 不读 DWARF,
  所以栈帧有函数名、**没有 file:line**;要行号得再加一个 libdwarf 包,留作 feature。
  **`compat.libassert`** 依赖上面那个(上游是 FetchContent 一份进自己的树,这里是
  正经依赖,消费者链两次也只有一份 cpptrace);magic_enum **不需要** —— 读 CMakeLists
  会发现它只在 `LIBASSERT_BUILD_TESTING` 下打开,库源码一次都没提过它。
  ⚠️ **`compat.libcoro`** 只出**核心**:上游 networking 默认开,但它的 c-ares 在
  `vendor/c-ares` 这个 **git submodule** 里,而 GitHub 归档从不含 submodule
  (实测 `find vendor -type f` → 0 个文件)—— 这个产物根本编不出网络那半。所以源列表
  是上游 `LIBCORO_SOURCE_FILES` 在 `if(LIBCORO_FEATURE_NETWORKING)` 之前的部分,
  逐条转录而非 glob(`scheduler.cpp`/`poll.cpp`/epoll/kqueue/`net/` 全都不自 guard)。
  另外 `coro/export.hpp` 是 `generate_export_header` 生成的,tarball 里没有,
  缺了它第一个 TU 就 fatal error;快照进 `generated_files`,`CORO_STATIC_DEFINE` 走
  `defines`(要到消费者)而非 `cxxflags`。
  测试都断言真行为而非「能编译」:glm 断言叉积/列主序/`GLM_FORCE_DEPTH_ZERO_TO_ONE`
  下近平面映射到 0;gzip 断言 gzip magic + 真的变小 + 往返;cpptrace 断言四层调用链
  的帧数与**互不相同**的返回地址;libassert 走**失败路径**,断言报告里有表达式原文、
  消息和两个操作数的值,并且拿到了非空 stacktrace(这条同时证明 cpptrace 是传递到达的);
  libcoro 用 200 个协程在 `coro::mutex` 下累加。

- 收录 `khronos.vulkan-hpp` 1.4.357.0 —— Vulkan 的 C++ 绑定,按 Khronos 现在自己
  发布的形态消费:`import vulkan;` / `import vulkan_video;`。⭐ 这是本索引第一个走
  **形态 C 第一条分支**的包(上游自带 `.cppm`,直接点名),此前所有模块包都是合成
  包装体。描述符里没有一行包装代码:导出面是 Khronos 从 XML registry 生成的。
  载荷取 **Vulkan-Headers** 的 tarball,与 `compat.vulkan-headers` 同一个 URL、
  同一个 sha256 —— Khronos 把生成好的 `vulkan.cppm` / `vulkan_video.cppm` 随每个
  Vulkan-Headers tag 一起发。指向 Vulkan-Hpp 仓反而更差,三条都实测过:该仓没有
  `vulkan-sdk-*` tag(404),Vulkan-Headers 在那里是 git submodule 而 GitHub 归档
  永远不含 submodule,以及由此产生的第二份 `vulkan/` include 根会让 `vulkan.hpp`
  由 `-I` 顺序决定。同一份 tarball 则让两个包不可能错配 —— 模块单元开头就是
  `VULKAN_HPP_STATIC_ASSERT( VK_HEADER_VERSION == 357 )`。
  命名空间取 `khronos` 而非 `compat`(本索引里 namespace 是消费形态的契约:
  `compat.*` 按头文件消费,归属 namespace 承诺 `import`);**模块名保持上游的
  `vulkan` / `vulkan_video`**,不加索引前缀,否则所有 Vulkan-Hpp 文档对 mcpp 用户
  都是错的。`import_std = true` 不是偏好:单元第 27 行是无条件的
  `export import std;`,上游 CMake 也正因此把模块目标 gate 在
  `23 IN_LIST CMAKE_CXX_COMPILER_IMPORT_STD` 上。依赖取 **loader**
  (`compat.vulkan`)而不只是头:Vulkan-Hpp 默认 **静态 dispatcher**
  (`VULKAN_HPP_DISPATCH_LOADER_DYNAMIC` 在没有 `VK_NO_PROTOTYPES` 时为 0),
  `vk::enumerateInstanceVersion()` 会编成对 `vkEnumerateInstanceVersion` 的直接
  调用,只依赖头会得到一个"能编译、每个消费者都链接失败"的包。
  与上游 `Vulkan::HppModule` 一致地**不定义任何 `VK_USE_PLATFORM_*`**:那些宏按
  平台互斥、无法做成可移植的 feature,而可移植路线也不需要它们 —— GLFW/SDL2 交回
  的 `VkSurfaceKHR` 包成 `vk::SurfaceKHR{ raw }` 即可,surface/swapchain 本身在
  模块里是无条件存在的。
  新增 workspace 成员 `tests/examples/vulkan-hpp-module`(两个测试:`module.cpp`
  全文无 `#include`,断言枚举量取值、`sType` 默认、`format_traits` 的 constexpr
  结果、`raii` 层的编译期成员,以及经静态 dispatcher 打到 loader 的两次真实调用;
  `video.cpp` 单独证明第二个模块单元被编译 —— 它 `import vulkan;`,只能排在第一个
  之后,而 `sources` 只是一张无序的表)。
  实测:linux · gcc 16.1.0 与 linux · llvm 22.1.8 两条腿都产出两个 BMI/PCM 并跑通;
  macOS 与 Windows 走的是与 llvm 腿相同的 clang 路径,其运行期一半早已由
  `tests/examples/vulkan` 在三条腿上证明(调用的是同一批 loader 入口)。
  ⚠️ `x86_64-windows-gnu`(mingw)不可用,也不是 CI 腿(索引的 windows 工具链是
  llvm/MSVC ABI):GCC-on-PE 把模块归属的函数内静态量
  `vk::errorCategory@vulkan()::instance` 放进消费者对象的普通 `.bss`,与模块对象里
  的 COMDAT 副本撞成 `multiple definition`;且 `compat.vulkan` 的 windows 入口是
  MSVC 形态的 `vulkan-1.lib`,mingw 的 ld 找不到。两条都不是描述符能修的。

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
