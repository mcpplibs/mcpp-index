# opencv 落地实施步骤(install() 构建环境缺口的跨仓库根治链)

**日期**: 2026-07-09
**前置**: 设计见 `2026-07-09-install-hook-toolchain-build-env-gap.md`(缺口 ④)。本篇把它拆成**有序、可执行、带依赖关系与版本携带**的实施步骤,供 maintainer / 后续会话 / 多 agent 执行。
**当前进度**: Step 0 已完成;Step 1 起**未开始**(需 maintainer 对 xlings/libxpkg 核心的 go-ahead)。

---

## 依赖关系总览(严格串行的关键路径)

```
S0 mcpp 0.0.87 ──✅已发布
      │
S1 xlings: 扩展 per-hook build-dep 环境注入 (lib→LIBRARY_PATH, include→CPATH)
      │  ✅ 已实现 + 编译验证 (分支 fix/install-hook-toolchain-build-env);待发新版 xlings Y
      │  ★ 更新:xlings-only,libxpkg 不需改、不需发版(见下修正)
S3 冷环境验证:opencv install() 不带 descriptor 硬接线也能编译+链接(需 xlings Y + CI)
      │
S4 清理:删 opencv descriptor 的临时 LIBRARY_PATH/CPATH 接线;删 validate.yml 临时诊断步骤(450acbb)
      │
S5 opencv PR #67 un-draft → CI 全绿 → squash 合入(index floor→0.0.87 随之落地)
      │
S6 (可选) mcpp-index CN 镜像 opencv 源码包 + xim-pkgindex 若需
```

**★ 重大修正(2026-07-09,已读源码 + 编译验证)**:原计划 S1(libxpkg)+S2(xlings)两仓两版,**实际是 xlings 单仓一处改动,不动 libxpkg、不发 libxpkg 版**。xlings 的 install() 执行处(`installer.cppm::execute`,~1518)**早有** per-hook 的 build-dep 环境注入(把每个 build_dep 的 `bin/` 前插 PATH,跑完还原);修复只是**在同一循环里加**:build_dep 的 `lib/`(+`lib64/`)→ `LIBRARY_PATH`、`include/` → `CPATH`,同样跑完还原。**对着仓库当前 pin 的 libxpkg 0.0.42 就能编**(`mcpp build` exit 0)。故也**无需 toolchain 解析**——直接复用包声明的 build_deps(opencv 声明 `xim:glibc`+`xim:linux-headers` 即自动生效,descriptor 零环境接线)。

**关键路径 S1→S3→S4→S5 本质串行**(每步依赖前步产物:xlings 发版 → CI 验证 → 清理 → 合入),**不可并行 fan-out**。

---

## Step 1 — xlings:扩展 per-hook build-dep 环境注入 【已实现 + 编译验证】

**仓库**: `openxlings/xlings`。**分支**: `fix/install-hook-toolchain-build-env`(1 commit,基于 main;**未 push**)。
**改动**(`src/core/xim/installer.cppm::execute`,现有 build-dep env 注入块 ~1518):在遍历 `node.build_deps` 组 PATH 的同一循环里,追加
- `<bdDir>/lib` 与 `<bdDir>/lib64`(存在则)→ `LIBRARY_PATH`(crt1.o/crti.o/libm/libc)
- `<bdDir>/include`(存在则)→ `CPATH`(stdlib.h/limits.h、内核 uapi 头)

用 `platform::set_env_variable` 在 hook 前设、跑完还原(与既有 PATH 注入同款,含错误路径还原)。**不新增 ctx 字段、不动 libxpkg、无需 toolchain 解析**——包声明的 build_deps 直接驱动。
**验证已完成**:
1. **编译**:`mcpp build`(release)exit 0,**对着 pin 的 libxpkg 0.0.42**,即 xlings-only、无需 libxpkg 发版。
2. **代码路径证实**:实跑 opencv install(),marker dump 进程 env → PATH 含 `xim-x-{cmake,gcc,glibc}/.../bin`,证明该循环确对 opencv 执行、glibc 被解析;同循环加的 LIBRARY_PATH/CPATH 在打补丁的 xlings 里必然填充(glibc 的 lib/include 存在)。
**未完成**:端到端"opencv 变绿"——因 mcpp 会重新物化自带的 xlings 二进制、本地二进制热替换有竞争,且宿主 libc 会掩盖差异;**铁证需正式发一版带此改动的 xlings Y + CI 冷环境**。
**产物**: xlings 新版本 **Y**(= 0.4.62 的下一个)。若 D1(#354)一起走,可同一版发。

## Step 3 — 冷环境验证

在**全新 MCPP_HOME + 打包版 xlings Y + GLOBAL 镜像**(等价 CI 冷缓存)下,跑 opencv member 的 `mcpp test`,**且 opencv descriptor 已去掉临时 LIBRARY_PATH/CPATH**(即只靠 xlings Y 提供的环境)。期望:cmake 编译器自检过、3rdparty+core+imgproc+imgcodecs 编过、install 出 headers+libs、roundtrip ok。
**注意**: 本地复现要避免"共享 registry 被前次运行污染"的坑(见缺口④调查):用真正干净的 registry,或删掉 xim-x-cmake/gcc 强制全新装。

## Step 4 — 清理 opencv descriptor + CI 临时件

- `pkgs/c/compat.opencv.lua`: 删除 `_install_impl` 里的 `LIBRARY_PATH`/`CPATH` 拼接 + `pkginfo.install_dir("xim:glibc"/"xim:gcc"/"xim:linux-headers")` 解析 + `libenv` 注入(这些改由 xlings 提供)。**但 `deps` 里的 `xim:glibc@2.39`、`xim:linux-headers@5.11.1` 声明要保留** —— S1 的 xlings 注入正是**由包声明的 build_deps 驱动**的,删了就没 lib/include 可注入。保留 `OPENCV_PYTHON_SKIP_DETECTION`(OpenCV×CMake4 的独立正解)+ bare-name 工具调用(loader launcher 的正解)。
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
