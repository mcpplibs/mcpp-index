# 深度根因调研:build-dep 工具在项目沙箱不可执行(cmake INTERP 悬空)

**日期**: 2026-07-09
**触发**: 收录 OpenCV(`compat.opencv`,install() 驱动 CMake 源码构建)时,`mcpp test` 无法闭环。
**归责规则(用户设定)**: 先查是不是 **mcpp 设计/使用/架构** 问题;再看是不是 **xlings 原生** 问题。若 xlings 本身没问题、只是 mcpp 使用方式出问题 → 归 mcpp;**除非存在真实的 xlings 原生设计缺陷**。
**方法**: 实证复现(含 fresh 环境普适性)+ mcpp 源码追踪 + xlings 源码追踪(两路独立),交叉裁决。
**关联**: `.agents/docs/2026-07-08-opencv-*.md`、`2026-07-09-mcpp-xlings-project-sandbox-builddep-payload-bug.md`(本篇为其升级/更正版,归责以本篇为准)。

## 文档族与职责边界(三份配套,全部根治设计、无 workaround)

| # | 仓库 / 文档 | 角色 | 与本故障的关系 |
|---|---|---|---|
| ① | **本篇** mcpp-index `2026-07-09-mcpp-builddep-loader-store-split-rootcause.md` | 根因总报告(现象/实证/归责) | 全貌 |
| ② | mcpp `2026-07-09-project-index-scope-global-infra-fix.md` | **本故障唯一必需修复(根治)** | 修 ② 即闭环 |
| ③ | openxlings/xlings `2026-07-09-scope-consistency-installed-check-and-loader-resolution.md` | xlings 侧**独立**健壮性缺口(根治) | 不由本故障触发、与 ② 互不依赖 |

**职责边界**:本篇是根因分析;**修复设计见 ②(唯一必需,根治)**;③ 是独立缺口。三份均根治设计、不含 workaround。

---

## 0. 结论(TL;DR)

- **现象**:项目沙箱里 build-dep `xim:cmake` 的 ELF interpreter 被指向 `<proj>/.mcpp/.xlings/data/xpkgs/xim-x-glibc/2.39/lib64/ld-linux-x86-64.so.2`,该 loader **从未落进项目 store**;glibc 的真身与记录都在 **registry(global)**。→ cmake `cannot execute`。
- **普适**:**fresh `MCPP_HOME` 同样失败**(RC=1,同一错误),**CI 亦会失败**,非本机历史所致。

### 根因(一句话):mcpp 强制把 xlings 官方 **全局** 索引 `xim` 注册成 **项目作用域** index repo,覆盖了 xlings 原生的 additive 项目机制 —— 把本应装进全局 registry 的 xim 工具(cmake/glibc/gcc/make)整体错误地"项目化",装进了项目 store。

- **直接证据**:项目 `.mcpp/.xlings.json` 的 `index_repos` = `[compat(本地,对), xim(官方全局索引,被塞进项目 repos)]`。而 `catalog.cppm:168-176` 把"项目 index_repos 里的包"一律判 `scope=Project` → `storeRoot=项目 store`(`:297-300`)。→ xim 工具全被装进项目 store。
- **肇事代码(mcpp,故意但机制错)**:`mcpp/config.cppm:684-697` 主动把官方 `xim` 索引 append 进项目 `customRepos`;意图注释见 `:745-748`("让 `xim:python@latest` 之类能解析")。
- **为何是"强制改变 xlings 设计意图"**:xlings **原生**就同时扫 project+global 两套 repo(`catalog.cppm:328-329`)且项目模式 **additive over global**(`merged_versions :603`、`merge_workspace_into_ Anonymous :581-584`);xim 本是全局默认索引、registry 里已有其本地 clone(`registry/data/xim-pkgindex/pkgs`)。**因此 `xim:cmake` 本会以 Global 作用域解析→装 registry→并对项目可见 —— 根本不需要 mcpp 再把 xim 加进项目 repos。** mcpp 的强加既**多余**又**有害**。
- **下游连锁(为何最终悬空)**:xim 工具被项目化后,cmake 装进项目 store(`install()`/`config()` 确实跑了,项目 store 里 cmake 有 8201 文件、xvm 已注册);但其 loader 依赖 glibc 已被**工具链 bootstrap**(`gcc@16.1.0` 默认)装进 registry 并记录,项目安装时被 `installer.cppm:906` 的 merged 版本库判"已装"跳过 → 项目 store 的 glibc 空;auto-elfpatch 又把 cmake interpreter 指向项目 store 的空 glibc → 悬空。

