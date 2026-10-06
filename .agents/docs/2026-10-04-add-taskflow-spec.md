# Taskflow 4.1.0 模块接入

## 范围与消费方式

以最小必要改动接入上游 CPU 模块，包名为 `taskflow.taskflow@4.1.0`，入口保持 `import tf;`。不提供独立 compat 包、CUDA feature 或自行维护的 API wrapper。

```toml
[dependencies.taskflow]
taskflow = "4.1.0"
```

消费者使用 `import std; import tf;`。模块只提供上游实际导出的 API，预处理宏不随模块导出，版本查询使用 `tf::version()`。模块与文本头文件混用不在本次验收范围内。

## 上游与包结构

- 上游：[taskflow/taskflow v4.1.0](https://github.com/taskflow/taskflow/releases/tag/v4.1.0)，MIT。
- Tag commit：`45366fe5bc4f2f8ec9aa590b40c504e296886865`。
- 归档：`https://github.com/taskflow/taskflow/archive/refs/tags/v4.1.0.tar.gz`。
- SHA-256：`2107f90e315e48a676922010b036357ff2b0c6b9160ce17fa9396e5860b1d715`，独立下载摘要一致。
- 归档根目录为 `taskflow-4.1.0/`，没有符号链接；Linux、macOS、Windows 使用相同归档及校验值。
- 描述符为内联 Form B，采用 C++23，`import_std = false`，include 根为归档根目录。
- 显式编译 `tf.core.cppm`、`tf.algorithm.cppm`、`tf.utility.cppm`、`tf.cppm`；不通配 modules 目录，因为 `tf_with_cuda.cppm` 同样提供主模块 `tf`。
- 未配置 CN 镜像，使用纯字符串上游 URL；需要镜像时应上传相同归档字节。

该形态参考 `khronos.vulkan-hpp` 的上游模块复用方式，安装期适配参考 `compat.muduo`，Linux 线程链接配置参考 `chriskohlhoff.asio`。

## 必要适配

安装钩子逐项检查目标文件可读且替换位置恰好出现一次，不匹配立即失败。下载归档保持上游原样，适配只发生在解包后的三个模块文件中。

| 文件 | 适配 | 验证依据 |
|---|---|---|
| `modules/tf.core.cppm` | 移除 `HasGraph`、`ProfileData` 两条失效导出 | 4.1.0 头文件中不存在这两个名字，原模块在 Clang 下直接编译失败 |
| `modules/tf.core.cppm`、`modules/tf.cppm` | 将总头文件包含及版本函数导出移至 core，主接口先导入 core 再导入 algorithm | GCC 16.1.0 消费原模块时找不到 `tf::Executor`、`tf::Taskflow`；宿主 GCC 16.2.1 独立复现，组合调整后通过 |
| `modules/tf.utility.cppm` | 显式包含 `<algorithm>` | libc++ 下 `iterator.hpp` 使用的 `std::max` 缺少声明 |

逐文件摘要比较确认其余上游文件未改变，包括所有头文件及调度实现。没有独立 fork，也未修改 mcpp 引擎或现有 CI 配置。

Linux 最终链接使用 `-pthread`。不单独给依赖模块的编译命令增加该参数，否则 LLVM 消费者与 PCM 的线程配置不一致。实际构建命令确认链接参数到达消费者。

## 测试与索引登记

`tests/examples/taskflow-module` 通过单条 `taskflow` 索引重定向消费当前 checkout。一个测试 main 与一个辅助 TU 共同链接，覆盖：

- `import std; import tf;` 的多 TU 消费。
- 两个 worker 执行两条 DAG 分支并汇合，检查结果为 42。
- 1024 个元素的 `reduce`，检查结果为 1024。
- `next_pow2` 与 `tf::version()`。

断言失败返回非零退出码，运行时间由 mcpp 测试超时约束。成员已登记到根 workspace，中英文描述符目录已有对应条目。

## 验证结果

使用 CI 固定的 mcpp `2026.10.1.2`：

```sh
mcpp test -p taskflow-module --cache off --timeout 30
mcpp test -p taskflow-module --toolchain llvm@22.1.8 --cache off --timeout 30
mcpp xpkg parse --all-os pkgs/t/taskflow.taskflow.lua
```

- Linux GCC 16.1.0、LLVM 22.1.8/libc++：各 `1 passed; 0 failed`，GCC 增量运行通过。
- 冷安装、Lua 语法、三平台描述符解析通过。
- 镜像 URL、包身份、保留 namespace、全仓跨包引用、平台版本一致性、重复版本检查通过。
- workspace 与描述符变更均能由现有 CI 选择规则命中 `taskflow-module`。
- macOS、Windows 尚待 PR CI 构建和运行验证；描述符解析不代表运行验收。
