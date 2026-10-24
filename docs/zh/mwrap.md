# 模块化封装：mcpplibs.mwrap

`mcpplibs.mwrap` 为已有 C/C++ 头文件库提供模块入口；原生模块项目仍位于各自的直接命名空间下。
封装保持上游 API 名称、namespace、类型身份、重载与行为。这里不重新设计上游 API。

[English](../mwrap.md)

## 命名与实现归属

| 对象 | 约定 | 示例 |
|---|---|---|
| 仓库 | `<上游库名>-m` | mcpplibs/opencv-m |
| 包命名空间 | mcpplibs.mwrap | C/C++ 封装统一分类 |
| 包短名 | 上游库名，单个原子段 | opencv |
| 根模块 | 完整包身份 | mcpplibs.mwrap.opencv |
| 子模块 | 沿用上游功能分组 | mcpplibs.mwrap.opencv.core |
| API | 保留上游 | cv::Mat、Ort::Session |
| 宏映射模块 | `<根模块>.macros` | mcpplibs.mwrap.opencv.macros |

包和模块名不带 -m，不创建另一套普通 API namespace。已发布旧身份、版本和内容保持不可变，
通过新 mwrap 身份迁移。简单实现优先依赖 compat.xxx；复杂库可以 vendor 到 upstream/。
同一程序的同一实现只能有一个所有者，不能把 compat 与 vendored 实现重复链接。

## 仓库分层

```text
<库名>-m/
  mcpp.toml / build.mcpp / .xlings.json
  upstream/              来源、版本、校验和、许可证；需要时含原始源码
  patches/               最小可重放补丁与原因
  port/                  适配实现、兼容头、配置模板
  src/<库名>.cppm        公共根模块
  src/macros.cppm
  generated/             必须提交的稳定可复现生成物
  templates/<名称>/     快捷模板
  tests/                 API、行为、混用与安装后消费
  tools/                 同步、生成与审计
```

上游与适配分开，记录 tag/commit、SHA256、裁剪与许可。按 feature/target 变化的生成文件
写入构建输出目录，不能覆盖共享源码。获取依赖由 provider 负责，不在模块编译时偷偷下载。

## 版本

版本与上游一致，最多追加一个数字封装修订段，例如 5.0.0、5.0.0.1、5.0.0.2。
上游升级到 5.0.1 后从 5.0.1 重新开始；修订从 1 开始，不发布排序等同原版本的 .0。
不使用独立 0.x 封装版本，不修改上游 patch 号冒充封装修复，不使用 +build 进行升级排序。
metadata 与上游锁文件仍明确记录来源。破坏性模块/API 变化必须附迁移说明。
非数字或预发布上游版本需要明确映射规则，保持原版本含义。

## 导出与宏

优先 export using 上游实体，每个实体仅有一个导出归属，根模块聚合已启用的公共模块闭包。
以公共 C/C++ 头文件审计模板、重载和函数，不把绑定标记当完整清单，不静默 prune 失败导出。
内部链接实体确需替换时列出清单并验证语义。

模块不能传递预处理宏。常量可映射为 constexpr，可保持语义的计算宏可映射为函数；
映射置于 mcpplibs::mwrap::<库名>::macros，保留原宏名。字符串化、token 拼接、条件编译、
控制流宏通过 `<mwrap/<库名>/macros.hpp>` 保留，在 import 前 include。
限定名仍会被宏展开；原始宏与映射常量的用法必须分别测试，断言函数不能默认代替断言宏。

## feature

采用小写 kebab-case，复用上游术语：模块 dnn/highgui/stitching；后端 highgui-gtk3、
videoio-ffmpeg、dnn-onnxruntime；格式 imgcodecs-png/imgcodecs-tiff；跨模块依赖 opencl/tbb/lapack；
扩展 contrib-<上游模块名>；模块全集 all-modules 必须给出展开清单。

feature 为加法并集，通过 implies、依赖转发、feature-deps 与 target 条件表达。
消费者可通过依赖边的 default-features=false 关闭该边的默认集合，显式 feature 仍激活；其他边仍可能要求默认项。
可替换/大体积后端使用明确命名的 feature 门控。
模块 API 与实际运行后端分开说明，缺失目标/SDK 与冲突组合明确报错，不能静默跳过。
capability 选择不会自动移除另一份实现对象文件，必须先防止重复运行库进入图。
记录 ABI、CPU baseline、C++ runtime 和 SDK 约束。

## README 风格

所有 `<库名>-m` 仓库使用统一、简洁的入口风格，README 原则上不超过 **100 行**。
已有多语言 README 各自遵守同一结构和长度目标，内容保持对应。

推荐顺序：项目名与一句定位 → 快捷模板 → 已有项目接入与最小 import 示例 →
关键能力/平台边界 → 详细文档、示例与许可证入口。快速开始优先展示完整包身份和可直接执行的命令。

只保留影响首次使用的必要信息；架构、完整 feature/API 矩阵、后端配置、排错、验证记录
及版本历史放入 `docs/`，从 README 链接。避免徽章墙、重复导航、大表格、长篇实现解释、
checkpoint 日志及“后面继续追加”的更新记录，也不要用超长行或删掉必要前提来凑行数。
未发布候选、设备/SDK 前提和重要使用限制仍须简短说明；约 100 行是编辑目标，不新增用户审批环节。

