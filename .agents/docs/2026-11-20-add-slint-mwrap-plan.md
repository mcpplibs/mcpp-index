# 实施方案：Slint 进入 mcpp 生态（compat.slint + mcpplibs.mwrap.slint + 构建规则 slint.mcpp.plugins）

状态：已按维护者决定修订（2026-11-20）：规则放入 slint-m，模块名 `slint.mcpp.plugins`（`slint.mcpp.plugins` 被索引的 R9.6 收录门拒绝，见 §1 修订记录）。上游版本：Slint 1.19.0（2026-11-16）。
本文的事实均为实测或读源码所得，出处写在各条之后；未验证的部分列在 §9。

## 0. 目标

开发者在 mcpp 中得到与官方 CMake 集成**同等的功能覆盖**：

| 官方 CMake | 本方案 |
|---|---|
| `find_package(Slint)` + 预构建 SDK | `compat.slint` 的预构建档位（xlings-res，GitHub + GitCode） |
| `FetchContent(... SOURCE_SUBDIR api/cpp)` + `SLINT_FEATURE_*` | `compat.slint` 的同名 feature；未预构建的组合走源码构建（cargo，§4.3） |
| `slint_target_sources(...)` 与目标属性 | 构建规则 `slint.mcpp.plugins`（包 `mcpplibs.slintgen`，slint-m 的 `rules/`，§5） |
| `#include "app.h"` | 同上，另可 `import` 生成的组件模块（§5.3） |
| — | `import mcpplibs.mwrap.slint;`（§6） |

## 1. 命名与归属（按包的性质区分）

| 性质 | 规则 | 本方案 |
|---|---|---|
| 上游库原样构建 | `compat.<名>` | `compat.slint` |
| 通用 C++ 库的模块封装 | `mcpplibs.mwrap.<名>`（docs/mwrap.md） | `mcpplibs.mwrap.slint`，仓库 `mcpplibs/slint-m` |
| mcpp 专用构建插件（导入引擎接口 `mcpp`） | 通常 `mcpp.<命名空间>.*`（R9.6）；保留的第二段只属于命名空间为 `mcpp` 的包 | 包 `mcpplibs.slintgen`（slint-m 的 `rules/`，与 grpc-m 的 `grpcgen` 同形），模块 `slint.mcpp.plugins` |

**修订记录。** 初版把规则放进官方插件包 `mcpp.plugins`（feature `rules-slint`，模块 `mcpp.rules.slint`），依据是 `rules-qt`
等先例与 R9.6。维护者决定改为放入 slint-m、模块名 `slint.mcpp.plugins`（mcpp-plugins#64 已不合入关闭）。代价已核实：
(1) 实测：`mcpp.plugins.slint` 由命名空间不是 `mcpp` 的包提供，引擎每次构建警告，而索引的成员门（tests/run_members.sh）
拒绝此类包，mcpp-index#861 因此失败；维护者改定模块名为 `slint.mcpp.plugins`（不以 `mcpp.` 起头，不受 R9.6 约束），
以修订号 1.19.0.1 发布（mwrap-1.19.0 已打标签、未收录）；(2) `device_extensions` 的认领不经 `reexport` 传递，所以工程须自己在
`[build-dependencies]` 写 `mcpplibs.slintgen = { …, features = ["slint"] }`，slint-m 不再 reexport 规则；
(3) 规则对 `mcpp.plugins`（feature `plugins-core`）的依赖写在规则包自己的 `[dependencies]`（mcpp 2026.10.11.1+ 形态）。

规则不声明 SDK、不固定版本（与 `rules-qt` 相同）：`slint-compiler` 与运行时出自同一个 SDK，版本一致由载荷保证。

附带发现（不在本方案范围）：`mcpplibs.protogen`（protobuf-m）与 `grpcgen`（grpc-m）是 SPEC-007 §9 之前的命名
（裸模块名 `protogen`/`grpcgen`）。后续可评估迁为 `mcpp.rules.protobuf` / `mcpp.rules.grpc`，单独立项。

## 2. 上游事实（v1.19.0，读源码与实测）

