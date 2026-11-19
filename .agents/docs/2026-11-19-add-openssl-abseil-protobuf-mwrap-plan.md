# 新增 mcpplibs.mwrap.openssl / abseil / protobuf —— 设计方案

状态：**已实施（v5）**。v4 经 review 确认（abseil-m 命名、GitCode 上传策略、codegen 规则架构 §6.5）；实施结果与偏差见 §12。
修订记录：v2 加入平台分析；v3 吸收三路自审（§11）；v4 命名与上传策略；v5 实施结果。

规范：[mwrap](../../docs/zh/mwrap.md) · [README 布局](../../docs/zh/mwrap-readme.md) · [许可](../../docs/zh/mwrap-licensing.md)。
参照：libpng-m（compat 之上的薄封装、NOTICE 写法）、jolt-m / acl-m（导出审计、arm64 与 wasm 行）、miniaudio-m（compat 之上的 wasm 行）、
grpc-m（codegen feature、rule 子包、版本耦合检查）、2026-10-24-add-mwrap-and-ort-plan.md（候选索引 commit 固定）。

## 1. 目标与交付

| 仓库（新建） | 包身份 | 版本 | 实现 | tag / 资产 / CN 镜像 |
|---|---|---|---|---|
| mcpplibs/abseil-m | `mcpplibs.mwrap.abseil` | `20250512.1` | `compat.abseil` | `mwrap-20250512.1` / `abseil-m-20250512.1.tar.gz` / `mcpp-res/mwrap-abseil`（tag `20250512.1`） |
| mcpplibs/protobuf-m | `mcpplibs.mwrap.protobuf` | `35.1` | `compat.protobuf` | `mwrap-35.1` / `protobuf-m-35.1.tar.gz` / `mcpp-res/mwrap-protobuf`（tag `35.1`） |
| mcpplibs/openssl-m | `mcpplibs.mwrap.openssl` | `3.5.9` | `compat.openssl`（新增 3.5.9） | `mwrap-3.5.9` / `openssl-m-3.5.9.tar.gz` / `mcpp-res/mwrap-openssl`（tag `3.5.9`） |
| mcpplibs/grpc-m（修订） | `mcpplibs.mwrap.grpc` | `1.83.0.1` | 依赖改 `compat.openssl 3.5.9` | `mwrap-1.83.0.1` |

首发一次做完整：openssl 含 `digest`（默认）与 `tls-loopback` 模板；protobuf 含 `codegen`、`upb`、`gzip` feature 与 `message`（默认）、`codegen` 模板。

PR 一览（**每个仓库恰好一个 PR**，保留 checkpoint commits）：

| PR | 仓库 | 内容 |
|---|---|---|
| IDX | mcpp-index | compat.openssl 3.5.9；依赖方切换（带 revision）；compat.protobuf Windows protoc；grpc 1.83.0.1；三个 mwrap 描述符；消费者成员；CI 接入；CHANGELOG |
| G | grpc-m | 1.83.0.1 |
| A | abseil-m | 新包 |
| P | protobuf-m | 新包 |
| O | openssl-m | 新包 |

IDX 先以 draft 打开并持续推进；各封装仓库 CI 固定到 IDX 的某个候选 commit（§8），IDX 最后合入即发布。

## 2. 现状（2026-11-19 核查）

- `compat.abseil 20250512.1`、`compat.protobuf 35.1`：mcpp 图内源码构建，linux/macosx/windows。compat.protobuf 的 feature：
  `protoc`（libprotoc + protoc 二进制，要求同时开 `upb`）、`upb`、`gzip`。**Windows 上去掉了 `protoc` target**（host tool 子构建在
  三个 abseil TU 的 `.ddi` 缺失处失败，原因未查明）。`compiler/importer.cc`、`parser.cc` 已在运行时源码列表中。
- `compat.openssl 3.5.1`：install() 钩子在安装时为**宿主**运行 Configure + make（linux/macOS 带 asm）；Windows 为 VC-WIN64A + nmake，
  且配置为 `no-asm`。产物绑定宿主 C 库（`provides = ["platform-sdk"]`），不能交叉构建；install 钩子本身与版本无关，升级只改 url/sha/注释。
- 依赖 `compat.openssl 3.5.1` 的：index 描述符 asio(ssl)、curl、httplib、websocket、jwt-cpp、mysql-connector-cpp（`deps`、xpm 安装期依赖
  `compat:openssl@3.5.1` 两处、`find_dep_install_dir`）；**清单在上游归档里、index 改不了的**：`mcpplibs.mwrap.grpc 1.83.0`、旧身份
  `grpc.grpc 1.83.0`（pkgs/g/grpc.lua）、`yizhinailong.mcr`；测试 `tests/test_select_members.py:91`、tests/examples 中的 openssl/asio-ssl/curl/grpc-*。
- grpc-m：tag `v1.83.0`、`v1.83.0-2/-3/-4`、`mwrap-1.83.0`；`plugin/`、`rules/` 已为 1.83.0.1，且 index 中 `grpcgen`/`grpc-plugin 1.83.0.1`
  指向 **mwrap-1.83.0 的归档**；其 CI 断言 `runtime == 1.83.0` 且 `plugin == rule == runtime + ".1"`；`MCPP_VERSION` 固定 2026.10.24.1；
  无 Windows 行（理由“compat.openssl 无 Windows”已过时）。
