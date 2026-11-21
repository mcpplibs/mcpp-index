# 设计方案与实施计划：mcpp 构建插件包规范（`<owner>.mplugin.<name>`，描述符放 `pkgs/mcpp/`）

状态：**v2 已按目标实施**（2026-11-21，见 §9 执行记录）。v2 纳入了维护者对 Q1–Q7、Q9、Q10 的决定（§7），Q8 未答、暂按建议；并加入多视角自审（§8）及其引出的修改。本文含：决策记录（§1）、实测证据（§2）、规范正文草案（§3，评审通过后成为 `docs/build-plugins.md` 与 `docs/zh/build-plugins.md`）、影响面（§4）、实施计划与任务关系（§5）、风险与未验证项（§6）、决定与待决（§7）、自审（§8）。
事实均为实测或读源码所得，出处写在各条之后；没有验证的写在 §6。

## 0. 目标与范围

**问题。** 索引里的构建插件（带 `build.mcpp` 可 `import` 的规则模块）现在没有统一的包命名规范：`mcpplibs.slintgen`、`mcpplibs.grpcgen`、`mcpplibs.openkal-bind`、`mcpplibs.clangtidy`，后缀（`gen`、`-bind`）是各包随手加的；包 id、模块名（`mcpp.mcpplibs.slintgen`）、C++ 命名空间（`mcpp::mcpplibs::slintgen`）靠约定对应；描述符散在 `pkgs/<首字母>/`，没有统一的地方管理。mcpp 的 `mcpp add` 也无从知道一个包是不是构建插件。

**范围。**
1. 定一个规范：包 id = 模块名 = C++ 命名空间，由同一个字符串得出，`mcpp.*` 保留给官方。
2. 索引里新增 `pkgs/mcpp/`，放官方的与 mcpplibs 的、以及以后第三方的 mcpp 扩展包。
3. 老包不删、不改已发布的行，冻结；新版本以新 id 发布，按需迁移。
4. 以 slint 作为第一个新形态包，走通整条链并做冷装验收。
5. 向 mcpp 仓库提一个 issue：`mcpp add` 对符合规范的包默认写入构建依赖。

**不在范围。** 引擎改动（§2 证明不需要）；官方 mcpp-plugins 的包内容；已发布版本的任何改写；`mcpplibs.mwrap.*` 包装包的规范（已有 `docs/mwrap.md`）。

## 1. 决策记录