### 归责(按规则)
- **主责 = mcpp 设计错误**:mcpp **强制改变了 xlings 的设计意图** —— 把全局索引 `xim` 注册为项目作用域(`config.cppm:684-697`),而 xlings 原生的"全局安装 + 映射到项目"机制本就够用。这是"可解析"与"项目作用域 store"混为一谈。**删掉这一强加即从源头消除问题**(xim 工具回到 registry,cmake interpreter 天然指 registry 的可用 glibc)。
- **xlings 侧:与本故障无关、非产生方**。mcpp 侧根治(见文档 ②)后,cmake/glibc 同在全局 registry,`installer.cppm:906` 的 merged 复用是正当 additive 语义、不再被误触。xlings 另有一个**独立**的 elfpatch loader 解析健壮性缺口(合法"项目消费者 + 全局 provider"),其根治设计见文档 ③——**不是本故障的必要条件,与 ② 互不依赖**。

---

## 1. 现象与复现

- 工程 `mcpp.toml` 含自定义 `[indices]`(本地 path 索引)→ 进入项目本地模式(`mcpp/src/config.cppm:100-105` `make_project_xlings_env` 注释:*"Used when custom (non-builtin) indices are configured"*)。
- compat 包声明 build-dep `xim:cmake` 且 install() 执行它 → `mcpp test`:
  ```
  <proj>/.mcpp/.xlings/data/xpkgs/xim-x-cmake/4.0.2/bin/cmake: cannot execute: required file not found
  ```
  cmake 的 PT_INTERP 指向 `<proj>/.mcpp/.xlings/data/xpkgs/xim-x-glibc/2.39/lib64/ld-linux-x86-64.so.2`,该文件不存在;真 loader 在 `<proj>/.mcpp/.xlings/data/runtimedir/glibc-2.39-linux-x86_64/lib/`。

### 1.1 普适性(关键,排除"本机历史")
- `MCPP_HOME=<fresh tmp> mcpp test` → **RC=1,同一 cmake 错误**。
- fresh 日志:`First run no toolchain configured — installing gcc@16.1.0 (glibc, native ABI) as default` → `Default set to gcc@16.1.0`。
- fresh `registry/data/xpkgs/xim-x-glibc/2.39/` **完整**(bin/lib/lib64/…,loader 在);`registry/.xlings.json` 版本库含 `glibc-2.39`。
- fresh 项目 `.../xpkgs/xim-x-glibc/2.39/` **只有 `.xpkg.lua`**。
→ 证明:失败**不依赖任何预装历史**,而是 mcpp 引导流程每次都种下 registry 的 glibc 记录。

---

## 2. 完整机制链(源码 file:line)

**0.(上游根因)mcpp 把官方全局索引 `xim` 注册成项目作用域 index repo**
- `mcpp/config.cppm:684-697`:`ensure_project_index_dir` 把 `officialIndex`(`xlingsHome()/data/xim-pkgindex`)以名字 `xim` append 进项目 `customRepos`(`if (!hasXim) customRepos.emplace_back("xim", …)`),随后 `seed_xlings_json`(`:707`)写进项目 `.mcpp/.xlings.json` 的 `index_repos`。意图注释 `:745-748`。
- `xlings/catalog.cppm:168-176`:`project_index_repos()` 里的 repo → `scope=Project`;`:297-300`:`storeRoot = project_data_dir/xpkgs`。→ **凡从 `xim` 解析到的包(cmake/glibc/gcc/make/binutils)全部 Project 作用域、装进项目 store。**
- **本不必要**:`xlings/catalog.cppm:328-329` `collect(projectRepos_); collect(globalRepos_);` 原生同时扫两套;项目模式 additive over global(`config.cppm:603` merged_versions、`:581-584` merge_workspace)。xim 是全局默认索引、registry 有本地 clone → `xim:cmake` 本会 Global 解析→装 registry→对项目可见。mcpp 的强加**覆盖**了这套原生机制。

