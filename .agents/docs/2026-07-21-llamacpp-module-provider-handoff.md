# llama.cpp 模块 Provider 适配交接

日期: 2026-07-21

受众: 没有此前对话上下文、准备接手实现的任务 agent

## 1. 先看结论

目标是交付一个以 `import llama;` 为唯一公共接口的 llama.cpp 模块包。CPU 是
不可关闭的默认后端，Metal 是 macOS ARM64 上的单选 accelerator。首版不支持
CUDA，也不承诺公共 header 消费。

当前只完成了分析、设计和逐任务实施计划。没有任何正式实现进入 mcpp、
`llamacpp-m` 或 mcpp-index，也没有创建实现 PR、tag、release 或 mirror。

实现必须按以下依赖顺序进行:

```text
mcpp backend 选择硬错误
    -> mcpp-index 内部 CPU 包图
    -> llamacpp-m 公共模块门面
    -> mcpp-index Metal provider 与公共描述符
    -> 三平台准入和发布
```

不要直接从 Metal 描述符或公共 `llamacpp` 描述符开始。第一个实现任务是 mcpp
对未知 `backend=` 选择的硬错误能力。

## 2. 当前 Git 与目录状态

### 2.1 计划 worktree

| 项目 | 当前值 |
|---|---|
| worktree | `/Users/cltx/projects/mcpp/.worktrees/llamacpp-module-provider-design` |
| 分支 | `docs/llamacpp-module-provider-design` |
| fork remote | `origin = https://github.com/wellwei/mcpp-index.git` |
| 官方 remote | `upstream = https://github.com/mcpplibs/mcpp-index.git` |
| 计划基线 | `origin/main@0b0a98f3e82b05328be944bda3f91010344e2840` |
| 设计提交 | `d45e19f` |
| 实施计划提交 | `c9892d3` |
| fork 分支 | `origin/docs/llamacpp-module-provider-design` |

本交接文档提交后，远端分支头会晚于 `c9892d3`。用以下命令读取实际状态，不要
把表中的计划提交误当作当前分支头:

```bash
cd /Users/cltx/projects/mcpp/.worktrees/llamacpp-module-provider-design
git status --short --branch
git rev-parse HEAD origin/docs/llamacpp-module-provider-design origin/main
git log --oneline --decorate -5
```

该 worktree 只保存设计和计划，不用于实现。`.agents/docs/` 下这些规划文件不得
进入上游包实现 PR。

### 2.2 其他 checkout

- `/Users/cltx/projects/mcpp/mcpp` 是 mcpp 仓库，记录基线为
  `af25d18ee2a97d17fb57bae86232e6f61560343d`，版本 `0.0.101`。
- `/Users/cltx/projects/mcpp/mcpp-index` 当前是 Asio 工作分支
  `refactor/asio-module`。不得在这个 checkout 上实现 llama，也不得重置、变基或
  删除它。
- `/Users/cltx/projects/mcpp/llamacpp-m` 尚不存在。模块计划要求先建立本地仓库，
  不自动创建 GitHub 仓库或 remote。
- llama 的 mcpp-index 实现 worktree 尚不存在。执行到该阶段时，从刷新后的
  fork `origin/main` 创建独立 `feat/llamacpp-module-provider` worktree。

## 3. 已有证据与证据边界

已经确认:

- llama.cpp 快照为 tag `b10069`、commit
  `178a6c44937154dc4c4eff0d166f4a044c4fceba`。
- 源码归档 SHA-256 为
  `293a7c65a11e2203c5468a06d0d0e8d21dfff16ad08712b16c61efbe0d93e097`。
- 固定 GGUF fixture 为 `stories15M-q4_0.gguf`，大小 `19077344`，SHA-256 为
  `66967fbece6dbe97886593fdbb73589584927e29119ec31f08090732d1861739`。
