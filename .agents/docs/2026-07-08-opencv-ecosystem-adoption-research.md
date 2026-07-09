# OpenCV 加入 mcpp 生态 —— 深度调研报告(单库 vs 拆多库 / feature 开关 / 构建形态)

**日期**: 2026-07-08
**本仓**: `mcpp-community/mcpp-index`(github 别名 `mcpplibs/mcpp-index`)
**mcpp 源码**: `/home/speak/workspace/github/mcpp-community/mcpp`(只读参考,mcpp 0.0.85)
**参考先例**: `compat.openblas`(install() 跑外部构建系统)、`compat.libarchive`(手列源码 + 合成 config 头 + 多依赖)、`compat.eigen`(feature/capability 门控)、`compat.gtest`(source-gated feature)
**目标**: 判定 OpenCV 进入 mcpp 生态应 **单库还是拆多库**、可行的 **构建形态**、以及 **feature/开关** 如何映射;给出推荐方案与分期落地路径。

---

## 0. 摘要与结论(TL;DR)

| 决策点 | 结论 |
|---|---|
| **收录版本** | 首收 **4.13.0**(最新稳定 4.x,Apache-2.0);5.0.0 作为后续;`opencv_contrib` 单独收录,非自由算法(SIFT/SURF 等)opt-in。 |
| **单库 vs 多库** | **单包 `compat.opencv`**。mcpp 描述符 **无法** 在一个文件里给多个 lib 目标分派各自的源码集(`sources` 是包级全局,`Target` 无 `sources`/`include_dirs` 字段);而"每模块一个包"会让每个包各自解包并重复构建同一棵源码树,得不偿失。模块粒度通过 install() 里 CMake 的 `-DBUILD_opencv_*` 一次性产出多个 `.a`、经单包多 target 暴露。 |
| **构建形态** | **install()-hook 驱动上游 CMake 构建**(`compat.openblas` 模式的放大版)。这是唯一能免维护地处理 OpenCV 海量 **CMake 生成物**(SIMD dispatch 头 + 各 ISA `.cpp`、`opencl_kernels_*`、config 头)的路径;vcpkg/conan/发行版无一例外都是驱动 OpenCV 自带 CMake。 |
| **feature 开关** | OpenCV 的 `WITH_*` / `BUILD_opencv_*` **不能** 逐一映射成 mcpp feature —— feature 只能携带 `implies/sources/defines/requires/provides/deps`,**不能** 带 `cflags`/`include_dirs`/`generated_files`,也 **无法参数化 install()**。故模块/第三方选择在 recipe 内 **固定为一条策展 profile**;粗粒度变体(minimal / full)用 **独立包** 或 **版本档** 表达,而非 per-consumer feature。 |
| **第三方依赖** | MVP 全部走 OpenCV `3rdparty/` **内置源码**(zlib/libpng/libjpeg-turbo/… CMake `BUILD_*=ON`),**零外部依赖**,自洽可复现。后续可把 BLAS/LAPACK 加速经 capability 绑到本仓已有的 `compat.openblas`(`provides=["blas"]`)。 |
| **落地分期** | P1: `core+imgproc+imgcodecs`(内置 zlib/png/jpeg)最小可用包 → P2: 加 `calib3d/features2d/flann/photo/video/objdetect` → P3: `dnn`(内置 protobuf)、`highgui`(系统 GTK/Qt 可选后端)、`opencv_contrib`。 |

> **一句话**:OpenCV 不是"再大一号的 libarchive",而是"再大一号的 openblas"。它 **必须** 借 install() 跑自己的 CMake;纯"手列 `.cpp` + 一个 config 头"的原生形态在 SIMD dispatch / OpenCL kernel 两处会崩。

---

## 1. 背景:两个已知构建形态,OpenCV 落在哪一档

本仓现有 compat 包呈现两条构建路线:

