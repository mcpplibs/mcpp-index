# Vulkan 跨平台闭环 —— mcpp / xlings 生态

日期:2026-09-11 · 状态:**Windows / xlings / CI 已实施并实测;macOS 已实测,落地需要 mcpp 一项能力**
涉及:`mcpp-index`、`xim-pkgindex`、`xlings-res`、`mcpp`(仅 macOS 部署)

本文最初是一份待 review 的设计。实施过程中有几处原方案被实测否定或被更简单的既有机制取代,
所以现在它记录的是**做了什么、测到了什么、和原设计哪里不同、为什么**。原设计中仍成立的部分保留。

---

## 0. 结论

| | 开发者侧不报错 | `mcpp pack` 分发能跑 | xlings 分发能跑 |
|---|---|---|---|
| **Windows,有显卡驱动** | ✅ | ✅ | ✅ |
| **Windows,无显卡驱动**(用户重点) | ✅ 实测 | ✅ 实测(干净目录) | ✅(分发 pack 产物即可;xim 包亦有 1.4.357) |
| **Linux** | ✅ 实测 | ✅(RPATH,既有) | ✅(既有) |
| **macOS,无 MoltenVK** | ✅ 实测:不崩溃,设备数 0 | ⚠️ `mcpp pack` 目前**拒绝打包 Mach-O 程序**(mcpp 自身限制,与 Vulkan 无关);分发构建目录可运行 | ✅ 不崩溃 |
| **macOS,要真实设备** | ⚠️ 需 mcpp#615 的部署能力;当下 `VK_DRIVER_FILES` 实测可用 | ⚠️ 同上,且依赖 pack 支持 Mach-O | ⚠️ 机制具备(xim:moltenvk + shim `envs` 设 `VK_DRIVER_FILES`),`VK_DRIVER_FILES` 路径实测可枚举设备,未经 xlings 端到端 |

"无驱动 Windows 上 `0xC0000135` 启动即崩"这一核心问题已消除,并在没有任何系统 loader 的
`windows-2022` 上,对 `mcpp build`、`mcpp test`、`mcpp pack` 后在干净目录运行三种情形逐一实测。

---

## 1. 目标(不变)

1. **开发者侧不报错。** 三平台开发 Vulkan 库/应用,`mcpp build`/`mcpp test` 不应构建或启动失败。
2. **分发能跑。** `mcpp pack` 产物、经 xlings 分发的程序,在目标机器上能启动。

---

## 2. 前提:三层,以及两种不同的故障

| 层 | 缺失后果 | 可否随程序分发 |
|---|---|---|
| **Loader**(`vulkan-1.dll` / 静态 loader) | 进程在 `main` 之前死(Windows `0xC0000135`) | 可以(Apache-2.0) |
| **ICD**(驱动) | 正常启动,`vkCreateInstance` 返回 `VK_ERROR_INCOMPATIBLE_DRIVER`,设备数 0 | 厂商驱动不可;MoltenVK / lavapipe 可以 |

**设计目标:让所有故障都落在第二种。** 这一条贯穿实施,且已在 Windows 与 macOS 上实测成立。

---

## 3. 实施了什么

| PR | 内容 | 状态 |
|---|---|---|
| mcpp-index **#395** | `compat.vulkan` **1.4.357.3**:Windows 产物带 `bin/vulkan-1.dll` + `LICENSE.txt`;`mcpp.windows.runtime.library_dirs = {"bin"}`;`compat.eui-neo` **0.5.9.1**(vulkan feature 改 pin);成员 pin;`tests/examples/vulkan` 在 Windows 上断言 loader 就在 exe 同目录;修 eui-neo install hook | 见 PR |
| mcpp-index **#394** | PR 不再自动升级为全量 CI(仅 cron / 手动) | 已合 |
| mcpp-index **#392** | mysql-connector-cpp:stdlib 限制写明 + llvm 腿跳过 | 已合 |
| xim-pkgindex **#821** | `vulkan-loader` windows **1.4.357**、`latest` 指向它;install 目录由版本推导;声明平台版本分叉 | 已合 |
| xlings-res/vulkan-loader | release **1.4.357**:Windows loader,由 runner 构建并 LoadLibrary 自检 | 已发布 |
| xlings-res/vulkan-import | release **1.4.357.3**:扁平产物(见 §5.1) | 已发布 + CN 镜像 |
| mcpp-index #391 | CI 往 System32 放 DLL | **已关闭**:会掩盖真实修复 |
| mcpp-index #396 | 临时探针(Windows pack、macOS ICD 发现),runs 34610618549 / 34611138464 | 已关闭,结论见 §5 |
| mcpp-community/mcpp **#615** | macOS:让依赖把 `.dylib` 与子目录里的 ICD 清单部署到可执行文件旁(附实测) | 已提 |

