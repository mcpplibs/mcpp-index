# ggml-org.llamacpp 模块适配设计文档

## 架构

`ggml-org.llamacpp` 是将 llama.cpp C API 封装为 C++23 模块 (`import llama;`) 的单包描述符。下游消费者不需要 `#include` 任何 llama.cpp 或 GGML 头文件。

```
消费者项目                    ggml-org.llamacpp 包
┌──────────────┐              ┌─────────────────────────┐
│ import std;  │              │  llama.cppm              │
│ import llama;│ ── 依赖 ──▶  │    ├─ required_ggml.inc  │
│              │              │    ├─ llama.inc          │
│ // 使用      │              │    └─ constexpr 常量      │
│ llama_* API  │              │                          │
└──────────────┘              │  编译时包含:               │
                              │    ├─ ggml-base (9 TU)   │
                              │    ├─ ggml-cpu (14 TU)   │
                              │    ├─ llama 核心 (168 TU) │
                              │    └─ ggml-metal (6 TU)  │
                              └─────────────────────────┘
```

## 版本管理

描述符通过 xpm 支持多版本共存。消费者选择版本：

```toml
[dependencies.ggml-org]
llamacpp = "b10069"   # 或 "b10107"
```

b10069 和 b10107 共享同一个模块接口和导出文件。两个版本的 API 差异由 `audit_snapshot.py` 自动检测。

升级流程:

1. 更新 xpm 表: URL, SHA256
2. `audit_snapshot.py --output` 重新生成快照
3. 手动检查: 新模型架构 → 加到排除列表

### b10069 → b10107 对比

| | b10069 | b10107 |
|---|---|---|
| API 函数 | 基准 | +2 (llama_load_mode_name/rn_str) |
| 宏变化 | — | 无 |
| GGML backend 变化 | — | 无 |
| 排除模型 | 3 (dflash, eagle3, t5) | +4 (laguna, hunyuan-dense, minimax-m2, llama-embed) |

## 与官方 llama.cpp 的区别

### `::size_t` 等 C 全局名不可用

`import std;` 不提供 C 层的全局名。消费者必须使用 `std::` 限定形式。

| 正确 | 错误 |
|------|------|
| `std::size_t` | `size_t` |
| `std::ptrdiff_t` | `ptrdiff_t` |
| `std::nullptr_t` (module 已提供) | 需要 `<cstddef>` |

原因: `import std;` 导出的是 `namespace std` 下的名字，不包含 C 头通过 `::` 注入的全局名。llvm@20 和 @22 行为一致。

### 预处理器宏 → constexpr

官方宏 `LLAMA_DEFAULT_SEED` 等在模块中替换为 `export inline constexpr` 常量。类型安全，不泄漏到头文件空间。

### GGML Backend 已内置

消费者不需要 `#include <ggml-backend.h>` 等头文件。模块已导出 `ggml_backend_reg_by_name`, `ggml_init` 等 28 个 GGML backend 类型/函数。

## vtable 限制

C++23 模块编译器 (llvm@20/22) 无法为头文件中定义的 inline 虚函数生成 vtable。这导致部分模型架构无法通过模块编译。

处理方式: 这些模型的源文件直接从 sources 列表移除，不编译。下游消费者无法调用这些模型架构。此限制源自 llama.cpp 上游将虚函数实现在头文件中的设计选择，与我们的适配无关。

| 版本 | 排除模型 | 数量 |
|------|------|:--:|
| b10069 | dflash, eagle3, t5 | 3 |
| b10107 | laguna, hunyuan-dense, minimax-m2, llama-embed | 4 |

## 模块所有权冲突

C++20 模块的 global module fragment 拥有其包含的头文件声明。消费者如果在 `import` 后再 `#include` 同一头文件，会产生 conflicting declaration (Linux/glibc) 或 conflicting asm label (macOS/Xcode SDK)。

测试文件全部改为纯 `import std; import llama;`，零 `#include`。

## 验证

| 测试 | b10069 |
|------|:--:|
| `check_llamacpp_snapshot.py` | ✅ |
| 41 单元测试 | ✅ |
| CPU 推理 (stories15M-Q4_0) | ✅ |
| Metal 推理 (GPU offload) | ✅ |
| Standalone demo project | ✅ |