- mcpp v2026.11.18.1 仅发布 linux x86_64/aarch64、macosx-arm64、windows-x86_64 二进制。index CI 覆盖 linux x86_64、macos-15、windows-2022，
  **无 wasm 作业、无 Linux aarch64**。index `min_mcpp` 为 2026.9.18.3。
- 上游最新：OpenSSL 3.5.9（LTS）/ 3.6.5 / 4.1.0；Abseil 20260817.0；Protobuf v36.2。
- 未合并的自动更新 PR：#634（compat.httplib 0.64.0）、#563（yizhinailong.mcr 0.3.0），都涉及 openssl 依赖方。

## 3. 已确认的决策

- **D1**：三库均薄封装于 compat，不 vendor 源码；与 grpc 同图时各只有一份实现。
- **D2**：abseil `20250512.1`、protobuf `35.1` 与 compat/grpc 对齐；compat.openssl 新增 3.5.9，依赖方切换，grpc-m 发修订版，openssl-m 首发 3.5.9。
- **D3 命名（v4 建议，待确认）**：仓库 `abseil-m`、`protobuf-m`、`openssl-m`；namespace `mcpplibs.mwrap`，name `abseil`/`protobuf`/`openssl`。
  仓库名 = 包短名 + `-m`，与现有 40 个封装一致，**不产生例外**。上游仓库名 `abseil-cpp` 中的 `-cpp` 只用于区分 abseil-py，
  在只有 C++ 的生态里是冗余的；`abseil` 也是 compat.abseil、vcpkg、Conan、Homebrew、xmake 采用的包名。
  （godot-cpp、llama.cpp 保留后缀，是因为后缀本身就是产品名的一部分。）上游来源记录仍用原名：`upstream/abseil-cpp/`、documents.json 的 repo 字段。
  abseil 的全部名字：

  | 项 | 值 |
  |---|---|
  | 仓库 / 资产 / CN 镜像 | `mcpplibs/abseil-m` / `abseil-m-<ver>.tar.gz` / `mcpp-res/mwrap-abseil` |
  | 包 | namespace `mcpplibs.mwrap`，name `abseil`；描述符 `pkgs/mwrap/abseil.lua` |
  | 模块 | `mcpplibs.mwrap.abseil`、`mcpplibs.mwrap.abseil.strings` …、`mcpplibs.mwrap.abseil.macros`；根文件 `src/abseil.cppm` |
  | 宏头文件 | `#include <mwrap/abseil/macros.hpp>`（仓库内 `include/mwrap/abseil/macros.hpp`，同 libpng-m/freetype-m） |
  | 宏映射 C++ 命名空间 | `mcpplibs::mwrap::abseil::macros` |
  | 上游 API / 头文件 | 不变：`absl::…`、`<absl/…>` |

  protobuf、openssl 同理：`<mwrap/protobuf/macros.hpp>`、`<mwrap/protobuf/prelude.hpp>`、`<mwrap/openssl/macros.hpp>`。
- **D5**：protobuf 有 `codegen`（protoc + 规则包）。
- **范围**：首发做完整，覆盖所有可行平台；做不到的写明原因。

## 4. 平台

### 4.1 矩阵（封装仓库 CI 行）

| 行 | abseil | protobuf | protobuf codegen | openssl |
|---|---|---|---|---|
| Linux x86_64 gcc@16.1.0 / llvm@23.1.3 | ✓ | ✓ | ✓ | ✓ |
| Linux aarch64 gcc / llvm（ubuntu-24.04-arm） | ✓ | ✓ | ✓ | 待测（compat.openssl 的 aarch64 路径从未进 CI） |
| macOS arm64 llvm（macos-15） | ✓ | ✓ | ✓ | ✓ |
| Windows x86_64 llvm（windows-2025，MSVC ABI） | ✓ | ✓ | 取决于 §5.3 | ✓（no-asm） |
| wasm32-emscripten（node） | ✓ | ✓ | protoc 在宿主运行 ✓ | ✗ |

`platforms`：abseil、protobuf 为 `["linux", "macos", "windows", "emscripten"]`；openssl 为 `["linux", "macos", "windows"]`。

不覆盖且原因明确的：

- **macOS x86_64**：mcpp 没有 macOS x86_64 二进制，macos-15-intel 行无法启动。mcpp 发布该二进制后再加。
- **Windows arm64**：mcpp 无该宿主二进制；compat.openssl 写死 `vcvars64.bat` / `VC-WIN64A`，该格必然失败。
- **openssl 的 wasm32 / openkal（musl）/ 交叉目标**：compat.openssl 是安装时的宿主构建。改为图内构建需要按数据模型
  （LP64/LLP64/ILP32）做 Configure 快照，并且为保留 AES-NI/ARMv8 加速与常数时间实现，要按目标提交 perlasm 汇编；还会打破
  mysql-connector-cpp 对安装目录布局的依赖。这是独立的 compat 重构，另起计划。（Windows 现已 no-asm，即 C 查表 AES，README 写明。）
- abseil/protobuf 在 openkal 目标上由 index 的 openkal-compat 测量覆盖，不进封装仓库 CI。

### 4.2 各平台要点（已实测部分标 ✔）

