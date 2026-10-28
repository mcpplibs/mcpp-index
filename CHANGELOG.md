# Changelog

维护说明：未发版的变更记录在 `## [Unreleased]` 下；准备发版时，按
`vX.Y.Z` 标题格式将累计条目整理到对应版本节，并按改动性质归入
`Added`、`Changed`、`Fixed`、`Docs` 或 `Chore`。每条记录只保留用户和维护者
需要知道的主线变化，不逐行复制提交差异。

## [Unreleased]

### Added

- **mcpplibs.openkal-emscripten 0.6.0。** 按 openkal 0.17.1 实现其提供的十二个接口,使依赖 openkal 0.17 的
  mcpplibs.os 能在 `wasm32-emscripten` 上解析与链接。`kal_env_image` 为 node 所给的脚本(页面中为 `kal_err_not_found`),
  `kal_env_loader` 为 `kal_err_not_found`,`kal_env_system` 为 `emscripten`;`kal_fs_rename_flags` 中
  `KAL_RENAME_NO_REPLACE` 为 `kal_err_not_supported`(C 库没有不替换的原子改名),声明 `KAL_FS_PROP_REMOVE_OPEN`
  (在 MEMFS 上测得);`kal_net_listen_at`/`kal_net_connect_at` 为 `kal_err_not_supported`。修正:C 库对其自身终端设备
  即使在管道下也回答 `isatty` 为 1,现在由宿主(node 的 `tty.isatty`)判断标准流是否为终端,终端设置
  `KAL_TERM_SEQUENCES`。一致性(emsdk 6.0.9、node 26.7.0):终端下 109 成立、0 不成立、14 未观察;管道下 97、0、15。
  GLOBAL 为 GitHub 标签归档,CN 为 GitCode `mcpp-res/openkal-emscripten` 镜像,sha256 一致。测试成员 `openkal` 的
  wasm32 依赖移到 0.6.0。
- **mcpplibs.os 0.2.1。** 在程序自己的 C 库的两种安排下构建并通过测试:系统自己的 C 库,以及位于系统自身三元组上的
  openkal-musl 与 openkal-llvm-runtime(mcpp docs/24)。机器、内存、卷的种类与两项交换在 Linux 与 macOS 上经内核调用
  得到,Windows 上以 32 位 DWORD 与 UTF-16 WCHAR 声明 kernel32 的名字,均不经 C 库;标准输出的转向与 SIGPIPE 在进程
  保存它们的地方修改。mcpp-language-server 的操作系统层进入 os(有界运行、线程、环境赋值、有界读取、规范名)。
  ok image 的 C 库、C++ 运行时与加载器取自其平台(openkal-platform,mcpp 2026.10.27.1 为 `<arch>-openkal` 选择),
  包不再声明它们。GLOBAL 为 GitHub 标签归档,CN 为 GitCode `mcpp-res/os` 镜像,sha256 一致。测试成员 `os` 移到 0.2.1。
- **mcpplibs.mwrap.dr_libs 2026.03.03(新包)。** dr_libs-m:以 C++23 模块(`import mcpplibs.mwrap.dr_libs;`)使用
  compat.dr_libs 2026.03.03(dr_wav 0.14.5、dr_flac 0.13.3、dr_mp3 0.7.3)。每个头文件各一个模块且可单独导入:
  `mcpplibs.mwrap.dr_libs.wav`(42 个类型、48 个枚举值、94 个函数)、`.flac`(32、6、31)、`.mp3`(28、8、29),全部以
  `export using` 导出上游全局名;每个枚举都由 typedef 命名,枚举值按原样导出。`mcpplibs.mwrap.dr_libs.macros` 把 171 个
  对象式宏映射为其自身类型的常量;`*_API` 等属性、字符串化宏与 dr_flac 的平台检测宏共 28 个留在
  `<mwrap/dr_libs/macros.hpp>`。包装仓库的 CI(Linux x86_64 GCC/LLVM、Linux arm64、macOS、Windows)逐样本核对 FLAC
  解码、按 LAME 标签的无缝长度解码 MP3、在各容器中往返 WAV,并与 compat.miniaudio 链接在同一程序中解码出相同样本。
  GLOBAL 为 `mwrap-2026.03.03` 发布资产,CN 为 GitCode `mcpp-res/mwrap-dr_libs` 镜像,sha256 一致。新增测试成员
  `tests/mwrap/dr_libs-audio` 与已安装模板及其许可文件的部署检查。
- **compat.dr_libs 2026.03.03(新包)。** dr_libs:单文件的 WAV/AIFF、FLAC 与 MP3 解码器(以及 WAV 编码器),C 实现,
  无依赖,许可为 MIT-0 或 Unlicense 二选一。上游按头文件分别打标签(`wav-*`、`flac-*`、`mp3-*`),没有同时覆盖三者的标签;
  本包固定 `wav-0.14.5` 的提交 `fa931f3`(2026-03-03)的归档,其中 `dr_flac.h`、`dr_mp3.h` 与 `flac-0.13.3`、`mp3-0.7.3`
  标签逐字节相同,即 dr_wav 0.14.5、dr_flac 0.13.3、dr_mp3 0.7.3 三者均为已发布版本的最新提交;版本号取提交日期(同
  compat.nanosvg)。一个生成的实现编译单元同时定义 `DR_WAV_IMPLEMENTATION`、`DR_FLAC_IMPLEMENTATION`、
  `DR_MP3_IMPLEMENTATION`,构建为一个静态库;使用者 `#include <dr_wav.h>`(`<dr_flac.h>`、`<dr_mp3.h>`)并链接,不要再定义
  这些宏。上游默认配置(stdio 与转换接口保留,SIMD 由编译器预定义宏决定)。miniaudio 内嵌的是改名的副本(`ma_dr_*`),
  两者可在同一程序中共存。GLOBAL 为 GitHub 提交归档,CN 为 GitCode `mcpp-res/dr_libs` 镜像,sha256 一致。新增测试成员
  `tests/examples/dr_libs`(三平台):WAV(RIFF、Wave64、IEEE float、mu-law)往返、FLAC 按 STREAMINFO 的 MD5 逐样本无损解码与
  定位、MP3 按 LAME 标签的无缝长度解码。
- **mcpplibs.mwrap.opus 1.6.1(新包)。** opus-m:以 C++23 模块(`import mcpplibs.mwrap.opus;`)使用 compat.opus 1.6.1、
  compat.opusfile 0.12 与 compat.ogg 1.3.6。`mcpplibs.mwrap.opus` 导出 libopus 的 13 个类型与 87 个函数,并重新导出
  `.file`(opusfile:10 个类型、54 个函数;不导出未构建的 libopusurl 的 9 个声明)、`.ogg`(libogg:12 个类型、71 个函数)
  与 `.macros`(115 个整数常量、6 个类型别名、54 个 CTL 宏映射为返回带类型 `ctl_request` 的 constexpr 函数,7 个 `*_ctl`
  函数各有接受它的重载,`opus_encoder_ctl(enc, OPUS_SET_BITRATE(64000))` 写法不变);属性、版本测试与 CTL 参数检查等
  22 个宏留在 `<mwrap/opus/macros.hpp>`。包装仓库的 CI(Linux x86_64 GCC/LLVM、Linux arm64、macOS、Windows)经由模块
  解码 RFC 8251 的 12 个测试向量(5 种采样率、单声道与立体声,共 120 次,逐包核对区间解码器最终状态,并以 libopus 的
  `opus_compare` 对照参考输出),0 失败;212 个导出函数全部可链接。GLOBAL 为 `mwrap-1.6.1` 发布资产,CN 为 GitCode
  `mcpp-res/mwrap-opus` 镜像,sha256 一致。新增测试成员 `tests/mwrap/opus-ogg` 与已安装模板及其许可文件的部署检查。
