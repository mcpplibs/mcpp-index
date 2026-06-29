# 用 mcpp workspace 原生跑 mcpp-index CI(替代 smoke `xxx.sh`)架构方案

**日期**: 2026-06-29
**本仓**: `mcpp-community/mcpp-index`(github 别名 `mcpplibs/mcpp-index`)
**问题**: 现在 mcpp-index 的 CI 用一堆 `tests/smoke_*.sh` 脚本(heredoc 生成临时消费者工程
再 `mcpp build`/`run`)。能不能**不用 .sh**,把 mcpp-index 当成一个**大的 mcpp workspace**,
直接 `mcpp test` 跑完?
**结论先行**: **能搬一半,不能全去掉**。让**仓库根自指**为「索引 ⊕ virtual workspace」
(member 复用 `tests/examples/*`、`[indices] compat = { path = "." }` 指回自己的 `pkgs/`,**不另起
`ci/` 目录**),可以把脚本里**「造工程 + 路由依赖」**那一半变成签入的静态 member(地道 mcpp 用法、
顺带吃狗粮);但 mcpp 今天**没有「整 workspace 一条命令测完」、没有 per-OS 依赖/ldflags、没有条件化
跳过执行**,而**环境隔离 / 下载缓存 / 产物断言**本就不属于 mcpp 职责。所以现实落点是**一个薄得多的
驱动脚本** 驱动 `mcpp test/run` 跑这个自指 workspace —— 而不是脚本归零。per-OS 那块由 mcpp 侧
**L1 条件依赖**(见 §4a 关联文档)落地后从驱动删除。
本文给出能力对照、差距、分层方案、以及让驱动继续变薄的 **mcpp 侧特性路线图**。

> 证据基于 mcpp 源码 `mcpp-community/mcpp`(下文 file:line 均指该仓)与本仓 `tests/`。

---

## 1. 现状:smoke `.sh` 干了什么

脚本:`smoke_compat_core.sh` / `smoke_compat_portable.sh` / `smoke_compat_imgui.sh` /
`smoke_compat_imgui_window.sh` / `smoke_compat_archive.sh` / `smoke_imgui_module.sh`,
外加 `run_example.sh` 和 lua 镜像校验器。每个脚本做的事可归成两类:

- **A. 「造工程 + 路由依赖 + 编译运行」**(mcpp 本职):heredoc 写 `mcpp.toml` + `src/main.cpp`,
  用 `[indices] compat = { path = "../../.." }` 把 `compat.*` 路由到本仓的 `pkgs/**/*.lua`,
  然后 `mcpp build` + `mcpp run`,断言编进 `main`(失败 return 非 0)。
- **B. 「CI/环境编排」**(非 mcpp 本职):临时 `MCPP_HOME` 隔离、预装 xpkg 软链入 registry、
  镜像选择、下载缓存 restore/save、平台门控(Windows 才跑 openblas)、显示门控(有 `DISPLAY`
  才跑窗口)、产物断言(`readelf -d` 查链接、DLL 是否落在 exe 旁、从中性 CWD 直跑 exe)、
  对 recipe `.lua` 内容的元断言(grep `dlopen_libs`)。

A 类是「把 mcpp 当库索引来消费」,完全可以静态化;B 类大部分是 mcpp 边界之外的编排。

---

## 2. mcpp 今天原生支持什么(可直接利用)