| # | 决策 | 理由 | 否决的备选（及证据） |
|---|---|---|---|
| D1 | 种类段叫 **`mplugin`**（单数），构建插件包 id 为 `<owner>.mplugin.<name>`，namespace 为 `<owner>.mplugin`（两段，与 `mcpplibs.mwrap` 同形），name 是单个原子段 | owner 永远是第一段，`mcpp.*` 一律是官方；与 `mcpplibs.mwrap.<lib>` 同构；包 id、模块名、C++ 命名空间严格是同一个字符串 | `mcpp.<owner>.<name>`：现有引擎对 `mcpp.` 下的模块要求 `mcpp.<自己的 namespace>.*`，模块名等于包 id 时每次构建警告（§2-A）。`<owner>.mcpp.<name>`：C++ 里 `mcpplibs::mcpp` 遮蔽全局 `mcpp`，规则代码必须到处写 `::mcpp::`（§2-I）。把 C++ 命名空间与模块名脱钩（`mcpplibs::slint`）：失去三者一致，且占用 `mcpplibs::` 根下的名字，须额外查重（§2-L）。`mcpp.slint`（全放进官方 namespace）：官方与各家抢同一批名字，看不出谁维护 |
| D2 | **单数**，目录同样不出现 `plugins` | `mwrap` 是单数的种类段；官方 `mcpp.plugins` 是复数集合包，含义不同 | `mplugins` |
| D3 | 描述符放 **`pkgs/mcpp/`**，里面有官方（`mcpp.plugins`、`mcpp.platforms`）、`<owner>.mplugin.<name>`；文件名用**完整 id** | 客户端按描述符声明的身份扫描 `pkgs` 的各个子目录，目录和文件名都不决定身份（`docs/mwrap.md`）；目录按“谁来加载它”分：mcpp 自己加载的扩展包。owner 会变，所以不能像 mwrap 那样省前缀 | `pkgs/mplugin/`（仅社区）：官方包就没有归处；目录名等于种类段的对称性不是必需 |
| D4 | 老包**冻结**，不改已发布的行，不删；新版本以新 id 在 `pkgs/mcpp/` 发布；**按需迁移**（下次要发新版本时才迁） | 老包按现行 SPEC-007 §9 是合规的，不是违规；同一个 id 改模块名会让写着 `x = "1"` 的使用者在升级时被悄悄带到新模块名，构建就坏；新 id 才能保证老使用者不被动受影响 | 同 id 发新版本并改模块名；一次性全迁 |
| D5 | 库绑定的规则：name 取**库名**（`slint`，不加 `gen`），规则放对应 -m 仓库的 `rules/` 子包，由包装包 `reexport`；通用工具规则独立仓库；引擎级能力才进官方 mcpp-plugins | 使用者只依赖包装包，不必知道规则包名；种类段已说明它是插件，后缀多余 | 沿用 `slintgen` |
| D6 | **不转发**：老包不提供转发到新模块的垫片 | 老包冻结，老使用者不受影响；垫片模块名不以包 id 开头，会违反 §3 的前缀不变式，还需要例外字段 | 保留一个周期的转发模块 |
| D7 | 规范文档放 **mcpp-index 的 `docs/`**（沿用 mwrap 先例），mcpp 仓库只提一个 issue | mwrap 规范就在这里；引擎不需要改（§2） | 在 mcpp 的 SPEC-007 里改写 |
| D8 | `mcpp add` 的判定用**包 id**：第二段是 `mplugin` 的写入 `[build-dependencies]` 并带 `host-module = true`；官方 `mcpp.plugins` 单独处理（需要 `features`）；`mcpp.platforms` 不自动处理 | `mcpp.platforms` 是目标平台的数据行（`platform = "mcpp.platforms@…"`），不是 host-module；目录不能用来判断种类 | “第一段是 `mcpp` 就是插件”（会把 `mcpp.platforms` 误判） |
| D9 | **构建包与库包分开测试**：构建插件的测试成员只测 `build.mcpp` 层面的简单功能（规则对一个小输入产出什么、生成的模块能否编译、改输入是否重新生成）；库本身的行为由包装包的成员测。slint 的成员先留在 `tests/mwrap/slint-ui`，最终收敛到 `tests/mcpp/` | 构建插件的职责只到构建期；运行期行为属于库包。测试位置先不动，避免为新目录补一整套 `run_members.sh`/`validate.yml` 分支 | 现在就把成员移到 `tests/mcpp/` |
| D10 | **slint 的新 id 版本线从头开始**：`mcpplibs.mplugin.slint` 的首个版本是它所针对的上游版本 `1.19.0`，不继承 `1.19.0.3`（slint 还没有使用者）。归档仍是包装包 `mwrap-1.19.0.3` 的那个（同一个标签、同一个 sha256）；规则包自己的 `rules/mcpp.toml` 版本与描述符的行一致，即 `1.19.0`，与包装包的修订号脱钩 | 规范“首个版本等于上游版本、修订追加 `.N`”对新 id 同样成立；包装包 `mcpplibs.mwrap.slint` 不能回到 `1.19.0`（标签 `mwrap-1.19.0` 已存在、行 `1.19.0.1/.2` 已发布），所以只有新 id 能“从头开始” | 延续 `1.19.0.3` 的编号；连同包装包一起重来（做不到：标签不移动） |
| D11 | 向 mcpp 只提**一个 issue**，汇总背景、规范链接、实测证据与对 `mcpp add` 的建议行为，不拆成多条功能请求 | 维护者决定；mcpp 侧自行决定实现范围与顺序 | 五条分别提；带优先级清单 |
| D12 | 实施顺序：T1 → T3 → T4 → T2（先让 slint 成为 `pkgs/mcpp/` 的第一个文件，再搬官方包；T2 可推后，不阻塞 slint）。**Q8 维护者未答，暂按此，待确认** | T4 只需要目录存在，它自己的第一个文件就能创建目录；这样 U1 先在低风险的包上验证 | T4 依赖 T2 |

## 2. 实测证据（mcpp 2026.11.20.1，gcc 16.1，Linux x86_64）

方法：每项是一个最小的 host-module 包（一个 `export module <模块名>;` 加一个 `answer()` 函数）加一个在 `build.mcpp` 里 `import` 它的消费者，依赖键决定包的 namespace；`mcpp build`，看警告与退出码。所有项构建都成功（exit 0），区别只在警告。

| 项 | 依赖键（包 id） | 模块名 | 警告 |
|---|---|---|---|
| A | `mcpp.mcpplibs.slint` | `mcpp.mcpplibs.slint` | **有**：`is under 'mcpp.' but not under its own namespace … a plugin names its modules 'mcpp.mcpp.mcpplibs.*'`（文字与索引 gate 匹配的那句不同，gate 抓不到） |
| B | `mcpp.acme.x` | `mcpp.plugins.x` | 有：`which belongs to the modules maintained by the mcpp project`（整串 namespace 比较：`mcpp.acme` ≠ `mcpp`） |
| C | `acme.x` | `mcpp.plugins.x` | 有（同 B） |
| D | `mcpp.x` | `mcpp.plugins.x` | 无（namespace `mcpp` 豁免） |
| E | `mcpplibs.mcpp.slint` | `mcpplibs.mcpp.slint` | 无 |
| F | `mcpplibs.slintgen`（现有老包） | `mcpp.mcpplibs.slintgen` | 无 |
| G | `mcpp.mcpplibs.slint` | `mcpp.mcpp.mcpplibs.slint` | 无（引擎要求的写法，包 id ≠ 模块名） |
| H | `mcpp.slint` | `mcpp.slint` | 无 |
| I | `mcpplibs.mcpp.slint`，模块内 `import mcpp;` 调 `mcpp::graph_file()` | 同 E | **编译失败**：`'graph_file' is not a member of 'mcpplibs::mcpp'` |
| J | 同 I，改写 `::mcpp::graph_file()` | 同 E | 无 |
| K | **`mcpplibs.mplugin.slint`**，模块内 `import mcpp;` 调 `mcpp::graph_file()`，消费者 `using namespace mcpplibs;` 后用 `mcpp::` 与 `mplugin::` | `mcpplibs.mplugin.slint` | **无，且不加 `::`** |
| L | `mcpplibs.mcpp.slint`，C++ 命名空间 `mcpplibs::slint` | `mcpplibs.mcpp.slint` | 无 |