**功能开关**（`api/cpp/cmake/SlintFeatures.cmake`，括号内为桌面平台默认值）：
`compiler`(ON) `interpreter`(ON) `live-preview` `backend-winit`(ON) `backend-winit-x11` `backend-winit-wayland`
`backend-qt` `backend-linuxkms`(OFF) `backend-linuxkms-libseat` `backend-linuxkms-libinput` `backend-linuxkms-libdlmclient`
`renderer-femtovg`(ON) `renderer-femtovg-wgpu` `renderer-skia`（**桌面 OFF**，Android/iOS ON） `renderer-skia-opengl`
`renderer-skia-vulkan` `renderer-skia-software` `renderer-vello` `renderer-software`(ON) `software-renderer-path`
`accessibility`(ON) `system-tray`(ON) `testing`(ON) `experimental` `gettext` `system-testing` `mcp` `freestanding`
`image-pixel-format-rgb565` `image-pixel-format-gray8` `sdf-fonts`。其它：`SLINT_COMPILER`（空=源码构建 / `download` / 路径）、
`BUILD_SHARED_LIBS`(ON)、`SLINT_LIBRARY_CARGO_FLAGS`。

**官方预构建 SDK** 的功能集为 `INTERPRETER LIVE_PREVIEW BACKEND_WINIT RENDERER_FEMTOVG RENDERER_SKIA RENDERER_SOFTWARE
BACKEND_LINUXKMS_LIBINPUT ACCESSIBILITY SYSTEM_TRAY TESTING`——**不等于** CMake 默认值（多 skia、linuxkms、live-preview）。
其 Linux `libslint_cpp.so` NEEDED `libxkbcommon.so.0 libudev.so.1 libinput.so.10 libgbm.so.1 libfontconfig.so.1
libfreetype.so.6`（libgbm 在本生态由 `xim:mesa` 提供，即整个 Mesa）。Windows 只有 NSIS 安装包；`7z` 可直接读取
（`Type = Nsis`：`bin/slint-compiler.exe`、`include/slint/*`、`lib/slint_cpp.dll`、`slint_cpp.lib`）。

**`slint_target_sources`**（`SlintMacro.cmake`）：参数 `NAMESPACE` `LIBRARY_PATHS` `COMPILATION_UNITS` `EDITION`，输入可为
`slint-project.json`；目标属性 `SLINT_EMBED_RESOURCES`（as-absolute-path / embed-files / embed-for-software-renderer）
`SLINT_SCALE_FACTOR` `SLINT_BUNDLE_TRANSLATIONS` `SLINT_TRANSLATION_DOMAIN`；全局 `SLINT_STYLE`。

**Skia**：rust-skia 的 `build.rs` 读取 `SKIA_BINARIES_URL`、`FORCE_SKIA_BINARIES_DOWNLOAD`、`FORCE_SKIA_BUILD`
（`skia-bindings/build_support/binary_cache/env.rs`），默认从 `rust-skia/skia-binaries` 下载按目标与功能区分的预构建。

**原型结论（GCC 16 / Clang 23，经 mcpp 构建）**：生成代码大量使用 `slint::private_api`、`slint::cbindgen_private`，以模块单元
包装生成头文件后 `import` 可用（属性、回调、`SharedString`，软件渲染无头平台）。GCC 16 拒绝在模块中导出
`slint-platform.h` 的 `SoftwareRenderer`（`render_by_line` 的 requires 子句含 lambda，"exposes TU-local entity"），Clang 接受。

## 3. 总体结构

```text
mcpp-index
  pkgs/c/compat.slint.lua            运行时 + slint-compiler（载荷；feature 与上游同名）
  pkgs/mwrap/slint.lua               mcpplibs.mwrap.slint（slint-m 发布包）
  pkgs/s/slintgen.lua                mcpplibs.slintgen（slint-m 发布包中的 rules/，与 grpcgen 同形）
xlings-res（GitHub + GitCode）
  slint/<ver>/slint-cpp-<ver>-<profile>-<platform>.<ext>    预构建档位
  slint-vendor/<ver>/slint-<ver>-vendor.tar.zst              cargo vendor（源码构建离线依赖）
  skia-binaries/<key>/...                                    rust-skia 预构建的逐字节镜像
mcpplibs/slint-m
  src/*.cppm  include/mwrap/slint/macros.hpp  rules/（slintgen，模块 slint.mcpp.plugins）  templates/hello  tests  tools
```

## 4. compat.slint

### 4.1 feature

feature 名与上游 cargo 功能名逐一相同（kebab-case，与 mwrap 规范一致），**`default` = 上游 CMake 桌面默认值**：
`compiler interpreter backend-winit renderer-femtovg renderer-software accessibility system-tray testing`。
关闭默认项用依赖边的 `default-features = false`。每个 feature 的 `defines` 给出 `SLINT_FEATURE_*`（头文件的
`slint_generated_public.h` 也写有，二者必须一致，CI 校验）。

### 4.2 预构建档位