- **compat.ogg 1.3.6、compat.opus 1.6.1、compat.opusfile 0.12(新包)。** Opus 音频的三个 Xiph.Org 库,均为
  BSD-3-Clause,均以上游发布 tarball 从源码构建为静态库。compat.ogg:Ogg 容器的分页与位打包(`src/framing.c`、
  `src/bitwise.c`),`<ogg/config_types.h>` 按上游 CMake 的结果由 `generated_files` 生成(int16_t…uint64_t)。
  compat.opus:Opus 编解码器(RFC 6716)的编码器与解码器、multistream、ambisonics projection 与 repacketizer;
  上游默认的浮点构建(源文件取自 `celt_sources.mk` / `silk_sources.mk` / `opus_sources.mk`),deep PLC、DRED、
  OSCE 与 QEXT 关闭(上游默认),纯 C、不启用 SIMD 内建函数与运行时 CPU 检测(x86 内建函数需要逐文件 `-m` 标志);
  生成的 `config.h`(`OPUS_BUILD`、`PACKAGE_VERSION "1.6.1"`、`VAR_ARRAYS`、`ENABLE_HARDENING`)与内部头文件目录
  是私有包含目录,使用者只看到 `include/`(`#include <opus.h>`);Linux/macOS 以 `-fvisibility=hidden` 编译,
  与上游 configure 一致。compat.opusfile:Ogg Opus 文件(RFC 7845)的解码与精确定位,依赖 compat.ogg 与
  compat.opus;只构建 libopusfile(不含需要 OpenSSL 的 libopusurl / HTTP)。GLOBAL 为上游发布资产
  (opus 为 downloads.xiph.org,GitHub 无 1.6.1 发布;ogg 与 opusfile 为 GitHub 发布资产),CN 为 GitCode
  `mcpp-res/opus`、`mcpp-res/ogg`、`mcpp-res/opusfile` 镜像,sha256 一致;声明 `extensions.autoupdate`(`v${version}`
  标签)。新增测试成员 `tests/examples/opus`(三平台):CELT 与 SILK 往返(信噪比)、包解析、5.1 multistream、
  ambisonics、repacketizer,以 libogg 生成的 Ogg Opus 流经 opusfile 读取(OpusHead、OpusTags、精确长度、定位)。
- **mcpplibs.mwrap.box2d 3.2.0(新包)。** box2d-m:以 C++23 模块(`import mcpplibs.mwrap.box2d;`)使用
  compat.box2d 3.2.0。按上游全局名导出已安装头文件的 110 个类型、3 个不透明结构体、176 个枚举值、506 个 `B2_API` 函数、
  91 个内联函数、8 个 C++ 向量运算符与 `b2_lengthUnitsPerMeter`;头文件的 13 个 `static const` 对象(内部链接)以同类型、
  同初值的常量置于 `mcpplibs::mwrap::box2d`。`mcpplibs.mwrap.box2d.macros` 把 20 个宏映射为常量、5 个读取长度单位的宏
  映射为函数(`B2_LINEAR_SLOP()`)、3 个 id 宏映射为 constexpr 函数;声明说明符、初始化器语法与断言留在
  `<mwrap/box2d/macros.hpp>`。包装仓库的 CI(Linux x86_64 GCC/LLVM、Linux arm64 GCC/LLVM、macOS、Windows、
  wasm32-emscripten)在 dev 与 release 下运行确定性场景:上游的 falling hinges(第 299 步、哈希 0x465F3DF4)与
  被撞倒的 20 层金字塔(600 步,哈希 0x790D7C28),1–8 个 worker、用户任务系统、SSE2 回退,各行逐位一致。
  GLOBAL 为 `mwrap-3.2.0` 发布资产,CN 为 GitCode `mcpp-res/mwrap-box2d` 镜像,sha256 一致。新增测试成员
  `tests/mwrap/box2d-physics` 与已安装模板及其许可文件的部署检查。
- **compat.box2d 3.2.0(新包)。** Box2D v3:游戏用 2D 刚体物理引擎(C17,MIT,无依赖)。按上游 CMake 的做法从标签归档
  构建 `src/*.c` 为静态库:`-std=gnu17`、`-ffp-contract=off`(上游为跨平台确定性对每个 GCC/Clang 设置,禁止乘加收缩为
  FMA)、上游默认的 SIMD 选择(x86_64 为 SSE2,并在运行时按 cpuid 分派 AVX2 求解器;arm64 为 Neon)、unix 上
  `-fPIC -fvisibility=hidden`,Linux 链接 `-lm -lpthread`;Emscripten 目标加上游同样的 `-msimd128 -msse2`(`target_cfg`)。
  不定义 BOX2D_VALIDATE / BOX2D_DOUBLE_PRECISION / BOX2D_PROFILE(与上游作为依赖使用时相同)。使用者 `#include <box2d/box2d.h>`。
  GLOBAL 为 GitHub 标签归档,CN 为 GitCode `mcpp-res` 镜像,sha256 两处一致;声明 `extensions.autoupdate`(`v${version}` 标签)。
  新增测试成员 `tests/examples/box2d`(三平台):版本、下落与休眠、接触与移动事件、射线与凸包,以及上游的确定性场景
  falling hinges(第 299 步全部休眠、变换哈希 0x465F3DF4,1 个与 4 个 worker、SSE2 回退路径)。
- **mcpplibs.mwrap.miniaudio 0.11.25(新包)。** miniaudio-m:以 C++23 模块(`import mcpplibs.mwrap.miniaudio;`)使用
  compat.miniaudio 0.11.25(MIT-0 或 Unlicense)。导出 `miniaudio.h` API 部分的全部 266 个类型与结构体标签、368 个枚举值与
  931 个 `MA_API` 函数(上游全局名不变),每个声明位于头文件声明它的同一预处理条件下;三个 `static MA_INLINE` 辅助函数在
  `mcpplibs::mwrap::miniaudio` 中适配;`mcpplibs.mwrap.miniaudio.macros` 把 27 个数值宏映射为常量,并把兼容名字
  (`ma_resource_manager_job*`)映射为类型别名与函数引用;属性、字符串化与平台/后端测试宏留在 `<mwrap/miniaudio/macros.hpp>`。
  包装仓库的 CI(Linux x86_64 GCC/LLVM、Linux arm64、macOS、Windows,以及 Web:wasm32-emscripten,node 下运行测试)
  在每个目标上依编译器自身的预处理审计导出。GLOBAL 为 `mwrap-0.11.25` 发布资产,CN 为 GitCode `mcpp-res/mwrap-miniaudio`
  镜像,sha256 一致。新增测试成员 `tests/mwrap/miniaudio-engine` 与已安装模板及其许可文件的部署检查。
- **mcpplibs.mwrap.sheenbidi 3.0.0(新包)。** sheenbidi-m:以 C++23 模块(`import mcpplibs.mwrap.sheenbidi;`)
  使用 compat.sheenbidi 3.0.0。导出已安装头文件的全部类型、结构体标签与 51 个 `SB_PUBLIC` 函数(上游全局名不变);
  `mcpplibs.mwrap.sheenbidi.macros` 把宏映射为常量与 constexpr 函数,并把无名枚举的 236 个枚举值映射为其 typedef
  类型的常量;`SB_PUBLIC`、`SB_DEPRECATED` 与 `extern "C"` 括号留在 `<mwrap/sheenbidi/macros.hpp>`。包装仓库的 CI
  (Linux x86_64 GCC/LLVM、Linux arm64、macOS、Windows)运行 Unicode 17.0.0 的 BidiTest.txt(770,241 例)与
  BidiCharacterTest.txt(91,707 例),0 错误。GLOBAL 为 `mwrap-3.0.0` 发布资产,CN 为 GitCode `mcpp-res/mwrap-sheenbidi`
  镜像,sha256 一致。新增测试成员 `tests/mwrap/sheenbidi-bidi` 与已安装模板及其许可文件的部署检查。
