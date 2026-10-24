# mwrap 实施与发布验收清单

本清单按原实施方案逐项验收，不以仓库存在、一次编译或单个绿色任务代替完成证明。
当前状态：候选审查中。所有 PR 保持未合入；未创建 tag/release。mcpp 引擎源码只读。
原方案：[OpenCV 实施基线](https://github.com/mcpplibs/opencv-m/blob/c052ccf15de43689c23b70952bb3c0a63779f71f/.agents/docs/2026-10-24-opencv-5-full-and-onnxruntime-plan.md)。

## 可供 review 的核心约定

- 新封装使用 `<upstream>-m` 仓库、`mcpplibs.mwrap.<lib>` 包/模块；普通 API 保留上游 `cv::`、`Ort::` 等名字和类型。
- 宏映射单列 `<root>.macros`，C++ 命名空间使用 `mcpplibs::mwrap::<lib>::macros`；预处理控制宏保留文本头。
- 版本跟随上游，最多增加一个数字封装修订尾号；不发布 `.0`，不改写历史版本资源。
- `pkgs/mwrap` 平铺，`tests/mwrap` 独立；Git 与发布布局一致，不做 staging 路径转换，不修改客户端引擎。
- OpenCV core 必需、`default=[]`；`all-modules` 选择十六个主模块，窗口、codec、视频和 SDK 后端显式选择。
- 七个 -m 库都有可运行默认模板；README 每种语言不超过约 100 行。现有旧包身份逐包迁移，不绑定一次性改名。
- 测试共用四核 CPU quota、单个编译任务和内存限制，并监测整机 80% 阈值。只清理任务生成且无进程引用的可执行文件。

## 原方案要求与验收证据

| 要求 | 必需证据 / 当前结果 | 尚未关闭的门槛 |
|---|---|---|
| P0：规范与设计 | 索引 `docs/mwrap.md`、`docs/zh/mwrap.md` 是规范；设计历史留在各仓库 `.agents/docs` | 由用户最终 review，不宣称已合入 |
| P1：组织 fork、独立 ORT、最新工具 | OpenCV 保留 Sunrisepeak fork 历史；ORT 独立仓库；七库固定 mcpp 2026.10.24.1，2026-10-25 再核对仍为 latest stable | 不改 mcpp 引擎，不移动旧 tag |
| 每仓库一个 PR / checkpoint | OpenCV #1、ORT #1、llama.cpp #5、FFmpeg #8、gRPC #8、ImGui #13、Godot #1；索引 #564 | 最终报告需绑定各 PR 当前 HEAD 和全部检查 |
| P2：来源/适配/生成分层 | 固定官方 OpenCV 5.0.0；2305 个保留 SDK 文件逐字节验证；配置由 target/feature/module 图生成 | 不以生成文件存在代替运行验证 |
| 十六主模块 | Linux GCC16、LLVM22/23 完整 38 程序；十六 direct imports 和聚合查找 | 当前 HEAD 五腿原生 CI |
| 公共 API / 模板 / 转换 | 64 个 Mat 参数转发保留原始转换规则；114 赋值组合、原始逗号初始化；七组 SDK/module oracle | 名称查找不证明每个重载/后端；已知编译器混用限制继续公开 |
| 宏与头文件混用 | 独立宏模块、原始宏桥、接口 ISA guard、混用消费者 | 不把完整原始 core.hpp 的 GCC 声明合并限制隐藏成支持 |
| API 拒绝项审查 | 每项有准确名字、SDK 文件 SHA256、原因和源码锚点；未知/过期项必须失败 | 原生 SSE 与软件模式分别验收，不能只用一方替代 |
| P3：GUI | GTK3/Xvfb、Win32、Cocoa 创建/显示/事件/销毁具有原生证据；窗口模板明确选择后端 | 新源码当前 HEAD 必须重新通过原生 CI |
| P3：ORT CPU | 官方 1.25.1 SDK、独立 Ort::Session 与 OpenCV ENGINE_ORT；实际 CPUExecutionProvider profile 排除回退 | 当前源码 HEAD、部署及 DLL/SO/dylib 闭包证据 |
| P4：codec / 视频 | PNG/JPEG/BMP/PPM/PFM、WebP alpha/动画/XMP；FFmpeg 文件往返、原生视频文件/注册与错误路径 | 真实摄像头为 requires-device，不以文件测试冒充 |
| 默认与关闭依赖边界 | core-only、图像、all-modules、native GUI/video、ORT、WebP 及配置拒绝分别测试 | 不穷举无意义组合；每项声明能力仍需对应证据 |
| P5：contrib / 加速 | 方案 §3 允许硬件/专有 SDK 阶段交付；覆盖矩阵列出 planned/unavailable，未注册空 feature | 不声称 contrib、GPU、其他 ISA、额外 codec/后端已实现 |
| P6：索引发现与旧包 | Flat 分类、发布枚举、搜索/选择、workspace/shards、updater、旧资源保留；混合 namespace 回归 | 最终索引 HEAD 所有 CI |
| P6：真实归档消费 | `c052ccf` 归档两次下载相同；全部 3716 文件匹配工作树；新 home 模板/API/build/run/pack/relocate 通过 | 若后续只修改审查元数据，也必须核对最终归档和实际索引 pin |
| SDK/第三方通知 | 普通 OpenCV 部署 15 份、WebP 部署 18 份选中通知逐字节匹配，Linux loader 依赖均在搬迁包内 | 不将安装目录运行当作搬迁部署验收 |
| 七库快捷模板 | 默认模板无外部输入资产即可运行；SDK/设备限制明确 | 不将 Godot math 当作引擎加载、llama CPU 初始化当作模型质量验证 |
| P7：规范与技能 | 索引中英规范、包索引 skill 已同步；独立 mcpp 文档 PR #836 不合入、不阻塞库项目 | 最终核对规范示例、版本与实际客户端语义一致 |
| README / 临时文件 | 七库 README 42–52 行；临时安装 home 自动清理；任务可执行文件在成功后删除 | 保留用户原始未跟踪文件、源代码、对象/BMI 和审查日志 |

## 当前不可省略的最终检查

1. 已在 `71d0967` 修复并本地通过原生 SSE 审计模式的 23 个实现辅助名字；原生 121 / 软件 101 项审查均通过，未知/过期项仍失败。当前提交 CI 仍待通过。
2. OpenCV 当前源码 HEAD 所有原生任务通过；不得用旧提交或步骤局部成功代替。
3. 最终源归档、索引描述符 URL/SHA、仓库 HEAD 对齐；运行代码与已通过部署的归档一致性有明确证据。
4. 索引最终 HEAD 的 validate、updater、site、OpenKAL 检查全部通过。
5. 六个伴随仓库当前远端 HEAD、归档、模板、工具 pin、README 与 CI 再核对。
6. 分别报告 passed、build-only、requires-device、unsupported；不使用“全部功能支持”掩盖矩阵中的阶段项。
7. 汇总核心点、每仓库 PR、实际版本、验证范围与剩余边界，供用户决定合入/发布。该决定尚未执行。

## 已通过的候选归档证据

`c052ccf15de43689c23b70952bb3c0a63779f71f`：SHA256
`e7016133547422085b293800d102becfa6c5fc8bd3d0fa9f3a36b88ccf227674`。
默认模板原样 build/run 后，在同一独立 home 添加实际索引 API 测试，typed-Mat/FP/PNG/JPEG 等通过；
release pack、隔离搬迁运行、15 份通知与 ELF 闭包通过。WebP 的透明 RGB/alpha、动画、XMP、release
pack、搬迁运行和 18 份通知也通过。日志分别为
`/tmp/mwrap-c052ccf-template-api-deployment.log`、`/tmp/mwrap-c052ccf-webp-deployment.log`。
这些证明该归档的实现，不自动证明后续修改的审计脚本或新提交 CI。

## 伴随仓库当前 HEAD 复核（2026-10-25）

以下远端 PR HEAD 与本地 HEAD 相同；当前检查全部 success，均未合入且保持 draft。
源码归档仍固定这些提交，未将旧绿灯替代新代码。

| 仓库 / PR | HEAD | 当前绿色检查 | README 行数 | 模板数 |
|---|---|---:|---|---:|
| [onnxruntime-m #1](https://github.com/mcpplibs/onnxruntime-m/pull/1) | `576c780` | 4 | README.md: 50 | 1 |
| [llama.cpp-m #5](https://github.com/mcpplibs/llama.cpp-m/pull/5) | `5028a1a` | 8 | README.md: 48 | 1 |
| [ffmpeg-m #8](https://github.com/mcpplibs/ffmpeg-m/pull/8) | `1e8bce6` | 2 | README.md: 45 | 1 |
| [grpc-m #8](https://github.com/mcpplibs/grpc-m/pull/8) | `0d11b22` | 6 | README.md: 52, README.zh.md: 52 | 1 |
| [imgui-m #13](https://github.com/mcpplibs/imgui-m/pull/13) | `ffebf83` | 4 | README.md: 46 | 3 |
| [godot-cpp-m #1](https://github.com/mcpplibs/godot-cpp-m/pull/1) | `40f72d5` | 3 | README.md: 42 | 1 |

六库均固定 mcpp 2026.10.24.1。gRPC Windows 运行时、真实 Godot 引擎加载和模型质量不从这些检查数量推断；支持范围以各仓库文档及实际已执行用例为准。

最终源码审查修复为 `71d0967124222f23999d57e4d514df6a4ed60834`，归档 SHA256 `d2c0b85536bf4cbb22c914cc055d63cb780cfb25492da3bdc53bd0a08022ed24`。
与已通过部署的 c052ccf 相比仅四个审计/CI/记录文件变化；实现、模板、构建配方和许可证逐字节一致。新归档的实际安装验收正在执行，未提前标为通过。


## GCC root-import and CI shard corrections (2026-10-25)

The 71d0967 source failed GCC's staged OpenCV/ORT configuration with missing
bare detail.core/detail.matx BMI paths. Source checkpoint 52fa4a1 directly
imports both producers before public core; 5056249 adds the explicit bilingual
legacy module/macro migration table. The same warmed staged project fails
again with the original root and passes actual ORT CPU/profile inference after
restoring exact formal bytes. Logs: /tmp/mwrap-gcc-root-import-negative.log and
/tmp/mwrap-gcc-root-import-ab.log. All 38 programs pass LLVM23/GCC16/LLVM22
(128.68/238.24/790.55s), with unchanged seven SDK oracles and strict review gates.

Final source 5056249212be1470de7fa7c85ea9fc805f72349d is independently downloaded
twice, SHA256 9bb69f39be2bd135e83fe1d9afc6b3e00adeaa70a65be315bb29cc5a92e0e40d.
All 3716 files match the checkout; all 2305 retained SDK files are unchanged.
Against 71d0967 only the root aggregate, two usage documents and source ledger
differ. Templates, provider recipes, notices and implementation bodies remain
byte-identical, but changed interface inputs still require fresh archive and CI
acceptance. Actual final-archive template/API/release/relocation is in progress;
older passing bundles are not silently substituted.

Index 9fce3e7's validate job 120923966425 reached its 90-minute cap while
compiling the legacy opencv-module-dnn member. Prior members passed; updater,
site and OpenKAL succeeded. The canceled shard combined 18 minutes of installed
checks with previously unpriced grpc-cpu/grpc-tools/godot-math consumers and
three legacy OpenCV consumers. Member and completed installed-step durations
from the actual Linux jobs now price those wrappers in member-timings.tsv.
For the same 26 selected members the old three-way assignment reprices to
4588/3410/6486s; the revised four-way split is 4087/3523/3402/3472s. Thus the
slowest estimated slice drops from 108.1 to 68.1 minutes without removing tests
or raising the 90-minute cap.

The matrix also advertised six LLVM slices while the emitted plan contained
only the first/default Linux three-way split. Planning is now keyed by both
platform and count; each toolchain consumes its advertised split. Three regressions exercise real Lua splits and verify different Linux counts
each cover every selected member exactly once, full-workspace planning retains
both examples and mwrap, and missing/incomplete plans fail instead of reporting
empty success.
YAML parsing and whitespace checks pass. New source/index final CI remains a
required gate; neither the actual GCC failure nor timeout is counted passing.
