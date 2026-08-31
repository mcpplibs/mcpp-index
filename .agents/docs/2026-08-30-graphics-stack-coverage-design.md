# mcpp 图形栈:从「能跑通」到「能开发」的覆盖面设计

Date: 2026-08-30 · 前置:[`2026-08-30-gbm-cross-repo-closed-loop-plan.md`](2026-08-30-gbm-cross-repo-closed-loop-plan.md) §19/§20 · **状态:已实现并闭环验证(v1.8,§11 总账 / §14 fork 规范 / §18 八角度复核 / §19 合成器闸门与 GObject 栈,含沙箱实测 · §20 gio 与一次被推翻的判断 · §21 namespace 是契约:四个成员补上 import)**

## 0. 这份文档解决什么

前一份文档证明了 GBM/DRM/EGL/Wayland-协议 这条栈**能跑通**(沙箱干净房间,宿主库在场
可达却全部落败)。但 §20 的盘点显示,「跑通」离「能写一个合成器」还差两条链:

- **渲染链**:EGL 能初始化,但拿到 context 之后**没有 GL 可调**
- **输入链**:整条缺

以及 Vulkan 那一处宿主依赖。这份文档把每一条**调研到能直接动手的程度**,而不是列愿望。

**判据不重新论证**:可独立分发 → 源码构建;目标相关的决定进 `build.mcpp`,能预先算定的
生成物签进仓 + CI diff;模块名跟接口所有者。三条都在前一份文档里立过并验证过。

### 0.1 形态判据(本轮补齐的第四条)

前三条决定「怎么建」,这一条决定「放哪、叫什么」:

> **上游源码能直接用的 → `compat.*` 内联描述符;
> 需要 fork 才能建的 → mcpp 原生模块化(Form A + 模块层),namespace 用上游组织名。**

| | 触发条件 | 形态 | 本轮的例子 |
|---|---|---|---|
| **A. `compat.*` 内联** | 上游 tarball 直接就能编:源码列得出来、没有必须先编译才能跑的生成器、没有 workspace | 描述符一个文件,`mcpp = { ... }` | `pixman`、`libxkbcommon`、`libevdev`、`mtdev` |
| **B. fork + 原生模块化** | 需要 `build.mcpp`、需要 workspace 多成员、或有必须先编译出来才能跑的生成器 | Form A fork,`mcpp = "*/mcpp/<member>/mcpp.toml"`,带模块层 | GL 家族(libglvnd fork)、wayland-protocols(wayland fork) |

判 A 还是 B 的**操作性问题**:「把上游 tarball 解开,能不能只靠一份 `mcpp.toml` 把它编出来?」
能就是 A,不能就是 B。B 的成本主要在维护一个 fork,所以**不要因为「顺便加个模块层」而
把 A 推成 B** —— 模块层是 B 的**结果**,不是选 B 的理由。

按这条,本设计里 G1/G3 是 B,G4 全是 A。
⚠ 设计时以为「都进已有的 fork,新增仓 0」——**实现推翻了这一半**:wayland-protocols、
libevdev、libxkbcommon 各是独立上游、独立版本,一个仓一个上游一个版本,所以新增了三个
fork。见 §10.2。

---

## 1. 调研结论速览

| # | 目标 | 调研结论 | 规模 |
|---|---|---|---|
| **G1** | GL 家族(GLESv2 等) | ✅ **形态完全确定**,四张生成表已实跑通过 | 中,收益最大 |
| **G2** | Vulkan 走生态驱动 | ⚠️ **原假设两次被推翻**,最终是「既有机制的 Vulkan 那一半没接」 | 一处调用,在 xim-pkgindex |
| **G3** | wayland-protocols | ✅ 形态确定,可全量预生成 | 小 |
| **G4** | libxkbcommon / pixman | 独立项目,内联描述符 | 中 |
| **G5** | libinput | 拖 libevdev/mtdev/libudev | 中偏大 |
| **G6** | libudev / libseat | systemd 邻域,最难 | 大 |

---

## 2. G1 — libglvnd 的 GL 家族

### 2.1 五个库的精确构成(读 meson 得到,非推测)

`src/GLdispatch/vnd-glapi/meson.build` 有一个 `foreach`,为四种 API 风味各建一个静态库:

```meson
foreach g : ['gl', 'opengl', 'glesv1', 'glesv2']
  _lib = static_library(
    'glapi_' + g,
    ['stub.c', _entry_files, header],          # header = g_glapi_mapi_<g>_tmp.h
    c_args : ['-DSTATIC_DISPATCH_ONLY',
              '-DMAPI_ABI_HEADER="…"'],
  )
endforeach
```

然后各个共享库:

| 库 | soname | 构成 | X11? |
|---|---|---|---|
| `libGLESv2` | `libGLESv2.so.2` | `libopengl.c` + `idep_glapi_glesv2` + gldispatch | **否** |
| `libGLESv1` | `libGLESv1_CM.so.1` | `libopengl.c` + `idep_glapi_glesv1` + gldispatch | **否** |
| `libOpenGL` | `libOpenGL.so.0` | `libopengl.c` + `idep_glapi_opengl` + gldispatch | **否** |
| `libGLX` | `libGLX.so.0` | `libglx.c` `libglxmapping.c` `libglxproto.c` `glvnd_genentry.c` + 生成的 stub list | **是**(`dep_x11` `dep_xext` `dep_glproto`) |
| `libGL` | `libGL.so.1` | `libgl.c` + `idep_glapi_gl` + **`dep_glx`** | **是**(经 libGLX) |

**这个分层是本节最有用的发现**:三个无 X11 的库覆盖了合成器的全部需要;`libGLX`/`libGL`
只有 X11 应用需要,而索引里 `compat.x11` / `compat.xext` / `compat.xorgproto` 已经齐备。
**所以 G1 可以只做前三个**,规模立刻小一半,而且不引入 X11 依赖。

### 2.2 四张生成表 —— 已实跑验证

命令从 `src/generate/meson.build` 逐字转写,2026-08-30 实跑:

```bash
cd upstream/src/generate
python3 gen_gldispatch_mapi.py opengl xml/gl.xml xml/gl_other.xml > g_glapi_mapi_opengl_tmp.h   # 30197 行 ✓
python3 gen_gldispatch_mapi.py glesv1 xml/gl.xml xml/gl_other.xml > g_glapi_mapi_glesv1_tmp.h   # 11292 行 ✓
python3 gen_gldispatch_mapi.py glesv2 xml/gl.xml xml/gl_other.xml > g_glapi_mapi_glesv2_tmp.h   # 15788 行 ✓
# libGL 特殊:符号表从文件读,不从 XML 生成
python3 gen_gldispatch_mapi.py ../GL/gl.symbols xml/gl.xml xml/gl_other.xml \
                                                            > g_glapi_mapi_gl_tmp.h            # 78373 行 ✓
```

四条全部成功。**都签进 `mcpp/generated/`**,与已有的 `glapi_mapi_tmp.h` 并列,CI 的
`generated` job 加四行 diff 即可 —— 构建期依然不跑 Python。

### 2.3 为什么必须是独立成员,而不是给 gldispatch 加 target

`stub.c` 和那组 per-arch entry 文件**被编译两次,用不同的宏**:

| | 宏 |
|---|---|
| `libglapi`(在 gldispatch 里) | `-DMAPI_ABI_HEADER="glapi_mapi_tmp.h"` |
| `glapi_<g>`(每个 GL 库) | `-DSTATIC_DISPATCH_ONLY -DMAPI_ABI_HEADER="g_glapi_mapi_<g>_tmp.h"` |

mcpp 把一个包的源码**编一次**、让每个库 target 链接全部对象。同一个 `.c` 需要两套宏,
一个包做不到 —— 这与 `freedesktop.wayland` 拆四个成员是同一条约束,mcpp 自己的告警
也点了这个办法(「split into a workspace member」)。

**结论**:`mcpp/glesv2`、`mcpp/glesv1`、`mcpp/opengl` 各是一个成员,各自 path 依赖
`mcpp/gldispatch`,与 `mcpp/egl` 平级。

### 2.4 源码构建 vs 绑定 payload —— 为什么仍然是源码

`xim:libglvnd` 的 payload **确实带** `libGLESv2.so.2`(实测,连 libGL/libGLX/libOpenGL
都有)。所以这里存在真实的选择,不是只有一条路。

判据本身已经给出答案(libglvnd 可独立分发 → 源码)。但还有一条**具体**理由:

```
payload libGLESv2.so.2  →  DT_NEEDED: libGLdispatch.so.0     (实测)
```

如果绑 payload 的 GLESv2、同时用我们源码构建的 `freedesktop.egl`,那么 payload 的
GLESv2(glvnd **1.7.0.1**)会因为 soname 复用去用我们建的 GLdispatch(glvnd **1.7.0**)。
这**能跑**(soname 复用已实测),但它是一处跨构建耦合,靠
`__glDispatchGetABIVersion` 在运行期兜底。源码构建让整个 dispatch 家族**同一份构建、
同一个版本**,这个耦合根本不存在。

### 2.5 模块层

按已立的规则,模块名跟接口所有者 —— GLES 与 OpenGL 都是 **Khronos** 的规范:

```
import khronos.glesv2;      // 与 khronos.egl 并列
import khronos.glesv1;
import khronos.opengl;
```

⚠ **一个必须先验证的风险**:GL 的入口点是否都是外部链接。`khronos.egl` 不需要
forwarder 是因为 EGL 入口是 `EGLAPI … EGLAPIENTRY`;GL 的头(`GLES2/gl2.h`)用的是
`GL_APICALL … GL_APIENTRY`,展开后是否同样是外部链接**需要先验一次**,否则会重演
wayland 那次 clang 报 `using declaration referring to … with internal linkage cannot be
exported`。**建议:先只做 C 库三个成员,模块层作为独立一步。**

---

## 3. G2 — Vulkan:调研推翻了原来的判断

### 3.1 原假设

§20 写的是「`compat.vulkan-runtime` 把宿主 `/usr/lib` 的 ICD 做成符号链接农场,是最后
一处 host 边;照 §17.2 走 `xim:mesa` 的 ICD 声明就能拆掉」。

### 3.2 实测(沙箱,**不装** vulkan-runtime,只用 `compat.vulkan` 源码构建 loader)

```
vkCreateInstance      = 0 (ok)
physical devices      = 1
  - llvmpipe (LLVM 20.1.2, 256 bits)

[Vulkan Loader] ERROR: libXext.so.6: cannot open shared object file
[Vulkan Loader] ERROR | DRIVER: loader_icd_scan: Failed loading library associated with
                        ICD JSON libGLX_nvidia.so.0. Ignoring this JSON
```

`XDG_DATA_DIRS` 的实际内容:

```
<subos>/share/vulkan/icd.d/radeon_icd.x86_64.json      ← 生态的(xim:mesa)
/usr/share/vulkan/icd.d/{asahi,intel,lvp,nouveau,nvidia,radeon,…}_icd.json   ← 宿主的
```

### 3.3 根因:机制早就在,只是 Vulkan 这一半没接

生态里**已经有一套完整的「共享 vendor 目录」设计**,而且已经在 EGL 上跑通了。不需要
新机制,需要的是把 Vulkan 接进同一套。

`libs/graphics.lua` 与 `nvidia-gl-host-link.lua` 里的既有形态:

```
share/glvnd/egl_vendor.d/          ← 共享目录,谁都可以往里放
    10_nvidia.json                 ← nvidia-gl-host-link 写的(sentinel)
    50_mesa.json                   ← mesa 写的
```

优先级**由文件名前缀决定**,和每个发行版的约定一样。`graphics.lua` 的注释写得很清楚:
之前 mesa 和 nvidia 各自贡献**自己的**目录时,跨 vendor 优先级取决于 xlings 恰好把谁排
在前面——「correct by alphabetical accident」。改成共享目录之后才有了确定的语义。

而 `nvidia-gl-host-link` 写 JSON 时用的是**绝对路径**,注释说明了为什么:

> a bare name here is a way for the host's stack to get back in through the door we closed

**Vulkan 侧缺的正是这一半。** 该 sentinel:

- ✅ 已经把 `libGLX_nvidia.so.0` 软链进自己的 `lib/`,注释还写着
  「GLX vendor **AND Vulkan ICD**: same file」
- ✅ 已经供给 `libX11`/`libXext`/glibc/libglvnd(实测失败的正是 `libXext.so.6`)
- ✅ 已经有写 ICD JSON 的现成代码路径
- ❌ **只调了 `graphics.declare_egl_vendor(...)`,没有调 `declare_vulkan_icd(...)`**

于是 loader 找不到生态里的 NVIDIA ICD,退回去扫 `/usr/share`,读到宿主那份**裸 soname**
的 `nvidia_icd.json`,dlopen 时缺 `libXext.so.6` 而失败,再往下落到宿主的
`lvp_icd.json`(llvmpipe 依赖少,能加载)——**于是静默变成软件渲染**。

### 3.4 结论:一处改动,形态与 EGL 完全对称

| | 做什么 | 在哪个仓 |
|---|---|---|
| **V1** | `nvidia-gl-host-link` 增调 `graphics.declare_vulkan_icd(...)`,把 `10_nvidia.json`(绝对 `library_path`,指向它自己软链的 `libGLX_nvidia.so.0`)写进共享的 `share/vulkan/icd.d` | xim-pkgindex |
| **V2** | `compat.vulkan-runtime` 描述符改写:说明它是**专有驱动的最小 host 面**,不是默认路径;生态驱动走 V1 | mcpp-index |

#### V1 已实测验证(2026-08-30,`default` subos,`--sandbox --gpu`)

提案在写任何代码之前先验过。非破坏性做法:不动 subos 的共享目录,用 `VK_DRIVER_FILES`
指一份**等效**的 JSON —— `library_path` 写成 sentinel 那个软链的**绝对路径**:

```
===== A. 现状(生态 + 宿主 /usr/share 混在一起)=====
  devices = 1
    - llvmpipe (LLVM 20.1.2, 256 bits)          ← 软件渲染

===== B. V1 假设:NVIDIA ICD 用【绝对路径】声明 =====
  library_path = <subos>/lib/libGLX_nvidia.so.0
  devices = 1
    - NVIDIA GeForce RTX 4080                    ← 真 GPU
```

**差别只有「那份 JSON 在不在、路径是不是绝对的」。** sentinel 供给的
`libX11`/`libXext` 让 NVIDIA 的驱动这次加载成功了,而现状下 loader 读的是宿主那份裸
soname 的 JSON、缺 `libXext.so.6` 而放弃。所以 V1 不是推理,是已验证的结论。

**顺带发现的第二处、更小的泄漏**:`libVkLayer_MESA_device_select.so`(宿主的 Vulkan
**layer**,不是驱动)同样从 `/usr/share` 被扫到并加载失败。它不影响结果(layer 缺失
只是少一层),但说明 `XDG_DATA_DIRS` 里的 `/usr/share` 会同时把 layer 带进来。
**layer 的清理是独立的一小步,不阻塞 V1。**

