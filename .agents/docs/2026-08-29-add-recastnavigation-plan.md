# 新增 compat.recastnavigation

> 日期：2026-08-29 · 验证工具链：mcpp `2026.8.27.2`（与 `validate.yml` 的 `MCPP_VERSION` 对齐）

## 1. 动机

[Recast Navigation](https://github.com/recastnavigation/recastnavigation) 是游戏行业导航网格
事实标准：Recast 负责把关卡几何烘成导航网格，Detour 负责在网格上跑运行时寻路。Godot、
Unreal、O3DE、Bullet 等大量项目直接或间接依赖它。索引此前没有它，任何需要寻路的 mcpp
工程都得自己拖源码。

上游不提供 mcpp 支持，因此以 `compat` 形态（Form B 内联）适配。版本取最新 tag **v1.6.0**
（`git ls-remote --tags` 确认，旧 tag 为 1.5.1）。许可证为 **Zlib**（`License.txt`）。

本次**不做模块化**：用户明确要求以传统 `#include` 形态提供，不生成 `.cppm` 包装。这与
`nlohmann.json` 那条路不同 —— 后者是 header-only，不包装就无法 `import`；recastnavigation
是编译型库，`#include <recastnavigation/Recast.h>` 是它自己的安装契约，包装反而会与上游
ABI 和现有集成代码脱节。

## 2. 形态判定：**A**（源码 compat，C++ 版）+ 三个 source-gated feature

判定依据来自实际解包与试编译，而非读 CMake：

| 检查项 | 结论 |
|---|---|
| 可编译源码 | 5 个模块共 **30 个 `.cpp`**，全在 `<模块>/Source/` 下 |
| 外部依赖 | **无**。五个模块全部 `#include` 的并集 = 自身头文件 + `<float.h>` `<math.h>` `<new>` `<stdarg.h>` `<stddef.h>` `<stdint.h>` `<stdio.h>` `<stdlib.h>` `<string.h>` |
| configure 产物 | **无**。`version.h.in` 由 `configure_file()` 生成，但**源码树里没有任何文件 include 它**，纯属安装产物 |
| C++23 可编译性 | `clang++ -std=c++23 -Wall` 编译 30 个 TU **全部通过，零告警** |

因此不需要 `generated_files` 里的 config 快照（对比 `compat.msdfgen` 的 A+E）：这儿没有
「不生成就编不了」的头文件。唯一需要生成的是**转发头**，见第 4 节。

`-lm`：Recast 用到 `log()`（`RecastRegion.cpp`）与 `sqrtf/fabsf/ceilf/floorf/cosf/sinf`。
glibc 早于 2.34 时这些在独立的 libm 里，故 `linux` / `macosx` 各加一条 `ldflags = {"-lm"}`
（参照 `compat.nanosvg`）。

## 3. 五模块 → 一库三 feature 的切分

上游是五个独立 CMake target，依赖关联网状（`DebugUtils` → `Recast` + `Detour` +
`DetourTileCache`；`DetourCrowd` / `DetourTileCache` → `Detour`）。mcpp 的 feature 只能门控
`sources`，且所有 feature 编进**同一个 lib target**，没有 target 间依赖图。切分如下：

| 上游模块 | 归属 | 理由 |
|---|---|---|
| `Recast` | **核心** | 烘网格 |
| `Detour` | **核心** | 走网格。两者互不依赖，但几乎没有消费者只用一个 —— 拆成 feature 只会给最常用的组合加一道门槛 |
| `DetourCrowd` | feature `crowd` | 群体仿真与局部避障，真实项目完全可能不用 |
| `DetourTileCache` | feature `tilecache` | 流式 tile 与动态障碍 |
| `DebugUtils` | feature `debug-utils`，**`implies = { "tilecache" }`** | 调试绘制 |

`debug-utils` 必须 imply `tilecache`：上游 `DebugUtils/CMakeLists.txt` 无条件链接
`DetourTileCache`，其源码引用 `dtTileCache*` 符号。所有 feature 编进同一 lib，若只开
`debug-utils`，这些引用会变成**链接期 undefined reference**，而且是消费者侧的报错，很难
定位。`implies` 让「开 debug 绘制却拿不到 tilecache」这个状态不可表达。

### 3.1 两个刻意**不**做成 feature 的 CMake 选项

`RECASTNAVIGATION_DT_POLYREF64` 与 `RECASTNAVIGATION_DT_VIRTUAL_QUERYFILTER` 在上游是
`target_compile_definitions(... PUBLIC)`：前者改 `dtPolyRef` 的位宽，后者给 `dtQueryFilter`
加虚表。两者都改变**跨库边界类型的 ABI**。

feature 的 `defines` 只作用于**本包自己的 TU**，消费者看不到。若把它们做成 feature，就得到
「库按 A 编译、消费者按 B 编译」的 ODR/ABI 分裂，失败既晚又难查。故两者保持上游默认
（OFF），这也是所有二进制发行版的取值。这与 `compat.eigen` 的 `EIGEN_MPL2_ONLY`、
`compat.msdfgen` 的 `MSDFGEN_USE_CPP11` 是同一条规则。

## 4. include 拼写：两种都保留

上游自己的安装把五个模块的头文件**拍平**放进 `<includedir>/recastnavigation/`，且每个模块
的 `CMakeLists.txt` 都写着：

```cmake
INCLUDES DESTINATION ${CMAKE_INSTALL_INCLUDEDIR} ${CMAKE_INSTALL_INCLUDEDIR}/recastnavigation
```

即**两个目录都在 interface include path 上**，所以对着一份真实安装，`#include <Recast.h>`
与 `#include <recastnavigation/Recast.h>` 都合法 —— 这正是两种拼写都在野外存活的原因。

源码树内构建只能直接得到前者（`Recast/Include/Recast.h`）。为了让后者也成立，描述符生成
了 **26 个转发头**（25 个公开头 + `version.h`），每个只有两行：

```c
#pragma once
#include <Recast.h>
```

- `include_dirs` 列出五个模块的 `Include/` + `mcpp_generated`，两种拼写同时成立；
- `mcpp_generated` 在 include path 上，而 `mcpp_generated/recastnavigation/` 不在，因此
  `<Recast.h>` 不会自递归；
- `version.h` 按 `version.h.in` 实例化（`RECASTNAV_VERSION_NUM` 取上游的逗号形式
  `1,6,0,0`）。源码不 include 它，缺了也不会编译失败，但它是公开安装面的一部分。

这条与 `compat.msdfgen` 的做法一致。26 个文件采用转义单行字符串而非长括号：每个文件只有
两行，用 `[==[ ]==]` 包 26 次会把本该可审阅的清单埋进括号噪音里（多行、有实义的
`version.h` 仍用长括号）。

**注意**：feature 只能门控 sources，头无法隐藏。不开 `crowd` 时
`<recastnavigation/DetourCrowd.h>` 依然可 include，失败发生在**链接期**。这与
`compat.eigen` 的「纯头组件不可门控」是同一条限制。

## 5. CN 镜像

**未配置**。发布到 `mcpp-res` 需要 gitcode token，本次编写环境没有
（`~/.config/gitcode-tool/config.json` 不存在，`gtc` 亦不在 PATH）。按 `docs/zh/cn-mirror.md`
的回退方案，`url` 写作纯字符串，CN 用户回落到 GitHub 上游；`check_mirror_urls.lua` 允许此
形式（只校验表形式）。

后续有 `gtc` 权限的维护者可改为 `{ GLOBAL = ..., CN = ... }` 表形式，**上传的 tarball 必须与
GLOBAL 字节一致**，因此下列 sha256 不变：

```
d48ca0121962fa0639502c0f56c4e3ae72f98e55d88727225444f500775c0074
  https://github.com/recastnavigation/recastnavigation/archive/refs/tags/v1.6.0.tar.gz
```

该值经 `archive/refs/tags/` 与 `codeload` 两个 URL 各下载两次、`cmp` 确认字节一致后得出。

## 6. 验证

两个 workspace 成员，均含可失败断言并以 `return ok ? 0 : 1` 收尾。

### `tests/examples/recastnavigation`（核心构建）

地面是 20×20、**中间挖了 4×4 洞**的四块四边形，从 (2,2) 走到 (18,18) 必须绕行。逐项防住
「包坏了但测试依然绿」：

| 断言 | 防住的失败 |
|---|---|
| `nverts > 0` / `npolys > 0` | 栅格化出空网格 |
| 8 个三角形全部被标记为 walkable | 绕序反了（正常量朝下）。这是**静默**失败：不会报错，只会得到空网格 |
| `findStraightPath` 点数 ≥ 3 | 洞没进网格 / 网格是一整块方形，路径穿洞而过 |
| 终点距目标 < 2.0 | findPath 提前截断 |
| 路径长度 > 直线距离 + 0.5 | 同上，独立复核 |

递归测试同时**混用两种 include 拼写**：Recast 走生成的 `recastnavigation/` 前缀，Detour 走
`<DetourNavMesh.h>` 裸拼写。只有一种能用时，shim 层就是未被覆盖的。

### `tests/examples/recastnavigation-features`

依赖**只声明 `features = ["crowd", "debug-utils"]`，不写 `tilecache`** —— 这是刻意的：它同时
验证了第 3 节的 `implies` 链，链一旦失效，本成员在**链接期**失败。

- **crowd**：加一个 agent，请求移动目标，跑 400 步 `update(1/60)`，断言它离目标近了 5 米
  以上（真走了，不是原地不动）；
- **tilecache**：`rcBuildHeightfieldLayers` → `dtBuildTileCacheRegions/Contours/PolyMesh`
  （builder 半边）→ 自制 passthrough compressor → `dtBuildTileCacheLayer` → `addTile` →
  `buildNavMeshTile`，再断言 tile **能回答 `findNearestPoly`**。最后一条是必要的：poly flags
  为 0 的 tile 同样「存在且有几何」，但答不了任何查询；
- **debug-utils**：实现 `duDebugDraw`（抽象接口）并计数，`duDebugDrawNavMesh` 驱动它，断言
  收到顶点且收到三角形批次。只做 header-only 的 DebugUtils 撑不到 `begin()`。

### 两处踩坑（均在原型阶段用 ASan 定位）

1. `dtFreeTileCacheContourSet` / `dtFreeTileCachePolyMesh` 会 `alloc->free(cset)` —— **连容器
   本身一起释放**。因此必须用 `dtAllocTileCacheContourSet` / `dtAllocTileCachePolyMesh`
   从堆上取，栈上对象会导致 `free on address which was not malloc()-ed`；
2. 手工填 `dtTileCacheLayer` 的 heights/areas/cons 会让 `dtBuildTileCachePolyMesh` 产出
   **0 个 poly**。正确路径是 `rcBuildHeightfieldLayers`（见 `RecastDemo/Source/
   Sample_TempObstacles.cpp`）由 compact heightfield 派生层数据；且该 heightfield 必须带
   `borderSize`（`walkableRadius + 3`），所以这是一次**独立配置**的栅格化，不能复用核心
   测试那份 chf。

两个成员在提交前均于本地以 `clang++ -fsanitize=address` 跑通，无报错、无泄漏。

## 7. 注意事项 / 后续

- **未覆盖**：`RecastDemo`（需 SDL2 + OpenGL + 自带 imgui）与 `Tests/`（自带 catch2）未收录，
  符合本仓「只收库本身」的惯例。
- **未收录上游的两个 ABI 开关**，理由见 3.1。若 mcpp 日后支持跨包可见的 `defines`（即
  `PUBLIC` 语义），可再开 `polyref64` / `virtual-queryfilter` 两个 feature。
- **镜像缺失**意味着 CN 用户首次拉取走 GitHub。见第 5 节。
