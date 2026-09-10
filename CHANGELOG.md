# Changelog

维护说明：未发版的变更记录在 `## [Unreleased]` 下；准备发版时，按
`vX.Y.Z` 标题格式将累计条目整理到对应版本节，并按改动性质归入
`Added`、`Changed`、`Fixed`、`Docs` 或 `Chore`。每条记录只保留用户和维护者
需要知道的主线变化，不逐行复制提交差异。

## [Unreleased]

### Changed

- **三个 host farm 改为对自己的成员负责,并且对宿主只保留一条具名的触达**
  (`compat.glx-runtime` 2026.09.10、`compat.opencl-runtime` 2026.09.10、
  `compat.vulkan-runtime` 2026.09.10)。

  这三个包的成员由**文件名模式**决定,而完整性(如果检查的话)对着的是**另一个
  集合** —— ICD 清单里的库。模式存在的理由恰恰是「专有驱动会按名字 dlopen 自己
  家族的成员,没有任何 `DT_NEEDED` 遍历看得见」;既然这么说了,那些成员在别处也
  得当作可达的 —— 而它们不是。**从来没被验证的,正是模式为之存在的那一半。**

  实测(装了 NVIDIA 驱动的宿主,用 mcpp 自己的 dlopen 面检查):
  `compat.glx-runtime` 52 个成员缺 30 条闭包边(它根本没有闭包遍历)、
  `compat.vulkan-runtime` 76 个缺 5 条、`compat.opencl-runtime` 缺 4 条 ——
  最后这 4 条就是 mcpp-index#376 报的那几条(该 issue 标题写的是 vulkan,
  实际观测到的来自 opencl)。

  ⚠️ **配方里「种子不能取整个 farm」的理由测的是排除之前的集合。** 它写着闭包会
  拉进 64 个库、GTK 在其中 —— 那是对「模式匹配到的每个文件」成立,因为
  `libnvidia*.so.*` 也匹配驱动的设置界面。farm 是模式匹配**减去**
  `never_farm_patterns`,对**那个**求闭包在本机只新增 5 个,GTK/GLib/Pango/Cairo
  一个都没有。**结论会被复查,理由不会。**

  ⭐ 新规则:一个成员需要的每条 soname 都有**明写的答案**,没有静默分支。
  1. 生态发布了它 —— 在 `xpm.linux.deps` 里声明,从已装载荷取
     (新增 `xim:openssl`、`xim:mesa`);
  2. 不可再分发的专有驱动用户态 —— 也走包:新增
     `xim:nvidia-video-host-link` 拥有「宿主的 `libnvcuvid.so.1` 在哪」这一个
     问题,和 `libcuda-host-link`/`nvidia-gl-host-link` 同形;
  3. 两者都不是、也不可能成为 —— 写进配方的 `UNSERVED` 表**并附理由**
     (今天只有 `libcrypto.so.1.1`:OpenSSL 1.1 上游已 EOL,而只有 NVIDIA 的
     PKCS#11 提供者要它,没有任何 OpenCL/Vulkan 入口够得到);
  4. 以上都不是 —— 安装时**打警告点名**。这一条是关键:farm 从生态之外拿了什么,
     必须是有人写下来的清单,而不是残留物。

  **没有任何一条分支会为成员去 /usr/lib 收一个新文件。** `compat.glx-runtime`
  一条都不收:那 30 条全部来自已装载荷(4 条 `libnvidia-*` 来自
  `xim:nvidia-gl-host-link`,其余 26 条来自 `xim:graphics` 拉起来的栈)。

  ⭐ 判据落在 mcpp 会问的那个问题上:成员的 `DT_NEEDED` 用 `readelf -d` 读,
  归属只对着 farm 这一个目录判。**先前用 `ldd` 是错的** —— 它答的是「在这台机器
  上能不能解析」,而这台机器包含宿主默认目录,于是宿主碰巧有的 soname 读成已解析、
  从不被记录,而消费者的搜索路径里没有宿主。实测:`libcrypto` 那两条对这一趟不可见,
  却被 mcpp 在上一层从同一个目录报了出来。

  实测结果(本机,opencl farm):`members 48 / walked 47 / missing 0`,
  只剩 `libcrypto.so.1.1` 一条 dangling —— 正是明写为 unserved 的那条。
  改动前是 4 条 missing。

  ⚠️ 抬版本键是必须的:`install()` 的产物烤进已安装载荷,不换键的机器会一直留着
  未闭合的 farm。消费者 `compat.glfw` / `compat.opencl` / `compat.vulkan` 同步重钉。

### Added

- 收录 `compat.sdl3` 3.4.2 —— SDL3 窗口/输入/音频层,从源码构建(形态 E)。
  它是 `compat.sdl2` 的**兄弟而非替代**:两者是不同 API、不同 soname。
  比 SDL2 好办的两点都是实测:**tarball 没有符号链接**
  (`tar tvzf|grep -c '^l'` → 0),所以不需要 SDL2 那种 `-nosymlinks` 重打包托管;
  以及**配置分发器是上游自带的** —— windows/macOS 的 config 都是签入的,
  只有 linux 会掉进 `SDL_build_config_minimal.h`(那份根本没有视频驱动)。
  所以只生成**一份** config,而且只有 linux 用它。
  ⚠️ 生成它必须用**索引自己的工具链 + 索引自己的 X11 头** —— mcpp 的 gcc 自带
  sysroot,看不见 `/usr/include`,不喂索引的头 SDL 的检测会直接失败退出。
  ⚠️⚠️ **config 只许声明索引真正打了包的东西**,这是规则不是偏好:CMake 探的是
  它运行的那台机器,宿主有什么就开什么,然后在这里编不过。三个是靠失败的构建
  一个个抓出来的 —— XSCRNSAVER(`X11/extensions/scrnsaver.h` 找不到)、LIBTHAI、
  HIDAPI_LIBUSB;XTEST/XSYNC 一并预防性关掉。剩下的是**可核对**的:配置里所有
  会被 `dlopen` 的库共 7 个,每一个都有对应的包(fribidi + X11 六件套),
  与 `linux.deps` 一一对应。
  源集不是"读 CMakeLists 猜的":configure 之后从
  `CMakeFiles/SDL3-static.dir/build.make` 把 CMake 真正选中的 266 个源读回来,
  归并成 **73 个整目录 + 1 个部分目录**(`src/core/linux`,跳过 dbus/IME 那 6 个
  文件 —— 与 `compat.sdl2` 跳过的是同一批,它们不自 guard)。
  macOS/Windows 不用生成的 config,所以它们的源集是**从签入 config 里开了哪些
  driver 反推的**;windows 有一处不显然:`SDL_THREAD_GENERIC_COND_SUFFIX` /
  `_RWLOCK_SUFFIX` 意味着条件变量和读写锁回退到 generic 实现,所以要单独带上
  `thread/generic/SDL_syscond.c` 与 `SDL_sysrwlock.c` —— **只这两个**,其余四个
  与 windows 版同名。
  测试用 SDL 的 **dummy 视频驱动**,三个平台上无显示器都能跑:断言头与运行时
  版本一致、编译进来的驱动表里有 dummy 与 offscreen(掉进 minimal config 就一个
  都没有)、dummy 驱动真能初始化并建出 320x240 的窗口和同尺寸 surface、
  以及计时器会前进。
  实测:linux · gcc 16.1.0 与 linux · llvm 22.1.8 两条腿都编过(267 个 TU)并跑通;
  macOS/Windows 由 CI 裁决。CN 镜像 `gitcode.com/mcpp-res/sdl3` 已建并验过逐字节相同。

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

- `compat.sycl-runtime` 2026.09.10 与 `compat.cuda-driver` 2026.09.10:驱动一侧
  的 farm 由**枚举哨兵目录**得到,不再手写 `libcuda.so.1` 一个名字,并把哨兵
  依赖钉到 `xim:libcuda-host-link@0.0.2`。手写的那一半正是错的那一半:
  `libur_adapter_cuda.so.0` 的 DT_NEEDED 里除 `libcuda.so.1` 之外还有
  `libnvidia-ml.so.1`,farm 没有携带,适配器加载失败,CUDA 后端整个消失,
  程序以退出码 134 终止且不打印任何异常文本(mcpp#596)。哪些驱动库存在是
  哨兵包的问题;读它的目录得到的 farm 无法与它不一致,而写死文件名的 farm 已经
  不一致了。旧版本键保留:本文件只有一个 `install()` 且不读 `pkginfo.version()`,
  所以旧钉今天安装得到的仍是当前 farm,新版本键的作用是让已经装过该目录的机器
  重新安装。
- `compat.sycl-runtime` 明确声明**不服务** `libOpenCL.so.1`。载荷自带 OpenCL
  适配器,而 `compat:opencl` 会连带引入宿主专有 OpenCL 驱动的 farm,把一份
  随机器而变的厂商面塞进每一个 SYCL 工程;实测中它还提供了 `libnvidia-ml.so.1`,
  从而遮住上一条正在修的缺口。需要该后端的工程在自己的 manifest 里声明
  `compat:opencl`。

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

- `tests/examples/sycl-runtime` 的判据由**三个手写 soname 的 dlopen**改为
  **对 farm 全体成员做 DT_NEEDED 闭包走查**。farm 有 26 个成员而断言只有三个
  名字,坏掉的两个不在其中,所以这条判据在缺陷存在期间一直是绿的。改用 dlopen
  全体成员仍然不够:dlopen 量的是**进程**,而进程的搜索路径上不止本包放的东西
  —— 实测中另一个 farm 提供了 `libnvidia-ml.so.1`,把本包的缺口遮成通过。
  现在的走查只看 farm 自己,并区分三种读数:解析到、farm 里存在但悬空(无驱动的
  机器,记 note)、farm 根本没有(打包缺口,失败)。三条腿都实测过:补全后 26/26
  通过;拿掉 NVML 后点名成员与 soname 失败;把驱动链改为悬空后 24/26 通过。

- 跟进 Galay 5.0.1 对 C++23 module prelude 的跨平台 intrinsic 头文件守卫修复，
  避免 Clang 在 Linux/macOS 上错误转发 `intrin.h`。
- 跟进 Galay 5.0.2 将 `AioCommitAwaitable::await_suspend` 的类外模板定义放回
  `galay::async` 命名空间，修复 Clang 22 导出 `galay.kernel` 时的模块语义错误，
  同时保留 Linux `USE_EPOLL` AIO 后端行为。

### Docs

- 记录 Galay 5.0.2 归档的双下载 SHA256 校验，以及 PR #285 的全平台 CI 验证结果。
