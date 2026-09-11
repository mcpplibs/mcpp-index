# Vulkan 跨平台闭环设计 —— mcpp / xlings 生态

日期:2026-09-11 · 状态:**设计待 review,未实施**
涉及:`mcpp-index`、`xim-pkgindex`、`mcpp`(仅诊断层需要其配合)

---

## 1. 目标

两条,来自用户,按优先级:

1. **开发者侧不报错。** 在 linux / macOS / windows 上开发 Vulkan 相关的库和应用,
   `mcpp build` / `mcpp test` 不应出现构建或启动失败。若环境确实不具备条件,
   必须在**构建期**给出可操作的说明,而不是运行期崩溃。
2. **分发能跑。** `mcpp pack` 产出的程序、以及经 xlings 分发的程序,
   在目标机器上能启动并正常工作。

注意这两条的差别:第 1 条要的是**诊断质量**,第 2 条要的是**产物完整性**。
现状下两条都不满足,但原因不同。

---

## 2. 前提:Vulkan 运行期由三层组成

任何设计都必须先分清这三者,混为一谈是本文要避免的主要错误。

| 层 | 是什么 | 谁提供 | 可否随应用分发 |
|---|---|---|---|
| **Loader** | `vulkan-1.dll` / `libvulkan.so.1`。ABI 入口,做 trampoline 与分发 | Khronos,Apache-2.0 | **可以**,LunarG Runtime redistributable 即为此存在 |
| **ICD(驱动)** | 真正实现 Vulkan 的后端 | GPU 驱动厂商;或软件实现(lavapipe / SwiftShader / MoltenVK) | 厂商驱动**不可**;软件实现**可以** |
| **Layer** | validation、overlay(Steam/OBS/RTSS) | 各自安装 | 不涉及 |

发现路径:

- Windows:loader 从 `HKLM\SOFTWARE\Khronos\Vulkan\Drivers` 读 ICD 清单
- Linux:loader 搜 `$XDG_DATA_DIRS/vulkan/icd.d`
- macOS:无原生 Vulkan,ICD 只能是 MoltenVK(Metal 之上的翻译层)

**关键推论:loader 缺失和 ICD 缺失是两种完全不同的故障。**

- 缺 loader → 进程在 `main` 之前死,Windows 弹系统级"丢失 vulkan-1.dll",退出码 `0xC0000135`
- 缺 ICD → 进程正常启动,`vkEnumerateInstanceVersion` 正常返回,
  `vkEnumeratePhysicalDevices` 返回 0 个设备

第一种是"这软件坏了",第二种是"这台机器没有 Vulkan 驱动"。
**本设计的核心,就是让所有故障落到第二种。**

---

## 3. 现状:实测的缺口

### 3.1 mcpp-index 的声明

`compat.vulkan` 三个平台的 `mcpp.<platform>.runtime` 都声明了需求:

```lua
-- windows
runtime = {
    -- vulkan-1.dll ships with the GPU driver, not with us.
    dlopen_libs  = { "vulkan-1.dll" },
    capabilities = { "vulkan.icd.driver" },
},
```

linux / macosx 同样声明 `capabilities = { "vulkan.icd.driver" }`。

### 3.2 供给方只有一个

| 能力 | linux | macOS | windows |
|---|---|---|---|
| `vulkan.icd.driver` | ✅ `compat.vulkan-runtime` | ❌ 无 | ❌ 无 |
| loader 本体 | 源码静态编入 | 源码静态编入 | ❌ **无**(只链接导入库) |

**需求声明齐全,供给方缺两个平台。** 这是全部问题的根。

### 3.3 实测证据

`#387` 探针,run `34569282837`,三个 GitHub runner 镜像:

```
windows-2022       vulkan-1.dll absent     MSVC 14.29/14.44
                   huxerui-module PASS     vulkan FAIL 0xC0000135
windows-2025       vulkan-1.dll PRESENT    MSVC +14.51
                   huxerui-module FAIL     vulkan PASS
windows-latest     同 windows-2025
```

`0xC0000135` = `STATUS_DLL_NOT_FOUND`。`#392` 的全量矩阵在 windows 分片上独立复现。

macOS 未实测,但 `xim:moltenvk` 的描述符已写明:
"Without it a machine running macOS enumerates no Vulkan device at all,
and every macOS runner in this ecosystem is such a machine."