- **wasm32**：✔ em++ 6.0.9 不加 `-pthread` 可编译抽样的 abseil（mutex、cctz、symbolize、flags、log）与 protobuf（arena、map、JSON、message）TU。
  compat 描述符大概率不需修改（miniaudio 的 `-lpthread` 在 wasm 行无碍）；只在封装 CI 实测失败时再在 IDX 中补 `target_cfg`。
  多线程测试在该行跳过；时区只用 UTC/固定偏移；导出审计按目标分别记录（`long`/指针宽度不同）。index 不新增 wasm 作业，wasm 覆盖在封装仓库 CI（与 jolt/miniaudio 一致）。
- **Windows**：✔ abseil 公共头不含 `<windows.h>`，protobuf 只有 `compiler/subprocess.h`；只有 openssl 经 `e_ostime.h` 引入 `<winsock2.h>` →
  openssl-m 在 `cfg(windows)` 下设 `NOMINMAX`/`WIN32_LEAN_AND_MEAN` 并在 README 说明。wincrypt 宏冲突的 `#undef` 在 `openssl/types.h`，头文件混用测试覆盖。
- **Linux aarch64**：compat.openssl 的 gcc sysroot + xim perl 路径首次在 CI 运行；失败则在 IDX 中修 compat，不降级声明。

## 5. compat 与 grpc 的变更（都在 IDX / G 中）

### 5.1 compat.openssl 3.5.9

- 新增 3.5.9 条目（GLOBAL + CN 镜像；sha256 以上游 `.sha256` 文件核对，自审下载得 `603f5602…859a`），**3.5.1 条目不动**。
- 依赖方切到 3.5.9：asio、curl、httplib、websocket、jwt-cpp、mysql-connector-cpp（三处）；改的是已发布条目的依赖 →
  用 index `revision`（必要时 `floor`）刷新已安装载荷，并实测“已有旧缓存的构建”能刷新且运行（mwrap-licensing.md 末段）。
- 改不了的：`mwrap.grpc 1.83.0`、`grpc.grpc 1.83.0`、`yizhinailong.mcr`。它们与切换后的依赖方或新包同图会出现**两份 OpenSSL**。
  CHANGELOG 与 openssl-m README 写明：用 OpenSSL 的 gRPC 请用 `mcpplibs.mwrap.grpc 1.83.0.1`；mcr 等待其上游更新清单。
- 处理 #634 / #563：先合入或在 IDX 中 rebase，避免冲突。
- 测试与注释同步：`tests/test_select_members.py`、tests/examples 各成员、openkal `members.toml` 中过时注释。

### 5.2 grpc-m 1.83.0.1（G）

- 运行时包 `mcpplibs.mwrap.grpc` → `1.83.0.1`，依赖 `compat.openssl = "3.5.9"`，其他不变；`MCPP_VERSION` → 当前固定版本。
- **`plugin/`、`rules/` 保持 1.83.0.1 且内容不变**：不新增它们的 index 条目（现有条目继续指向 mwrap-1.83.0 归档）。改写 CI 的版本检查为
  “runtime = upstream 或 upstream + 修订；plugin == rule == 1.83.0.1；`git diff mwrap-1.83.0 -- plugin rules` 为空”。
  实施前先确认 mcpp 对 path 子包按路径/内容而非 name@version 缓存。
- ci.yml 的 `paths-ignore: **.md` 导致纯文档合入 commit 无法打 tag：G 的合入 commit 必须触发 CI（或 release.yml 改为接受最近一次被 CI 覆盖的祖先）。
- Windows：作为**附加尝试**加 windows-2025 行（210 分钟上限内）；通过则 `platforms` 加 windows，并同步放开 index 中 grpc 成员的 `cfg(unix)` 门控；
  不通过则保持 linux/macos，并把过时注释改为真实原因。不阻塞其他 PR。

### 5.3 compat.protobuf：Windows 上的 protoc

- 在 windows-2025 + 当前 mcpp 复现（注释写于较早引擎）；取子构建内层 ninja 完整输出。已修复 → 去掉 `windows.targets` 覆盖；
  引擎问题 → 向 mcpp 提 issue 附最小复现。本轮修不了：protobuf-m 的 `codegen` 在 Windows 明确报错，README 与平台表注明。

### 5.4 许可通知

compat 三包没有 `license_files`。按 libpng-m 做法，**由各封装保留并部署其静态闭包的全部通知**：

| 封装 | `upstream/` 保留并 `runtime.deploy` |
|---|---|
| abseil-m | `abseil-cpp/LICENSE`、`README.md` |
| protobuf-m | `protobuf/LICENSE`、`README.md`；`utf8_range/LICENSE`（MIT）；`abseil-cpp/LICENSE`（compat.protobuf 依赖 compat.abseil） |
| openssl-m | `openssl/LICENSE.txt`、`README.md` |

部署路径为 `licenses/<lib>/upstream/<组件>/`，同时使用两个封装时不会互相覆盖。`check_installed_template.py` 的 `STATIC_NOTICES` 扩展为每包多个许可文件。

## 6. 三个封装仓库

### 6.1 通用约定

- 布局：`mcpp.toml / .xlings.json / upstream/<组件>/ + upstream/documents.json / src/<lib>.cppm 与子模块 / src/macros.cppm /
  include/mwrap/<lib>/macros.hpp / templates/ / tests/ / tools/（surface.py、surface.json、check_exports.py、check_mwrap_release.py、test_template.py）/
  docs/usage.md / README.md + README.zh.md / LICENSE / NOTICE`；`.gitattributes` 为 `upstream/** -text -whitespace`。
