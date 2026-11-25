# 修复方案：Slint 真窗口在 NVIDIA 桌面上 abort —— GL 厂商提供者缺失（v2，重写）

状态：**草案 v2，待维护者评审**（2026-11-22）。本文**取代**同名文件的 v1：v1 把原因判断为“宿主 NVIDIA 驱动桥接包过期”，这一判断已被实验推翻（§3）。本文含：结论与证据（§1）、三个现象各自的状态（§2）、被推翻的分析与教训（§3）、修复方案（§4）、以 Slint 为金丝雀的验证（§5）、实施计划与任务关系（§6）、独立且不阻塞的事项（§7）、风险与未验证项（§8）、待决问题（§9）。
事实均为实测所得，出处写在各条之后。**本文不改 mcpp 仓库**；mcpp issue #995 已关闭（§7）。

## 0. 问题

`mcpp new counter --template mcpplibs.mwrap.slint` 生成的 Slint hello 模板，在带 NVIDIA GPU 的 Linux 桌面（X11）上 `mcpp run` 会 abort；`SLINT_HEADLESS=1` 正常。

## 1. 结论与证据

**结论。** `compat.slint`（及它背后的 `xim:slint` 配方）依赖 libglvnd，也就是 GL 的**分发器**，却没有依赖任何提供 GL **厂商**的包。`compat.glx-runtime`（`compat.glfw` 依赖它）、`compat.libgbm`，以及 godot、chatgpt、xdesk、luban-os、qemu-system-gl 都依赖 `xim:graphics`（mesa + `nvidia-gl-host-link` + glvnd 的 `glx-vendor` 布线），Slint 没有。NVIDIA 的 X 服务器要求 GLX 厂商是 NVIDIA，glvnd 要加载 `libGLX_nvidia.so.0`，mcpp 的 registry 里没有它，GLX 就没有厂商，glutin 失败，Slint 的 femtovg 渲染器没有回退，`unwrap` abort。

| # | 证据（在 NVIDIA 580.178.04、X11 的真机上） |
|---|---|
| a | 探针 A（按 mcpp 构建的程序现在的方式运行）与 C（经 `mcpp run`）：`libGLX_nvidia.so.0`、`libEGL_nvidia.so.0` 找不到（不是“找到但缺依赖”）；**EGL on X11 由 Mesa 提供，50 个窗口配置**；**GLX：`client vendor: (null)`，`glXChooseFBConfig` 0 个配置** |
| b | `check-homes.sh`：`~/.mcpp/registry` 里**没有** `nvidia-gl-host-link`（`~/.xlings` 里有 0.1.3 和 0.1.4 两个版本，与 mcpp 无关） |
| c | C 的环境：`mcpp run` 把 `__EGL_VENDOR_LIBRARY_DIRS`、`LIBGL_DRIVERS_PATH`、`GBM_BACKENDS_PATH` 指向 registry 的 subos，所以**EGL 是封闭的**（总有 Mesa 兜底）；GLX 没有对应变量，厂商由 X 服务器决定 |
| d | Slint 的六种运行方式：默认与 `winit-femtovg` **abort**（`glutin: argument does not name a valid config`）；`winit-software` 正常；GLX 厂商强制为 mesa（单独，或与 EGL 一起）正常（软件渲染：`failed to load driver: nouveau`） |
| e | 对照实验 1：在项目里加 `[xlings.workspace] "xim:graphics" = "0.1.5"`：registry 里出现 `nvidia-gl-host-link` 0.1.4（驱动记账 580.178.04，25 个链接全有效），glvnd 的 `glx-vendor` 里有 `libGLX_nvidia.so.0`；六种运行方式**全部**窗口正常 |
| f | 对照实验 2：在项目的 `[dependencies]` 里加 `compat.glx-runtime = "2026.09.11"`（`compat.glfw` 的做法）：`mcpp run` 正常 |
| g | **静态证据：** 索引里共有 14 个能力名，其中只有 2 个没有任何包 `provides`：`display` 与 `opengl.egl.driver`，**都只由 `compat.slint` 声明**。其余 12 个都有提供者（`opengl.glx.driver`、`x11.display` ← `compat.glx-runtime` 等） |

g 说明这是一个**能被静态发现的描述符缺陷**：compat.slint 声明了没有人提供的能力，也没有依赖任何提供者。

## 2. 三个现象各自的状态

