# add `ffmpeg`(公开模块包,Form A)+ 收编 compat.ffmpeg 描述符流水线

日期:2026-07-18 · 关联:pkgs/f/ffmpeg.lua、tools/compat-ffmpeg/、tests/smoke_ffmpeg_module.sh
前置:#74(compat.ffmpeg 8.1.2 全源码直编)已合并;ffmpeg-m v0.0.1 已发布 tag。

## 形态判定

- **Form A 原生模块库**(同 `imgui`):上游 [mcpplibs/ffmpeg-m](https://github.com/mcpplibs/ffmpeg-m)
  自带 `mcpp.toml`,描述符只声明元数据 + tag tarball 下载地址,默认查找
  `<verdir>/*/mcpp.toml`。
- 包内容 = 纯 C++23 模块层(`import ffmpeg.av;` 及 7 个分库模块),FFmpeg 全部
  源码经其 `compat.ffmpeg = "8.1.2"` 依赖到达消费者(全源码直编形态,零预构建)。
  C API 名称与用法完全不变。
- **linux-only**(先例 `compat.x11`):compat.ffmpeg 目前仅有 linux-x86_64 configure
  快照;macOS 阻塞于 mcpp#229(依赖侧 cfg 条件源)。
- license:模块层 MIT;上游经 compat.ffmpeg 为 LGPL-2.1-or-later(无 GPL/nonfree 组件)。

## CN 镜像

gitcode `mcpp-res/ffmpeg`(与 compat 上游 tarball 同仓,tag 不冲突):
release `v0.0.1`,资产 `ffmpeg-m-0.0.1.tar.gz` = GitHub
`archive/refs/tags/v0.0.1.tar.gz` 同字节,`gtc release publish` 上传,sha256 一致。

## 验证方式(imgui-module 先例)

默认命名空间(namespace = "")的包尚不能作为 workspace 成员指向本地 path index,
故沿用 `imgui-module` 的例外通道:`tests/smoke_ffmpeg_module.sh` 重播默认 index
后以 `[dependencies] ffmpeg = "0.0.1"` 消费,gcc@16.1.0,断言 libavutil 主版本、
4 个解码器存在、demuxer 数 > 300。仅 Linux(非 Linux 直接 SKIP)。
smoke 内先 `mcpp index update` 刷新沙箱包索引(nasm 自举,mcpp#232 规避;置于
重播默认 index 之前,避免刷新覆盖重播结果)。validate.yml 新增 `ffmpeg-module`
job(ubuntu-only,镜像 imgui-module 结构)。

## 描述符流水线收编(tools/compat-ffmpeg/)

`compat.ffmpeg.lua` 为生成物(329 KB,禁止手改)。生成器原在 ffmpeg-m
(`tools/gen_config.sh`/`gen_descriptor.py`),随本次 PR 迁至本仓
`tools/compat-ffmpeg/`(fetch_upstream.sh + gen_config.sh + gen_descriptor.py),
与其生成的描述符同仓维护;ffmpeg-m 只保留模块层与导出面生成器(gen_exports.py)。
迁移回归:迁移后重跑流水线,与已合并描述符 diff 仅头注释 2 行(2281 源 + 15
生成文件字节一致;host gcc 13 与原生成环境结果一致,可复现)。
注意:宿主 `cc` 若被 xlings subos 切到交叉工具链会导致 configure 失败,用
`CC=/usr/bin/gcc` 显式指定。

## FFmpeg 版本升级 SOP

1. 本仓:改 `tools/compat-ffmpeg/fetch_upstream.sh` 的 version/sha256 pin →
   `sh tools/compat-ffmpeg/gen_config.sh` 重生成描述符 → 上传新上游 tarball 到
   CN 镜像 → PR。
2. ffmpeg-m:bump `compat.ffmpeg` 依赖 + `tools/fetch_upstream.sh` pin →
   `python3 tools/gen_exports.py` 重生成导出面 → 审阅 diff → 发新 tag →
   本仓登记新版本条目。
