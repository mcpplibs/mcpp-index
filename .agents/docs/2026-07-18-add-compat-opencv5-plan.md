# add `compat.opencv5` 5.0.0 — 全源码直编 + build.mcpp 消费端合成(新形态)

日期:2026-07-18 · 关联:pkgs/c/compat.opencv5.lua、tools/compat-opencv5/、tests/examples/opencv5/
背景:opencv-m 项目(OpenCV 5 模块化封装)的 compat 底座;compat.ffmpeg(#74)形态的演进。

## 形态判定:为什么不是既有三形态

- 不是 install()/CMake 形态(compat.opencv 4.13 那种):项目目标是**构建期零 CMake**、
  mcpp 直编(用户硬约束)。
- 不是纯 config-快照形态(compat.ffmpeg 那种):OpenCV 构建期生成物达 17MB
  (字体 hex 头 13MB+1.7MB、OpenCL kernel 内嵌 0.6MB、逐 TU 转发 stub),无法内联。
- **新形态**:小体量 config 快照(59KB,171 文件)内联 + 包内嵌 `build.mcpp`
  在消费端合成大生成物(mcpp 0.0.95 依赖包 build.mcpp 执行 + `mcpp:generated=`
  + OUT_DIR 契约)。合成器为 CMake 逻辑的逐字节忠实移植
  (blob2hdr / cl2cpp+MD5,已 diff 参考构建产物 8/8 IDENTICAL)。

## 范围与 profile(v0.1,linux-x86_64)

`BUILD_LIST=core,imgproc,imgcodecs,highgui,videoio`(闭包拉入 flann、geometry);
hermetic:外部探测全 OFF,vendored zlib/libpng/libjpeg-turbo(含 27 NASM `.asm`);
headless highgui;V4L2 videoio;`WITH_UNIFONT=OFF`(13MB CJK 字体是 configure 期
**额外下载**,破坏单源 sha256 封闭;将来做 feature);**SIMD runtime dispatch 保留**
(per-ISA glob flags:`**/*.{sse4_1,sse4_2,avx,avx2,avx512_skx}.cpp`)。

## 转发 TU 层(gen/tu/)

每个 C/C++ TU 经唯一名 stub 进构建,一石三鸟:
1. mcpp#233(对象路径按「父目录名+文件名」折叠,`modules/*/src/` 同名源必撞);
2. libjpeg-turbo 同源三编(BITS_IN_JSAMPLE=8/12/16);
3. mcpp#234(含空格 define 命令行被拆散)→ 改注入 stub 顶部 `#define`。
`tu_manifest.txt`(内联 generated_files)驱动;#233/#234 修复后此层可退役。

## flag 面分解与校验

flags(TU) = 基础(-msse3) ∪ 目录组(9 组) ∪ ISA 后缀组 ∪ 逐文件特例(3 个);
gen_descriptor.py 对全部 457 条参考编译命令做**精确重构断言**,不闭合即失败。
语言标准:上游 c++17,index 楼层 c++23 —— 457 TU 已在 gcc16 `-std=c++23` 下
全绿验证(O0 spike),声明 `language = "c++23"`。

## CN 镜像

gitcode `mcpp-res/opencv` release `5.0.0`,资产 = GitHub tag tarball 逐字节
(sha256 `b0528f5a…3095` 双端核验)。

## 验证

- lint(语法/必填/无前导 v/镜像表)+ `mcpp xpkg parse`(0.0.95、0.0.96)✓
- 合成忠实性:blob2hdr×2 + cl2cpp×6 与 CMake 参考 **逐字节一致** ✓
- 端到端(mcpp 0.0.96):零 override 消费工程 → 官方 tarball 下载 →
  generated_files → dep build.mcpp 合成 → 457 TU 直编(冷 33s/32 核)→
  运行断言(版本/resize/cvtColor/PNG+JPEG roundtrip/videoio registry/AVX2)✓
- workspace 成员 tests/examples/opencv5(cfg(linux) 门控)`mcpp test` ✓

## 踩坑记录(过程中新发现并已提 issue)

- mcpp#233 对象路径折叠冲突(2 文件最小复现)。
- mcpp#234 defines 含空格未转义。
- build.mcpp 诊断输出**不要写 stderr**:会与缓冲中的 stdout 指令流交错,
  污染 `mcpp:generated=` 行(表现为"declared generated source ... does not
  exist",路径里混入诊断文本)。诊断走 stdout 非指令行 + 末尾 fflush。
- `ninja -n` 在已构建目录只列过期目标 → 源列表推导必须用 `ninja -t commands`。
- 参考构建需真跑一次 ninja(-k 容错宿主 gcc13 对 2 个 AVX2 bfloat TU 的 ICE),
  否则 cl2cpp/blob2hdr 产物不落盘、无从对照。

## 升级 SOP

改 `tools/compat-opencv5/fetch_upstream.sh` 版本/sha256 pin →
`sh tools/compat-opencv5/gen_config.sh` (需宿主 cmake+ninja+nasm;CC=/usr/bin/gcc
防 xlings subos 交叉 shim)→ 描述符重生成 + review diff → gtc 上传新 tarball 到
CN 镜像 → PR。

## 后续(opencv-m 侧)

O2:opencv-m 模块层仓库(`import opencv.cv;`,hdr_parser.py 驱动导出面)→
O3:发布 + `pkgs/o/opencv.lua` Form A 登记(imgui/ffmpeg 先例)。
