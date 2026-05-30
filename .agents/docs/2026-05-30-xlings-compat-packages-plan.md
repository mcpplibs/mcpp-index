# mcpp-index: xlings Native Dependency Packages Plan

> 状态: in progress
> 分支: `codex/xlings-mcpp-compat-packages`
> PR: https://github.com/mcpplibs/mcpp-index/pull/17
> 目标: 把 xlings 当前本地 mcpp index 中的通用 C/C++ 依赖迁移到官方 mcpp-index，使 xlings 可以直接使用默认索引。

## 待新增包

- [x] `compat.zlib`
- [x] `compat.bzip2`
- [x] `compat.lz4`
- [x] `compat.zstd`
- [x] `compat.xz`
- [x] `compat.libarchive`

## 命名判断

第三方兼容库应使用 `compat.*` 命名空间。`compact` 容易和 xlings 内部 `core.compact` 模块混淆，不适合作为官方第三方库命名空间。

## 包迁移来源

来源仓库:

```text
/home/speak/workspace/github/openxlings/xlings/mcpp/pkgs
/home/speak/workspace/github/openxlings/xlings/mcpp/include
```

迁移时需要把配置头和包级 flags 变成包自身资产，而不是要求消费者项目提供。

当前实现依赖 mcpp `0.0.35` 中的两项能力:

- package-owned `cflags` / `cxxflags` 只作用到包自身源码。
- Form B `generated_files` 在包解压目录中写入少量配置头。

## 依赖关系

```text
compat.libarchive
  -> compat.zlib
  -> compat.bzip2
  -> compat.lz4
  -> compat.zstd
  -> compat.xz
```

## 验证要求

- [ ] `mcpp search libarchive` 能找到官方索引包。
- [x] 一个最小项目只声明 `compat.libarchive`，无需根级第三方 C 库宏即可构建。
- [x] xlings 改用默认 mcpp-index 后 `mcpp build` 通过。
- [x] musl static target 通过。

## Checkpoints

- [x] 文档 checkpoint commit。
- [x] 等 mcpp 支持 package-owned flags 后迁移包描述。
- [x] 增加官方 index smoke test:
  - 临时项目 `compat.libarchive@3.8.7` default target 构建/运行通过。
  - 临时项目 `compat.libarchive@3.8.7` `x86_64-linux-musl` 静态构建/运行通过。
- [x] PR draft 创建: https://github.com/mcpplibs/mcpp-index/pull/17
- [x] CI lint 通过。
- [x] 上游 mcpp PR #88 已合入并发布 `v0.0.35`。