结论：
1. 引擎不需要改。B 证明保护没有丢：它比较的是整串 namespace，不是第一段。
2. 现有引擎只检查 `mcpp.` 下的模块名，`mcpplibs.mplugin.*` 不在范围内，**这类包不会触发任何 R9.6 警告**。
3. `mplugin` 避开了 `::mcpp` 遮蔽（I 对 K）。
4. 老包（F）合规，不是错误。

**在 CI 固定的版本上复验。** 索引 CI 固定 `MCPP_VERSION: "2026.11.18.1"`（`validate.yml`），上表是在本机 2026.11.20.1 上测的。自审时我取了 v2026.11.18.1 的发布包、用独立的 `MCPP_HOME` 把 K、B、D、F 再跑了一遍：K 无警告且不加 `::` 即可调用 `mcpp::graph_file()`；B 有 R9.6 警告；D、F 无警告。结果与 2026.11.20.1 一致。A、E、I、L 没有在固定版本上重测（它们是被否决的备选，不影响结论）。

另一处事实：索引已有一个 namespace 检查 `tests/check_reserved_namespace.lua`（`validate.yml` 步骤 5b），拒绝以 `core/plugins/deps/rules/dist/tools` 开头的 namespace。成员 gate `tests/run_members.sh` 对构建输出匹配 R9.6 的那一句警告来失败。

## 3. 规范正文草案（成稿为 `docs/build-plugins.md` + `docs/zh/build-plugins.md`）

### 3.1 术语
- **构建插件**：提供 `build.mcpp` 可 `import` 的规则模块的包（`host-module`）。
- **种类段**：包的 namespace 里表示种类的一段，包装包是 `mwrap`，构建插件是 `mplugin`。
- **官方包**：namespace 第一段是 `mcpp` 的包，由 mcpp 项目维护。

### 3.2 身份（一个名字，三种写法）

构建插件包的 id 是 `<owner>.mplugin.<name>`：

| 写法 | 形式 | 例子 |
|---|---|---|
| 包 id（namespace + name） | `<owner>.mplugin` + `<name>` | `mcpplibs.mplugin.slint` |
| 模块名 | 与包 id 相同；子模块为 `<id>.<子名>` | `mcpplibs.mplugin.slint` |
| C++ 命名空间 | 包 id 的 `.` 换成 `::` | `mcpplibs::mplugin::slint` |

规则：
1. `<owner>` 与 `<name>` 都必须是小写标识符：`[a-z][a-z0-9_]*`；多词用下划线，不用连字符（模块名需要标识符，mwrap 已如此：`godot_cpp`）。
2. `<owner>` 是维护者：`mcpplibs` 只给 mcpplibs 组织维护的包；个人或其他组织用自己的名字。
3. `<owner>` 不得是 `mcpp`，不得是官方保留名（`core`、`plugins`、`deps`、`rules`、`dist`、`tools`、`platforms`），也不得是种类段（`mwrap`、`mplugin`）。官方以后每新增一个包，须检查是否与已有 owner 重名。
4. 包的主接口模块名必须恰好等于包 id；其余模块必须以 `<id>.` 开头。
5. 包 id 的第一段是 `mcpp` 的只能是官方维护的包；`mcpp.<name>` 不属于此规范的 `<owner>.mplugin.<name>` 形态。
6. 库绑定规则的 `<name>` 取库名（`slint`、`grpc`、`protobuf`），不加 `gen`、`-bind` 之类后缀；同一个库有多个规则时，用函数名区分，不再另起包。通用工具规则取工具名（`clangtidy`）。
7. 规则代码里调用引擎写 `mcpp::…`；此命名不会遮蔽全局 `mcpp`（§2-K）。

### 3.3 规则放在哪里

| 类型 | 放哪里 | 使用者怎么用 |
|---|---|---|
| 库绑定规则（slint、grpc、protobuf、openkal） | 对应 -m 仓库的 `rules/` 子包，描述符 `mcpp = "*/rules/mcpp.toml"`；根 `mcpp.toml` 里 `[build-dependencies] <id> = { path = "rules", host-module = true, reexport = true }` | 只依赖包装包 |
| 通用工具规则（clangtidy 等） | 独立仓库，独立发布 | `[build-dependencies] <id> = { version = "…", host-module = true }` |
| 引擎级、跨生态通用的能力 | 官方 mcpp-plugins（`mcpp.plugins`） | `mcpp.plugins` 的 feature |

规则包自己的依赖写在它的 `[dependencies]`（mcpp ≥ 2026.10.11.1；`[build-dependencies.mcpp]` 已弃用）。`device_extensions` 之类的 feature 认领不经 `reexport` 传递，库绑定规则因此不带 feature，输入以 `options` 字段传入（slint 的 `options::sources` 是先例）。

