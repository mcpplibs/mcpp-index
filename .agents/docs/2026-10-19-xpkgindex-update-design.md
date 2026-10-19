# xpkgindex-update：两个索引共用的声明式版本更新工具

日期：2026-10-19  
状态：实现联调中。工具开发 PR：openxlings/xpkgindex-update#1；mcpp 为首个 draft CI 接入仓库。

## 1. 目标与结论

项目使用 `openxlings/xpkgindex-update`；CLI 命名为 `xpkgindex-update`，Action 使用
`openxlings/xpkgindex-update@v1`。它同时服务 `openxlings/xim-pkgindex` 与
`mcpplibs/mcpp-index`，只做现有资源的版本发现、描述符更新和 PR 提交。

核心约定：

- 包通过 `package.extensions.autoupdate` 显式参与；安装时忽略该扩展。
- 工具只追加不存在的新版本；已有版本块逐字保留，包括 URL、镜像、SHA256、配置与注释。
- 禁止 replace、覆盖、删除、重排或自动回填已有版本；只开 PR，人工决定是否合并。
- 一个公共实现，CLI 与 Action 调用相同逻辑；两个索引用内部 adapter 处理结构差异。
- 首版不自动 mirror，不上传、不覆盖镜像资产；新版本可以直接引用 GitHub，旧版本的镜像不动。
- 候选版本必须得到实际验证，不能把仍然测试旧版本的绿色 CI 当成升级验证。

