# mwrap 七库统一身份、README 精简与首次发布方案

状态：2026-10-25 设计评审后已获用户实施授权；执行进度见 [实施记录](2026-10-25-unified-mwrap-execution.md)。
下文的“本轮只写方案”等措辞记录设计阶段的边界，已被后续明确的实现、合入与发布授权替代。

## 1. 本轮决策与执行边界

用户最新确认：对外依赖、模板命令与 C++ 模块 import 显示完整 `mcpplibs` 前缀。
索引文件名省略完整 namespace 前缀，统一为 `pkgs/mwrap/<lib>.lua`；文件内仍声明完整身份。
README 在原有布局与栏目上精简，不再整页替换成同一套新结构；所有 `xxx-m` 仓库必须默认英文并提供中文 README。
Godot 命名已由用户确认：`mcpplibs.mwrap.godot_cpp`，不再作为待定建议。
七个封装库均新增 `mcpplibs.mwrap` 身份，旧身份、已发布版本、校验值与资源保留。
新 mwrap 身份首次发版直接使用所封装的上游版本，不机械继承旧封装修订尾号。

本文通过 review 后再实施：更新相关 PR → 自我 review 与完整 CI → squash 合入库 → 验证合入提交 → 发布库 → 更新并合入索引。
当前“先不要动代码”的要求优先于上述后续执行步骤；本轮不开始发布操作。
mcpp 引擎源码继续只读；不因本次命名统一新增引擎功能，也不依赖独立文档 PR #836 合入。

## 2. 包身份、文件名与 import 分别处理

| 层次 | 统一约定 | FFmpeg 示例 |
|---|---|---|
| 仓库 | 沿用 `<upstream>-m` | `mcpplibs/ffmpeg-m` |
| 包 namespace | `mcpplibs.mwrap` | `namespace = "mcpplibs.mwrap"` |
| 包 short name | 单个原子段，无点，无 `-m` 后缀 | `name = "ffmpeg"` |
| 描述符路径 | 分类内平铺，文件名省略 `mcpplibs.mwrap.` | `pkgs/mwrap/ffmpeg.lua` |
| manifest 依赖 | 显示完整身份，推荐 TOML dotted key | `mcpplibs.mwrap.ffmpeg = "8.1.2"` |
| 模板命令 | 与依赖使用相同完整身份 | `mcpp new media --template mcpplibs.mwrap.ffmpeg@8.1.2` |
| 根模块 | 完整 `mcpplibs.mwrap.<lib>` | `import mcpplibs.mwrap.ffmpeg;` |
| 子模块 | 沿用上游分组 | `import mcpplibs.mwrap.ffmpeg.avcodec;` |
| 普通 API | 保留上游名字、namespace 和类型身份 | `avcodec_find_decoder(...)` 等 |
| 宏映射 | `<root>.macros`；映射 namespace 独立 | `mcpplibs::mwrap::ffmpeg::macros` |

```toml
[dependencies]
mcpplibs.mwrap.ffmpeg = "8.1.2"
mcpplibs.mwrap.opencv = { version = "5.0.0", features = ["imgproc", "imgcodecs-png"] }
```

```lua
-- pkgs/mwrap/ffmpeg.lua（只表示目标身份，非完整安装配方）
package = {
    spec = "1",
    namespace = "mcpplibs.mwrap",
    name = "ffmpeg",
    -- xpm、mcpp、license 等沿用经过验证的配方并指向新发布资源。
}
```

完整身份只有一个。不要另建 `namespace = "mwrap"` 的第二套包，不通过重复描述符模拟别名；
也不要写成 `namespace = "mcpplibs", name = "mwrap.ffmpeg"`。
C++ 的 `import` 没有包选择器的省略规则，必须与实际 `export module` 完全一致。

### 2.1 分类内短文件名与字母子目录

最新补充采用 `pkgs/mwrap/ffmpeg.lua`：目录已经表达封装分类，文件名不再重复 `mwrap.` 或 `mcpplibs.`。
`opencv.lua`、`onnxruntime.lua` 等同理。各分类目录的同名文件不代表相同身份，必须检查 descriptor 声明。