### 3.4 索引布局
- 描述符放 `pkgs/mcpp/<完整 id>.lua`，如 `pkgs/mcpp/mcpplibs.mplugin.slint.lua`、`pkgs/mcpp/mcpp.plugins.lua`；不加额外的字母目录层。
- 声明 `namespace = "<owner>.mplugin"`、`name = "<name>"`；`mcpp = "*/rules/mcpp.toml"`（子包形态）或省略（搜索 `*/mcpp.toml`）。
- **构建包与库包分开测试。** 构建插件的测试成员只测 `build.mcpp` 层面的简单功能：规则对一个小输入产出什么、生成的模块能否编译、改输入是否重新生成；库本身的行为由包装包的成员与已安装模板检查来测。
- 测试位置分两个阶段：**阶段 1（现在）**：slint 的成员留在 `tests/mwrap/slint-ui`，不新增 `tests/mcpp/`，因为 `run_members.sh`、`validate.yml` 的选择与分片都只认 `tests/examples/` 和 `tests/mwrap/`。**阶段 2（收敛）**：第一个独立规则（如 clangtidy）迁移时，给这些脚本补 `tests/mcpp/` 的分支，此后构建插件成员统一放 `tests/mcpp/<成员>/`（成员名为 `<owner>-<name>` 加用途后缀），slint 补一个只测 `build.mcpp` 的最小成员，`slint-ui` 回到只测库。
- `pkgs/mcpp/` 里允许两种文件：namespace 第一段是 `mcpp` 的官方包，或 namespace 第二段是 `mplugin` 的插件包；反过来，namespace 第二段是 `mplugin` 的描述符必须在 `pkgs/mcpp/`。目录**不用于**判断种类（`mcpp.platforms` 是平台数据行）。

### 3.5 版本
- 每个包有自己的版本线：首个版本等于它所针对的上游版本，修订追加 `.N`；标签不移动。
- 库绑定规则随包装包发布，**描述符的行指向包装包的标签归档**（同一个归档、同一个 sha256、GLOBAL 与 CN 两处 URL）；规则包自己的 `rules/mcpp.toml` 的 `version` 必须等于描述符的行，但**不必**等于包装包的修订号。slint：`mcpplibs.mplugin.slint@1.19.0` 的归档是 `mwrap-1.19.0.3`，包装包 `mcpplibs.mwrap.slint` 同时发 `1.19.0.3`；规则内容之后若有改动，规则发 `1.19.0.1`，指向当时的包装包标签。
- 库绑定规则的描述符不写 `extensions.autoupdate`（行由与包装包行同一个 PR 加入，避免机器人给同一归档开出第二条版本线）。

### 3.6 老包与冻结
- 老包 = 已发布的、id 不以 `mcpp.` 开头且不符合 §3.2 的构建规则包。其描述符、归档、已安装的 xpkg 保持原样，依赖老 id 的 `mcpp.toml` 继续解析。
- 冻结的描述符：删除 `extensions.autoupdate`，`description` 写明 “FROZEN: superseded by `<新 id>`”，已发布的行不改。
- 老包不再追加新版本；其后继以新 id 在 `pkgs/mcpp/` 发布，版本号延续原来的线。
- 不提供转发模块。
- 迁移按需：一个老包在下次要发新版本时才迁。

### 3.7 `mcpp add`（向 mcpp 提的**一个** issue 的内容）
issue 只汇总信息，是否实现、实现多少由 mcpp 侧决定。要写进去的有：背景与本规范的链接、§2 的实测、以及对 `mcpp add` 的建议行为：
- id 第二段是 `mplugin` 时，默认写入 `[build-dependencies]` 并带 `host-module = true`；官方 `mcpp.plugins` 同样写入构建依赖，但需要 `--features`（现在 `mcpp add` 只有 `--dev`）；`mcpp.platforms` 不自动处理（它是 `platform = "…"` 的数据行）。
- 判定只用包 id，不用目录。
- 顺带的想法（不要求）：显式覆盖项 `--build`/`--dep`；对冻结的老 id 给出提示和新 id；`mcpp remove` 对称处理。

### 3.8 lint（索引实施）
| 检查 | 位置 | 内容 |
|---|---|---|
| namespace 保留名 | `tests/check_reserved_namespace.lua`（已有） | 补：`<owner>.mplugin` 的 owner 不得是 `mcpp`、官方保留名、官方包名（含 `platforms`） |
| 布局 | 新增 `tests/check_mplugin_layout.lua`，在 `validate.yml` lint 里作步骤 5c | §3.4 的双向检查；`<owner>`、`<name>` 是小写标识符 |
| 前缀不变式（模块名以包 id 为前缀） | 描述符层看不到模块名（它在包内的 `.cppm` 里），所以不在 5c；靠评审，或加一个读 `.cppm` 的扫描脚本（§7-Q5） | §6-U5 |
| 保留名警告 | `tests/run_members.sh`（已有） | 保持不变 |

### 3.9 安全说明
构建插件在 `build.mcpp` 里以 host-module 运行，**会在构建机上执行任意代码**，这与任何依赖里的 `build.mcpp` 相同，`mplugin` 这个名字并不表示被审计过。索引对 `pkgs/mcpp/` 里的新增和版本更新按“会执行代码的包”评审；owner 的归属、与 `mcpplibs` 相像的名字（抢注）都靠评审，没有自动校验。若仓库有 CODEOWNERS，`pkgs/mcpp/mcpp.*` 应归官方维护者。

## 4. 影响面

### 4.1 老的构建规则包（冻结 + 按需迁移）