后续(依赖 #395 合入并发布索引):`khronos.vulkan-hpp` **1.4.357.1** 改 pin + `vulkan-hpp-module` 成员(§4.4)。

---

## 4. 与原设计的偏差,以及原因

### 4.1 没有新建 `compat.vulkan-loader` 包 —— 用 openblas 的既有形状

原设计打算新建一个 `compat.vulkan-loader`,经 `xim:vulkan-loader` 依赖取 payload。实施时发现
**同一件事已经有被 CI 验证过的先例**:`compat.openblas`(mcpp #185 / v0.0.73,mcpp-index #55)——
compat 描述符自己的 `xpm.windows` 直接指向一个扁平预编译包,`mcpp.windows.runtime.library_dirs =
{"bin"}` 让 mcpp 把 DLL 拷到可执行文件旁。

于是 DLL 直接放进 `compat.vulkan` 自己的 Windows 产物。**每个已经依赖 compat.vulkan 的消费者自动获得它,
不需要任何人新增依赖边。**

### 4.2 放弃 `xpm.<platform>.deps` 路线(原设计 §3.4 的判断被坐实)

#391 首版在 `compat.vulkan` 的 windows 块声明 `deps = { "xim:vulkan-loader@>=1.4.313" }`,三次运行零效果、
零诊断(冷存储 / 热存储 / 删光缓存后冷跑)。该路径在本索引中:**linux 20 个包使用,windows 2 个,
且那 2 个没有任何成员在 Windows 上测**。§4.1 的做法完全不经过它。

### 4.3 必须升版本号,不能原地改 pin

已安装的副本记录着它解析时的 pin。原地改 pin 到不了热存储——#391 第二次运行就是这样:热缓存保留
`compat.vulkan@1.4.357.0`,闭包从不重新求值,loader 根本没装。与 compat.vulkan 1.4.357.1 的规则一致。

`mcpp` 表是版本无关的,所以新增 `library_dirs = {"bin"}` 对旧版本也可见;旧版本产物没有 `bin/`,
mcpp 对不存在的运行期目录直接跳过(`plan.cppm`:`if (!is_directory) continue`),对它们无效果。

### 4.4 `khronos.vulkan-hpp` 拆到后续 PR

`vulkan-hpp-module` 只把 `khronos` 命名空间重定向到本 checkout,`compat` 来自**已发布**索引,
而 1.4.357.3 在 #395 合入前并不存在:

```
xlings install_packages failed (exit 1) for 'compat.vulkan@1.4.357.3'
with 1 index repo configured [mcpplibs -> https://github.com/mcpplibs/mcpp-index.git]
```

尝试同时重定向 `compat`,被拒绝:

```
≥2 project-level index repos is a known xlings resolution gap
(mcpp #238; root cause openxlings/xlings#374)
```

**注意:mcpp#238 与 xlings#374 均已关闭(2026-07-18/19),但 mcpp 2026.9.11.2 自带的 xlings 上仍能复现。**
要么修复未进入 vendored xlings,要么有回归。这是一条独立的待查项(§6)。

### 4.5 能力名(`vulkan.loader`)暂未引入

原设计 §5.2 提议新增 `vulkan.loader` 能力。实施中确认 mcpp 对未满足的能力**不会**构建期报错
(`vulkan.icd.driver` 在 macOS/Windows 上一直未被满足,构建照常成功),所以新增一个"需求"
既不能带来原设计 L3 想要的诊断,反而有误导性。loader 的供给改为由产物本身保证(§4.1)。

### 4.6 CI 往 System32 放 DLL 的方案被放弃

#391 第二版在 CI 里供给 loader。它能让 windows 腿变绿,**但无论包是否正确都会变绿**。
`windows-2022` 恰好没有系统 loader,是验证"无 vulkan dll 的 Windows"的理想环境,不应被掩盖。

---

## 5. 实测

### 5.1 产物与兼容性

`xlings-res/vulkan-import` **1.4.357.3**,sha256 `8118f1bd897e553baffabf484a14db980ce1f0a6cfdb5a6222c0a236ecdf12f5`:

| 文件 | 来源 |
|---|---|
| `bin/vulkan-1.dll` | tag `vulkan-sdk-1.4.357.0`,xlings-res/vulkan-loader windows workflow(run 34608619850),构建时 LoadLibrary 并解析 `vkEnumerateInstanceVersion` / `vkCreateInstance` / `vkGetInstanceProcAddr` |
| `lib/vulkan-1.lib` | 与 1.4.357.1 产物**字节一致** |
| `vulkan-1.def` | 上游原样 |
| `LICENSE.txt` | Vulkan-Loader Apache-2.0 —— 分发二进制须附许可证 |

- 确定性打包(排序、固定 mtime、数值 owner、`gzip -n`),两次 sha 一致;GitHub 回读一致;gitcode 镜像字节一致
- **导出表:DLL 导出与 `vulkan-1.def` 的 265 个名字完全一致,差集 0**(`llvm-readobj --coff-exports`)。
  早先担心的"新导入库配旧 DLL → 找不到入口点"不存在;1.4.313 的 DLL 同样是这 265 个
- PE:`IMAGE_FILE_MACHINE_AMD64`,自报版本 1.4.357

### 5.2 mcpp 部署机制(本地,mcpp 2026.9.11.2)

| 验证 | 结果 |
|---|---|
| 传递依赖 `app → mid → dep(bin/vulkan-1.dll)` | DLL 部署到 `app` 旁 ✅ |
| `mcpp test` 的测试二进制 | DLL 部署到测试可执行文件旁 ✅ |
| `pack.cppm` | PE 闭包"始终搜索产物自身目录";`vulkan-1.dll` 不在 `kPeSystem` 白名单(`opengl32`/`d3d12`/`dxgi` 在)|

### 5.3 Windows(探针 #396,`windows-2022`,**已确认无系统 loader**)

```
no system vulkan-1.dll: confirmed
-- mcpp build, 原地运行 --
PROBE: loader api 1.4.357
PROBE: vulkan-1.dll = D:\a\_temp\vkprobe\target\x86_64-windows-msvc\...\bin\vulkan-1.dll
PROBE: portability_enumeration=1 vkCreateInstance=-9
PROBE: devices=0 (no instance)
-- mcpp pack --
archive: target/dist/vkprobe-0.1.0-x86_64-pc-windows-msvc.zip
   741376  vkprobe-0.1.0-x86_64-pc-windows-msvc/vulkan-1.dll
-- 解压到干净目录,PATH 只有 System32 --
PROBE: loader api 1.4.357
PROBE: vulkan-1.dll = D:\a\_temp\clean-run\vkprobe-0.1.0-x86_64-pc-windows-msvc\vulkan-1.dll
PROBE: devices=0 (no instance)
```

`-9` = `VK_ERROR_INCOMPATIBLE_DRIVER`:无 ICD 的机器的正确状态,不是故障。

#395 自己的 CI(`windows-2022`,同一台无 loader 的镜像)上,两个被判定的成员:

```
Downloading compat.vulkan v1.4.357.3
compat.vulkan: loader deployed beside the executable (...\tests\examples\vulkan\target\x86_64-windows-msvc\...\bin\vulkan-1.dll)
compat.vulkan: ok (loader api 1.4.357, 4 loader extension(s), WSI trampolines linked)

Downloading compat.eui-neo v0.5.9.1
Downloading compat.vulkan v1.4.357.3
compat.eui-neo[vulkan]: ok (backend=vulkan, loader api 1.4.357)
```

第一条来自 `tests/examples/vulkan` 新增的断言:加载的 `vulkan-1.dll` 必须与 exe 同目录。第二条是经
eui-neo 的 feature 传递依赖到 compat.vulkan 的路径。同一腿上 `vulkan-hpp-module` 仍失败,原因如 §4.4
所预测:它从已发布索引解析到 compat.vulkan 1.4.357.0。

### 5.4 Linux(本地)

`vulkan`(compat.vulkan 1.4.357.3,loader api 1.4.357)、`eui-neo-vulkan`(eui-neo 0.5.9.1 → compat.vulkan
1.4.357.3,`backend=vulkan, loader api 1.4.357`)均通过。

### 5.5 macOS(探针 #396,`macos-15` arm64)

CoreFoundation 对未打包可执行文件:

```
PROBE: bundle url    = /Users/runner/work/_temp/cfprobe/bin
PROBE: resources dir = /Users/runner/work/_temp/cfprobe/bin     ← 就是 exe 所在目录
```

静态 loader(`APPLE_STATIC_LOADER`)在 `loader.c` 中把 `<resources dir>/vulkan/icd.d` 放在搜索路径最前。

| 场景 | 退出 | 结果 |
|---|---|---|
| A 无 MoltenVK | 0 | `vkCreateInstance=-9`,"Found no drivers!",设备 0 —— **不崩溃** |
| B `bin/libMoltenVK.dylib` + `bin/vulkan/icd.d/MoltenVK_icd.json`(`library_path: "../../libMoltenVK.dylib"`) | 0 | `vkCreateInstance=0`,**devices=1,Apple Paravirtual device** |
| B2 同上,绝对路径 | 0 | devices=1 |
| B3 **把整个 `bin/` 拷到别处**再运行 | 0 | 在新位置找到清单,**devices=1 —— 布局可随程序迁移** |
| C `VK_DRIVER_FILES`(xim:moltenvk 文档的方式) | 0 | devices=1 |

所有设备枚举都要求实例启用 `VK_KHR_portability_enumeration` 并设置
`VK_INSTANCE_CREATE_ENUMERATE_PORTABILITY_BIT_KHR`——这是消费方 API 层的事,包无法代劳。

---

## 6. 仍未闭环的部分

| 项 | 性质 | 去向 |
|---|---|---|
| **macOS 部署 MoltenVK** | mcpp 目前只把 `*.dll` **平铺**拷进 `bin/`;macOS 需要 `.dylib` 与 `vulkan/icd.d/` **子目录**。§5.5 B3 证明该布局可行且可迁移,缺的只是部署能力 | **mcpp#615** |
| **`mcpp pack` 拒绝 Mach-O 程序** | "cannot package the Mach-O program … yet":闭包靠 `LD_TRACE_LOADED_OBJECTS` 解析,dyld 不认。与 Vulkan 无关,但决定了 macOS 上 pack 这条分发路径目前不存在 | mcpp 既有限制 |
| 双项目 indices 仍失败 | mcpp#238 / xlings#374 已关闭,2026.9.11.2 上仍复现 | 待查,可能是 vendored xlings 回归 |
| `APPLE_STATIC_LOADER` 为上游不支持的配置 | CMake 原话:"not supported or tested as part of the loader. Use it at your own risk" / "only exists at the request of Google for Chromium. No other project should use this!" | 风险记录;§5.5 实测未见问题 |
| exe 旁的 loader 优先于系统 loader | 用户驱动若带更新版本,用的仍是我们的 1.4.357;ICD 仍是用户的驱动,导出表稳定,但更新的 loader 级扩展不可用 | 已知代价,所有 bundling 应用共担 |
| 同进程双 loader | 应用带一份、注入的插件加载系统那份 | 业界已知问题,无通用解 |
| gitcode `xlings-res/vulkan-loader@1.4.357` 有一个误名资产 `loader357.zip` | 首次上传用错了文件名;gitcode 资产不能经 API 删除 | 需网页删除;描述符指向正确命名的资产 |

---

## 7. 实施中发现并修复的 bug

| 位置 | 问题 | 修复 |
|---|---|---|
| `compat.eui-neo` install hook | 用包版本拼上游目录名:`0.5.9.1` 找 `EUI-NEO-0.5.9.1/`,而归档是 `EUI-NEO-0.5.9/`,报 "neither wrapped nor flat" | 查找前剥掉第四段(实测 `0.5.9.1→0.5.9`、`1.2.3.45→1.2.3`、`0.5.10`/`0.5.9-rc1` 不变) |
| `xim:vulkan-loader` install | 写死目录 `vulkan-loader-1.4.313`;加第二个版本就会移动空目录 | 由版本推导,缺失即报错 |
| 描述符注释 | `compat.vulkan` 头部与 windows `runtime` 仍写着"DLL 随显卡驱动来,不随我们" | 按 1.4.357.3 修正 |
| `tests/examples/vulkan` 注释 | "compat.vulkan has no windows entry" 早已不实 | 删除 |

两处 hook bug 同属一类:**hook 从版本号推导路径,只在第二个版本共用同一个归档之前成立。**

---

## 8. 附:参考

| | |
|---|---|
| mcpp `src/build/plan.cppm` | `runtimeDeployFiles`:依赖 `runtime.library_dirs` 下的 `*.dll` → `bin/<filename>` |
| mcpp `src/pack/pack.cppm` | PE 闭包搜索产物自身目录;`kPeSystem` 白名单 |
| mcpp `.agents/docs/2026-06-29-windows-runtime-dll-deployment-and-openblas.md` | 部署机制的原始设计 |
| Vulkan-Loader `loader/loader.c` | macOS 下 bundle Resources + `vulkan/icd.d` 搜索 |
| mcpp-community/mcpp#609 / microsoft/STL#6294 | windows-2022 钉子的起因 |
| mcpp-community/mcpp#614 | `XLINGS_PROJECT_DIR` 的 Windows/POSIX 不对称 |