按字母分组会形成 `pkgs/mwrap/f/ffmpeg.lua`。当前固定客户端只扫描 pkgs 根和一级分类，不能保证发现第二级目录。
因此本轮选择“平铺分类 + 裸 short name 文件名”；不增加字母子目录、不发布转换副本、不为此修改 mcpp。
未来只有通用递归发现/发布协议实际支持并经过端到端验证后，才另行评估字母分组。

### 2.2 已核实的 mcpp 行为

核对已发布 `v2026.10.24.1` 的实现与文档，而非仅依赖本地较旧 main：

- `normalize_package_selector`：没有 namespace 的裸名采用默认 `mcpplibs`；带点选择器的最后一段是 name，前面是精确 namespace。
  因此 `mwrap.ffmpeg` 表示 `(mwrap, ffmpeg)`，并不等价于 `(mcpplibs.mwrap, ffmpeg)`。用户已确认不采用该简写。
- `xpkg_lua_candidates` 的推荐快路径使用全名，但 fetcher 有 identity-first fallback：扫描 `pkgs` 根和一级子目录，按 descriptor 声明的身份匹配。
  所以 `pkgs/mwrap/ffmpeg.lua` 可以承载完整身份；文件名不要求等于 FQN。
- 目录只增加一层分类，不使用 `pkgs/mwrap/f/` 等二级嵌套；不做 staging 路径转换。

这证明客户端发现规则允许缩短文件名，不等于已证明索引的每个外围脚本均支持。
实施时必须验证发布、lint、站点、变更影响分析、updater 和 provider 加载路径；修改索引适配即可，不改引擎。

证据：