| 档位 | 功能集 | 来源 | 平台 |
|---|---|---|---|
| `default` | 上表默认值 | xlings-res：cargo 构建（xlings subos，glibc 对齐，mcpp#352） | linux-x86_64、linux-aarch64、macosx-arm64、windows-x86_64 |
| `full` | 官方预构建 SDK 的功能集 | macOS / Windows：上游官方产物（Windows 由 `xim:7zip` 解 NSIS）；Linux：xlings-res 构建 | 同上 |

档位以功能集为键：使用方解析出的功能集与某档位**完全相等**时使用该档位。
依赖随功能：`backend-linuxkms*` → `compat.libinput`（补 soname `libinput.so.10`，packaging revision）、`compat.libgbm`、
`compat.libudev`；`renderer-skia*` → `freedesktop.fontconfig`、`compat.freetype`（Linux）；`backend-qt` → Qt；`gettext` → libintl。
均以 `feature-deps` 表达，未选功能不引入。

### 4.3 源码构建（任意功能组合）

与 FetchContent 等价：以 cargo（`xim:rust`）构建 `api/cpp`，`--no-default-features --features <选择>`。规范要求获取依赖
由 provider 负责、不在编译时下载，因此：
- crates 由 xlings-res 的 `slint-vendor` 载荷提供（`cargo vendor` 结果，GLOBAL + CN），cargo 以 `--offline` 运行；
- Skia 以 `SKIA_BINARIES_URL` 指向 xlings-res 的 skia-binaries 镜像（按 mirror 选择 GitHub / GitCode）；无上游预构建的
  组合在 xlings-res CI 以 `FORCE_SKIA_BUILD=1` 构建后发布；
- 构建结果按（版本、目标、功能集）的摘要进入 mcpp 的缓存，之后复用。

### 4.4 与 mcpp 机制的对接（§9-S2 待验证）

候选：`compat.slint`（default 档）、`compat.slint-full`、`compat.slint-src` 三个提供者以同一 capability
（如 `mcpp:slint-runtime`）互斥，`mcpplibs.mwrap.slint` 的 feature 经 `feature-deps` 选择提供者；或单一包内由
install / build 程序按功能集选择载荷。以 S2 的实测结果定稿。

## 5. 构建规则 slint.mcpp.plugins（slint-m 的 rules/）

### 5.1 形态

`mcpp.toml`：
```toml
[dependencies]
mcpp.plugins = { version = "0.26.1", features = ["plugins-core"] }

[features.slint]
sources           = ["src/slint.cppm"]
rule_module       = "slint.mcpp.plugins"
device_extensions = [".slint"]
```
与 `rules-qt` 相同：不声明 SDK、不固定版本。`slint-compiler` 的来源按序：`options::compiler`；环境变量 `SLINT_COMPILER`；
工程依赖中提供 `slint-compiler` 工具的包（`compat.slint` 的 `tools`）。缺失时为警告（`mcpp emit build-database`
不失败）。

### 5.2 参数（对应 `slint_target_sources` 与目标属性）

`namespace`、`library_paths`（name → path）、`compilation_units`、`edition`、`style`、`embed_resources`、`scale_factor`、
`bundle_translations`、`translation_domain`；输入可为 `.slint` 或 `slint-project.json`。每个输入一条 action：声明的输入
包括被 import 的 `.slint` 文件（slint-compiler 的依赖输出），输出头文件（及 `compilation_units` 个 `.cpp`）。

### 5.3 模块单元（可选）

`module = "<名>"` 时另生成一个模块接口单元：全局模块片段 `#include` 生成的头文件，`export using` 每个导出组件
（以及 `namespace` 内的名字）。使用方 `import <名>;` 与 `import mcpplibs.mwrap.slint;` 并用。生成代码依赖内部命名空间，
因此组件以“生成头文件 + 包装单元”分发，不导出 `private_api`。

### 5.4 测试（slint-m 的 tests/rule-consumer）

`tests/` 中一个工程：`.slint` 经 `device_extensions` 自动交给规则；改一个被 import 的 `.slint` 只重跑一条 action；
`namespace` / `compilation_units` / `embed_resources` 生效；模块单元可 `import`；缺失 SDK 时警告不失败。

## 6. mcpplibs.mwrap.slint（slint-m）

| 模块 | 内容 | 需要的功能 |
|---|---|---|
| `mcpplibs.mwrap.slint` | `slint::` 公开 API：ComponentHandle、Window、SharedString、SharedVector、Model 系列、Image、Color、Brush、Timer、事件循环函数 … | 默认 |
| `.interpreter` | `slint::interpreter::` | `interpreter` |
| `.platform` | `slint::platform::`（自定义平台、窗口适配器、软件渲染器） | — |
| `.testing` | `slint::testing::` | `testing` + `experimental` |
| `.macros` | `SLINT_FEATURE_*` → `constexpr bool`；其余宏 | — |

