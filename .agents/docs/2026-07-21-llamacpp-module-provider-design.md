# llama.cpp 模块门面与后端 Provider 适配设计

日期:2026-07-21

分支:`docs/llamacpp-module-provider-design`

基线:

- mcpp-index fork:`wellwei/mcpp-index@0b0a98f`
- llama.cpp 快照:`b10069`
- 原型提交:`64c5d2e`(CPU)、`42f36d6`(Metal)

## 1. 背景与现状

当前 `compat.llamacpp@b10069` 仅是发布前验证原型。它证明 mcpp 可以从
upstream 源码归档直接编译 GGML base、CPU backend、llama 推理实现、模型实现
以及可选 Metal backend，但它尚未上线正式 mcpp-index，也没有消费者迁移约束。

原型不作为最终包契约保留:

- 只生成一个单体 `libllama`;
- 消费端使用 `#include <llama.h>`;
- 没有 `.cppm` 或 named module;
- CPU 与 Metal 源码同处一个描述符;
- `metal` 只是加性 feature，不是 provider;
- 没有 `provides`、`requires` 或 feature dependency;
- CPU、Metal、registry、llama 实现边界与 upstream CMake target 不一致。

因此最终适配直接建立干净边界，不设置兼容别名、弃用周期或迁移测试。

## 2. 已确认的公共契约

唯一承诺的公共消费接口是:

```cpp
import llama;
```

`#include <llama.h>` 只属于内部实现，不是公共 `llamacpp` 契约。`compat.*`
包可以因调试需要被直接解析，但不进入普通消费者文档。

公共依赖使用单选 backend:

```toml
[dependencies]
llamacpp = "0.1.0"                            # CPU
# 或
llamacpp = { version = "0.1.0", backend = "cpu" }
# 或
llamacpp = { version = "0.1.0", backend = "metal" }
```

语义如下:

| 选择 | 实际构建 |
|---|---|
| 省略 | CPU |
| `cpu` | CPU |
| `metal` | CPU + Metal |
| `cuda` | 首版不提供 |

llama.cpp 即使启用 GPU offload 也必须保留 CPU，用于输入、未卸载层和回退工作。
Metal/CUDA 是 accelerator，不是 CPU 的替代品。

公共接口不接受 backend 数组，首版不支持在一个消费者图中同时编译多个
accelerator。

## 3. 包架构

首版由五个包组成:

```text
llamacpp                         公共模块门面
    |
    `-- compat.llamacpp          llama 实现 + GGML registry
            |-- compat.ggml-base GGML 公共实现
            |-- compat.ggml-cpu  必需 CPU backend
            `-- compat.ggml-metal 可选 Metal accelerator provider
```

### 3.1 `llamacpp`

`llamacpp` 是唯一公共包，使用独立 SemVer，只包含薄模块接口，不编译 upstream
实现源码。

模块源码由独立 `llamacpp-m` 仓库持有，并以 Form A 发布:

