# Quill 13.0.0 接入 mcpp 模块生态

日期：2026-10-04。状态：已实施，Linux GCC/LLVM、macOS ARM、Windows 构建运行均通过。验收依据见第 5 节。

## 1. 范围与消费方式

包为 `odygrd.quill@13.0.0`，模块入口保持上游的 `import quill;`。复用正式发布的实验性模块，保留异步日志行为、公开 API 和内置 fmt。没有独立 compat 包、fork、自制 wrapper、额外 feature 或引擎改动。

```toml
[dependencies.odygrd]
quill = "13.0.0"
```

PR 合并发布前，本地使用需要指向索引 checkout；将示例路径替换为自己的仓库路径：

```toml
[indices]
odygrd = { path = "/path/to/mcpp-index" }
```

消费者写 `import std; import quill;`。可通过 `quill::Frontend` 创建 sink/logger，使用无宏 API `quill::info(logger, "answer={}", 42)` 或运行时级别 `quill::log`。使用上游日志宏时额外写：

```cpp
#define QUILL_USE_MODULE
#include <quill/LogMacros.h>
```

随后可调用 `LOG_INFO` 或 `QUILL_LOG_INFO`。13.0.0 消费端显式定义 `QUILL_USE_MODULE`；不依赖包内 defines 自动传播。宏头在此模式下跳过普通类型头，并补充宏所需的 helper，不重复包含完整实现。`QUILL_MODULE`、`FMTQUILL_MODULE` 由上游模块自行定义，消费者无需设置。