- [发布版 selector 实现](https://github.com/mcpp-community/mcpp/blob/v2026.10.24.1/modules/manifest/src/dependency_selector.cppm)
- [发布版 descriptor 发现实现](https://github.com/mcpp-community/mcpp/blob/v2026.10.24.1/src/pm/package_fetcher.cppm)
- [发布版依赖语法](https://github.com/mcpp-community/mcpp/blob/v2026.10.24.1/docs/05-dependencies.md)

## 3. 七库新身份与版本映射

以下“当前版本”为现有未合入候选，不代表新 mwrap 已发布。上游版本依据当前源码 pin；本轮不顺带升级上游。

| 仓库 / 现有 PR | 当前候选身份与版本 | 新完整身份 | mwrap 首发版本 | 描述符文件名 |
|---|---|---|---|---|
| opencv-m #1 | `mcpplibs.mwrap.opencv@5.0.0.1` | `mcpplibs.mwrap.opencv` | `5.0.0` | `opencv.lua` |
| onnxruntime-m #1 | `mcpplibs.mwrap.onnxruntime@1.25.1` | `mcpplibs.mwrap.onnxruntime` | `1.25.1` | `onnxruntime.lua` |
| llama.cpp-m #5 | `ggml-org.llamacpp@b10069.3` | `mcpplibs.mwrap.llamacpp` | `b10069` | `llamacpp.lua` |
| ffmpeg-m #8 | `ffmpeg.ffmpeg@8.1.2.1` | `mcpplibs.mwrap.ffmpeg` | `8.1.2` | `ffmpeg.lua` |
| grpc-m #8 | `grpc.grpc@1.83.0.1` | `mcpplibs.mwrap.grpc` | `1.83.0` | `grpc.lua` |
| imgui-m #13 | `ocornut.imgui@1.92.8.1` | `mcpplibs.mwrap.imgui` | `1.92.8` | `imgui.lua` |
| godot-cpp-m #1 | `godotengine.godot-cpp-m@10.0.0-rc1.1` | `mcpplibs.mwrap.godot_cpp` | `10.0.0-rc1` | `godot_cpp.lua` |

Godot short name 已确认为 `godot_cpp`：与原 module spelling 对应，适合直接作为 C++ 模块名的一段；
仓库仍为 `godot-cpp-m`，供应者仍为 `compat.godot-cpp`。该映射在正式规范中明确记录。
`llamacpp` 保留既有辨识名称，避免把 `llama.cpp` 的点误表达为额外 namespace。
`b10069` 使用精确 pin，不承诺 semver 范围；Godot 仍为 prerelease，不标为稳定引擎兼容认证。

首发后的封装修复才追加单个修订尾号，例如 `8.1.2.1`、`b10069.1`；上游升级后重新从对应原始版本开始。
新身份首发去尾号不表示可以将已经发布的同身份版本降级、覆盖或重用。
发布前再次查询新 FQN 是否已存在；若出现同身份同版本资源，先核对不可变性，不直接替换。

### 3.1 统一的不只是 dependencies 字符串

五个旧身份库需要同步修改 package metadata、`export module`、内部 module imports、examples、tests、模板、构建代码中的显式包/模块名。
原有 `ffmpeg.*`、`llamacpp`、`grpc`、`imgui.*`、`godot_cpp` 模块迁到完整 mwrap 前缀。
原 C/C++ API namespace 和实体保持不变，不将 `ImGui::`、`grpc::`、`godot::` 等改名。
补齐各库的 `.macros` 映射入口，文本预处理桥仍可用于 token/control-flow 宏；不伪造宏导出。

供应者、编译规则和 host tools 按职责保持独立。`compat.ffmpeg`、`compat.godot-cpp`、`compat.onnxruntime` 等不是模块封装层，不迁入 mwrap。
gRPC 的 protoc/plugin/代码生成规则仍为工具包，不为“统一七个 wrapper”而全部改成 mwrap。
但其依赖、宿主/目标版本绑定和新源码发布地址必须一起核验，避免新 wrapper 依赖仅存在于未发布候选中的工具版本。

OpenCV→FFmpeg 的实现依赖仍使用对应 compat 供应者；OpenCV→ORT 继续遵守既定所有权与 ABI 边界。
同一程序不得因为新旧 wrapper 混用而链接两份相同上游实现。迁移说明提示整体迁移；必要时配置阶段明确拒绝冲突，不承诺旧/新模块任意混合。

## 4. README：保留原结构再精简

所有 `xxx-m` 仓库（不限于本轮七库）必须满足：

- `README.md` 为默认英文入口；中文统一使用 `README.zh.md`。
- 两份 README 顶部提供双向语言链接：英文页链接 `简体中文`，中文页链接 `English`。
- 两种语言都必须包含相同的核心能力、依赖/模板命令、版本、平台前提和限制；代码和命令保持一致。
- 缺少中文版本的仓库必须补齐；已有中文为主的默认页，应按原布局提供英文默认页，并将中文内容整理到中文页。
- 每种语言通常约 100 行以内；英文与中文不要求字数或行数机械相等，不能只翻译标题而省略关键限制。

“统一风格”约束语言、密度和可用性，不强制七库采用完全相同的标题或顺序。
基线使用各 PR 当前 base 的 README（含对应翻译）；保留项目标题、logo/少量有效 badge、语言入口、原一级/二级栏目及顺序。
保留布局不要求保留中文栏目标题在英文页中：标题和正文按页面语言翻译，栏目语义、层级与顺序保持对应。
修正失效链接、CI 仓库地址、license 标签等事实错误，不为保留外观继续展示错误信息。
每种语言通常控制在约 100 行以内；完整矩阵、长示例、平台细节移到 docs，并在原栏目保留短摘要和链接。
不通过压成超长行、删除必需前提或把所有内容塞入折叠块来满足行数。

| 仓库 | 已核查的原 README 结构 | 精简方式 |
|---|---|---|
| OpenCV | badge/CI → Characteristics → Getting started → Modules → Features → Examples → Build and toolchains → License | 保留栏目与模块/feature 摘要，快速开始使用新模板，完整矩阵链接 docs |
| FFmpeg | badge/CI → 核心特性 → 快速开始 → 模块一览 → 示例 → 工具链与运行时 → License | 原约 86 行，重点修订身份、版本与示例，避免不必要重排 |
| ImGui | badge/CI → 核心特性 → 快速开始 → 模块一览 → Features → 示例 → 工具链与运行时 → License | 原约 101 行，压缩重复说明，保留 headless/window/docking 区别 |
| llama.cpp | Add The Package → Minimal CPU Program → CPU/Metal/Vulkan Chat → Supported Boundary | 各后端栏目保留，长命令与 shader 原理转 docs，CPU 默认模板无模型资产也能运行 |
| gRPC | Quick Start → Two ways to use it → Code generation → More control → Platform support → Features → Build/test → License | 保留两种使用方式和代码生成栏目，构建内部说明转 docs，平台限制不删 |
| Godot | Install → Macros → hashfuncs shim → Example → Regenerating → Tests → License | 长 shim/扩展示例转 docs，原栏目保留摘要；独立 math 和引擎加载分清 |
| ORT | 原基线仅两行占位 | 没有成熟布局可恢复，沿用候选已建立的入门结构，与生态字体、代码块和链接风格对齐 |

验收时并排查看 base 与新 README：栏目/顺序、badge 与语言入口、关键示例、约 100 行、实际命令均核对。
中英文必须同步；根据当前 checkout，OpenCV 和 gRPC 已有 `README.zh.md`，ORT、llama.cpp、FFmpeg、ImGui、Godot 五库需要新增中文页。
这里是补齐翻译，不是重新设计整页布局；ORT 的占位基线例外只影响栏目设计，不豁免英文默认和中文支持。
中英 README 的双向链接、文档锚点、badge、许可证链接应分别验证；不能假设标题翻译后的锚点相同。
索引规范 `docs/mwrap.md` / `docs/zh/mwrap.md` 与 authoring skill 改为“保留既有结构的精简原则”，去掉强制整页重排的要求。

## 5. 索引目录与历史资源策略

```text
pkgs/
  mwrap/
    opencv.lua
    onnxruntime.lua
    llamacpp.lua
    ffmpeg.lua
    grpc.lua
    imgui.lua
    godot_cpp.lua
  f/ffmpeg.ffmpeg.lua             # 已发布历史保留
  g/ggml-org.llamacpp.lua          # 已发布历史保留
  g/grpc.lua                      # 已发布历史保留
  g/godotengine.godot-cpp-m.lua    # 已发布历史保留
  o/ocornut.imgui.lua             # 已发布历史保留
  o/opencv.opencv.lua             # 已发布历史保留
tests/
  mwrap/                         # 七个新身份的消费者/归档/模板测试
  examples/                      # 旧身份消费者继续覆盖历史资源
```

当前未合入的两个 `pkgs/mwrap/mcpplibs.mwrap.*.lua` 重命名并更新为新首发版本；不保留同身份第二份 descriptor。
另外五库新建 mwrap descriptor，不移动或重定向历史 descriptor。
现有索引 PR 向旧描述符加入的“尚未发布候选”条目要从最终 diff 撤回；已发布条目逐字节保留，不能把两者混为一谈。
若供应者确有本轮必需的功能修订，独立解释其变更与版本，不以 wrapper 迁移名义改写已有资源。

索引工具统一从 descriptor 的 `(namespace, name)` 读取身份，不从短文件名或分类目录推断包 namespace。
审查并适配：发布枚举/内容 hash、镜像与 manifest、Lua lint、保留 namespace、跨包引用、站点/搜索、updater、changed-files→member 映射、shards 和缓存 key。
特别检查现有 updater 的 tag 模板及 descriptor 按名定位，避免缩短文件名后漏更新或更新旧身份。
保留 `min_mcpp` 作为兼容下限；不能仅因测试固定新版本就机械提高。

### 5.1 mcpp-index 文档、规范与 skill 同步清单（必交付）

这不是只改描述符路径的任务。下面各文件须与实现处于同一索引 PR，不能留到发布后补文档。
本轮仍只写方案；实际同步在方案 review 通过后执行。

| 文件 / 入口 | 必须更新的内容 |
|---|---|
| `docs/mwrap.md`、`docs/zh/mwrap.md` | 正式规范唯一来源；七库统一完整身份，`pkgs/mwrap/<lib>.lua`，无字母子目录，首次上游原版本、独立 mwrap tag、API/macros 与兼容边界 |
| 上述规范的 README 小节 | 明确 `README.md` 默认英文、`README.zh.md` 必须提供且双向链接；保留原布局/栏目再精简；约 100 行是每语言编辑目标，删除强制统一标题顺序的旧要求 |
| `docs/repository-and-schema.md`、`docs/zh/repository-and-schema.md` | 将 `<完整身份>.lua` 改为 `<lib>.lua`；说明文件名、分类目录与声明身份的区别；源码与发布布局一致 |
| `docs/package-types.md`、`docs/zh/package-types.md` | 核对 wrapper / compat / native / host-tool 分类说明及交叉链接，示例采用完整 FQN 与新目录规则 |
| `README.md`、`README.zh-CN.md` 及站点包列表入口 | 核对规范导航与示例；存在旧 mwrap 路径或旧 wrapper 身份时同步更新，避免全站重复维护规范正文 |
| `.agents/skills/add-mcpp-index-package/SKILL.md` | 写 descriptor 的步骤、目录特例、英文默认且中文必备/双向链接的 README 规则、首发/tag/updater 约束、示例与常见错误表全部同步；保留完整身份验收与不可变资源规则 |
| `.agents/docs/` 的现有实施/验收记录 | 保留历史事实；在本次实施的验收记录中链接本方案并标注旧决策已被替代，不将旧绿灯写成新版本结果 |
| descriptor/example 模板和脚本使用说明 | 若有固定 `<full-identity>.lua` 或从文件名拆 namespace 的约定，同步为读声明身份；实际代码适配由实现阶段完成 |

实施 skill 修改前按 `skill-creator` 与目标 skill 的实际要求读取说明；不创建第二份重叠 skill，不修改 mcpp 仓库的引擎或技能文件。
规范示例统一展示 `mcpplibs.mwrap.*`；不要让 README、skill 或模板再次推广 `mwrap.*` 依赖简写。

文档验收：

- 中英规范、仓库 schema 说明与 skill 的命名/路径/版本/tag/README 规则逐项对照；README 的英文默认和中文必备不能写成可选。
- 搜索旧路径约定、旧短身份和强制重排措辞；历史记录与旧包示例可以保留，但必须有明确上下文。
- 所有新示例的 dependency、`mcpp new`、`import`、descriptor FQN 互相对应，链接指向真实文件。
- 代码评审表同时检查实际实现与文档，不能仅因文字替换完成就判定 loader/updater 支持。

## 6. 版本与 tag：包版本对齐，上游同名旧 tag 不覆盖

2026-10-25 经 GitHub API 查询，各仓库已有：

| 仓库 | 与目标上游版本相同的旧 tag | 已有该 tag 的 release |
|---|---|---|
| OpenCV | `v5.0.0` | 无，但 tag 已存在 |
| ORT | 无 `1.25.1` / `v1.25.1` | 无 |
| llama.cpp | `b10069` | 有 |
| FFmpeg | `v8.1.2` | 有 |
| gRPC | `v1.83.0` | 有，另有 `v1.83.0-2/-3/-4` |
| ImGui | `1.92.8` | 有 |
| Godot | `v10.0.0-rc1` | 有 |

“新 mwrap 身份首次发版”不等于“Git 仓库没有历史版本”。已有 tag 的源码携带旧身份或旧接口，不能给新包复用这些归档。
建议七库统一采用独立 tag 序列 `mwrap-${version}`：例如 `mwrap-8.1.2`、`mwrap-b10069`、`mwrap-10.0.0-rc1`。
包 version 仍分别是 `8.1.2`、`b10069`、`10.0.0-rc1`；release title 使用 `mwrap.ffmpeg 8.1.2` 这类可辨认名称。
tag 的 mwrap 前缀用于隔离同仓库历史，不是额外封装版本尾号。ORT 也采用同一规则，避免每库一套规则。
未来修订 tag 为 `mwrap-8.1.2.1` 等，已发布 tag、release asset 与 SHA256 永久不变。
updater 新 mwrap 配方只匹配新 tag 序列；旧配方不能把新 tag 当作旧 namespace 的后续版本自动提案。
不能仅依赖 GitHub 的 latest release：同仓库混有旧序列与 mwrap 序列，必须显式筛选 tag、去除准确的 mwrap 前缀后再核对 manifest/package version。
新增回归覆盖旧 tag 被新 updater 拒绝、新 tag 被旧 updater 忽略、`b10069` 精确版本及 Godot RC 的 prerelease 策略。

如果 review 决定 tag 也必须完全等于旧的上游同名 tag，则与“旧资源保留”冲突；不能用强推旧 tag 解决。
本方案默认采用上述独立 tag 序列，不另建七个仓库。

## 7. 实施与 squash / release / 索引顺序

### A. 设计通过后更新现有 PR

复用七库现有 PR 和 index #564，不另开重复实现 PR。保留 checkpoint commits 直到 review 完成。
依次更新 manifest/模块身份与版本、内部 import、宏映射、模板、消费者、README 和规范/skill。
索引 PR 可提前准备 candidate-only 归档描述符供 CI，但不先合入，也不把临时 namespace 视图当发布布局证明。
检查每个供应者/host tool 的正式可用版本；必须新增的依赖先完成独立验证和发布。

### B. 自我 review 与所有最终 CI

已有旧 HEAD 的全部绿灯只作为基线，新身份/模块/版本修改后必须重新完整通过。
每个 PR HEAD 对齐实际归档 pin，检查完整必需 workflow，不将 skip、旧 run、局部步骤或超时计作通过。
本地重型测试串行，合计四核 quota、32 GiB cap；整机 CPU 达到 80% 或可用内存低于 20% 则中止任务测试。

### C. squash 合入库并验证真正发布提交

取消 draft 前完成 review 清单，检查分支保护、mergeable 和最新基线差异；有冲突则解决并重跑相关最终检查。
库 PR 使用 squash merge；checkpoint 保留在 PR 历史，最终 squash commit 提供清楚的问题、行为与验证说明。
合入后记录真正 main SHA，等待该提交的必要 CI 成功。PR HEAD 的归档 hash 不能冒充 squash SHA 的归档 hash。
按供应者/被依赖库先行，再处理消费者；新 wrapper 的供应者和 host tools 必须有可获取且校验过的正式资源。
库 source CI 若依赖本轮尚未公开索引的新 wrapper，用独立完整候选索引固定精确归档验证；不要求为了消除循环而先合入公共索引。
库 release 先行期间，README 明确“新身份需待索引发布后可直接安装”；此时不能宣布公共快捷模板已经可用。

### D. 库 release

对已通过的 squash SHA 创建独立 mwrap tag；核查 tag 指向、manifest 首发版本、上游 pin、许可证与产物后发布。
从实际 tag/release 下载正式归档，计算 SHA256、核对源码与打包闭包；GitHub/GitCode 镜像地址只有实际上传并验证后才写入。
先建立可验证的发布物，再声称库已 release；不能只建空 release 或仍指向 PR commit。
Godot RC release 标为 prerelease；llama 的非 semver tag 不因含字母就自动判为 prerelease。
发布源归档/选中 notices，并按现有受支持平台规则提供所需运行资源，不把上游 SDK 大二进制直接提交 Git。

### E. 最后统一更新并发布索引

七库正式资源可获取后，将 index #564 的七个新 descriptor 切换为正式 mwrap tag/release URL 和真实 SHA256。
使用完整候选索引在独立 home 验证；不从已安装源码、用户全局索引或旧包缓存误取同名产物。
新版本依赖、模板默认值、workspace 测试、updater 版本和 docs 同步；旧版本条目不变。
索引所有最终 workflow 通过后 squash 合入；再检查 main 发布流程和实际发布索引的七库发现、模板安装与运行。
只有这一步通过，才宣布七库公共索引和默认模板整体可用；候选索引通过不能替代公共索引验收。
若库先发布而索引仍待通过，可保留未被公共索引引用的 release，修复索引；不得重写已经发布的库资产。

## 8. 具体验收清单

| 范围 | 必须提供的证据 |
|---|---|
| 身份 | 七库 manifest、descriptor、lock、安装日志均命中唯一完整 mwrap FQN；无旧身份误命中 |
| 缩短文件名 | `<lib>.lua` 携带完整身份，path/Git/发布归档发现均通过；lint/updater/站点按声明身份处理 |
| 源码模块 | 根/子模块 import、内部依赖、API namespace 与原类型身份正确；五库不能只替换 manifest 名字 |
| README | 七库各有英文 `README.md` 和中文 `README.zh.md`，顶部互链；与原 base 布局并排检查，原栏目语义/顺序保留，每语言约 100 行，命令、版本、平台限制和链接一致 |
| 快捷模板 | 七库默认 `mcpp new --template <完整FQN>@<首发版本>` 原样生成、build/run；窗口/视频/ORT 等附加模板分别验证 |
| 共存边界 | 新旧描述符均可发现，旧资源 hash 不变；应用不误链接两份 SDK；实际新包消费不依赖旧模块别名 |
| gRPC 工具链 | protoc、plugin、rule、runtime 版本一致；host 与 target 区分；正式发布资源无悬空依赖 |
| OpenCV / ORT | 保留五平台范围、十六模块与 SDK/API oracle；原生窗口、CPU 实际 session profile、codec/视频与搬迁回归 |
| 归档部署 | 最终 squash/tag 源、hash、manifest、模板一致；fresh-home 安装、release pack、隔离搬迁、选中 notices 与 loader 闭包 |
| 发布与索引 | 每库 PR HEAD CI、合入 SHA CI、tag 指向及正式资源均核对；索引最终 HEAD 和 main 发布检查通过 |
| 文档/skill | 索引中英 mwrap 规范与 authoring skill 同步身份、短文件名、README 保留布局且英文默认/中文必备、首发/tag 规则；不改 mcpp 引擎 |

相同版本新旧 identity 的缓存/安装隔离需专门验证，尤其 Godot 曾有同 short name/version 的历史 lookup 限制注释；
不能用改个版本尾号掩盖当前工具行为。本方案 Godot 新 short name 为 `godot_cpp`，其他同名跨 namespace 仍要测。
上述验证按实际风险组合，不要求无意义的 feature 全排列；不降低已有功能测试覆盖。

支持范围沿用明确矩阵：ORT CPU、Godot 独立 math、llama CPU 初始化等；设备、GPU、contrib、非基线 ISA 与 API 未覆盖项继续如实列出。
当前 OpenCV 20 个 partial/未实现 intrinsics/架构审查记录不因重命名或 release 而变为通过；不发布“所有 API/硬件全支持”的声明。

## 9. 需要 review 的核心决定

1. 已确认：显示完整 `mcpplibs.mwrap.*`；文件采用 `pkgs/mwrap/<lib>.lua`，省略两个 namespace 前缀，目录内平铺，不修改引擎解析。
2. 七库全部建立新 mwrap 身份，旧 descriptor 与已发布历史原样保留；同身份 descriptor 不重复。
3. 首发包版本使用上游原版本；Godot 新 short name 已确认 `godot_cpp`，llama 保持 `llamacpp`。
4. 为避开已有上游同名 tag，统一新 `mwrap-${version}` tag；release 展示上游版本，绝不覆盖旧 tag。
5. 所有 `xxx-m` 仓库必须默认英文 `README.md`，提供中文 `README.zh.md` 并顶部互链；保留原布局再精简，每语言通常约 100 行；ORT 占位基线不豁免双语要求。
6. 索引中英规范、schema/包分类文档与现有 authoring skill 必须同步，详见 §5.1。
7. 本轮只交付本文。review 通过后再更新代码；所有新检查通过后库逐个 squash/release，最后统一更新与合入索引。

## 10. 本轮核查记录

- 权威实施 checkout：`/home/speak/workspace/github/mcpp-community/mcpp-index-mwrap`，分支 `feat/mwrap-opencv-onnxruntime`，起点 `48640fc7183d428999111f01a6c3c642179ad38d`。
- 七库 PR 当前 open/unmerged；README 原布局从各 PR base SHA 的 `README.md` 读取，并核对当前 manifest/module 声明。
- tag/release 清单通过 GitHub REST 查询；明细留在 `/tmp/mwrap-unified-design-release-state.json`，发布实施前需再次查询。
- mcpp 发布版三份源码已通过 contents API 读取；selector / compat / fetcher blob SHA 分别为 `758853758c78edba0a66f5418025bd1e6f2dcbac`、`dd8832e26c197251c39db45606d41da2a6383699`、`2a4007c4f04764489f82f2a2eda39b12ca5375b9`。
- 本轮未运行编译、未更新全局索引、未修改产品文件、未提交或 push；原方案文档及用户原始文件保留。


## 11. 综合自我 review（本次修订）

本节是方案审查结果，不把尚未实施的修复或 CI 标为完成。

| 视角 | 发现与处理 | 实施时的验收证据 |
|---|---|---|
| 用户体验 / 国际化 | 旧稿“没有翻译不要求新增”与新要求冲突，已删除；七库及未来 xxx-m 均英文默认、中文必备。FFmpeg/ImGui 原中文栏目只保留布局语义，英文页必须译成英文 | 七库共十四份语言 README，顶部互链；实际命令、限制、版本一致 |
| 命名 / 工具兼容 | 显示完整 FQN，文件短名与声明身份分离；Godot 已确认。目录内平铺规避现有客户端二级目录发现限制 | 全索引解析短文件名、唯一 FQN、单独/聚合模块 import 与安装来源 |
| 历史兼容 / 缓存 | 新身份可以使用上游原版本，但不能覆盖旧 tag 或误取旧缓存；同时链接新旧实现有重复定义风险 | 已发布资源不变、fresh-home 精确解析、旧包消费者、混用冲突诊断 |
| 构建 / API | 只改依赖键不够，五库模块声明、内部 import、模板和宏桥需要整体迁移；上游 API namespace 保持原样 | 七库新 HEAD 的真实默认模板/API/SDK 对照与平台 CI；旧绿灯不替代 |
| 发布 / 依赖顺序 | squash 改变提交与归档身份；库先 release、索引后发布存在短暂不可公共安装窗口，已明确候选索引验收和对外可用的分界 | 合入 SHA CI、tag 指向、新归档 hash、候选索引及最终公共索引安装/搬迁 |
| 自动更新 / 维护 | 同仓库新旧 release 序列可能污染 latest 与 updater；已增加严格 tag 过滤和双向隔离回归要求 | 新旧 tag 互斥选择、非 semver/RC 测试、manifest 版本比对 |
| 文档 / 规范 / skill | 规范强制顺序与“保留原布局”冲突，需一起更新；不得只改 README 留下 skill 再次生成旧布局 | §5.1 文件同步对照，英/中文规范和 skill 示例一致，链接/代码块/模板验证 |
| 范围 / 资源 | 本轮只改设计稿；后续重命名不扩张成 GPU/contrib/API 完整性承诺；本地整机 80% 资源上限继续有效 | 设计阶段仅本文变化；实施阶段明确支持矩阵、资源限制和全部必需 CI |

审查结论：本次需求已纳入方案，未发现必须修改 mcpp 引擎才能落地的命名或目录需求。
独立 `mwrap-${version}` tag 仍是为保留旧发布提出的方案建议，待用户 review；Godot 命名和 README 双语规则已是确认要求。
代码、双语 README、规范/skill 和 CI 的实际完成情况在实施后逐项验收，本轮不提前宣称完成。