- 导出面以 Clang 从公开头文件推导并审计（openssl-m 的做法：紧凑记录 + `build.mcpp` 生成，或 wuffs-m 的 AST 生成），
  不导出 `private_api` / `cbindgen_private`（只经可达性使用）。
- GCC 16 与 `.platform`：先以最小复现报告上游（lambda 位于 requires 子句）；在修复前 `.platform` 在 GCC 上以文本
  `#include <slint-platform.h>`（在 import 之前，规范已有此写法）提供，Clang 上导出；README 写明。
- feature：与 compat.slint 同名转发；`slint-compiler` 经 compat.slint 的 `reexport` 到达使用方的构建程序；规则包
  `mcpplibs.slintgen` 由使用方在 `[build-dependencies]` 写 `features = ["slint"]`（见 §1 修订记录）。
- 模板 `hello`（默认）：计数器窗口；CI 中以软件渲染无头平台运行并断言；有桌面时开窗。
- 许可：上游三选一（GPL-3.0-only / Royalty-free-2.0 / 商业），描述符列出三者，README 写明由使用方选择、Royalty-free
  不含嵌入式；封装层 Apache-2.0。

## 7. 阶段与验收

| 阶段 | 交付 | 验收 |
|---|---|---|
| 0（实测） | S1–S3（§9） | 结论写回本文 |
| 1 | xlings-res `slint` 的 `default` 档（4 平台，GLOBAL + CN）；compat.slint 1.19.0（default 档，feature 与上游同名）；`slint.mcpp.plugins`；slint-m（核心、`.interpreter`、`.platform`、`.macros`）与 `hello` 模板 | Linux（gcc/llvm）、Linux arm64、macOS、Windows 的 CI：模板严格构建并无头运行；规则的增量测试；运行时依赖闭包只含声明的提供者；导出审计 |
| 2 | `slint-vendor` 载荷；源码构建路径（任意功能组合） | 一个非档位组合（如 `default` + `gettext`）冷构建与二次缓存命中 |
| 3 | `skia-binaries` 镜像；`full` 档；`renderer-skia*` | CN 镜像下无 GitHub 访问构建成功；Skia 渲染无头截图比对 |
| 4 | linuxkms（compat.libinput soname）、Android / iOS / wasm / MCU 行、`backend-qt`、`gettext` | 各平台行的模板构建；KMS 以无显示设备的冒烟测试 |

每个仓库一个 PR，CI 全绿后合入；索引候选以 `prepare_builtin_index.py` 测试；发布后以
`check_installed_template.py --published-index`（GLOBAL 与 `--mirror CN`）冷安装验收。

## 8. PR 顺序

1. xlings-res：`slint` default 档载荷与构建脚本（xim-pkgindex `.agents/tools`，与图形栈相同的 subos 构建）。
2. mcpp-index：compat.slint（S2 定稿的形态）+ `tests/examples/slint`。
3. slint-m：PR #1（含 `rules/` 与规则测试）→ `mwrap-1.19.0`；mcpp-index：`pkgs/mwrap/slint.lua` + `pkgs/s/slintgen.lua` + `tests/mwrap/slint-*` + 已安装模板检查。（mcpp-plugins 不再参与。）
5. 之后按阶段 2–4。

## 9. 待验证（阶段 0）

- **S1 default 档的闭包**：在 xlings subos 中以 cargo 构建 default 功能集，记录 `libslint_cpp` 的 NEEDED / 依赖
  dylib / DLL 导入。目标：Linux 只剩 libc、libm、libgcc_s、libstdc++（gcc-runtime）；X11/Wayland/GL 均 dlopen。
  若仍有其它 NEEDED，逐个确定提供者。
- **S2 功能集到载荷的选择机制**：index 描述符是否支持 `feature-deps` 与 capability 互斥提供者；否则由谁（install
  钩子 / 构建程序）按功能集选择载荷，且不违反“编译时不下载”。以最小描述符实测。
- **S3 规则的依赖输出**：slint-compiler 是否输出被 import 的 `.slint` 依赖列表（depfile 或 `--dependencies`），
  供规则声明输入；否则规则自行解析 `import` 语句。

## 10. 风险

- 功能组合数量大：档位只出 default / full，其余走源码构建；CI 只验证档位与若干代表组合。
- Skia 体积与网络：只在 `renderer-skia*` 时引入，镜像覆盖实际使用的键。
- 生成代码与运行时版本耦合：由同一载荷提供 compiler 与运行时，规则不固定版本；slint-m 的版本与上游一致。
- GCC 16 的 TU-local 判定可能扩展到其它头文件：导出审计在 GCC 与 Clang 上都编译。
