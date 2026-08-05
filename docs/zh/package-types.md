# 库形态与描述符模板

[English](../package-types.md) | **简体中文**

编写描述符前,应先判定库所属的形态,再选用对应模板。`mcpp = {}` 内的所有路径均为**相对 verdir 的 GLOB**:
前导 `*` 用于吸收 tarball 的 `<repo>-<tag>/` wrap 层;`*` 匹配单段,`**` 匹配跨段(例如 `*/blas/*.cpp` 合法)。

A–D 是四种**基础**形态,先按它们判定;E–G 是在基础形态之上叠加的处理方式,按需组合。

| 形态 | 特征 | 样例 | 关键字段 |
|---|---|---|---|
| **A. C 源码 compat** | 纯 C 或少量源码,用户 `#include <foo.h>` | `pkgs/c/compat.cjson.lua`、`compat.zlib.lua`、`compat.gtest.lua` | `sources` 与 `c_standard` |
| **B. header-only** | 纯头文件,无需编译 | `pkgs/c/compat.eigen.lua`、`compat.opengl.lua`、`compat.khrplatform.lua` | `include_dirs` 与 anchor 源 |
| **C. C++23 module** | 暴露 `import x.y;` | `pkgs/n/nlohmann.json.lua` | `modules` 与 `generated_files` 或源 `.cppm` |
| **D. 外部 Form-A 模块仓** | 上游自带 mcpp 描述符,独立仓库 | `pkgs/i/imgui.lua`、`pkgs/m/mcpplibs.*` | `mcpp = "<repo 路径>"`(Form A) |
| **E. 生成 config 的全源码直编** | 上游用 configure/CMake 生成配置头,此处以 `generated_files` 落一份快照 | `pkgs/c/compat.libpng.lua`、`compat.curl.lua`、`compat.sdl2.lua`、`compat.ffmpeg.lua` | `generated_files` + `include_dirs` |
| **F. 共享库 compat** | 必须是**唯一**的那个 `.so`(会被第三方 `dlopen`) | `pkgs/c/compat.x11.lua` 等 X11 家族、`compat.vulkan.lua`(linux) | `targets = { kind = "shared", soname = … }` |
| **G. 宿主运行时适配** | 驱动之类无法 vendor 的东西,只做符号链接农场 + 元数据 | `pkgs/c/compat.glx-runtime.lua`、`compat.vulkan-runtime.lua` | `runtime.library_dirs` / `capabilities` |
| **H. 宿主工具提供方** | 上游 tarball 里除了库,还带着消费者在构建期要跑的**代码生成器** | `pkgs/c/compat.protobuf.lua`(`protoc`) | `targets` 里一条 `kind = "bin"` + `main`,配 `required_features` |