```text
llamacpp-m/
|-- mcpp.toml
|-- src/llama.cppm
`-- tests/
```

mcpp-index 中的 `llamacpp` 描述符只登记 `llamacpp-m` release。
`llamacpp-m` 负责:

- 公共 SemVer;
- `llama.cppm` 导出清单;
- 对 `compat.llamacpp` 的精确依赖;
- 模块专属测试;
- upstream 快照映射记录。

完整模块单元不得以大型 `generated_files` 字符串埋入 Lua 描述符。

公共包职责:

- 提供 `import llama;`;
- 精确依赖一个 `compat.llamacpp` upstream 快照;
- 声明 `backend-cpu` 与 `backend-metal`;
- 将 `backend-cpu` 作为必需 CPU 基线的空操作拼写;
- 将 `backend-metal` 转发给 `compat.llamacpp/backend-metal`;
- 不在普通消费者文档中暴露任何 `compat.*` 包名。

### 3.2 `compat.ggml-base`

对应 upstream `ggml-base` target，拥有 GGML 公共实现和其他内部包所需头文件。
它不包含 registry 或硬件 backend。

### 3.3 `compat.ggml-cpu`

对应 upstream `ggml-cpu` target，拥有 CPU 公共实现、架构相关源码和可选
`llamafile` kernel，精确依赖同快照的 `compat.ggml-base`。

CPU 是必需基线，不提供 accelerator capability。

### 3.4 `compat.ggml-metal`

对应 upstream `ggml-metal` target，拥有:

- 4 个 C++ 与 2 个 Objective-C Metal TU;
- Foundation、Metal、MetalKit 链接需求;
- Metal shader 嵌入构建程序;
- `provides = ["ggml.accelerator"]`。

该包仅支持 macOS ARM64，并精确依赖同快照的 `compat.ggml-base`。

### 3.5 `compat.llamacpp`

该包拥有:

- `ggml-backend-reg.cpp` 与 `ggml-backend-dl.cpp`;
- llama 推理与模型实现源码;
- 对 `compat.ggml-base`、`compat.ggml-cpu` 的必需依赖;
- backend feature 解析和 registry 编译宏。

其 `backend-metal` feature:

- 在编译 registry 的包上定义 `GGML_USE_METAL`;
- `requires = ["ggml.accelerator"]`;
- 通过 feature dependency 拉取同快照 `compat.ggml-metal`。

## 4. 模块边界

模块单元是稳定公开 C API 的薄门面，不在 named module 中编译 llama/GGML
实现源码。

基本形态:

```cpp
module;
#include <llama.h>

export module llama;

export {
    using ::llama_model;
    using ::llama_context;
    using ::llama_token;
    using ::llama_backend_init;
    using ::llama_backend_free;
}
```

全局模块片段使 upstream 声明仍属于 global module;named module 通过
using-declaration 导出已审阅接口，避免把宏驱动的整份头文件附着到
`llama`。

上例只是形态示意，不是完整导出清单。对每个 upstream 快照，模块导出:

- 所有非 deprecated 公共类型;
- 使用公共 API 所需的 enum 与枚举值;
- 所有非 deprecated `LLAMA_API` 函数。

导出清单由 `llama.h` 生成，提交到 `llamacpp-m`，并作为 API diff 人工审阅。

首版不导出:

- `llama-cpp.h` inline C++ wrapper;
- `ggml.h` 或其他 GGML API;
- 无法跨 named module 的预处理宏;
- `src/`、`ggml/src/`、backend 实现目录中的头文件。

公共 API 必需的宏常量改为显式导出的类型化 C++ 常量。受支持程序不得混用
`import llama;` 和 `#include <llama.h>`。

## 5. Backend 选择与 Provider 绑定

Metal 数据流:

```text
consumer backend="metal"
    -> backend 糖请求 llamacpp/backend-metal
    -> llamacpp 转发 compat.llamacpp/backend-metal
    -> compat.llamacpp 增加 GGML_USE_METAL
    -> compat.llamacpp 拉取 compat.ggml-metal
    -> compat.ggml-metal provides ggml.accelerator
    -> capability binding 验证唯一 accelerator provider
    -> ggml-backend-reg.cpp 引用 ggml_backend_metal_reg()
    -> 最终链接保留并注册 Metal backend
```

Capability binding 只校验已经解析完成的依赖图，不从 index 自动发现包，也不删除
未选择 provider。因此 backend feature 必须显式拉取具体 provider。

Provider archive 被链接并不等于完成注册。upstream `b10069` 的 registry 在
`GGML_USE_METAL` 下显式调用:

```cpp
#ifdef GGML_USE_METAL
    register_backend(ggml_backend_metal_reg());
#endif
```

因此宏必须作用于 registry TU，只定义在 provider 包上会得到未注册 backend。

首版只有 Metal 一个 accelerator provider。CUDA 在构建先决条件完成前不声明。
第二个 accelerator 上线前，mcpp 必须提供不能被 capability pin 绕过的
one-of/conflict 机制，避免两个 provider 与两个 registry 宏同时生效。