两种 API 的行为不完全相同：上游 [`LogFunctions.h`](https://github.com/odygrd/quill/blob/v13.0.0/include/quill/LogFunctions.h) 说明无宏 API 的参数始终求值，存在运行时元数据处理，也不能像宏一样按编译期日志级别完全移除。接入不强制迁移原有宏用法，也不作性能等价承诺。

模块公开面以 13.0.0 的模块入口及它实际导出的声明为准；不承诺所有可选头都能通过 import 使用。没有新增 Syslog/Systemd/Android sink、Prometheus 示例或自定义 codec/formatter 导出。完整 Quill 文本头与模块混用、跨 DLL 共享后端不在此次验收范围内。

## 2. 固定的上游输入

- 上游：[odygrd/quill v13.0.0](https://github.com/odygrd/quill/releases/tag/v13.0.0)，MIT；保留根 LICENSE 和 bundled fmt 的声明。
- Tag commit：`eb802a37c7d585840324886a3d8648c9c2159952`。
- 归档：`https://github.com/odygrd/quill/archive/refs/tags/v13.0.0.tar.gz`。
- SHA-256：`88b4a1542125577a4d51cf444c51e34d63618c422ba6a4fa9bd23894b49d696b`；spec 调研时两次独立下载一致，实施中的真实下载通过包摘要校验。
- 解包根为 `quill-13.0.0/`。普通形态为头文件库，模块入口是 [`src/quill.cc`](https://github.com/odygrd/quill/blob/v13.0.0/src/quill.cc)，采用 CRLF。
- [`CMakeLists.txt`](https://github.com/odygrd/quill/blob/v13.0.0/CMakeLists.txt) 的 `QUILL_BUILD_MODULE` 标为 experimental，编译 `src/quill.cc` 并链接 `Threads::Threads`。
- 内置格式化库位于 `include/quill/bundled/fmt/`，使用 `fmtquill` 命名空间，无需依赖 `fmtlib.fmt` 或 `compat.fmt`。

调研时 GitHub Releases API 的 latest 为 13.0.0；实施时该 API 返回 403，改用 `git ls-remote --tags ... 'refs/tags/v13*'` 确认仍只有 `v13.0.0`。在线 latest 文档/master 出现的 13.1.0 内容未混入固定版本实现。

## 3. 接入方案与适配边界

采用内联 Form B 描述符 [`pkgs/o/odygrd.quill.lua`](../../pkgs/o/odygrd.quill.lua)：

| 字段 | 实现 |
|---|---|
| `namespace` / `name` | `odygrd` / `quill` |
| `language` / `import_std` | `c++23` / `false`；保留上游 global module fragment，消费者仍可导入 std |
| `modules` | `{ "quill" }` |
| `include_dirs` | `{ "*/include" }`，服务模块内部包含及消费端宏头 |
| `sources` | `{ "*/src/quill.cppm" }`，只编译一个入口 |
| `targets` / `deps` | `quill` lib / 空依赖 |
| Linux 链接 | `ldflags = { "-pthread" }` |
| 三平台下载 | 相同版本、归档和摘要，使用纯字符串 GLOBAL URL |

安装钩子检查源文件可读且恰有一条 `export module quill;`，以其内容生成同目录 `src/quill.cppm`。原 `.cc` 保留但不加入编译源集。507 个上游文件内容保持不变，适配仅作用于新增的 `.cppm`；读取后统一按 LF 匹配，兼容安装环境对 CRLF 的文本转换。

macOS ARM 的 PR CI 暴露两处上游模块入口问题，安装钩子执行两项精确替换，匹配次数不是一次即失败：

- x86 intrinsic 包含增加 x86 目标架构条件。Clang 在 ARM 上也能找到 `x86gprintrin.h`，仅靠 `__has_include` 会触发无效汇编约束和不存在的 x86 builtin。
- 在 global module fragment 中为 Apple 预包含 Mach 头，以及后端使用的 `unistd.h`、`fcntl.h`、`sys/file.h`、`sys/mman.h`、`sched.h`、`time.h` 和遗漏的 `<charconv>`。否则 Mach 类型、`timeval`、`timespec` 等在全局模块和 Quill 模块中重复归属，编译报错。

失败证据见 [PR CI 的 macOS job](https://github.com/mcpplibs/mcpp-index/actions/runs/37198494639/job/111425198293)。适配不修改 Quill 头文件、导出列表或日志实现。后续 CI 的 [macOS 系统头错误](https://github.com/mcpplibs/mcpp-index/actions/runs/37198733789/job/111425892513) 和 [Windows 换行匹配错误](https://github.com/mcpplibs/mcpp-index/actions/runs/37198733789/job/111425892875) 分别对应系统头补全和换行规范化；仓库中的 [安装钩子检查](../../tests/check_quill_install.lua) 验证 CRLF/LF 生成相同结果，以及输入不可读、模块声明或替换位置缺失/重复时，在任何写入或安装目录操作前失败；该检查已接入 CI lint。

扩展名适配参考 [`fmtlib.fmt`](../../pkgs/f/fmtlib.fmt.lua)，避免 Clang 将 `.cc` 当普通翻译单元。实际 GCC、LLVM 构建图均只编译 `.cppm`，分别生成 `quill.gcm`、`quill.pcm`；未增加 `scan_overrides` 或完整生成式 wrapper。没有执行 CMake，`QUILL_BUILD_MODULE=ON` 不是本包的构建开关。

线程选项仅在 Linux 最终链接时传入，已检查两套构建图的 `ldflags`。不能只给模块或消费者一方增加影响 PCM 配置的 `-pthread` 编译选项：调研中的宿主 Clang 曾复现配置不一致，分开编译与链接后通过。当前 mcpp GCC/LLVM 构建无需额外线程编译选项。

上游对 MinGW 有 `ucrtbase` 分支，未将其泛化为所有 Windows 编译器的链接需求；本次 Windows CI 使用 MSVC ABI 工具链并已通过，未验证 MinGW。未建立 CN 镜像，不声明猜测的地址；以后若增加镜像，须上传相同归档字节并核对摘要与可达性。

选择依据：复用模块及安装钩子参考 [Taskflow](2026-10-04-add-taskflow-spec.md)，保留上游模块名参考 [`khronos.vulkan-hpp`](../../pkgs/k/khronos.vulkan-hpp.lua)，内置 fmt 与 build/test 分别验证参考 [spdlog](2026-07-15-add-spdlog-plan.md)。普通头文件 `compat.quill` 无法提供所需 import；独立 Form A 适配仓会增加维护责任，目前均无必要。

## 4. 持久文件与测试契约

- 描述符：`pkgs/o/odygrd.quill.lua`。
- 测试成员：[`tests/examples/quill-module/mcpp.toml`](../../tests/examples/quill-module/mcpp.toml)，仅一条 odygrd 本地索引重定向；根 workspace 已登记。
- 测试入口：[`tests/quill.cpp`](../../tests/examples/quill-module/tests/quill.cpp)。
- 辅助 TU：[`src/log_worker.cpp`](../../tests/examples/quill-module/src/log_worker.cpp)。
- 中英文目录：`docs/descriptor-examples.md`、`docs/zh/descriptor-examples.md`。README 已链接这两份完整目录，无需改变其结构。

一个测试可执行文件、两个消费 TU，均使用 `import std; import quill;`，覆盖：

1. 主 TU 启动后端、创建 FileSink/logger；辅助 TU 在工作线程查询同名 logger，断言与主 TU 的指针相同。
2. 宏 `LOG_INFO` 输出整数和字符串；不包含任何 Quill 头的辅助 TU 通过 `quill::info` 输出 `std::vector<int>`，通过 `quill::log` 输出运行时级别记录。
3. 两个 TU 分别提交 Debug 日志，Info 阈值下断言它们均未输出。
4. producer 通过 `std::jthread` join，随后 flush/stop，再读回文件，断言三条有效消息的格式化内容和行数；不依赖时间戳、并发顺序或任意 sleep。
5. 每次创建独享临时目录；断言失败返回非零，异常写 stderr；结束后停止后端并清理目录。测试超时 30 秒。

## 5. 实际验证与复现

模块实现提交 `2b17c5587d1b0410272621b9f3940f1bfd97841e` 的 [PR CI 验收](https://github.com/mcpplibs/mcpp-index/actions/runs/37199001009) 已通过，包含 Linux GCC/LLVM、macOS ARM、Windows 的真实构建运行，以及 lint、镜像 URL 和图形安装副作用检查。跨平台结果不是仅由描述符解析推断。

| 检查 | 结果 |
|---|---|
| Linux GCC 16.1.0、LLVM 22.1.8/libc++ | 开发构建、最终安装补丁后的隔离测试均为 `1 passed; 0 failed` |
| macOS ARM、Windows MSVC ABI | PR CI 各 `1 passed; 0 failed` |
| Linux Release（`-O2`） | GCC、LLVM 各 `1 passed; 0 failed` |
| GCC 增量与独立消费工程 | 增量测试通过；独立 `mcpp run --cache off` 编译、链接和运行断言通过 |
| 冷安装 | 独立测试目录实际下载、解包和运行安装钩子；不将 `--cache off` 本身作为重装证据 |
| 安装文件比较 | 507 个上游文件内容不变，仅新增带模块入口适配的 `.cppm` |
| 安装钩子边界 | LF/CRLF 输出一致；不可读输入、缺失/重复模块声明、缺失/重复替换位置五个负向用例均通过 |
| Lua、schema 和索引 lint | Lua 语法、三平台描述符解析、镜像 URL、包身份、保留 namespace、全仓跨包引用/版本一致性/重复版本检查通过 |

在仓库根目录使用 Bash 复现。先将 `MCPP_ROOT` 设置为已解包的 mcpp 2026.10.1.2 发布目录；`MCPP_HOME` 可指定已有 GCC/LLVM 工具链目录，默认使用用户目录下的 `.mcpp`。这些设置仅作用于当前 Shell，不切换全局默认版本。安装钩子检查仅需要 Lua 5.4，不需要上游归档、网络或临时调查文件。

```sh
: "${MCPP_ROOT:?请设置 mcpp 2026.10.1.2 发布目录}"
export MCPP="$MCPP_ROOT/bin/mcpp"
export MCPP_HOME="${MCPP_HOME:-$HOME/.mcpp}"
export MCPP_INDEX_MIRROR=GLOBAL
export MCPP_VENDORED_XLINGS="$MCPP_ROOT/registry/bin/xlings"
test "$("$MCPP" --version)" = "mcpp 2026.10.1.2" || exit 1
lua5.4 tests/check_quill_install.lua
"$MCPP" xpkg parse --all-os pkgs/o/odygrd.quill.lua
"$MCPP" test -p quill-module --cache off --timeout 30
"$MCPP" test -p quill-module --toolchain llvm@22.1.8 --cache off --timeout 30
"$MCPP" test -p quill-module --timeout 30
"$MCPP" test -p quill-module --profile release --cache off --timeout 30
"$MCPP" test -p quill-module --toolchain llvm@22.1.8 --profile release --cache off --timeout 30
```

## 6. 验证边界

上游仍将模块标为实验性。当前覆盖 Linux x86_64、macOS ARM 和 Windows MSVC ABI 工具链；未验证 MinGW、跨 DLL、完整 Quill 文本头与模块混用，以及全部可选 sink/codec/metrics，不承诺性能指标。未上传 CN 镜像。

升级上游或工具链时应重新执行同一套跨平台测试。若需要超出模块入口的小范围适配、改动日志实现或 mcpp 引擎，应保留失败复现并重新审查范围，不以跳过平台或静默改成头文件包代替验收。