以下 1–5 是"xim 被项目化"之后的下游连锁:

1. **mcpp 把工具链(含 glibc)装进 registry(global),并记录版本**
   - `make_xlings_env()` 构造 GLOBAL env(无 projectDir):`mcpp/config.cppm:84-98`;`XLINGS_HOME=~/.mcpp/registry`(`config.cppm:78-80, 459-465`)。
   - 普通构建即自动触发全局装 glibc:`mcpp/build/prepare.cppm:805-810`;fetcher 走全局 home:`mcpp/pm/package_fetcher.cppm:739,800,810`。显式安装同理:`mcpp/toolchain/lifecycle.cppm:332-338`。
2. **mcpp 把项目 build-dep 路由到项目 store,但 `XLINGS_HOME` 仍是 registry**
   - 自定义(非内置)索引 → 项目模式:`mcpp/build/prepare.cppm:1188`(`useProjectEnv = idxSpec && !idxSpec->is_builtin()`),`:1350` 走 `make_project_xlings_env`。
   - 该 env:`home=cfg.xlingsHome()`(**仍 registry**)+ `projectDir=<proj>/.mcpp`(`mcpp/config.cppm:102-105`)。
   - 命令前缀**同时**设 `XLINGS_HOME=registry` 与 `XLINGS_PROJECT_DIR=<proj>/.mcpp`:`mcpp/xlings.cppm:730-738`。→ xlings 一次调用里同时看到"装满的 global"和"空的 project"。
3. **cmake 及其 dep glibc 解析进项目 store**
   - `node.storeRoot = match.storeRoot`(`xlings/xim/resolver.cppm:275`);`match.storeRoot` 由 `match.scope` 选 project/global(`xlings/xim/catalog.cppm:298-300`);scope 由包所属 index repo 是否 project 决定(`catalog.cppm:170-189`)。
   - `install_dir = targetRoot/store/version`(`xlings/xim/installer.cppm:838-839`),cmake/glibc 均落项目 store 目标。
4. **xlings 的"已装"跳过闸门读 merged 版本库 → 跳过 glibc 在项目 store 的落盘**
   - 空 `install_dir` 先被创建:`installer.cppm:887-891`。
   - `payloadInstalled` 初值来自 catalog 的**项目作用域**判定(store 空 → false):`catalog.cppm:302-306` → `resolver.cppm:277` → `installer.cppm:893`。
   - glibc 无 `installed` hook → 落到默认闸门:`installer.cppm:905-913`,读 `Config::versions()`=**merged**(`xlings/config.cppm:601-603`,`merged_versions :564-568`),命中 registry 的 glibc → `payloadInstalled=true`。
   - 于是 `glibc.lua:87-98` 的 `os.mv`(把 loader 落进 `xpkgs/xim-x-glibc/2.39/`)被 `!payloadInstalled` 守卫跳过(`installer.cppm:916/953/964`)→ **项目 store 的 glibc 目录仍空**。
