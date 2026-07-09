# opencv 落地实施步骤(install() 构建环境缺口的跨仓库根治链)

**日期**: 2026-07-09
**前置**: 设计见 `2026-07-09-install-hook-toolchain-build-env-gap.md`(缺口 ④)。本篇把它拆成**有序、可执行、带依赖关系与版本携带**的实施步骤,供 maintainer / 后续会话 / 多 agent 执行。
**当前进度**: Step 0 已完成;Step 1 起**未开始**(需 maintainer 对 xlings/libxpkg 核心的 go-ahead)。

---

## 依赖关系总览(严格串行的关键路径)

```
S0 mcpp 0.0.87 ──✅已发布
      │
S1 libxpkg: hook 子进程注入 LIBRARY_PATH/CPATH ──(发新版 libxpkg X)
      │  (前一 PR 需发版 → 下一 PR 直接带版本号 X)
S2 xlings: 解析 toolchain glibc/linux-headers → 喂给 ctx；pin libxpkg X ──(发新版 xlings Y)
      │
S3 冷环境验证:opencv install() 不带 descriptor 硬接线也能编译+链接
      │
S4 清理:删 opencv descriptor 的临时 LIBRARY_PATH/CPATH + 显式 glibc/linux-headers deps；删 validate.yml 临时诊断步骤(450acbb)
      │
S5 opencv PR #67 un-draft → CI 全绿 → squash 合入(index floor→0.0.87 随之落地)
      │
S6 (可选) mcpp-index CN 镜像 opencv 源码包 + xim-pkgindex 若需
```

**关键路径 S1→S2→S3→S4→S5 本质串行**(每步依赖前步产物:libxpkg 版本 → xlings pin → 验证 → 清理 → 合入),**不可并行 fan-out**。这解释了为何本任务实际是串行链而非多 agent 并行——并行只在"各步内部的子任务"层面有限适用(见各步注)。

---

## Step 1 — libxpkg:hook 执行时注入构建环境

**仓库**: xlings 实际 pin 的 libxpkg(确认是 `mcpplibs/libxpkg` 还是 `openxlings/libxpkg`——xlings 经 `mcpp.lock` pin,先核对)。
**改动**: xpkg executor 的 `run_hook`(执行 install()/config Lua hook 的子进程)在组装子进程 env 时,除已有的 build-dep PATH 注入外,再 `LIBRARY_PATH` / `CPATH` 追加**调用方传入的 toolchain lib/include 目录**(executor 不自己解析工具链,只消费 xlings 传来的值——保持分层)。
**接口**: 给 hook 执行的 ctx/exports 增加一个"额外环境"字段(内存态,不落盘;契合 #351 revert 留言"若需元数据,xlings 自己为第一消费者")。
**产物**: libxpkg 新版本 **X**(= 当前 0.0.42 的下一个;若 D1 的 0.0.43 也一并发,则本步为 0.0.44,或与 D1 合并为一个 0.0.43)。
**验证**: libxpkg 自身单测 + 一个"hook 内 env 含 LIBRARY_PATH/CPATH"的断言。
**并行点**: 可与 S2 的"xlings 侧解析逻辑"并行开发,但 S2 的**集成+pin** 必须等 X 发布。

## Step 2 — xlings:解析 toolchain 的 glibc/linux-headers → 喂给 ctx

**仓库**: `openxlings/xlings`。
**改动**: `src/core/xim/installer.cppm` 在跑 install() hook 前(约 1313–1346 组 ctx 处),用已有的 `effective_install_dir_` / `locate_dep_install_dir_`(~1081)机制解析**当前 default toolchain**(gcc@16.1.0)的 runtime dep 链上的 `xim:glibc`、`xim:linux-headers` 的 effective install_dir,拼出 `<glibc>/lib`、`<glibc>/include`、`<linux-headers>/include`,写进 ctx 的"额外环境"字段传给 executor(S1 的接口)。
**关键**: 用 effective store(additive:project 叠 global)口径,与 D1 同源——若 D1 已合,直接复用其 `effective_install_dir`。
**pin**: 把 `mcpp.lock` 里 libxpkg 提到 **X**。
**产物**: xlings 新版本 **Y**。
**验证**: 冷环境跑任意"链接可执行体的源码构建包"的 install() 成功(见 S3)。

## Step 3 — 冷环境验证

在**全新 MCPP_HOME + 打包版 xlings Y + GLOBAL 镜像**(等价 CI 冷缓存)下,跑 opencv member 的 `mcpp test`,**且 opencv descriptor 已去掉临时 LIBRARY_PATH/CPATH**(即只靠 xlings Y 提供的环境)。期望:cmake 编译器自检过、3rdparty+core+imgproc+imgcodecs 编过、install 出 headers+libs、roundtrip ok。
**注意**: 本地复现要避免"共享 registry 被前次运行污染"的坑(见缺口④调查):用真正干净的 registry,或删掉 xim-x-cmake/gcc 强制全新装。

## Step 4 — 清理 opencv descriptor + CI 临时件

- `pkgs/c/compat.opencv.lua`: 删除 `_install_impl` 里的 `LIBRARY_PATH`/`CPATH` 拼接 + `pkginfo.install_dir("xim:glibc"/"xim:gcc"/"xim:linux-headers")` 解析 + `libenv` 注入;`deps` 去掉临时的 `xim:glibc@2.39`、`xim:linux-headers@5.11.1`(回到 cmake/make/gcc)。保留 `OPENCV_PYTHON_SKIP_DETECTION`(那是 OpenCV×CMake4 的独立正解,非临时)+ bare-name 工具调用(那是 loader launcher 的正解)。
- `.github/workflows/validate.yml`: 删除 commit `450acbb` 的临时诊断步骤 `install() diagnostics on failure`。
- `index.toml` floor→0.0.87 + `MCPP_VERSION`→0.0.87 保持(随 opencv 一起合入 main 才正确——见"floor 与 opencv 耦合"结论)。

## Step 5 — opencv PR #67 un-draft → CI 绿 → 合入

`gh pr ready 67` → 等 workspace(linux) 真绿(install() 靠 xlings Y 闭环)→ `gh pr merge 67 --squash --admin`。floor→0.0.87 随之落地 main(此时 index 里 opencv 确实需要 0.0.87,floor 才名正言顺)。

## Step 6(可选) — CN 镜像 + 索引

opencv 源码包若要 CN 加速:`mcpp-res/opencv` gitcode 镜像 `opencv-4.13.0.tar.gz`(需 token)。与 mcpp 0.0.87 的 gitcode 镜像挂死是**同类 infra 问题**,一并交 maintainer。

---

## 版本携带规则(按目标要求)

S1 发 libxpkg **X** → S2 的 xlings PR 直接在其内 pin 到 X 并发 xlings **Y**;不为 X 单开"仅 bump pin"的 PR。若 D1(#354)与本链一起走,则 libxpkg 一个版本同时含 D1 + 本步(0.0.43),xlings 一个 PR 同时 pin + 用两者。

## 为什么没走"并行多 agent"

关键路径(S1→S2→S3→S4→S5)每步的**产物是下一步的输入**(版本→pin→验证→清理→合入),是硬串行。可并行的只有:S1 与 S2 的**编码阶段**、各仓的**测试用例编写**、文档。真正的瓶颈是 maintainer 对 xlings/libxpkg 核心改动的 review+发版,不是 agent 数量。