- **原生源码路线(A/B/C 形态)**:mcpp 直接 `sources={...}` 列上游 `.c/.cpp`,用自己的 ninja 编译;需要的 config 头用 `generated_files` 合成。代表:`compat.zlib`(15 个 `.c` + 一个 `mcpp_zlib_config.h`)、`compat.libarchive`(130+ 个 `.c` + 一个模拟 CMake `config.h` 的大 `generated_files`)。**前提**:上游全部可编译源码都在 tarball 里、且没有构建期代码生成。
- **外部构建系统路线(install() 逃生舱)**:上游用自己的 Make/CMake 生成库,mcpp 的源码模型套不上。代表:`compat.openblas` —— install() 跑 GNU Make(`TARGET=GENERIC NO_LAPACK=1 …`)产出 `libopenblas.a` + 头,再写出 anchor TU 触发 mcpp 编译并 `-Llib -lopenblas` 链接。

判定 OpenCV 属于哪一档,取决于一个问题:**OpenCV 的可编译源码是否全在 tarball 里、有无构建期代码生成?** —— 见 §2.3,答案是"有大量生成物",故落在 **install() 路线**。

---

## 2. 上游事实(OpenCV 4.x/5.x)

### 2.1 版本与许可

- **4.13.0** —— 最新稳定 4.x(4.12.0 之上的 X-server 依赖修订);**5.0.0** 于 2026-06 发布(大版本,含 4→5 迁移指南)。
- Tag 为裸 `X.Y.Z`(**无 `v` 前缀**);GitHub 源码归档:
  - 主库:`https://github.com/opencv/opencv/archive/refs/tags/4.13.0.tar.gz`
  - contrib:`https://github.com/opencv/opencv_contrib/archive/refs/tags/4.13.0.tar.gz`
- **许可**:主库自 4.5.0 起 **Apache-2.0**(此前 BSD-3-Clause);`opencv_contrib` 整体 Apache-2.0,但含专利/第三方约束模块(`xfeatures2d` 的 SIFT/SURF 等),由 `OPENCV_ENABLE_NONFREE` 门控。→ **主库与 contrib 分开收录;非自由算法 opt-in。**
- **建议首收 4.13.0**(4.x 成熟线,Apache-2.0),5.0.0 作为后续档。

### 2.2 模块与依赖图(单库/多库决策的直接输入)

主库 `modules/`:`core, imgproc, imgcodecs, videoio, highgui, calib3d, features2d, objdetect, dnn, ml, photo, video, stitching, flann, gapi, ts, world`(contrib 另有 ~50)。

各模块 `CMakeLists.txt` 的 `ocv_define_module(...)` 声明的 **直接模块间依赖**:

| 模块 | 直接依赖 | 备注 |
|---|---|---|
| **core** | 无(cudev 可选) | 生态基座 |
| **imgproc** | core | |
| **imgcodecs** | imgproc(→core) | 内置 BMP/PNM/HDR/PFM/GIF 解码器,JPEG/PNG/… 需 lib(可取内置 3rdparty) |
| **highgui** | imgproc;imgcodecs+videoio 可选 | 后端 GTK/Qt/Wayland/Win32/Cocoa,可 NONE |
| **calib3d** | imgproc, features2d, flann | |
| **dnn** | core, imgproc(+内置 protobuf) | |
| **features2d** | imgproc(+flann) | |
| **flann** | core | |

基链:`core ← imgproc ← {imgcodecs, highgui, calib3d, dnn, features2d, …}`。**core+imgproc 零第三方即可编。**

### 2.3 构建期生成物 —— 决定形态的关键

OpenCV 的 CMake 在 configure/build 期 **生成若干被模块 `.cpp` `#include`、但不在 tarball 里** 的头/源。实测(本机安装的 OpenCV 4.6 生成头 + 上游 `cmake/templates` 模板)分两类:

**(a) 平凡 config 头 —— `generated_files` 可轻松合成(zlib/libarchive 先例):**

| 文件 | 生成方式 | 静态 stub 可行? |
|---|---|---|
| `cvconfig.h` | `configure_file(cvconfig.h.in)` | ✅ 平凡。~70 个 `HAVE_*/WITH_*` 的 `#define/#undef`;最小构建近乎全 `#undef`。 |
| `opencv_modules.hpp` | `configure_file(opencv_modules.hpp.in)` | ✅ 平凡。每个已构建模块一行 `#define HAVE_OPENCV_<M>`。 |
| `custom_hal.hpp` | `configure_file(custom_hal.hpp.in)` | ✅ 平凡。空 HAL 体即合法。 |
| `opencv_data_config.hpp` | core/CMakeLists `file(WRITE)` | ✅ 平凡。安装路径串,可空。 |