| 老包 | 描述符 | 后继 id（建议） | 触发迁移 |
|---|---|---|---|
| `mcpplibs.slintgen` | `pkgs/s/slintgen.lua` | `mcpplibs.mplugin.slint`（版本线从 `1.19.0` 起，D10） | **第一个，本计划 T3/T4** |
| `mcpplibs.grpcgen` | `pkgs/g/grpcgen.lua` | `mcpplibs.mplugin.grpc` | grpc-m 下次发布 |
| `mcpplibs.protogen` | `pkgs/p/protogen.lua` | `mcpplibs.mplugin.protobuf` | protobuf-m 下次发布 |
| `mcpplibs.clangtidy` | `pkgs/c/clangtidy.lua` | `mcpplibs.mplugin.clangtidy` | clangtidy 下次发布 |
| `mcpplibs.openkal-bind` | `pkgs/o/openkal-bind.lua` | `mcpplibs.mplugin.openkal_bind` | openkal 下次发布 |
| `mcpplibs.rules-cuda` | `pkgs/r/rules-cuda.lua` | 无：它只是指向官方 `mcpp.rules.cuda` 的垫片，保持冻结，不迁移 | — |

grpcgen、protogen、clangtidy 的模块名我没有逐个核对（§6-U6）。

### 4.2 不属于此规范的包
- `xpkg`、`std-freestanding`、`mcpplibs.capi.lua`：普通库。
- `marzer.tomlplusplus`：普通库，使用方可以把它作为 host-module，不是构建插件。
- `mcpp.platforms`：官方的目标平台数据行，搬进 `pkgs/mcpp/`，但不是构建插件。

### 4.3 官方包
`mcpp.plugins`、`mcpp.platforms` 从 `pkgs/m/` 纯 `git mv` 到 `pkgs/mcpp/`，文件名不变，已发布的行不变。

## 5. 实施计划与任务关系

### 5.1 任务清单

| 任务 | 仓库 | 内容 | 前置 | 验收 |
|---|---|---|---|---|
| **T0** | mcpp-index | 本文评审 | — | 维护者确认（Q8 尚待确认） |
| **T1** | mcpp-index（PR A1） | `docs/build-plugins.md` + `docs/zh/build-plugins.md`；`tests/check_mplugin_layout.lua` 及其正反例测试；`check_reserved_namespace.lua` 扩展（owner 不得是 `mcpp`、官方保留名、官方包名、种类段）；`validate.yml` lint 步骤 5c；`package-types.md`、`repository-and-schema.md`、README 的引用；CHANGELOG | T0 | lint 通过；反例（owner 为保留名或种类段、`mplugin` 描述符不在 `pkgs/mcpp/` 等）被拒绝；中英文文档一致 |
| **T3** | slint-m（PR）+ 标签与发布 | 规则包改为 `name = "slint"`、模块 `mcpplibs.mplugin.slint`、C++ 命名空间 `mcpplibs::mplugin::slint`；`rules/mcpp.toml` 的 `version` 为 `1.19.0`（D10），包装包版本 `1.19.0.3`；根 `mcpp.toml` 的构建依赖键改名；`templates/hello`、`tests/rule-consumer`、`docs/rules.md`、`docs/usage.md`、README 中英文、`tools/test_template.py`、`ci.yml` 同步；新增 `rules/LICENSE`（仓库根许可证的副本，收掉 `mcpp pack` 的无许可证警告；`STATIC_NOTICES` 不扩展）；规则仓库 CI 加一行检查：`rules/src` 的 `export module` 等于包 id（Q5）；CI 通过后打标签 `mwrap-1.19.0.3`，发布 release，镜像到 `gitcode.com/mcpp-res/mwrap-slint` | T0（不依赖 T1） | CI 四个任务通过；**在 CI 固定的 mcpp（2026.11.18.1）上**重命名后的 `reexport` 仍把规则传给消费者；规则版本（1.19.0）与包装包版本（1.19.0.3）不同时 `mcpp pack`、描述符解析不报错（U12）；两处 release 的归档逐字节一致 |
| **T4** | mcpp-index（PR B） | 新增 `pkgs/mcpp/mcpplibs.mplugin.slint.lua`（版本 `1.19.0`，行指向 `mwrap-1.19.0.3` 的归档，GLOBAL + CN，无 autoupdate，`mcpp = "*/rules/mcpp.toml"`）；`pkgs/mwrap/slint.lua` 加 `1.19.0.3` 行；**冻结** `pkgs/s/slintgen.lua`（默认：删 autoupdate、标注 FROZEN、行不动；是否改为删除见 §8-R11）；`tests/prepare_mwrap_indices.py` 增 `mcpplibs.mplugin` 视图（若成员需要）；`tests/mwrap/slint-ui` 与 `validate.yml` 验收步骤升到 1.19.0.3；CHANGELOG | T1（lint 认得这个布局）、T3（发布与镜像就绪） | 全部 lint 通过（含 `check_cross_package_refs`、`check_duplicate_versions`、`check_platform_version_parity`）；候选 CI 全绿；**客户端从 `pkgs/mcpp/` 解析到新包（U1 的第一次实测）**；`check_installed_template.py --published-index --mirror GLOBAL` 与 `--mirror CN` 冷装 `mcpplibs.mwrap.slint@1.19.0.3` 通过；`mcpplibs.slintgen@1.19.0.1/.2` 与 `mcpplibs.mwrap.slint@1.19.0.1/.2` 仍可解析 |
| **T2** | mcpp-index（PR A2） | `git mv pkgs/m/mcpp.plugins.lua pkgs/m/mcpp.platforms.lua` 到 `pkgs/mcpp/`；适配 `tests/select_members.py`（`pkgs/*/*.lua` 的选择结果不变，`test_select_members.py` 加用例）；其他对旧路径的引用（`rules-cuda.lua`、`mcpp.plugins.lua` 注释） | T4（U1 已验证）；T2 前核对 mcpp-plugins 的发布流程（U4） | 全量 CI 通过；搬迁前后 `select` 的成员集合一致；已发布行字节不变。**可推后，不阻塞 slint** |
| **T5** | mcpp-community/mcpp | **一个** issue：背景、本规范链接、§2 实测、对 `mcpp add` 的建议行为（§3.7） | T1 已合入 | issue 开出；不阻塞任何后续任务 |
| **T6** | 各 -m 仓库与索引 | 其余老包按需迁移：grpc、protobuf、clangtidy、openkal-bind；每个包 = 新 id（版本线从其上游版本起）+ 冻结老描述符；第一个独立规则迁移时完成测试阶段 2（`tests/mcpp/`，§3.4） | 对应包下次要发版 | 按 T3/T4 的同一套验收 |