5. **elfpatch 把 cmake INTERP 指向空的项目 store glibc**
   - loader провайдер 用**约定扫描**(非 deps_exports;`ctx.deps_exports/self_exports/runtime_deps_list` 在本版 xlings 全未赋值)。`_resolve_dep_via_scan`(`xlings/…/xpkg-lua-stdlib.cppm:473-505`)扫"消费者 install_dir 的祖父目录"=消费者**项目 store** 的 xpkgs,匹配到 glibc 目录并因 `os.isdir` 为真而接受(该目录存在但空,`installer.cppm:890` 建的)。
   - 结合 glibc 的 `loader="lib64/ld-linux-x86-64.so.2"` 导出(`glibc.lua:38-44`)→ `patchelf --set-interpreter <project>/…/xim-x-glibc/2.39/lib64/ld-linux-x86-64.so.2`(`xpkg-lua-stdlib.cppm:1366-1370`)→ 指向空目录 → 悬空。**registry 里那个存在的 loader 从不被采用**(扫描先命中空的项目目录)。

### 2.1 核心矛盾一句话
**"跳过 materialize(因为 merged 命中 global 记录)" 与 "elfpatch 指向 project store(假定本地有)" 两个决策,对 glibc 究竟在哪个 store 各执一词**;而工具(cmake)在 project、loader(glibc)在 registry —— 两者分属不同 store。

---

## 3. 归责裁决(按用户规则)

### 3.1 两路追踪的分歧
- **mcpp 路**:失败状态由 mcpp 制造(双 store 同调 + 无 loader 落盘/改指);原生 xlings 单次单作用域不会有"装满 global + 空 project 同时呈现"。→ 归 mcpp。
- **xlings 路**:`installer.cppm:906` 是真实内部不一致(同一流水线两次判"已装"、作用域不一致,scope-blind 的 :906 覆盖了正确的 project 判定 `catalog.cppm:302-306`);声称纯 xlings 可复现。→ 归 xlings 原生缺陷。

### 3.2 裁决依据
按规则"**除非真实的 xlings 设计缺陷**,否则归 mcpp",关键在:**触发失败的那个状态,是 mcpp 制造的、还是 xlings 原生就会产生并支持的?**

1. **失败所需状态 = "装满 global + 空 project,一次调用同时呈现"**,由 mcpp 明确构造:`XLINGS_HOME=registry` 与 `XLINGS_PROJECT_DIR=project` 同时设置(`mcpp/xlings.cppm:730-738`),工具链强制 global(`make_xlings_env`)、build-dep 强制 project(`make_project_xlings_env`)。这是 mcpp 的架构选择。
2. **原生 xlings 不触达、无测试**:xlings 路自己承认无任何 e2e 覆盖"global 预装某 dep + project 作用域消费者需重新 materialize loader"这一路径;`elfpatch_install_verify_test.sh` 只在**单 store** 断言;`project_global_fallback_test.sh` 是"有 project config 但全局作用域"(**单 store**)。
3. **xlings 自身对"同包两作用域"另有设计**:`prefer_project_scope_`(`catalog.cppm:375-390`)专门去重"project 与 global 同包" —— 说明 xlings 设计者预期到两作用域并**打算优先 project**;而 `:906` 闸门**没有走这套去重/优先逻辑**,直接被 global 记录短路。即 xlings 的**既定意图是 materialize/优先 project**,`:906` 是与该意图相悖的一处疏漏。
4. **mcpp 无修复步骤**:唯一的 payload 兜底 `fallback/xpkg_copy.cppm:21-60` 只拷单个 verdir、且只接在**全局** fetch 路径(`package_fetcher.cppm:773,818`),从不接项目安装(`prepare.cppm:1350-1357`);不遍历 runtime/loader dep。→ mcpp 没有把 loader 落进项目 store,也没让消费者改指 registry loader。

**裁决**:
- **主责 = mcpp 设计错误(强制改变 xlings 设计意图)**。**最上游、决定性的一步**是 `mcpp/config.cppm:684-697` 把官方全局索引 `xim` 强加为**项目作用域** index repo(§2.0),使 xim 工具整体错误项目化。而 xlings **原生**的"全局解析 + additive 映射到项目"机制本就满足 mcpp 的需求(让 `xim:` 依赖在项目模式可用),**根本不需要这一强加**。按规则,这是"xlings 本身可用、mcpp 使用方式(强制覆盖原生意图)导致出问题" → **mcpp 的设计问题**。
- **次责 = xlings `installer.cppm:906`(潜在、防御性)**。"已装"判定读 merged、与落盘/elfpatch 的 project 作用域不一致,与自身 `prefer_project_scope_` 意图相悖 —— 一处真实内部不一致,值得加固;但它是被 mcpp 的错误作用域**诱发**的下游,xim 作用域修正后不再被触达。**非本失败的产生方。**