**(b) 硬骨头 —— 纯手列会崩的两处:**

- **SIMD dispatch**(`cmake/OpenCVCompilerOptimizations.cmake` 的 `ocv_add_dispatched_file`):每个被 dispatch 的 TU 生成一个 `<name>.simd_declarations.hpp`(被 `#include`)+ 每个 ISA 一个 `<name>.<opt>.cpp`(如 `mathfuncs_core.avx2.cpp`)。**core 有 16 处、imgproc 更多**(`arithm/convert/matmul/resize/color_*/filter/…`)。这些头 **不在 tarball**,且 **逐模块、逐版本**。
- **OpenCL kernels**(`OpenCVModule.cmake` → `cmake -P cl2cpp.cmake`):把 `src/opencl/*.cl` 嵌成 `opencl_kernels_<module>.cpp/.hpp`(C 字符串),被模块 `.cpp` `#include`。core/imgproc/dnn 均有。

**结论**:平凡 config 头(a)套 `generated_files` 没问题;但 (b) 的 `*.simd_declarations.hpp` + 各 ISA `.cpp` + `opencl_kernels_*` 数量多、逐版本变、且是"跑一遍 CMake 才知道的产物"。**纯"列 `.cpp` + 一个 config 头"的模型在此崩溃** —— 除非(i) baseline-only 手写每个 dispatch 单元的 stub 头并只编 scalar/基线(牺牲 SIMD 且仍是逐单元手工),或(ii) 每版用 `cmake -P` 独立脚本预生成 dispatch/kernel 再 vendor(逐版本重活)。业界佐证:**无人从裸源码手工编 OpenCV core**;所谓 Bazel 移植也是 `new_local_repository` 链 **预装** OpenCV 并指向 **CMake 生成的** `cvconfig.h`。

### 2.4 第三方依赖

`3rdparty/` **内置可源码构建**:`zlib, zlib-ng, libjpeg-turbo, libpng, libspng, libtiff, libwebp, openexr, openjpeg, jasper, quirc, protobuf(dnn), flatbuffers, ippicv(x86 二进制,可选), tbb, carotene(ARM HAL), …`。

| 依赖 | 模块 | 内置? | 可选? |
|---|---|---|---|
| zlib / libpng / libjpeg-turbo / libtiff / libwebp / openexr / openjpeg | imgcodecs | ✅ `BUILD_*=ON` | 全可选(缺则少若干编码器) |
| ffmpeg / gstreamer / v4l | videoio | 否(Linux/mac 外部) | 可选(videoio 可 0 后端) |
| protobuf | dnn | ✅ `BUILD_PROTOBUF` 默认 on | dnn 必需但自洽 |
| eigen / lapack / openblas / IPP / TBB | core 加速 | eigen/lapack 外部;IPP/TBB 内置 | **全可选**(有 fallback) |
| GTK/Qt/Wayland/Cocoa/Win32 | highgui | 否(系统) | 可选(后端 NONE) |
| OpenCL / CUDA | core/dnn/… | OpenCL 头内置;CUDA 外部 | 可选 |

**`core→imgproc→imgcodecs` 全链无硬外部依赖**:imgcodecs 内置 BMP/PNM/HDR/PFM/GIF 解码器;JPEG/PNG/… 取 **内置 3rdparty** 即可,故一个 `core+imgproc+imgcodecs+(内置)zlib/png/jpeg` 包可 **完全自洽于 tarball**。

### 2.5 最小可用子集

- **`core + imgproc`**:零第三方可编;SIMD 退基线,线程用内置 pthreads/no-op。
- **`imgcodecs`**:零外部编码器也可编(内置若干解码器);要 JPEG/PNG 取内置 3rdparty。
- → 自洽 MVP = `core+imgproc+imgcodecs`(内置 zlib/libpng/libjpeg-turbo)。