- 原型提交 `64c5d2e` 验证过 CPU 方向，`42f36d6` 验证过 Metal 方向。它们只是
  源集合和编译问题的证据，不是待迁移的正式包契约。
- 临时五包描述符曾使用 mcpp `0.0.101` 通过 Linux、macOS、Windows 的
  `xpkg parse --all-os`。

最后一项只证明描述符语法和 OS overlay 可解析，不证明归档获取、实际编译、
链接、模块导入、模型 decode、Metal shader 嵌入或 GPU offload。接手者必须按
计划重新建立当前 checkout 上的验证证据。

## 4. 不可变公共契约

普通消费者只看到:

```toml
[dependencies]
llamacpp = "0.1.0"
# 或在 macOS ARM64 上:
# llamacpp = { version = "0.1.0", backend = "metal" }
```

```cpp
import llama;
```

选择语义:

| 配置 | 结果 |
|---|---|
| 省略 `backend` | CPU |
| `backend = "cpu"` | CPU |
| `backend = "metal"` | CPU + Metal，仅 macOS ARM64 |
| `backend = "cuda"` | 首版硬错误 |
| 拼写错误或不支持平台 | 硬错误，不得回退到 CPU-only 成功 |

其他硬约束:

1. 不公开承诺 `#include <llama.h>`，也不在普通文档中暴露 `compat.*`。
2. CPU 始终存在。Metal 是 accelerator，不是 CPU 替代品。
3. 首版 backend 是单选值，不支持数组或多个 accelerator。
4. 不导出 `llama-cpp.h`、GGML API、预处理宏或工具程序。
5. 模块导出所有经审阅的非 deprecated 公共 llama API，以及签名所需的最小
   GGML 类型。公共宏常量改为显式类型化 C++ 常量。
6. 受支持消费者不得混用 `import llama;` 与 `#include <llama.h>`。

## 5. 五包边界

```text
llamacpp                         公共 Form A 模块门面
    `-- compat.llamacpp          llama 实现 + GGML registry
            |-- compat.ggml-base GGML 公共实现
            |-- compat.ggml-cpu  必需 CPU backend
            `-- compat.ggml-metal 可选 Metal provider
```

| 包 | 所有权 |
|---|---|
| `llamacpp` | 独立 `llamacpp-m` release，只提供模块门面和 feature forwarding |
| `compat.ggml-base` | upstream `ggml-base` 源集合 |
| `compat.ggml-cpu` | upstream `ggml-cpu`、架构源码、llamafile、Windows `advapi32` |
| `compat.llamacpp` | GGML registry/dynamic loader、llama 和显式模型 TU |
| `compat.ggml-metal` | 六个 Metal TU、framework、shader 嵌入和 `ggml.accelerator` capability |

Metal 的解析和注册路径必须是:

```text
llamacpp/backend-metal
  -> compat.llamacpp/backend-metal
  -> exact compat.ggml-metal@b10069 dependency
  -> provides ggml.accelerator
  -> requires ggml.accelerator
  -> GGML_USE_METAL only on ggml-backend-reg.cpp
  -> ggml_backend_metal_reg() is retained and registered
```

Capability 只校验已经解析出的依赖图，不负责从 index 自动发现包。因此 feature
必须显式拉取具体 provider。`GGML_USE_METAL` 必须落在 registry TU，不能只定义
在 provider 包。

Metal provider 的 `build.mcpp` 自行把 shader 输入嵌入 Mach-O section。消费者
不安装 `default.metallib`，不设置 `GGML_METAL_PATH_RESOURCES`，构建失败也不得
静默回退 CPU。

## 6. 计划索引

按以下顺序阅读:

1. [总体设计](2026-07-21-llamacpp-module-provider-design.md): 公共契约、包边界、
   provider 语义、失败规则和 upstream 更新策略。
2. [总实施计划](2026-07-21-llamacpp-module-provider-implementation-plan.md): 三仓职责、
   P0-P4 顺序、跨仓门禁和最终验证命令。