| 能力 | 证据 | 说明 |
|---|---|---|
| **`[workspace]` 多 member** | `src/manifest.cppm:215-228`(`WorkspaceConfig`:members/exclude/`[workspace.dependencies]`);`examples/04-workspace/mcpp.toml` | Cargo 式,virtual(只有 `[workspace]`)或 rooted(`[package]+[workspace]`)。member 是普通包,可 `path` 互依。 |
| **本地路径索引** `[indices] x = { path }` | `src/pm/index_spec.cppm:14-25`(path 优先于 url);`package_fetcher.cppm:503-515`(读 `<path>/pkgs/<首字母>/<name>.lua`) | 正是 smoke 用法:索引名=命名空间,`compat.<pkg>` 路由到本仓 recipe。无需 clone。 |
| **`mcpp test`** | `src/cli/cmd_build.cppm:67-79` → `src/build/execute.cppm:421-594` | glob `tests/**/*.cpp`,每个 `.cpp` 合成一个 test 二进制,一次 ninja 全编,顺序跑,汇总 `N passed; M failed`。**只认退出码 0/非 0**。唯一会解析 `[dev-dependencies]` 的命令。 |
| **`mcpp run`** 执行产物 | `execute.cppm:416` | 编消费者 bin 并 exec,子进程退出码透传。断言写进 `main`。 |
| **per-OS 工具链** `[toolchain]` | `manifest.cppm:87-100` parse `:1073-1081` | `default`/`linux`/`macos`/`windows` → `pkg@ver`。根 `mcpp.toml` 已用(gcc 默认、mac/win 用 llvm)。 |
| **per-target 覆盖** `[target.<triple>]` | `manifest.cppm:169-172` parse `:1144-1171` | 仅 `toolchain` + `linkage` 两键。 |
| **profile / feature / capability / feature-deps** | `manifest.cppm:231-240`、`259-278`、`645-673`;per-target `required_features` 门 `:72-76` | A/B 矩阵在「单包内」可表达;`--features`/`--cap` 驱动。 |
| **`[runtime]` 运行期库路径** | `manifest.cppm:153-165`;`execute.cppm:532-563`(run/test 都 prepend) | 动态库定位原生支持(本次 0.0.73 的 Windows DLL 旁置即走这条)。 |

---

## 3. 差距分析:为什么「纯静态 manifest + 一条命令」做不到

### G1. 没有「整 workspace 构建/测试」命令(最关键)
`prepare_build` 把 workspace **解析成恰好一个 member**:`-p <name>` 选定
(`src/build/prepare.cppm:318-331`),virtual workspace 无过滤时选**第一个有 bin 的 member、
否则最后一个**(`:332-349`)。源码里对 members 的 `for` 循环都是**选择**,不是**遍历构建**
(`prepare.cppm:320,334`)。**没有 `mcpp test --workspace`**。
→ 即便做成 workspace,也还得有个外层 loop:`for m in members; mcpp -p $m test`(或逐目录 `mcpp test`)。

### G2. `mcpp test` 只有 `tests/*.cpp` 约定 + 退出码
没有 `[[test]]`/`kind="test"`(`manifest.cppm:701-706` 只收 bin/lib/shared;`TestBinary` 是代码里
按 `.cpp` 合成的,`execute.cppm:438-453`),**没有 expected-stdout/expected-exit 声明**,断言只能
编进二进制(gtest 之所以行得通,是 `gtest_main` 失败返非 0)。且 `mcpp test` 只作用于
`find_manifest_root(cwd)` 的单包(`execute.cppm:423`),**不跨 member**。

### G3. 没有 per-OS 依赖、没有 per-OS ldflags/cflags(最影响 smoke 矩阵)
依赖是**扁平** `[dependencies]`/`[dev-dependencies]`/`[build-dependencies]`
(`manifest.cppm:251-253`,`load_deps:987-1057`),**无 `[target.'cfg(...)']` 平台条件依赖**
(`package.platforms` 只是 CI 矩阵提示 `manifest.cppm:41,564`)。`[build].ldflags/cflags` 是**单一全局
数组**(`manifest.cppm:134-136`)——这正是 `smoke_compat_portable.sh:118-157` 要用 bash
`write_build_ldflags` 按 `uname -s` 现生成 `[build] ldflags`(Linux `-ldl -lm`、Darwin `-lm`、
Windows 无)的原因。「Windows 才依赖 openblas」「按平台换 ldflags」**进不了单个静态 manifest**。

### G4. 没有条件化/门控执行
显示门控(`smoke_compat_imgui_window.sh:193-203` 需 `DISPLAY`+env 才跑窗口)、Windows-only、
env 选 code path(`portable:421`)——mcpp **没有「满足某 env/capability 才跑这条 test」** 的门。
`[runtime].capabilities` 存在但不会条件跳过执行。

