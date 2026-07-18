# add `opencv`(公开模块包,Form A)

日期:2026-07-18 · 关联:pkgs/o/opencv.lua、tests/smoke_opencv_module.sh
前置:compat.opencv5(#76)已合并;opencv-m v0.0.1 发布 tag。

## 形态判定

- **Form A 原生模块库**(imgui/ffmpeg 先例):上游
  [Sunrisepeak/opencv-m](https://github.com/Sunrisepeak/opencv-m) 自带 mcpp.toml,
  描述符只声明元数据 + tag tarball;包内容 = C++23 模块层
  (`import opencv.cv;` + 7 个 per-module 接口),OpenCV 5.0.0 源码经其
  `compat.opencv5 = "5.0.0"` 依赖到达消费者(全源码直编 + build.mcpp 消费端合成,
  SIMD dispatch 保留)。
- **linux-only**(compat.opencv5 目前仅 linux-x86_64 快照)。
- license:模块层 MIT;上游经 compat.opencv5 为 Apache-2.0。

## CN 镜像

gitcode `mcpp-res/opencv`(与 compat 上游 tarball 同仓,tag `v0.0.1` 与 `5.0.0`
不冲突):资产 `opencv-m-0.0.1.tar.gz` = GitHub `archive/refs/tags/v0.0.1.tar.gz`
同字节,gtc 上传,sha256 一致。

## 验证方式(imgui/ffmpeg-module 先例)

默认命名空间包不能做 workspace 成员 → `tests/smoke_opencv_module.sh`
重播默认 index 后以 `[dependencies] opencv = "0.0.1"` 消费(gcc@16.1.0),
断言版本/resize/cvtColor/PNG+JPEG roundtrip/videoio registry。仅 Linux
(非 Linux SKIP);smoke 内先 `mcpp index update`(nasm 自举,mcpp#232 规避)。
validate.yml 新增 `opencv-module` job(ubuntu-only)。

## 升级 SOP

opencv-m 发新 tag → 本包新增版本条目(GLOBAL/CN + sha256)→ smoke 的
断言版本随 compat.opencv5 的 OpenCV 版本走。