- NOTICE 按 libpng-m 格式：mcpp-community contributors 版权行、Apache-2.0 适用范围，并写明上游许可与版权人——
  OpenSSL：Apache-2.0，The OpenSSL Project Authors；protobuf：BSD-3-Clause，Google LLC，另列 utf8_range（MIT）与 Abseil（Apache-2.0，The Abseil Authors）；
  abseil：Apache-2.0，The Abseil Authors。
- 清单：`[package.metadata.mwrap] upstream-version`；`authors = ["mcpp-community"]`；Topics `mcpp-community`、`cpp-modules`、库名。
- 导出：`tools/surface.py` 用 **clang** JSON AST 读公共头（按 compat 的实际宏配置），生成 `tools/surface.json`；`export namespace <ns> { using <ns>::X; }`
  （libc++ `std.cppm` 写法；protobuf 35.1 无 inline namespace）。**命名空间作用域运算符必须导出**（Clang 不导出就拒绝 `cout << status`、
  `Duration + Duration`；GCC 接受，所以审计以 Clang 为准）。不导出的实体每项带原因列清单，不静默 prune。
  GCC 对 abseil/protobuf 的 `-Wexpose-global-module-tu-local` 仅为警告（`kMsbs8Bytes`、`KeyMapBase` 等），模块 TU 不加 `-Werror`，并在审计中记录。
- **头文件与 import 混用（✔ 已实测）**：Clang 两种顺序都可；GCC 下 **import 后再 include 会失败**（`std::__is_constant_evaluated` 重定义），
  include 在前但包含的头少于模块 GMF 时也会失败。规则：**所有 #include 在前，import 在后**；protobuf 提供
  `<mwrap/protobuf/prelude.hpp>`（含 `descriptor.pb.h` 等与模块 GMF 一致的头），生成代码的 TU 先 include 它。
  GCC 上 import-在前 是已知限制写入 README，测试只断言支持的顺序，另保留一个 Clang 两序用例。
- 宏：
  1. 常量宏 → `mcpplibs::mwrap::<lib>::macros` 下同名 `constexpr`，`static_assert` 等于原宏；
  2. 单一调用转发 / 名称别名宏 → 同名 inline 函数；
  3. 字符串化、可变参、类型泛型、逗号列表、控制流、日志断言、依赖 `__FILE__/__LINE__` → 只经 `<mwrap/<lib>/macros.hpp>`；
  原宏与映射分别测试，docs/usage.md 列完整清单。
- 模板：`[dependencies]` 写点分 key `{{self.name}} = { version = "{{self.version}}", … }`（不加引号，--strict 拒绝带引号形式）。
- README：模块栏只列根模块与少数核心子模块 + `> More Modules API -> docs/usage.md`。
- CI：`ci.yml` 按 §4.1，dev/release 两 profile，身份与双语 README 契约，导出审计（Linux LLVM 行重推导）；`templates.yml` 对**每个模板**从安装副本
  `mcpp new` 后 strict build/run；`release.yml` 由 `mwrap-*` tag 触发。构建缓存按 toolchain+profile 键。索引固定方式见 §8。
- mcpp：实施开始时核 remote main 与最新稳定 mcpp（目前 2026.11.18.1），清单/CI/模板/例子中精确固定。
- 本地：80% 资源预算（mwrap-tests.slice、`MCPP_JOBS`），三库不并行全量编译，保留 ≥6 GiB 磁盘。

### 6.2 abseil-m（`mcpplibs.mwrap.abseil`）

- 模块：根聚合 `.base` `.algorithm` `.cleanup` `.container` `.crc` `.debugging` `.flags` `.functional` `.hash` `.log` `.memory` `.meta` `.numeric`
  `.random` `.status` `.strings` `.synchronization` `.time` `.types` `.utility`；`.macros`。`*_internal` 不导出。
- 宏：版本常量、`ABSL_HAVE_*` → constexpr；`LOG`/`CHECK`/`ABSL_*LOG*`/`ABSL_*CHECK*`/`ABSL_FLAG`/`ABSL_DECLARE_FLAG`/`ABSL_PREDICT_*`/线程注解/属性 → macros.hpp。
- 模板 `basics`：StrSplit/StrJoin/StrFormat、flat_hash_map、StatusOr 错误路径、UTC CivilTime、自定义 LogSink 捕获 LOG。
- 测试：上述 API、Hash 一致性、Mutex/Notification（wasm 外多线程）、flags、Cord、random 分布边界、`operator<<`/算术运算符可用、宏与常量、混用规则。

### 6.3 protobuf-m（`mcpplibs.mwrap.protobuf`）

- 依赖 `compat.protobuf = "35.1"`；**dev-dependency** `mcpplibs.mwrap.abseil`（仅用于类型同一测试）。模块不导出任何 `absl` 名字；
  使用 `absl::Status` 等名字的消费者自己 import `mcpplibs.mwrap.abseil`（README 说明）。
- Features：

  | Feature | 内容 |
  |---|---|
  | `codegen` | `compat.protobuf = { features = ["upb"], tools = ["protoc"], reexport = true }` + 规则子包 `rules/`（host module `protogen`） |
  | `upb` | 转发 compat `upb`（与 grpc 同图时并集，一份实现） |
  | `gzip` | 转发 compat `gzip`（`GzipInputStream/OutputStream`，引入 compat.zlib） |

