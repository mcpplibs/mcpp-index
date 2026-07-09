# OpenCV 落地实现与本地验证记录(compat.opencv,install()-CMake,host-free)

**日期**: 2026-07-08
**承接**: `.agents/docs/2026-07-08-opencv-ecosystem-adoption-research.md`(调研报告,决策依据)
**产出**: `pkgs/c/compat.opencv.lua` + `tests/examples/opencv/`(workspace member)+ README 一行 + 本文档
**mcpp**: 0.0.85(与 CI `MCPP_VERSION` 一致)

---

## 1. 形态与最终决策(与调研报告一致)

- **单包 `compat.opencv`**,**install()-hook 驱动 OpenCV 自带 CMake** 从源码构建(compat.openblas 模式,Make→CMake)。
- **MVP 模块集**:`core + imgproc + imgcodecs`(`-DBUILD_LIST`),第三方 codec 全走 tarball 内置 `3rdparty/`
  (`-DBUILD_ZLIB=ON -DBUILD_PNG=ON -DBUILD_JPEG=ON`)——**零外部依赖**。
- **模块/开关是 recipe 内固定 profile**,不是 mcpp feature(feature 不能带 cflags/include_dirs/generated_files、
  也传不进 install();见调研报告 §3/§6)。更大变体(calib3d/dnn/highgui/contrib)是后续独立包。

## 2. host-free / 生态闭环 —— 核心约束,已证明

用户硬约束:**不能依赖 host,完全 mcpp 生态闭环**。落实与证据:

- 构建只用 **生态工具**,均为声明的 build-dep,从不碰 host:
  - `xim:cmake@4.0.2`(`~/.xlings/data/xpkgs/xim-x-cmake/4.0.2/bin/cmake`)
  - `xim:ninja@1.12.1`
  - `xim:gcc@16.1.0`(与 mcpp 消费侧解析到的同一 g++:`Resolved gcc@16.1.0 → …/xim-x-gcc/16.1.0/bin/g++`)
- **离线证明**:在 **network-isolated 命名空间**(`unshare -rn`)里跑完整 configure+build+install,
  **零下载**。唯一的 configure 期下载(gapi 的 ADE zip)由 `-DWITH_ADE=OFF` 消除(gapi 本就被 BUILD_LIST 白名单排除)。
  其余全部来自 tarball 内置 `3rdparty/` 源码编译。
- install() 里 CMake 的 `CMAKE_C/CXX_COMPILER`、`CMAKE_MAKE_PROGRAM` 全部显式指向 build-dep 解析出的 bin
  (`pkginfo.build_dep` + PATH 兜底),不依赖 host PATH。

## 3. ABI:C++ 库的工具链一致性(关键工程点)

OpenCV 是 C++,静态库的 libstdc++ ABI 必须与 **消费者链接用的编译器** 一致。

- install() 用 `xim:gcc@16.1.0`(gcc/libstdc++)构建;mcpp 在 linux 默认也解析到 `gcc@16.1.0`
  → **ABI 天然对齐**(实测 mcpp 日志 `Resolved gcc@16.1.0`)。
- **linux-gated**:macOS 默认 clang/libc++,与 gcc/libstdc++ 的 `.a` 会 ABI 冲突;Windows 是 MSVC-ABI clang。
  两者均为后续项。测试工程按 `cfg(linux)` 门控(gui-stack 先例),off-linux 为 no-op main,
  `mcpp test --workspace` 在 mac/win 干净通过。
- 这暴露一个 **通用能力缺口**(见 §6 第 1 条):install() 应能拿到"mcpp 已选定的工具链",让源码构建对齐目标 ABI。

## 4. descriptor 关键点(`pkgs/c/compat.opencv.lua`)

- `sources = { "mcpp_opencv_anchor.c" }`:anchor **不** 放进 `generated_files`,而由 install() 写出 → 其缺失正是
  触发 mcpp 运行 install()(=触发 CMake 构建)的机制(compat.openblas / compat.xcb 同款)。