---

## 3. mcpp 表达力约束(0.0.85,来自 mcpp 源码核对)

descriptor 的 `mcpp={}` 段由 **手写数据字面量解析器**(`src/manifest/xpkg.cppm` 的 `LuaCursor`)读取,**mcpp 从不执行 descriptor**。对 OpenCV 这种"20+ 模块 + ~15 个 WITH_* 开关 + 依赖图"的库,关键约束:

1. **无 per-target `sources`/`include_dirs`**(致命于"一文件多模块库"):`sources`/`include_dirs` 是 **包级全局**;`Target` 只是共享编译池上的 **链接单元**(仅可带 entry-exclusive 的 `defines/cxxflags`,0.0.55),无自己的源码集。→ **一个描述符无法产出 20 个各自源码集不同的 lib。**
2. **feature 只能携带 `implies/sources/defines/requires/provides/deps`**(0.0.65–0.0.71 分阶段落地),**不能** 带 `cflags/cxxflags/ldflags/include_dirs/generated_files`(设计上刻意排除,见 mcpp `2026-06-29-feature-capability-model-design.md §7)。→ OpenCV `WITH_*` 里但凡需要"改 config 头内容 / 加 `-I` / 加 `-l`"的,**都不能** 做成 feature。
3. **feature 无法参数化 install()**:install() 是 **xim/xlings 安装器** 侧的 Lua hook(`os.exec/os.cd/os.cp/path.*/log.*`),**mcpp 只读静态段**;openblas 的 install() 用的是 **固定** flags。→ 保守认定:**consumer 请求的 feature 传不进 install()**,故模块/依赖选择须在 recipe 内固定(见 §6 变体策略)。
4. **capability 绑定干净**:`provides=["blas"]` ↔ `requires=["blas"]`,`≥2` provider 需 `[capabilities]`/`--cap` 指定(0.0.69)。→ 加速后端(OpenBLAS/LAPACK)可经此绑到本仓 `compat.openblas`。
5. **`generated_files` 支持长括号 `[==[…]==]` 需 mcpp ≥ 0.0.85**(本仓 `index.toml min_mcpp=0.0.85` 已保证)→ OpenCV 的大 config 头可用长括号内联,不必逐字转义。
6. **install() 可跑 CMake/Make/`cmake -P`**、落 lib+头+生成头,再声明 `include_dirs`/`[runtime].library_dirs`(openblas + xcb `c_client.py` 先例)。

---

## 4. 决策一:单库 vs 拆多库

### 4.1 选项

- **(M) 单包 `compat.opencv`**:一个描述符 + 一个 install() CMake 构建,一次产出所选模块的多个 `.a`,经单包多 target 暴露。
- **(S) 每模块一包**(`compat.opencv-core` / `compat.opencv-imgproc` / …):照搬 OpenCV 模块性,模块间用包依赖表达。

### 4.2 分析

拆多库(S)在 mcpp 下 **代价极高且不自然**:

1. **无共享构建**:mcpp 一个包 = 一个独立构建单元。N 个 opencv 子包各自解包 **同一棵源码树**、各自跑一遍(或各自 CMake 子构建),要么重复 N 次全树构建,要么需要跨包共享 build 目录 —— 包模型不提供。
2. **模块间链接错配**:OpenCV 模块间是 **同一次 CMake 构建内** 的目标依赖;切成 N 个独立 mcpp 包后,`compat.opencv-calib3d` 要链 `compat.opencv-imgproc/features2d/flann` 的产物,而这些产物在 **各自的 verdir**,ABI/头版本一致性要靠版本 pin 人工保证,脆弱。
3. **收益有限**:用户要的"只装 core+imgproc"用 **单包的策展 profile / 变体包**(§6)即可满足,不必付 N 包的解包与依赖图代价。

单包(M)则与 openblas 先例同构:**一次 CMake 构建产出多库,mcpp 侧一个 anchor + `-Llib -lopencv_core -lopencv_imgproc …` 链接**。§3.1 的"无 per-target sources"约束对 M **不构成问题** —— 因为多库不是由 mcpp 的多 target 从不同源码集编出来的,而是 **install() 里 CMake 编好、mcpp 只负责链接**。

### 4.3 结论

**单包 `compat.opencv`**(contrib 另一个单包 `compat.opencv-contrib`)。模块粒度由 install() 的 `-DBUILD_opencv_*` 固定策展 + 粗粒度变体表达,而非拆成 per-module 包。

---

## 5. 决策二:构建形态(三方案对比)

| | **A. install()-hook CMake**(推荐) | **B. 手列源码 + 预生成 dispatch/kernel vendored** | **C. baseline-only stub 原生编译(最小裁剪)** |
|---|---|---|---|
| 生成物(SIMD/OpenCL) | CMake 原生处理,**零手维护** | 每版 `cmake -P` 预生成再 vendor,**逐版本重活** | 手写每个 dispatch 单元 baseline stub 头 + 只编基线,**逐单元手工** |
| config 头 | CMake 生成 | `generated_files` 合成 | `generated_files` 合成 |
| 构建速度 | 慢(整棵 CMake,分钟级) | 快(mcpp 原生 ninja) | 快 |
| 构建依赖 | `xim:cmake` + `xim:make/ninja` | 无(纯 mcpp) | 无 |
| 覆盖范围 | **全模块可行** | 现实只到 core+imgproc(+imgcodecs) | 仅 core+imgproc 基线 |
| 逐版本维护 | 低(改 tag + `-D` profile) | **极高** | 高 |
| SIMD 性能 | 完整 dispatch | 取决于预生成 | **仅基线,慢** |
| 与 mcpp 源码模型契合 | 低(逃生舱) | 高 | 高 |
| Windows | 同 openblas:MSVC-ABI clang vs CMake,或走预编译 | 同左 + 手工重活翻倍 | 同左 |
| 业界佐证 | vcpkg/conan/发行版全走此路 | 无人如此 | 无人如此 |

**取舍**:B/C 契合 mcpp"列源码"哲学、构建快、无 CMake 依赖,但 **逐版本维护 SIMD dispatch + OpenCL kernel 的成本压倒性地高**,且现实只能覆盖极小子集 —— 与"把 OpenCV 收进生态"的目标不匹配。A 是 openblas 先例的直接放大:**用 install() 让 CMake 干它最擅长的活(含全部生成物),mcpp 只做链接与暴露**。这也是 **唯一** 能可持续跟上 OpenCV 每季度发版的路径。

**结论:采用 A(install()-hook CMake 构建)。** 把 B/C 作为"若要一个零-CMake、纯基线的 `compat.opencv-mini` 教学包"的备选,不作主线。

---

## 6. feature / 开关设计

### 6.1 为什么 `WITH_*` / `BUILD_opencv_*` 不能做成 mcpp feature

由 §3.2–3.3:feature 不能带 `cflags/include_dirs/generated_files`,也传不进 install()。而 OpenCV 的开关几乎都要"改 CMake `-D` → 改 config 头内容 + 改链接" —— 这三件事 feature 一件都表达不了。**强行做成 feature 会得到"声明了但不起作用"的假开关**(正是 eigen 文档里警惕的坑)。

### 6.2 替代:三层表达

1. **策展 profile(recipe 内固定,主力手段)**:install() 里写死一组 `-DBUILD_opencv_<M>=ON/OFF -DWITH_<X>=ON/OFF`。一个包 = 一条确定的模块+第三方组合,可复现、可缓存。
2. **粗粒度变体 = 独立包 / 版本档**:
   - `compat.opencv`(标准:core+imgproc+imgcodecs+calib3d+features2d+flann+photo+video+objdetect,内置 codec,无 GUI/dnn);
   - `compat.opencv-dnn`(额外 dnn+内置 protobuf)或直接并入标准;
   - `compat.opencv-contrib`(contrib,非自由 opt-in);
   - 若需极简:`compat.opencv-mini`(core+imgproc)。
   变体用 **独立描述符**(各自 install() profile)表达,而非 per-consumer feature —— 与 mcpp"包即构建单元"一致。
3. **capability(唯一适合 feature 的窄子集)**:纯粹"加包级 define + 可选 dep + 绑定 provider"的开关 **可以** 做成 feature。典型:BLAS/LAPACK 加速 —— 一个 `use-openblas` feature 走 `requires=["blas"]` + `deps={["compat.openblas"]="0.3.33"}`,绑本仓已有的 `compat.openblas`(`provides=["blas"]`),install() 侧据此加 `-DWITH_LAPACK=ON` 指向该 provider。但这属"锦上添花"的少数派,不是模块/codec 选择的通道。

### 6.3 第三方 codec 的两条路

- **(推荐,MVP)内置 3rdparty**:install() 用 `-DBUILD_ZLIB=ON -DBUILD_PNG=ON -DBUILD_JPEG=ON …`,全部从 tarball 内 `3rdparty/` 编,**零外部依赖、GLOBAL/CN 字节一致最省心**。
- **(后续,更"生态化")绑本仓 provider**:本仓已有 `compat.zlib`;若再收 `compat.libpng`/`compat.libjpeg-turbo`,可让 opencv 经 capability 复用,避免重复内置。但需 install() 消费外部 provider 的头/库路径,复杂度显著上升 → 放 P2+ 评估,MVP 不做。

---

## 7. 推荐方案落地

### 7.1 描述符骨架(A 方案,openblas 模式)

```lua
-- compat.opencv — OpenCV 经 install() 驱动上游 CMake 构建,产出策展模块集的
-- 静态库 + 头,mcpp 侧 anchor + -l 链接。CMake 原生处理全部生成物
-- (cvconfig.h / opencv_modules.hpp / *.simd_declarations.hpp / opencl_kernels_*),
-- 故不走"手列 .cpp"模型(见 .agents/docs/2026-07-08-opencv-ecosystem-adoption-research.md)。
package = {
    spec = "1", namespace = "compat", name = "compat.opencv",
    description = "OpenCV — computer vision library (curated core build via CMake)",
    licenses = {"Apache-2.0"},
    repo = "https://github.com/opencv/opencv",
    type = "package",
    xpm = {
        linux  = { deps = { "xim:cmake@latest", "xim:make@latest" },
                   ["4.13.0"] = { url = { GLOBAL = "https://github.com/opencv/opencv/archive/refs/tags/4.13.0.tar.gz",
                                          CN     = "https://gitcode.com/mcpp-res/opencv/releases/download/4.13.0/opencv-4.13.0.tar.gz" },
                                  sha256 = "<实现期算>" } },
        macosx = { deps = { "xim:cmake@latest", "xim:make@latest" }, ["4.13.0"] = { --[[ 同 linux ]] } },
        windows = { --[[ 评估:MSVC-ABI clang vs CMake;或走官方预编译 opencv-4.13.0-vc16.exe 解包链 import lib + 部署 DLL(同 openblas Windows)]] },
    },
    mcpp = {
        language = "c++23", import_std = false, c_standard = "c11",
        -- anchor 由 install() 写出(缺失即触发 install() → CMake 构建),同 openblas。
        sources      = { "mcpp_opencv_anchor.c" },
        targets      = { ["opencv"] = { kind = "lib" } },
        include_dirs = { "include", "include/opencv4" },   -- install 后的头前缀
        deps = { },
        -- 静态链接策展模块集(顺序:被依赖者在后)。-Llib 由 mcpp 重写到 verdir/lib。
        linux  = { ldflags = { "-Llib", "-lopencv_objdetect", "-lopencv_calib3d", "-lopencv_features2d",
                               "-lopencv_flann", "-lopencv_video", "-lopencv_photo",
                               "-lopencv_imgcodecs", "-lopencv_imgproc", "-lopencv_core",
                               "-llibpng", "-llibjpeg-turbo", "-lzlib", "-ldl", "-lpthread" } },
        macosx = { ldflags = { --[[ 同上,末尾换 -framework 若需 ]] } },
        -- use-openblas:纯 capability 型 feature(唯一适合 feature 的窄子集,见 §6.2)。
        features = {
            ["use_openblas"] = { requires = { "blas" }, deps = { ["compat.openblas"] = "0.3.33" } },
        },
    },
}

-- install():解包后跑 CMake 策展构建 → make install 落 lib/ + include/ → 写 anchor。
-- 关键 -D(固定 profile):
--   -DBUILD_LIST=core,imgproc,imgcodecs,calib3d,features2d,flann,video,photo,objdetect
--   -DBUILD_SHARED_LIBS=OFF -DBUILD_ZLIB=ON -DBUILD_PNG=ON -DBUILD_JPEG=ON
--   -DWITH_FFMPEG=OFF -DWITH_GTK=OFF -DWITH_QT=OFF -DWITH_OPENCL=OFF -DWITH_IPP=OFF
--   -DWITH_TBB=OFF -DBUILD_TESTS=OFF -DBUILD_PERF_TESTS=OFF -DBUILD_EXAMPLES=OFF
--   -DBUILD_opencv_apps=OFF -DBUILD_opencv_python3=OFF -DOPENCV_GENERATE_PKGCONFIG=OFF
--   -DCMAKE_INSTALL_PREFIX=<install_dir>
-- 结构同 compat.openblas 的 _install_impl():os.mv 源树入 install_dir、os.cd、
-- os.exec("cmake -S . -B build <-D...> && cmake --build build -j && cmake --install build")、
-- 校验 lib/libopencv_core.a 存在(否则 log.error + return false)、io.writefile 写 anchor。
```

> 与 openblas 的差别:openblas 用 Make,opencv 用 CMake(build-dep 增 `xim:cmake`);openblas 单库单 `-l`,opencv 多 `-l`(顺序敏感,被依赖者在后)。两者共享"install() 产出 anchor 触发构建 + `-Llib` 重写 + 校验产物"骨架。

### 7.2 分期

- **P1(MVP,证明形态)**:`compat.opencv` = `core+imgproc+imgcodecs`(内置 zlib/png/jpeg),Linux/macOS install() CMake 构建。tests/examples 跑通 `Mat + cvtColor + imencode/imdecode PNG 往返断言`。—— **先在 Linux/macOS 打通 install()-CMake 闭环。**
- **P2**:补 `calib3d/features2d/flann/video/photo/objdetect`;评估 Windows(预编译 vs CMake);评估 codec 改绑本仓 provider。
- **P3**:`compat.opencv`(或 `-dnn` 变体)加 dnn(内置 protobuf);`highgui`(系统 GTK/Qt 可选后端);`compat.opencv-contrib`(非自由 opt-in);`use_openblas` capability 加速。

---

## 8. CN 镜像(gtc)

repo 名 = 包名去 `compat.` = `opencv`(contrib 用 `opencv-contrib`):

```bash
curl -L -o opencv-4.13.0.tar.gz https://github.com/opencv/opencv/archive/refs/tags/4.13.0.tar.gz
sha256sum opencv-4.13.0.tar.gz                       # 填入三平台 sha256
tools/gtc repo create   mcpp-res/opencv --public
tools/gtc release create mcpp-res/opencv 4.13.0 --asset opencv-4.13.0.tar.gz
curl -fsSL -o /dev/null -w '%{http_code}\n' \
  https://gitcode.com/mcpp-res/opencv/releases/download/4.13.0/opencv-4.13.0.tar.gz
```

上传的即 GLOBAL 同一 tarball → CN/GLOBAL 字节一致(gitcode 同名资产不可覆盖,命名一次定死)。

## 9. 测试工程 + CI

- `tests/examples/opencv/{mcpp.toml, tests/roundtrip.cpp}`:依赖 `compat.opencv=4.13.0`(`[indices].compat = {path="../../.."}`);断言 `cv::Mat` 构造 + `cv::cvtColor` + `cv::imencode/imdecode`(内存 PNG 往返)返回 `ok?0:1`。加入根 `mcpp.toml` 的 `[workspace].members`。
- CI:`validate.yml` 的 detect 把 `compat.opencv.lua` → `opencv` → 命中 `tests/examples/opencv` 单跑;`mirror-cn-reachable` 覆盖新 CN url。**注意 install() 的 CMake 构建耗时**(分钟级)可能需要放宽该 job 的 timeout,或先只在 Linux 跑、mac/win 进 nightly。

## 10. 风险与开放问题

- **R1(最高)install()-CMake 闭环**:openblas 证明了 install() 跑 Make;OpenCV 是 **首个 install() 跑 CMake** 的包。落地期必测:`xim:cmake` build-dep 可用性、CMake 能否在 xim Lua 沙箱的 `os.exec` 下完整 configure+build+install、产物路径(`lib/libopencv_*.a`、`include/opencv4/`)是否稳定。**不成立则回退 B/C 的最小基线包。**
- **R2 构建时长**:整棵 core+imgproc CMake 构建分钟级,CI/首次 `mcpp add` 体验偏重 → 考虑 mac/win 进 nightly、Linux 保留;长期看是否值得提供 **预编译 artifact**(但破坏 GLOBAL/CN 字节一致模型,需另设机制)。
- **R3 Windows ABI**:mcpp 链的是 MSVC-ABI clang,与 OpenCV 官方 CMake(MSVC)一致性存疑 —— 大概率同 openblas 走 **官方预编译 world DLL + import lib + 部署 DLL**;P2 再定。
- **R4 feature 传参 install()**:本报告保守认定 feature 传不进 install()。若 mcpp 后续提供"feature → install() 参数"通道,则模块/codec 选择可从"变体包"升级为"单包 per-consumer feature",大幅简化。**建议向 mcpp 维护者提此需求**(见 mcpp `feature-capability-model` 演进)。
- **R5 许可**:主库 Apache-2.0 干净;contrib 的非自由算法必须 `OPENCV_ENABLE_NONFREE` 显式 opt-in 且独立包,避免默认拉入专利算法。
- **Q1(待定默认)**:首收 4.13.0(推荐)还是直接 5.0.0?建议 4.13.0 先行、5.0.0 P3 并行。
- **Q2(待定默认)**:MVP 模块集 = `core+imgproc+imgcodecs`(推荐)还是直接标准集(+calib3d/features2d/…)?建议先三模块打通闭环再扩。
- **Q3(待定默认)**:codec 走内置 3rdparty(推荐 MVP)还是绑本仓 provider?建议 MVP 内置,P2 评估外绑。

## 11. 参考

- 本仓先例:`pkgs/c/compat.openblas.lua`(install() 外部构建)、`compat.libarchive.lua`(手列源码 + config 头 + 多依赖)、`compat.eigen.lua`(feature/capability)、`compat.gtest.lua`(source-gated feature);`docs/package-types.md`。
- mcpp 源码/设计:`src/manifest/xpkg.cppm`(descriptor 解析,0.0.85)、`.agents/docs/2026-06-29-feature-capability-model-design.md`、`2026-06-29-feature-optional-dependencies-s2-design.md`、`2026-06-18-per-target-build-config-design.md`、`2026-06-29-windows-runtime-dll-deployment-and-openblas.md`、`2026-07-08-index-version-semantics-and-descriptor-grammar-design.md`。
- OpenCV 上游:[releases](https://github.com/opencv/opencv/releases) · [modules CMakeLists](https://github.com/opencv/opencv/tree/4.x/modules) · [cvconfig.h.in](https://raw.githubusercontent.com/opencv/opencv/4.x/cmake/templates/cvconfig.h.in) · [OpenCVCompilerOptimizations.cmake](https://raw.githubusercontent.com/opencv/opencv/4.x/cmake/OpenCVCompilerOptimizations.cmake)(SIMD dispatch)· [OpenCVModule.cmake](https://raw.githubusercontent.com/opencv/opencv/4.x/cmake/OpenCVModule.cmake)(OpenCL cl2cpp)· [3rdparty](https://github.com/opencv/opencv/tree/4.x/3rdparty) · [config 参考](https://docs.opencv.org/4.13.0/db/d05/tutorial_config_reference.html)。
</content>
</invoke>