V1 之后共享目录里是 `10_nvidia.json`(sentinel)+ `50_mesa.json`(mesa),而 subos 的
`share` 在 `XDG_DATA_DIRS` **最前面**(实测确认),所以生态的 ICD 先被扫到、`10_` 前缀
让 NVIDIA 优先——**与 EGL 那一半逐字对称**。宿主的 `/usr/share` 仍在列表后面,但已经
轮不到它。

~~原提案 `VK_DRIVER_FILES`~~ **作废**:那是在既有机制之外另起一套。既有的共享目录 +
文件名优先级已经解决了同一个问题,而且已经过 EGL 验证。

### 3.5 最小 Host 面:这是设计,不是妥协

**不开源的驱动/运行时层**(NVIDIA 专有 GL/EGL/Vulkan、CUDA)不可能进生态 payload。
生态对此的既有答案是 **sentinel + 共享目录**:

```
nvidia-gl-host-link      Sentinel: stable symlinks to the host's NVIDIA proprietary GL/EGL userspace
libcuda-host-link        同上,CUDA
wsl-gl-host-link         同上,WSL
```

sentinel 的性质值得点明:它**只做符号链接与一份 JSON**,把宿主面收敛到
「几个具名文件 + 一个 vendor 声明」,而不是让每个消费者各自去 `/usr/lib` 捞。
`install()` 在没有 NVIDIA 的机器上**成功且什么都不链** —— 注释原话:
「"no NVIDIA on this machine" is a normal state, not a failure」。

**所以设计原则是:host 面保留,但收敛到 sentinel,并且只对不开源的那一层。**
V2 要做的就是把 `compat.vulkan-runtime` 归到这一类里说清楚,而不是删掉它。

---

## 4. G3–G6 — 合成器其余依赖

### 4.1 wayland-protocols 1.49

**纯 XML,没有代码。** 消费者需要对 `xdg-shell.xml` 等跑 `wayland-scanner` 生成
`.h`/`.c`。索引已经有 `freedesktop.wayland-scanner`。

两种形态,判据已经给出答案:

| | 做法 | 判据 |
|---|---|---|
| ❌ 消费者构建期生成 | 包只发 XML,消费者用 `build.mcpp` + `dep_bin(...)` 调 scanner | 输出**与目标平台无关** → 不该放构建期 |
| ✅ **全量预生成** | fork 里对每个协议跑 scanner,产物签进仓,CI diff | 与 `freedesktop.wayland` 的协议代码同一形态 |

**建议**:作为 `mcpplibs/wayland` 的**第五个成员**(`mcpp/protocols`),而不是新建仓 ——
scanner 就在同一个 workspace 里,`mcpp/generated/` 机制现成。索引条目
`freedesktop.wayland-protocols = "1.49"`。

⚠ 需要实测的一点:全量生成后的体积。约 40 个协议,预计 3–5 万行,可接受但要量过再定。

### 4.2 libxkbcommon 1.13.2 / pixman 0.46.4

两个都是独立项目,**内联描述符即可**(与 `compat.libdrm` 同形)。

- **libxkbcommon**:上游活跃仓在 GitHub(`xkbcommon/libxkbcommon`),freedesktop 那个
  停在 0.3.0 —— 别取错。运行期需要 `xkeyboard-config` 的数据文件,这是**第二个包**,
  且是纯数据。
- **pixman**:有 per-arch SIMD(SSE2/AVX2/NEON/…),各自独立 TU 且**带 `#ifdef` 自门控**
  (与 libffi 同形),所以**不需要 `build.mcpp`** —— 全列进 `sources` 让它们自己关掉即可。
  这一点与 GLdispatch 的 entry stub 正相反,是判据的一个好对照。

### 4.3 libinput 1.31.3

拖 `libevdev` 1.13.7、`mtdev`、以及 **`libudev`**。前两个是普通独立项目;`libudev` 是难点,
见下。

### 4.4 libudev / libseat — 真正的难点

- **libudev** 是 systemd 的一部分。可选替代:`eudev`(独立 fork,已停更)或
  `libudev-zero`(极简重实现)。**需要单独决策,不要顺手做。**
- **libseat**:`seatd` 0.9.3 提供,支持无 logind 的 `seatd` 后端 —— 合成器可以只用
  seatd 后端,绕开 systemd。

**建议**:这一层**先不做**。合成器可以在「已有 DRM master」的前提下开发(如从 TTY 直接
启动、或 `SEATD_SOCK`),把 session 管理留到最后。

---

## 5. 任务依赖图与排序

```
G1a  glesv2/glesv1/opengl 三个成员(C 库)      ← 无前置,规模最小,解锁渲染链
 │
 ├─ G1b  khronos.glesv2 等模块层               ← 依赖 G1a;先验外部链接风险
 │
G2a  nvidia-gl-host-link 增调 declare_vulkan_icd  ← 无前置,与 G1 并行(xim-pkgindex)
 │
 └─ G2b  compat.vulkan-runtime 归类为「专有驱动的最小 host 面」 ← 依赖 G2a
                                                    
G3   wayland-protocols(wayland fork 第五成员)  ← 无前置,与 G1/G2 并行
G4a  libxkbcommon + xkeyboard-config           ← 无前置
G4b  pixman                                    ← 无前置
 │
G5   libinput(+ libevdev + mtdev)             ← 依赖 G6 的 libudev 决策
 │
G6   libudev 路线决策 → libseat                ← 最后,单独评估
```

**可并行的三条**:G1a / G2a / G3。它们互不依赖,而且各自独立可验证。

**排序建议**:`G1a → G3 → G2a → G4 → G1b → G2b → G5 → G6`

理由:G1a 是从「能初始化」到「能画」的分水岭;G3 之后才谈得上实现一个 shell;G2a 一处调用
改动换掉一处静默降级;模块层(G1b)放在 C 库稳定之后,免得两个风险叠在一起。

---

## 6. 多角度评估

> ⚠ **这张表是设计时写的,八条里有四条已被实现推翻或需要重述。**
> 每行末尾的标记给出结论,逐条的证据在 **§18**。不要单独引用本节。

| 角度 | 评估(设计时) | |
|---|---|---|
| **架构** | G1 不新建仓,复用 mcpplibs/libglvnd 已有的 `mcpp/generated/` 与 path 依赖机制;G3 复用 mcpplibs/wayland 的 scanner。**新增仓数量 = 0** | ❌ 实际五个仓,§18.1 |
| **稳定性** | 四张生成表已实跑;CI 的 diff 守卫扩四行即可。风险集中在 G1b(模块导出)与 G3(体积),两者都可先验 | ⚠ 真正的风险不在此,§18.2 |
| **优雅/简洁** | 只做三个无 X11 的 GL 库,不碰 GLX/GL —— 覆盖合成器的全部需要,且不把 X11 拖进任何消费者 | ✅ 且被 feature 加强,§18.3 |
| **用户体验** | 合成器作者的 `mcpp.toml` 从「缺渲染链」变成可写;`import khronos.glesv2;` 与既有命名一致 | ✅ 且多一层,§18.4 |
| **兼容性** | 全部是新增条目,不动任何已发布包。唯一的行为变更是 G2a,而它修的是「静默落到软件渲染」 | ❌ 动了三个,§18.5 |
| **跨平台** | GL 家族的 per-arch entry stub 沿用 `build.mcpp` 里已有的 `target_arch()` 选择,aarch64/ppc64 由构造成立;pixman 的 SIMD 自门控,不需要额外机制 | ⚠ 咬人的是编译器不是架构,§18.6 |
| **一致性** | 模块命名(khronos.*)、生成物签进仓、path 依赖三条规则原样复用,不引入新范式 | ⚠ 第二条已推翻,§18.7 |
| **无感升级** | 全是新增包,无同版本重切 tag 的问题(那正是上一轮的教训) | ⚠ 换三种形态出现,§18.8 |

---

## 7. 验证矩阵

| # | 断言 | 怎么验 |
|---|---|---|
| V1 | 三个 GL 库 soname 正确且**非空** | CI:`readelf -d` + 符号断言 + obj 计数(沿用 libglvnd 现有检查) |
| V2 | GLESv2 与 EGL 用**同一个** GLdispatch | 测试里 `dladdr(&glClear)` 与 `dladdr(&eglInitialize)` 的 GLdispatch 路径一致 |
| V3 | **拿到 context 之后真能画** | 沙箱 `--gpu`:GBM→EGL→`eglMakeCurrent`→`glClear`+`glReadPixels` 读回像素值 |
| V4 | Vulkan 落到**真实** GPU 而非 llvmpipe | ✅ **已验证**(见 §3.4):`deviceName` 从 `llvmpipe` 变成 `NVIDIA GeForce RTX 4080`。做成 V1 之后应固化为沙箱回归 |
| V5 | 宿主一条都没赢 | 沿用 `tests/verify_graphics_closed_loop_sandbox.sh`,扩到 GL/Vulkan |
| V6 | 生成表无漂移 | CI `generated` job 扩四行 diff |

**V3 是这一轮的核心验证** —— 它是「能画」的定义。`glReadPixels` 读回一个已知颜色,
比任何符号存在性检查都硬。

---

## 8. 明确不做的事

- **libGLX / libGL**:合成器不需要,而且会把 X11 拖进依赖图。X11 应用要用时再做,
  索引里 `compat.x11`/`compat.xext`/`compat.xorgproto` 已经齐备。
- **HGL**(Haiku 的 libGL):平台不相关。
- **把 NVIDIA 专有驱动纳入生态**:不可能,也不该假装。
- **libudev 的重实现**:超出图形栈范围,单独评估。

---

## 9. 一句话

> **G1a 三个成员是分水岭 —— 做完它,mcpp 从「EGL 能初始化」变成「能画」;
> 其余都是补齐,唯一的架构性问题是 Vulkan 的 `XDG_DATA_DIRS` 目录合并,
> 而那一行改在 xim-pkgindex,不在这里。**

---

## 10. 实现结果与对本设计的更正(2026-08-30 执行记录)

设计写完就动手了。这一节记录**做出来的东西**,以及**设计里被实现推翻的部分** ——
后者更重要,因为每一条都是被实测否掉的。

### 10.1 交付

| # | 交付 | 状态 |
|---|---|---|
| G1a | mcpplibs/libglvnd 加 `mcpp/{glesv2,glesv1,opengl}` 三个成员 | `v1.7.0`,CI 全绿 |
| G1b | `khronos.{glesv2,glesv1,opengl}` 模块层 | 同上,与 C 库一起做完 |
| G2 | xim-pkgindex `nvidia-gl-host-link` 0.1.3 声明 Vulkan ICD | PR #731,已实测 |
| G3 | **mcpplibs/wayland-protocols**(新建)三个 tier | `1.49`,CI 待绿 |
| G4a | `compat.pixman` 0.46.4 | 已实测 |
| 索引 | `freedesktop.{glesv2,glesv1,opengl}`、三个 `wayland-protocols-*`、`compat.pixman` | PR #294 |
| G4b | **mcpplibs/libxkbcommon**(新建)bison parser 预生成 | `1.13.2`,CI 全绿 |
| G5 | `compat.mtdev`、`compat.libudev`(libudev-zero)、**mcpplibs/libevdev**(新建)、`compat.libinput` | 全部实测 |
| G6 | `compat.libseat`,只开 seatd + builtin,**没碰 systemd** | 实测 |
| 镜像 | libglvnd / wayland-protocols / pixman / mtdev / libudev-zero / seatd / libevdev / libxkbcommon / libinput 九份 CN,均已核对 sha256 | 完成 |

### 10.2 被推翻的:「新增仓 0」——实际新增了三个

设计 §6 写着「新增仓数量 = 0 —— G1 复用 libglvnd,G3 做 wayland fork 的第五个成员」。
**G3 那半是错的,而且做到输入链之后错得更多。**

`mcpplibs/wayland` 的 `upstream/` 是 wayland **1.26.0** 且 CI 逐字节 diff;
wayland-protocols 是**另一个上游项目、另一个版本(1.49)**。一个仓一个上游一个版本,
所以它必须是独立 fork。

同一条规则在输入链上又触发了两次:`libevdev` 的 `event-names.h` 和 `libxkbcommon` 的
bison parser 各自是必须先跑的生成器,而两者都是独立上游、独立版本。

**新增仓数量 = 3**:`mcpplibs/wayland-protocols`、`mcpplibs/libevdev`、
`mcpplibs/libxkbcommon`。判据本身没错 —— 错的是「已有的 fork 装得下」这个假设,而它
装不下的原因很具体:**一个仓一个上游一个版本**,因为 CI 要对着一份 release tarball
逐字节 diff `upstream/`。

### 10.3 被推翻的:G3 的「一个包装全部 65 个协议」

设计说「全量预生成」,只提了体积。**体积不是问题,链接才是。**

```
multiple definition of `zwp_linux_dmabuf_v1_interface'
```

staging/ 与 unstable/ 携带**同一个协议的不同成熟度**,scanner 为两者生成**同名符号**。
按导出的 `wl_interface` 数清点:

| | |
|---|---|
| stable ∩ staging | **0** |
| stable ∩ unstable | **13** |
| staging ∩ unstable | **0** |
| 任一 tier 内部 | **0** |

所以是**三个包,按 tier 分** —— 而这个边界是上游自己的目录结构,不是发明出来的。

由此还带出两条只有动手才会发现的事:

1. **三个 unstable 协议不能发**:`xdg-shell-unstable-v5`、`linux-dmabuf-unstable-v1`、
   `tablet-unstable-v2` —— 它们**就是**那 13 个重叠符号,而且各自都已被同名 stable 协议
   取代。上游留着只为兼容,一个包不可能两个都发。
2. **staging/unstable 依赖 stable**,实测:两者都引用 `xdg_toplevel_interface`,staging
   还引用 `zwp_tablet_tool_v2_interface`。fork 内用 path 依赖,于是**消费者不能同时写
   staging 和 stable** —— mcpp 报「既是 version dep 又是 path dep」。规则:要 staging
   就只写 staging。

体积那一问也量了,而且答案与担心相反:65 个协议的 `.c` 一共 **5910 行,编出 270KB**;
3.5MB 几乎全是**头文件**,不 include 就不花钱。

### 10.4 被推翻两次的:G2 的形态

设计 §3 已经把 `VK_DRIVER_FILES` 标成「作废,应当接既有的共享目录机制」。**接完发现两者
是互补的,不是二选一** —— 但第二个仍然**现在不能做**。

实测三段:

```
A  改动前                     devices = 1  →  llvmpipe (LLVM 20.1.2)
B  sentinel 声明 Vulkan ICD   devices = 3  →  NVIDIA RTX 4080 ×2 + llvmpipe
C  再加 VK_DRIVER_FILES       devices = 1  →  NVIDIA RTX 4080
```

B 是本轮做的:GPU 到位了。但 NVIDIA **出现两次** —— sentinel 补上 `libXext` 之后,
宿主 `/usr/share` 里那份裸 soname 的 ICD 也能加载了。C 能消掉重复(而且
`VK_DRIVER_FILES` **接受目录**,一行 DISCOVERY 就够)。

**C 现在不能做**:`xim:mesa` 的 payload 只带 `radeon_icd.x86_64.json` 一个 ICD。声明
`VK_DRIVER_FILES` 会让生态集合成为唯一权威,而在 Intel 机器上那个集合是空的 —— 等于拿
「NVIDIA 重复枚举」换「Intel 上完全没有 Vulkan」。前置条件是 mesa 把它构建的 ICD 都发
出来(anv / lvp / nouveau),那是 payload 的问题。

### 10.5 被修正的:G4 pixman「SIMD 自带门控」

设计说 pixman 的 SIMD「自带 `#ifdef` 门控,不需要 build.mcpp」。**分类(A 类内联)对了,
理由错了。**