- 规则：`protogen`，架构与取舍见 §6.5。
- 模块：根（Message/MessageLite/Arena/RepeatedField/Map/Descriptor/Reflection/DynamicMessage/DescriptorPool/TextFormat + well-known types）、
  `.io`、`.util`（JsonUtil、MessageDifferencer、TimeUtil、FieldMaskUtil、delimited）、`.compiler`（Importer、DiskSourceTree、Parser——已在运行时源码中，
  **不需要 feature**）、`.macros`。
- 宏：`GOOGLE_PROTOBUF_VERSION`/`PROTOBUF_VERSION` → constexpr；`GOOGLE_PROTOBUF_VERIFY_VERSION` → macros.hpp。
- 模板：`message`（默认，无 protoc：运行时构造 FileDescriptorProto → DynamicMessage；Struct/Timestamp ↔ JSON/文本）；`codegen`（`proto/*.proto` + prelude + `protogen::generate_all()`）。
- 测试：wire 字节 pin、JSON/文本往返、MessageDifferencer、Any、TimeUtil、gzip 往返、Importer 解析 .proto、`JsonStringToMessage` 的 `absl::Status` 与 mwrap.abseil 类型同一、codegen 模板。

### 6.5 代码生成规则的架构（protogen 与 grpcgen）

**行业做法**：代码生成规则都归 protobuf 所有，是一个以插件为参数的通用层；gRPC 只提供一个插件，外加一层很薄的便捷封装。

| 体系 | protobuf 层（通用） | gRPC 层 |
|---|---|---|
| Bazel | `proto_library` + `cc_proto_library`（protobuf / rules_proto 仓库） | `cc_grpc_library` 建在 `cc_proto_library` 之上（grpc 仓库） |
| CMake | `protobuf_generate()`，随 protobuf 的 package config 发布 | 调同一个 `protobuf_generate(... PLUGIN protoc-gen-grpc=...)` |
| Buf | `buf generate` + 插件列表 | gRPC 只是其中一个插件 |
| xmake / Meson | `protobuf.cpp` 规则 / generator | 给同一规则传 grpc 插件参数 |

共同点：
- 规则归 protobuf（它拥有 protoc 和 well-known types）；
- 插件是一等参数；
- gRPC 依赖 protobuf 的规则，反过来不行；
- 生成器与运行时同一个版本。

**现状**：grpcgen 的 491 行里，大部分其实是这个通用层：L0–L3 分层、`plugin` 结构、WKT 定位、嵌套目录、每个 .proto 一条边、
边描述中记录参数。gRPC 专有的只有 `cpp()` 插件和 `.grpc = true` 这个快捷参数。也就是说，通用层目前被放在 grpc-m 里。

**可选方案**：

| 方案 | 分层 | 问题 |
|---|---|---|
| ① protobuf-m 复用 grpcgen | protobuf → grpc，依赖反转 | 只用 protobuf 的项目要依赖 grpc 的规则包，protobuf-m 的版本也绑到 grpc 的版本轴上；名字语义不对 |
| ② protobuf-m 自带私有 protogen（path 子包、不发布） | 正确 | 通用层有两份实现；grpcgen 没法依赖它（不能 path 依赖到别的仓库），会长期分叉 |
| ③ **protogen 作为通用层，独立发布；grpcgen 以后改为建在它之上** | 正确，与行业做法一致 | 本轮多一个 index 描述符和一个消费者成员 |
| ④ 写进 mcpp 引擎 | — | 引擎要绑定某个库的知识；CMake 已经把 FindProtobuf 让位给 protobuf 自带的 config，行业方向相反 |

**建议 ③**：
- **身份**：namespace `mcpplibs`，name `protogen`，host module `protogen`（与 grpcgen 同一命名规则：裸包名 = 模块名，是生态自写的规则，不属于上游）。
  **版本 = protobuf 版本 `35.1`**，生成器、规则、运行时共用一个版本轴。
  源码在 protobuf-m 的 `rules/`，从 protobuf-m 的 `mwrap-35.1` 归档发布（同 grpcgen 从 grpc-m 归档发布），描述符 `pkgs/p/protogen.lua`（与 `pkgs/g/grpcgen.lua` 同约定）。
- **API**：从 grpcgen 抽出通用层，保持 L0–L3 的形态与参数名，让以后的迁移是机械替换：
  `generate_all()`、`generate({"name"})`、`options{ .imports, .protoc_args, .plugins, … }`、`plugin{ name, tool, outputs, params }`、`plan_all()`/`submit()`。
  默认只跑 `--cpp_out`；插件列表为空时不需要任何插件依赖。
  另外支持 `.descriptor_set`（生成 FileDescriptorSet，给 DynamicMessage/反射场景用）和 `.lite`（`lite:`，对应 MessageLite）。
- **接入方式**：protobuf-m 的 `codegen` feature reexport protoc 与 protogen；用户的 build.mcpp 写 `import protogen;`。
  用户也可以直接依赖 `mcpplibs.protogen`（同 grpcgen 的用法）。
- **与 grpc 共存**：本轮 grpc-m 只发 1.83.0.1，plugin/rules 不动（已确认），grpcgen 暂时保留自己那份通用层。
  文档写明：gRPC 项目调用 `grpcgen`，纯 protobuf 项目调用 `protogen`。两者都在 build.mcpp 中显式调用，不会自动重复生成；
  组合成员 `grpc-protobuf-stack` 验证两个 feature 同时开启时，只调用 grpcgen 也能正常构建。