### B 类:本就在 mcpp 之外(无论如何都要 wrapper)
- 临时 `MCPP_HOME` 隔离(`core:21-26`)、预装 xpkg 软链入 registry(`core:29-47`)、镜像选择
  (`mcpp self config --mirror`)、下载缓存 restore/save 到 `actions/cache`(`portable:92-116`)、
  `.mcpp` 彻底清理。
- **产物断言**:`readelf -d` 查 libX11 链接(`imgui_window:179-191`)、DLL 是否落在 `.exe` 旁并从
  中性 CWD 直跑(`portable:474-485`,本次 0.0.73 新增)。mcpp 没有「断言产物链接/包含 X」「从某
  CWD 跑产物」的设施。
- **recipe 元断言**:grep `.lua` 查 `dlopen_libs`/capabilities(`imgui_window:18-26`)——这是对
  **索引自身**的测试,不在任何消费者构建里。
- 重置内置 `mcpplibs` 索引为本检出(`imgui_module:53-64`)。

---

## 4. 方案:仓库**自指**为「索引 ⊕ workspace」(不另起 ci/ 目录)

把可静态化的 A 类沉成签入的 workspace member,B 类收敛进一个**远比现在小**的驱动。
**关键收敛(相对本文初稿)**:不新建 `ci/workspace/`,而是让**仓库根自己**成为一个
virtual workspace,member **复用现有 `tests/examples/<库>/`**,并用 `[indices] compat = { path = "." }`
**指回自己的 `pkgs/`**——于是同一个仓库**既是包索引**(`pkgs/` 被 xlings 消费)**又是 mcpp 工程**
(workspace 通过本地 path 索引消费自己的 `pkgs/`)。这就是"吃自己的狗粮"。

```
mcpp-index/                          # 仓库根 = 索引 ⊕ virtual workspace
  mcpp.toml                          # [workspace] members=["tests/examples/*"]
                                     # [indices] compat = { path = "." }   ← 自指
  pkgs/c/compat.openblas.lua         # 索引内容(recipe,不动)
  tests/examples/openblas/           # member = openblas 的测试工程(复用现有 examples 约定)
    mcpp.toml                        #   继承根 [indices];[dependencies.compat] openblas=…
    src/blas_ops.cpp                 #   kind=lib:把库能力封成干净接口(matmul2x2 …)
    tests/dgemm.cpp                  #   mcpp test:调接口断言 [19 22 43 50]
    tests/syrk.cpp                   #   同依赖集多个断言点 → 一次 mcpp test 全跑
  tests/examples/compression/  imgui/  glfw/ …
  ci/run.sh                          # 薄驱动:环境隔离 + 缓存 + 平台门控 + 遍历 member + 产物断言
```