文件确实自带门控,但**编译标志是逐文件的**:上游每个指令集建一个静态库,各自带
`-msse2` / `-mssse3`。包级 cflags 表达不了 —— `-mssse3` 加到所有文件上,编译器就可能在
`pixman-x86.c` 的 CPUID 检查**之前**发出 SSSE3 指令。

真正的答案是 **`[build] flags` 带 `glob`**,而且不是新机制:`compat.sdl2` 早就用它把
`-msse3` 限定到单个文件。实测标志没有外溢:

```
pixman-ssse3.o      SSSE3 指令   2   ← 应当有
pixman-sse2.o       SSSE3 指令   0
pixman.o            SSSE3 指令   0
pixman-fast-path.o  SSSE3 指令   0
pixman-x86.o        SSSE3 指令   0
```

**由此得到一条判据补充**,值得记住,因为它把 build.mcpp 的边界又划细了一层:

> 按目标变的是**编哪些文件** → `build.mcpp`(GLdispatch 的 entry stub)。
> 按目标变的是**给哪个文件什么标志** → `[build] flags` 的 `glob`(pixman 的 SIMD)。

### 10.6 G1 的三个坑(都已写进代码注释)

1. **`genglmod.sh` 必须 `LC_ALL=C`。** CI 上重新生成得到**一样的符号数**(358/145/653)
   却有 48 行 glesv2 和 88 行 opengl 不同 —— `sort` 按 locale 排序混合大小写标识符,
   开发机 en_US.UTF-8 与 runner 的 C 顺序不同。同样的输入,不同的文件。
2. **包内测试无法证明 `.so` 身份。** 它链接的是本包的**对象**,所以 test 二进制自己定义
   `glClear`,dladdr 报的是可执行文件 —— 一条「不是 payload 的副本」的断言会在从未看过
   任何库的情况下通过。`.so` 级身份检查属于**消费者**,在 mcpp-index 的成员里。
3. **三个 GL flavour 符号面重叠**(都导出 `glClear`)。同一进程链两个,名字绑到先加载的
   那个 —— 实测:一个想用 GLESv2 的程序里 `glClear` 落到了 `libGLESv1_CM.so.1`,毫无
   提示。所以索引测试成员只依赖一个 flavour,并断言 `glClear` 确实解析在它里面。

模块层那个「GL 入口是否外部链接」的风险**解除了**:`KHRONOS_APICALL` 在 Linux 分支展开
为空,所以 `GL_APICALL void GL_APIENTRY glClear(...)` 就是普通外部链接声明,和 EGL 一样
不需要 forwarder。

### 10.7 pixman 的一个静默坑

`PIXMAN_API` 定义在 **`pixman-version.h.in`** 里,不在编译器头里。生成 version.h 时漏掉
它,`pixman.h` 里每个 `PIXMAN_API void pixman_fill(...)` 都解析成未知标识符、声明整个
丢失 —— 而报出来的错误是某个 SIMD 文件里的
`implicit declaration of function 'pixman_fill'`,与真正的原因隔了十万八千里。

### 10.8 沙箱验证已扩到渲染链,并重跑

签进仓的 `tests/verify_graphics_closed_loop_sandbox.sh` 加了 GLES2 渲染,在合成 home、
清空 store、从零构建的沙箱里对分支重跑(`--sandbox --gpu`):

```
===== 6. did anything come from the host? =====
  PASS: the host.s copies were present and reachable, and none of them won

===== 7. run it =====
  /dev/dri/renderD128     drm driver nvidia-drm
    eglInitialize        EGL 1.5, vendor Mesa Project
    GL_VERSION           OpenGL ES 3.2 Mesa 25.0.7
    glReadPixels         64 128 191 255 (wanted 64 128 191 255)
  /dev/dri/card0          drm driver simpledrm
    gbm_bo_create        256x256 stride=1024
    GL_VERSION           OpenGL ES 3.2 Mesa 25.0.7
    glReadPixels         64 128 191 255 (wanted 64 128 191 255)

  reached EGL on a real device: yes
  drew and read the pixel back: yes
RESULT: PASS
```

脚本后来又扩了一次,把输入链也纳入(只纳入 `freedesktop.*` 的两个 —— 这个项目声明
单一索引键,`compat.libinput` / `libudev` / `mtdev` / `libseat` 从**已发布**索引解析,
所以它们要等发布后才能进这个脚本):

```
  -- input --
    libevdev  KEY_A -> KEY_A
    xkbcommon keycode 24 -> "q"
  input chain answers: yes
```

**这是本轮之前做不到的那一步。** §19.4 那次止于 `eglInitialize` —— 能初始化不等于能画。
现在闭环从「打开 DRM 节点」一路走到「读回自己画的像素」,而且是在宿主图形库在场且可达
的沙箱里。

#### 10.8.1 第三次扩:整条输入链 + RMLVO(#298 / xim#732 之后)

`compat.libinput` 发布后补进依赖表(它把 `compat.libudev` + `compat.mtdev` 一起拉进来),
运行期加两段:libinput 经 libudev 起 context 并枚举 seat,以及 RMLVO 按名字编译真布局。
`eco-2026-8-30-3`,`--sandbox --gpu`,BRANCH=main:

```
===== 6. did anything come from the host? =====
  libudev.so.1 => <project>/target/.../bin/libudev.so.1        ← 不是宿主那份
  PASS: the host's copies were present and reachable, and none of them won

===== 6b. and the merged-in ones brought no shared library at all =====
  PASS: none of libinput/libevdev/libmtdev/libxkbcommon/pixman is a DT_NEEDED

  -- input --
    libevdev  KEY_A -> KEY_A
    xkbcommon keycode 24 -> "q"
    libinput  assign_seat=0 fd=3 dispatch=0
    libinput came up on libudev: yes
    XKB_CONFIG_ROOT /home/speak/.xlings/subos/eco-2026-8-30-3/share/X11/xkb
    evdev/pc105/us  keycode 24 -> "q"
    the real us layout compiled: yes
  input chain answers: yes
RESULT: PASS
```

**断言拆成两种,因为两半根本不是同一个问题**,而第一版把它们混在了一起:

| | 形态 | 判据 | 为什么 |
|---|---|---|---|
| `libudev` | `kind = "shared"` | 查**来源** | 宿主有自己的 `libudev.so.1`,而 compat.libudev 故意用同一个 soname |
| libinput / libevdev / libmtdev / libxkbcommon / pixman | `kind = "lib"` | 查**缺席** | 对象并进消费者,正确构建下根本不该有 DT_NEEDED |

把 `kind = "lib"` 的名字塞进原来那条「有没有解析到宿主」的 grep 是**误导**:它们永远
匹配不到,而「没匹配到」会被读成「宿主没赢」,实际上是压根没东西可赢。

没用 `nm` 查符号定义:strip 过的二进制没有 `.symtab`,会误报 FAIL;「没有共享库提供它」
是同一主张的另一面,且不受 strip 影响。代码真在且能跑,由第 7 步证明。

`libudev.so.1` 那一行是这次新增里最有分量的。`compat.libudev` 是**故意**用
`libudev.so.1` 这个规范 soname 的(见其描述符),理由是 soname 复用能让源码构建与
生态 payload 共存;这是那条判断第一次被放进「宿主有同名库、可达、就在 `/usr/lib`」的
环境里正面检验 —— 而它赢了。

#### 10.8.2 最终一次性闭环验证(全部数据集齐备)

上一节跑的时候 quirks 还没有提供方,输出里带着两条 `libinput error: failed to find
data files`。xim#734 之后重跑,**一次跑完整条链**,`eco-2026-8-30-3`,`--sandbox --gpu`:

```
===== 6. did anything come from the host? =====
  PASS: the host's copies were present and reachable, and none of them won
===== 6b. and the merged-in ones brought no shared library at all =====
  PASS: none of libinput/libevdev/libmtdev/libxkbcommon/pixman is a DT_NEEDED

===== 7. run it =====
  EGL_VERSION            1.5 libglvnd
  /dev/dri/renderD128   nvidia-drm    GL_VERSION OpenGL ES 3.2 Mesa 25.0.7
    glReadPixels         64 128 191 255 (wanted 64 128 191 255)
  /dev/dri/card0        simpledrm     gbm_bo_create 256x256 stride=1024
    glReadPixels         64 128 191 255 (wanted 64 128 191 255)
  reached EGL on a real device: yes
  drew and read the pixel back: yes

  -- input --
    libevdev  KEY_A -> KEY_A
    xkbcommon keycode 24 -> "q"
    libinput  assign_seat=0 fd=3 dispatch=0
    libinput came up on libudev: yes
    evdev/pc105/us  keycode 24 -> "q"
    the real us layout compiled: yes
  input chain answers: yes

===== 8. the datasets the ecosystem supplies, checked by their absence of complaint =====
  LIBINPUT_QUIRKS_DIR = .../share/libinput (52 files)
  ok: libinput loaded the quirks database (no 'failed to find data files')
  XKB_CONFIG_ROOT     = .../share/X11/xkb (151 layouts)

===== RESULT =====
  PASS
```

**第 8 步是新加的,而且它的判据是「没有抱怨」。** 两条数据变量都**优雅降级** ——
不设也照样一路 PASS,libinput 用内置默认、xkbcommon 只编字符串 keymap。所以它们必须
有自己的检查,而唯一可观测的信号是那条消息在不在:

```
不设 LIBINPUT_QUIRKS_DIR:  libinput error: failed to find data files    ← 在
设了:                      (无)                                          ← 没了
```

变量未设时这一步**报告而不失败** —— 没装数据集的 subos 是合法配置,不是缺陷。

### 10.9 xkeyboard-config 属于生态,不属于 mcpp-index

输入链做到最后一环时,这一条自己浮出来了,而且它与 §3 的 Vulkan ICD **是同一个形状**。

libxkbcommon 只编译 keymap、自身不含布局。布局在 xkeyboard-config 里。问题是:一个
**没有源码的纯数据包**,怎么让消费者知道路径?

**mcpp-index 没有这个机制,而且不该有。** 图形栈里所有这类运行期发现路径 ——
`GBM_BACKENDS_PATH`、`__EGL_VENDOR_LIBRARY_DIRS`、Vulkan 的 ICD 目录 —— 一律由
**环境**声明,由 `xim:mesa` 通过 graphics discovery 层给出。`XKB_CONFIG_ROOT` 是同一
类东西:它是运行期数据发现,不是构建期依赖。

**实测缺口**:生态里已经有 `xim:libxkbcommon`,但它的 payload 只有 `bin include lib
share/{bash-completion,man}` —— **不带 xkb 数据**。所以 `XKB_CONFIG_ROOT` 无处可指,
按名字查 keymap(`xkb_keymap_new_from_names`)只能落到宿主的
`/usr/share/X11/xkb` —— 与 Vulkan 静默落到宿主 llvmpipe 完全同构。

**结论**:xkeyboard-config 应当作为 payload 进 **xim-pkgindex**,并通过 discovery 层
声明 `XKB_CONFIG_ROOT`,而不是作为源码包进 mcpp-index。索引侧已经做对了自己那一半:
`freedesktop.libxkbcommon` 的 `DFLT_XKB_CONFIG_ROOT` 是空的,所以数据集缺失会说
「找不到 keymap」而不是悄悄用宿主的。

⚠ 顺带一提:一个**只需要 `xkb_keymap_new_from_string`** 的合成器不需要这份数据 ——
那正是它从客户端收到 keymap 的路径,也是本索引测试跑通 parser 的方式。

#### 10.9.1 已落地(openxlings/xim-pkgindex#732)

上面的结论已实现,并在实现过程中改了 discovery 层的两处形状:

**`XKB_CONFIG_ROOT` 是表里第一个非列表项。** DISCOVERY 的另外四行都是冒号分隔的搜索
路径,`prepend` 在那里既正确又无损(而且必须是 prepend:一个提供方 `set` 会盖掉另一
个,NVIDIA vendor 目录消失就是这么来的)。`XKB_CONFIG_ROOT` 是**标量** —— libxkbcommon
读一次当一个目录用,`prepend` 上第二个提供方就变成 `dirA:dirB`,一个不存在的路径,而
报错只会说「keymap 编译失败」。所以给 DISCOVERY 行加了可选的 `op`,默认仍是 `prepend`,
这一行写 `set`。

> 这与记忆里那条 `xvm envs 是 PATH 式合并`(标量 env 会被冒号拼接)是同一件事的第二次
> 撞见。第一次的答案是「生成 launcher」;这次因为发现点在 discovery 层内部,所以修在
> 了机制里。

**声明变量 ≠ 放置内容。** 第一版只加了 DISCOVERY 行和 `declare_subos_env` 调用,装完之后:

```
XKB_CONFIG_ROOT=[.../subos/eco-2026-8-30-1/share/X11/xkb]
ls: cannot access '.../share/X11/xkb': No such file or directory
```

变量在 shell 里读得好好的,指向不存在的目录。补 `graphics.declare_xkb`,与
`declare_dri` / `declare_gbm` 同形(`xvm.files` 把树放进 subos)。

**跨索引闭环已实测** —— mcpp 侧的 `freedesktop.libxkbcommon` 消费 xim 侧的数据集:

```
XKB_CONFIG_ROOT = .../subos/eco-2026-8-30-1/share/X11/xkb
xkb_keymap_new_from_names(evdev/pc105/us) against that root ok
   real layout: keycode 24 -> "q"
…and the real us layout maps keycode 24 to "q"           ok
0 check(s) failed
```

消费侧断言写在 `tests/examples/libxkbcommon`,且是**条件式**的:`XKB_CONFIG_ROOT` 未
设置时只报告,设置了才要求编得出来。没有数据集的机器不是这个包的缺陷。

**合并后又从「已发布索引 + 全新 subos + 沙箱」复验了一遍**,因为上面那次用的是
`xlings config --add-xpkg` 的本地副本:

```
xim:xkeyboard-config@2.48 installed          ← 来自已发布索引,不是 local:
ROOT=[.../subos/eco-2026-8-30-2/share/X11/xkb]
compat geometry keycodes rules symbols types
  rules/evdev 行数: 512
  布局数: 151
```

**这次复验抓到一个真实陷阱,而且差点得出"包坏了"的结论**:第一次从已发布索引装,
数据**没有**放进去。原因不在包 —— store 里还留着本地验证时的
`local:xkeyboard-config@2.48`,而 xlings 的 store 查找**忽略 namespace**,
`(name, version)` 撞上就把 `install()` 静默跳过,payload 是空的,而 `config()` 照常跑。
清掉 store 重装即正常。

**两条要记住的**:

1. 用 `--add-xpkg` 本地验证过的包,发布后必须**先清 store 再验一遍**,否则验的
   仍然是本地那份。