| # | 现象 | 状态 |
|---|---|---|
| E1 | `mcpp new --template mcpplibs.mwrap.slint@1.19.0` 报 `constraint '=1.19.0' matches none of: [1.19.0.3, …]` | **与本事无关**：命令行的 `@<版本>` 按前缀读是 mcpp 2026.11.21.1 起的行为（`docs/mwrap.md` 已写），该版本尚未发布；现在用 `@1.19.0.3` 或不写版本 |
| E2 | `Failed to load one of xlib's shared libraries` | **已修**（`xim:slint` revision 1 补了 X11、xcb、xkbcommon、wayland、glvnd 的依赖）。已装的 revision 0 载荷不会被自动刷新，且 compat.slint 里指向它的符号链接在删载荷后悬空；恢复路径：同时删 `~/.mcpp/xpkgs/compat-x-slint` 与对应的构建缓存，再 `mcpp run`（已在隔离环境验证） |
| E3 | `glutin: argument does not name a valid config`（本文的主体） | **根因已定位，修复未做**（§4） |

## 3. 被推翻的分析与教训

v1 的判断是：xim 的 `nvidia-gl-host-link` 在安装时按驱动版本快照了宿主驱动库的符号链接，宿主升级驱动后悬空；mcpp 的私有 registry 与全局 xlings 各存一份、互相漂移；方案是按驱动版本生成并共享状态。**这个判断对你的机器不成立。** 错在哪里：

1. **我把沙箱的状态当成了你机器的状态。** 我的会话把 `/home` 绑定到 `~/.xlings/subos/speak-agent-private/home`，我读到的 `~/.mcpp` 是那里的私有 registry：它确实有一份 0.1.3 且 22 条链接悬空。你的真实 `~/.mcpp/registry` 里根本没有这个包。教训：**关于用户机器状态的断言，必须来自用户运行的输出**；我看到的 `~` 不是用户的 `~`。
2. **我的探针有错误。** 探针向 GLX 要 stencil 位时用了 `0x1A`，应为 13（`0xD`）：NVIDIA 对未知属性返回空，Mesa 忽略，所以第一次运行里 B 的 GLX“0 个配置”是假象。已修正。
3. **把一个真实存在的相邻问题当成了原因。** 过期的 host-link 确实存在（`~/.xlings` 里的 0.1.3，以及 `chatgpt-e2e`、`verify-0930` 等 subos 里各 24 条悬空），但与这次崩溃无关（§7）。
4. **“为什么只有 Slint”曾被我误答成“其他程序也会走同一批过期链接”。** 实际是其他程序**声明了提供者**，Slint 没有。

## 4. 修复方案

| # | 决策 | 理由 |
|---|---|---|
| D1 | `compat.slint` 在 Linux 上**依赖 `compat.glx-runtime`**，写法同 `compat.glfw`（放在 `mcpp` 表的 `linux` 段的 `deps` 里） | 复用已有的、被 glfw 验证过的提供者约定（实验 f）；比直接依赖 `xim:graphics` 更符合现有约定，也不会让只用 `slint-compiler` 的使用者装上 35 个图形包 |
| D2 | `compat.slint` 的能力声明补上 `x11.display`、`opengl.glx.driver`（这是 `compat.glx-runtime` 提供的名字），`dlopen_libs` 补 `libGLX.so.0`；原有的 `display`、`opengl.egl.driver` **暂时保留** | Slint 在 X11 上实际走的是 GLX。保留原名是因为已发布且被打包逻辑读取（#867：声明宿主能力的程序不能用 `--mode self-contained`）；是否去掉要实测（U3） |
| D3 | **不改 `xim:slint`** | 它也被当纯工具用（`slint-compiler`），不应背上 GL 提供者；它的 revision 1 注释只描述窗口系统库，不动 |
| D4 | 新增 lint：**一个包声明的能力，必须有它的某个依赖 `provides` 它**（先作警告，扫描一遍现状后再定是否转为失败） | 静态证据 g：现在整个索引只有 compat.slint 的两个能力违反，零误报；这个缺陷类型以后能在 CI 里被发现，不需要等到用户的桌面上 |
| D5 | 验证以**真机检查**为准，CI 只覆盖能自动做的（§5） | GPU 与真窗口没法在 CI 里验证，不假装覆盖了 |
| D6 | 把探针目录整理成 slint-m 里的自检工具（`tools/check_display/`）并在文档里说明 | 这次排查里它几分钟就定位了问题，使用者遇到类似现象可以自己跑 |
| D7 | 已关闭的 mcpp issue 不再另开新的；留给 mcpp 维护者的两点只记在本文 §7 | 维护者的要求 |

