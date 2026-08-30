# mcpp 图形栈:从「能跑通」到「能开发」的覆盖面设计

Date: 2026-08-30 · 前置:[`2026-08-30-gbm-cross-repo-closed-loop-plan.md`](2026-08-30-gbm-cross-repo-closed-loop-plan.md) §19/§20 · 状态:待 review

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

| 角度 | 评估 |
|---|---|
| **架构** | G1 不新建仓,复用 mcpplibs/libglvnd 已有的 `mcpp/generated/` 与 path 依赖机制;G3 复用 mcpplibs/wayland 的 scanner。**新增仓数量 = 0** |
| **稳定性** | 四张生成表已实跑;CI 的 diff 守卫扩四行即可。风险集中在 G1b(模块导出)与 G3(体积),两者都可先验 |
| **优雅/简洁** | 只做三个无 X11 的 GL 库,不碰 GLX/GL —— 覆盖合成器的全部需要,且不把 X11 拖进任何消费者 |
| **用户体验** | 合成器作者的 `mcpp.toml` 从「缺渲染链」变成可写;`import khronos.glesv2;` 与既有命名一致 |
| **兼容性** | 全部是新增条目,不动任何已发布包。唯一的行为变更是 G2a,而它修的是「静默落到软件渲染」 |
| **跨平台** | GL 家族的 per-arch entry stub 沿用 `build.mcpp` 里已有的 `target_arch()` 选择,aarch64/ppc64 由构造成立;pixman 的 SIMD 自门控,不需要额外机制 |
| **一致性** | 模块命名(khronos.*)、生成物签进仓、path 依赖三条规则原样复用,不引入新范式 |
| **无感升级** | 全是新增包,无同版本重切 tag 的问题(那正是上一轮的教训) |

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

### 10.10 仍未做

- ~~G4b `libxkbcommon`~~ **已做**(fork,bison parser 预生成)。它需要的数据集见 §10.9:
  属于生态,不属于这里。
- ~~G5 `libinput`~~ **描述符已做**;测试成员待本 PR 合并、`freedesktop.libevdev` 发布
  后接上 —— 它同时需要 `compat.*` 和 `freedesktop.*` 两个 namespace 指向同一个
  checkout,而成员级 `[indices]` 是替换而非合并。
- ~~G6 `libudev` / `libseat`~~ **已做**,而且没有碰 systemd:libudev 用
  **libudev-zero**(三个实现里唯一既活着又可独立分发的),libseat 只开 seatd 与
  builtin 后端。两者的代价都在描述符里点名了。
- **xkeyboard-config**:见 §10.9,应进 xim-pkgindex。

前两条是普通工作量;G6 是需要决策的。合成器可以在「已有 DRM master」的前提下开发
(从 TTY 直接启动、或 `SEATD_SOCK`),把 session 管理留到最后。