2. `declare_xkb` 的 `os.isdir` 守卫确实触发了,但那条 `log.warn`
   **在 install 输出里根本没出现**(同一次输出里 xlings 自己的 `[warn]` 是打出来的)。
   所以 `declare_dri` / `declare_gbm` / `declare_xkb` 的警告都不能当诊断依赖 ——
   判断内容有没有真放进去只能直接 `ls`。

#### 10.9.2 同一形状的第三处:libinput quirks

写 `compat.libinput` 时把 `LIBINPUT_QUIRKS_DIR` 也编译成空,注释里当时写的是「编译期
路径,空即用内置默认」。**这句话不准确**:`libinput.c:1911` 是
`getenv("LIBINPUT_QUIRKS_DIR")` 优先、编译期值兜底 —— 和 `GBM_BACKENDS_PATH`
一模一样的形状。

所以这不是死路,是**缺提供方**:`.quirks` 文件就在 libinput 自己的 tarball 里,但
mcpp-index 没有发布数据目录的机制(与 §10.9 同因)。在有东西填上之前,libinput 打印

```
failed to find data files ... will negatively affect device behavior
```

并跑在内置默认上。这是**优雅降级**:枚举、事件、手势都正常,丢的是逐机型调校(比如
某块触摸板的压力区间)。`tests/examples/libinput` 就是在这条消息存在的情况下全绿的。

补法与 xkeyboard-config 对称(xim 数据包 + 一行 DISCOVERY)。**已做**,见 §10.9.3。

#### 10.9.3 已落地(openxlings/xim-pkgindex#734)

**没建新仓,也没发新 release** —— 这是它与 xkeyboard-config 的关键差别,而差别的
判据是**数据是不是构建出来的**:

| | 数据来源 | 结论 |
|---|---|---|
| xkeyboard-config | 上游 meson 跑规则编译器,`rules/evdev` 由 ~40 片段拼出 | 必须预生成 + 重新发布 |
| libinput quirks | 签在 libinput 树里,`install_subdir` 原样安装 | **直接用上游 tarball** |

所以 `libinput-quirks` 下的是 libinput **自己的** tarball —— 与 `compat.libinput`
**同一个 URL、同一个 sha256** —— 只保留 `quirks/`。为 240KB 数据下 1.1MB,换来没有第二
份归档要发布、没有镜像要同步,而且数据集**可证明**就是 libinput 1.31.3。

版本跟库走不是装饰:quirks 文件里写 libinput 的特性名(`AttrPressureRange`、
`ModelBouncingKeys`),数据集比库新就可能带库不认识的键。

`LIBINPUT_QUIRKS_DIR` 是 DISCOVERY 表里第二个 `op = "set"` 的标量(`quirks.c:1217`
只 scandir 一个目录),排序用 `versionsort` —— 所以 `10-` / `30-` / `50-` 文件名前缀
决定优先级,与 glvnd vendor JSON 同一套约定,也正是 `compat.libinput` 里
`HAVE_VERSIONSORT` 不可省的原因。

**实现中撞到的:`install()` 里的 `os` 表是受限子集。** 写日志逐个 `type()` 探出来:

| nil | 可用 |
|---|---|
| `os.files` `os.filedirs` `os.exists` `os.curdir` `os.iorunv` | `os.dirs` `os.isdir` `os.isfile` `os.mv` `os.cp` `os.mkdir` `os.tryrm` `os.cd` |

坑不在「调了会报错」,而在惯用的 `#(os.files(...) or {}) == 0` —— 它把**「这个函数
不存在」变成「目录是空的」**。第一版就是这么把一次**已经成功**的移动报成失败的:探针
打出来 `isdir(dst) = true`,数据早就在位,挂的只是计数那一行。

改法:**先做再验结果,不预探测**;计数换成 `os.isdir` + 一个规范文件名
(`10-generic-keyboard.quirks`)。耦合一个文件名比 glob 差,但比受限表下**根本没有
检查**好 —— 空目录是唯一会**静默**失败的情况:scandir 到零个匹配,libinput 用内置
默认继续跑,连那条报错都不打。

前后对照(`tests/examples/libinput`):

```
不设变量:  libinput error: failed to find data files       ← 在
设了变量:  (无)                                             ← 没了
           52 个 .quirks 已加载,6 项断言全过
```

#### 10.9.4 `USB_IDS_PATH` 是**不该补**的那一格

`compat.libudev` 也把 `USB_IDS_PATH` 编译成空,本文档早前把它与 quirks 并列成
「机制在、提供方缺」。**核实后两句都是错的**:

1. **机制不在。** libudev-zero 全树**零个 `getenv`**,`udev.c:95` 是
   `fopen(USB_IDS_PATH, "r")` —— 编译期常量,没有环境出口。加数据包不会让它生效。
2. **补了也没用。** 它只喂 `udev_hwdb_get_properties_list_entry()` 的两个属性
   (`ID_MODEL_FROM_DATABASE` / `ID_VENDOR_FROM_DATABASE`),而 **libinput 一次都没
   读过**(`src/*.c` 里 grep `FROM_DATABASE` 为空)。设备名走的是
   `libinput_device_get_name → evdev_device_get_name →` 内核 `EVIOCGNAME`。

而且这压根不是 libudev 的标准做法:systemd 的 udev **运行期不读 `usb.ids`**,它读
编译好的 `hwdb.bin`(由 `hwdb.d/*.hwdb` 文本编译,而那些文本在构建期从 usb.ids 生成)。
宿主上 `/usr/share/hwdata/usb.ids` 是给 `lsusb` 之类用的。libudev-zero 直接 parse
文本是它自己对 hwdb 的简化实现。

**结论:这一格留空对本栈影响为零,不列为缺口。**

#### 10.9.5 发行版为什么不需要这些变量

值得单独写一句,因为它解释了整类问题:**发行版拥有 `/usr`**。

```
libinput-bin: /usr/share/libinput/*.quirks     ← 库和数据同一个包,--prefix=/usr 写死
/usr/lib/udev/hwdb.d/20-usb-vendor-model.hwdb  ← systemd udev 编译成 hwdb.bin
```

路径永远不会错,所以不需要任何环境变量。需要环境变量的恰恰是**可重定位**的那一类 ——
Nix、Flatpak、Snap、Conda,和我们。这不是本生态特殊,是同一类系统的共同解法。

### 10.10 仍未做

- ~~G4b `libxkbcommon`~~ **已做**(fork,bison parser 预生成)。它需要的数据集见 §10.9:
  属于生态,不属于这里。