> 一句话:**xlings 原生就"全局装 + 映射到项目",够用;是 mcpp 多此一举把官方 xim 索引强注册成项目作用域(`config.cppm:684-697`),把本该在 registry 的工具整体项目化,才引出后续 loader 不落盘、interpreter 悬空。删掉这一强加即根治。**

---

## 4. 修复方案

### 4.1 mcpp 侧(唯一必需修复,根治)——详见文档 ②
根治设计见 **mcpp 仓 `.agents/docs/2026-07-09-project-index-scope-global-infra-fix.md`**(文档 ②),摘要:
- **原则:global 是默认**(xlings 只把落进"项目组"的 repo 判 Project,`catalog.cppm:175-224`)。**mcpp 只把用户在 `[indices]` 声明的项目本地索引放进项目组,绝不注入官方 `xim`。** 删除 `mcpp/config.cppm:684-697`(无条件把官方 xim 注入项目 `customRepos`)、收敛 `:745-765`;全局 `xim` 指 registry 本地 clone 以免 remote fetch。**不硬编码 `is_global_infra` 白名单**(违背"global 默认"、漏 xim 动态 sub-index)。
- 效果:xim 及其 sub-index 留全局 → cmake/glibc/gcc/make 全 registry(同一全局 store)→ interpreter 天然指 registry glibc → 可执行。**`:906` merged 复用随之无关,xlings 无需改动。**
- **不采用**任何治标补丁(往项目 store 物化 loader、改 elfpatch 指项目空目录等);理由见文档 ②"❌ 不要做"。

### 4.2 xlings 侧 —— 与本故障**无关**,是独立缺口(见文档 ③)
本故障**不需要**任何 xlings 改动:mcpp 侧根治(§4.1 / 文档 ②)后,cmake/glibc 全在同一全局 registry,`installer.cppm:906` 的 merged 复用是**正当的 additive 语义**、不再被误触。
- xlings 另有一个**相互独立**的健壮性缺口:合法"项目消费者 + 全局 loader-provider(additive 复用)"场景下,elfpatch 对 provider 的解析口径可能指向未物化 store。其根治设计(单一事实源 `effective_install_dir`、内存传递)见 **openxlings/xlings 仓文档 ③**。**它不是本故障的必要条件,与 ② 互不依赖。**

---

## 5. 对 compat.opencv / mcpp-index 的影响

- `compat.opencv.lua` 已是**零兼容代码**的极简 `pkginfo.build_dep` 形式;**本问题(mcpp 侧)修复后,descriptor 与测试工程零改动即闭环**。
- 构建配方 host-free 正确性已在沙箱外证明(`unshare -rn` 隔离构建 core+imgproc+imgcodecs 零下载 81s + mcpp g++ 链接运行 `opencv ok=1 core=4x4x3 gray(blue)=29 png_bytes=82 decoded=4x4`)。
- 因 CI 走同一 `mcpp test` 沙箱,**修复前 opencv 无法进 CI 选跑**(必红,且 fresh 环境已证必现)。→ PR 应待 mcpp 侧修复;或先将 opencv 暂缓接入 workspace/CI(staged)。

## 6. 附:最小复现清单
1. 任意工程 `mcpp.toml` 声明自定义 `[indices]`(本地 path 索引)。
2. 一个 compat 包声明 build-dep `xim:cmake` 并在 `install()` 内执行 `cmake`。
3. 任意机器(含全新 `MCPP_HOME`)`mcpp test` → `cmake: cannot execute`。
4. 现成:`tests/examples/opencv` + `pkgs/c/compat.opencv.lua`。