### 5.2 依赖关系

```
T0 评审
 ├─► T1 (A1: 规范 + lint) ──► T4 (索引 PR B: 新描述符 + 冻结老的 + 冷装验收) ──► T2 (A2: 官方两包搬迁，可推后)
 │        └──► T5 (mcpp issue)                  ▲                                  └─► T6 (其余老包，按需)
 └─► T3 (slint-m: 改名、1.19.0.3、标签、两处发布) ─┘
```

- T1 与 T3 可并行；T4 同时依赖 T1、T3；T2 排在 T4 之后（Q8，待确认），不阻塞 slint。
- T5 只依赖 T1。slint 的新形态**今天就能用**，不需要 mcpp 发布任何东西（§2 在 CI 固定的版本上复验过）。
- 每个 PR 单独开、单独 CI、单独合入（A1、T3、T4、A2）；T3 的发布遵循既有流程（CI 在标签提交上成功才能发布，已存在的 release 不覆盖，标签不移动）。

### 5.3 回滚
- A1/A2/T4 是索引内的 PR：合入后出问题，用后续 PR 修；已发布的行从不改。
- T3 的标签不移动；出问题以修订 `1.19.0.4` 修复。
- 老 id 与老版本全程保持可用，所以任何一步失败都不影响已有使用者。

## 6. 风险与未验证项

| # | 项 | 状态 / 处理 |
|---|---|---|
| U1 | 客户端从目录名为 `mcpp` 的目录找到包：`docs/mwrap.md` 写明按声明身份扫描子目录，没有用 `pkgs/mcpp/` 实测 | T4 的验收就是第一次实测（slint 是 `pkgs/mcpp/` 的第一个文件）；若失败，回退为 `pkgs/mplugin/` 只放社区包，官方留在 `pkgs/m/` |
| U2 | `prepare_mwrap_indices.py` 按 namespace 建视图（`compat`、`mcpplibs.mwrap`、`grpc`、`mcpplibs`），新 namespace `mcpplibs.mplugin` 的成员可能需要新视图 | T4 内适配；若成员测试不需要则不加 |
| U3 | `select_members.py` 对 `pkgs/*/*.lua` 的选择是否因搬迁而变 | T2 的验收：搬迁前后选择集合一致 |
| U4 | mcpp-plugins 的发布自动化是否改 `pkgs/m/mcpp.plugins.lua`：我在 mcpp-index、mcpp-community、各 -m 仓库里 grep 了路径，CI 里没有引用，但没读 mcpp-plugins 的发布流程 | T2 前核对 |
| U5 | 规则包的模块名以包 id 为前缀，在描述符层看不出（模块名在归档的源码里，索引 lint 看不到） | 评审 + 规则仓库自己的 CI 加一行检查（Q5） |
| U6 | grpcgen、protogen、clangtidy 的模块名没有逐个核对 | T6 各包迁移时核对 |
| U7 | 第三方 owner 的归属没有自动校验 | 文档写明；评审把关；不是本规范新增的负担 |
| U8 | `mplugin` 与官方 `mcpp.plugins`、`mcpp.rules` 字面相近，可能被误认 | 文档中用一句话说明；种类段已决定（Q1） |
| U9 | 搜索 `mcpp` 找不到 `mplugin` 包 | 描述符 `description` 写明 “mcpp build plugin” |
| U10 | 未迁移的老使用者要在某一天自己改依赖名才能拿到新版本 | 冻结描述符的 `description` + 文档对照表 + CHANGELOG |
| U11 | 构建插件会在构建机上执行任意代码，`mplugin` 不代表被审计 | §3.9；评审 |
| U12 | 描述符的行版本（`1.19.0`）与包装包版本（`1.19.0.3`）、规则 `rules/mcpp.toml` 的 `version` 三者不同，引擎或 `mcpp pack` 是否要求一致没有实测 | T3 的验收项；若要求一致，退回为“规则版本等于包装包版本”（`1.19.0.3`），D10 改为只对描述符生效，由维护者再定 |
| U13 | 新形态在比 2026.11.18.1 更早的 mcpp 上的行为没有测 | 新包声明的 mcpp 版本下限取 CI 固定版本；沿用 `mcpp.plugins` 描述符声明下限的方式（T4 核对写法） |