## 6. Metal Shader 所有权

Metal provider 必须自包含。消费者不手工安装 `default.metallib`，也不设置
`GGML_METAL_PATH_RESOURCES`。

`compat.ggml-metal` 使用包内 `build.mcpp` 复现 upstream
`GGML_METAL_EMBED_LIBRARY` 路径:

1. 读取 `ggml-common.h`、`ggml-metal.metal`、`ggml-metal-impl.h`;
2. 在 `MCPP_OUT_DIR` 生成合并后的 Metal source;
3. 生成包含该 source 的 Darwin assembly section;
4. 把生成的汇编加入本包构建;
5. 定义 `GGML_METAL_EMBED_LIBRARY`;
6. 用 `rerun-if-changed` 声明全部输入。

该路径不依赖 `xcrun`，也不需要运行时资产复制契约。生成或汇编失败必须终止
构建，不能把已请求的 Metal 静默降级为 CPU-only。

## 7. 失败语义

配置错误必须响亮失败:

| 条件 | 结果 |
|---|---|
| 未指定 backend 或 `backend="cpu"` | 构建 CPU |
| `backend="metal"` on macOS ARM64 | 构建 CPU + Metal |
| `backend="metal"` on Linux/Windows/macOS x86-64 | 平台错误 |
| 首版请求 `backend="cuda"` | 未知 backend 硬错误 |
| backend 拼写错误 | 硬错误，禁止 warning 后回退 CPU |
| provider 缺失 | capability 错误 |
| 多个 accelerator provider | one-of conflict 错误 |
| 内部快照版本不一致 | 依赖解析错误 |
| Metal shader 生成失败 | 构建错误 |

当前 mcpp 在非 strict 模式下只 warning 未知 `backend-*` feature。正式发布前
必须先修改 mcpp:当依赖声明了 backend feature 时，未知 `backend=` 选择必须
硬错误。包侧不以 CUDA sentinel feature 绕过这一问题;`backend-cuda` 在真实
provider 存在前保持未声明，CUDA 与拼写错误走同一硬错误路径。

## 8. 版本与 Upstream 跟进

公共包和内部包使用不同版本身份:

```text
llamacpp 0.1.0
    `-- compat.llamacpp b10069
            |-- compat.ggml-base b10069
            |-- compat.ggml-cpu b10069
            `-- compat.ggml-metal b10069
```

- `llamacpp` 使用 SemVer 表达公共模块契约;
- 内部包使用 llama.cpp upstream `b` tag;
- 内部依赖全部精确锁定;
- 同一 upstream 快照的所有包原子更新和发布;
- 历史版本保留用于回退;
- 不自动追踪每个 upstream tag 或 commit。

公共版本规则:

| 变化 | 公共版本 |
|---|---|
| 实现/性能更新，模块 API 不变 | patch |
| 模块 API 加法或新增正式 backend | minor |
| 删除或改变已导出 API | major |

每个公共 release 记录快照映射和 backend 集:

```text
llamacpp 0.1.1
- upstream: llama.cpp b10120
- module API: compatible with 0.1.0
- backends: CPU, Metal
```

### Upstream 快照审计

更新辅助脚本只下载和报告候选快照，不自动重写描述符。报告比较:

- `llama.h` 公共声明;
- GGML 公共头和 `GGML_BACKEND_API_VERSION`;
- upstream CMake 中 ggml-base、CPU、Metal、registry、llama 源集合;
- 新增、删除、改名 TU;
- registry 函数和 `GGML_USE_*` 条件;
- 平台库、framework、宏和工具需求;
- Metal shader 生成输入;
- 模型实现源码和 C++ dialect 例外。

`src/models/*.cpp` 等 glob 必须展开并保存具体快照清单，禁止 upstream 新文件
未经审阅静默进入构建。

任何已支持平台或 backend 失败时，不发布新快照中的任何包，禁止内部包部分更新。

## 9. 验证设计

测试面:

```text
tests/examples/llamacpp-module-cpu
tests/examples/llamacpp-module-metal
tests/negative/llamacpp-backends
```