- **后续（不在本轮）**：grpc-m 下一个上游版本里，grpcgen 依赖 `mcpplibs.protogen` 并删掉自己的通用层，只保留 `cpp()` 插件和 `.grpc` 快捷参数；
  公共 API 不变，用户的 build.mcpp 不用改。
- **测试**：protogen 单元测试在 protobuf-m 中跑（嵌套目录、imports、自定义插件，用一个测试插件二进制，以及 descriptor_set）；
  index 消费者 `tests/mwrap/protobuf-codegen` 同时覆盖 protogen 描述符（避免 “no candidate consumer” 扫描失败）；
  `check_installed_template.py --template codegen`。

### 6.4 openssl-m（`mcpplibs.mwrap.openssl`）

- 依赖 `compat.openssl = "3.5.9"`；无 feature。
- 模块：根聚合 `.crypto`（EVP、BIO、ERR、RAND、X509/PEM、BN、EC、KDF/MAC、OSSL_PARAM、provider…）、`.ssl`（ssl.h、tls1.h、dtls1.h…）、`.macros`。
  头文件按 compat 的配置读取；3.0 deprecated API 按实际声明导出（使用时仍有上游警告），模块 TU 内抑制。
- 宏与内部链接实体（docs/usage.md 列完整清单）：
  1. 常量（`SSL_OP_*`、`SSL_ERROR_*`、`TLS1_3_VERSION`、`EVP_MAX_MD_SIZE`、`NID_*`、`OPENSSL_VERSION_NUMBER`…）→ constexpr；
  2. 单一调用转发与别名（✔ `SSL_CTX_set_mode`、`BIO_get_mem_data`、`SSL_set_tlsext_host_name`；`SSLv23_method` → `TLS_method`）→ 同名 inline 函数；
  3. **`static ossl_inline` 公共 API**（`ERR_GET_LIB`、`ERR_GET_REASON`、`ERR_FATAL_ERROR`、byteorder 等，内部链接，无法 `export using`）→
     在 `mcpplibs::mwrap::openssl` 中以同名函数重新声明，逐项验证语义；
  4. 类型泛型/可变参/逗号列表（`sk_TYPE_*`、`lh_*`、`DEFINE_*_OF`、`ERR_raise_data`、`OBJ_*` 列表宏、`OPENSSL_malloc/free`）→ 只经 macros.hpp。
- 模板：`digest`（默认：SHA-256、EVP_MAC HMAC、AES-256-GCM 往返、ERR 错误路径）；`tls-loopback`（运行时生成自签证书，内存 BIO 对完成 TLS 1.3 握手并收发，无网络、无外部文件）。
- 测试：NIST/RFC 向量、内存 TLS 1.2/1.3 握手、X509 生成与校验、错误队列、四类分别测试、混用（Windows 覆盖 wincrypt）。

## 7. IDX（mcpp-index 唯一 PR）的内容

按以往 mwrap 新增（jolt 21c2013、acl 507e7d8）实际触及的文件：

- `pkgs/c/compat.openssl.lua`（+3.5.9）、依赖方描述符（切 3.5.9 + revision）、`pkgs/c/compat.protobuf.lua`（若 §5.3 修复）；
- `mcpplibs.protogen 35.1` 描述符（§6.5）；
- `pkgs/mwrap/{abseil,protobuf,openssl}.lua`（GLOBAL/CN、sha256、autoupdate `mwrap-${version}`——已核 `tag_version` 能正确解析 20250512.1、35.1、3.5.9、1.83.0.1）；
  `pkgs/mwrap/grpc.lua` 增 1.83.0.1；
- 成员（空 `[indices]`，注册根 `mcpp.toml`）：`tests/mwrap/abseil-basics`、`protobuf-message`、`protobuf-codegen`、`openssl-digest`、`openssl-tls`；
  组合成员 `tests/mwrap/grpc-protobuf-stack`（unix；mwrap.grpc 1.83.0.1 + protobuf + abseil + openssl：无重复符号、`absl::Status` 同一、只有一份 OpenSSL、分发包通知齐全）；
  `grpc-cpu` 与 validate.yml 中 grpc installed-template 的 pin 改 1.83.0.1；`grpc-tools` 不变（plugin/rules 仍 1.83.0.1）；
- `tests/mwrap/check_installed_template.py`：`STATIC_NOTICES` 三项且支持多许可文件；新增 `--template <name>` 以覆盖非默认模板（`codegen`、`tls-loopback`）；
  `validate.yml` 对应步骤（`--deploy`）；
- `tests/member-timings.tsv` 为新成员加耗时行（避免按中位数估价撑爆 90 分钟分片）；
- `CHANGELOG.md` `[Unreleased]`；本计划终稿（实测 hash、导出数量、CI 结果）。
- 不需要：站点/搜索/选择器改动（自动发现）；`index.toml` `min_mcpp` 不变（2026.9.18.3）。

## 8. 执行顺序与候选索引

1. 开 IDX draft，先提交 compat 变更（openssl 3.5.9 + 依赖方 + protobuf Windows）→ 候选 commit **C1**，等其 CI 与 `publish-artifact.yml`（若候选需要）完成。
2. G、A、O 的 CI 固定 C1：checkout `mcpp-index@<C1>`，`python3 tests/prepare_builtin_index.py --home <测试 home>`，把完整候选布局作为唯一内置索引
   （ORT/llama Vulkan 先例）。commit 在 PR 合入后仍可经 `refs/pull/<n>/head` 取到。