- `include_dirs = { "include/opencv4" }`:install 后头文件落点,用户 `#include <opencv2/core.hpp>`。
- 链接(per-OS `linux`/`macosx` 块):模块库在前、其 3rdparty 在后、系统库最后;OpenCV 把内置 3rdparty 归档放在
  `lib/opencv4/3rdparty/`,故需第二个 `-L`:
  ```
  -Llib -Llib/opencv4/3rdparty
  -lopencv_imgcodecs -lopencv_imgproc -lopencv_core
  -llibpng -llibjpeg-turbo -lzlib -ldl -lpthread -lm
  ```
- `CMAKE_POLICY_VERSION_MINIMUM=3.5`:让 CMake 4.0.2 能解析 OpenCV 及其 3rdparty 的老 `cmake_minimum_required`。
- Windows:xpm 声明齐三平台(索引完整性 + 未来 CN 镜像),但 install() 在 windows 直接返回,anchor 由
  `generated_files` 提供(source 构建是后续项)。
- **CN 镜像**:本会话无 `GITCODE_TOKEN`(无 mcpp-res 写权限),按 add-package skill 采用 **纯字符串 GLOBAL url**,
  CN 用户回退 GLOBAL,镜像由维护者后续补(`mcpp-res/opencv`,资产 `opencv-4.13.0.tar.gz`)。

## 5. 本地验证(mcpp 0.0.85,linux x86_64)

| 步骤 | 命令 | 结果 |
|---|---|---|
| 上游 sha256(两次稳定) | `sha256sum opencv-4.13.0.tar.gz` | `1d40ca017ea51c533cf9fd5cbde5b5fe7ae248291ddf2af99d4c17cf8e13017d` |
| 离线隔离构建 core+imgproc+imgcodecs | `unshare -rn cmake … && cmake --build` | **零下载**,产出 6 个 `.a`,~81s(4 job) |
| 独立链接+运行(mcpp g++ 16.1.0) | 手工 `g++ roundtrip.cpp -l…` | `opencv ok=1 core=4x4x3 gray(blue)=29 png_bytes=82 decoded=4x4` |
| **端到端 mcpp 管线** | `mcpp test`(fetch→install() CMake→link→run) | ✅ **PASS**(mcpp **0.0.87**):`test result ok. 1 passed`。曾在 ≤0.0.86 被阻断(§5.1),根因为 mcpp 把全局索引 xim 误注入项目作用域,已在 0.0.87 修复(见 `2026-07-09-mcpp-builddep-loader-store-split-rootcause.md` + mcpp 仓 `2026-07-09-project-index-scope-global-infra-fix.md`)。cmake 现装进全局 registry,项目 store 仅含 compat.opencv。 |
| lint(CI 同款) | `mcpp xpkg parse` + `lua5.4 loadfile` | PARSE_OK / LUA_LOAD_OK,`unknown_keys=[]` |

测试断言(`tests/examples/opencv/tests/roundtrip.cpp`,linux-gated):core 造 `cv::Mat` → imgproc `cvtColor` BGR→GRAY
(蓝色 luma=29)→ imgcodecs `imencode/imdecode` PNG 内存往返,逐步 `return` 非零错误码。

### 5.1 ⛔ BLOCKER —— `mcpp test` sandbox 未向 install() 提供可运行的 build-dep 工具链

**现象**:`mcpp test` 触发 install() 的 CMake 构建时,cmake/make/gcc 均无法执行 → install() 失败 → mcpp 报
`fetch 'compat.opencv@4.13.0' failed`。这是调研报告 R1 风险的实测坐实,且是 **通用**(非 opencv 专属)。

**根因(install() 内 env/ELF 实证)**:mcpp 为 install() 导出了 `XLINGS_BUILDDEP_{CMAKE,MAKE,GCC}_PATH`(定位
build-dep 工具的 intended 机制),但 project-local `.mcpp/.xlings` sandbox 里这些工具 **未被完整物化**:

- `XLINGS_BUILDDEP_GCC_PATH`(`xpkgs/xim-x-gcc/16.1.0/`)、`XLINGS_BUILDDEP_MAKE_PATH`(`xim-x-make/4.3/`)
  目录下 **无 bin/**(gcc/make 二进制根本不存在于该路径)。
- `XLINGS_BUILDDEP_CMAKE_PATH/bin/cmake` 存在,但其 **ELF interpreter 悬空**:INTERP 指向
  `<sandbox>/xpkgs/xim-x-glibc/2.39/lib64/ld-linux-x86-64.so.2`,而该 loader 未被部署(`xim-x-glibc/2.39/` 下只有
  `.xpkg.lua`);真正的 loader 只在 `runtimedir/glibc-2.39-linux-x86_64/lib/` 里 → 直接执行报
  `cannot execute: required file not found`。
- install() subprocess PATH 上的 xlings shim(`make`/`gcc`)在此上下文失效(`executable 'make' not found`、
  `alias for 'gcc' references itself`)。
- 对照:**GLOBAL** 工具可运行(`$HOME/.xlings/.../cmake --version` = 4.0.2 OK;`$XLINGS_HOME=~/.mcpp/registry`
  下的 gcc 即消费侧链接所用、可运行)。即 build-dep 工具设计上经 xvm shim 环境运行,而该环境未注入 install() 的
  bash 子进程。

**为何 openblas 没暴露**:openblas 的 install() 只需 `make`(musl-static,免 loader)+ 裸 `gcc`,且其
workspace 测试是 **windows-gated** → 在新的 `mcpp test --workspace` linux 流程里 openblas 的 install() **根本不被触发**。
opencv 是首个在该流程里真正跑 install()-CMake 的包,故首次撞上此 gap。

**影响**:任何"install() 里跑 glibc-dynamic build-dep 工具(cmake/autotools/…)"的 compat 包,在当前
`mcpp test`(及同流程的 CI)下都无法闭环。这是 mcpp/xim 侧问题,**不在本仓(index)可修复范围**,已列为 §6 头号通用缺口。

**已证明未受此影响的部分**:descriptor 语法/解析、构建 recipe 本身(§5 前三行:离线隔离构建 + 手工链接运行全绿,
用的正是同一套 ecosystem cmake/gcc,只是在 sandbox 之外调用)。此外,手工把 sandbox cmake 用 `xim:patchelf`
`--set-interpreter` 指向 `runtimedir/glibc-*/lib/ld-linux-x86-64.so.2` + registry 的可运行 gcc/make,一个最小
CMake 工程 configure+build 全绿(证明"只要 cmake 可执行,整条工具链子进程链即通")。即 **一旦 mcpp 向 install()
提供可运行的 build-dep 工具链,本 descriptor 不改即可闭环**。

**机制细节(供 mcpp 侧定位,均实证)**:
- `descriptor` 用的是 **openblas 同款** `pkginfo.build_dep("xim:cmake").bin`(0.0.85 存在)解析工具 —— 无任何
  loader/patchelf 兼容代码(遵循"deps 由 xlings 自动处理"的约定)。但 `build_dep` 返回的正是那个 **INTERP 悬空、
  不可执行** 的 sandbox cmake。
- `pkginfo.with_build_deps_on_path`(把 build-dep bin/ 前置进 PATH 的便捷 API)**只在独立 libxpkg 0.41/0.42 有,
  mcpp 0.0.85 内置 runtime 无此函数**(调用即 nil→install() 早抛)。
- mcpp 0.0.85 内置 libxpkg **有 `xim.libxpkg.elfpatch`**(auto 模式)——但它 patch 的是 **本包自身产物**
  (依据 deps 里的 loader provider),**不 patch build-dep 工具**(如 cmake)。故 build-dep cmake 的 INTERP 无人修。
- openblas 之所以没撞上:其 install() 只用 **make(musl 静态,无 INTERP 依赖)** + 裸 gcc,且 linux 测试
  windows-gated → 从不触发。opencv 是首个真正在 `mcpp test` 里跑 install()-CMake 的包。

→ **修复方向(mcpp 侧,三选一或组合)**:(a) 部署 build-dep 时把其 xim:glibc loader 落到二进制 INTERP 指向的
路径(或对 build-dep 工具跑一次 elfpatch);(b) 把 `with_build_deps_on_path` 纳入 0.0.85 runtime 并让其前置的是
**可执行** 的工具;(c) 让 `build_dep().bin` 返回已 elfpatch 的可执行副本。任一落地后,本 descriptor 与测试工程
**零改动** 即闭环。

## 6. 适配中暴露的 mcpp 通用能力缺口(非 opencv 专属,构建工具/模块化视角)

判据:每条都是"任何走外部构建系统 / 多产物 / 重源码构建的库"共有的架构问题。

0. **【实测 BLOCKER】install() 需要一个可运行的 build-dep 工具链(最高优先级)**。见 §5.1。现状
   `mcpp test` sandbox 只导出 `XLINGS_BUILDDEP_*_PATH` 但不物化可运行二进制:gcc/make bin 目录为空,cmake 的 ELF
   interpreter 悬空(xim:glibc loader 未部署到 patch 进二进制的路径),PATH shim 在 install() 子进程失效。→ 任何
   在 install() 里跑 glibc-dynamic 工具(cmake/autotools)的包都无法闭环。诉求:mcpp 让 install() 的执行环境拿到
   **可直接执行** 的 build-dep 工具(要么把 loader/依赖完整部署进 sandbox 并修正 INTERP,要么在 install() 子进程
   注入 xvm 的 PATH+LD 环境,要么提供一个"运行 build-dep 工具"的封装 API)。这是 opencv 之所以卡住的直接原因,也是
   所有 CMake/autotools compat 包的共同前置。

1. **install() ↔ 消费侧工具链握手**。现状 install()(xim 侧)不知道 mcpp 会用哪个编译器/ABI 链接消费者;
   openblas 靠"纯 C、ABI 稳定"绕过。任何 **C++** 源码构建型包都踩:install() 的 g++ 必须与消费者一致,否则
   libstdc++/libc++ 冲突(正是本包 linux-gated 的原因)。诉求:mcpp 把已选 toolchain(CC/CXX/AR/ABI 三元组)以稳定
   契约(env 或 pkginfo API)暴露给 install()。
2. **feature/capability 传参到 install()**。现状 feature 仅被 mcpp 静态读取,传不进 install();外部构建系统型包的
   模块/开关(CMake `-D…`)只能 recipe 内写死,无法 per-consumer 选择。诉求:把 consumer 请求的 features/绑定作为
   参数传入 install(),让"外部构建系统的开关"成为真正的 mcpp feature。
3. **一个包产出多库目标(per-target sources/include_dirs)**。现状 `sources`/`include_dirs` 包级全局、`Target` 仅
   链接单元;多模块库无法在单描述符按 target 分派各自源码集。诉求:target 携带自己的源码/头子集,或等价的
   sub-package 机制(直接决定"OpenCV 拆多库"能否原生表达)。
4. **feature 可携带 `defines` 之外的构建片段(include_dirs / cflags)**。现状刻意排除。对"开关即改配置头/加 -I/-l"的
   通用场景(几乎所有 autotools/CMake 库的 WITH_*)表达力不足。诉求:受控地允许 feature 贡献 include_dirs/cflags。
5. **重型 from-source 构建的产物二进制缓存**。现状每次干净构建都重跑 install()(opencv 分钟级)。诉求:对 install()
   产物做可复现的二进制缓存/artifact 复用(与 mcpp-index artifact publish 模型对齐),避免 CI/首次 add 反复重编。

## 7. 后续项(P2+)

- macOS:让其用 gcc,或用消费者编译器构建(依赖 §6-1);Windows:MSVC 预编译 或 clang-MSVC CMake(调研报告 R3)。
- 更大模块集(calib3d/features2d/flann/photo/video/objdetect → dnn → highgui)与 `compat.opencv-contrib`(非自由 opt-in)。
- codec 由内置 3rdparty 改绑本仓 provider(compat.zlib 等,依赖 §6-1/§6-2 的能力)。
- CN 镜像 `mcpp-res/opencv@4.13.0`(维护者)。
- CI:install() 的 CMake 构建分钟级,`smoke-examples (opencv)` 可能需放宽 timeout,或 mac/win 进 nightly。