### CPU Consumer

- 源码只含 `import llama;`，不含 llama/GGML header;
- 覆盖 Linux x86-64、macOS ARM64、Windows x86-64;
- 加载固定、带校验和且许可证明确的小型 GGUF fixture;
- 至少完成一次 decode;
- 验证模块链接与 backend 生命周期;
- 发布门禁包含空包缓存与空构建缓存。

### Metal Consumer

- 只在 macOS ARM64 运行;
- 使用 `backend="metal"`;
- 断言 Metal registry/device 存在;
- 断言嵌入 shader 初始化成功;
- 至少完成一次 GPU-offloaded decode;
- 断言必需 CPU backend 同时存在。

性能数据只记录，不作为通过阈值。

### 负向验证

- Linux/Windows 请求 Metal;
- macOS x86-64 请求 Metal;
- backend 拼写错误;
- 首版请求 CUDA;
- 内部 provider/core 版本不一致。

第二个 accelerator 上线时再加入双 accelerator conflict 测试，首版不伪造未来
provider。模型缺失不得把必需发布验证变成 skip。

## 10. 交付阶段

### P0:冻结原型证据并建立新契约

当前描述符只作为证据输入。记录其展开源码清单、编译例外、平台库、已知失败和
两个原型提交。围绕新包边界建立失败的 CPU/module/provider consumer 契约。

不修补即将被替换的单体描述符。已知问题落入新边界:

- `advapi32` 进入新 Windows CPU backend;
- 模型缺失由新的自包含 consumer 解决;
- Metal flags/frameworks 进入 Metal provider;
- T5 源码决策在新 llama 实现包处理;
- 新包组重新完成 release asset 与 mirror 准入。

原型单包不发布，并在最终包组准入前删除。

### P1:CPU 实现拆分

新增 `compat.ggml-base`、`compat.ggml-cpu`、`compat.llamacpp`。在公共模块
加入前，先以内部 smoke 证明三平台 CPU 图。

### P2:公共模块门面

创建 `llamacpp-m` 仓库与 Form A release。mcpp-index 新增 `llamacpp`
描述符、审阅后的 `llama` 导出清单、公共 SemVer 映射和三平台
`import llama` CPU consumer。

### P3:Metal Provider

新增 `compat.ggml-metal`、capability binding、feature forwarding、shader
嵌入和 macOS ARM64 Metal consumer。

### P4:首次发布

descriptor lint、all-OS parse、mirror、冷缓存 CPU、Metal、模块与负向测试全部
通过后才正式发布。

### P5:CUDA 后续

CUDA 单独进入下一轮设计与实现，先决条件:

- 已验证的 NVCC/CMake 包构建策略或 mcpp 原生 CUDA source 支持;
- hermetic CUDA SDK/tool discovery;
- 不可绕过的 one-of backend 约束;
- Linux/Windows CUDA runtime 与 consumer 验证。

## 11. 首版非目标

- 公共 header 消费;
- 将 GGML API 导出为模块;
- 导出 `llama-cpp.h`;
- CUDA、Vulkan、SYCL、RPC、动态 backend plugin;
- 同时选择多个 accelerator;
- 依赖解析期自动硬件探测;
- `llama-cli`、`llama-server` 等工具;
- 性能 benchmark 门禁。

## 12. 验收条件

1. 消费者只依赖 `llamacpp` 并使用 `import llama;`。
2. CPU 从冷缓存通过 Linux x86-64、macOS ARM64、Windows x86-64。
3. `backend="metal"` 在 macOS ARM64 无外部 shader 配置完成真实 GPU-offload
   decode。
4. 不支持或无效 backend 在生成 CPU-only 二进制前失败。
5. 最终依赖图中所有内部包属于同一 upstream 快照。
6. 消费源码和 manifest 不需要内部 header、包名或 provider 细节。
7. 公共 release 记录模块版本、upstream tag 和 backend 集。
8. 全部必需 CI、mirror、descriptor 检查通过后才发布。