3. A 合入 → tag → release → CN 镜像核对字节 → IDX 加 abseil 描述符得 **C2** → P 的 CI 固定 C2（类型同一测试需要 mwrap.abseil）。
4. G、O、P 依次合入并发布，IDX 加对应描述符 → 最终 commit → IDX CI 全绿。
5. **上传 GitCode 前必须本地验证完毕**：GitHub release 资产下载两次核对 sha256；在本机（Linux x86_64，80% 资源预算内）以 IDX 最终 commit
   做完整冷安装：`check_installed_template.py` 跑每个模板（`--deploy` 校验通知）与全部 tests/mwrap 新成员；另一台 runner 的 CI 结果覆盖 macOS/Windows/arm64。
   全部通过后才用 gtc 上传 CN 镜像（tag 用裸版本号），上传后再次下载核对字节与 GLOBAL 一致。
6. IDX 合入 → 等 `publish-artifact.yml` → 对四个包跑 `check_installed_template.py --published-index`，含 `MCPP_INDEX_MIRROR=CN`。
7. 自动更新：G 打 `mwrap-1.83.0.1` 后每日扫描可能提出 grpc bump，与 IDX 内容相同，关闭即可；#634/#563 先处理（§5.1）。

回滚（已获授权）：IDX 合入前发现本轮四个版本有缺陷，可覆盖首发——替换 GitHub tag 与资产、更新 hash，重跑当前提交 CI 与真实安装验收。
GitCode 同名资产无法由工具覆盖：如确需覆盖，我会给出要删除的 release/资产、新文件路径与 sha256，**由你在 GitCode 上操作**，之后我核对字节。
IDX 合入后的缺陷按规范追加修订尾号。

## 9. 风险

| 风险 | 应对 |
|---|---|
| abseil/protobuf 头文件 TU-local 暴露 | GCC 仅警告；Clang 审计逐项记录；无法导出的带原因列出 |
| GCC 的 include/import 顺序限制 | §6.1 规则 + prelude 头；限制写入 README |
| Windows protoc 子构建 | §5.3；最坏 codegen 在 Windows 明确报错 |
| openssl 依赖方切换 / 改不了的旧清单造成两份 OpenSSL | 3.5.1 保留；revision + 缓存刷新实测；CHANGELOG/README 指向 grpc 1.83.0.1 |
| grpc 版本检查与 plugin/rules 版本耦合 | §5.2 改写检查 + 目录不变断言 |
| Linux aarch64 上的 compat.openssl 首次进 CI | 失败则在 IDX 修 compat |
| CI 耗时（abseil+protobuf × 多行 × 2 profile；grpc Windows 210 分钟） | 构建缓存；审计只在一行重推导；成员耗时行；grpc Windows 不阻塞 |
| 封装 CI 依赖候选 commit | 固定 commit，经 refs/pull 可达；下次版本升级时改回已发布索引 |
| compat 对齐被他人单独升级打破 | 描述符注释记录对齐关系，升级须联动三个封装与 grpc-m |

## 10. 规范更新（随 IDX 提交）

`docs/mwrap.md` 与 `docs/zh/mwrap.md`：
- 命名：`<上游库名>-m` 中的“库名”取库本身的名字，不含仅用于区分语言的仓库后缀（abseil-cpp → abseil-m）；
- 记录 GCC 的 include/import 顺序限制，以及 Clang 下运算符必须导出。

## 11. 自审修订记录（v2 → v3）

| 来源 | 结论 | 处理 |
|---|---|---|
| 规范 | 两个 index PR 违反“每仓库一个 PR” | 合并为 IDX，封装 CI 固定候选 commit |
| 规范 | compat 不带许可文件，通知会缺失 | §5.4 由封装保留并部署整个静态闭包的通知 |
| 规范 | abseil 包名偏离先例 | D3 标为新例外并更新规范 |
| 规范 | 规则模块名应为裸名 `protogen`；documents.json 位置；`.gitattributes`；模板 key 写法；README 模块栏 | §6.1 / §6.3 已改 |
| 技术 | macOS Intel、Windows arm64 没有 mcpp 二进制 | 移出矩阵并写明原因 |
| 技术 | `compiler` feature 转发 protoc 会拉 libprotoc 和 upb，多余且可能链接失败 | 删除该 feature，`.compiler` 进基础模块 |
| 技术 | GCC 混用顺序限制（已实测） | §6.1 规则 + prelude 头 |
| 技术 | Clang 要求导出运算符 | 审计以 Clang 为准 |
| 技术 | OpenSSL 缺 `static ossl_inline` 一类 | 宏方案改为四类 |
| 技术 | Windows 上只有 openssl 需要 NOMINMAX；Windows 本已 no-asm | §4.2 / §4.1 已改 |
| 技术 | 依赖方清单不全；Linux aarch64 未测 | §2 / §5.1 / §4.1 已改 |
| 流程 | 封装 CI 看不到未发布依赖 | §8 候选 commit 流程 |
| 流程 | grpc-m CI 拒绝 1.83.0.1；plugin/rules 已占用 1.83.0.1 | §5.2 |
| 流程 | 依赖方先切换会在同图中出现两份 OpenSSL | 与 grpc 1.83.0.1 同在 IDX；旧清单的风险写明 |
| 流程 | 非默认模板未被安装检查覆盖；成员缺耗时行；index 无 wasm 作业 | §7；wasm 留在封装 CI |
| 流程 | 没有回滚路径；CN 资产不可覆盖 | §8 先冷安装再镜像；请求预先授权 |