完整的样例索引见[根 README 的「参考示例」表](../../README.zh-CN.md#参考示例lua-描述符)。

A、B、C 三类共用的骨架(`package` 头与 `xpm`)如下:

```lua
package = {
    spec        = "1",
    namespace   = "compat",          -- 点分层级路径;compat / nlohmann / mcpplibs 等,决定 import 前缀与依赖 key
    name        = "<lib>",           -- 单一原子段,不重复 namespace(SPEC-001 §3.2)
    description = "…",
    licenses    = {"MIT"},           -- SPDX
    repo        = "https://…",
    type        = "package",

    xpm = {  -- 三平台均需声明;纯源码或纯头时三平台共用同一 url 与 sha256
        linux   = { ["1.2.3"] = { url = { GLOBAL = "https://…/v1.2.3.tar.gz",
                                          CN     = "https://gitcode.com/mcpp-res/<slug>/releases/download/1.2.3/<slug>-1.2.3.tar.gz" },
                                  sha256 = "<计算所得>" } },
        macosx  = { ["1.2.3"] = { url = { GLOBAL = "…", CN = "…" }, sha256 = "…" } },
        windows = { ["1.2.3"] = { url = { GLOBAL = "…", CN = "…" }, sha256 = "…" } },
    },

    mcpp = { … 见下文各形态 … },
}
```

身份是 `(namespace, name)` 二元组:层级一律放 `namespace`,`name` 只写一段。文件名不参与解析,推荐
`pkgs/<首字母>/<namespace>.<name>.lua`(命中 mcpp 的快路径)。详见
[仓库结构与 schema](repository-and-schema.md#包身份namespace-name)。

---

## A. C 源码 compat(`compat.cjson` / `compat.zlib`)

将 C 源码编译为 lib,头文件经 `include_dirs` 暴露,可选组件由 `features` 门控。

```lua
mcpp = {
    language     = "c++23",   -- 与既有 compat 对齐;实际的 C 行为由 c_standard 决定
    import_std   = false,
    c_standard   = "c99",     -- 或 c11
    include_dirs = { "*" },           -- 暴露顶层头文件(*/foo.h)
    sources      = { "*/cJSON.c" },   -- 核心源码,始终编译
    targets      = { ["cjson"] = { kind = "lib" } },
    features     = {                  -- 可选扩展,默认不编译
        ["utils"] = { sources = { "*/cJSON_Utils.c" } },
    },
    deps         = { },
}
```

要点:多源码时可逐个列出(`compat.zlib` 列出了 15 个 `.c`)或使用 glob;需要配置头时可用 `generated_files` 合成
(`compat.zlib` 使用 `mcpp_generated/include/mcpp_zlib_config.h` 配合 `cflags = {"-include …"}`)。

## B. header-only(`compat.eigen` / `compat.opengl`)

此类库无可编译源码:由 `include_dirs` 暴露头文件,并加入一个 trivial anchor `.c`,以提供一个可构建的 lib 目标。

```lua
mcpp = {
    language     = "c++23",
    import_std   = false,
    c_standard   = "c11",
    include_dirs = { "*" },           -- 或更精确的 "*/include" / "*/api"
    generated_files = {
        ["mcpp_generated/<lib>_anchor.c"] = "int mcpp_compat_<lib>_anchor(void) { return 0; }\n",
    },
    sources      = { "mcpp_generated/<lib>_anchor.c" },
    targets      = { ["<lib>"] = { kind = "lib" } },
    -- 若存在额外可编译源码的组件(非纯头),可实现为 source-gated feature:
    features     = {
        ["blas"] = { sources = { "*/blas/*.cpp", "*/blas/f2c/*.c" } },  -- eigen 实例
    },
    deps         = { },
}
```

注意:纯头形式的可选项无法隐藏(与核心共享 include 根),因此不应为其勉强构造 feature;只有额外可编译源码才能被门控
(`compat.eigen` 的 `blas` 即由 C++ 与 f2c 转换的 C 构成,不依赖 Fortran,因此可门控)。

## C. C++23 module(`nlohmann.json`)

使用户可 `import x.y;`。有两种实现路径:

1. **上游已自带 `.cppm`**:直接 `sources = { "*/path/to/unit.cppm" }`。
2. **上游 release 不含**(较常见):以 `generated_files` 合成 wrapper(`#include <header>`、`export module x.y;`、
   `export using …`),基底头 pin 至已发布 tag。应逐字复用上游官方 wrapper,而非自行推断符号清单。

```lua
mcpp = {
    schema       = "0.1",
    language     = "c++23",
    import_std   = false,                 -- wrapper 含上游头,启用 import std 易产生冲突
    modules      = { "nlohmann.json" },
    include_dirs = { "*/single_include" }, -- 使 wrapper 内的 #include <…> 可解析
    generated_files = {
        ["mcpp_generated/nlohmann.json.cppm"] = "module;\n#include <nlohmann/json.hpp>\nexport module nlohmann.json;\n…",
    },
    sources      = { "mcpp_generated/nlohmann.json.cppm" },
    targets      = { ["nlohmann_json"] = { kind = "lib" } },
    deps         = { },
}
```

注意:mcpp 段解析器不支持 Lua 长括号 `[[ … ]]`,`generated_files` 的内容必须采用双引号字符串并对 `\n`、`\"`
转义,否则报 `malformed mcpp segment`。消费侧不应将 `import x.y;` 与文本 `#include <string>` 混用(会与 GCC
modules 冲突),应配合 `import std;`。

## D. 外部 Form-A 模块仓(`imgui` / `mcpplibs.*`)

上游或独立仓库自带 mcpp 描述符,本仓仅充当指针:`mcpp = "<相对或远程路径>"`(Form A,而非内联的 Form B)。新增的
独立库通常归属于另一仓库(如 `mcpplibs/imgui-m`),本仓只负责登记。写法可参照 `pkgs/i/imgui.lua` 与
`pkgs/x/xpkg.lua`。

---

## E. 生成 config 的全源码直编(`compat.curl` / `compat.sdl2`)

上游用 configure 或 CMake 生成一份配置头,而本仓要的是「列出 .c 文件」。可行的前提是这类库把**未选中的后端
编成空 TU**(curl 的 `vtls/gtls.c` 从头到尾是 `#ifdef USE_GNUTLS`,SDL 的 `src/video/windows/*.c` 同理),于是
源码列表可以是朴素的 glob,配置全部落在一份 `generated_files` 快照里。

只在**上游有缺口的平台**生成:curl 签入了 `lib/config-win32.h`(Windows 无需生成),SDL 签入了
`SDL_config_windows.h` / `SDL_config_macosx.h`(只有 linux 落到无用的 `SDL_config_minimal.h`)。生成时务必
用**本索引的工具链**跑 configure —— 用宿主 `cc` 生成的 curl 配置曾断言 `ssize_t` 不存在,导致 curl 编不过自己
的配置。

## F. 共享库 compat(`compat.x11` 家族 / `compat.vulkan`)

当这个库会被第三方 `dlopen` 时,它必须是进程里**唯一**的那一个,静态链接会出问题。

```lua
targets = { ["vulkan"] = { kind = "shared", soname = "libvulkan.so.1" } },
```

`soname` 不是可选项:SDL2 的 `SDL_CreateWindow(SDL_WINDOW_VULKAN)` 会 `dlopen("libvulkan.so.1")` 并用它解析
surface 创建。若 loader 是静态的,应用最终会有两个 loader —— 自己那份建 instance,SDL 那份建 surface ——
`createSurface` 拿到一个对方没见过的 instance 而失败。

声明位置也有讲究:`kind = "shared"` 会把 `-fPIC` 传播给消费者,而 clang 对 msvc 目标直接拒绝该选项。因此
`compat.vulkan` 把它写在 **linux 块内**,Windows 走另一套(链接预生成的 import library)。平台块里的 `targets`
会覆盖顶层声明,`compat.ffmpeg` 亦如此。

## G. 宿主运行时适配(`compat.glx-runtime` / `compat.vulkan-runtime`)

GPU 驱动无法打包 —— ICD 必须匹配机器上的内核驱动。本仓的既定立场是把它建模为**宿主能力**,而不是假装厂商
驱动是可再分发的普通包(见 `.agents/docs/2026-06-03-gl-runtime-packages-plan.md`)。这类包不 vendor 任何东西,
只做符号链接农场加元数据:

```lua
runtime = {
    library_dirs = { "mcpp_generated/<name>/lib" },
    capabilities = { "vulkan.icd.driver" },
},
```

之所以需要它:mcpp 的产物跑在**自带的 glibc** 下(`interp` 指向 `xim-x-glibc`,rpath 只覆盖 mcpp 自己的树),
因此裸 soname 的 `dlopen` 根本不搜索宿主库路径 —— loader 能找到全部 ICD manifest,却一个驱动都打不开。

两个反复踩到的细节:

- **农场里只放带版本号的 soname**(`lib*.so.*`)。`runtime.library_dirs` 同时进**链接行**,一个裸 `libxcb.so`
  会遮蔽本仓自己的 `compat.xcb`,链接报 `undefined reference to XauDisposeAuth`(mcpp#304)。带版本号的名字对
  链接器不可见,而恰好是 `dlopen` 要的。
- **闭包必须完整**。农场里有 `libxcb.so.1` 却没有它依赖的 `libXau.so.6`,会遮蔽掉本来能解析的宿主副本,可执行
  文件直接起不来。

## H. 宿主工具提供方(`compat.protobuf` 的 `protoc`)

有些 tarball 里同时装着一个库,和「针对这个库生成代码」的那个生成器。把生成器声明成第二个 target,
消费者用 `tools = [...]` 索取(mcpp 2026.8.5.1 起):

```lua
targets = {
    ["protobuf"] = { kind = "lib" },
    ["protoc"]   = { kind = "bin",
                     main = "*/src/google/protobuf/compiler/main.cc",
                     required_features = { "protoc", "upb" } },
},
features = {
    ["protoc"] = { sources = { … 编译器自身的源码 … } },
},
```

```toml
# 消费者侧 —— 一条依赖,两种角色
compat.protobuf = { version = "35.1", tools = ["protoc"] }
```

mcpp 会在一次嵌套子构建里把这个 target 编成**构建机**的二进制,并把路径经
`mcpp::dep_bin("protobuf", "protoc")` 交给消费者的 `build.mcpp`。这个形态值得单列的全部理由在于:
工具的版本**就是**那条依赖的版本,于是「生成器与运行时版本错配」——在别处是**运行期**才炸、也正是
protobuf 最经典的坑——在这里**语法上无法表达**。`mcpp build --target <triple>` 下工具仍为宿主构建,
因为代码生成器必须在本机跑。

四个要点:

- **把编译器的源码关进一个 feature**,并在 target 的 `required_features` 里写明。只链库的消费者不该为
  生成器的 TU 买单;索取工具的消费者也不该需要知道它要哪些 feature。`compat.protobuf` 的 `protoc` 还
  必须要 `upb`,因为 libprotoc 的 upb 生成器要链 upb 运行时——搞错了会在**链接期**缺一批 `upb_*` 符号。
- **源码列表照旧逐条转录自上游**:protobuf 这 138 项来自它自己的 `src/file_lists.cmake` 的 `libprotoc_srcs`。
- **`main` 和 `sources` 一样需要 `*/` 那层 wrap glob**,展开方式相同。
- **运行期还要读数据文件的生成器,仍然需要一个路径**。protoc 并不内嵌 well-known types:
  `import "google/protobuf/timestamp.proto"` 是从磁盘读的。消费者用 `mcpp::dep_dir("protobuf")` 推出那个
  目录——见 `tests/examples/protobuf-protoc/build.mcpp`。

对应的成员是 `tests/examples/protobuf-protoc`,它与 `tests/examples/protobuf` 互为补集:那个刻意**不用**
任何生成代码,这个从头到尾都是生成代码。

---

## 最小工程(`tests/examples/<short>/`)

`mcpp.toml`(短式依赖与长式依赖二选一):

```toml
[package]
name = "<short>-example"
version = "0.1.0"
[toolchain]
default = "gcc@16.1.0"
# `compat` 由 workspace 根的 [indices] 继承,成员无需再写;
# 消费其他命名空间时才在此声明,例如 `[indices] fmtlib = { path = "../../.." }`
# —— 成员级声明会**替换**根级表而非与之合并(这正是保持单个项目索引 repo 的方式)。
[dependencies.compat]
<short> = "1.2.3"                          # 或:<short> = { version = "1.2.3", features = ["…"] }
[targets.<short>-example]
kind = "bin"
main = "src/main.cpp"                      # C 库可使用 .c
```

`src/main.cpp` 应包含有效断言并 `return ok ? 0 : 1`,而非仅打印输出。module 库使用 `import std; import x.y;`;
header-only 与 C 库使用文本 `#include`。