3. [mcpp backend 硬错误计划](2026-07-21-mcpp-backend-selection-hard-error-plan.md):
   第一个必须完成并发布的前置能力。
4. [`llamacpp-m` 模块门面计划](2026-07-21-llamacpp-m-module-facade-plan.md):
   Form A 仓库、API 生成器、模块单元、测试和 tag 门禁。
5. [mcpp-index 五包图计划](2026-07-21-mcpp-index-llamacpp-package-graph-plan.md):
   snapshot 工具、四个内部包、公共描述符、consumer、CI 和发布准入。

子计划中的文件列表、测试内容和命令是实现权威来源。本交接只决定进入顺序和
停止条件。如果 live `main`、workflow 或 mcpp schema 已变化，先更新审计结论，
不要机械执行旧命令。

## 7. 执行阶段与停止条件

### P0: 证据与 mcpp 前置能力

1. 刷新三个仓库，检查重复 issue、PR 和 upstream 变化。
2. 在 mcpp-index 实现分支建立确定性的 `b10069` snapshot 报告，不修补旧单体包。
3. 在 mcpp 独立 worktree 先写失败测试，再实现未知 dependency backend 的硬错误。
4. mcpp PR 合并、全平台 CI 通过并正式发布后，才确定实际最低版本。计划中的
   `0.0.102` 只是基线期预期，不能预填为事实。
5. 建立 mcpp-index staging 分支供 `llamacpp-m` 的未发布测试使用。

停止条件: 有重复 PR、当前行为或 schema 已改变、mcpp 前置版本未发布、归档 tag
移动或 SHA 不匹配。

### P1: 内部 CPU 图

新增 `compat.ggml-base`、`compat.ggml-cpu`、`compat.llamacpp`，先用内部
header-based smoke 在 Linux x86-64、macOS ARM64、Windows x86-64 冷缓存完成
真实模型 load 和一次 decode。

停止条件: 任一原生平台失败、模型缺失、Windows 未链接 `advapi32`、显式模型 TU
未完整进入构建。

### P2: 公共模块门面

本地创建 `llamacpp-m`，生成并人工审阅 API 导出，使用 staging index 验证三平台
`import llama;`。保持 release candidate 未打 tag。

停止条件: 测试源码包含 llama/GGML header、宏泄漏、deprecated API 混入、生成
结果不确定或 staging 依赖无法重现。

### P3: Metal provider

增加 Metal 包、capability 绑定、feature forwarding、registry 宏和 shader 嵌入。
macOS ARM64 测试必须证明嵌入 shader 被使用、至少一层实际 offload，并完成 decode。

停止条件: 只有链接成功而无注册证据、使用运行时 shader 文件、Metal 请求失败后
CPU-only 成功、缺少真实 offload 证据。

### P4: 发布准入

从隔离缓存运行三平台 CPU、macOS ARM64 Metal、无效 backend 和不支持平台负向
用例。全矩阵通过后，获得单独授权再 tag `llamacpp-m`，校验 release archive，
加入公共 Form A 描述符并完成 mcpp-index 准入。

任何一个受支持平台或 backend 为红时，整组包都不发布。

## 8. 新 agent 的第一批操作

先在计划 worktree 确认事实，不做修改:

```bash
cd /Users/cltx/projects/mcpp/.worktrees/llamacpp-module-provider-design
git fetch origin main
git fetch upstream main
git status --short --branch
git rev-list --left-right --count upstream/main...origin/main
git log --oneline origin/main..HEAD
```

然后阅读仓库 `AGENTS.md` 和本交接第 6 节前三份计划。执行计划时使用
`superpowers:subagent-driven-development` 或 `superpowers:executing-plans`，并按
`superpowers:test-driven-development` 先建立失败测试。

第一个代码 worktree 按 mcpp 子计划创建:

```bash
cd /Users/cltx/projects/mcpp/mcpp
git fetch origin main
git status --short --branch
git rev-parse origin/main
gh issue list -R mcpp-community/mcpp --state open \
  --search "backend unknown feature" --limit 20
gh pr list -R mcpp-community/mcpp --state open \
  --search "backend unknown feature" --limit 20
git worktree add ../mcpp-backend-hard-error \
  -b fix/backend-selection-hard-error origin/main
```

进入新 worktree 后，从
`2026-07-21-mcpp-backend-selection-hard-error-plan.md` 的 Task 2 开始红灯测试。
不要先改 `src/build/prepare.cppm`。创建 GitHub issue、push 或 PR 仍需单独授权。

mcpp-index 执行 worktree 只在 P0 对应步骤到达时创建:

```bash
cd /Users/cltx/projects/mcpp/mcpp-index
git fetch origin main
git worktree add ../mcpp-index-llamacpp-provider \
  -b feat/llamacpp-module-provider origin/main
```

创建前先确认该路径和分支不存在，并保留当前 Asio checkout。不要把 docs 分支
merge 或 cherry-pick 到实现分支。

## 9. 版本与后续 upstream 更新

首版版本关系固定为:

```text
llamacpp 0.1.0
    `-- compat.llamacpp b10069
            |-- compat.ggml-base b10069
            |-- compat.ggml-cpu b10069
            `-- compat.ggml-metal b10069
```

公共包用 SemVer，内部包用 llama.cpp `b` tag，四个内部包必须精确锁定同一快照并
原子更新。

当前 mcpp `0.0.101` 的 xpkg recipe 和 dependency map 不是 version-scoped。首版
内部描述符只能登记 `b10069`。加入第二个 upstream 快照前必须先完成并发布以下
方案之一:

1. 首选: xpkg 支持 version-scoped `mcpp`/dependency overlay，保留稳定包身份。
2. 备选: 使用 snapshot-qualified 内部包身份，由每个公共 release 锁定对应 cohort。

在该门禁解决前，不得仅追加新 `xpm` tag 并改写共享源列表或依赖，否则历史内部
版本 fresh resolution 会被新 recipe 覆盖。

每次候选 upstream 更新先运行 snapshot audit，只生成报告，不自动改 descriptor。
人工审阅以下变化:

- `llama.h` 公共 API 和必要 GGML 类型;
- `GGML_BACKEND_API_VERSION`;
- base、CPU、Metal、registry、llama 和模型 TU 的新增、删除、改名;
- registry 宏、注册函数和链接保留路径;
- 平台库、framework、编译宏和 dialect 例外;
- Metal shader 输入和生成方式。

公共 API 不变的实现更新升 patch，API 加法或新增正式 backend 升 minor，删除或
改变已导出 API 升 major。任一平台失败时不发布新 cohort 的任何包。

## 10. 验收与外部操作边界

最终验收至少要求:

1. 普通 consumer 只依赖 `llamacpp`，源码只使用 `import llama;`。
2. Linux x86-64、macOS ARM64、Windows x86-64 从冷缓存完成 CPU decode。
3. macOS ARM64 使用嵌入 shader 完成真实 Metal offload decode。
4. CUDA、拼写错误和不支持平台在产生 CPU-only 成功产物前失败。
5. 四个内部包使用同一快照、同一归档字节和精确依赖。
6. workflow 固定到已经发布且包含 backend 硬错误的 mcpp 版本。
7. descriptor、snapshot、model checksum、负向契约和必需 CI 全部通过。

当前用户授权只覆盖把设计、计划和本交接文档推送到 fork 的 docs 分支。以下动作
没有被授权:

- 创建或修改 GitHub issue;
- 创建 `mcpplibs/llamacpp-m` 远端仓库;
- 推送任何实现分支;
- 创建或更新 PR;
- 创建 tag、release 或 mirror;
- 推送 upstream 或直接修改任何 `main`。

每到一个外部动作边界都必须重新请求明确授权。维护者负责合并和正式发布。