- **每库一 member,member 内 src/ + tests/**:`src/` 放把库能力封装出来的接口(`kind=lib`),
  `tests/*.cpp` 调该接口做结果验证——正好吃上 `mcpp test` **一次编一批、退出码汇总**的能力
  (`execute.cppm`),比把断言塞进一个大 `main` 里 `return 1..N` 干净;断言点天然可拆多个文件。
  需要"跑产物看结果"的(如 openblas 直跑)再叠用 `kind=bin` + `mcpp run`。
- **member 粒度 = 依赖集**(对齐现有 smoke 分组:core/archive/compression/imgui…)。
- **自指依赖路由**:根 `[indices] compat = { path = "." }`(仓库根就有 `pkgs/`),member 继承
  (`prepare.cppm:366-402`);现有 `tests/examples/*` 已在用 `path = "../../.."`,**几乎现成**——
  只需加一个根 `mcpp.toml` 把它们登记为 members。
- **驱动 `ci/run.sh`** 只剩 B 类 + 绕开 G1/G3/G4 的最小逻辑:
  1. 环境隔离 / 缓存 / 镜像(B 类,本就该在 CI)。
  2. **遍历 member**(绕 G1):`for m in $(members); do mcpp -p "$m" test || fail; done`(无 `--workspace` 前)。
  3. **平台门控**(绕 G3/G4):Windows 才纳入 `openblas` member;per-OS 差异暂由驱动兜——
     **直到 mcpp 侧 L1 条件依赖落地**(见下)后删掉。
  4. **产物断言**(B 类):`readelf` 链接检查 / DLL 旁置 / 中性 CWD 直跑,留在驱动里。

**净效果**:heredoc 全删、`smoke_compat_*.sh` 的「造工程」逻辑全删;留一个 `ci/run.sh`(约比现
六脚本之和小一个量级),member 可被人类直接 `mcpp test`/`mcpp run` 复现——本身就是更好的回归资产。

### 4a. 与 mcpp 侧设计的关系(独立又相关)
本方案的 member 正是 mcpp 仓
`.agents/docs/2026-06-29-manifest-environment-and-platform-design.md` 里 **L1 条件依赖图的第一个真实
用户**:`tests/examples/openblas/mcpp.toml` 要表达"**Windows 才依赖 compat.openblas、才设
`-llibopenblas`**",这正是 `[target.'cfg(windows)'.dependencies/.build]` + `lazy=true`。在 L1 落地前
这块靠驱动按平台选 member 子集 + 注入 ldflags;L1 落地后**直接删驱动里的平台逻辑**。这与
windows-runtime-dll(0.0.73)那次"mcpp 补能力 → recipe/CI 变简单"完全同构。

### 4b. 配合 §刚落地的 detect 拆分
本仓 CI 现已把 `full` 拆成 `full_linux`/`full_portable`(见
`.github/workflows/validate.yml` 的 `detect`)。workspace 化后,member 与平台的映射更清晰,可进一步
让 detect 直接输出「要跑哪些 member」,驱动据此只构相关 member。

---

## 5. 让驱动继续变薄:mcpp 侧特性路线图

驱动里**只有这几条**是「本可由 mcpp 承担、今天缺」的;补上后驱动还能再瘦:

| 缺口 | 建议的 mcpp 特性 | 收益 |
|---|---|---|
| G1 整 workspace 测 | `mcpp test --workspace` / `mcpp build --workspace`(遍历 members,聚合退出码) | 删掉驱动里的 member 遍历 loop |
| G3 per-OS 依赖 | `[target.'cfg(windows)'.dependencies]`(或 `[dependencies.<os>]`)条件依赖表 | 「Windows 才依赖 openblas」进静态 manifest,删平台门控 |
| G3 per-OS flags | `[build.<os>] ldflags/cflags`(对齐 xpkg recipe 已有的 `mcpp.<os>` per-OS 合并) | 删 `write_build_ldflags` |
| G4 门控执行 | test 级 `required_capabilities`/`skip_if`(无 `DISPLAY` 跳过窗口 test) | 删显示门控 |
| G2 断言表达力 | test 目标支持 expected-exit / expected-stdout 声明 | 简单断言不必写 `main` |
| 产物断言 | (可选)`mcpp test` 后置 hook 或 `[test.assert]`(链接/旁置文件检查) | 把 `readelf`/DLL 旁置检查纳入 mcpp |

其中 **G1 + G3 优先级最高**:这两条补上,smoke 矩阵的「平台差异」和「跑全部」就能进 manifest,
驱动基本只剩「CI 环境隔离 + 缓存 + 产物断言」这类天然 wrapper 的事。

---

## 6. 迁移计划(分阶段,低风险)

1. **P0 — 试点一个 member**:把 `smoke_compat_core` 改成 `ci/workspace/core/`(静态 `mcpp.toml`+
   `main.cpp`,`[indices] compat={path}`),用最小驱动 `mcpp -p core run` 在三平台跑通,与旧脚本**并行**
   验证等价。
2. **P1 — 搬完可静态化的 member**:archive/compression/imgui/glfw/openblas 依次成为 member;驱动统一
   遍历;per-OS 差异暂留驱动(写 `[build]`/选 member)。删对应 `smoke_compat_*.sh`。
3. **P2 — 收敛驱动**:把环境隔离/缓存/镜像/产物断言集中到单个 `ci/run.sh`;`validate.yml` 调它;
   detect 输出 member 选择。
4. **P3 — 推 mcpp 特性**(§5,与 mcpp 仓协同):优先 `--workspace` 与 per-OS 依赖/flags;每落地一个就从
   驱动删一段。windows-runtime-dll(0.0.73)已示范「mcpp 补能力→ recipe/CI 变简单」的闭环。

每阶段都**保留旧脚本到新路径验证等价后再删**,避免一次性失去覆盖。

---

## 7. 取舍与结论

- **可行且值得**:workspace + 本地路径索引是地道 mcpp 用法,能消灭 heredoc、让 smoke 工程变成可复现
  的签入资产,并顺带「吃自己的狗粮」(用 mcpp 的 workspace 测 mcpp 的索引)。
- **但不能「零脚本」**:G1(无整-workspace 命令)、G3(无 per-OS 依赖/flags)、G4(无门控执行)和 B 类
  (环境隔离/缓存/产物断言/元断言)决定了**一定还有一个薄驱动**。声称能完全去掉 `.sh` 是不准确的。
- **推荐路径**:走 §6 分阶段——先静态化 member + 薄驱动拿掉大头复杂度;再用 §5 的 mcpp 特性
  (优先 `--workspace` + per-OS 依赖/flags)把驱动逐步削到只剩 CI 环境编排。

> 关联:本仓 `.github/workflows/validate.yml`(detect 拆分 + 下载缓存,2026-06-29 已落);mcpp 仓
> `.agents/docs/2026-06-29-windows-runtime-dll-deployment-and-openblas.md`(per-OS 能力如何让 recipe 变简单的先例)。

---

## 8. 实现状态(2026-06-30 落地)

自参照 workspace 的**首个可签入切片**已落地(对应 §6 的 P0 + P1 起步,依赖 mcpp 0.0.77 的 L1
`[target.'cfg(...)']` per-OS 依赖/flags + windows-runtime-dll 部署):

- **`mcpp.toml`(仓根)**:虚拟 `[workspace]`,`members` 列出 `tests/examples/{cjson,eigen,
  nlohmann.json,openblas}`——即真实索引的逐库示例本身就是 workspace 成员。仓 = 索引 ⊕ 消费索引的
  workspace(双视角)。
- **`tests/run_workspace.sh`**:薄驱动。从仓根 `mcpp.toml` 的 `[workspace].members` 解析成员(单一
  事实源,无硬编码),逐个 `mcpp build && mcpp run`;每个成员经本地 `[indices]` path 解析**本仓
  pkgs/** 的真实 recipe。
- **`tests/examples/openblas/`**:L1-cfg 消费者示范。`[target.'cfg(windows)'.dependencies.compat]
  openblas` + `[target.'cfg(windows)'.build] cxxflags=["-DHAVE_OPENBLAS=1"]`;Windows 走 `cblas_dgemm`
  断言 `[19 22; 43 50]`,linux/macos 为 no-op(openblas 不被拉取)。证明 per-OS 依赖按**解析目标
  三元组**门控。
- **`validate.yml`**:`detect` 增 `workspace` 输出(push/schedule 全跑;PR 命中仓根 `mcpp.toml`、
  `tests/run_workspace.sh`、或任一 `tests/examples/*` 成员时触发);新增 `smoke-workspace`(ubuntu)
  跑驱动。`MCPP_VERSION` 升至 0.0.77。

**尚未收敛**(留待 §6 P2/P3):per-OS 成员差异仍可由 cfg 表承担而非驱动;环境隔离/缓存/产物断言仍在
各 smoke 脚本;`--workspace` 单命令(G1)仍是 mcpp 侧待加能力——当前驱动按成员循环。旧 smoke 脚本
**保留**,与 workspace 并行覆盖,等价验证充分后再逐个迁移/删除。