**Wayland 上的 EGL 路径：** 索引里没有任何包提供 `opengl.egl.driver`（静态证据 g）。本方案不处理 Wayland，也没有验证；记为缺口 G1（§8）。

## 5. 以 Slint 为金丝雀的验证

| 项 | 内容 | 在哪里跑 | 修复前 | 期望（修复后） |
|---|---|---|---|---|
| V1 | 无头 hello（GLOBAL 与 CN 冷装，现有） | CI + 验收脚本 | 通过 | 不变 |
| V2 | **能力有提供者**的静态检查（D4） | CI，lint | compat.slint 的 2 个违反 | compat.slint 的 `x11.display`、`opengl.glx.driver` 不再被报；因 D2 保留的 `display`、`opengl.egl.driver` 仍是 2 条警告（G1）；另新发现 compat.sdl2（G2） |
| V3 | 候选索引构建：`tests/mwrap/slint-ui` 与冷装验收 | CI | 通过 | 通过（确认新依赖在三个平台上解析、构建；glx-runtime 只在 Linux） |
| V4 | 真机：**不加任何项目级的图形依赖**，`mcpp new` 后 `mcpp run` | 维护者的 NVIDIA 桌面 | abort | 窗口起来 |
| V5 | 真机：`slint-variants.sh` 六种运行方式 | 同上 | 默认与 `femtovg` abort | 全部起来 |
| V6 | 真机：探针 A/C：`libGLX_nvidia.so.0` 为 `loaded`，GLX 厂商为 NVIDIA 且配置数 > 0 | 同上 | `(null)`、0 | 通过，说明走的是 GPU |
| V7 | 软件 X 服务器上同样六种方式 | 我的沙箱（已有 `:99`）/ CI（需要 X 服务器包，U1） | 通过 | 通过（不回归） |
| V8 | 已装旧版 compat.slint 的机器在升级后是否按新依赖重新解析 | 维护者机器 | — | 不需要手动删缓存（U2） |

验收口径：V1–V3 进 CI；V4–V6 在维护者机器上跑，结果写进 PR；V7 若 CI 能提供 X 服务器就进 CI。

## 6. 实施计划与任务关系

| 任务 | 仓库 | 内容 | 前置 | 验收 |
|---|---|---|---|---|
| **T0** | mcpp-index | 本文评审，决定 §9 | — | 确认 |
| **T1** | mcpp-index | `pkgs/c/compat.slint.lua`：`mcpp.linux` 段加 `deps = { ["compat.glx-runtime"] = "2026.09.11" }`；能力与 `dlopen_libs` 按 D2；更正该文件里“xim:slint declares the packages…”的注释；CHANGELOG | T0 | V2、V3 通过；V4–V6 在真机通过；老版本的已发布行不变 |
| **T2** | mcpp-index | `tests/check_capability_providers.lua`（D4）及正反例测试，接入 `validate.yml` 的 lint；先作警告 | T0 | 对现状报 compat.slint 的两项；T1 合入后 compat.slint 只剩按 D2 保留的两项（`display`、`opengl.egl.driver`），不会归零；反例被报告 |
| **T3** | slint-m | `docs/usage.md`、README 中英文：真窗口的前提、GL 提供者由 compat.slint 带入、NVIDIA 与 `SLINT_BACKEND` 开关；`tools/check_display/`（探针与三个脚本，D6） | T1 | 文档合入；脚本在真机上能跑 |
| **T4** | 真机 | V4、V5、V6、V8 的结果贴在 T1、T3 的 PR 里 | T1 | §5 的真机项全绿 |

```
T0 评审
 ├─► T1 mcpp-index: compat.slint 依赖与能力 ──► T3 slint-m: 文档 + check_display ──► T4 真机验证
 └─► T2 mcpp-index: 能力提供者 lint（警告）  （与 T1 互不依赖；T1 合入后 compat.slint 的 GLX 一项消失，D2 保留的两项仍报警告）
```

- 每个仓库尽量单 PR，CI 通过后 squash 合入；T1 不需要发 slint-m 的新版本（compat.slint 是索引里的描述符，不在 slint-m 的归档里）。
- 不需要改 `xim-pkgindex`、`xlings`、`mcpp`。

## 7. 独立且不阻塞的事项