## 7. 决定与待决

### 7.1 维护者已决定（2026-11-21）

| 问题 | 决定 |
|---|---|
| Q1 种类段 | `mplugin` |
| Q2 目录 | `pkgs/mcpp/` 放官方 + mcpplibs + 第三方，文件名完整 id；U1 失败则回退 |
| Q3 PR 切分 | A1 / A2 / T3 / T4 四个 PR |
| Q4 老包 | 只冻结，不转发；冻结时删 `autoupdate`、描述加 FROZEN |
| Q5 前缀不变式 | 评审 + 规则仓库 CI 一行检查 |
| Q6 测试成员位置 | 先 a：留 `tests/mwrap/slint-ui`；最终收敛到 `tests/mcpp/`；构建包与库包分开测，构建包只测 `build.mcpp` 的简单功能（D9） |
| Q7 `rules/LICENSE` | 加；`STATIC_NOTICES` 不扩展 |
| Q9 slint 版本号 | 新 id 从头开始（首个版本 `1.19.0`），因为还没有使用者（D10） |
| Q10 mcpp issue | 一个 issue 汇总信息（D11） |

### 7.2 待决
- **Q8**（维护者未答）：实施顺序 T1 → T3 → T4 → T2，T2 可推后。暂按此（D12）。
- **R11**（自审引出，§8）：slint 还没有使用者，老的 `mcpplibs.slintgen` 是**冻结保留**（默认）还是**从索引删除**？
- **R12**（自审引出，§8）：U12 若实测要求规则版本等于包装包版本，D10 的“规则版本从 1.19.0 起”是否改为“规则版本等于包装包版本”？

## 8. 多视角自审

自审的方法：把 §1 到 §7 当作评审对象，分别站在九个角色的位置，逐条核对文档里的断言是否有证据、有没有漏掉的前提；能查的当场查（结果写在各条），查不了的转成 §6 的未验证项或 §7 的待决。

| 视角 | 检查点 | 结论 / 因此做的修改 |
|---|---|---|
| **R1 已有使用者与兼容** | 老 id、老版本、老归档、已安装 xpkg 是否全程可用；包装包对规则的 `reexport` 是否影响老版本 | 全程不动；包装包老版本自带老规则，不受影响。唯一的副作用是写死老 id 的使用者拿不到新版本（U10），已列出；slint 目前没有使用者 |
| **R2 索引维护与 CI 基础设施** | `pkgs/mcpp/` 会不会被发布、被 lint 覆盖 | **已查**：发布脚本 `tools/publish_mcpp_index.sh` 对整个 `pkgs/` 做 `cp -a`；`validate.yml` 的 lint 全部用 `pkgs/*/*.lua` 通配，所以 `pkgs/mcpp/` 自动被发布和 lint。需要适配的只有按 namespace 建视图的 `prepare_mwrap_indices.py`（U2）与成员选择（U3）。T4 验收里补了三个跨包检查 |
| **R3 引擎与客户端** | 新形态在 CI 固定的版本上是否零警告 | **已补测**：CI 固定 2026.11.18.1，我之前只测了 2026.11.20.1；用 v2026.11.18.1 复验 K、B、D、F，结果一致（§2）。更早版本没测（U13）。U1（目录 `mcpp`）仍未实测，已把验证放在 T4 |
| **R4 发布与流程** | 标签不移动、两处镜像、归档与 sha256、autoupdate | 新增：库绑定规则的描述符行指向包装包的归档，所以**不写 autoupdate**（§3.5），否则机器人可能给同一归档开第二条版本线。D10 引出的“规则版本与包装包版本脱钩”是新增风险（U12），在 T3 验收里实测 |
| **R5 第三方贡献者** | 一个陌生人按文档能不能把包放对位置、过 lint | 路径清楚：取 `<owner>.mplugin.<name>`，描述符放 `pkgs/mcpp/` 用完整 id，lint 反馈具体。空缺：没有给第三方的插件仓库模板；不在本计划范围，T6 之后再看 |
| **R6 安全与信任** | `mplugin` 是否会被误读成“已审计”；owner 抢注；官方 `mcpp.*` 冒用 | 新增 §3.9 与 U11：构建插件会在构建机上执行任意代码；owner 与抢注靠评审；lint 查不了“谁维护”，若有 CODEOWNERS 把 `pkgs/mcpp/mcpp.*` 归官方 |
| **R7 规范自身的一致性** | owner、种类段、保留名之间有没有漏洞 | 补了一条：owner 不得是种类段（`mwrap`、`mplugin`），否则出现 `mwrap.mplugin.x` 这类难读的 id（§3.2-3，T1 lint）。另：我之前把 `mrule` 说成“不会和官方混淆”是错的（官方也有 `mcpp.rules.*`），已在决定 Q1 的说明里更正 |
| **R8 测试策略** | 构建包与库包的测试是否分开 | 按 D9 写入 §3.4：构建包只测 `build.mcpp` 的简单功能；位置分两个阶段，避免现在为 `tests/mcpp/` 补一整套脚本分支 |
| **R9 迁移可行性与工作量** | slint 的 T3/T4 是否是已跑通流程的重复；有无新增步骤 | 主体重复我之前做过的 1.19.0.2 流程。新增的有三处：规则版本脱钩（U12）、`reexport` 键改名在固定版本上的验证、`pkgs/mcpp/` 首次解析（U1）。T4 不再依赖 T2（D12），顺序改为 T1 → T3 → T4 → T2 |
| **R10 可逆性** | 每一步出问题能否回退 | A1、T4、A2 是索引内 PR，出问题用后续 PR 修；已发布的行从不改；T3 的标签不移动，出问题发修订；老 id 全程可用，所以任何一步失败都不影响已有使用者 |
| **R11 slint 的老包（自审引出）** | 因为“还没有使用者”，是不是不必冻结老的 `mcpplibs.slintgen` | 删除可以让索引更干净，但已发布的归档、GitHub release 与 CN 镜像不会随之消失，且删除不可逆、与“老 xpkg 不删除、仍可用”的原则相悖；冻结没有代价。**默认冻结**，请维护者确认 |
| **R12 版本脱钩的退路（自审引出）** | 若 U12 实测失败怎么办 | 退回规则版本 = 包装包版本（`1.19.0.3`），D10 只保留“新 id、描述符独立”这一层；由维护者再定 |

