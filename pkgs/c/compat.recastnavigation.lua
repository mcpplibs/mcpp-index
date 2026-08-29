-- compat.recastnavigation — Recast 与 Detour，大量上线游戏背后共用的导航
-- 网格工具集：Recast 负责把关卡几何烘成导航网格，Detour 负责在网格上跑
-- 运行时寻路。
--
-- 形态：A（源码 compat，C++ 版），带三个按源码门控的 feature。
-- 上游是五个 CMake 库，从一份裸源码列表即可干净构建——30 个 .cpp、只依赖
-- 标准库、没有 configure 步骤、没有 config 头、没有外部依赖（已核实：五个
-- 模块全部 #include 的并集 = 自身头文件 + <float.h> <math.h> <new>
-- <stdarg.h> <stddef.h> <stdint.h> <stdio.h> <stdlib.h> <string.h>）。
-- 因此没有任何「为了能编译而必须生成」的东西；下面的 generated_files
-- 只是为了还原安装接口（见下）。
--
-- 核心构建装了什么，以及为什么 Recast 和 Detour 不是 feature。
-- 上游把 Recast 和 Detour 做成互不依赖的独立库，所以它们本可以各自成为
-- feature。没有这么做，是因为几乎没有消费者只要其中一半：Recast 烘网格、
-- Detour 走网格，一个逼你为「人人都要的组合」多报一次名字的包，只是一道
-- 速度障碍。真正可选的是真实项目完全可能不带的三块——群体仿真、流式
-- tile 和调试绘制。
--
-- 为什么 debug-utils 必须 imply tilecache。
-- 上游的 DebugUtils 链接 Recast、Detour 和 DetourTileCache
-- （DebugUtils/CMakeLists.txt），且其源码无条件引用 dtTileCache 的符号。
-- 本包所有 feature 编进同一个 lib target，因此只开 debug-utils 会留下
-- 无法解析的引用，消费者在链接期报缺 dtTileCache* 符号——报错晚、难定位。
-- implies 让「开了调试绘制却拿不到 tilecache」这个状态无法被表达出来。
--
-- include 拼写——两种都成立，而且是有意的。
-- 上游自己的安装把每个头文件平铺进 <includedir>/recastnavigation/，并把
-- <includedir> 和 <includedir>/recastnavigation 同时放到 target 的
-- INTERFACE include 目录（见各模块 CMakeLists.txt 里那句 INCLUDES
-- DESTINATION）。所以对着一份真实安装，#include <Recast.h> 与
-- #include <recastnavigation/Recast.h> 同样合法——这正是两种拼写都在
-- 野外存活的原因。在源码树内构建只能直接得到前一种，于是
-- mcpp_generated/recastnavigation/*.h 把后一种补回来：每个公开头一个
-- 转发头，外加一份上游 configure_file() 会产出的 version.h。
-- package-types.md「feature 不能隐藏头」的规则在这里同样成立——不开
-- crowd，<recastnavigation/DetourCrowd.h> 也照样能解析，用了才在链接期
-- 失败。
--
-- 两个刻意不做成 feature 的 CMake 选项。
-- RECASTNAVIGATION_DT_POLYREF64 和 RECASTNAVIGATION_DT_VIRTUAL_QUERYFILTER
-- 在上游是 target_compile_definitions(... PUBLIC)：前者改 dtPolyRef 的
-- 位宽，后者给 dtQueryFilter 加虚表，改的都是跨库边界类型的 ABI。
-- feature 的 defines 只能到达本包自己的翻译单元，用 feature 门控它们会
-- 得到「库按一种方式编、消费者按另一种方式编」的 ODR/ABI 分裂——失败
-- 既晚又难查。因此两者保持上游默认（OFF），这也是所有二进制发行版的取值。
--
-- 镜像：暂无 CN 镜像。发布需要 mcpp-res 的写权限，编写本描述符时没有，
-- 所以 url 写成纯字符串；CN 用户回落到 GitHub。有 gtc 权限的维护者可以
-- 改成惯用的 { GLOBAL = ..., CN = ... } 表——要上传的 tarball 与 GLOBAL
-- 那份逐字节一致，因此下面的 sha256 不变。
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "recastnavigation",
    description = "Recast Navigation — navmesh generation (Recast) and runtime pathfinding (Detour); optional crowd simulation, tile cache and debug draw",
    licenses    = {"Zlib"},
    repo        = "https://github.com/recastnavigation/recastnavigation",
    type        = "package",

    xpm = {
        linux = {
            ["1.6.0"] = {
                url    = "https://github.com/recastnavigation/recastnavigation/archive/refs/tags/v1.6.0.tar.gz",
                sha256 = "d48ca0121962fa0639502c0f56c4e3ae72f98e55d88727225444f500775c0074",
            },
        },
        macosx = {
            ["1.6.0"] = {
                url    = "https://github.com/recastnavigation/recastnavigation/archive/refs/tags/v1.6.0.tar.gz",
                sha256 = "d48ca0121962fa0639502c0f56c4e3ae72f98e55d88727225444f500775c0074",
            },
        },
        windows = {
            ["1.6.0"] = {
                url    = "https://github.com/recastnavigation/recastnavigation/archive/refs/tags/v1.6.0.tar.gz",
                sha256 = "d48ca0121962fa0639502c0f56c4e3ae72f98e55d88727225444f500775c0074",
            },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        -- 每个模块的 Include/ 目录一条，对应上游的
        -- `target_include_directories(<mod> PUBLIC <mod>/Include)`。
        -- 裸拼写 `#include <Recast.h>` 靠这些条目解析。
        include_dirs = {
            "*/Recast/Include",
            "*/Detour/Include",
            "*/DetourCrowd/Include",
            "*/DetourTileCache/Include",
            "*/DebugUtils/Include",
            "mcpp_generated",
        },
        generated_files = {
            -- 上游安装的拼写，每个公开头一个转发头。
            -- 写成转义单行字符串而非长括号，因为每个文件只有两行；
            -- 给 26 个文件都套上 `[==[ ]==]` 会把本该便于审阅的清单
            -- 埋进括号噪音里。
            ["mcpp_generated/recastnavigation/Recast.h"]        = "#pragma once\n#include <Recast.h>\n",
            ["mcpp_generated/recastnavigation/RecastAlloc.h"]   = "#pragma once\n#include <RecastAlloc.h>\n",
            ["mcpp_generated/recastnavigation/RecastAssert.h"]  = "#pragma once\n#include <RecastAssert.h>\n",

            ["mcpp_generated/recastnavigation/DetourAlloc.h"]           = "#pragma once\n#include <DetourAlloc.h>\n",
            ["mcpp_generated/recastnavigation/DetourAssert.h"]          = "#pragma once\n#include <DetourAssert.h>\n",
            ["mcpp_generated/recastnavigation/DetourCommon.h"]          = "#pragma once\n#include <DetourCommon.h>\n",
            ["mcpp_generated/recastnavigation/DetourMath.h"]            = "#pragma once\n#include <DetourMath.h>\n",
            ["mcpp_generated/recastnavigation/DetourNavMesh.h"]         = "#pragma once\n#include <DetourNavMesh.h>\n",
            ["mcpp_generated/recastnavigation/DetourNavMeshBuilder.h"]  = "#pragma once\n#include <DetourNavMeshBuilder.h>\n",
            ["mcpp_generated/recastnavigation/DetourNavMeshQuery.h"]    = "#pragma once\n#include <DetourNavMeshQuery.h>\n",
            ["mcpp_generated/recastnavigation/DetourNode.h"]            = "#pragma once\n#include <DetourNode.h>\n",
            ["mcpp_generated/recastnavigation/DetourStatus.h"]          = "#pragma once\n#include <DetourStatus.h>\n",

            ["mcpp_generated/recastnavigation/DetourCrowd.h"]            = "#pragma once\n#include <DetourCrowd.h>\n",
            ["mcpp_generated/recastnavigation/DetourLocalBoundary.h"]    = "#pragma once\n#include <DetourLocalBoundary.h>\n",
            ["mcpp_generated/recastnavigation/DetourObstacleAvoidance.h"] = "#pragma once\n#include <DetourObstacleAvoidance.h>\n",
            ["mcpp_generated/recastnavigation/DetourPathCorridor.h"]     = "#pragma once\n#include <DetourPathCorridor.h>\n",
            ["mcpp_generated/recastnavigation/DetourPathQueue.h"]        = "#pragma once\n#include <DetourPathQueue.h>\n",
            ["mcpp_generated/recastnavigation/DetourProximityGrid.h"]    = "#pragma once\n#include <DetourProximityGrid.h>\n",

            ["mcpp_generated/recastnavigation/DetourTileCache.h"]         = "#pragma once\n#include <DetourTileCache.h>\n",
            ["mcpp_generated/recastnavigation/DetourTileCacheBuilder.h"]  = "#pragma once\n#include <DetourTileCacheBuilder.h>\n",

            ["mcpp_generated/recastnavigation/DebugDraw.h"]        = "#pragma once\n#include <DebugDraw.h>\n",
            ["mcpp_generated/recastnavigation/DetourDebugDraw.h"]  = "#pragma once\n#include <DetourDebugDraw.h>\n",
            ["mcpp_generated/recastnavigation/RecastDebugDraw.h"]  = "#pragma once\n#include <RecastDebugDraw.h>\n",
            ["mcpp_generated/recastnavigation/RecastDump.h"]       = "#pragma once\n#include <RecastDump.h>\n",

            -- 上游的 version.h.in 按 1.6.0 实例化。数字形式是上游自己的：
            -- LIB_VERSION "1.6.0" 先补一个 ".0"，再把点换成逗号，装进用户
            -- 机器的就是这个内容。源码树里没有任何文件 include 它——
            -- 缺了也不会编译失败——但它是公开安装面的一部分，消费者检查
            -- RECASTNAV_VERSION 时应当能找到它。
            ["mcpp_generated/recastnavigation/version.h"] = [==[
#pragma once

/* Define to the library version */
#define RECASTNAV_VERSION "1.6.0"
#define RECASTNAV_VERSION_NUM 1,6,0,0
]==],
        },
        -- Recast 和 Detour：每个消费者都会用到的两个模块，也是上游仅有的
        -- 两个只依赖自身的构建目标。
        sources      = {
            "*/Recast/Source/*.cpp",
            "*/Detour/Source/*.cpp",
        },
        targets      = { ["recastnavigation"] = { kind = "lib" } },
        features     = {
            -- DetourCrowd：在 Detour 之上的 agent 转向与局部避障。
            ["crowd"]      = { sources = { "*/DetourCrowd/Source/*.cpp" } },
            -- DetourTileCache：流式导航网格 tile，外加运行时能刻进 tile 的
            -- 动态障碍。
            ["tilecache"]  = { sources = { "*/DetourTileCache/Source/*.cpp" } },
            -- DebugUtils：duDebugDraw 抽象绘制接口，加上驱动它的
            -- Recast/Detour/TileCache 各渲染器。无条件依赖 DetourTileCache，
            -- 所以才有上面的 implies。
            ["debug-utils"] = {
                implies = { "tilecache" },
                sources = { "*/DebugUtils/Source/*.cpp" },
            },
        },
        deps         = { },
        -- Recast 调用 log()/sqrtf() 等；glibc 早于 2.34 时它们在独立的
        -- libm 里。Windows 没有对应物。
        linux   = { ldflags = { "-lm" } },
        macosx  = { ldflags = { "-lm" } },
    },
}