## 12. 实施结果（v5，2026-11-20）

| 仓库 | 合入 | 发布 | sha256（GitHub = GitCode） |
|---|---|---|---|
| abseil-m | #1 squash b206127 | mwrap-20250512.1 | 14cdfc1a08576e20f57b5d81a33333c4d6007d5efd141e5d3b5e9333c7ce198e |
| protobuf-m | #1 squash d5ffe2d | mwrap-35.1 | 26b0305e7d602e049391aa579e7e3cef17ebedff27c4ff416054c03df9c687ed |
| openssl-m | #1 squash 836b473 | mwrap-3.5.9 | df3d0458c18538b9dc680221e2e78e9b5eacc632d37c33efbc744ac64def5e8f |
| grpc-m | #9 squash 48b91a5 | mwrap-1.83.0.1 | 5f71291472460f980f64e0d8d76ac8bccd5f76fa4ed3fd35904b22f8db9d17f9 |

每个仓库一个 PR，CI 全绿后 squash 合入，main 的 CI 通过后打 tag；资产下载两次与 `.sha256` 一致，本机以真实归档跑
`check_installed_template.py`（每个模板；默认模板带 `--deploy`）后才上传 GitCode，上传后再次下载核对字节。IDX 为 mcpp-index#845。

与方案的偏差与实测结论：

1. **openssl-m 的结构（review 后改为方案 C）。** 首版提交生成物（约 15.7 万行，98% 由 tools/surface.py 生成）。改为只提交紧凑记录
   `src/surface.tsv`（25.7k 行：一行一项，带平台条件与宏的分类原因），由包的 `build.mcpp` 在构建时生成 `.crypto`、`.ssl`、`.macros`
   三个模块单元与常量测试的比较（对包自身与每个消费者都运行）；生成结果与原生成物逐字节相同。`check_exports.py` 校验记录，
   并在 Linux LLVM 行由 clang 重新推导、要求文本一致。规范已加入该做法（docs/mwrap.md）。
2. **平台。** openssl-m：Linux aarch64 只用 LLVM（mcpp 在该平台的 gcc@16.1.0 是 musl 工具链，compat.openssl 在安装时按 glibc 构建）；
   Windows 需在 OpenSSL 头文件前引入 `<windows.h>`（async API），`OSSL_BAD_ASYNC_FD`、`CRYPTO_ONCE_STATIC_INIT`、`OPENSSL_fork_*`
   按平台条件导出。grpc-m 1.83.0.1 在 Windows 上可构建链接，但运行时启动即中止（exit 133），因此不声明 Windows。
   protobuf-m 的 `codegen` 仅 Linux/macOS：compat.protobuf 35.1 在 Windows 构建 protoc 失败（"multiple rules generate bin/protobuf.lib"）。
3. **mcr 与 compat.openssl。** yizhinailong.mcr 0.1.5 固定 3.5.1，与改用 3.5.9 的依赖同图时版本不可调和；成员或 target 表中的 override
   在工作区内不生效，改为根 mcpp.toml 的 `[workspace.dependencies] compat.openssl = { version = "3.5.9", override = true }`。
4. **protogen 的依赖名。** 规则中以限定名 `compat.protobuf` 取 dep_dir：grpcgen 与 protogen 同在时短名有歧义。
5. **GCC 16 的模块合并。** 同一翻译单元 import protobuf 与 Abseil 时须 import Abseil 的分组模块（根模块带入 `abseil.log`，
   GCC 随后报 "failed to read compiled module cluster … Bad file data"），且不在命名空间作用域对 protobuf 调用取 decltype
   （GCC 报 descriptor.h 成员 "conflicting type for imported declaration"）。按此写法，`grpc-protobuf-stack` 在一个翻译单元中
   import 四个封装，GCC 与 Clang 均通过；Clang 两种写法都接受。这两条已写在 protobuf-m 的 abseil_identity_test 与成员注释中。
6. **成员。** 实际为 `abseil-basics`、`protobuf-message`、`protobuf-codegen`、`openssl-tls`、`grpc-protobuf-stack`（方案中的
   `openssl-digest` 并入 `openssl-tls`；摘要由 openssl 的默认模板在 installed 检查中覆盖）；`grpc-cpu` 与 installed gRPC 模板改为 1.83.0.1。
7. **候选索引固定。** 四个封装仓库的 CI 固定 IDX 候选 commit（compat.openssl 3.5.9 尚未发布）；下次版本升级时改回已发布索引。
8. **本机环境（不影响 CI）。** 新建 home 时 compat.openssl 的安装 hook 经 xlings shim 调用 `gcc`，本机全局 subos 未装 gcc 时失败；
   IDX 的测试 home 与 check_installed_template 的新 home 不受影响，openssl-m 的模板脚本在本机受影响（CI 通过）。

待 IDX 合入后：`check_installed_template.py --published-index` 对四个包冷安装验收，含 `MCPP_INDEX_MIRROR=CN`。
