# GBM 闭环:mcpp / xim-pkgindex / mcpp-index 跨仓方案

Date: 2026-08-30 · 起因:`compat.libgbm`(mcpp-index PR #281)· 状态:待 review

## 怎么读这份文档

它记录了**三轮修正**,后面的推翻前面的。**结论以最后一轮为准**,前面保留是为了记录
被否掉的推理——因为每一次被否,否掉它的都是一次实测,而那些实测本身是资产。

| 想知道 | 看哪节 | 注意 |
|---|---|---|
| **最终结论与交付** | §12(实现结果)、§13(状态)、§14(要不要做 mesa 包) | 权威 |
| 为什么 `compat.libgbm` 该独立存在 | §3、§10.1 | 理由换过三次,结论没变 |
| 任务拆分与依赖 | §11 | |
| mcpp 侧该怎么修 | **§12.1** | ⚠ §2 的 C2(B1/B2)与 §8 的 B3 **都已作废** |
| 实测证据 | §1、§12.3、§12.4 | |

**唯一反复改的是 mcpp 侧的形态**(B1 → B3 → 「装到全局 scope 就够了」),因为那是唯一
一处我没有一开始就去读源码 / 做实验的部分。理由被换掉三次而结论不变的那几条,才是稳的。

## TL;DR

让 `gbm_create_device()` 在 mcpp 工程里能用,**不需要新机制**。所需的机制三层全都已经存在
并且已经在跑;缺的是**两个具体的接线点**,分别在两个仓:

| # | 缺什么 | 在哪个仓 | 规模 |
|---|---|---|---|
| **R1** | `GBM_BACKENDS_PATH` 不在 graphics 的 `DISCOVERY` 表里 | xim-pkgindex | 一个常量 + 一行表项 + 一个照抄 `declare_dri` 的函数 |
| **R2** | 默认 runtime selection 读的是**工具链 subos**,而项目的 `xim:` 依赖声明在**项目 subos** | mcpp | 见 §8/§9:拆成 R2a/R2b/R2c,形态是**分层继承 + 首次构建自动供给** |

R2 **不是 gbm 专属的**:同一条线上 `LIBGL_DRIVERS_PATH` 和 `__EGL_VENDOR_LIBRARY_DIRS`
也没到进程,也就是说**任何 mcpp 构建的 GL 程序都找不到 DRI 驱动**。gbm 只是让它显形。

R1 + R2 落地后,`compat.libgbm` 里的 constructor 与后端 farm **全部删除**,退化成一个
只有「头 + `-lgbm`」的薄壳。

> **第二轮 review 修正(§8)**:R2 应拆成 R2a/R2b/R2c 三条,且 mcpp 侧正确形态是
> **分层继承(B3)** —— 工具链 subos 作基座、项目 subos 作叠加层 —— 而不是原文建议的
> B1(只合 env)或 B2(整体切换)。实测:项目 subos **缺 `libgcc_s` / `libstdc++`**,
> 不是工具链 subos 的超集,所以 B2 会回退;而 B1 只修运行期、不修构建期。
> 另外实测确认:今天**唯一**能把 xim 层引进 mcpp 工程的东西就是 compat 包的
> `xpm.deps.runtime`(`[xlings] deps` 只物化不供给、`[xlings] subos` 不能自举)。
>
> **第三轮(§9/§10)**:R2b 的修法是**首次构建自动供给**,复用工具链首次运行同款流程;
> R2a 降级为「供给先于选择」的顺序约束。并且修正了一处预期 —— 即便三条全修完,
> `compat.libgbm` **也不会消失**,因为库→库的**传递依赖**只能靠包来表达,
> 不能靠消费者的 `[xlings] deps`。

---

## 1. 实测证据(全部可复现)

### 1.1 机制在,但没接上

一个只依赖 `compat.libgbm` 的独立工程,`mcpp run` 打印自己的环境:

```
LIBGL_DRIVERS_PATH           = <unset>
__EGL_VENDOR_LIBRARY_DIRS    = <unset>
XDG_DATA_DIRS                = /usr/share/ubuntu:/usr/share/gnome:/usr/local/share/:…   ← 宿主原样
GBM_BACKENDS_PATH            = …/compat-x-libgbm/…/mcpp_generated/libgbm/lib/gbm  ← 仅来自本包 constructor
```

同一个工程,`mcpp.toml` 加上 `[xlings] subos = "_"` 之后:

```
LIBGL_DRIVERS_PATH           = …/envprobe/.mcpp/.xlings/subos/_/usr/lib/dri            ✔
__EGL_VENDOR_LIBRARY_DIRS    = …/envprobe/.mcpp/.xlings/subos/_/share/glvnd/egl_vendor.d ✔
XDG_DATA_DIRS                = …/subos/_/share:/usr/share/ubuntu:…                      ✔ prepend 合并正确
```

**结论:`${subosdir}` 展开、`prepend` 语义、注入子进程 —— 整条链路都是好的。**
它只是默认情况下指向了一个空表。

### 1.2 两个 subos,声明在一个、读的是另一个

| subos | `.xlings.json` 的 `envs` | 谁写的 | 谁读的 |
|---|---|---|---|
| `<xlingsHome>/subos/default` | **`{}`** | 工具链安装(gcc/glibc) | **mcpp 默认读这个** |
| `<proj>/.mcpp/.xlings/subos/_` | mesa@25.0.7.2 的 3 条 `prepend` | 项目的 `xim:` 依赖 | 只有显式 `[xlings] subos` 时才读 |

项目 subos 的实际内容:

```json
"envs": { "mesa@25.0.7.2": [
  { "op": "prepend", "var": "LIBGL_DRIVERS_PATH",        "value": "${subosdir}/usr/lib/dri" },
  { "op": "prepend", "var": "__EGL_VENDOR_LIBRARY_DIRS", "value": "${subosdir}/share/glvnd/egl_vendor.d" },
  { "op": "prepend", "var": "XDG_DATA_DIRS",             "value": "${subosdir}/share" }
] }
```

`GBM_BACKENDS_PATH` 不在其中 —— 这就是 **R1**。

### 1.3 R2 的代码位置

`mcpp/src/platform/xlings/runtime_binding.cppm`:

```cpp
std::filesystem::path subos_path(const RuntimeSelection& selection,
                                 const GlobalConfig& cfg) {
    if (selection.mode == Mode::McppDefault || selection.subosName == "default")
        return cfg.xlingsHome() / "subos" / "default";          // ← envs 是 {}
    return selection.ownerRoot / ".mcpp" / ".xlings" / "subos"
         / selection.subosName;                                  // ← 有 mesa 的声明
}
```

`select_runtime()` 只在 `owner.xlings.subosDeclared` 为真时走第二个分支。
普通工程不写 `[xlings] subos`,于是永远读第一个。

mcpp 侧其余部分**都是对的**,不需要动:

- `subos_info.cppm` 已经把 `envs` 解析成 `EnvDecl{var, op, value}`;
- `runtime_binding.cppm:440` 把它收进 `binding.environment`;
- `execute.cppm` 的 `compute_subos_env()`(mcpp#352 的修复)已经把它注入 run/test 子进程;
- `binding.environment` 已经参与 `contractHash`,所以声明变化会正确地让快取失效。

一句话:**mcpp#352 修好了「怎么注入」,没修「从哪读」。**

---

## 2. 三仓改动

### C1 — xim-pkgindex:把 GBM 加进 discovery 层

`libs/graphics.lua`。GBM 后端与 DRI 驱动是**同一类东西**(按路径 `dlopen`、不是链接目标),
所以照抄 `declare_dri` 而不是走 `sysroot.declare_libs` —— 后者会把它们摊进 `<subos>/lib`,
也就是**链接目录**,这一点 `declare_dri` 的注释已经论证过了。

```lua
-- 1) 常量,与 DRI_DIR / EGL_VENDOR_DIR 并列
graphics.GBM_DIR = "usr/lib/gbm"

-- 2) DISCOVERY 增加一行
local DISCOVERY = {
    { var = "LIBGL_DRIVERS_PATH",        rel = graphics.DRI_DIR },
    { var = "__EGL_VENDOR_LIBRARY_DIRS", rel = graphics.EGL_VENDOR_DIR },
    { var = "XDG_DATA_DIRS",             rel = graphics.SHARE_DIR },
+   { var = "GBM_BACKENDS_PATH",         rel = graphics.GBM_DIR },
}

-- 3) declare_dri 的镜像
function graphics.declare_gbm(install_dir, rel_dir, tag)
    if not xvm.files then return false end
    if not os.isdir(path.join(install_dir, rel_dir)) then
        log.warn("no %s in this payload -- GBM_BACKENDS_PATH would point at an "
                 .. "empty directory and gbm_create_device would find no backend",
                 rel_dir)
        return false
    end
    xvm.files{ src = rel_dir, dst = graphics.GBM_DIR, binding = tag }
    return true
end
```

`pkgs/m/mesa.lua` 的 `config()`,紧挨现有那几行:

```lua
    graphics.declare_dri(dir, "lib/dri", tag)
+   graphics.declare_gbm(dir, "lib/gbm", tag)
    graphics.declare_egl_vendor(dir, "share/glvnd/egl_vendor.d/50_mesa.json", tag)
```

`consumer_envs()` / `declare_subos_env()` 都是从 `DISCOVERY` 生成的,所以 S2(xvm shim)
与 S3(subos shell)**自动**跟着获得 `GBM_BACKENDS_PATH`,无需再改。

**单独 C1 就能修好 xlings 侧的消费者**(godot 这类走 xvm shim 的),与 mcpp 无关。

> 根因备注:`xim-x-mesa` 是以 `--prefix=/usr` 构建的,`gbm.pc` 里写着
> `gbmbackendspath=/usr/lib/gbm`,这个路径被编译进 `libgbm.so`。payload 重定位之后它必然
> 是错的。DRI/EGL 早就用环境变量兜住了,GBM 只是没人补。
> 另一条路是让 xlings-res 用 `-Dgbm-backends-path=` 重建 mesa,但那要求构建时就知道
> 重定位后的绝对路径(含版本号),不如 discovery 层稳。**建议走 C1,不动构建。**

### C2 — mcpp:让默认选择也能读到项目 subos 的声明

> **⚠ 本节已被第 8 节「深度自我 review」推翻。** 下面的 B1/B2 是一个假二分,正确的形态是
> **分层继承**(B3)。保留原文是为了记录被否掉的推理,新方案见 §8。

两个方案,~~建议 B1~~。

#### B1(小,建议):只合并 env,不动其他

保持 runtime binding 仍旧绑在工具链 subos(sysroot / libc / loader 全部不变),
**额外**读取 `<ownerRoot>/.mcpp/.xlings/subos/_/.xlings.json` 的 `envs`,
合并进 `binding.environment`。

- 影响面只有 `binding.environment` 一个字段;
- 它**已经**参与 `contractHash`,快取失效天然正确;
- `resolve_env()` 的 `${subosdir}` 必须按**声明来源的那个 subos** 展开,不是 binding 的
  `subosDir` —— 这是 B1 唯一需要小心的点,签名要带上来源目录;
- 语义清楚:「工具链从工具链 subos 来,项目的依赖声明从项目 subos 来」。

#### B2(大):默认选择直接切到项目 subos

即 `select_runtime()` 在未声明 `[xlings] subos` 且 `<ownerRoot>/.mcpp/.xlings/subos/_`
存在时,选它。等价于把实测 1.1 里手写的 `subos = "_"` 变成默认。

- 好处:一个改动,env / sysroot / 库搜索全部统一到项目视图,概念最干净;
- 代价:`subos_path()` 的结果同时决定 sysroot、libc、loader、搜索目录 —— 爆炸半径大得多,
  且会让所有既有工程的 fingerprint 变化(实测确实触发 full rebuild)。

**建议 B1 先落地修复现象,B2 作为后续的架构统一单独评估。**

#### 无论哪个方案都要补的回归测试

一个依赖 `xim:mesa` 的最小工程,`mcpp run` 断言 `LIBGL_DRIVERS_PATH` 非空且指向
`<subos>/usr/lib/dri`。**这条测试今天就会红**,正是 R2 的证据。

### C3 — mcpp-index:`compat.libgbm` 退化为薄壳

C1 + C2 落地后删掉:

- `mcpp_generated/gbm_backends.c` 整个 TU(constructor + `mcpp_gbm_backends_dir` +
  `mcpp_gbm_use_sibling_backends`),
- `install()` 里的后端 farm(`lib/gbm/` 那部分),
- `mcpp_gbm.h`,
- `tests/gbm.cpp` 中与 constructor 有关的断言。

保留:

- `install()` 从 `system.subos_sysrootdir()` 取 `libgbm.so*` 与 `gbm.h` 的 farm,
- `include_dirs` / `ldflags = {"-lgbm"}` / `runtime.{library_dirs, link_library_dirs}`,
- `deps.runtime = { "xim:mesa" }`,
- **`tests/stock_usage.cpp` 原样保留** —— 它只 include 上游 `<gbm.h>`,C1+C2 之后它断言的
  就不再是 constructor 而是**整条闭环**,是最有价值的那条回归。

**过渡期**:C1/C2 未落地之前,constructor 是唯一能让 mcpp 消费者用上 gbm 的东西
(见 1.1 的表)。它应当保留,但在描述符里写明删除条件。

---

## 3. 为什么 `compat.libgbm` 仍然应该独立存在

这一节回答「要不要干脆不做这个包」。结论:**要做,而且独立成包是对的,但必须是薄壳。**

### 行业证据:拆分轴是「接口」,不是「源码项目」

| | 源码单位 | 消费单位 |
|---|---|---|
| Debian | 一个 `mesa` 源码包 | `libgbm1` / `libegl1` / `libgl1` **三个二进制包** |
| Conan | — | `opengl/system`、`egl/system` **两个包**(无 `gbm`,见下) |
| pkg-config | — | `gbm.pc` / `gl.pc` / `egl.pc` **三个 .pc** |

所以「优先源码/原项目一起」与「按接口拆包」不冲突,它们是两个轴:
**构建单位是整个 Mesa**(`xlings-res/mesa` 已经如此),**消费单位是接口**。
发行版的标准做法正是「一个源码包 → 多个二进制包」。

### Conan 的形态(实查 conan-center-index)

- `libgbm` / `gbm` / `mesa` → **全部 404,Conan 根本不打包 gbm**;
- `opengl` / `egl` / `xorg` → 存在,但是 `version = "system"` 的**虚包**:
  `package_id()` 清空、`system_requirements()` 调 apt/dnf/pacman 装发行版 `-dev` 包、
  `package_info()` 用 `PkgConfig(...).fill_cpp_info(is_system=True)` 读系统 `.pc`,
  并且 `includedirs = []` / `libdirs = []` —— **一个目录都不贡献**;
- `libdrm` / `wayland` / `libglvnd` / `vulkan-loader` → 真配方,真源码构建。

判据很清楚:**上游作为独立项目发布 → 真构建;是平台/驱动栈的一个切面 → 薄虚包交给平台。**
GBM 属于后者。

`compat.libgbm` 就是这个形态在 mcpp 里的对应物,**「平台」由 `xim:mesa` 扮演**:

| Conan | mcpp-index |
|---|---|
| `system_requirements()` → apt/dnf | `xpm.linux.deps.runtime = { "xim:mesa" }` |
| `package_info()` → 系统 pkg-config | `include_dirs` / `ldflags` / `runtime.*_dirs` |
| 不 vendor 任何源码 | 同 |

一处**必要的**差异:Conan 的 system 包能 `includedirs = []` 是因为有系统 pkg-config;
沙箱里没有,所以薄壳必须自己把 xim payload 指出来(`install()` 从 `system.subos_sysrootdir()`
取)。这是沙箱带来的,不是多做 —— `compat.glx-runtime` 同款。

### 为什么不做成一个大 `compat.mesa`

按接口拆已有三方一致的先例(上表)。合成一个大包会让只要 gbm 的消费者拖上 GL/EGL 的
include 根,并与既有的 `compat.opengl` / `compat.glx-headers` 抢 `GL/` 目录 ——
后者已经在 `compat.glx-headers` 的注释里被记为一个真实的踩坑。

### constructor 为什么不属于「包该做的事」

Conan 的 system 包**不做任何 runtime env wiring**,因为发行版里编译进去的 `$libdir/gbm`
本来就对。只有**被重定位的栈**才需要,而那一层的标准做法是容器/环境级:
Valve 的 pressure-vessel 在 mesa 24.3 拆出后端后踩到同一个 bug(steam-runtime#797),
用 `GBM_BACKENDS_PATH=/run/host/usr/lib64/gbm` 解决;Nix / Conda / AppImage 同理。

在 mcpp 生态里,「环境级」就是 subos env manifest —— 也就是 C1 + C2。
所以 constructor 是**在补 R2 的洞**,不是包的职责。

---

## 4. 闭环验证矩阵

每一条都要能独立跑、独立红。

| # | 断言 | 在哪 | C1 前 | C1 后 | C1+C2 后 |
|---|---|---|---|---|---|
| V1 | `.xlings.json` 的 `envs` 含 `GBM_BACKENDS_PATH` | xim-pkgindex 测试 | 红 | **绿** | 绿 |
| V2 | xvm shim 程序(godot 类)`GBM_BACKENDS_PATH` 非空 | xim-pkgindex | 红 | **绿** | 绿 |
| V3 | `mcpp run` 下 `LIBGL_DRIVERS_PATH` 指向 `<subos>/usr/lib/dri` | mcpp 回归 | 红 | 红 | **绿** |
| V4 | 只 include `<gbm.h>` 的消费者拿到 `GBM_BACKENDS_PATH` | `tests/examples/libgbm/tests/stock_usage.cpp` | 绿*(constructor)* | 绿*(constructor)* | **绿(闭环)** |
| V5 | 删掉 constructor 后 V4 仍绿 | 同上 | — | — | **这就是 C3 的准入条件** |

V4/V5 是关键:V4 现在靠 constructor 绿,C1+C2 之后靠体系绿。
**V5 通过就是删 constructor 的信号**,不必靠人判断。

反向验证(证明断言非空转):把 `dri_gbm.so` 移出目标目录,V4 必须转红 —— 已实测,退出码 1。

---

## 5. 落地顺序

三个仓可以**并行开工**,但合并有序:

```
C1 (xim-pkgindex)  ──┐
                     ├─→  V3 绿  ──→  C3 (mcpp-index 删 constructor,V5 把关)
C2 (mcpp)          ──┘
```

- **C1 独立可合**:不依赖任何人,合了立刻修好 xlings 侧消费者(V1/V2)。
- **C2 独立可合**:不依赖 C1,合了立刻修好 GL/EGL 的 `LIBGL_DRIVERS_PATH`(V3)——
  **这本身就是一个比 gbm 重要得多的修复**。
- **C3 最后**:两者都在、且 V5 绿,才删 constructor。

在 C3 之前,mcpp-index PR #281 以现状合并是安全的:它自包含、CI 全绿、对消费者透明,
唯一代价是一份临时的 constructor + 后端 farm,已在描述符里注明删除条件。

## 6. 风险与回滚

| 风险 | 评估 | 处置 |
|---|---|---|
| C1 让 `GBM_BACKENDS_PATH` 指向空目录 | mesa 无 `lib/gbm` 的构建是合法配置 | `declare_gbm` 照抄 `declare_dri` 的 `os.isdir` 检查并 `log.warn` 后返回 false |
| C1 覆盖用户自设的值 | 不会 | `DISCOVERY` 一律 `prepend`,`graphics.lua` 已论证过 `set` 会抹掉 NVIDIA 目录 |
| C2/B1 的 `${subosdir}` 展开错源 | 真实风险 | 展开必须用**声明来源**的 subos 目录,不是 `binding.subosDir`;回归测试须断言路径前缀 |
| C2/B2 改变所有工程的 fingerprint | 实测会触发 full rebuild | 这正是不建议 B2 先行的理由 |
| C3 删早了 | V5 把关 | V5 红就不删 |

## 7. 一个顺带发现,值得单独报

`xim-x-mesa 25.0.7.2` 的 `libgallium-25.0.7.so` 需要 `GLIBC_2.43`,而栈里配的
`xim-x-glibc` 是 `2.39`:

```
MESA-LOADER: failed to open dri: …/xim-x-glibc/2.39/lib64/libm.so.6:
version `GLIBC_2.43' not found (required by …/libgallium-25.0.7.so)
```

后端**找得到**了(`search paths` 已经是对的),但**加载不了**。这与本方案正交,
是 `xim:mesa` 自身的构建/运行时错位(mcpp#352 的形状),应当单独提。

这也是为什么全套测试断言的是「后端**存在于**将被搜索的路径上」而不是「后端能加载」——
后者在这台机器上永远红,且红的原因不在本方案范围内。

---

## 8. 深度自我 review(2026-08-30 第二轮)

> **⚠ 本节的 8.1(结论:mcpp 侧应采用「分层继承 B3」)已被 §12.1 推翻。** 实现时测出:
> 装到**全局 scope** 之后 sysroot 天然看得见,B3 不需要。8.1 那张「项目 subos 缺
> libgcc_s/libstdc++」的表仍是事实,但它证明的是「别往项目 scope 装」,不是「需要叠加」。
> 8.2–8.6 的其余内容仍然成立。**mcpp 侧怎么修,以 §12.1 为准。**


第一轮方案有四处实质错误。逐条记录,因为其中三条是「没做实验就下结论」。

### 8.1 B1/B2 是假二分,正确形态是**分层继承**(B3)

**实测**:项目 subos `_` 里有什么:

| | |
|---|---|
| `libc.so.6` / `crt1.o` / `libm.so.6` / `ld-linux-x86-64.so.2` | ✔ |
| **`libgcc_s.so.1` / `libstdc++.so.6`** | **✗ 没有**(工具链 subos 里有) |
| `libgbm.so{,.1}` / `libEGL.so.1` / `libGL.so.1` / `usr/include/gbm.h` | ✔ |

所以**项目 subos 不是工具链 subos 的超集**。由此:

- **B2(切换)会回退**:sysroot 换过去就丢了 gcc runtime。我当时反对 B2 的理由是「爆炸半径大 /
  会 full rebuild」—— 那是**弱理由**(fingerprint 变化本就由 `contractHash` 正确处理,一次性重建
  不是正确性问题)。真正的反对理由是**它会丢东西**,而我没测出来。
- **B1(只合 env)不够**:它修好 `GBM_BACKENDS_PATH`,但 `gbm.h` 与 `-lgbm` 仍然只能靠 compat 包
  自己声明。也就是说 B1 把「运行期」修好了,「构建期」原样留着。

**B3 = 默认用 mcpp 的工具链 subos 作**基座**,项目 subos 作**叠加层**:**

```
sysroot   : --sysroot=<toolchain subos>            ← 不变,保住 gcc runtime
叠加      : -isystem <proj subos>/usr/include
            -L       <proj subos>/lib
            -Wl,-rpath,<proj subos>/lib
env       : 项目 subos 的 envs 按 prepend 合并(项目在前)
```

一个编译器只吃一个 `--sysroot`,所以「继承」在实现上必然是「基座 sysroot + 叠加 `-isystem`/`-L`」,
而不是换 sysroot。这既拿到了 B2 想要的东西(头和库直接可见),又不承担 B2 的回退风险,
比 B1 多修一个构建期。

### 8.2 我从没验证过「不要 compat 包」这条路走不走得通

第一轮直接断言「薄壳仍然要保留」,没有证伪替代方案。补测之后:

| 尝试 | 结果 |
|---|---|
| `[xlings] deps = ["mesa"]`(无 compat 依赖) | `.mcpp/.xlings.json` 里确实写进了 `"deps": ["mesa"]`,但**没有安装、没有建 subos**,`fatal error: gbm.h: No such file or directory` |
| `[xlings] subos = "_"`(subos 不存在时) | **报错**:`selected SubOS '_' does not exist … create/bootstrap that environment instead of falling back`,mcpp 不会自举 |
| 包声明 `xpm.deps.runtime = { "xim:mesa" }` | ✔ 项目 subos 被建出来,mesa 进去 |

**⇒ 今天唯一能把 xim 层引进一个 mcpp 工程的东西,就是 compat 包的 `xpm.deps.runtime`。**

结论没变(薄壳要保留),但**理由变了**,而且这个理由本身是第三个洞:

- **R2a**:`[xlings] subos` 只能**选择**已存在的 subos,不能创建。
- **R2b**:`[xlings] deps` 只被**物化**进 `.mcpp/.xlings.json`,没有被**供给**(install/expose)。

R2a + R2b 不修,B3 从 manifest 侧就是不可达的 —— 用户写 `[xlings]` 也拿不到东西,
只能绕道「随便依赖一个声明了 `xim:mesa` 的 compat 包」。这恰好就是 `compat.libgbm` 现在的处境:
**它事实上在扮演「xim 层的入口」,而这不该是一个库包的职责。**

### 8.3 V 矩阵把两种 C2 混在一起了

原矩阵的 V3/V5 默认「C2 之后头和库也就有了」。只有 B3 成立;B1 之下 V5 永远不可能绿,
因为删掉 constructor 只影响 env,而 `include_dirs`/`ldflags` 本来就来自包本身。

修正:V5 的准入条件应写成「**C2 采用 B3** 且 V3 绿」。若最终只做 B1,则
`compat.libgbm` 的薄壳形态是**长期**的,不是过渡的 —— 这对 §3「是否独立成包」的结论没有影响
(仍然该独立、该薄),但对「多久之后能删 constructor」的预期影响很大。

### 8.4 R2 应拆成三条

原文一条 R2 说不清。正确的分解:

| | 缺陷 | 影响 |
|---|---|---|
| **R2a** | `[xlings] subos` 不能自举 | manifest 侧无法建立项目 subos |
| **R2b** | `[xlings] deps` 只物化不供给 | 声明了也拿不到东西 |
| **R2c** | 默认选择只读工具链 subos,无分层 | 项目 subos 的 env / 头 / 库全部不可见 |

`mcpp#352` 修的是「怎么注入 env」,R2c 是「从哪读」,R2a/R2b 是「谁来建」。三者独立。

### 8.5 修正后的建议

- **C2 采用 B3(分层继承)**,不是 B1。理由见 8.1:B1 只修一半,B2 会丢 gcc runtime。
- **C2 的前置**是 R2a/R2b,否则 B3 只能被包触发,manifest 侧仍然不可用。
- **C3 的准入条件**改为「B3 落地 + V3 绿 + V5 绿」。
- §3 的结论(`compat.libgbm` 应独立且薄)**不变**,但要补一句:它今天还额外承担了
  「xim 层入口」这个不属于它的职责,R2a/R2b 修好之后这份职责才真正卸掉。

### 8.6 仍然成立的部分

- §1 的全部实测证据(两个 `.xlings.json`、`subos = "_"` 的前后对比)。
- **R1 与 C1 完全不受影响** —— 它在另一个仓,独立可合,且单独就能修好 xlings 侧消费者。
- §3 的行业论证(按接口拆包;Conan 无 gbm recipe、`<name>/system` 形态)。
- §7 的 glibc 错位,与本方案正交。

---

## 9. R2b 的修法:首次构建自动供给 `[xlings] deps`

### 9.1 现状

`[xlings]` 段被 1:1 物化成 `ProjectEnv`(`src/platform/xlings/xlings.cppm:307`):

```cpp
struct ProjectEnv {
    std::vector<std::string>  deps;       // → .xlings.json "deps"
    ... workspace / subos / envs
};
```

`seed_xlings_json(env, repos, mirror, penv)` 把它写进 `<proj>/.mcpp/.xlings.json`。
**写完就结束了 —— 没有任何一处去装它。** 实测:`deps = ["mesa"]` 写进了文件,
`gbm.h` 依然 not found,项目 subos 根本没被创建。

### 9.2 mcpp 里已经有两条现成的「声明 → 自动安装」路径

**(a) 工具链首次运行**(`src/build/prepare.cppm` ~1690):

```cpp
mcpp::ui::info("First run",
    std::format("no toolchain configured — installing {} ({}) as default", …));

mcpp::fetcher::Fetcher fetcher(**cfg);
mcpp::fetcher::InstallProgressHandler progress;
for (auto dep : {"xim:glibc", "xim:linux-headers"})
    (void)fetcher.resolve_xpkg_path(dep, /*autoInstall=*/true, &progress);
auto payload = fetcher.resolve_xpkg_path(defaultPkg.target(), /*autoInstall=*/true, &progress);
```

**(b) 项目作用域安装**(`src/build/prepare.cppm` ~2936),已经带实时进度 UI:

```cpp
auto projEnv = mcpp::config::make_project_xlings_env(**cfg, *root);
auto argsJson = std::format(R"({{"targets":["{}"],"yes":true}})", target);
mcpp::fetcher::InstallProgressHandler progress;
auto r = mcpp::xlings::call(projEnv, "install_packages", argsJson, &progress);
```

注释里写得很清楚:安装目的地由**包的 scope(project vs global)**决定,不由 transport 决定 ——
也就是说 (b) 装出来的东西正好落在**项目**作用域,而项目 subos 正是这样被建出来的。

### 9.3 提案

在 `seed_xlings_json` 物化 `ProjectEnv` 之后、runtime selection 之前,
若 `penv.deps` 非空且尚未满足,走 **(b)** 的同一条路把它们装上:

```cpp
if (!penv.deps.empty() && !already_provisioned(penv.deps)) {
    mcpp::ui::info("First run",
        std::format("provisioning [xlings] deps — installing {}", join(penv.deps)));
    auto projEnv = mcpp::config::make_project_xlings_env(cfg, root);
    auto argsJson = to_targets_json(penv.deps);          // {"targets":[…],"yes":true}
    mcpp::fetcher::InstallProgressHandler progress;
    auto r = mcpp::xlings::call(projEnv, "install_packages", argsJson, &progress);
    if (!r) return std::unexpected(/* 与工具链同款:给出手工命令 */);
}
```

要点:

- **复用 (b) 而不是新写一条**,因为 scope 语义、进度 UI、错误捕获(`captured_error()`)
  都已经是对的;
- 失败信息照抄工具链那条的形状:说明失败了、并给出**手工可执行的等价命令**;
- 幂等:已装则跳过 —— 与工具链首次运行一样只在缺失时触发;
- **供给必须发生在 runtime selection 之前**,否则 §8.2 那条
  `selected SubOS '_' does not exist` 会先一步报错。这条顺序约束就是 **R2a 的实质**:
  R2a 与其说是「subos 要能自举」,不如说是「**供给先于选择**」。修好顺序,
  R2a 作为独立缺陷基本消失,`[xlings] subos` 可以继续保持「只选择、不创建」的严格语义。

### 9.4 R2b 修好之后,直接消费这条路就通了

预期(修完应当能实测通过,即新增回归):

```toml
[xlings]
deps = ["mesa"]

[build]
ldflags = ["-lgbm"]
```

配合 B3 分层,`#include <gbm.h>` / `-lgbm` / `GBM_BACKENDS_PATH` 全部可用,
**不需要任何 mcpp-index 包**。

---

## 10. 综合 review(第三轮):这套方案自洽吗?

### 10.1 R2b + B3 之后,`compat.libgbm` 还需要存在吗?

**需要,而且理由比前两轮更硬 —— 是「传递依赖」。**

§9.4 那条路只对**应用自己的 manifest** 成立。而 GBM 的真实消费者多数是**库**:
`compat.sdl2` 的 KMSDRM 后端、wlroots、ffmpeg 的 VAAPI hwcontext。
一个库包**无法往消费者的 `mcpp.toml` 里注入 `[xlings] deps`** —— 它只能声明一条依赖边。

所以两条路各有各的用途,不重复:

| 场景 | 用什么 |
|---|---|
| 应用自己要用 gbm | `[xlings] deps = ["mesa"]`(R2b 之后) |
| **库**要用 gbm,并让它随依赖图传播 | **`compat.libgbm`** |

Conan 也正是这么并存的:`opengl/system` 是一个**包**而不是「让用户自己写
system_requirements」,因为 `sdl`、`glfw` 这些库需要 `requires` 一个东西。
`compat.libgbm` 在 mcpp 里承担同一角色。

`ldflags = ["-lgbm"]` 也一样:让每个消费者手写是错的,那属于包的 `package_info()`。

### 10.2 三轮下来,哪些结论真正稳定

| 结论 | 第1轮 | 第2轮 | 第3轮 |
|---|---|---|---|
| R1 / C1(GBM 进 DISCOVERY) | ✔ | ✔ | ✔ **从未动摇,且独立可合** |
| 按接口拆包、包要薄 | ✔ | ✔ | ✔ |
| `compat.libgbm` 应独立存在 | ✔(理由弱) | ✔(理由:唯一入口) | ✔ **(理由:传递依赖)** |
| constructor 不属于包的职责 | ✔ | ✔ | ✔ |
| mcpp 侧该怎么修 | B1 | **B3** | B3 + R2b(供给) |
| R2 的分解 | 一条 | 三条 | 三条,且 **R2a 降级为顺序约束** |

理由被换掉三次而结论不变的那几条,才是真的稳。**唯一反复改的是 mcpp 侧的形态** ——
因为那是我唯一没有一开始就去读源码/做实验的部分。

### 10.3 还没验证、需要在实现时确认的假设

诚实列出,不假装已闭环:

1. **B3 的叠加是否会与包自己的 `include_dirs` 撞车。** 项目 subos 的 `usr/include` 会带进
   `EGL/`、`GL/`、`KHR/`(mesa + libglvnd),而 `compat.opengl` / `compat.glx-headers`
   也提供 `GL/` —— `compat.glx-headers` 的注释已经记过这个重叠是真实踩坑。
   **叠加顺序必须让包的 `include_dirs` 优先于 subos 叠加层**,否则等于给所有消费者
   换了一套 GL 头。这是 B3 最需要测的一点。
2. **`install_packages` 对「已装」是否幂等**,以及在离线/无网时的行为。
3. **`${subosdir}` 的展开源**:必须是声明所在的那个 subos,不是 `binding.subosDir`(§2 B1 已记)。
4. **workspace 成员**:`select_runtime` 用的是 `workspaceManifest` 的 `[xlings]`
   (`owner = workspaceManifest ? … : projectManifest`),所以 mcpp-index 这种虚拟 workspace
   里,`[xlings]` 该写在根还是成员,需要确认;写错会静默不生效。

### 10.4 对 PR #281 的最终判断

不变:**以现状合并是安全的**,它自包含、CI 全绿、对消费者透明(`#include <gbm.h>` 即可),
唯一代价是一份带删除条件的临时 constructor + 后端 farm。

但 §10.1 修正了一处预期:即便 R1 + R2b + B3 全部落地,**这个包也不会消失**,
只会瘦下来 —— 它作为「库→库」传递依赖的载体是长期的。

---

## 11. 任务拆分与依赖关系(执行版)

### 11.1 任务表

| ID | 仓 | 内容 | 依赖 | 可并行 |
|---|---|---|---|---|
| **T1** | xim-pkgindex | `graphics.GBM_DIR` + `DISCOVERY` 一行 + `declare_gbm()`;`mesa.lua` 调用 | — | ✔ 起点 |
| **T2** | xim-pkgindex | T1 的测试(vendor-form harness 同款) | T1 | |
| **T3** | mcpp | R2b:`[xlings] deps` 首次构建自动供给 | — | ✔ 与 T1 并行 |
| **T4** | mcpp | B3:工具链 subos 作基座 + 项目 subos 叠加 | T3(供给先于选择) | |
| **T5** | mcpp | T3/T4 回归测试 | T4 | |
| **T6** | mcpp-index | `compat.libgbm` 定型 + 文档 | — | ✔ 与 T1/T3 并行 |
| **T7** | mcpp-index | `stock_usage.cpp` 保留为闭环回归 | T6 | |
| **T8** | 三仓 | 规范/文档同步(含 zh) | T1/T4/T6 | |
| **T9** | — | release + gtc 补 CN 资源 | T6 | |
| **T10** | — | 生态真实验证(`xlings subos --sandbox --cmd`) | T1(+T4) | 终点 |

关键路径:**T1 → T10**。T3/T4 是另一条独立链,不阻塞 GBM 闭环 —— 这是把
R1 与 R2 拆开的最大收益。

### 11.2 多角度评估

**架构** —— 每个改动都落在**已经拥有该职责**的那一层:发现路径归 `graphics.lua`
(它已经管 DRI/EGL/XDG),供给归 mcpp(它已经为工具链做过一次),接口暴露归 compat 包。
没有任何一层被要求承担新职责,所以没有新的抽象。

**稳定性** —— T1 是纯增量:`DISCOVERY` 多一行,旧消费者读不到新变量也不会坏;
`declare_gbm` 缺目录时 `warn + return false`,不中断安装。T4 是叠加而非替换,
不会丢工具链的 `libgcc_s`/`libstdc++`(§8.1 实测)。

**优雅简洁** —— T1 全部收益来自「把 GBM 加进一张已经存在的表」,`consumer_envs()`
与 `declare_subos_env()` 自动跟随,不需要第二处改动。T6 之后包里**没有一行**
GBM 特有的运行期逻辑。

**用户体验** —— 终态是 `#include <gbm.h>` 就能用,不需要知道任何 mcpp/xlings 概念。
T3 的失败信息照抄工具链那条:说明失败并给出**手工可执行的等价命令**。

**兼容性** —— `prepend` 而非 `set`,尊重用户已 export 的值(`graphics.lua` 自己论证过
`set` 会抹掉 NVIDIA 目录)。旧 mesa 版本没有 `lib/gbm` 时安装照常成功。

**跨平台** —— GBM 是 Linux DRM 概念,`xpm` 只有 `linux` 段,测试在非 Linux 编译成
no-op `main()`(`compat.libaio`/`compat.wil` 同款)。T3/T4 是平台无关的 subos 逻辑。

**一致性** —— `declare_gbm` 是 `declare_dri` 的镜像;`GBM_DIR` 与 `DRI_DIR` 同在
`usr/` 下(受 `is_permitted_file_destination` 白名单约束,见 11.3);
T3 复用 `install_packages`,T4 复用既有 `EnvDecl`。

**无感升级** —— 三个改动都不需要消费者改任何东西:T1 在下次 `xlings install/update`
时随 mesa 的 `config()` 生效;T4 之后旧工程只是多拿到几个变量;T6 删 constructor 时
公开 API 没有变化(本来就是 `#include <gbm.h>`)。`binding.environment` 参与
`contractHash`,声明变化自动使快取失效,不会出现「新声明 + 旧产物」。

**测试覆盖** —— §4 的 V1–V5,其中 **V5 是删 constructor 的机械准入**;
`stock_usage.cpp` 是防止「退回 opt-in 修法」的回归;反向验证(移走 `dri_gbm.so`)
已实测能让断言转红。

### 11.3 实现期发现的硬约束(写进代码注释)

`graphics.lua` 自己记着:**xlings 只允许 `usr`/`etc`/`share` 开头的 file asset 目标**
(`xvm/bindings.cppm` 的 `is_permitted_file_destination`),而且**被拒绝不是错误 ——
放置只是不发生**。所以 `GBM_DIR` 必须是 `usr/lib/gbm`;写成 `lib/gbm` 会得到一个
安装干净、变量指向不存在目录、`gbm_create_device()` 静默返回 NULL 的配方。
这与 `DRI_DIR = "usr/lib/dri"` 的理由完全相同。

---

## 12. 实现与验证结果(2026-08-30 执行记录)

### 12.1 结论先行:**B3 不需要**

第 8 节推导出「必须分层继承(B3)」,实现时被实验推翻。**真正的修法是把
`[xlings] deps` 装到 GLOBAL scope**,因为那个 registry 的 SubOS **就是** mcpp 的
`--sysroot`。一旦装对了地方,头和库天然可见,不需要任何 `-isystem`/`-L` 叠加。

推翻的过程(每一步都是实测):

| 试的东西 | 结果 |
|---|---|
| `install_packages` + `make_project_xlings_env`(**项目** scope) | 装成功、`.xlings.json` 也写了,但头落在 `<proj>/.mcpp/.xlings/subos/_/usr/include`,而 `--sysroot` 指的是 `<MCPP_HOME>/registry/subos/default` → **`gbm.h` 仍然找不到** |
| `resolve_xpkg_path`(工具链同款,**全局** scope) | 头进了 sysroot,`gbm.h` 找到了 ✔ —— 但它要求 `<name>@<version>`,裸名报 `invalid xpkg target 'xim:mesa': expected <name>@<version>` |
| **`install_packages` + `make_xlings_env`(全局 scope)** | ✔ 全对:裸名、带命名空间、带版本都能用,歧义名还会列出候选 |

所以 §8.1 那张「项目 subos 缺 libgcc_s/libstdc++」的表仍然是**事实**,但它证明的不是
「需要分层」,而是「**不该往项目 subos 装**」。结论方向反了,数据没错。

**这也让 mcpp 侧的改动小了一个数量级**:没有碰 `linkmodel.cppm`、
`plan.runtimeSearch`、`link_line.cppm` 的任何排序不变量 —— 那几处的注释明确写着
「一个可变视图排在已链接产物之前会让后续安装悄悄改变加载的库,这不是假设,正是本模块诞生的原因」。
不动它们是这次实现最重要的克制。

### 12.2 已实现并验证

**T1 / C1 — xim-pkgindex** ([openxlings/xim-pkgindex#713](https://github.com/openxlings/xim-pkgindex/pull/713))

`graphics.GBM_DIR` + 一行 `DISCOVERY` + `declare_gbm()`,`mesa.lua` 调用。
测试:`tests/test_graphics_gbm_discovery.py`(5 例)+ 纯 Lua harness。
**两种静默失败都实测转红**:删掉 DISCOVERY 行、把 `GBM_DIR` 写成 `lib/gbm`(白名单外)。
既有 graphics/mesa 测试 22 项全过。

**T3 / R2b — mcpp**(`feat/xlings-subos-layering`)

`[xlings] deps` 首次构建自动供给,全局 scope,内容级幂等(stamp)。
实测第二次 `mcpp run` 输出 0 行 `Provisioning`。

**T6 — mcpp-index**(PR #281,CI 全绿)

`compat.libgbm` + 两个测试二进制,constructor 形态,已在 §10 论证为传递依赖载体。

### 12.3 生态真实验证(`xlings subos --sandbox --gpu`)

全新 subos `eco-gbm-20260830`,`xlings install xim:mesa@25.0.7.2`:

```
[xlings] subos eco-gbm-20260830: 4 env var(s) from 1 package(s)      ← 原本 3
GBM_BACKENDS_PATH=/home/speak/.xlings/subos/eco-gbm-20260830/usr/lib/gbm
<subos>/usr/lib/gbm/dri_gbm.so
```

沙箱内真跑(`--sandbox --gpu`):

```
search paths <subos>/usr/lib/gbm, suffix _gbm        ← 是我们的路径,不是 /usr/lib/gbm
/dev/dri/renderD128  gbm_create_device = 0x27080ed0  backend = drm
/dev/dri/card0       gbm_create_device = 0x27080ed0  backend = drm
/dev/dri/card0       gbm_bo_create = 0x2708b8a0      ← 真的分配出了 buffer object
RESULT: PASS
```

`renderD128` 上 `gbm_bo_create` 返回 NULL 并打印
`KMS: DRM_IOCTL_MODE_CREATE_DUMB failed: Permission denied` —— 那是 render node
的权限边界(dumb buffer 需要 KMS 权限),不是打包问题;`card0` 上分配成功。

### 12.4 mcpp 侧闭环(全新 MCPP_HOME,零 mcpp-index 依赖)

```toml
[package]
name = "nopkg"
version = "0.1.0"

[xlings]
deps = ["xim:mesa"]

[build]
ldflags = ["-lgbm"]
```

`src/main.cpp` 只 `#include <gbm.h>`:

```
Provisioning [xlings] deps (xim:mesa)
Compiling nopkg v0.1.0 (.)
Running `target/.../bin/nopkg`
XR24 | GBM_BACKENDS_PATH=<registry>/subos/default/usr/lib/gbm
```

编译、链接、运行、环境变量四项全通,**没有任何 mcpp-index 包**。

### 12.5 唯一仍未闭合的一环,且不在本方案范围内

`xim-x-mesa/25.0.7.2` 的 payload RUNPATH 指向 `xim-x-glibc/2.39/lib64`,
而它自己的 `libgallium-25.0.7.so` 需要 `GLIBC_2.43`(store 里有 2.44 和 2.44.2):

```
MESA-LOADER: failed to open dri: …/xim-x-glibc/2.39/lib64/libm.so.6:
version `GLIBC_2.43' not found (required by …/libgallium-25.0.7.so)
(search paths <subos>/usr/lib/gbm, suffix _gbm)
```

注意 search path 已经是对的 —— **可达性已闭合**,倒在下一跳。12.3 那次成功的运行
是把 `LD_LIBRARY_PATH` 指向 2.44.2 之后取得的,用来隔离出这一个变量。

`mesa.lua` 自己不做任何 patchelf(全仓只有 `graphics.lua`/`hostlib.lua` 用 patchelf,
且都是只读的 `--print-rpath`),所以这要在 `xlings-res` 侧重建/重打 payload 解决,
**不该由 recipe 或 compat 包绕过**。已单独记录待报。

### 12.6 验证期踩到的两个坑(留给下一个人)

1. **`MCPP_HOME` 会再拼一层 `registry/`**。设 `MCPP_HOME=<X>` 时实际用的是
   `<X>/registry/subos/default`。我一度在检查 `<X>/subos/default` 并得出「envs 是空的」
   的错误结论,而真正在用的那个里面有东西。查 sysroot 请以 `build.ninja` 里的
   `--sysroot=` 为准,别自己推。
2. **mcpp 有自己的一份索引副本**(`<MCPP_HOME>/registry/data/xim-pkgindex`),
   与 `~/.xlings/data/xim-pkgindex` 是两份。改了后者,mcpp 侧不会看到,
   要等合并 + artifact 重新发布(本地验证时手工同步了两份)。

---

## 13. 交付状态(每仓一个 PR)

| ID | 仓 | 状态 | 落在哪 |
|---|---|---|---|
| **T1** | xim-pkgindex | ✅ 完成 | [#713](https://github.com/openxlings/xim-pkgindex/pull/713) |
| **T2** | xim-pkgindex | ✅ 完成 | 同上(`test_graphics_gbm_discovery.py` 5 例 + Lua harness) |
| **T3** | mcpp | ✅ 完成 | [#531](https://github.com/mcpp-community/mcpp/pull/531) |
| **T4** | mcpp | ⛔ **不需要**,已退休 | 见 §12.1 |
| **T5** | mcpp | ✅ 完成 | `mcpp test` 96 passed;SubOS-env 轴由既有 `tests/e2e/200_subos_env_reaches_program.sh` 覆盖 |
| **T6** | mcpp-index | ✅ 完成 | [#281](https://github.com/mcpplibs/mcpp-index/pull/281) |
| **T7** | mcpp-index | ✅ 完成 | 同上(`stock_usage.cpp`) |
| **T8** | 三仓 | ✅ 完成 | 各自 PR 内(mcpp-index 含 zh) |
| **T9** | — | ✅ 完成 | `gitcode.com/mcpp-res/libgbm@2026.08.29`,与 GLOBAL 逐字节一致 |
| **T10** | — | ✅ 完成 | §12.3 / §12.4 |

**每个仓恰好一个 PR。**

### 13.1 「SubOS 环境那半哪去了?」

这是 review 时最该问的问题,答案是:**它一直都在 mcpp 里,不需要新写**。

| 环节 | 在哪 | 状态 |
|---|---|---|
| 解析 `.xlings.json` 的 `envs` | `subos_info.cppm` → `EnvDecl{var,op,value}` | 早已有 |
| 收进 binding | `runtime_binding.cppm` → `binding.environment` | 早已有 |
| 展开 `${subosdir}` / 应用 `prepend` / 注入子进程 | `execute.cppm::compute_subos_env()`(mcpp#352) | 早已有 |
| **回归测试** | `tests/e2e/200_subos_env_reaches_program.sh` | 早已有 |
| **声明里有 GBM 这一项** | `libs/graphics.lua` 的 DISCOVERY | ← **T1,这次补的** |
| **SubOS 里有东西可读** | `[xlings] deps` 自动供给 | ← **T3,这次补的** |

所以 #531 只包含供给逻辑是**正确的**:环境注入不缺,缺的是「声明里没有 GBM」和
「mcpp 读的那个 SubOS 里没有 mesa」。§12.1 的三次实测把 T4 也一并否掉了 ——
装对 scope 之后,sysroot 天然看得见,不需要叠加层。

一句话:**mcpp#352 修好了「怎么注入」;T1 补上「注入什么」;T3 补上「从哪读得到」。**

---

## 14. 要不要把 mesa(或它内部可分离的库)做成 mcpp-index 包?

mcpp **确实**支持共享库包 —— `docs/package-types.md` 的形态 F(「共享库 compat:必须是
唯一的那个 `.so`」),`compat.x11` 家族与 linux 上的 `compat.vulkan` 就是。所以这不是
「能不能」的问题,是「该不该」。

### 14.1 mesa 本体:不建议

三条,前两条已实测:

1. **一个进程里会出现两个 `libgbm.so.1`。** `xim:mesa` 已经提供一个,索引再建一个,
   谁被加载取决于搜索顺序。`compat.vulkan-runtime` 的注释对同一件事的结论是
   「宿主自己的 `libvulkan.so*` **刻意不** harvest……一个进程一个 loader 才是重点」。

2. **混合链接形态 = 静默符号劫持。** 索引里的 `compat.*` 全是**静态**包,而 mesa 的
   payload 是 shared 闭包。实测(glib/zlib,见 [[mcpp-prebuilt-package-route]]):exe 的
   `.dynsym` 导出 86 个 zlib 符号,`LD_DEBUG=bindings` 显示 libgio 的 12 次 zlib 调用
   **全部绑到 exe**,捆进去的 `libz.so.1` 被完全遮蔽成死重 —— **跑得通、无告警**。
   vcpkg 用 triplet、Conan 用 `shared` option 沿图传播来禁止「一次链接里混形态」,
   mcpp/xlings 缺的正是这个全图开关。

3. **成本。** mesa 要 meson + LLVM + ~30 个依赖;而 `xlings-res/mesa` 已经把这件事做完了。

### 14.2 内部「可分离的库」:`compat.libdrm` 值得做

用户的直觉在这里是对的 —— **有些确实是独立项目**,判据仍是 §3 那条(上游是否作为
可独立分发的单元发布):

| 候选 | 是独立项目吗 | Conan 有没有 | 建议 |
|---|---|---|---|
| **libdrm** | ✔ 独立发布 | ✔ 真配方(源码构建) | **值得加**,见下 |
| expat | ✔ 独立发布 | ✔ | 可加,按需 |
| libglvnd | ✔ 独立发布 | ✔ | 索引已有 `compat.glx-headers`(只取头) |
| **libgbm / libEGL / libGL** | ✗ 是 mesa 内部 target | ✗ **Conan 根本没有** | 保持绑定形态 |

**`compat.libdrm` 有一条现成的理由**:`compat.vulkan-runtime` 今天从**宿主**
`/usr/lib/x86_64-linux-gnu` harvest `libdrm*.so.*` —— 这正是本方案第 2 节反复要消除的
host 依赖。一个源码构建的 `compat.libdrm` 能把那条 host 边关掉,而且它**不触发 14.1 的
任何一条**:libdrm 是独立项目、索引里没有第二份、可以静态构建从而与其余 `compat.*`
形态一致。

**结论**:不复制 mesa;把「可分离」这条判据用在真正可分离的东西上,而 libdrm 是最该先做的
那个。`compat.libgbm` 保持 §3/§10.1 论证过的薄绑定形态。

---

## 15. xlings 版本 pin:**不下调,现状已经是对的**

任务里有一条「顺带 pin 一下内部依赖的 xlings 版本到 `2026.8.27.4`,到时候应该就发布了」。
查完之后这条建立在一个反过来的前提上,所以**没有执行**,理由如下。

### 15.1 事实

```
gh release list --repo openxlings/xlings
2026.8.27.5   Latest   v2026.8.27.5   2026-08-27T13:29:41Z      ← 已发布,8 个 asset
2026.8.27.4            v2026.8.27.4   2026-08-27T10:18:31Z      ← 更旧
```

`.4` **不是待发布的新版,是已经发布的旧版**;`.5` 才是 Latest,而且三仓的 pin 已经都在 `.5`:

| 仓 | pin | 状态 |
|---|---|---|
| mcpp | `src/xlings/xlings.cppm` `kXlingsVersion = "2026.8.27.5"` | `.github/tools/check_version_pins.sh` → `OK: xlings pins all at 2026.8.27.5` |
| xim-pkgindex | `pkgs/x/xlings.lua` `latest = 2026.8.27.5` | 一致 |
| mcpp-index | 只 pin mcpp(`MCPP_VERSION`),不 pin xlings | 无关 |

所以「pin 到已发布的 xlings」这个**意图本身已经满足**,而且是被更好地满足了。

### 15.2 下调会丢掉一个有记录的性质

`src/xlings/xlings.cppm` 的注释写明了为什么是 `.5` 而不是 `.4`:

> 2026.8.27.4 和 .5 都改成读索引,因此保持一致。**`.5` 还让声明在解析时压过索引,
> 所以即使 `latest` 不是表里最高的那条,它也成立。**

`.5` 之下(≤ `.4`)那条「声明压过索引」的行为没有。同一段注释还记录了 `.5` 作为
**下限**要挡住的故障:低于 `2026.8.27.2` 的 xlings 从编译进去的常量取 runtime binding,
于是一个 home 可以声明一个 glibc、装另一个,而报错的是 mcpp:

```
error: selected RuntimeBinding glibc@2.44 requires payload
       '<store>/xim-x-glibc/2.44', but it is not installed
```

`kXlingsVersion` 是**全仓每一处 xlings pin 的唯一真源**,`check_version_pins.sh` 会强制
`.github/` 下所有地方与它一致 —— 下调会同时改动 release/CI/bootstrap 的十几处。

### 15.3 那条 warning 的正确解法不是下调

本地看到的

```
Note vendored xlings 2026.8.27.4 is older than the pinned 2026.8.27.5,
but no newer source is available (keeping it; run `xlings self update`)
```

说的是**随 mcpp 发行版打包进去的那份 vendored 副本**是 `.4`,不是说 `.5` 拿不到 ——
`.5` 有 8 个 release asset,可下载。这条消息自己给了解法:`xlings self update`。
把 pin 降到 `.4` 只会让「pin 与 vendored 一致」,代价是整个生态退回到没有
「声明压过索引」的那个版本。

**结论**:保持 `2026.8.27.5`。若确实要下调,那是一次独立的、影响 release/CI/bootstrap
的变更,应当单独评估,不该搭在本方案里顺带做。

---

## 16. V5 已验证:合并 #713 之后 constructor 可以删

§4 把「删 constructor」定义成一个**机械准入条件**而不是判断题。现在它通过了。

### 16.1 做法

把合并后的状态在本地模拟出来:`libs/graphics.lua` + `pkgs/m/mesa.lua` 的 #713 版本
复制进 `~/.mcpp/registry/data/xim-pkgindex`,再 `xlings install xim:mesa@25.0.7.2`
让 `config()` 重跑:

```
mesa vars: ['LIBGL_DRIVERS_PATH', '__EGL_VENDOR_LIBRARY_DIRS', 'XDG_DATA_DIRS', 'GBM_BACKENDS_PATH']
<registry>/subos/default/usr/lib/gbm/dri_gbm.so
```

然后走**真实依赖路径**(`[dependencies.compat] libgbm`,无 `[xlings]`、无 `ldflags`,
`#include <gbm.h>`),经 CN 镜像冷跑:

```
XRGB8888 -> XR24
GBM_BACKENDS_PATH = /home/speak/.mcpp/registry/subos/default/usr/lib/gbm
```

### 16.2 为什么这一行就是证明

值是 **subos 路径**,不是包自己的 farm(`…/compat-x-libgbm/…/mcpp_generated/libgbm/lib/gbm`)。
constructor 的实现是 **`if (getenv("GBM_BACKENDS_PATH")) return;`** —— 只在未设置时才写。
既然进程里读到的是 subos 的值,说明**在 constructor 运行之前它已经被生态设好了**,
constructor 这一步是空转。

对比同一个包在**未打补丁**的索引下(本文档 §12.4 之前的所有测量),同一条路径给出的是
包内 farm 的值 —— 差别只有一个变量:索引里有没有那一行 DISCOVERY。

### 16.3 为什么现在还不能删 —— ⚠ 已过时,#713 已合并,constructor 已删除(见 §18)

`#713` 尚未合并,artifact 也没重新发布。删了之后:

* 用**已发布索引**的消费者拿不到 `GBM_BACKENDS_PATH`,`gbm_create_device()` 回到返回 NULL;
* mcpp-index CI 会红 —— `tests/stock_usage.cpp` 断言的正是「只 include `<gbm.h>` 的消费者
  能拿到这个变量」,而 CI 用的是已发布的 xim 索引。

**这正是我们想要的顺序保证**:准入条件由 CI 机械把关,而不是靠人记得。

### 16.4 合并之后的收尾(一步)

`#713` 合并 + artifact 重新发布后,在 `pkgs/c/compat.libgbm.lua` 删掉:

* `generated_files`/`install()` 里写的 `mcpp_generated/gbm_backends.c` 整个 TU
  (constructor + `mcpp_gbm_backends_dir` + `mcpp_gbm_use_sibling_backends`);
* `install()` 里的后端 farm(`lib/gbm/` 那段与 `mesa_libdir()` 辅助函数);
* `mcpp_gbm.h`,以及 `include_dirs` 中对它的依赖(`gbm.h` 仍从 subos view 取);
* `tests/gbm.cpp` 里与 constructor 相关的断言(§0 的「入口即已设置」改为断言来源是 subos;
  re-exec 那条随 constructor 一起删)。

`tests/stock_usage.cpp` **原样保留** —— 删掉 constructor 之后,它断言的就从
「本包的 constructor 生效了」变成「**整条生态闭环生效了**」,是这个包最有价值的一条回归。

---

## 17. §14.2 的更正,以及真正该做的下一步

§14.2 把 `compat.libdrm` 列为「最该先做的那个」,理由是它能关掉
`compat.vulkan-runtime` 从宿主 harvest `libdrm*.so.*` 那条边。**这个理由是错的**,
而查错的过程指向了一个更好的下一步。

### 17.1 为什么那个理由不成立

`compat.vulkan-runtime` 的农场存在的原因是:被 `dlopen` 的 **ICD 本身来自宿主**,
而它有自己的 `DT_NEEDED`(libdrm、LLVM、xcb…),这些必须在同一个目录里解析得到。
所以那里需要的是**宿主兼容的共享库**。

一个索引内源码构建的 `compat.libdrm` 是**静态**包(索引里的 `compat.*` 都是),
**满足不了一个 `.so` 的 `DT_NEEDED`**。所以它根本替代不了那条边 —— 我把「有个包叫
libdrm」和「农场里那条 `libdrm*.so.*` 需求」当成同一件事了,它们不是。

`compat.libdrm` 仍然可能有价值(给**构建期**消费者,例如将来若真要源码建 GBM 前端),
但**不是**因为它能关掉 vulkan-runtime 的 host 边。

### 17.2 真正该做的下一步:vulkan-runtime 走 glx-runtime 走过的那条路

实测 `xim:mesa` 的 payload:

```
share/vulkan/icd.d/radeon_icd.x86_64.json
lib/libvulkan_radeon.so
```

而 `mesa.lua` 的 `config()` 里已经有:

```lua
graphics.declare_vulkan_icd(dir, "share/vulkan/icd.d", tag)
```

配合 DISCOVERY 的 `XDG_DATA_DIRS`(Vulkan loader 搜 `$XDG_DATA_DIRS/vulkan/icd.d`),
**生态已经能 hermetic 地提供 RADV 这一条 ICD**。

而 `compat.vulkan-runtime` 至今 `deps = {}`,并且照旧从
`/usr/lib/x86_64-linux-gnu` 一把抓 `libvulkan_*.so` / `libdrm*.so.*` / `libLLVM*.so.*` …
—— **这正是 2026.08.08 之前 `compat.glx-runtime` 的处境**:生态自己有了,包却还在够宿主。

`glx-runtime` 当时的修法就是答案:声明 `deps = { runtime = { "xim:graphics" } }`,
从生态栈取,宿主那扇门只留给生态覆盖不到的厂商(它保留 `MCPP_HOST_GL_LIBRARY_PATH`
并在注释里写明代价)。

**但要诚实的一点**:生态的 Vulkan 覆盖目前**只有 AMD**(RADV)。`mesa.lua` 自己写着
「anv(Intel Vulkan)与 NVK 仍然不在这里」。所以 vulkan-runtime **不能**像本方案对
`compat.libgbm` 那样做到「零 host」,它应当变成 glx-runtime 那个形态:
**生态优先 + 宿主兜底**,而不是现在的**只有宿主**。

### 17.3 收益与排序

| 候选 | 关掉的 host 边 | 依据 |
|---|---|---|
| **vulkan-runtime 接 `xim:mesa`** | AMD 机器上的 ICD + 其整条传递闭包(libdrm/LLVM/xcb…) | 生态已有 RADV,机制已有 `declare_vulkan_icd` |
| `compat.libdrm` | **无**(见 17.1) | 仅构建期价值 |

所以下一步是 **vulkan-runtime**,不是 libdrm。这与本方案的主线是同一条:
**先问「生态是不是已经拥有它」,再决定是 vendor、绑定、还是够宿主。**


---

## 18. 最终状态(2026-08-30,#713 合并之后)

§16.4 列的那一步已经做完了。

### 18.1 包最终长什么样

| | 行数 |
|---|---|
| 带 constructor 的形态 | 598 |
| **最终** | **303** |

删掉的:`gbm_backends.c`(constructor + 两个 helper)、`lib/gbm/` 后端 farm、
`mesa_libdir()`、`mcpp_gbm.h`,以及为它们辩护的那段注释。

剩下的就是一个绑定:`deps = { runtime = { "xim:mesa" } }`、一个把
`gbm.h` 与 `libgbm.so*` 从 subos view 软链出来的 `install()`,加上
`include_dirs` / `ldflags` / `runtime.{library_dirs,link_library_dirs}`。
**它不编译任何上游源码、不带自己的头文件、不设任何环境变量。**

设 `GBM_BACKENDS_PATH` 从来就是 Mesa 自己的机制、而且是**环境**的职责;
包去做那件事的那个版本是权宜之计,不是设计。

### 18.2 验证(对着**已发布**的 artifact,不是本地打补丁的副本)

`xlings update` 从发布的 artifact 同步索引 → 重装 `xim:mesa` → `config()` 重跑:

```
mesa vars: ['LIBGL_DRIVERS_PATH', '__EGL_VENDOR_LIBRARY_DIRS', 'XDG_DATA_DIRS', 'GBM_BACKENDS_PATH']
<registry>/subos/default/usr/lib/gbm/dri_gbm.so
```

`mcpp test -p libgbm`(CN 镜像,冷跑):**2 passed**,且

```
backends dir: <registry>/subos/default/usr/lib/gbm      ← subos 给的,不是包给的
```

### 18.3 测试现在守的是什么

两个二进制断言的对象**移到了本仓之外**,这是刻意的:

| 断言 | 一旦谁坏了会红 |
|---|---|
| `GBM_BACKENDS_PATH` 已设置 | xim-pkgindex 的 DISCOVERY 行被删 / mcpp 停止注入 subos env |
| 它指向的目录里有 `*_gbm.so` | `xim:mesa` 不再把后端放进 subos |
| `GBM_BO_FORMAT_XRGB8888`(值 0)→ `"XR24"` | 头与库来自不同 Mesa |

所以这个 member 现在是**整条生态链的绊线**,而不只是这个包的自测。

### 18.4 顺带修掉的一个更大的问题

`index.toml` 的 `min_mcpp = 2026.8.3.3` 是**假的**,而且是本包证明的 —— 详见提交
`feat(libgbm): the package sheds its workaround; index floor corrected`。
已上调到 `2026.8.27.2`,同时把「floor 与 CI pin 一起动」这条早已漂移的不变量恢复了。