- ~~G5 `libinput`~~ **已做,并且测试成员一接上就抓出了四个 bug**(#298)。
  形态问题解决得很朴素:这个成员**不声明 `[indices]`**,继承根的
  `compat = { path = "." }` —— compat 来自 checkout,`freedesktop.libevdev` 来自已发布
  索引(它确实已发布)。声明 `freedesktop` 反而会让 `compat.libinput` 去查已发布索引。

  四个 bug 值得单列,因为它们**全都是"包进了索引但从没被编译过"造成的** ——
  没有测试成员消费它,而没人编译的包不会编译失败(记忆里那条「绿 CI 不等于包被编译」
  的教科书案例):

  | 问题 | 症状落点 |
  |------|---------|
  | 缺 `libinput-version.h`(meson 从 `.h.in` 生成) | `libinput-private.h:45` 无条件 include,40 个源文件全挂 |
  | `config.h` 只写了一半 | `HTTP_DOC_LINK` / `LIBINPUT_QUIRKS_OVERRIDE_FILE` / `LIBINPUT_PLUGIN_{LIB,ETC}DIR` / `HAVE_VERSIONSORT` / `HAVE_MTDEV` |
  | `include_dirs` 少了包根 | 全树只有一个文件写 `#include "src/evdev-frame.h"` |
  | `typeof` 是 GNU 关键字 | `-std=c11` 下 cast 塌成 `int`,错误落在十几个没提 typeof 的文件里 |

  其中两条有普遍意义:

  **`HAVE_VERSIONSORT`** —— 不定义它,`libinput-versionsort.h` 会给出自己的
  `static strverscmp`,而 glibc 已经 `extern` 声明过。这是硬错误,不是遮蔽。
  「少定义一个 HAVE_ 宏最多退化」的直觉在这里是错的。

  **`c_standard = "gnu11"` 不生效,这次是实测的** —— mcpp 收下这个字符串,仍然发
  `-std=c11`,那些 typeof 错误原样还在。所以走 `-Dtypeof=__typeof__`。这与记忆里
  「c_standard 的 gnu 模式被静默忽略」一致,但那条记的是 `_GNU_SOURCE` 类的**库特性
  宏**;`typeof` 是**语言方言**,`-D_GNU_SOURCE` 对它无效。两者要分开记。
- ~~G6 `libudev` / `libseat`~~ **已做**,而且没有碰 systemd:libudev 用
  **libudev-zero**(三个实现里唯一既活着又可独立分发的),libseat 只开 seatd 与
  builtin 后端。两者的代价都在描述符里点名了。
- ~~**xkeyboard-config**~~ **已做**(xim-pkgindex#732),见 §10.9.1。
- ~~**libinput quirks 数据**~~ **已做**(xim-pkgindex#734),见 §10.9.3。
- ~~**`USB_IDS_PATH`**~~ **不补**,理由见 §10.9.4:机制不在(零 `getenv`),而且补了
  也没用(libinput 从不读那两个属性)。

至此渲染链与输入链都不再有「静默落到宿主」的边,而且**没有一格是留着的**:

| 子系统 | 发现变量 | 提供方 | 状态 |
|--------|---------|--------|------|
| DRI 驱动 | `LIBGL_DRIVERS_PATH` | `xim:mesa` | ✅ |
| EGL vendor | `__EGL_VENDOR_LIBRARY_DIRS` | `xim:mesa` + host-link 哨兵 | ✅ |
| Vulkan ICD | `XDG_DATA_DIRS` / 共享 vendor 目录 | 同上 | ✅ xim#731 |
| GBM 后端 | `GBM_BACKENDS_PATH` | `xim:mesa` | ✅ |
| 键盘布局 | `XKB_CONFIG_ROOT` | `xim:xkeyboard-config` | ✅ xim#732 |
| 输入 quirks | `LIBINPUT_QUIRKS_DIR` | `xim:libinput-quirks` | ✅ xim#734 |
| USB 名字库 | `USB_IDS_PATH` | — | ➖ 无影响,见 §10.9.4 |

**留空编译期默认值换来的东西,到这里可以结账了**:六个子系统里没有一个会悄悄读宿主
的数据;缺失的那些在补上之前**都会自己说出来**(GBM 的 `MESA-LOADER: failed to open`、
libinput 的 `failed to find data files`),而这些消息正是本轮把它们一个个补上的线索。

#### 10.10.1 加一行进这张表,同时是一次对**现有提供方**的改动

xim#732 加 `XKB_CONFIG_ROOT` 那天就出了回归(xim#733 修):`mesa` 一直写
`declare_subos_env(tag)`,而**不传 `only` 的含义是「声明每一行」**。表一变长,mesa 就
替键盘布局声明了路径,而它的 payload 是 `share/{drirc.d,glvnd,vulkan}`,没有 `share/X11`。

今天这个值碰巧无害(xkeyboard-config 声明同一条相对路径、而且是它真正放的树),但在
**没装** xkeyboard-config 的 subos 上,mesa 会把变量指向不存在的目录 —— 正是 §10.9.1
刚记下的失败形态,只是由错误的提供方造成。

修的是规则不是 mesa:新增 `graphics.RENDER_PATHS`,三个调用点(`mesa` /
`nvidia-gl-host-link` / `xkeyboard-config`)现在都传显式集合。**省略 `only` 读起来像
便利写法,行为上是一个会在调用方背后增长的声明。**

所以往这张表加行的检查清单是两项,不是一项:

1. 新提供方 `config()` 里要有**两个**调用(`declare_*` 放置 + `declare_subos_env` 声明);
2. **回头检查每个现有调用点传没传集合** —— 没传的那个会自动继承你的新行。

顺带一条环境事实:环境变量声明是**持久化**的,改 recipe 不回溯更新已装的包。验证必须
开新 subos —— 在已装的那个上看到的是旧值,第一次就被这个骗了一轮。

G6 仍是需要决策的:合成器可以在「已有 DRM master」的前提下开发(从 TTY 直接启动、或
`SEATD_SOCK`),把 session 管理留到最后。

---

## 11. 交付总账(v1.0)

### 11.1 完整变更集

八个 PR,两个仓,全部已合入:

| 仓 | PR | 内容 | 性质 |
|---|---|---|---|
| mcpp-index | #298 | libinput 测试成员 + 描述符四个 bug | 功能 |
| mcpp-index | #301 | 沙箱脚本纳入输入链 / RMLVO / quirks 断言 + 文档 | 验证 |
| xim | #731 | nvidia-gl-host-link 声明 Vulkan ICD | 功能 |
| xim | #732 | xkeyboard-config 键盘布局数据集 | 功能 |
| xim | #733 | mesa 只声明自己填的路径 | **#732 的回归** |
| xim | #734 | libinput-quirks 设备 quirks 数据集 | 功能 |
| xim | #735 | consumer_envs 跳过标量 + `libs/**` 纳入 CI | **#732/#734 的回归** |
| xim | #736 | publish-artifact 也看 `libs/**`,并把自己列进 paths | **#735 的交付缺口** |

### 11.2 为什么不是单 PR —— 两条硬约束和一处我的失误

**硬约束一:跨仓。** mcpp-index 打包代码,xim 发布数据目录与运行期发现变量;一个
GitHub PR 无法跨两个仓库。这个切分不是选择,§10.9 论证过它是两个索引各做各建模的
事 —— 而**正是这条约束**决定了这套东西必须至少两个 PR。

**硬约束二:发布顺序。** #301 的沙箱脚本从**已发布索引**解析 `compat.libinput`
(它只声明一个索引键,见脚本注释),所以它只能在 #298 合入**并且索引产物发布之后**
才可能被验证。合成一个 PR 会让脚本引用一个还不存在的包。

**我的失误:#733 与 #735 本可以不存在。** 它们修的是 #732 引入的回归,而找到它们
靠的是自我 review 而非新信息 —— 也就是说,如果我在合 #732 之前就跑完那份检查清单,
两处都会在 #732 里。清单本身是被这两次回归**逼出来**的(§10.10.1 与下节),这正是
代价:**规则是从事故里学的,而事故已经进了历史**。

### 11.3 `libs/**` 三处缺席 —— 本轮最可迁移的发现

`libs/graphics.lua` 被四个 recipe `import`,是这个索引里波及面最大的文件,而它同时
是**唯一完全不被看见**的一类改动:

| workflow | 缺席 `libs/**` 的代价 |
|---|---|
| `ci-test.yml` | 评审覆盖 —— 改动不跑任何检查 |
| `ci-xpkg-test.yml` | 评审覆盖 |
| **`publish-artifact.yml`** | **交付** —— 产物不重出,用户拿到旧版 |

第三处最隐蔽:#735 合进 main、11 个检查全绿、gitee 镜像同步到 `ea36f6b`,而
`xlings update` 仍在发 `xim-index-f1702a1.tar.gz` —— 修复**之前**那一版。夜间
cron 最终会补上,所以是**慢漏**不是断供,但「合了、绿了、用户拿到的还是旧的」骗过了
每一个常规检查。

**这解释了本轮四处问题为什么全部靠自我 review 发现、没有一处是 CI 抓到的** ——
CI 从来没有机会看那个文件。

两条操作性结论:

1. 判断共享文件有没有被覆盖,**读 `on.paths`,别看 workflow 名字**。反查:
   `grep -rln "pkgs/\*\*" .github/workflows/ | xargs grep -L "libs/\*\*"`
2. 修复合入后**核验产物,不要核验 PR 状态**:`xlings update` 之后直接 grep 本地
   索引里那段代码。「PR merged + CI green」不蕴含「用户拿到了」。

发布器现在把**自己**也列进 paths(沿用 `ci-test.yml` 既有做法),于是改发布器的 PR
自验 —— 实测:合入后立刻自触发一次 `push` 发布,而合入前同样的改动零触发。

### 11.4 加一行 DISCOVERY = 三项检查

被 #733 与 #735 各逼出来一项:

1. 新提供方 `config()` 里要有**两个**调用(`declare_*` 放置 + `declare_subos_env`
   声明)—— 只声明会让变量指向不存在的目录(§10.9.1);
2. 回头看每个 `declare_subos_env` 调用点传没传集合 —— 不传 `only` 就是「声明每一
   行」,新行会被现有提供方自动继承(§10.10.1);
3. 回头看 `consumer_envs()` 的消费者 —— 新行会自动进入**每一个** shim,而 shim 侧
   **没有 `op`**,标量会被拼成冒号路径(#735)。

### 11.5 最终状态

发现变量表六格全部有提供方,第七格经核实不该补(§10.9.4)。闭环验证一次跑完
(§10.8.2),用户侧产物已核验为 `xim-index-ea36f6b.tar.gz`(含全部修复),两份数据
归档的 GLOBAL/CN 镜像均已发布且逐字节一致(sha256 比对,非可达性)。

---

## 12. 「完备」是对谁而言 —— 客户端那半的缺口

本设计通篇是从**合成器**视角写的,而这带来一个直到最后才浮出来的偏差:整条栈从
服务端看是完整的,从**客户端**看是不能用的。

### 12.1 `libwayland-egl` —— 断掉的第二步(mcpp-index#304,已合)

一个 Wayland 客户端要用 EGL 画东西,需要三样:libwayland-client 给的 `wl_surface`、
libEGL 给的 `EGLDisplay`,以及把两者接起来的东西。那个东西是
`wl_egl_window_create` —— Wayland 上拿到 `EGLNativeWindowType` 的**唯一**办法。

```
wl_surface  ->  wl_egl_window  ->  eglCreateWindowSurface  ->  draw
                ^^^^^^^^^^^^^ 之前不存在
```

漏掉的原因很具体:fork 建了 client / server / util / scanner 四个成员就停了 ——
**合成器渲染进 GBM 缓冲,永远不会问这个**。上游把源码放在同一个 tarball 里
(`upstream/egl/`,118 行),所以这是一个从没写过的成员,不是一个权衡过的决定。

**判据修正**:「这个包的功能齐了吗」不够,得问「**齐了给谁用**」。同一条栈,
服务端消费者和客户端消费者要的东西不重叠,而本轮之前只有前者有测试成员。

### 12.2 换 tarball 而不重切 tag

加第五个成员改变了归档内容,而**一份归档支撑五个索引条目**。原来 GLOBAL 指向
**tag archive**(`archive/refs/tags/v1.26.0.tar.gz`),重切 tag 会当场打断已发布的
四个描述符的 sha256 —— 就是 §19.6 那条教训。

**解法是根本不重切**:把新内容作为 **release 资产**发布
(`wayland-1.26.0-mcpp2.tar.gz`),旧 tag 归档原样保留。这样没有任何时间窗口里
main 是坏的,而重切方案无论顺序怎么排都有。

顺带两个收益:GLOBAL 与 CN 形态对称(都是 release 资产);重打包时解引用了
`upstream/git-blame-ignore-revs` 符号链接,消掉「符号链接归档咬 Windows」那条隐患。

> **这一条比 §19.6 更该被记住**:重切 tag 的正确顺序是个精细活,而**不重切**把
> 问题整个消掉。tag 指向历史,资产承载分发,两者不必是同一个东西。

### 12.3 一处我断言错了、被测试抓住的地方

`tests/examples/wayland-egl` 第一版断言 `wl_egl_window_get_attached_size` 在
`create` 之后返回创建尺寸。实测是 `0 x 0`。读源码才知道 `attached_width/height`
是 **EGL 实现附加缓冲时才写**的字段,`create` 用 `calloc` 归零、`resize` 也不碰。

现在断言的是真契约:**没有东西渲染进去的窗口报告「什么都没附加」**。这也是为什么
测试包含 `wayland-egl-backend.h` —— 那是这个库与 EGL 实现之间的契约(Mesa 就包含
它),否则透过公共头只能观测到「create 返回非空」。

### 12.4 客户端侧仍缺的

| 缺口 | 后果 | 规模 |
|---|---|---|
| `fontconfig` / `cairo` | `freetype` ✓ `harfbuzz` ✓ 能渲染字形,但**不能按名字找到字体**,也没有 2D 矢量绘制 | 中 |
| `libdisplay-info` | EDID 解析,较新的 wlroots 需要 | 小 |
| **wlroots** | 原材料齐了但没有这一层,等于要自己写它 | 大 |
| XWayland | 跑不了 X 应用 | 大(拖 xorg-server) |

前两个是普通工作量。**wlroots 是需要决策的**:它是几乎每个现代合成器的基座
(sway / hyprland / river / wayfire),没有它,「用 mcpp 写合成器」的意思是从
DRM/GBM/EGL 直接起手写一万行。

### 12.5 `libwayland-cursor` —— 第六个也是最后一个成员(#306)

Wayland **没有服务端光标**:客户端要指针,就得自己加载主题、把图像变成
`wl_buffer`、附到交给 `wl_pointer.set_cursor` 的 surface 上。没有这个库,每个应用
都得自己解析 XCursor 文件格式。

⚠ 不是 `compat.xcursor` —— 那是 X11 的 `libXcursor.so.1`,要和 X 服务器说话。

**至此 fork 建齐了上游发布的每一个库,没有第七个。** 与 `-egl` 的实质差别:cursor
**真的链** libwayland-client(`wl_shm_create_pool` 等),egl 只要头。两者 manifest
长得一样而实质不同,所以 CI 分别断言。

**第七个发现变量:`XCURSOR_PATH`。** `xcursor.c:493` 写死
`"~/.icons:/usr/share/icons:/usr/share/pixmaps:…"`,而 `xcursor.c:515` 先读
`getenv("XCURSOR_PATH")` 且设置了就原样返回 —— 和 `LIBINPUT_QUIRKS_DIR` /
`XKB_CONFIG_ROOT` 完全对称,所以同样编译期置空。fork CI 里 **grep 二进制**确认,
因为值错了的失败方式是**在恰好有 `/usr/share/icons` 的机器上静默正常工作**。

---

## 13. 仍缺的部分(收尾备注)

排在这里的都**核实过**,不是猜测。

### 13.1 wlroots 只卡在两个包 —— 从它自己的 meson 逐条读出

| wlroots 0.18.2 需要 | 状态 |
|---|---|
| wayland-server / client / protocols / scanner / **egl** | ✅ 六个成员齐了 |
| libdrm · pixman · xkbcommon · libinput · libudev · libseat · egl · glesv2 · gbm | ✅ |
| vulkan(可选渲染器)· lcms2(可选色彩管理)· libliftoff(可选) | ✅ / 可选 |
| **hwdata**(构建期,读 `pnp.ids` 生成 `pnpids.c`) | ❌ |
| **libdisplay-info** | ❌ |
| cairo | **不需要** —— 只在 `examples/`,`required: false` |

⚠ 本文档早前把 cairo 列为 wlroots 的缺口,**是错的**;而把 `libdisplay-info` 标为
「小」也没说清 —— 它体量确实小,但**它是整个 wlroots 的闸门**。

`libdisplay-info` 该走 **fork + 预生成**(和 libevdev / libxkbcommon 同形):它要跑
`tool/gen-search-table.py` 生成 2568 行的 `pnp-id-table.c`,放不进
`generated_files` 字面量。而且 **`pnp.ids` 必须取上游 hwdata 的发布物,不能用宿主
那份** —— 上游 meson 找不到 hwdata 时会回落到 `/usr/share/hwdata/pnp.ids`,正是要
消的宿主边;这也是 libevdev 那次「宿主内核头给出不同的表」的同一教训。

### 13.2 桌面侧仍缺的

| 缺口 | 后果 | 规模 |
|---|---|---|
| `fontconfig` | **按名字找字体**。`freetype` ✓ `harfbuzz` ✓ 只给字形,不给发现 | 中 |
| `pango` | 段落级排版:换行、双向文字、CJK、组合字符 | 中(拖 glib) |
| `cairo` | 2D 矢量绘制,或全用 GLES 自己画 | 中 |
| `dbus` | 通知、portal、会话、媒体键 | 中 |
| `PipeWire` | 音频 + 屏幕共享 | 大 |
| `libjpeg-turbo` | png/webp 有了,jpeg 没有 | 小 |
| XWayland | 跑 X 应用(本轮明确不考虑) | 大 |

**数据包(xim 侧,和 `xkeyboard-config` 同形)**:光标主题(填 `XCURSOR_PATH`)、
图标主题、字体。三者都是「机制已就位、缺提供方」。

### 13.3 发现变量总表(收尾状态)

| 子系统 | 变量 | 提供方 |
|--------|------|--------|
| DRI 驱动 | `LIBGL_DRIVERS_PATH` | `xim:mesa` ✅ |
| EGL vendor | `__EGL_VENDOR_LIBRARY_DIRS` | `xim:mesa` + host-link 哨兵 ✅ |
| Vulkan ICD | `XDG_DATA_DIRS` | 同上 ✅ |
| GBM 后端 | `GBM_BACKENDS_PATH` | `xim:mesa` ✅ |
| 键盘布局 | `XKB_CONFIG_ROOT` | `xim:xkeyboard-config` ✅ |
| 输入 quirks | `LIBINPUT_QUIRKS_DIR` | `xim:libinput-quirks` ✅ |
| **光标主题** | **`XCURSOR_PATH`** | **— 机制已就位,缺提供方** |
| USB 名字库 | `USB_IDS_PATH` | — 经核实**不该补**(§10.9.4) |

七格里六格有提供方,第七格(光标主题)是纯数据包,补法与 xkeyboard-config 完全相同。

### 13.4 本轮被自己的测试抓住的三处

都记在这里,因为它们是同一类:**我从假设写断言,而不是从源码**。

1. **`get_attached_size` 返回创建尺寸** → 实际 `0 x 0`。`attached_*` 是 EGL 实现
   附加缓冲时才写的字段(§12.3)。
2. **null `wl_shm` 只会跑到主题解析器** → 实际 `wayland-cursor.c:410` 无保护解引用,
   段错误 exit 139。`wl_cursor_theme_load` 真的需要活的 `wl_shm`。
3. **`&wl_shm_create_pool` 能证明链了 client** → 它是 wayland-scanner 的
   `static inline` 协议包装,取地址会**强制本 TU 实例化**,把
   `wl_proxy_marshal_flags` 等私有符号拖进来。GNU ld 经传递 DT_NEEDED 解析,
   **lld 不会,而 lld 是对的**。改用 `wl_display_connect`(真外部符号)。

第 3 条只有 llvm 那条腿抓得到 —— 它没有 sysroot 且用 lld,而这正是
`validate.yml` 注释里说的「gcc 腿结构上看不见这一类 bug」。

---

## 14. fork 的规范形态(2026-08-30 修订)

本轮前半段的 fork 用了 `sh` + `python` 预生成、把产物签进仓。**那是错的**,正确
形态是:

> **上游目录与适配目录分开;能支持模块的直接支持模块;生成走
> `mcpp` + `build.mcpp` + `feature`;尽量不依赖其他工具、sh 或 python。**

### 14.1 `build.mcpp` 是 C++ 程序,不是配置

这是我一开始判断错的地方,而它决定一切:`build.mcpp` 由 mcpp **编译并运行**,
`import mcpp;` 提供指令 API(`generated` / `include_dir` / `define` / `action` /
`dep_dir` / `dep_bin` / `out_dir` / `manifest_dir` / `rerun_if_changed` /
`target_os`)。所以任何"读文件、变换文本、写文件"的生成器都能在里面做,不需要
外部解释器。

`freedesktop.libdisplay-info` 是按这个形态重做的样板(#308):

| 产物 | 由谁产 |
|---|---|
| `pnp-id-table.c`(2583 行) | `build.mcpp` → out dir |
| `src/libdisplay-info.cppm`(206 个名字) | `build.mcpp` → src/ |

**没有签进仓的生成物,所以也没有「重生成再 diff」的 CI 步骤** —— "数据与代码
不一致"这个状态不存在。这是构建期生成与签生成物的本质区别。

模块写进 `src/` 而非 out dir,因为 `[lib] path` 是**静态**声明的;`build.mcpp`
在编译前跑,所以到用的时候文件已经在。

### 14.2 模块能顺手消掉一类上游缺陷

libdisplay-info 的七个公共头**一个 `extern "C"` 都没有**,C++ 消费者 `#include`
会 mangle 到链接失败(`undefined reference to di_info_get_make(di_info const*)`)。
原来的处理是"让消费者自己包,并写进文档";有了模块,包装做在模块 purview 里:

```cpp
import freedesktop.displayinfo;   // 消费者不用管
```

`compat.libseat` 有同样的上游问题而没有模块,所以那里消费者仍要自己包 —— 两者
对照说明模块层不只是风格。

### 14.3 生成器可以比上游更正确

`build.mcpp` 的 PNP 表与上游 python 生成器**逐行 diff 过**:2583 行,除几个
非 ASCII 名字外完全一致,而那几个**这边是对的**。

`pnp.ids` 里 `DemoPad<U+00A0>Software<U+00A0>Ltd`,U+00A0 编码是 `c2 a0` 两字节。
上游按**文本**读、按码点转义成 `\240` —— 单字节,不是 UTF-8,消费者打印会得到
替换字符。`build.mcpp` 按**字节**转义成 `\302\240`。

---

## 15. fontconfig:我的估算错了,以及它真正的形态

### 15.1 更正

| | 我先前说的 | 实测 |
|---|---|---|
| 规模 | 「中,和 libinput 同量级」 | 26k 行源码,**7 个生成物** |
| 生成器 | 「一个 python 脚本读一个文本文件」 | `makealias.py` 71 行 + `cutout.py` + gperf + `fc-case.py` **240 行** + `fc-lang.py` **387 行,吃 281 个 `.orth` 数据文件** |

`fc-lang` 把 281 个正字法文件编译成 FcCharSet 的 leaf/number 位图 —— 复刻它
约等于重写一个小编译器。**这不是「工作量不大」**,而我基于错误估算说过它是。

### 15.2 已经做通的部分(全部在 `build.mcpp` 里,零外部工具)

- `fcstdint.h`
- `fcalias.h` / `fcaliastail.h` —— 复刻 `makealias.py`,**含它的分组顺序**:
  tail 按"哪个 `.c` 定义了这个符号"分组,`#ifdef` 块必须按首见顺序嵌套
- `fcftalias.h` / `fcftaliastail.h`
- **`fcobjshash.h` —— 用二分查找替掉 gperf 的完美哈希**。这是一处**判断**而非
  转写:唯一消费者是 `fcobjs.c`,它调 `FcObjectTypeLookup(str, strlen(str))` 并
  只读 `->id`,72 个条目。语义等价,而少一个工具和一遍 C 预处理。条目来自
  `fcobjs.h` 的 `FC_OBJECT(...)` 列表 + `fontconfig.h` 的 `#define FC_<NAME>`,
  两个文本扫描,不需要 cpp
- 模块包装
- `config.h` —— **不是**生成物:它是探测**答案**,属于适配目录里可读可争的文件,
  不属于生成器。四条运行期路径按既定立场留空
  (`FONTCONFIG_FILE` / `FONTCONFIG_PATH` / `FONTCONFIG_SYSROOT` 是出口)

### 15.3 仍缺的两个,以及形态建议

`fc-case`(240 行,吃 `CaseFolding.txt`)和 `fc-lang`(387 行,吃 281 个
`.orth`)。前者可复刻;后者是本轮单个最大的一块。

**建议的混合形态**:能 `build.mcpp` 的全做,`fclang.h` 作为**唯一例外**签进适配
目录并在文件头写明理由。这违反"不签生成物",但避开重写位图编译器 —— 而把例外
写在文件里、只此一处,比为了纯粹性再花一天更划算。

---

## 16. 沙箱验证的一个盲点(2026-08-30)

补跑新增三个包的沙箱验证时,脚本把一个**已发布一小时**的包报成「找不到」。原因:

```
index: local index af79fd2 (never refreshed)
```

沙箱的 home 是合成的,mcpp 带的是镜像里那份索引快照,**早于被测的包**。而
"刷新索引"正是新用户会做的第一件事。

**所以任何在 `--sandbox` 里做的验证,第一步必须是 `mcpp index update`** ——
否则测的是镜像打包那天的生态,而不是今天的。这与
「本地旧索引快照掩盖描述符错误」那条 是同一类,只是发生在沙箱侧。

---

## 17. 桌面栈补齐:fontconfig、cairo,以及被推翻的两条判据

§15 停在「fontconfig 还差 fc-case 和 fc-lang」。两个都做完了,cairo 也做完了,而
过程中有两条判据被实测推翻——都是本文档自己先前写下的。

### 17.1 判据修正一:决定 fork 难度的是**生成器**,不是行数

| | 源码 | 生成器 | 实际难度 |
|---|---|---|---|
| fontconfig | 26k 行 | **7 个**(python + gperf) | 大 |
| cairo | **104k 行** | **0 个** | 小 |

§13.2 按行数把 cairo 标成「中」、把 fontconfig 标成「中」,并据此排了优先级——排反了。
cairo 的 meson 只出两个产物,`config.h` 和 `cairo-features.h`,两个都是
`configure_file`:那是探测**答案**,属于手写的适配文件,不是生成物。

**新判据**:看 `grep -c 'custom_target\|configure_file'`,并区分「生成代码」与
「记录探测结果」。后者永远是手写,而且应该手写——决定属于可读可争的文件,不属于
生成器。

### 17.2 判据修正二:`build.mcpp` 是 C++ 程序,不是配置

§14.1 已记。这里补一条后果:因为它是完整 C++,**生成器可以比上游更正确**。

- libdisplay-info:上游 python 把 U+00A0 按码点转义成 `\240`(单字节,不是
  UTF-8),`build.mcpp` 按字节转义成 `\302\240`
- fontconfig:上游用 gperf 对 72 个条目做完美哈希,而唯一消费者只读一个字段;
  排序表 + 二分查找语义相同,少一个工具和一遍 C 预处理

### 17.3 fontconfig(mcpp-index#310)

七个生成物全部由 `build.mcpp` 产出,零 python / 零 sh / 零 gperf。两个大的**与
上游逐字节一致**,fork CI 每次重跑上游脚本再 diff:

```
fclang.h  4897 行   281 个 .orth -> charset 位图
fccase.h   368 行   Unicode 大小写折叠
```

**`fclang.h` 第一次 diff 有 2/4897 行不同,原因是 locale collation** ——参考输出
用 `ls *.orth` 生成,UTF-8 locale 下 `ayc.orth` 排在 `ay.orth` 前(比较忽略点号)。
`LC_ALL=C` 后一致。这是 libglvnd `genglmod.sh` 那个坑的第二次撞见,而
`build.mcpp` 用 `std::sort` over `std::string` 即**字节序**,结构性免疫。

### 17.4 cairo(mcpp-index#312)

后端做成 **feature**,`default = ["ft", "fc", "png"]`,**X11 默认关**。上游把每个
后端做成 `get_option()`,等于让发行版替所有人决定一次;索引不能这样,因为合成器
和 X11 应用要的是同一个包的不同构建。

两条实现细节值得记:

- **feature 的 `sources` 必须逐个文件列**。选通按字面条目匹配,glob 不受 feature
  控制——`"*/src/cairo-xlib-*.c"` 会把 X11 后端编进**每一个**消费者。上游自己的
  `cairo_feature_sources` 字典正好是逐条的,照抄即可。
- **验证要看产物,不是 manifest**。fork CI 查 `.o` 里有没有 `XOpenDisplay` /
  `xcb_connect`,有没有 `cairo-xlib-*.o` 被编出来。manifest 写的是意图。

**归档从 47.8 MB 降到 1.8 MB**:cairo 发布物带 61 MB 参考图(`test/`),这个包一个
都不编。裁掉 `test/` 和 `perf/`,同时把「upstream 与发布物一致」检查改为比对**剩下
的树**而不是关掉——那条检查此前已经拦住过一次真实缺口(见 §17.6)。

### 17.5 最贵的一个 bug 是一个 `0`

```c
#define WORDS_BIGENDIAN 0          // 我写的
#ifdef FLOAT_WORDS_BIGENDIAN       // cairo 怎么测(cairoint.h:196)
```

`#ifdef` 对 `0` 一样成立,所以这是在说**大端**。x86-64 上的后果是最坏的那种静默:

- 编过、链过、`cairo_status` 全程 SUCCESS、`cairo_paint` **正常工作**
- 每一条**路径**拿到垃圾定点坐标:`cairo_rectangle(4,4,16,16)` 的
  `path_extents` = `-8.03e+06 … 4.37e+06`,`cairo_in_fill(40,40)` 对界外点返回 1
- `cairo_fill` / `cairo_stroke` 改动 **0 个像素**,一声不吭

查了一小时「是不是缺了扫描转换器 / spans 合成器」。**判据**:上游用 `#ifdef` 测的
宏,只能「定义」或「不定义」,不能定义成 0。

**由此改了测试写法**:除了断言结果,再断言**中间量**。像素断言只会说「描边没画」,
把人引向缺文件;`cairo_path_extents` 直接指出算术错在哪。同类中间量:
`di_edid_get_version` 之于 EDID、`FcLangGetCharSet` 之于 fclang。

### 17.6 一个 compat 包的源码列表就是它的 ABI 承诺

两次撞见,方向相反:

- fontconfig 按上游默认声明 `HAVE_FT_GET_BDF_PROPERTY` → 链接期**八个**未定义引用,
  因为 `compat.freetype` 不编 BDF/Type1 模块 → 关掉这两个探测项
- cairo **无条件**调 `FT_GlyphSlot_Embolden`(无 `HAVE_` 守卫)→ **两个**未定义
  引用,因为 `compat.freetype` 漏了 `ftsynth.c` → 补进 compat.freetype(#311)

**承诺是被消费者发现的,不是被自己的测试发现的**——freetype 的测试成员一直是绿的。

同一轮里,cairo 的 fork CI 抓到另一个完整性缺口:cairo 自带 **14 个 `.gitignore`**,
fork 提交时生效,吞掉了 5 个**在发布 tarball 里存在**的文件。抓到它的正是那条
「upstream 与发布物逐字节一致」——我写它时当成防手改的形式检查。

### 17.7 「干净环境的索引是那天的,不是今天的」——第三次

| 场景 | 症状 | 真因 |
|---|---|---|
| 沙箱验证 | 「包找不到」 | 合成 home 的索引快照早于被测包 |
| 索引测试成员 | 「glob 没匹配到文件」 | store 缓存了旧 tarball |
| **cairo fork CI** | **两个 `FT_GlyphSlot_*` 未定义引用** | **runner 的索引快照早于同日的 freetype 修复** |

三次报错都指向别处,最后一次读起来像 cairo 有 bug。**凡是从零开始的验证——沙箱、
CI、新 subos——第一步必须 `mcpp index update`。** 已加进 cairo 的 fork CI。

这也解释了为什么本地一直绿:开发环境的索引是新的。**本地绿 ≠ 干净环境绿**,差别
恰好是「索引有多旧」。

### 17.8 最终沙箱验证(五个包,已发布索引)

```
===== 5. did anything come from the host? =====
  PASS: the host's copies were present and reachable, and none of them won
===== 5b. libdisplay-info is kind=lib, so it must NOT be a DT_NEEDED =====
  PASS: libdisplay-info's objects were merged in

===== 6. run it =====
  wl_egl_window_create      0x1e3b28c0          客户端 GPU 入口
  wl_cursor_frame           0                   客户端指针
  di_info_get_make          Acer Technologies   EDID + 生成的 PNP 表
  fclang zh-cn              6765 codepoints     语言表完整
  cairo inside=255,255,255 outside=191,128,64   矩形填充内外像素精确
  cairo xlib                off                 feature 默认集生效
  0 failure(s)
RESULT: PASS
```

后两条断言是**专为本轮踩过的坑设的**:`zh-cn` 的码点数会让截断的语言表当场露馅,
而不是很久之后表现为「匹配不到字体」;cairo 的内外两个像素会让字节序 bug 露馅,
而 `cairo_status` 全程 SUCCESS。

### 17.9 桌面栈的当前状态

| 层 | 状态 |
|---|---|
| 渲染链 DRM→GBM→EGL→GLES | ✅ 沙箱像素级 |
| 输入链 udev→evdev/mtdev→libinput→xkb | ✅ 沙箱 |
| 客户端 GPU 路径 / 指针 | ✅ |
| 显示器识别(EDID) | ✅ |
| 字体发现(fontconfig) | ✅ |
| 2D 矢量绘制(cairo) | ✅ |
| **段落排版(pango)** | ⬜ **卡在 glib** |

**wlroots 的闸门已开**:它需要的东西索引里现在全有,做与不做是「要不要」而非
「能不能」。

**pango 是唯一量准后仍需决策的**:57k 行本身不大,但硬依赖 glib,而 glib 是
`glib/` + `gobject/` + `gio/` 三大块 300k+ 行,自己还缺 `pcre2` 和 `libmount`。
按 §17.1 的新判据,它的难点也不在行数——需要先数它的生成器再定。

---

## 18. 八个角度的实现后复核

§6 的表是**设计时**写的。实现之后逐条回看,**八条里有四条被推翻或需要重述**——
把它们留在原样比不写更糟,因为下一个人会照着一张已经不成立的表做决定。

### 18.1 架构 —— ❌ 推翻

> 设计时:「不新建仓,**新增仓数量 = 0**」

实际新建 **五个** fork 仓:`wayland-protocols`、`libevdev`、`libxkbcommon`
(前三个见 §10.2)、`libdisplay-info`、`fontconfig`、`cairo`。

**错在哪**:当时以为「进已有 fork」是可选的组织方式。它不是——**一个 fork 仓对应
一个上游、一个版本**。wayland-protocols 有自己的版本号和发布周期,塞进
mcpplibs/wayland 就等于让两个上游共用一个 tag,那才是真正的架构错误。

**留下的规则**:fork 仓的数量由**上游的数量**决定,不由「想少建几个仓」决定。

### 18.2 稳定性 —— ⚠ 重述

设计时说「风险集中在模块导出与体积,两者都可先验」。体积确实可先验(cairo 47.8MB
→ 1.8MB,§17.4)。模块导出也确实是风险,但**真正咬人的不是它**。

实现期的失败按代价排序,前三名都不在当时的风险清单上:

1. **探测答案错**(§17.5、§17.6)——编过、链过、报 SUCCESS,行为错。三次。
2. **环境陈旧**(§17.7)——沙箱/CI/store 各一次,报错全部指向别处。
3. **上游自己的 `.gitignore`**(§17.6)——fork 少了 5 个发布物文件。

**留下的规则**:风险不在「难写的代码」里,在「写完之后没人检查的断言」里。所以
每个 fork 的 CI 都要有一条**拿产物和上游对照**的检查,而不只是「能编过」。

### 18.3 优雅/简洁 —— ✅ 成立,而且被 feature 机制加强

设计时的「只做三个无 X11 的 GL 库」成立。cairo 把同一个想法做到了更好的形态:
**不是替消费者选,而是让消费者选**——`default = ["ft","fc","png"]`,X11 是
feature(§17.4)。

差别是真实的:「只做无 X11 的库」意味着要 X11 的人没得用;feature 意味着他写一行
就有。

### 18.4 用户体验 —— ✅ 成立,且比预期多一层

`import khronos.glesv2;` 那条成立。多出来的一层是**模块消掉了上游的缺陷**:
libdisplay-info 七个公共头一个 `extern "C"` 都没有,C++ 消费者 `#include` 会
mangle 到链接失败;`import freedesktop.displayinfo;` 把包装做在模块内(§14.2)。

**留下的规则**:模块层不只是「换个写法」,它是**放置适配代码的位置**。

### 18.5 兼容性 —— ❌ 推翻

> 设计时:「全部是新增条目,**不动任何已发布包**」

实际动了三个已发布包:

- `compat.freetype` 补 `ftsynth.c`(#311)——cairo 无条件调它
- `xim:mesa` 改成只声明自己填的路径(xim#733)——加一行 DISCOVERY 造成的回归
- `graphics.consumer_envs` 跳过标量行(xim#735)——同一行造成的第二处回归

**错在哪**:当时把「新增」等同于「无风险」。**新增一个条目会改变现有条目的行为**
——DISCOVERY 表加一行,`declare_subos_env(tag)` 不传 `only` 的调用点就自动继承了
它;新增一个消费者,`compat.freetype` 的源码列表缺口就暴露了。

**留下的规则**:见 §14 的三项检查清单,以及「一个 compat 包的源码列表就是它的
ABI 承诺」(§17.6)。

### 18.6 跨平台 —— ⚠ 重述

设计时只考虑了 CPU 架构(aarch64/ppc64)。实现期真正咬人的跨平台维度是
**编译器与标准库**:

- `wl_shm_create_pool` 是 `static inline`,取地址强制实例化 → GNU ld 经传递
  DT_NEEDED 解析,**lld 不会**(#301)
- `<sstream>` 被 libstdc++ 经 `<fstream>` 传递包含,**libc++ 不会**(#310)

两个都只有 mcpp-index 的 **llvm 腿**抓得到——它没有 sysroot 且用 lld。

**留下的规则**:fork 里任何 `build.mcpp` 或模块包装的改动,推之前先
`mcpp toolchain default llvm` 跑一遍。cairo 的 fork CI 已经把这一步固化。

### 18.7 一致性 —— ⚠ 重述

三条规则(模块命名、生成物签进仓、path 依赖)里,**第二条被推翻**:生成物不再
签进仓,改由 `build.mcpp` 在构建期产出(§14.1)。

这不是风格变更,是消掉了一整类状态:**没有签进仓的生成物,就没有「数据与代码不
一致」这个状态**,也就不需要「重生成再 diff」的 CI 步骤。

另外两条原样成立,并新增一条:**feature 的 `sources` 逐条列,不用 glob**
(§17.4)。

### 18.8 无感升级 —— ⚠ 重述

> 设计时:「全是新增包,无同版本重切 tag 的问题」

同版本重发的问题**换了三种形态出现**:

| 形态 | 后果 |
|---|---|
| tag archive 做 URL | 重切直接打断已发布描述符的 sha256 |
| store 按 `(name, version)` 缓存 | 同版本重发**不重新解压** |
| 删 tag 再建 | release 掉成**草稿**,资产 404 |

三个都指向同一条,已成为本轮的操作规则:**tag 指向历史,资产承载分发,不要动
tag**——把新内容作为 release 资产发布,旧资产原样保留,零窗口(§12.2)。

### 18.9 一句话

八条里**两条推翻**(架构、兼容性)、**四条重述**(稳定性、跨平台、一致性、无感
升级)、**两条成立且被加强**(优雅、用户体验)。

设计时的判断有一半没扛过实现——而这正是「验证要更新到文档」的意义:留下的应该是
**被证伪之后的那一版**。

---

## 19. 合成器闸门与 GObject 栈(2026-08-31)

§18 结尾说 wlroots「是『要不要』而不是『能不能』」。这一轮做了,答案是能 ——
连同 pango 那条线上能做的部分,以及**做不到的那一段的确切边界**。

| 包 | 版本 | 形态 | 为什么 |
|---|---|---|---|
| `wlroots.wlroots` | 0.20.2 | fork | 六个生成器 |
| `compat.pcre2` | 10.44 | 描述符 | 133k 行,**零生成器**(发布包自带 `.generic`/`.dist`) |
| `compat.fribidi` | 1.0.16 | 描述符 | 有八个生成程序,但**输出随发布包一起发** |
| `gnome.glib` / `gobject` / `gmodule` | 2.82.5 | fork | 六个生成器,含 816 行的 `glib-mkenums` |
| `freedesktop.wayland-protocols-*` | 1.49.1 | 补 enum 头 | 上游装、fork 之前没生成 |

**判据再次被证明是「生成器」而不是行数**:pcre2 比 cairo 还大 29k 行,仍然是
描述符;libdisplay-info 两千行是 fork。fribidi 更细一层 —— 它**有**生成器,但
release tarball 里带着七张表的输出,所以没有东西需要跑。

### 19.1 `import wlroots;` 不是便利,是唯一入口

这是本轮最值得记的一条。wlroots 的 121 个公共头**没有一个 `extern "C"`**,而且
其中两个**根本不是合法 C++**:

```c
void wlr_scene_rect_set_color(struct wlr_scene_rect *rect,
                              const float color[static 4]);   /* C99 专有 */
```

g++ 报 `expected primary-expression before 'static'`,而且解析再也没恢复,于是
文件里**后面每一条**声明都被报成「has not been declared」—— 把人引向「是不是
少了 feature 守卫」。另有三个结构体成员叫 `namespace`、`delete`、`class`。

所以 C++ 消费者用任何 `extern "C"` 组合都 include 不了这些头。fork 的做法:

| 上游 C | C++ |
|---|---|
| `[static N]` | `[N]` |
| `wlr_layer_surface_v1::namespace` | `::namespace_` |
| `wlr_input_method_v2::delete` | `::delete_` |

关键字成员用 `#ifdef __cplusplus` 双臂给出,`#else` 一字不改是上游原文 ——
**同一偏移、同一 ABI,一种语言一种拼法**。C++ 拼不出 `namespace` 这个名字,所以
给出 `namespace_` 不是改上游 API,而是它在这一侧唯一存在的形态。

**与 glib 对照可以看出这不是家风。** glib 没有模块:它的 API 是宏重的
(`G_DEFINE_TYPE`、`g_signal_connect` 全是宏),而**宏不跨模块边界**,`import`
会把声明给你、把让声明可用的那一半扣下。形态跟着上游的头长什么样,不跟风格。

### 19.2 模块的两条固有限制

| | |
|---|---|
| 宏不跨模块 | `WLR_HAS_*`、`wl_container_of` 都来自头。`#include <wlr/config.h>` 与 import 并存是安全的 —— 它只有 `#define` |
| **会声明东西的头不能与模块并存** | `<wlr/version.h>` 没有 `extern "C"`,并存会让那三个名字拿到 C++ 链接,而模块里是 C 链接。链接错误是 ``undefined reference to `wlr_version_get_major()'`` —— **括号就是线索**:名字被修饰了 |

### 19.3 四个「看起来成功、其实拿错文件」的失败

本轮代价最高的一类,全部只在 CI 出现、本地四种清理方式都复现不了:

1. **`config.h` 是 C 里最挤的文件名。** wlroots 的 include 路径上有**六个**,
   而 `mcpp::include_dir()`(build 程序发的)排在**所有依赖之后** —— 我们那份是
   59/59。十一个 wlroots 源码读到的是 `compat.libinput` 的,`if (!HAVE_EVENTFD)`
   ——wlroots 把它当**普通 C 表达式**用——报 `HAVE_EVENTFD undeclared`。

2. **清单里的 `include_dirs` 排在最前**,所以生成的头要写进清单点名的目录。
   但 mcpp 在**运行 build 程序之前**就构造好命令行,并且**静默丢弃**尚不存在的
   条目 —— 干净 clone 的第一次构建里,config.h 生成正确然后被无视。
   `include/.gitkeep` 就是为这个提交的。

3. 同样的道理适用于**协议头**。先是用 `#include_next` 让 shim 找到真头,CI 报
   `use of enum 'zwlr_layer_surface_v1_keyboard_interactivity' without previous
   declaration` —— 一个**成功了但拿到错文件**的 include(文件缺失会明说)。改成
   绝对路径后,另一个头又以同样方式失败。最终把**所有生成的头**都放进清单首位
   目录,这一类才根除。

4. **本地绿可能链的是别的库。** `mcpp::link_lib("EGL")` 只发一个**标志**,ninja
   拿不到到 `bin/libEGL.so` 的边;本地能过是因为 mcpp subos 里正好有一份
   `libEGL.so.1`,`ldd` 指着它。lld 在干净树上直接说 `unable to find library
   -lEGL`。

### 19.4 `[feature-deps]` 只对 `kind = "lib"` 有效

实测,而且判据很干脆:

- `kind = "lib"` 的 feature 依赖(libseat、libinput、libudev、libdisplay-info)
  **正常** —— 它们的对象并进本包,压根不需要 `-l`。
- `kind = "shared"` 的(egl、glesv2)**不链接**,报 30 多个 `undefined symbol:
  glActiveTexture / eglMakeCurrent`。

所以 EGL/GLESv2/gbm 移到普通 `[dependencies]`:它既链接又建立 ninja 边。代价是
`default-features = false` 也会构建它们;feature 仍然决定**渲染器源码编不编**
和 `WLR_HAS_GLES2_RENDERER` 说什么,那才是消费者观察得到的部分。

### 19.5 探测宏:两个方向都踩过

§17 记的是「`#ifdef` 测的宏不能写 0」。这轮同时踩到了它和它的反面:

| 文件 | 测法 | 正确写法 |
|---|---|---|
| glib `config.h` | `#ifdef HAVE_ISSETUGID` | **缺席**。写 `0` 让 glib 调了 glibc 没有的 BSD 接口 |
| wlroots `wlr/config.h` | `#if WLR_HAS_DRM_BACKEND` | **总是定义**,0 或 1。漏掉会让 `#if` 静默为假 |
| glib `gmoduleconf.h.in` | `#if (@X@)` | **值**,所以 0 是对的,省略是语法错 |

**测法决定,每一次。** 名字长得像不算数。

还有一对几乎同名的宏:`USE_SYSTEM_PRINTF`(config.h,**选择**)与
`GLIB_USING_SYSTEM_PRINTF`(公共 glibconfig.h,只**报告**)。只设第二个,glib
继续调它自带的 gnulib printf,而那部分根本没编 —— 一页
`undefined reference to _g_gnulib_snprintf`。

### 19.6 包无法导出生成的头(2026-08-31 实测)

两个包的探针,结论干脆:

| | 消费者看得见吗 |
|---|---|
| `mcpp::include_dir()`(build 程序发的) | ❌ **包私有**,消费者报 `No such file or directory` |
| `[build] include_dirs`(清单里的) | ✅ 传播 |

**产物本身就是头的包,不能在构建期生成它们。** 这解释了
`freedesktop.wayland-protocols-*` 为什么把 195 个生成文件签进仓 —— 那不是历史
包袱,是被迫的。§14 的规则对**自用**生成物成立,对**导出**生成物不成立。

1.49.1 就是按这条补的:上游的 meson 会装 `wayland-protocols/<name>-enum.h`,
fork 之前只生成 client/server 两种,而 wlroots 0.20 的**十个公共头**要它们。

### 19.7 ❌ 本节的结论是错的 —— 见 §20

原文写的是「仍然缺的:gio,以及被它挡住的 pango」,理由是:

- gio 的六个生成器里有两个是 **`gdbus-codegen`,8,351 行 Python**;
- **七个** gio 源码 include 它的产物,另有**两个**引用那七个;
- 所以「在 `build.mcpp` 里复刻一个 8.3k 行的代码生成器与消费者的需要不成比例」。

**前两条测量是对的,第三条推不出结论。** 它把两件不同的事混成了一件:

```
复刻这个生成器          ≠          拿到它的输出
```

构建从来不需要那个生成器,只需要 **15,392 行 C**,而那是五个 XML 文件与
codegen 版本的**纯函数**。`gnome.gio` 2.82.5 已经在索引里,pango 没有被挡住。
完整记录见 **§20**。

`vulkan-renderer`(要 glslang)、`x11-backend` / `xwayland`(要 xcb)、
`color-management`(要 lcms2)仍然缺席,但那三条的理由是「依赖不在索引里」,
和本节原来的理由不是一回事 —— 不要把它们和这一条一起引用。

### 19.8 「引用别的包生成的文件」是静默的

§19.3 那四个失败都是「include 成功了但内容不对」。GObject 这条更隐蔽一层:
**源码条目匹配不到任何文件,不会报错。**

`gnome.gobject` 的 `sources` 里写过 `../include/gobject/glib-enumtypes.c` ——
那是 **glib 的** build 程序产出的文件。单独用 gobject 或单独用 gmodule 都正常;
一个消费者**同时点名两个**时:

```
undefined reference to `g_unicode_script_get_type'
```

因为 gobject 和 gmodule 各自 path 依赖 `../glib`,而 mcpp 把两个解析成了**一个**
包 —— 于是只有其中一个成员的 `include/` 被写过,另一个的源码条目**匹配到零个
文件**。不是「file not found」:那个 .o 压根没出现在 ninja 里。

> **一个包不能命名另一个包的 build 程序产出的文件。**

改法:生成器移到 `mcpp/common/generators.h`,每个成员三十行的 `build.mcpp` 调
自己需要的那几个,写进**自己的** `include/`。共享的四项(config.h、
glibconfig.h、gversionmacros.h、glib-visibility.h)由三个成员各生成一份 ——
生成器是确定性的,同输入同字节,三份不会分歧。

代价是每个成员各自重建一次 glib,CI 时间约三倍。换来的是「成员自给自足」这个
性质,而它挡住的那个 bug 只有消费者能碰到。

### 19.9 path 依赖的兄弟不能被消费者再点名

同一个形态在 wayland-protocols 上已经出现过,glib 这里又一次:

```
error: dependency 'gnome.glib' is requested as both a version dep
       (by 'compositor-stack') and a path dep (by 'gnome.gmodule@2.82.5')
```

`gobject`/`gmodule` 用 workspace path 依赖拉 `glib`,所以消费者**只点名那两个**,
`glib` 传递而来。两个包的描述符和 README 都写了这条 —— 它是消费者第一次用就会
撞上的。

### 19.10 沙箱闭环:六个包的实测结果

`xlings subos use eco-2026-8-31-x --sandbox` —— 合成 home、mcpp 与索引与全部包
从零拉取,而 `/usr` 仍是宿主的(宿主自带 libglib-2.0/libgobject-2.0/libpcre2-8/
libfribidi,所以「用的是我们这份」是个可以为假的判断):

```
host has  /usr/lib/x86_64-linux-gnu/libglib-2.0.so.0
host has  /usr/lib/x86_64-linux-gnu/libgobject-2.0.so.0
host has  /usr/lib/x86_64-linux-gnu/libpcre2-8.so.0
host has  /usr/lib/x86_64-linux-gnu/libfribidi.so.0
…
PASS: only the ecosystem's own libraries, plus the C runtime

wlroots 0.20.2      drm=1 libinput=1 session=1 gles2=1 gbm=1
                    x11=0 vulkan=0 xwayland=0
                    wlr_scene_rect_create 走被改写的 [static 4],调用成功
                    pnp ACR = Acer Technologies   ← 钉版 hwdata v0.410
pcre2 10.44         \p{Han} 编译通过 → SUPPORT_UNICODE 确实开着
fribidi 1.0.16      希伯来段落解析为 RTL;'(' 镜像为 ')'
glib 2.82.5         GRegex 经 pcre2 匹配 Han
                    g_utf8_strup(straße) = STRASSE
gobject             G_UNICODE_SCRIPT_HAN,nick "han"
gmodule             dl loader;g_module_build_path = /opt/plug/libdemo.so

0 failure(s)   RESULT: PASS
```

加载器解析到的**全部**是 `<project>/target/…` 或生态的 xpkgs —— libEGL、
libGLESv2、libwayland-client/server、libdrm、libudev、libgbm、libffi 无一来自
`/usr/lib`,而宿主那四个同名库是**存在且可达**的。

⚠️ 脚本自己也错过两次,两次都值得记:

**一、`ldd` 里的解释器行。** 第 5 步「有没有东西来自宿主」用
`grep '=> /(usr|lib)'`,而 `ldd` 会打印

```
/…/xim-x-glibc/…/ld-linux-x86-64.so.2 => /lib64/ld-linux-x86-64.so.2
```

—— 左边是生态的,右边是**内核写死的解释器路径**,任何包都替换不了也不该替换。
匹配到它,就会在一次「每个真实依赖都来自生态」的运行上报告「有宿主库」。

**二、转义写坏的正则。** `"^\\\\p{Han}+$"` 在 C++ 里是字面反斜杠加 `p`,
GRegex 当然不匹配汉字 —— 断言**正确地失败了**。

两条合起来是同一句:**判据本身也要能被证伪一次**,否则分不清「它在检查」和
「它在点头」。

---

## 20. gio:一次被推翻的「不成比例」判断(2026-08-31)

§19.7 说 gio 缺席,理由是 `gdbus-codegen` 太大不值得复刻。**这条判断是错的**,
本节记录它错在哪、改完之后学到了什么。原节已就地标注 ❌ 并指向这里。

### 20.1 错在把「复刻生成器」当成了「拿到输出」

```
复刻这个生成器          ≠          拿到它的输出
```

构建需要的是 **15,392 行 C**,而它是**五个 XML 文件与 codegen 版本的纯函数**
—— 没有 target、没有 host、没有 locale 进入其中。所以:

1. `mcpp/tools/gengdbus.sh` 用上游 `gio/meson.build:238` 与 `:254` 的**原参数**
   生成一次;
2. 产物提交进 `mcpp/generated/`;
3. **CI 在另一台机器、另一个 Python 版本上重新生成并 `git diff --exit-code`**。

第 3 步是全部论证所在。**提交进仓库的生成物有一个构建永远看不见的失败模式:
它可以停止匹配自己的输入,而且照样能编译。** 有 diff,「checked in」才不等于
「stale」。

这正是 `freedesktop.wayland-protocols-*` 已经在用的形态(195 个生成文件),
而且在那里是**被迫的** —— 产物本身就是头文件,包无法在构建期导出头(§19.6)。
在 gio 这里并不被迫,它只是拿到那些代码最便宜的办法。

> 索引里已有先例,却因为「生成器太大」就否掉了整个包 —— 判据用错了对象:
> **要衡量的是产物能不能预先算出来,不是生成器有多大。**

### 20.2 脚本必须在树外运行(不是整洁,是硬约束)

`gengdbus.sh` 把 codegen 包**复制到临时目录**再跑。两样东西会写进 `upstream/`:

| | |
|---|---|
| `codegen/config.py` | 它本身就是一个 `configure_file`,tarball 里只有 `.in` |
| `codegen/__pycache__/` | CPython import 时无条件写 |

而 `upstream/ is the release tarball, unmodified` 是一个 CI job。原地跑就会踩它。
CI 里因此有第二步断言:跑完 `git diff --exit-code -- upstream` 且 `find` 不到
这两样东西。

### 20.3 ⭐ 同一个生成器的几个输出是**独立失败**的 —— 已发货的缺陷

把 `glib-mkenums` 从 gobject 的 4 个 enum 扩到 gio 的 82 个,逼着我去读真正的
算法。读完发现:**mkenums 有两个前缀,来源不同。**

| | 取自 | 决定 |
|---|---|---|
| `enum_prefix` | **枚举成员**(`G_UNICODE_`) | nick |
| `@ENUMPREFIX@` | **类型名**(`GUnicodeType` → `G`) | 宏名 |

原来的实现用第一个当了两个用。结果 `gnome.gobject 2.82.5` 发出去的是:

```
G_UNICODE_TYPE_TYPE          上游是  G_TYPE_UNICODE_TYPE
G_UNICODE_BREAK_TYPE_TYPE            G_TYPE_UNICODE_BREAK_TYPE
G_UNICODE_SCRIPT_TYPE_...            G_TYPE_UNICODE_SCRIPT
G_NORMALIZE_TYPE_MODE                G_TYPE_NORMALIZE_MODE
```

**每一个函数名都是对的**(`g_unicode_type_get_type`),所以它编译通过、链接通过、
并且通过了我自己写的测试 —— 那个测试检查了**函数**和**nick**,从没检查过**宏**。

推广出来的一条:

> **一个生成器有多个互相独立的输出;测了其中一个,不构成对其余的证据。**

修法是让判据能分辨:CI 现在**分开**检查宏名、nick、以及 enum/flags 的归类;
索引里的 gobject 示例加了一条 `G_TYPE_UNICODE_TYPE == g_unicode_type_get_type()`
—— 宏拼错就是编译错误,这是唯一能识破旧 tarball 的探针。

顺带印证了 memory 里那条:**「绿 CI ≠ 被验证」**,以及**判据本身要被证伪一次**。

### 20.4 annotation 是唯一判据,两个方向都会错

gio 用 `/*< flags >*/` 7 次、`/*< nick=… >*/` 17 次、`/*< prefix=… >*/` 1 次 ——
但也用 `/*< private >*/`、`/*< public >*/`、`/*< protected >*/` **144 次**,
那些是给 **struct 成员**看的 GTK-DOC 注解,对 mkenums 没有意义。

- 往一个方向错:**读所有 `/*< … >*/`** → 静默丢掉枚举成员。
- 往另一个方向错:**按类型名猜** → `GConverterFlags` 没有 `/*< flags >*/`,
  上游用 `g_enum_register_static` 注册它。按名字猜就和上游 ABI 不一致。

nick 是公开 API(`g_flags_get_value_by_nick` 读它):`G_CONVERTER_NO_FLAGS`
推导出来是 `"no-flags"`,上游写的是 `"none"`。

另一个扫描器坑:`} GTlsRehandshakeMode GIO_DEPRECATED_TYPE_IN_2_60;` ——
取 `}` 之后**整段**当类型名,会生成
`_g_i_o__d_e_p_r_e_c_a_t_e_d__t_y_p_e__i_n_2_60_get_type`。只取第一个标识符。

**验证方式**:生成的 `gioenumtypes.h` 的 82 个 `#define G_TYPE_*` 与系统
`/usr/include/glib-2.0/gio/gioenumtypes.h` 逐名相同;82 个 getter 全部存在于
发行版 `libgio-2.0.so.0` 的 ABI 里。

### 20.5 gio 有四类输入,其中三类缺了会**静默降级**

| 输入 | 缺了会怎样 |
|---|---|
| `gio/*.c` | undefined reference —— 链接器会抓。最便宜的一类 |
| `gio/xdgmime/` | `g_content_type_guess` 对一切回答 `application/octet-stream` |
| `gio/inotify/` | 文件监视**静默**退回轮询实现 |
| `subprojects/gvdb/` | GResource 与 GSettings 的 schema 读取根本走不到 |
| `mcpp/generated/` | 照样编译;portal 调用只在 Flatpak 沙箱里才失败 |

所以测试按名字断言每一类,而不是「它构建了」:

- inotify:读回 `GFileMonitor` 的**类型名**是不是 `GInotifyFileMonitor` ——
  这是轮询实现和它唯一能区分的地方;
- gvdb:拿一段**肯定不是 gvdb** 的字节给 `g_resource_new_from_data`,要求它
  **干净地拒绝**(返回 NULL 且 GError 有值)—— 那个答案只可能来自
  `gvdb_table_new_from_bytes`;
- xdgmime:只断言「答得出来」和两个转换互为逆 —— **不断言具体 MIME**,那取决
  于 runner 有没有 `/usr/share/mime`,断言它就是在检查 runner 而不是这个构建。

`-DXDG_PREFIX=_gio_xdg` 是**必须**的:xdgmime 的头把每个 `xdg_mime_*` 宏改名成
`_gio_xdg_mime_*`,而 `gcontenttype.c` 调的是不带前缀的写法 —— 两边看到的值必须
一致,否则调用和定义是两个不同的符号。

### 20.6 排除模式「看起来完整」的两种方式

```toml
"!../../upstream/gio/gwin32*.c",      # 漏了 giowin32-private.c、gmemorymonitorwin32.c
"!../../upstream/gio/gosxappinfo.c",  # 上游是 .m,这条什么都没匹配到
```

第一种**编译期报错**(`unknown type name 'gchar'`),第二种**完全静默** ——
和 §19.8 是同一类:**匹配不到任何文件的条目不会报错**。现在两类都在注释里写明。

### 20.7 版本形态:包版本就是上游版本,不加后缀

一度把它写成 `2.82.5.1`(「上游 2.82.5,fork 修订 1」)。**这是错的**,索引的
约定是**包版本与上游版本对齐**:

- fork 变了而上游没变时,**原地重切 tag**,描述符换新的 `sha256`;
- CN 镜像那边 gitcode **不允许替换同名 asset**,所以每份更正过的 tarball 需要
  一个新的**容器 tag**(`2.82.5-3`),而**包版本不动**。

代价要写明白:**store 按 `(name, version)` 索引**,已经解开过 `2.82.5` 的机器
会留着旧的那份。这次的探针(§20.3 那条宏断言)正是用来识破它的 ——
旧 tarball 上那行是编译错误。

### 20.8 结果

| | |
|---|---|
| `gnome.gio` 2.82.5 | 815 个对象,35 项断言,gcc 16.1 + llvm 22.1 双绿 |
| `gnome.gobject` 2.82.5 | 四个宏名更正,并加了识破旧 tarball 的探针 |
| fork CI | 四个 job:两条工具链 + `mcpp/generated/` 重新生成并 diff + `upstream/` 未改 |
| 消费者形态 | 一个同时点名 gobject、gmodule、gio 的程序,`G_TYPE_LIST_MODEL` 是活的接口 |

**pango 的闸门开了**:它的五个依赖(gio、gobject、harfbuzz、fribidi、
fontconfig、cairo)全部在索引里。

---

## 21. namespace 是契约:gnome.* 补上 import(2026-08-31)

### 21.1 判据不是我原来以为的那个

索引里 **namespace 决定消费形态**:

| | |
|---|---|
| `compat.xxx` | 按**头文件**消费,包不提供模块 |
| `<归属方>.xxx` | 包**提供 `import`** |

全索引核对成立:`freedesktop.cairo` 导出 544 个名字、`wlroots.wlroots` 986、
`freedesktop.libdisplay-info` 206、`freedesktop.wayland` 有
`import freedesktop.wayland.client;`、`freedesktop.fontconfig` 有
`src/fontconfig.cppm`;而 `compat.harfbuzz`/`freetype`/`pcre2`/`fribidi` 都只有
头文件。**`gnome.*` 四个是当时唯一的违例** —— 用了归属 namespace 却没有模块。

我原来在描述符里写的是「没有模块,因为 API 宏化」。**观察对,结论错**:宏确实
过不了模块边界,但那不代表模块无意义 —— 它仍然交付 2,732 个声明,而 gio 的函数
API 根本不需要宏。已就地标 ❌ 并改正。

### 21.2 两条路不能混用(这一条决定了形态)

```
import gnome.gio;        // 模块路线
#include <gio/gio.h>     // 头文件路线
```

同一个 TU 两条都走,会经由**两条路径**到达 `<time.h>` —— 一次через模块的 global
fragment,一次直接 —— 于是**同一个文件里的同一个 `struct tm` 变成两个实体**:

```
error: conflicting declaration 'struct tm'
note: previous declaration as 'struct tm'   (of module gnome.glib)
```

所以消费者**二选一**,而选哪条由**宏**决定:模块带不了宏,glib 的宏占 API 的一半
(glib 1,337 `#define` 对 1,312 声明;gio 1,679 对 1,753)。用
`G_DEFINE_TYPE`/`G_OBJECT`/`G_TYPE_*` 的代码走头文件;用函数 API 的(gio 的大
多数)走模块,一个头都不用包。**每个成员因此各带两个测试**。

### 21.3 ❌ 两种更省事的形态,都实测否掉了

| 形态 | 为什么不行 |
|---|---|
| 宏侧头文件(抽出全部 1,928 个 `#define`,自身不 include 任何东西) | 小范围可行 —— 探针编译、链接、运行都过。**不 scale**:glib 的版本/弃用机制是**预处理器有状态**的,顺序由**include 图**决定而不是文件列表。摊平后依次得到「`#ifdef` 两个分支都被发出、后者静默重定义前者」→「`#error "GLIB_VERSION_MIN_REQUIRED must be <= GLIB_VERSION_CUR_STABLE"`」→「`missing binary operator before token 'GLIB_DEPRECATED_MACRO'`」。**每修一个就冒出下一个,因为摊平本身才是错的**;忠实投影等于写半个预处理器 |
| `export import <glib-object.h>;`(具名模块转出 header unit) | 声明**确实**全部带过去了(实测),但导入方**拿不到宏**。所以导出清单无论如何都得列 |

### 21.4 ⭐ 生成器四次「静默漏名」—— 全部由消费者或另一条工具链发现

每一次产出的包装体**都能编译**:

| | 发生了什么 |
|---|---|
| `= '{'` | `G_VARIANT_CLASS_DICT_ENTRY = '{'` 是**字符字面量里的花括号**。typedef 读取器把它计入,再也没配平,于是**吞掉了 `gvariant.h` 剩下的全部内容** —— 每个 `g_variant_*` 函数消失,而另外 1,853 个名字让模块看起来很完整 |
| `G_DECLARE_INTERFACE` | 展开成 typedef **和** `_get_type`,文本扫描器两个都看不见。牺牲者是 `GListModel`、`GListStore`、`g_list_model_get_type` —— **正是 pango 等的那几个** |
| `<glibconfig.h>` | 拼写不带 `glib/` 前缀,所以按 umbrella 的 `<glib/…>` 行推导头文件集合看不到它 —— 而 `gsize`/`gssize` 正是在那里 typedef 的 |
| `void (g_free) (…)` | glib 把名字**加括号**以防宏展开,声明符因此位于括号深度 1;深度 0 规则丢掉了 `g_free`、`g_string_free` 和 GVariant 的构造函数 |

还有一次结构性的:**注释剥离与 typedef 读取器是两个读者**,后者有自己的
`getline` 循环、从没见过前者,于是 `typedef enum { … } GUnicodeScript;` 里的
脚本代码注释(`/* Geor */`)变成了导出名。**一个流上两个读者就是 bug**,改成
「先整文件剥一次注释」才是修法 —— 和 §20.6 的排除模式、以及 gio 扫描器那次
是同一类。

### 21.5 ⭐⭐ 只有两条工具链能看见的一条

生成器一度只导出 enum 的 typedef,依据是一次 mcpp 端到端实跑:
`GModuleFlags f = G_MODULE_BIND_LAZY;` 编译并运行了。

**它是在 GCC 上编译的。** clang 拒绝同一个文件:

```
error: use of undeclared identifier 'G_MODULE_BIND_LAZY'
error: use of undeclared identifier 'G_ZLIB_COMPRESSOR_FORMAT_ZLIB'
error: use of undeclared identifier 'G_UNICODE_OTHER_LETTER'
```

—— 因为 using 声明命名一个枚举**不引入它的枚举量**,GCC 的可达性是宽松解读。
现在每个枚举量都按名导出。

> **这是本 fork 里「CI 跑两条工具链」最有力的一条论据**:单条工具链会把这个
> 判成 done。

### 21.6 结果

| 模块 | 导出 |
|---|---|
| `gnome.glib` | 2,732 |
| `gnome.gobject` | 495 · 转出 `gnome.glib` |
| `gnome.gmodule` | 20 · 转出 `gnome.glib` |
| `gnome.gio` | 2,850 · 转出全部三个 |

转出**不是便利**:glib 是 workspace **path** 依赖,消费者再点名它就会得到
`requested as both a version dep and a path dep`。所以 `import gnome.gio;`
必须和 `#include <gio/gio.h>` 一样完整 —— 这一条也是先以失败出现的
(`'GQuark' was not declared in this scope`,消费者什么都没做错)。

CI 加了导出数下限(glib ≥1900、gio ≥2400)、pango 那三个符号按名断言、一个
枚举量、以及转出链。**塌陷是静默的,所以必须有东西去数。**