本设计承接 [mcpp-index #541](https://github.com/mcpplibs/mcpp-index/issues/541)，参考
xim-pkgindex 已有的 `package.ci`、中央扫描、版本添加和自动 PR 实现。

## 2. 已核对的现状

本次分析核对的远端版本：

- mcpp-index：`981a4f228b1ee75251dbd14748a80d5adfc2191c`。
- xim-pkgindex：`14c71d455db7ab623658bae454773d1c7fafb500`。

xim 已有：

- [中央策略](https://github.com/openxlings/xim-pkgindex/blob/14c71d455db7ab623658bae454773d1c7fafb500/.github/xpkg-ci.yml)
  与 [扫描工具](https://github.com/openxlings/xim-pkgindex/blob/14c71d455db7ab623658bae454773d1c7fafb500/tools/xpkg_ci.py)。
- [版本更新器](https://github.com/openxlings/xim-pkgindex/blob/14c71d455db7ab623658bae454773d1c7fafb500/.github/scripts/version-check.py)
  与 [自动 PR workflow](https://github.com/openxlings/xim-pkgindex/blob/14c71d455db7ab623658bae454773d1c7fafb500/.github/workflows/version-bump.yml)。

mcpp 的两个额外约束：

- [validate.yml](https://github.com/mcpplibs/mcpp-index/blob/981a4f228b1ee75251dbd14748a80d5adfc2191c/.github/workflows/validate.yml)
  在 PR 阶段实际下载 CN 资源并核对 SHA256，引用镜像前镜像就必须可用。
- [zlib 示例](https://github.com/mcpplibs/mcpp-index/blob/981a4f228b1ee75251dbd14748a80d5adfc2191c/tests/examples/zlib/mcpp.toml)
  固定依赖 `1.3.2`。添加新版本而不调整验证依赖，不能证明新版本可用。

因此复用 xim 的职责划分与测试经验，不直接复制现有调度和文本修改实现。

2026-10-19 对本地 checkout 的只读词法盘点发现，61 个描述符至少含一处字符串形式的直接
GitHub URL。这不是远端最终接入数量：其中包含历史条目、混合镜像、commit 快照及特殊 tag。
实施时必须在最新 mcpp-index 基线上重新生成逐包清单，不能把“61”当成已确认覆盖数。

## 3. 首版范围

### 3.1 支持

- 优先扫描 GitHub 已发布的 stable releases，排除 draft、prerelease；无匹配 release 的
  tag-only 仓库可查询 tags，按声明模板与版本语法筛选。tag 不能提供稳定性标记，报告标注发现来源。
- 版本支持数字点分（包括 calver）、b 编号，以及明确排序的单字母稳定后缀；不猜测任意字符串的版本关系。
- tag 由固定前缀、`${version}`、固定后缀组成，例如 `v${version}`。
- 按整数分段比较版本，缺少的尾段按零比较；等价但拼写不同的候选视为歧义并报错。
- 下载 URL 是显式模板；资源已经发布；每个安装资源使用单个字符串 SHA256。
- 一个包已声明的平台整体更新；不同平台可使用不同 URL。
- URL 是直连字符串，或已有 GLOBAL/CN 两个镜像的表。
- mcpp-index 为首个真实接入仓库；目标是为直接使用 GitHub 资源的包全部补齐更新声明，
  并为每一个目标给出实际扫描结果，不用“只选容易的包”代替完整覆盖。
- mcpp adapter 处理显式平台版本条目；xim adapter 同时处理已有 `latest.ref`。
- xim 已有 `xpm.source` 时，仅在其运行时展开结果与更新模板一致时写入对应新版本哈希。

### 3.2 不支持

- 自动推进 commit 快照、任意 tag、预发布版本和无明确排序的发行版后缀。
- 自动回填历史 release、清理旧版本、升级依赖约束、批量联动多个包。
- 架构分发表、per-arch SHA256、`XLINGS_RES`/`res_versioned` 等额外资源形态。
- 需要修改 shim、sources、generated_files、安装 hook 或 build.mcpp 的更新。
- 镜像上传、资源重打包、生成绑定、自建二进制、自动合并。

这些限制不阻止公共工具后续扩展，但首版不以增加 provider、脚本 hook 或复杂 DSL 解决例外。
对于首个 mcpp 覆盖目标中发现的例外，必须逐包列出并补齐设计或实现，不能静默省略。
commit 快照缺少版本到新 commit 的规则时，只能报告需要决策，不能擅自跟随默认分支。
xim 的复杂包可以暂留原有工具，不要求两仓同时迁完。

## 4. 包字段：extensions.autoupdate

采用复数且拼写为 `extensions`。它是维护扩展的容器，不参与运行时安装解析。

最小配置：

```lua
package = {
    repo = "https://github.com/madler/zlib",

    extensions = {
        autoupdate = {
            tag = "v${version}",
            url = "https://github.com/madler/zlib/archive/refs/tags/${tag}.tar.gz",
        },
    },

    xpm = {
        -- 已发布条目仍然是安装器读取的事实来源。
    },
}
```

首版只有 `tag`、`url` 两个字段，均必填；工具对 autoupdate 内的拼写错误做 lint。
其他工具的 extensions 子字段与安装器不认识的字段仍按现有规则忽略，不扩大严格检查范围。

| 字段 | 含义 |
|---|---|
| `tag` | 一个且仅一个 `${version}`；其余字符按字面量匹配，不是正则或 Lua pattern |
| `url` | 所有已有平台共用的资源模板，或平台到资源模板的映射 |

允许的占位符为 `${version}`、`${version:dash}`、`${tag}`。dash 只把点分版本转换为横线分隔，用于 FreeType。其他占位符报错。
`${tag}` 保留 API 返回的原始拼写，`${version}` 是从 tag 提取的版本。
优先从显式 GitHub 下载模板确定查询仓库；模板不指定 GitHub 仓库时回退 `package.repo`。首版不增加 provider/repo 覆盖字段。

不同平台的写法：

```lua
extensions = {
    autoupdate = {
        tag = "v${version}",
        url = {
            linux = "https://example.org/${tag}/foo-linux.tar.gz",
            macosx = "https://example.org/${tag}/foo-macos.tar.gz",
            windows = "https://example.org/${tag}/foo-windows.zip",
        },
    },
}
```

平台值也可以是 `{ GLOBAL = "...", CN = "..." }`；所有平台共用的 GLOBAL/CN 表也可直接
作为 `url`。解析器按键集合区分平台表与镜像表，混合写法拒绝。
GLOBAL/CN 必须下载后哈希一致，工具不创建镜像。

不使用 `enabled`：无字段即手工维护；存在合法字段即参与。
不使用 `mode`、`prerelease`、`interval`：首版固定 add、stable，调度留在仓库 workflow。
配置不合法或形态不支持是可见错误，不伪装为未参与。

### 4.1 已确认的兼容性约定

维护者已确认其他消费者会忽略不认识的字段，extensions 不影响现有安装行为。
采用这一约定直接设计与接入，不把修改安装器 schema 或提升客户端版本作为前置任务。
保留解析回归 fixture，确认新增元数据前后既有版本的解析结果一致。
不在 `mcpp` 或 `xpm` 安装段中新增维护工具专用字段。

## 5. 工具、Action 与仓库配置

### 5.1 CLI

```bash
xpkgindex-update check --output plan.json
xpkgindex-update apply --plan plan.json --package compat:zlib
xpkgindex-update propose --plan plan.json
```

- `check`：本地解析、发现候选、下载校验，输出完整计划；不改描述符、不创建 PR。
- `apply`：消费已确定计划，在本地生成最小补丁，便于维护者复现；不访问 GitHub 写接口。
- `propose`：消费计划，按包生成补丁与分支并开 PR；不重新查询 latest。
- 可用 `--package` 缩小范围；身份使用 namespace + name，缺省命名空间使用索引的既定规则。

### 5.2 Action

同仓库根目录提供 composite Action，安装固定版本的 Python 工具并调用同一个 CLI。
不维护第二套 Action 业务逻辑；首版不要求额外运行服务或数据库。

拟议调用：

```yaml
on:
  schedule:
    - cron: "17 2 * * *"
  workflow_dispatch:

concurrency:
  group: xpkgindex-update
  cancel-in-progress: false

jobs:
  update:
    runs-on: ubuntu-latest
    permissions:
      contents: read
    steps:
      - uses: actions/checkout@v4
        with:
          persist-credentials: false
      - uses: openxlings/xpkgindex-update@v1
        with:
          mode: propose
          token: ${{ secrets.UPDATE_TOKEN }}
```

这是正式发布后的接口草案。开发 Action 已在 draft PR 实现，开发联调使用完整 commit SHA，
不提前发布或移动 v1；composite Action 从自身 GITHUB_ACTION_PATH 执行该提交的源码，
不能安装一个与开发提交无关的已发布 PyPI 版本。
输入只有 `mode`（check/propose）、`token`（propose 必需）、可选 `package`。
默认从当前 workspace 读取配置，上传计划和汇总到 workflow artifact/summary。
`mode: propose` 内部先 check，再消费同一份计划；手动 CLI 可以拆开执行。

### 5.3 索引级配置

```yaml
# .github/xpkgindex-update.yml
version: 1
adapter: mcpp-index  # 或 xim-pkgindex；显式指定，不猜仓库名
max_prs: 3
```

首版只暴露这三个字段。每日调度直接写 workflow，不引入第二个 cron、包扫描周期或共享扫描状态。
请求预算、最大下载量、超时、有限重试作为工具的固定保护值，在报告里公开。
同一上游仓库只查一次，同一 URL 只下载一次；缓存失效不改变结果。
选取待创建 PR 的包使用确定性顺序；已有待处理 PR 的包不占新 PR 名额。

## 6. 一条链路与最小计划

```text
读取指定测试基线或默认分支的合法 opt-in 包
  → 查询 GitHub stable releases 并按 tag 模板过滤
  → 选择严格高于当前版本的最高候选
  → 锁定原始 tag、commit 与资源 URL
  → 下载、校验归档、计算 SHA256；必要时验证 CN
  → 生成 plan
  → adapter 原子生成补丁
  → 开发联调创建 draft PR；正式更新创建普通 PR
  → 索引原有 CI 验证候选版本
  → 人工 review / merge
```

候选发现不能仅依赖 GitHub `releases/latest`。release/tag 查询均有界分页，并在无法确认候选时明确报告
`discovery-incomplete`；不能用截断结果宣称已是最新。无匹配 tag 时同样给出明确诊断。

计划只包含必要证据：

```json
{
  "format": 1,
  "base_commit": "<index commit>",
  "packages": [{
    "id": "compat:zlib",
    "path": "pkgs/c/compat.zlib.lua",
    "current": "1.3.2",
    "candidate": "1.3.3",
    "tag": "v1.3.3",
    "upstream_commit": "<peeled commit>",
    "assets": [{
      "platforms": ["linux", "macosx", "windows"],
      "url": "https://example.org/v1.3.3.tar.gz",
      "size": 123456,
      "sha256": "<64 hex>"
    }]
  }]
}
```

GLOBAL/CN 情况记录两条实际 URL 和各自验证结果，不只记录展开模板。
计划不可提供任意写入路径：apply 必须重新解析身份、确认路径在 pkgs 内，并检查基线一致。
下载内容必须与计划哈希一致；tag 移动、资源内容变化或目标已更新时拒绝旧计划并要求重查。
首版不创建额外的 release manifest 发布系统；计划作为 PR 附件/Actions artifact 即可。

## 7. 两个 adapter 的职责

### 7.1 公共规则

- 先验证所有目标平台、资源及改动位置，再一次性写文件；失败不能留下半个包的更新。
- 平台集合以当前描述符为准；url 平台映射必须完整覆盖，禁止只更新 Linux。
- 当前版本从已有合法版本条目确定；有 `latest.ref` 时要求其指向存在的条目且各平台一致。
- 无 latest 时按数字点分规则确定最高版本；平台版本集合分歧则拒绝自动处理。
- 旧版本块必须逐字不变；同版本存在时跳过，不下载后替换其 URL、哈希或 mirror。
- 候选必须严格高于各平台当前最高版本；已有版本不自动补镜像、不修复或补齐缺失平台。
- 候选仅存在于部分平台时报告 existing-version-conflict，交由人工处理，避免变相覆盖。
- 既有版本块保存源码摘要；生成补丁后比较摘要与块顺序，并核对语法树仅新增目标版本。
- 不修改 mcpp 构建字段、依赖、安装 hook、README 或工具链 pin。
- 描述符使用能识别 Lua 字符串、长字符串和注释的语法工具读取并按源码范围插入。
  首版仅自动编辑可静态确定的字面量结构；动态拼接、循环生成等写法报告不支持。
- 不执行 Lua 安装脚本；不把未知复杂结构猜成可更新结构。

### 7.2 mcpp-index

为各平台添加完整版本块：版本 key、显式 URL、SHA256。
已有版本的 GLOBAL/CN 路由完全保留。新版本使用 extensions.autoupdate.url 声明的来源，
可以为 GitHub 直连字符串；不能通过复制旧版本模板误带尚不存在的 CN URL。
禁止整表重新序列化；插入新块不能重写、重排旧版本。
复用现有 lint、跨平台检查、镜像检查和受影响示例选择。

### 7.3 xim-pkgindex

为各平台添加新版本块。latest.ref 是别名，不是版本块；是否允许工具更新这个别名留待第二轮
review 决定，在决定前首版 mcpp 接入不依赖任何别名改写，xim apply 暂不启用。
已有 source 模板时先证明运行时展开 URL 与计划相同，再遵循原形态写入哈希；禁止悄悄切换来源。
首版不覆盖原更新器支持的全部历史资源形态；不支持的包保留旧工具且不得双重调度。

## 8. 验证候选版本：交给索引 CI，但必须补齐

工具不增加每包 `verify_member`，不执行描述符声明的 shell hook。
验证入口继续由各仓现有测试组织维护。

mcpp 接入前增加 CI 测试辅助步骤：

1. 比较 PR 与基线，识别新增的包版本。
2. 选择能覆盖该包的既有示例，在临时 workspace 中将对应直接依赖固定为候选版本。
3. 在该包支持的既有平台/工具链矩阵中编译、运行；保留正常 lint 与回归测试。
4. 检查解析结果确认候选实际被选中；不能仅根据命令退出码判断覆盖成功。
5. 无覆盖入口、依赖约束冲突或版本未被选中时，候选验证失败，不伪造通过。

xim 接入时确认包测试实际安装 `${candidate}`，不误测已安装版本或旧 latest。
对全部 GitHub 直连目标补齐声明，测试入口缺失作为明确的 CI 覆盖缺口处理，不能偷偷漏掉包。
新增元数据但没有真实新版本时，运行现有版本回归，并另外选择真实更新或历史基线进行候选路径测试。
新版本验证通过是合并条件，不要求开 PR 前
在 Action 所在的 Ubuntu runner 上完成所有平台测试。

## 9. PR、失败与凭证

### 9.1 PR

- 默认 base 为当前索引默认分支；分支按规范化包身份和候选版本确定，避免命名空间碰撞。
- 每个包最多一个打开的自动更新 PR；已有 PR 时报告 pending，不连续堆积多个版本 PR。
- push 成功但 PR 创建失败时，下次补建 PR；不能仅凭分支存在就永久跳过。
- 人工关闭且未合并的同版本 PR 不自动重开，报告 dismissed；可手动明确重试。
- 正式更新 PR 只提交目标包文件，附原始 tag、commit、下载 URL、哈希、旧/新版本及验证入口说明。
- 首次接入 draft PR 可以包含全部目标包的扩展声明、仓库配置及 CI 集成；与正常逐包更新 PR 区分。
- 不自动合并；分支保护要求的 CI 和人工 review 正常生效。

### 9.2 状态

| 状态 | 含义 | 最终任务结果 |
|---|---|---|
| up-to-date | 无更高的匹配版本 | 成功 |
| update-ready | 新版本资源已完整验证 | check 成功，propose 创建 PR |
| pending / dismissed | 已有 PR / 人工关闭过该版本 | 成功并列明 |
| waiting-assets | 已发现版本，但上游或 CN 资产尚未发布 | 成功并显著列明，下次重试 |
| error | 无效声明、API 故障、哈希冲突、验证或提交失败等 | 处理其余包后最终非零 |

只有明确的资产不存在/尚未发布归为 waiting-assets；API 403、限流、超时、下载中断不可
伪装成等待资源。长期等待在每次 summary 中持续列出；首版不自动开 issue，避免增加写权限和噪声。
无 autoupdate 的包完全不访问上游，不作为错误。

### 9.3 凭证

建议使用 GitHub App installation token，已有 PAT 可过渡。读取扫描与写分支/PR 分阶段，
token 仅交给所需 GitHub 请求及 git 认证；不传给任意下载域名或安装测试。
下载仅允许公开 HTTPS 资源，拒绝私网目标和携带认证信息的 URL，限制重定向与响应大小。
正式动作在默认分支可信 workflow 运行；开发期用维护者控制的同仓 draft PR 和固定工具提交。
draft 的 pull_request CI 运行 check/apply 验证，不使用写凭证递归创建 PR。
第一次 draft PR 由维护者或已有授权的提交动作创建；不用 pull_request_target 执行 PR 代码。

当前 GitHub 文档说明：GITHUB_TOKEN 创建/更新的相关 PR 事件可以产生等待人工批准的 CI；
GitHub App/PAT 可使其自动运行。不能沿用“GITHUB_TOKEN 创建 PR 绝不触发 CI”的绝对表述。
参见 [GitHub workflow 触发规则](https://docs.github.com/en/actions/how-tos/write-workflows/choose-when-workflows-run/trigger-a-workflow#triggering-a-workflow-from-a-workflow)。

## 10. 实现与迁移

拟议项目结构：

```text
action.yml
src/xpkgindex_update/
  cli.py
  github.py
  manifest.py
  lua_edit.py
  pull_request.py
  adapters/
    mcpp_index.py
    xim_pkgindex.py
tests/
```

不先拆多个服务、provider 插件系统或单独公共库。Python 包、CLI、Action 在一个仓库发版。

### 10.1 首个真实测试：mcpp-index draft PR

1. 创建 openxlings/xpkgindex-update 项目，在 `dev/mcpp-index-integration` 分支实现工具和 Action，
   包括离线 fixture；开发阶段不发布 v1。
2. 在 mcpp-index 建 `test/xpkgindex-update` 分支，基于最新默认分支盘点 pkgs 中安装资源。
   覆盖清单至少包括包身份、文件、当前版本、直接 URL、上游仓库、tag 模板、测试入口、扫描结果。
3. 为所有直接使用 GitHub 资源的目标包追加 extensions.autoupdate；只添加扩展声明，所有已有
   版本块逐字保留。同包有历史镜像也不排除；新版本来源可明确声明为 GitHub 直连。
4. 建立 draft PR，加入指向工具开发分支完整 SHA 的 check workflow，并接上候选版本 CI。
   workflow 必须显式匹配包文件、工具配置和集成 workflow 的路径；不能依赖只跑旧 validate 的偶然触发。
5. draft CI 先跑全量 check、元数据 lint、旧版本不变检查和现有回归。draft 状态本身不保证
   现有 workflow 会运行；检查事件类型、draft 条件和路径过滤，确保所需 jobs 实际执行。
6. 对实际发现的新版本，以 plan 在临时 workspace 运行 apply、候选依赖固定及构建测试，
   并输出真实 patch 和版本解析证据。可拆为逐包 CI jobs，失败不掩盖其余目标结果。
7. 若当前全量已最新，使用选定真实历史 release 的隔离 fixture 或历史索引基线复现追加流程。
   不修改当前 PR 的真实旧版本、不伪造远端 release、不降级已发布版本来制造测试。
8. 用单独的维护者触发写流程创建一个 draft 更新 PR，验证 propose 的 push、开 PR 与重试。
   该端到端测试仅操作测试分支/draft PR，不触及 main，不启用每天批量提交。
9. 输出逐包覆盖结果、所有例外及 CI 链接；全量声明与例外规则完成 review、候选与旧版本
   回归通过后，再把 draft 转正式，发布工具稳定版本并启用定时 propose。

全量目标的识别以 xpm 安装资源中的 GitHub URL 为准，不把 package.repo、注释或其他
文档链接算作下载来源。只要有现存直接 GitHub 版本即列入盘点；历史直连、当前镜像混合也
必须列出。扩展的候选来源由逐包核实确定，不从任意一条历史 URL 盲猜。
确无可更新规则的快照等也列入全量结果，明确作为待决项，不虚写无效配置冒充完成。

### 10.2 后续接入

稳定后再迁 xim；不要求首个 mcpp draft PR 同时改 xim。
CN 资源可在以后加入“只校验已存在资源”的路径，始终不自动生产镜像。

xim 按包迁移：支持的包从 ci.update/url_template 迁到 extensions.autoupdate；同一次变更
关闭该包旧更新入口，ci.mirror 等现有独立镜像行为暂时保持。不是要求所有 CI 元数据立即搬家。
不为了统一字段一次性重写两个索引的安装 URL 结构。

最低测试集覆盖：模板与版本比较、stable 筛选、平台完整性、相同 URL 去重、CN 哈希冲突、
Lua 注释/长字符串保留、修改原子性、实际候选选择、旧版本可解析，以及 push/PR 半失败恢复。

## 11. 多角度自审结果

本节是对修订方案的设计审查，不是已经完成的工具运行或线上 CI 验证。

| 角度 | 发现的问题 | 修订措施 / 剩余决定 |
|---|---|---|
| 已发布版本完整性 | 原版“默认 add”仍给覆盖/修复旧条目留空间 | 改为强制只追加，旧块逐字摘要与顺序检查；已有候选冲突交人工 |
| 镜像兼容性 | 强制新版本沿用旧 CN 路由会等待不存在的镜像 | 旧块不动，新块按声明使用 GitHub 直连；不创建或覆盖镜像 |
| 需求覆盖 | 仅少量数字 stable releases 无法覆盖全部 GitHub 直连目标 | 完整盘点逐包覆盖，增加 tag-only 发现；快照和特殊 tag 必须显式解决或列为待决 |
| 更新发现 | Boost 子仓等可能只有 tags；只看 releases 会漏包 | fallback tags，并公开来源和 stable 判断限制；特殊编码不猜 |
| 字段兼容 | 原 schema 前置任务超出维护者已确认范围 | 接受未知字段忽略约定，仅做解析回归，不另加安装器迁移 |
| CI 有效性 | 追加条目但依旧测试旧版本，容易假绿 | 临时 workspace 固定候选并核对解析版本，缺覆盖明确失败 |
| 开发版本一致性 | Action 可能装了 PyPI 旧版本；draft CI 可能未触发 | 固定开发提交，从 Action 自身路径运行源码；显式检查实际执行的 jobs |
| 全量提交成本 | 一次打开很多更新 PR 或一个失败中断全部 | 先一份接入 draft，全量只读/临时 apply；正式阶段才启用 max_prs |
| PR 幂等与凭证 | draft CI 自动开 PR 可递归；分支存在不等于 PR 存在 | draft CI 只读，写测试维护者触发；补建半失败 PR |
| xim 严格追加 | 更新 latest.ref 属于改既有条目，与字面“只追加”存在边界 | 不默认豁免；mcpp 先测，xim 是否允许移动别名单独确认 |

### 11.1 尚未解决、不得隐瞒的范围冲突

本地盘点中存在以下真实例外，实施前必须逐包核实远端最新状态：

- `compat.glad`、`compat.tray` 使用 commit 归档；模板无法自行决定“下一个版本”。
- `compat.freetype` 使用 `VER-2-13-3` 一类 tag，索引版本为点分形式；现有 tag 模板缺少
  分隔符转换语义，需要一个最小规则或专门适配，不能直接套 `v${version}`。
- `ggml-org.llamacpp` 的历史直接资源包含 b 编号 tag，且存在历史镜像；不能覆盖历史条目，
  也不能把它误报成标准数字 release。
- Boost 多个子包可能有固定依赖约束。可以分别追加候选，但构建若要求依赖同步，应报告失败，
  不能为了 CI 绿偷偷改既有条目或包依赖。是否引入成组更新另作决定。

这里不新增 enabled=false 等字段掩盖“全增加”目标。推荐先做完整盘点与接入 draft，
在同一轮 review 明确这些例外的更新规则；所有具有明确规则的目标都必须完成声明和 CI 覆盖。

## 12. 需要维护者 review 的决策

| 编号 | 建议决定 | 需要确认的细节与代价 |
|---|---|---|
| R1 | 项目/Action 为 openxlings/xpkgindex-update | 开发分支 dev/mcpp-index-integration；mcpp draft CI 固定完整开发提交，不提前发布 v1 |
| R2 | package.extensions.autoupdate 已确认 | 消费者忽略未知字段；不再把安装器 schema 修改当作前置任务 |
| R3 | tag + url 保持简洁，覆盖全部 GitHub 直连目标 | 增加 tag-only 查询；快照、分隔符和 b 编号更新规则仍需 review，不静默遗漏 |
| R4 | 强制只追加版本块 | 旧 URL、mirror、hash、注释及顺序逐字保留；同版本冲突不自动修；xim latest 别名边界另确认 |
| R5 | 一个公共工具 + 两个内置 adapter | 不统一重写 xpm、不要求两仓同时切换；会有少量维护结构差异的 adapter 代码 |
| R6 | 每日运行、默认最多三个新 PR | 无持久扫描状态、无包级周期；中央配置仅 version/adapter/max_prs，先接受轻量重复查询 |
| R7 | 首版不自动 mirror | 已有镜像不动；新版本可以追加直连，不被旧版本有 CN 这一事实阻塞 |
| R8 | mcpp-index 首测、全量声明、draft PR CI | 先全量 check/临时 apply，再验证一个真实 propose draft；候选测试与旧版本回归都必须实际运行 |
| R9 | 每包一个打开的更新 PR | 新 release 到来时不堆 PR、不自动改写维护者正在 review 的分支；关闭过的同版本不自动重开 |
| R10 | GitHub App 优先，PAT 可过渡 | Action 自己配置 git 写认证；checkout 不保留默认凭证；不把 token 暴露给包安装测试 |

设计约束与执行证据分开记录；下节列出实际进度，不能用设计自审代替 CI 通过。

## 13. 实现时核实的范围与调整

- 最新基线实际为 82 个含直接 GitHub 安装资源的描述符，全部追加 autoupdate 声明，旧版本不改。
- 保持 tag/url 两字段；tag 增加 `${version:dash}`，支持 FreeType 分隔符转换；支持 b 编号和单字母稳定后缀。
- 查询仓库优先来自显式 GitHub 下载模板，package.repo 作为回退，以覆盖下载自 GitHub 镜像但 repo 指向 GitLab 的 FreeType。
- commit 快照报告 pinned-snapshot；独立包计数到源版本的映射报告 pinned-version-map，绝不猜测跟随分支。
- SafeInt 历史上由 3.24 改为 3.0.28a；比较数字前同时过滤早于当前 release 的发布时间，避免回退。
- compat.libmysqlclient 的既有 wellwei/libmysqlclient 上游 API 确认返回 404，保留真实 error 诊断与旧条目；用户允许本轮暂时忽略该上游不可用，CI 只豁免此仓库的明确 404，不豁免其他错误。
- draft CI 全量审计声明和旧版本保留，对所有 update-ready 生成平台/工具链矩阵，在临时消费者实际构建运行并核对 mcpp.lock。
- 工具已有 Linux/macOS/Windows、Python 3.11/3.13 CI；Windows 揭示的 CRLF 哈希问题已修复并添加字节保留测试。

- 实际候选 CI 发现 FreeType 2.15 新增 HVF 驱动；人工追加 hvf.c union glob，2.15 与旧 2.13.3 均已本地构建运行通过，旧版本块不变。
- Linux 生成的计划与 Windows CRLF checkout 必须可互用：仅描述符计划摘要按 LF 规范化，实际追加仍逐字保留 checkout 的旧版本块；资源 SHA256 永不规范化。
- 候选 CI 保留 verbose 编译、link response 与 CDB 证据，用于分辨安装资源、包配置和工具链问题。

### 13.1 最终验证记录（2026-10-20 JST）

- 工具 draft：[openxlings/xpkgindex-update #1](https://github.com/openxlings/xpkgindex-update/pull/1)，开发分支 `dev/mcpp-index-integration`，提交 `416a954c67dba4cdf52a033a71ee88fdec0acf1d`。45 项测试，Linux/macOS/Windows × Python 3.11/3.13，打包、CLI 和 Action smoke；push/PR 合计 14 checks 成功。
- 接入 draft：[mcpp-index #543](https://github.com/mcpplibs/mcpp-index/pull/543)，分支 `test/xpkgindex-update`，最终提交 `582fc31a51a95984207bf4076bf8049ded349956`。74 个执行的 checks 成功；两个既有的条件性通知/发布任务按原规则跳过。
- [候选 CI](https://github.com/mcpplibs/mcpp-index/actions/runs/39296649657)：扫描 + 52/52 真实候选构建、运行及 mcpp.lock 版本确认成功；52 份候选日志/锁文件 artifact 齐全。
- [完整回归 CI](https://github.com/mcpplibs/mcpp-index/actions/runs/39296649642)：19 个执行 jobs 成功，覆盖 13 个现有消费者回归分片（Linux 默认/GCC 三份、LLVM 六份、macOS 两份、Windows 两份），以及 lint、镜像、选择、图形副作用、计时与失败归属检查。
- 真实 propose draft：[mcpp-index #544](https://github.com/mcpplibs/mcpp-index/pull/544)，最终提交 `8e72ea8011cd6bc794880aba2c33522bd404b465`。20 个执行 checks 成功；相对测试基线仅追加 hiredis 1.5.0 的三平台版本块，共 12 行。重复 propose 返回 pending，不重复创建 PR。
- [端到端候选 CI](https://github.com/mcpplibs/mcpp-index/actions/runs/39296667503) 和 [消费者 CI](https://github.com/mcpplibs/mcpp-index/actions/runs/39296667523) 均成功；候选固定为 1.5.0，四种平台/工具链实际构建运行通过。
- 82 个 GitHub 直连描述符全部声明；独立 guard 对 254 个已有描述符的历史版本条目保留检查通过。扫描结果：63 up-to-date、13 update-ready、4 pinned-snapshot、1 pinned-version-map、1 已批准源故障。

人工兼容适配与自动追加逻辑分开：

| 包 | 最终适配 | 真实验证 |
|---|---|---|
| FreeType | 追加 HVF 驱动源码的兼容 glob | 新 2.15 四种组合成功；旧 2.13.3 消费回归成功 |
| OpenMP | LLVM 23 改用 runtimes CMake 入口；工具定位支持 Windows Python 位于 payload 根目录 | 新 23.1.3 四种组合成功；旧 22.1.8 各支持平台回归成功，Windows 实际构建及运行通过 |
| hiredis | 七个独立 C 包装翻译单元，避免 Windows 遍历上游 AI 配置 symlink 时 Access denied；不删改上游资源 | 新 1.5 四种组合和端到端 CI 成功；旧 1.2 本地构建运行成功 |
| libuv | Windows 加 synchronization 链接库 | 新 1.53 四种组合成功 |
| nanodbc | 标准 locale 头；macOS 明确使用 libiodbc 头，旧版测试不再空跑 | 新 3.0.7 四种组合成功；旧 2.14 的 Linux LLVM23/macOS/Windows 消费回归成功 |
| Quill | 生成模块时移除未启用的 QUILL_IMPORT_STD 块，避免扫描器把 inactive import std 视为入口 | 新 13.1 四种组合成功；旧 13.0 回归成功 |
| mcr | 0.2 移除 JSON API，保留旧版 JSON 断言，新增 typed response/body/options 断言；仅对 0.2.0 回补 libc++20 不具备的 join_with/enumerate | 新 0.2 四种组合成功；旧 0.1.5 回归成功 |
| muduo / llama.cpp | 显式补标准头；llama.cpp 仅在 Linux 普通实现源注入 cstdlib/cerrno，避免改变 Mac/Windows 编译环境 | 旧版本全平台现有消费者回归成功；llama.cpp Windows 与 LLVM23 日志均输出 PASS |

临时源故障豁免：用户明确允许暂时忽略 wellwei/libmysqlclient 不可用。原 error 留在 plan；强制 gate 仅接受该包/仓库/路径的确切 HTTP 404。libmysqlclient 和依赖它的 mysql-connector-cpp 在 summary 标为 NOT TESTED，不计作成功构建。其他扫描或构建失败仍失败；上游恢复/迁移后删除 `tests/autoupdate/source_outage.py` 及对应 workflow 步骤。

补充自审：CI 对新增描述符不读取不存在的基线文件；新增包由普通消费者验证，若有更新候选仍执行候选 CI；删除任何已有描述符直接失败。真实临时 Git 仓库回归已验证新增包可审计、初始版本不误判为 bump、历史描述符不能删除，且已加入扫描 CI。

本轮未迁移 xim-pkgindex 的真实包；共用静态版本追加逻辑与 adapter 边界已有 fixture 验证，带 latest.ref 的变更明确拒绝，等待独立策略。自动更新可验证版本/资源/构建，不能保证 API 向后兼容；mcr 0.2 是实际例子，始终保留人工 review/merge。

三个 PR 均保持 draft；不发布稳定标签、不启用定时写入、不合并。运行中的旧提交已取消，失败历史及修复依据保留；最终结论仅依据以上最终提交的完整 CI。

## 14. 共享资源优化及合并验证（2026-10-20）

用户授权 CI 成功后 squash 合并工具与索引 PR，并实际触发更新验证、合入成功更新。

### 14.1 一份资源，多平台引用

```lua
local versions = {
    ["1.5.0"] = {
        url = "https://github.com/redis/hiredis/archive/refs/tags/v1.5.0.tar.gz",
        sha256 = "eec7ef8641d221e144a58d5ef8d733c8c75c7fd487097a233aacb4fa33981cfb",
    },
}

package = {
    -- 身份、构建配置与 extensions 保持原结构
    xpm = {
        linux = { -- 已有版本块保持原文
            ["1.5.0"] = versions["1.5.0"],
        },
        macosx = { ["1.5.0"] = versions["1.5.0"] },
        windows = { ["1.5.0"] = versions["1.5.0"] },
    },
}
```

- 所有参与平台的完整资源相同时，共用一份前置版本定义；URL 不同，即便 SHA 相同，也不混用来源。
- 后续版本追加到同一个共享表；旧的内联条目不迁移、不覆盖、不重排。名称与现有局部变量冲突时选择新名称。
- 支持字面量局部表、字面量字符串索引引用和已有整个平台共享表。不执行 Lua，不猜测动态表达式。
- 版本保留检查同时保护引用源码及引用指向的资源定义；仅保留引用、修改背后的 URL/SHA 同样失败。
- 拒绝共享表重绑、直接变更、外部调用和后续 package 访问；无法静态解析的历史版本资源明确报错，不能从版本比较中静默消失。
- 所有平台与资源先验证；生成后再次静态解析，确认每个平台的新条目确实指向已验证 URL/SHA，最后原子写入。

### 14.2 自审与实施证据

- 工具回归增至 59 项；覆盖连续追加、共享定义被改、变量重绑/变更、平台资源差异、名称冲突、不可解析前缀、动态历史资源等。
- 13 个真实候选生成结果均只有一份 URL/SHA，三平台引用同一资源；旧版本保留和 Lua 平台一致性检查通过。固定客户端 2026.10.1.2 对全部候选的三平台解析均成功。
- 索引 CI 的真实 Git 基线回归同时覆盖：新增描述符不误判为版本 bump、历史描述符不能删除、共享版本引用能生成精确候选构建矩阵。
- README 精简为正式项目入口，详细 CLI/config/shared-table 内容放在 docs/usage.md。
- 工具 PR #1 已 squash 合并为 `23c5e04948c55e606bc56ee2c649ddd4849b7ec6`；索引 Action 固定到此真实合并提交。

### 14.3 合并后的真实更新验证

先等待索引候选与现有消费者 CI 全部成功，再 squash 合并 #543。将 #544 同步到 main 基线，以工具重新生成共享格式并验证后合入。随后手动触发 main 上的 Action，使用可选 package 输入限定一个真实更新包；从 artifact 取回同一份固定计划，由已合并的 CLI 创建针对 main 的更新 PR，等待实际构建、运行、锁文件及旧版本保留检查成功后 squash 合入。

写 PR 使用本地已有授权，不新建长期 token secret。现有 libmysqlclient 源故障豁免继续明确保留，不改变其历史版本。此节是实施时的计划及已核实证据，最终合并与 CI 结果另见汇报和 PR 记录。