## 每个 -m 包必须有可运行快捷模板

至少提供一个默认 templates/<名称>/template.toml 与项目骨架。默认模板不要求 GPU、摄像头、
桌面会话或另行下载模型/数据；高级模板单独说明前提。

```sh
mcpp new vision --template mcpplibs.mwrap.opencv@5.0.0
mcpp new --list-templates mcpplibs.mwrap.opencv@5.0.0
mcpp new viewer --template mcpplibs.mwrap.opencv@5.0.0:window
```

模板是纯数据，不执行 hook。当前 mcpp 的 self.name 为完整包选择器，应作为一个带引号的 key：

```toml
[dependencies]
"{{self.name}}" = { version = "{{self.version}}", features = ["imgproc", "imgcodecs-png"] }
```

不能再把 self.name 放入另一层 namespace 表。版本与 self.version 绑定，明确所需 feature。
测试必须执行实际 mcpp new 后 build/run；未发布候选可使用隔离的已安装包 fixture，
先确认渲染的身份与版本，再添加本地依赖覆盖。发布归档也必须携带模板。

## 本地测试资源预算

本地测试合计 CPU 与内存占用不得超过本机有效资源的 **80%**；按物理资源、CPU affinity
与容器/cgroup 限额取实际可用值，默认预留更多桌面余量。上限覆盖全部并发测试及其依赖构建、
代码生成、编译器和 AST 子进程，不能让每个任务各占 80%。

启动前检查负载与可用内存，限制构建并发和同时运行的重型任务；运行中监测资源。
Linux 可使用任务专属 cgroup/systemd slice 设置 CPU/内存共享上限，并用 MCPP_JOBS 控制构建并发。
接近预算时降低并发或等待本任务的构建结束，不停止用户的其他进程；资源限制不替代验证门槛。

## 索引与验收

描述符平铺于 pkgs/mwrap/<完整身份>.lua，消费者置于 tests/mwrap/<成员>/，不再增加字母子目录。
客户端按声明身份扫描 pkgs 的一级分类目录，发布原样复制，无需 staging 转换。
测试注册 workspace，并接入选择器、分片、lint、镜像、搜索与站点；传统供应者仍归 compat。

使用最新已测试稳定 mcpp，在清单、CI、模板与例子中精确固定。核查源码前更新 remote main。
Linux 本地执行，CI 重跑发布门槛；Windows/macOS 原生 CI。区分编译验证与实际 GUI/设备/GPU 运行，
覆盖冷索引消费和动态加载库的运行时分发。SDK 附带 LICENSE 与第三方通知时，通过
`runtime.deploy` 显式声明它们的相对部署位置，并在搬迁后的消费方分发包中校验字节；
自动许可证收集可能只复制 LICENSE 而遗漏其他通知，无需为此修改引擎。
vendored 静态实现同样需要显式部署，不能依赖共享库扫描发现通知。保留许可/版权文件的来源路径，避免不同组件的同名 LICENSE 相互覆盖。
每仓库一个 PR，保留 checkpoint commits；
逐项核查最终 API/ABI/依赖图，并等待相关 CI 全通过后报告合入与发布就绪。

## 候选索引的跨 namespace 测试

固定客户端在同一 workspace 混用完整项目索引与 namespace 视图时可能报告候选歧义。
mwrap 成员保留显式空 `[indices]` 表，`tests/run_members.sh` 先将完整且字节不变的候选索引放进测试 home 的唯一内置索引。
未设置 MCPP_HOME 时使用任务自有的 target/mwrap-test-home；CI 在刷新已发布索引后准备候选。
保留旧 workspace 重定向的语义；`[workspace.indices]` 会合并条目，不能仅视为同义语法替换。

tests/prepare_mwrap_indices.py 的 namespace 视图仅供隔离的单项目消费者，描述符保留字节及源 SHA256。
不能以独立项目通过证明混合 workspace 顺序可用。视图是不提交、不发布的输出，不是新的发布格式。

正常安装由 tests/mwrap/check_installed_template.py 独立验证：把完整 pkgs/index.toml 发布布局放进独立 MCPP_HOME 的单一内置索引，
下载真实且带校验的源码归档，执行 mcpp new，再原样构建/运行生成清单，不替换为 path 依赖。
Git 与发布的 pkgs/mwrap 目录始终一致。

运行库、插件、构建模块耦合的测试可能同时依赖多个候选 namespace。使用 `python3 tests/prepare_builtin_index.py --home <独立测试目录>`，将完整且字节不变的候选布局放入该测试 home 的唯一内置索引；成员用空 `[indices]` 覆盖旧 workspace 路由。自动更新候选 CI 同样使用此模式。不要将同一个完整 checkout 注册为多个项目别名。这只是测试 home 准备，不需要发布 staging、路径转换或修改 mcpp 引擎。

Linux 消费方即使通过 C API 加载 C++ SDK，也要验证 C++ 运行时契约及异常路径。OpenCV/ORT 组合实测中，静态运行时与共享 SDK 运行时混用会使 typed catch 终止；选择 `cxx_runtime = "toolchain-coupled"` 后同一测试通过。模板必须声明已验证的契约，并执行一次类型化错误路径。

生成清单、模块入口和配置头是构建输入；内容不变时保留时间戳，避免触碰公共配置头导致整份 vendored 实现重编。除了字节幂等，还应验证增量构建行为。