### 3.4 已失败的尝试(不要重走)

`#391` 第一版让 `compat.vulkan` 的 windows 块声明
`deps = { "xim:vulkan-loader@>=1.4.313" }`。**三次运行,零效果,零诊断:**

1. 冷存储 —— loader 装上了,其 `config()` 钩子失败(`subos.env`;已由 xim#819 修复)
2. 热存储 —— `compat.vulkan@1.4.357.0` 已安装,依赖闭包从不重新求值,loader 根本没装
3. 删光三份 registry 缓存后再冷跑 —— 依然没装,且没有任何报错

根因线索:`xpm.<platform>.deps` 的使用分布是
**linux 20 个包 / macosx 4 个 / windows 2 个**,
而 windows 那两个(`riscv-virt-rt`、`std-freestanding`)**没有任何 workspace 成员在 Windows 上测**。
即:**这是一条基本未被执行过的代码路径。**

**结论:Windows 的运行期供给不要走 `xpm.deps`,走 `runtime` 契约。**

---

## 4. 零件盘点 —— 需要的东西已经全部存在

这是本设计最重要的发现:**不需要新建任何 payload。**

| 平台 | loader payload | ICD payload |
|---|---|---|
| linux | `xim:vulkan-loader` (1.4.313) | `xim:mesa-lavapipe` (26.2.0)、`xim:mesa` |
| macOS | compat.vulkan 源码编译 | **`xim:moltenvk` (1.4.2)** |
| windows | **`xim:vulkan-loader` (1.4.313)**(2026-09-11 新增) | **`xim:mesa-lavapipe` (26.2.0) 有 windows 分支** |

`mesa-lavapipe` 的 windows 分支是完整实现:处理 `vulkan_lvp.dll`,
并把 ICD JSON 里的 `library_path` 改写成 Windows 路径(含对 `\U` 转义的处理)。

mcpp 侧的机制也齐了:

- `plan.cppm` / `runtimeDeployFiles`:把依赖 `runtime.library_dirs` 下的每个 `*.dll`
  **拷到所生成可执行文件旁边**(`bin/`)。过滤条件是 `.dll` 后缀而非平台判断,
  所以非 Windows 平台自动为空
- `pack/binfmt.cppm` / `kPeSystem`:`vulkan-1.dll` **不在**系统 DLL 白名单里
  (`opengl32.dll`、`d3d11/12.dll`、`dxgi.dll` 在)。
  **所以 pack 已经会把它当作必须随包携带的库处理**
- `compat.glx-runtime` 有现成的未满足诊断文案:
  `"... is published by no installed payload ... Add the ecosystem package that provides it"`

**缺的只有 mcpp-index 里的接线。**

---

## 5. 设计

### 5.1 三层职责

```
L1 供给层   谁提供 loader / ICD           →  新增 compat.* 包,依赖已有 xim payload
L2 部署层   怎么到 exe 旁边 / 进 pack     →  runtime.library_dirs(已有机制)
L3 诊断层   未满足时说人话                →  capabilities 未供给时构建期报错
```

### 5.2 能力命名

现有 `vulkan.icd.driver` 只描述了 ICD。**loader 需要一个独立的能力名**,
因为两者的故障形态和可分发性都不同:

| 能力 | 含义 | 缺失后果 |
|---|---|---|
| `vulkan.loader` | 进程能找到 `vulkan-1.dll` / `libvulkan.so.1` | 启动即崩 |
| `vulkan.icd.driver` | 至少有一个可用 ICD | 设备数为 0 |

### 5.3 关键决策:loader 总是供给,ICD 绝不默认供给

**loader —— 总是供给。**

- 构建机 ≠ 运行机。构建期探测"宿主有没有 loader"是不成立的:产物会被拷走
- "有时带有时不带" = 同源码在两台机器上产出不同二进制,支持成本极高
- 代价:我们的 loader 是 1.4.313,若用户驱动带了更新版本,
  exe 旁边的会赢(Windows DLL 搜索顺序 exe 目录优先)。
  loader 对 ICD 向后兼容、会正常读注册表找到显卡驱动,
  但**更新的 loader 级扩展**我们这份没有。这是所有 bundling 应用共同的代价,可接受

**ICD —— 绝不默认供给,显式 opt-in。**

- 在 linux / windows 上,真正的 GPU 驱动应该赢。
  默认塞一个软件光栅器(lavapipe)会**掩盖"驱动没装"**,
  并给出灾难性的性能,用户还不知道为什么
- 因此 lavapipe 只作为 feature / 显式依赖提供,供 CI 和无头环境使用

**macOS 是唯一例外:MoltenVK 是必需依赖,不是 fallback。**
macOS 上没有别的 Vulkan 实现,不带 MoltenVK 就等于没有 Vulkan。

### 5.4 每平台接线

#### linux(基本已完成,只补 loader 能力名)

```
compat.vulkan (linux)
  ├─ loader:源码静态编入(已有)         → provides vulkan.loader
  └─ capabilities: vulkan.icd.driver     → compat.vulkan-runtime 提供(已有)
```

改动:`compat.vulkan` 的 linux `runtime` 增加 `provides = { "vulkan.loader" }`。

#### windows(主要工作量)

**新增 `compat.vulkan-loader`(windows only):**

```lua
xpm = { windows = { ["1.4.313"] = { ... } } }   -- 或直接复用 xim payload
mcpp = {
    windows = {
        runtime = {
            library_dirs = { "bin" },            -- mcpp 据此把 vulkan-1.dll 拷到 exe 旁
            provides     = { "vulkan.loader" },
        },
    },
}
```

`compat.vulkan` 的 windows `runtime` 增加 `capabilities = { "vulkan.loader" }`,
并把该包列为 windows 依赖。

**ICD 保持不供给。** 有显卡驱动的机器照常工作;无驱动的机器程序能启动、设备数为 0。

#### macOS

**新增 `compat.moltenvk`(macosx only)**,依赖 `xim:moltenvk`,
`provides = { "vulkan.icd.driver" }`,并把 ICD JSON 放进 loader 能搜到的位置。

`compat.vulkan` 的 macosx 块把它列为依赖。

**额外必须做的一件事**(否则装了也没用):MoltenVK 的清单声明
`"is_portability_driver": true`,loader **不会**把 portability driver 交给
`vkEnumeratePhysicalDevices`,除非实例启用了
`VK_KHR_portability_enumeration` 并设置
`VK_INSTANCE_CREATE_ENUMERATE_PORTABILITY_BIT_KHR`。
这是**消费方 API 层的事**,包做不了。
→ `compat.vulkan` 的 macosx 路径必须在文档和构建期提示里写明这一点。

#### CI(与上述正交,已落地)

`mcpp-index` 的 windows 腿钉在 `windows-2022`(为绕开 MSVC STL 14.51 的
`_Find_vectorized` bug,见 mcpp#609 / microsoft/STL#6294),该镜像没有 loader。
`#391` 在 CI 里直接供给 loader —— 这是业界 CI 的通行做法,
与 L1/L2 的包级方案互不冲突,且先落地。

---

## 6. 改动清单

| # | 位置 | 改动 | 规模 |
|---|---|---|---|
| 1 | `mcpp-index/pkgs/c/compat.vulkan-loader.lua` | **新增**,windows only,依赖 `xim:vulkan-loader` | 中 |
| 2 | `mcpp-index/pkgs/c/compat.moltenvk.lua` | **新增**,macosx only,依赖 `xim:moltenvk` | 中 |
| 3 | `mcpp-index/pkgs/c/compat.vulkan.lua` | 三个平台的 `runtime` 补 `provides`/`capabilities`;windows/macosx 加依赖 | 小 |
| 4 | `tests/examples/vulkan/` | 增加"无 ICD 时设备数为 0 属正常"的断言;macOS 启用 portability | 小 |
| 5 | `mcpp-index/pkgs/c/compat.mesa-lavapipe.lua` | **新增**(可选),软件 ICD,显式 opt-in,供 CI | 中 |
| 6 | mcpp 诊断 | 能力未供给时的构建期报错文案 | 需 mcpp 配合 |

第 6 项若 mcpp 暂不支持,退化为包 `install()` 里的 `log.warn`,不阻塞前五项。

---

## 7. 分发路径的闭环

### `mcpp pack`

`vulkan-1.dll` 不在 `kPeSystem` 白名单 → pack 视其为必带库。
接线完成后,它来自**我们供给的受控版本**,
而不是"开发者机器上显卡驱动装的那一份"(当前行为,版本不受控)。

**待验证**:pack 是否从 `runtimeDeployFiles` 的产物目录取,
还是从系统路径解析导入表。这是本设计唯一未经实测的环节。

### xlings 分发

xlings 侧 payload 已具备(`xim:vulkan-loader` / `xim:moltenvk` / `xim:mesa-lavapipe`),
`selfcontain.seal`(ELF RPATH)在 linux 上已闭环;
Windows 无 RPATH,靠 exe 同目录,与上述 L2 一致。

---

## 8. 明确不做的事

| 不做 | 理由 |
|---|---|
| 默认塞软件 ICD | 掩盖"驱动没装",性能灾难且不可见 |
| 往 System32 写 DLL | 系统级副作用。仅 CI runner(一次性环境)可接受 |
| 走 `xpm.<platform>.deps` 实现 Windows 供给 | 三次实测无效、无诊断;该路径在本索引里基本未被执行过 |
| 改 `compat.vulkan` 为动态加载(volk 风格) | 是正确方向,但属于**接口变更**,影响所有消费方,应单独立项。见 §10 |
| 给 compat.vulkan 升版本号以强制重装 | 成员是精确 pin,会级联到 `khronos.vulkan-hpp`、`compat.eui-neo` 各自的版本 |

---

## 9. 验证计划

每一步都要有可失败的断言,不接受"CI 绿了"作为证据。

1. **L1 供给** —— 无驱动的 Windows 环境里,`mcpp build` 后
   `bin/vulkan-1.dll` 存在,且 sha 与我们的 payload 一致(不是系统那份)
2. **L1 启动** —— 同环境运行测试二进制,**退出码不是 `0xC0000135`**;
   `vkEnumerateInstanceVersion` 返回成功
3. **L1 设备** —— 同环境 `vkEnumeratePhysicalDevices` 返回 0 且**不崩溃**
4. **macOS** —— 装 `compat.moltenvk` 后,启用 portability 的实例
   枚举到 ≥1 个设备;不启用时枚举到 0(负向验证,证明门控真实)
5. **pack** —— `mcpp pack` 产出在一台**干净的**无驱动 Windows 上解包即跑
6. **负向** —— 故意不装 `compat.vulkan-loader`,
   确认得到的是**构建期的可操作提示**,而不是运行期崩溃

第 6 条是第 1 条目标(开发者侧不报错)的真正验收标准。

---

## 10. 风险与未决

| 项 | 性质 |
|---|---|
| pack 的 DLL 来源未实测(§7) | **需先验证**,否则第 2 条目标不能宣称闭环 |
| 我们的 loader 版本可能旧于用户驱动带的 | 已知代价,所有 bundling 应用共担 |
| 同进程内两个 loader 实例 | 应用带一份、插件(如 Steam overlay)加载系统那份时会出现,行为未定义。业界已知问题,无通用解 |
| macOS portability 位需要消费方配合 | 包无法代劳,只能文档 + 提示 |
| `xpm.windows.deps` 为何静默失效,根因未查明 | 独立于本设计,但影响任何想在 Windows 上声明安装期依赖的包,**建议单独提 issue** |
| 动态加载(volk / `VULKAN_HPP_DISPATCH_LOADER_DYNAMIC`) | 能把"缺 loader"从崩溃变成可读提示,是最彻底的解。属接口变更,单独立项 |

---

## 11. 与本设计相关的既有工作

| | |
|---|---|
| `openxlings/xim-pkgindex#818` | vulkan-loader 的 Windows payload(构建 + 发布 + LoadLibrary 自检) |
| `openxlings/xim-pkgindex#819` | 改用 `exports.runtime.libdirs` 声明 DLL 位置 |
| `mcpplibs/mcpp-index#391` | CI 侧供给 loader(本设计的 CI 正交部分) |
| `mcpplibs/mcpp-index#388` | 已关。四轮尝试用 runner 镜像绕开,不收敛 |
| `mcpp-community/mcpp#609` | MSVC STL 14.51 的 `_Find_vectorized`,windows-2022 钉子的起因 |
| `mcpp-community/mcpp#614` | `XLINGS_PROJECT_DIR` 在 Windows/POSIX 的不对称 |
| `microsoft/STL#6294` | 上游 |