**7.1 过期的 `nvidia-gl-host-link`（与这次崩溃无关，但真实存在）。** 现状：`~/.xlings` 里 0.1.3（550.144.03，23 个链接，24 个悬空）与 0.1.4（580.178.04，正常）并存；`chatgpt-e2e`、`verify-0930` 等 subos 里各有 24 条悬空链接。这是 xlings 图形栈设计文档里记录的已知失效模式（驱动升级后链接悬空）。v1 设计过一套按驱动版本生成、稳定的 `current` 入口、使用点检查的机制，并且已验证“按当前驱动版本 glob 宿主库生成目录”这一核心做法在你机器上可行（探针 B 第 3 部分：NVIDIA 的 EGL 配置 64 个）。**不在本方案内做**；如果 xim-pkgindex / xlings 的维护者想做，v1 的设计思路可作参考，由他们决定。

**7.2 留给 mcpp 维护者的两点（已不再作为 issue，仅记录）。**
1. **没有提供者的能力在解析期和运行期都没有任何提示。** 这次的缺陷本可以在两处被发现：声明的能力在依赖图里没有提供者；或者在目标自己的加载器下验证声明的 `runtime.dlopen_libs` 是否能解析（我的探针就是这么做的）。
2. **同版本号下 xim 载荷的 revision 变化不会被刷新，依赖它的 compat 包在载荷被删后留下悬空链接**（E2）。

## 8. 风险与未验证项

| # | 项 | 状态 / 处理 |
|---|---|---|
| U1 | CI 里是否有可用的 X 服务器包（Xvfb 或同类）；我的沙箱里有一个软件 X 服务器 `:99`，来源没有查 | T3 前确认；没有则 V7 只在本机跑 |
| U2 | compat.slint 的**描述符**改了依赖后，已经装过 compat.slint 的机器是否会按新依赖重新解析（`mcpp` 表的改动不在版本行里，审计不要求 revision，但缓存是否跟随没有实测） | V8；若不跟随，评估是否给 1.19.0 行加 `revision` |
| U3 | 去掉 `display`、`opengl.egl.driver` 是否影响打包逻辑（#867 的行为） | 先保留；用 `check_installed_template.py --deploy` 验证后再决定 |
| U4 | glutin 在 X11 上 GLX 优先、EGL 兜底的顺序，是我凭记忆说的，没有对照源码 | 不影响修复（实验 e、f 已证明依赖到位后可行） |
| U5 | 加了 `compat.glx-runtime` 后，渲染是否走 GPU：窗口起来了，但 `GL_RENDERER` 没有打印 | V6 |
| U6 | `compat.glx-runtime` 只在 Linux 上存在；macOS、Windows 的 compat.slint 路径不受影响，应在候选 CI 里确认 | V3 |
| U7 | 本文假设维护者的 NVIDIA 桌面是 X11 会话（`XDG_SESSION_TYPE=x11`）；Wayland 会话没有测 | G1 |

**G1（缺口）：** 索引里没有任何包提供 `opengl.egl.driver`（也没有 `display`）；Slint 在 Wayland 上的 GL 路径没有提供者，也没有验证。D2 保留这两个名字，因此 lint 对 compat.slint 仍有 2 条警告，这是已知并接受的。

**G2（新发现）：** lint 首次运行就报出 `compat.sdl2` 声明了 `x11.display` 却不依赖任何提供者（`compat.glx-runtime` 提供）。形态与 compat.slint 相同，但没有在真机上复现过，本次**不改** compat.sdl2；需要在 NVIDIA 桌面上用 SDL2 程序确认后另行处理。

## 9. 决定与执行记录

**已决定：** Q1 依赖 `compat.glx-runtime`（与 compat.glfw 一致）；Q2 保留 `display`、`opengl.egl.driver`；Q3 lint 先作警告；Q4 探针进 slint-m `tools/check_display/`；Q5 向 xlings 提一个 issue 说明过期 host-link 的隐患（§7.1），不在本方案内修。

**执行（mcpp-index 单 PR）：**
- `pkgs/c/compat.slint.lua`：`linux.deps` 加 `compat.glx-runtime`；`dlopen_libs` 加 `libGLX.so.0`；`capabilities` 加 `x11.display`、`opengl.glx.driver`；头部与 linux 注释更正（libglvnd 只是分发器，厂商库来自 glx-runtime）。
- `tests/check_capability_providers.lua` + `tests/test_check_capability_providers.py`（8 个用例）；`validate.yml` 的 lint 前加一步，警告模式；`--strict` 可转失败。
- 本地验证（候选索引）：`tests/mwrap/slint-ui`、`tests/mwrap/slint-rule` 通过；冷装模板验收通过（含打包、relocated bundle）。
- 真机项 V4–V6、V8 由维护者在 NVIDIA 桌面上跑，结果记在 PR 里；U2（旧机器是否按新依赖重新解析）、U3（去掉能力名对打包的影响）依然未验证。