自审修改汇总：补 owner 不得为种类段；补 §3.9 安全说明；补“在 CI 固定版本上复验”；库绑定规则描述符不写 autoupdate；T4 验收加三个跨包 lint 与首次 `pkgs/mcpp/` 解析；顺序改为 T1 → T3 → T4 → T2；新增 U11–U13 与 R11、R12 两个待决。

## 9. 执行记录（2026-11-21）

维护者以目标“按本文实施，每个仓库尽量单 PR，CI 通过后 squash 合入、发布，最后综合汇报”授权；未答的 Q8 按建议（顺序 T1 → T3 → T4 → T2），R11 按默认（冻结保留），R12 按 D10（实测通过则保持脱钩）。mcpp 项目只提一个 issue，不提 PR。

| 任务 | 结果 |
|---|---|
| T3 slint-m | PR #4 squash 合入（3a24e15），四个 CI 任务与 templates 通过；标签 `mwrap-1.19.0.3`，release 与 `mcpp-res/mwrap-slint` 的 `1.19.0.3` 归档逐字节一致（sha256 `d4e409ad…384b`） |
| T1 + T4 mcpp-index | 合并为一个 PR #868（3057883）：文档 + lint + `pkgs/mcpp/` 的第一个文件 + 老包冻结 + 成员 + 验收步骤；CI 全部通过（含 CI 固定的 mcpp 2026.11.18.1 上跑 `slint-rule`、`slint-ui`） |
| 发布验收 | 索引发布后，`check_installed_template.py --published-index` 在 GLOBAL 与 CN 两个镜像上冷装 `mcpplibs.mwrap.slint@1.19.0.3`：hello 模板无头 counter = 3，7 个许可证文件逐字节一致，重定位后的应用包通过；新 id `mcpplibs.mplugin.slint@1.19.0` 从已发布索引直接解析并运行；冻结的 `mcpplibs.slintgen@1.19.0.2` 仍可解析、构建 |
| T5 mcpp issue | 一个 issue：mcpp-community/mcpp#993（只提 issue，没有 PR） |
| T2 官方两包搬迁 | **推后，未做。** 原因：索引的下限 `min_mcpp = "2026.9.18.3"` 早于 mwrap 目录（2026-10-25）的引入，没有验证过下限版本的客户端能否从 `pkgs/mcpp/` 找到已有的 `mcpp.plugins`；它被几乎所有工程使用，而搬迁没有使用方的收益。新包不受影响（旧客户端本来就不会请求它们）。若要做：先在 2026.9.18.3 上用 `pkgs/mcpp/` 的索引解析 `mcpp.plugins`，再单独开 PR；mcpp-plugins 的 README（155 行）也引用了 `pkgs/m/mcpp.plugins.lua`，要同步 |

对 §6 的回写：
- **U1**（客户端从 `pkgs/mcpp/` 解析）：已确认，在 CI 固定的 mcpp 与已发布的索引上都成功。
- **U2**（`mcpplibs.mplugin` 视图）：不需要；成员使用整份候选索引。
- **U4**（mcpp-plugins 发布流程引用路径）：已核对，没有脚本引用，只有 README 的一句话；登记由人工完成。
- **U12**（规则版本 `1.19.0` 与包装包 `1.19.0.3` 脱钩）：已确认可行，解析与构建都正常；D10 保持。
- **U13**（比固定版本更早的 mcpp）：仍未测。
- **R11**：保持冻结；`mcpplibs.slintgen@1.19.0.1/.2` 仍可用。
- 测试成员的一个教训：`tests/mwrap/<member>` 只有 `build.mcpp` 而没有 `tests/*.cpp` 时，`mcpp test` 报 “no tests found” 并显示 ok，没有真的构建。构建包的成员也需要一个测试文件（`slint-rule` 的 `tests/generated.cpp` 编译 build.mcpp 让规则产出的头文件）。另外规则在 `build.mcpp` 里只登记动作，头文件要在动作运行后才存在，所以 `build.mcpp` 里不能检查产物。
