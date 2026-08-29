# GBM 闭环:mcpp / xim-pkgindex / mcpp-index 跨仓方案

Date: 2026-08-30 · 起因:`compat.libgbm`(mcpp-index PR #281)· 状态:待 review

## TL;DR

让 `gbm_create_device()` 在 mcpp 工程里能用,**不需要新机制**。所需的机制三层全都已经存在
并且已经在跑;缺的是**两个具体的接线点**,分别在两个仓:

| # | 缺什么 | 在哪个仓 | 规模 |
|---|---|---|---|
| **R1** | `GBM_BACKENDS_PATH` 不在 graphics 的 `DISCOVERY` 表里 | xim-pkgindex | 一个常量 + 一行表项 + 一个照抄 `declare_dri` 的函数 |
| **R2** | 默认 runtime selection 读的是**工具链 subos**,而项目的 `xim:` 依赖声明在**项目 subos** | mcpp | 一处选择/合并逻辑 |

R2 **不是 gbm 专属的**:同一条线上 `LIBGL_DRIVERS_PATH` 和 `__EGL_VENDOR_LIBRARY_DIRS`
也没到进程,也就是说**任何 mcpp 构建的 GL 程序都找不到 DRI 驱动**。gbm 只是让它显形。

R1 + R2 落地后,`compat.libgbm` 里的 constructor 与后端 farm **全部删除**,退化成一个
只有「头 + `-lgbm`」的薄壳。

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

两个方案,**建议 B1**。

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