- **compat.sheenbidi 3.0.0(新包)。** SheenBidi:Unicode 双向算法(UAX #9)的 C 实现,Apache-2.0,无依赖;
  3.0.0 实现 Unicode 17.0.0,通过该版本的 BidiTest.txt 与 BidiCharacterTest.txt 全部用例。以上游的单一编译单元
  `Source/SheenBidi.c`(`SB_CONFIG_UNITY`)从源码构建为静态库,只导出公共头文件的 51 个 `SB*` 入口;使用者的包含路径
  只有 `Headers`(`#include <SheenBidi/SheenBidi.h>`),内部头文件所在的 `Source` 是私有包含目录。未定义
  `SB_CONFIG_EXPERIMENTAL_TEXT_API`(上游默认,实验性的 SBText 接口不编译)。是 compat.fribidi(LGPL-2.1-or-later)
  的宽松许可替代,可静态链接。GLOBAL 为 GitHub 标签归档,CN 为 GitCode `mcpp-res` 镜像,sha256 两处一致;
  声明 `extensions.autoupdate`(`v${version}` 标签)。新增测试成员 `tests/examples/sheenbidi`(三平台)。
- **openlifa.openmui 0.3.0。** OpenLifa 标准 openmui 的规范:registry、C ABI(`include/openmui.h`,
  在使用者的包含路径上)和声明其值类型的 C++ 模块 `openmui.spec`(语义树节点及其一致性检查、actor、
  信封、Core 组件契约)。actor、效果、授权与信封采用 openas 0.2。只依赖标准库(头文件为 C99);代码
  Apache-2.0,规范文本 CC BY-SA 4.0。GLOBAL 为 GitHub 标签归档。新增测试成员 `tests/examples/openlifa.openmui`。
- **openlifa.openas 0.2.0。** OpenLifa 标准 openas 的规范与声明它的 C++ 模块(`openas`、
  `openas.conformance`):actor 及其委托链的文本形式、动词的效果等级、系统上限之下的授权与单个请求的决定、
  运行信封的记录种类、退出码与错误码,以及动词描述、actor 与授权的一致性检查。只依赖标准库;代码 Apache-2.0,
  规范文本 CC BY-SA 4.0。GLOBAL 为 GitHub 标签归档。新增测试成员 `tests/examples/openlifa.openas`。
- **`gcc.libstdcxx` 16.1.0.1。** 向 llvm 构建提供 `mcpp:c++-abi=libstdc++`:安装时链接
  `xim:gcc` 16.1.0 载荷的头文件与运行库目录并写出自身清单(`std-module` 为 `bits/std.cc`),
  clang 据此以 libstdc++ 编译、`import std` 与链接(需要 mcpp 2026.10.26.1,SPEC-002 §7)。
  新增测试成员 `tests/examples/libstdcxx-llvm`。
- **openkal 0.17.1 及其实现 openkal-linux 0.18.1、openkal-macos 0.15.1、openkal-windows 0.13.1。**
  openkal 增加 `KAL_SPAWN_ONE_STRING` / `KAL_PROCESS_PROP_ONE_STRING`:接收单个字符串的系统(Windows)上,
  程序名之后的参数按原样连接,供以自身语法读取命令的命令解释器使用;接收参数向量的系统拒绝该标志。
  openkal-windows 实现它;openkal-linux 与 openkal-macos 把 SIGHUP 纳入结束请求;openkal-linux 以绝对名
  启动需要解释器的程序(`#!` 脚本的 `$0` 不再是 `/dev/fd/<n>`);openkal-macos 把 EBADARCH 与
  EBADMACHO 译为 `kal_err_not_program`。测试成员 `openkal` 移到这些版本,并观察单字符串标志在
  接收向量的系统上被拒绝。GLOBAL 为 GitHub 标签归档,CN 为 GitCode `mcpp-res` 镜像,sha256 两处一致。
- **openkal-linux 0.18.2、openkal-musl 0.22.1、openkal-llvm-runtime 0.16.1。** openkal-linux 的结束请求
  处理器以私有 futex 唤醒结束字(与 `kal_task_wait` 的等待一致),等待结束字的执行上下文由此被请求唤醒;
  此前共享唤醒到达不了私有等待,以等待结束请求结束的程序在请求后仍不结束。openkal-musl 与
  openkal-llvm-runtime 移到 openkal 0.17.1 这一轮:openkal 系列按精确版本固定,一个同时含 mcpplibs.os 0.2.0
  与 openkal-musl 0.22.0 的 ok image 图会出现两个 openkal。测试成员 `openkal`、`openkal-musl` 随之移动。
- **openkal-windows 0.13.2、openkal-musl 0.22.2、openkal-llvm-runtime 0.16.2。** openkal-windows 的有界等待
  按进程字的种类取得句柄:以有界生命期启动的程序由其记录命名,此前对它的每次有界等待都失败,
  调用方的时限(mcpp 的 `[hooks] timeout_seconds`)在 Windows 上不起作用。openkal-musl 与
  openkal-llvm-runtime 随之移动;测试成员 `openkal`、`openkal-musl` 随之移动。
- **openkal-windows 0.13.3。** 环境表在首次查询时于一把锁下填写一次,两个执行上下文同时首次查询时
  都读到已填写的表;此前其中一个可能读到空表,把已设置的变量(`PATH`)报为不存在。管道的有界读以
  性能计数器计量时限,此前把每次 1 ms 的睡眠计为 1 ms,而默认计时器下一次睡眠持续约 15.6 ms,
  100 ms 的时限约等待 1.5 s。测试成员 `openkal` 随之移动。
- **openkal-run、openkal-tools、openkal-ld 0.1.1,openkal-musl 0.22.3,openkal-llvm-runtime 0.16.3。**
  openkal-image 的三个包移到 openkal 0.17.1 这一轮:okrun 把 ok image 导入的名字绑定到 openkal-linux 0.18.2、
  openkal-macos 0.15.1 与 openkal-windows 0.13.3,以 `KAL_SPAWN_ONE_STRING` 启动命令解释器的 image 在 okrun
  下得到该标志的语义;三个包仍为同一版本、同一归档。openkal-musl 随 openkal-windows 0.13.3 与 openkal-ld 0.1.1
  移动,openkal-llvm-runtime 随 openkal-musl 移动。测试成员 `openkal`、`openkal-musl`、`openkal-tools` 随之移动。
- **openkal-platform 0.17.2。** 通用包(`universal = true`:一个包含两个架构的映像、启动器,自包含时按系统带上运行器);
  `okb` 包格式(平台插件经 mcpp.plugins.platform 0.20.0 运行 `okld bundle --package`);载体作为包的运行器、
  并能从内存运行一个映像 zip(单文件);`-ffunction-sections -fdata-sections` 与 `--icf=safe`;版本组移到
  openkal-image 0.1.3、openkal-musl 0.22.5、openkal-llvm-runtime 0.16.5。GLOBAL 与 CN 的 sha256 一致。
- **mcpp.plugins 0.20.0。** 新特性 `plugins-platform`(模块 `mcpp.plugins.platform`):平台插件与包格式提供者的
  `provide_format`(声明格式,并在请求该格式的一遍中由暂存包的 `mcpp-package.json` 生成 artifact action),以及平台的
  链接、产物命名、封装与运行主机的带检查的写法(mcpp SPEC-013 协议 17);`mcpp::plugins::package` 读取暂存包的
  `mcpp-package.json`(SPEC-014 §4.5)。SYCL 构建只有一个 C++ 运行时(libstdc++)。需要 mcpp 2026.10.27.1;
  `latest` 仍指向 0.19.1,随 mcpp 2026.10.27.1 发布移动。
- **openkal-platform 0.17.1(新包)。** ok 映像目标 `x86_64-openkal`、`aarch64-openkal` 的平台包(mcpp SPEC-013):
  工具链 llvm@23.1.3,C 库 openkal-musl 0.22.3,C++ 与编译器运行时 openkal-llvm-runtime 0.16.3,工具 okld、okrun
  (openkal-tools 0.1.1),编译与链接约定、封装、命名、运行器、载体,宿主组合与 openkal 0.17.1 的版本组。
  mcpp 2026.10.27.1 的目标表为这两个目标选用它,工程不再声明运行时与工具。GLOBAL 为 GitHub 标签归档,
  CN 为 GitCode `mcpp-res` 镜像,sha256 两处一致。
- **openkal 0.17.2 这一轮:openkal-ld、openkal-run、openkal-tools 0.1.2,新包 openkal-bind 0.1.2,
  openkal-musl 0.22.4,openkal-llvm-runtime 0.16.4。** openkal-image 0.1.2 定义 okb v1(`docs/okb.md`):
  一个 ZIP 归档,映像以 stored 存放、数据起点按 64 KiB 对齐,`okb.json` 给出各架构的目录、入口与每个成员的
  sha256,`okb.sig` 对清单签名;`okld bundle` / `okld bundle check` 写出并校验它,okrun 运行它;libokrun
  增加 `okrun_run_okb_bytes`、`okrun_run_images`(从内存运行,不写盘)与 `okrun_open_library` /
  `okrun_symbol` / `okrun_close`。openkal-bind 是构建插件(模块 `mcpp.mcpplibs.openkal_bind`,
  `docs/bind.md`):以 `.okso` 加 C 头文件发布的库,在 Linux、macOS、Windows 上经它生成的绑定调用,
  边界(`long`、`wchar_t`、变参、无原型的回调、未导出的函数)在构建时拒绝。四个包同一标签、同一归档。
  openkal-musl 0.22.4 的 `renameat2` 按标志的含义执行或拒绝(`RENAME_NOREPLACE` 为
  `kal_fs_rename_flags`,`RENAME_EXCHANGE` 与其余标志为 `EINVAL`);此前不读标志,交换会丢失第二个文件。
  openkal-llvm-runtime 随 openkal-musl 移动。新增测试成员 `openkal-bind`(在构建程序中构建一个映像并经
  插件绑定,测试经绑定调用映像、映像回调测试程序);`openkal`、`openkal-musl`、`openkal-tools` 随之移动。
- **openkal-ld、openkal-run、openkal-tools、openkal-bind 0.1.3,openkal-musl 0.22.5,openkal-llvm-runtime 0.16.5。**
  `okld bundle <out.okb> --package <树>` 由 mcpp 暂存的通用包写出 okb:读取 `mcpp-package.json`(mcpp SPEC-014 §4.5),
  角色为 `image` 的文件按 `lib/<arch>/` 成为成员,各自的架构与 sha256 被核对,入口取 `launch.entry`;这是
  openkal-platform 的 `okb` 包格式的动作。openkal-musl 随 openkal-ld 0.1.3 移动,openkal-llvm-runtime 随
  openkal-musl 移动。测试成员 `openkal`、`openkal-bind`、`openkal-musl`、`openkal-tools` 随之移动。
- **mcpplibs.os 0.2.0。** mcpp 的操作系统层所承载的内容进入 os:`exec`(本进程成为另一个程序)、
  一个管道按写入顺序承载输出与错误输出、追加写与持久化、卷的容量、`place` 与 `exchange`、属主、
  处理器数与可用内存、有界读取输入、发往错误流的输出、保留中断的原始模式,以及 Windows 的事实。
  基于 openkal 0.17.1(openkal-linux 0.18.2、openkal-macos 0.15.1、openkal-windows 0.13.3);ok image
  形态基于 openkal-llvm-runtime 0.16.3 与 openkal-tools 0.1.1。测试成员 `os` 移到 0.2.0,并观察两个输出
  经一个管道按序到达。

### Changed

- **compat.miniaudio 0.11.25 以 `gnu11` 编译(可构建到 wasm32-emscripten)。** Emscripten 上 miniaudio 的 Web Audio
  后端经 `EM_ASM` 内联 JavaScript,Emscripten 在严格的 `-std=c*` 模式下拒绝 `EM_ASM`(上游 miniaudio.h §2.6:
  不能使用 `-std=c*`),原来的 `c_standard = "c11"` 使 `mcpp build --target wasm32-emscripten` 编译失败;改为
  `gnu11` 后构建并在 node 下运行,启用的后端为 Web Audio 与 Custom(上游在 Emscripten 上不构建需要后台线程的 Null 后端)。
  其他平台不受影响(上游 CMake 不设标准,GCC/Clang 默认即 GNU 方言);归档与 sha256 不变,仍为同一版本。
- **同一归档的包由点名其中一个的成员一并构建。** 候选矩阵要求每个新增版本有直接点名它的测试成员;
  openkal-image 的 openkal-ld、openkal-run 与 openkal-tools 同一标签、同一归档,彼此以 `path` 依赖到达,
  成员 `openkal-tools` 构建 openkal-tools 时即从同一字节构建另两个。`tests/autoupdate/ci.py` 的 matrix
  对没有直接成员的包,查找本次计划中归档 URL 完全相同且有直接成员的同胞包,由该同胞的任务覆盖;
  不同归档的包仍报 `no candidate consumer`。
- **CI 按包身份选择受影响的成员。** `validate.yml` 的 select 曾在成员清单中查找描述符短名的
  子串:`pkgs/o/os.lua` 选中 205 个成员中的 113 个(`boost-*`、`macos`、`cfg(os = ...)`、
  注释里的 `exists`),而经 asio、curl 依赖 `compat.openssl` 的成员一个也未选中。
  `tests/select_members.py` 以 mcpp 的规则读取成员声明的 `(namespace, name)`,沿描述符的
  `deps` 与包归档内清单(按 tag 读 raw.githubusercontent.com;release 资产则读归档本身,
  并经 `path` 依赖到达同一归档的其他清单)陈述的依赖求传递闭包,选出依赖图含被修改身份的成员。
  归档以 sha256 固定,已读结果由 `actions/cache` 保存。读不到的清单记为警告,由每周全量运行覆盖。
- **`compat.sycl-runtime` 在 Linux 上要求 `mcpp:c++-abi=libstdc++`。** `libsycl.so` 在 libstdc++
  上抛出 `sycl::exception`,而一个进程中的两套 C++ 运行时之间带类型的 `catch` 不会匹配
  (mcpp-community/mcpp#838)。gcc 工具链,或 llvm 加 `gcc.libstdcxx`,满足该要求;其他构建
  在编译前被拒绝。测试成员 `sycl-runtime` 在 Linux 上陈述 gcc。
- **`mpusz.mp-units` 要求 `mcpp:compiler=llvm`**(原为 `mcpp:c++-abi=libc++`):约束来自 GCC 16.1
  的模块缺陷,是编译器而不是 C++ 库。**`compat.glfw`** 以 `requires = { "mcpp:c-abi=glibc" }`
  取代能力 `abi:glibc`。

- **`openkal-macos` 0.14.1、`openkal-musl` 0.21.1、`openkal-llvm-runtime` 0.15.6。** macOS 上
  经 `fork` 复制的程序此前不能启动线程(`pthread_create` 返回 `EAGAIN`,
  mcpplibs/openkal-musl#55):`kal_space_start` 只调用复制原语,而该系统的 `fork` 在原语前后
  由系统库各部分加锁并在副本中更新自身状态。0.14.1 按系统库自身的顺序调用这些导出的部分;
  0.21.1 与 0.15.6 移动锁定版本。两个 openkal 测试成员随之移动。GLOBAL/CN 与 sha256 的取法同上。
- **`openkal` 0.16.0 及随之移动的七个包。** 规范新增 `kal_task_start_sized`(栈大小的下限,
  给不出时为 `kal_err_no_memory`)与 `KAL_TERM_PASS_INPUT`(环境不改写所输入的字节),
  并补述关闭目录即结束其未读完的枚举。`openkal-linux` 0.17.0、`openkal-macos` 0.14.0、
  `openkal-windows` 0.12.0、`openkal-emscripten` 0.5.0 实现三者;`openkal-opensbi` 0.8.3
  只移动规范的锁定版本;`openkal-musl` 0.21.0 让线程得到所请求的栈并在 raw 模式下区分
  回车与 Ctrl+J;`openkal-llvm-runtime` 0.15.5 移动 C 库的锁定版本。GLOBAL 为上游 tag 归档,
  CN 为逐字节相同的 gitcode 资源,均按记录的 sha256 核对。
  新增两个测试成员:`tests/examples/openkal`(规范在三平台、各实现在自身平台,以及新声明的 C
  层行为)与 `tests/examples/openkal-musl`(三份报告的原始程序,Linux)。
- **`compat.httplib` 0.62.0。** 在 `0.53.1` 之外新增版本键(旧键保留)。仍是纯头文件 Form B:
  归档根目录仍只有一份 `httplib.h`(747,115 → 846,648 字节,增量是 SSE 客户端、WebSocket
  辅助与加固,全部落在头内,不引入 define、源文件或链接依赖),描述符的内联构建无需改动。
  上游 CMake 的 `option()` 集合与 `target_link_libraries` 在 0.53.1→0.62.0 之间逐项相同
  (两版实测 diff),三平台 ldflags 照旧。0.62.0 上游认识 wolfSSL/MbedTLS 后端,但本索引
  没有对应的 compat 包,`tls` 仍只接 OpenSSL,不新增 feature。实测(Windows / mcpp
  2026.10.11.1 / LLVM 23.1.3 + MSVC 14.44):`mcpp xpkg parse` OK;`httplib`、`httplib-zlib`、
  `httplib-brotli`、`httplib-no-exceptions` 各 1 passed。`httplib-tls` 与 `httplib-zstd`
  在本机都止步于依赖安装、未编到本包:`compat.openssl` 3.5.1 的 Windows 安装钩子需要带
  `Locale::Maketext::Simple` 的 Perl,而本机没有 Perl;`compat.zstd` 1.5.7 的上游 tag 归档含
  符号链接 `tests/cli-tests/bin/unzstd -> zstd`,Windows 上 xlings 无法创建。两项都与本次
  改版无关,交 CI 裁决。六个测试成员同步改到 0.62.0。
- **`compat.wolfssl` 5.9.4。** wolfSSL(TLS/crypto)以 C 源码 compat 形态收录,上游最新稳定
  tag 为 `v5.9.4-stable`。上游的 autotools/CMake 都会在编译前生成 `wolfssl/options.h`,而内联
  描述符无法运行 configure,因此把该步骤的两项输出原样带入:`sources` 逐条抄自上游 CMake 默认
  的 `generate_lib_src_list()`(5.9.4 的 `src/ssl_*.c`、`src/bio.c`、`src/x509*.c`、
  `src/pk*.c`、`src/conf.c` 由 `src/ssl.c` `#include`,故不单列;`wolfcrypt/src/{evp,
  evp_pk,asn_tsp,asm,ecc_fp}.c` 同理);`generated_files` 写入
  `mcpp_generated/wolfssl/options.h`,即 CMake 默认选项生成的配置头,平台探测改写为
  `_WIN32`/`__linux__`/`__SIZEOF_INT128__`/x86_64/aarch64 分支。描述符通过 `cflags` 与
  default-implied feature 同时下发 `WOLFSSL_USE_OPTIONS_H`,库与消费者编译同一份配置,
  结构体布局和功能集不会分叉。默认功能集:TLS 1.3/1.2、AES-GCM、ChaCha20-Poly1305、ECC、
  DH、RSA-PSS、SHA-2/3/SHAKE、ML-KEM,并保留 CMake 的加固默认值(`NO_OLD_TLS`/`NO_DES3`/
  `NO_RC4`/`NO_MD5`/`NO_MD4`/`NO_DSA`/`NO_PSK`);Curve25519/Ed25519 与系统 CA 读取在
  CMake 默认配置里本就关闭,本包保持一致。CN 镜像尚未发布到 `mcpp-res`,按先例用纯字符串
  url 回退 GLOBAL。实测(Windows / mcpp 2026.10.17.1 / LLVM):
  `mcpp xpkg parse --all-os pkgs/c/compat.wolfssl.lua` 三平台 `parse OK`(38 sources,
  2 include dirs,1 generated file);冷 `mcpp test -p wolfssl` →
  `test result ok. 1 passed; 0 failed`(头文件版本串、SHA-256 KAT、AES-256-GCM 往返及
  坏 tag 拒绝、RNG、P-256 密钥导出)。新增成员 `tests/examples/wolfssl`;linux/macOS
  两腿交 CI 裁决。

- **`compat.soci` 4.1.4。** SOCI(C++ 数据库访问层)以 C++ 源码 compat 形态收录:上游 `src/core`
  的 22 个 TU 与 sqlite3 后端的 10 个 TU 编入**同一个 lib** —— 上游 CMake 把它们拆成
  `soci_core`/`soci_sqlite3` 两个库,但 mcpp 的 `sources` 是每包一张表,且没有后端的 core 连
  `session` 都开不了,所以拍平。两处"上游归档里没有、必须补"的东西:`3rdparty/sqlite3` 是**空的
  git submodule**,由 `compat.sqlite3` 3.45.3 的依赖边替代(与 `compat.sqlitecpp` 同构);
  SOCI 4.1 起 core 与后端共 12 个 TU 无条件 `#include <fmt/format.h>`,依赖刚落的 `compat.fmt`
  12.2.0 —— **必须是普通形态,且这是实测**:先按「取 `fmtlib.fmt` 的头 + `FMT_HEADER_ONLY` 编进
  自己的 TU」实现过,`mcpp test -p soci` 一路走到**链接期**才失败,
  `lld-link: error: duplicate symbol … fmt::v12::detail::dragonbox::cache_accessor<double>::compute_mul`
  (模块对象的 COMDAT 键与 header-only 的不相撞),换成编译库形态后无需任何 define。
  三组 CMake PRIVATE 定义分别落地:`-DSOCI_SQLITE3_SOURCE=1` 进 `cxxflags`(缺它
  `soci-sqlite3.h` 只给两句前置声明,每个 `sqlite3_*` 调用都报 "use of undeclared identifier" ——
  消费者走的恰是**不定义**的那条路,所以它必须止步于本包);带引号的
  `SOCI_LIB_PREFIX`/`SOCI_LIB_SUFFIX`/`SOCI_DEBUG_POSTFIX` 走 `-include` shim(引号穿不过
  描述符 → mcpp → argv 管道,`compat.unixodbc` 撞过同一堵墙);`SOCI_HAVE_SQLITE3` 所在的
  `soci-config.h` 是 CMake `file(GENERATE)` 产物、**不随 tarball 发布**,按「只开 sqlite3」
  时的输出逐字节复刻进 `generated_files`。Boost 不做依赖:不加 `SOCI_USE_BOOST` 时全部源码不碰它。
  其余七个后端**不做 feature**:它们的客户端库要么根本不在索引里(libpq / Oracle / DB2 /
  Firebird),要么驱动管理器按平台来源天差地别而 feature 的 `deps` 没有平台门控(odbc 在 linux 靠
  `compat.unixodbc` 源码构建、windows/macOS 靠系统 SDK);以后加后端是一行 `sources` 加一行
  `deps`,不是重构。实测:`mcpp xpkg parse pkgs/c/compat.soci.lua` → `parse OK`;
  `mcpp test -p soci` 冷验证 → `test result ok. 1 passed; 0 failed`(llvm 23.1.3 / MSVC ABI)——
  `:memory:` 建表、绑定参数双向往返、rowset 迭代、`indicator` 区分 NULL、事务三条路径
  (显式 `rollback()` / 出作用域未 commit 自动回滚 / `commit()`)、后端自带错误码与
  `constraint_violation` 分类、`SOCI_VERSION` 精确断言。消费侧命令行另有两条旁证:实测**无
  `-DNDEBUG`**(所以那批断言是活的,不是空测试)、**无 `-DSOCI_SQLITE3_SOURCE`**(私有定义
  确实没外泄)。⚠️ 后端以 `soci::sqlite3` **工厂对象**取得:`session("sqlite3", …)` 会走 SOCI 的
  动态加载器去 dlopen 一个本包故意不产出的 `libsoci_sqlite3.so`。⚠️ CN 镜像尚未发布到
  `mcpp-res`,按先例用纯字符串 url 回退 GLOBAL,补传后 sha256 不变。新增成员
  `tests/examples/soci`;linux/macOS 两腿交 CI 裁决。

- **`compat.fmt` 12.2.0。** {fmt} 的**头文件形态**(`#include <fmt/format.h>` + 链接)收录,
  即 `fmtlib.fmt`(模块形态)的非模块兄弟:同一个上游归档、同一个 sha256,身份却分开 ——
  想要 `#include` 写法的工程不必为此背上一个自己从不 `import` 的模块 BMI。形态是编译库:
  `sources` 直接抄上游默认 lib 的两份实现 TU(`*/src/format.cc`、`*/src/os.cc`,即 CMake 的
  `add_library(fmt src/format.cc)` 加上 `FMT_OS` 默认 ON 的 `src/os.cc`),
  `include_dirs = {"*/include"}`(前导 `*` 吃掉 `fmt-12.2.0/` 包装层)。没有
  `generated_files`、没有 anchor,也不需要任何 define:`FMT_OS` 在 12.2.0 已不被头文件读取,
  `FMT_SHARED`/`FMT_LIB_EXPORT` 是静态链路上不该定义的 DLL 词法,而 `src/fmt.cc` 是模块 unit,
  归 `fmtlib.fmt`。上游那个**独立的** C API 静态库(`src/fmt-c.cc` + `include/fmt/fmt-c.h`)
  按仓内 sources-only feature 收成 `features = { ["c-api"] = … }`,默认 OFF:只要 C++ 头的
  消费者不付这个 TU。**门控经负向实测**:把 `tests/examples/fmt-c` 的依赖改回纯版本号,它在
  **链接期**报 `lld-link: error: undefined symbol: fmt_vformat` 与 `fmt_vprint`(`fmt_arg`
  的构造在头里是 `static inline`,未解析符号只可能是 fmt-c.cc 的),带 feature 时包构建报
  3 units、不带报 2 units。⚠️ MSVC 的 `/utf-8` 属**消费侧**:上游标记它 PUBLIC 的唯一来源是
  `chrono.h` 的 `"µs"` 字面量,而本包三个 TU 及它们包含的全部头(base.h / format.h /
  format-inl.h)实测均为纯 ASCII;`cxxflags` 只作用于本包 TU,替消费侧表达不了,故不声明,
  只写进描述符注释。⚠️ CN 镜像尚未发布到 `mcpp-res`,按 `compat.rapidcsv` 的先例用纯字符串
  url 回退 GLOBAL;补传镜像后改回 `{ GLOBAL, CN }` 即可,sha256 不变。
  实测:`mcpp xpkg parse pkgs/c/compat.fmt.lua` → `parse OK`;`mcpp test -p fmt` →
  `test result ok. 2 passed; 0 failed`(format.cc 的编译库断言 + os.cc 的
  `getpagesize`/pipe 往返),`mcpp test -p fmt-c` → `1 passed; 0 failed`;`.xpkg.lua` 快照
  里就是本 checkout 这份带 `c-api` 表的描述符,证明解析没落到远端已发布索引。新增成员
  `tests/examples/fmt` 与 `tests/examples/fmt-c`;linux/macOS 两腿交 CI 裁决。

- **`compat.sdl3` 3.4.18。** 在 3.4.2 之外新增版本键(旧键保留,与 `compat.ftxui`
  等既有做法一致)。**补丁号不等于补丁**:这份描述符里真正会失效的东西是源集与两份
  签入 config,所以四处都按两个 tarball 实测过,而不是假定 —— `src/` 只增 4 个文件
  (两个 Vulkan 着色器头落在已整目录 glob 的目录里;另两个是
  `src/video/wayland/SDL_waylandutil.{c,h}`,wayland 本就不在任何列表里),签入的
  windows/macOS config 与 3.4.2 **逐字节相同**(两个平台的源集正是从它们反推的,
  所以这次抬版本它们照用),linux config 的模板只动三行(删掉的 `HAVE__UITOA` 本就
  未定义,新增的 `SDL_EMSCRIPTEN_PERSISTENT_PATH_STRING` 只对 emscripten 有意义),
  上游 `CMakeLists.txt` 的源选择未变(唯一的 `.c/.m` 命中行是缩进)。
  ⚠️ 生成的 linux config **不重新生成**:它是冻结的 CMake 输出,3.4.18 新增而它不知道
  的宏一律读作关闭 —— 与当初裁剪的方向一致,也与「config 只许声明索引真正打了包的
  东西」同源。⚠️ CN 镜像 3.4.18 尚未发布到 `mcpp-res`,按 `compat.ftxui` 7.0.3 的先例
  用纯字符串 url 回退到 GLOBAL(`list_cn_urls.lua` 明写忽略纯字符串 url,所以
  `mirror-cn-reachable` 对这一条是空集);补传镜像后改回 `{ GLOBAL, CN }` 即可,
  sha256 不变(镜像按原样重托管 tag 归档)。
  实测:windows 本地 `mcpp test -p sdl3` 编完并跑通 —— 3.4.18 报出 3 个视频驱动,
  dummy 窗口 320x240、定时器前进,`test result ok. 1 passed`。linux/macOS 两条腿由
  CI 裁决:冻结的 linux config 是这次唯一没有被本地证伪的东西。

- **`compat.libserial` 1.0.0。** LibSerial 的 `SerialPort`/`SerialStream` 以 compat
  形态收录:上游 CMake `LIBSERIAL_SOURCES` 的三个 TU 编成一个 lib,公开头经
  `include_dirs` 暴露。仅声明 `linux`(公开头以 `<termios.h>` 开头、实现触及
  `<linux/serial.h>`,消费者用 `[target.'cfg(linux)'.dependencies]` 门控)。两处上游头
  文件缺陷在包内修复:`SerialPortConstants.h` 用 `uint8_t` 却未含 `<cstdint>`,由
  `generated_files` shim 补上;`SerialPort.h` 的 `call_with_retry` 用了 C++20 已移除的
  `std::result_of`,libc++ 下整个库编不过,由 `install()` 改写为等价的
  `std::invoke_result_t`。GLOBAL 为上游 tag,CN 为 `mcpp-res/libserial` 镜像,
  sha256 相同。

- **`openkal-llvm-runtime` 0.15.4。** 只移动锁定版本:openkal-musl 0.20.1 携带
  openkal-linux 0.16.1(修复线程局部存储镜像的位置)。该包的 `examples/cxx` 探针
  正是发现该缺陷的地方 —— C++ `thread_local` 对象的 guard 字节落在非零邻居上,
  构造函数从未运行;修复后同一探针通过(PR #34)。

- **`openkal-linux` 0.16.1 与 `openkal-musl` 0.20.1。** 0.16.1 修掉一处潜伏缺陷:
  线程局部存储的镜像被放在变量地址之下八字节(段声明 `p_align = 8, p_memsz = 56`
  时,链接器把变量放在 `tp - 56`,而区域按 16 对齐建成 64 深)。0.16.0 新增的
  实现自有 TLS 存储使该缺陷显形:两个带初值的线程局部变量互相读到对方的字节,
  C++ 的 `thread_local` 对象的 guard 字节落到非零邻居上而不构造 —— 由
  openkal-llvm-runtime 的探针在 runner 上报出。0.20.1 只移动锁定版本。
  GLOBAL/CN 与 sha256 的取法与前一行相同。

- **`openkal-linux` 0.16.0、`openkal-macos` 0.13.0、`openkal-windows` 0.11.0、
  `openkal-emscripten` 0.4.0、`openkal-opensbi` 0.8.2、`openkal-musl` 0.20.0。**
  六个同轮仓库的行:GLOBAL 为上游 tag 归档,CN 为字节一致的 gitcode 资源
  (sha256 两次取自上游、一次取自 CN,三者相同)。openkal-linux 以 `mincore` 实测
  映射、以 `mapping_end - RLIMIT_STACK` 与栈下最近映射之上一个 guard gap 的较高者
  为下界;openkal-macos 走 `_pthread_self` 与两个 `_np` 查询(三个名字补进
  `port/libSystem.tbd`);openkal-windows 走 `GetCurrentThreadStackLimits`(声明补进
  `src/win32.h` 与 `port/kernel32.def`);openkal-emscripten 走
  `emscripten_stack_get_base/_end`;openkal-opensbi 只移动锁定版本;openkal-musl 让
  `pthread_getattr_np` 对调用线程给出真实区间、对其它线程一律 `ENOSYS`。同时修掉
  openkal-linux 在 hosted 形态下从未描述自身 TLS 镜像的潜伏缺陷。

- **`openkal` 0.15.0 与六个同轮仓库。** 规范新增 `kal_task_stack`:一个执行上下文可以
  说出自己所在的栈区间(自问自答、不取句柄),用于替换 C 库移植层此前对
  `pthread_getattr_np` 的拒绝。openkal-linux 0.16.0 用 `mincore` 实测映射并以
  `mapping_end - RLIMIT_STACK` 与栈下最近映射之上一个 guard gap 两者中较高者为下界;
  openkal-macos 0.13.0 走 `_pthread_self` 与两个 `_np` 查询(三个名字同时补进
  `port/libSystem.tbd`);openkal-windows 0.11.0 走 `GetCurrentThreadStackLimits`
  (声明补进 `src/win32.h` 与 `port/kernel32.def`);openkal-emscripten 0.4.0 走
  `emscripten_stack_get_base/_end`;openkal-opensbi 0.8.2 只移动锁定版本;
  openkal-musl 0.20.0 让 `pthread_getattr_np` 对**调用线程**给出真实区间、对其它线程
  一律 `ENOSYS`,并撤回对应的 `[c-abi-absent]` 行。同时修掉 openkal-linux 在 hosted
  形态下从未描述自身 TLS 镜像的潜伏缺陷(上下文线程指针落在存储区错误一端),新增
  `tests/conformance_task_tls.cpp` 以非零初值观测该镜像。

- **`compat.libevent` 2.1.13。** Linux、macOS、Windows 分别通过上游 CMake 生成
  平台配置头,再由 mcpp 编译 libevent 核心、HTTP/DNS 扩展和对应系统后端;
  TLS 可选组件未收录。workspace 成员测试事件分派、缓冲区和 HTTP 对象。

- **`compat.muduo` 2.0.3 与 Boost 头组件。** muduo 仅支持 Linux;内联构建
  `muduo_base`/`muduo_net` 源码,按上游 2.0.3 的依赖补充 `compat.boost-any`、
  `compat.boost-circular-buffer`、`compat.boost-concept-check` 并复用既有 `compat.boost-utility`。
  三个新增 Boost 包各有 workspace 成员;muduo 的成员按 Linux 门控。上游归档使用 GLOBAL 地址,
  CN 镜像待补。安装钩子仅修补 C++20 移除的 `shared_ptr::unique()` 与缺失的 `<time.h>`。

- **`compat.yaml-cpp` 0.8.0 与 0.9.0。** YAML 1.2 解析与生成,按上游 CMake 目标原样编译
  (`src/*.cpp` + `src/contrib/*.cpp`),GLOBAL + GitCode CN 镜像字节一致。上游把
  `YAML_CPP_STATIC_DEFINE` 作为静态构建的 PUBLIC 定义;描述符的 `defines` 到不了消费者,
  所以用 `yaml-cpp/dll.h` 的同名遮蔽头送达,测试在编译期断言它到了(MSVC ABI 上缺它就是
  dllimport 链接错误,Linux 上看不出来)。两个版本各有一个测试成员(`yaml-cpp`、
  `yaml-cpp-v080`),都列入 `tests/openkal/members.toml` 在 openkal 上测量。

### Changed

- **候选门只在消费者构建候选包的平台上调度它。** `tests/autoupdate/ci.py` 的
  `member_platforms` 读取消费者清单:无条件依赖在三个平台调度;`cfg(os = ...)` 或
  `cfg(windows)` 下的依赖只在该平台调度;其余条件(环境、架构)不调度任何宿主作业,由包自身仓库
  在目标上测量。mcpp 只锁定宿主解析到的包,向另一平台的 runner 要平台包的锁定证明必然失败;
  `test_ci.py` 覆盖了这条规则。

- **站点的 openkal 分面改为两个取值:`openkal-ecosystem` 与 `openkal-compat`。** 原先的
  「openkal itself / runs on openkal / fails on openkal」是句子而不是名字。构成 openkal 的
  包归入 `openkal-ecosystem`;测试项目在 openkal 依赖图中测得 `runs` 的包归入
  `openkal-compat`。只测得 `builds` 或 `fails` 的包不再归入分面,其页面仍按目标列出测量结果
  与第一条诊断。
- **openkal 测量按改动选成员,不再每次全量。** `compat.py select --base <merge-base>`:
  改动 openkal 家族描述符、`pins.toml`、`compat.py` 才测全部成员;改 `members.toml` 只测
  新增或改动的条目(`[not-portable]` 计入所指成员,`[excluded]` 不选);改
  `tests/examples/<成员>/` 测该成员;改描述符测依赖它的成员。`selftest` 为每条规则各加一例。
- **openkal 的 Windows 目标改名为 `x86_64-windows-musl`。** 依赖图在 Windows 上呈现的是
  musl 的 C 环境,不是 MinGW;`x86_64-windows-gnu` 会被读成 mingw-w64 构建。实测同一依赖图:
  cli11、zlib、cmp-module 仍 runs,curl 仍停在同一条 `curl_setup.h:591`。2026-09-23 之前的
  结果仍记在旧名下。
- **CN 镜像可以由库的维护者自己托管。** `check_mirror_urls.lua` 要求 `CN` 是 gitcode 的
  release 资产(`https://gitcode.com/<owner>/<repo>/releases/download/…`),不再限定
  `mcpp-res` 组织;`mcpp-res` 仍是默认。#463 起 `main` 上的 lint 因 `ZheFeng7110.boost`
  的维护者镜像而失败,现在通过。

### Fixed

- **索引制品按提交只定一次字节,两个托管端提供同一份。** 同一提交重跑发布(夜间 cron)
  会重新打包:条目时间取自检出,于是字节不同;GitHub 以 `--clobber` 替换了资产,GitCode
  不能替换而保留第一份,两端指针却都改成第二份的摘要。2026-09-16 实测 v7649883:
  GitHub `78535f36…`(553573 字节)、GitCode `d89135a3…`(553557 字节),树相同。CN 客户端
  因此拒收 GitCode 的字节并回落到 GitHub(mcpp-community/mcpp#648)。现在
  `tools/publish_mcpp_index.sh` 先复用已发布的同版本字节(先问不可替换的 GitCode),
  新打包则可复现(排序、固定属主/权限/条目时间、`gzip -n`),发布末尾逐端取回比对摘要,
  不一致即失败。xim-pkgindex 在 2026-09-05 以同样方式修过同一缺陷。

### Changed

- **farm 只携带这个 runtime 够得到的东西,并且把「一个钉挪动」这件事在整条链上补齐。**
  三个 farm(`compat.glx-runtime` / `compat.opencl-runtime` / `compat.vulkan-runtime`)
  一起到 2026.09.11,消费者链 `compat.glfw` 3.4.0.1、`compat.opencl` 2026.09.11、
  `compat.vulkan` 1.4.357.2、`compat.sycl-runtime` 2026.09.11 同步。

  ⭐ **剔掉 `libnvidia-pkcs11*`,并撤回它带来的 OpenSSL 依赖。** 它是加密令牌模块,
  由应用自己的 PKCS#11 配置加载,不由任何 GPU 驱动派发;进 farm 只因为名字匹配
  `libnvidia*.so.*`。判据是 `LD_DEBUG=libs`(**带对照**):两条链上 `pkcs11` 出现
  **0 次**,而驱动确实够得到的 `libnvidia-glvkspirv` 出现 6 次、OpenCL adapter 出现
  23 次 —— 对照证明这个仪器分得开,所以 0 是读数不是沉默。它们也是 farm 里唯一需要
  `libcrypto` 的成员,随之消失的还有那条无解的 `libcrypto.so.1.1`(OpenSSL 1.1 上游
  已 EOL)。

  ⚠️⚠️ **一个更早的判据什么都没测到**:把成员删掉看示例还跑不跑 —— 删掉
  `libnvidia-glvkspirv` 示例照样跑。原因是被测二进制和被改的 farm 不是同一个
  (产物目录有两个,钉着不同版本)。**判据又一次指错了对象。**

### Fixed

- **三处只有真跑一遍才会现形的缺陷。**

  ⚠️⚠️ **排除循环遍历了模式表却把模式写死。** `compat.vulkan-runtime` 的
  `never_farm_patterns` 绑定了 `pat` 然后传了字面量 `libnvidia-gtk*`,于是这张表
  **看起来是列表、行为上只有一条**。往里加 `libnvidia-pkcs11` 毫无效果 —— farm 依旧
  81 个成员、两个 PKCS#11 都在,这是「排除」写完之后才发现的。

  ⚠️⚠️ **`readelf -d` 不是传递的,一趟补不完。** 上一版用 `ldd`(答案是整个传递闭包)
  所以一趟够;换成 `readelf` 是对的(它答**文件**说什么,而不是**这台机器**能不能解析),
  但这一轮补进来的库会带来自己的依赖。实测:`compat.glx-runtime` 第一次真安装,
  farm 从 52 涨到 77 **仍缺 9 条**,包括 `libLLVM.so.20.1` 和 `libstdc++.so.6`。
  现在迭代到不动点(带上界防环),再测 **86 个成员、0 缺口、0 封条**。

  ⚠️ 找不到 `readelf` 时那一趟静默返回空,读数与「已完全闭合」相同;现在明确告警,
  且 `compat.glx-runtime` 的工具查找也先查 store 再查 PATH。

  实测(本机,真驱动):`compat.glx-runtime` 86 成员 / 0 缺口,**零直接宿主触达** ——
  4 条走 `xim:nvidia-gl-host-link`、24 条走其它 xim 载荷、其余走 subos 库视图。
  SYCL 示例 `members 49 / walked 49 / findings 无`,Vulkan 示例
  `members 56 / walked 56 / findings 无`,两者都在 RTX 4080 上跑出正确结果。

### Fixed

- **两处只有把 glx 那一版真正跑一遍才会现形的缺陷。** 上一轮我量了 opencl 和
  vulkan,`compat.glx-runtime` 的新逻辑**从头到尾没有被执行过**。

  ⚠️⚠️ **`DT_NEEDED` 里可以是绝对路径。** 这个 farm 的四个 glvnd 厂商入口
  (`libEGL_nvidia`、`libGLESv1_CM_nvidia`、`libGLESv2_nvidia`、`libGLX_nvidia`)
  直接写着 `/lib/x86_64-linux-gnu/...`。loader 对这类条目直接打开、**完全不走
  搜索路径**,所以 farm 既服务不了它也不该为它封 unserved —— 而把它当 soname 会
  去查一个带斜杠的名字,并且造出一个**名字是路径**的 unserved 链接。三个包一并
  跳过这类条目。

  ⚠️ **找不到 `readelf` 时那一趟静默返回空**,读数与「farm 已完全闭合」一模一样。
  这正是这批改动要消灭的那种混淆,只是掉到了工具查找这一层。现在会明确告警,
  并且 `compat.glx-runtime` 的工具查找也和另外两个一样**先查 store 再查 PATH**
  —— 这个包跑在从未被要求装工具链的机器上。

  实测(本机,对着已装的 glx farm 走同一套逻辑):52 个成员、跳过 4 条绝对路径、
  19 条需补,**19 条全部来自生态载荷,0 条 unserved**,没有路径形状的条目。

### Changed

- **`compat.vulkan` 1.4.357.1 —— 移动一个钉,需要一个新版本。**
  上一条把 `compat.vulkan` 对 `compat.vulkan-runtime` 的钉从 2026.09.07 挪到
  2026.09.10,**没有抬 `compat.vulkan` 自己的版本**。对一台已经装着
  `compat.vulkan@1.4.357.0` 的机器,那份已安装副本里**记着的**仍是 2026.09.07;
  而同时**自己也直接声明** `compat.vulkan-runtime` 的消费者(mcpp 的图形示例在
  `cfg(linux)` 下就是这么写的)拿自己的钉去比,于是构建停在
  `irreconcilable versions`。

  ⚠️⚠️ **本地测不出来**:重新解析过索引的机器两边都读到 2026.09.10,毫无冲突。
  它是在 CI 上、一个 `~/.mcpp` 是热的 runner 上现形的。**「本机绿」在这一类升级
  问题上等于零信息量。**

  ⭐ 规则:**一个包如果钉着另一个包的版本,那个钉挪动时它自己必须换版本** ——
  换版本买到的是一次重装,重装才会按当前索引重新记录。`1.4.357.0` 保持原样,
  已经持有它的机器照原样解析。

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
