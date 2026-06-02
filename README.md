# mcpp-index

> [`mcpp`](https://github.com/mcpp-community/mcpp) 构建工具的默认包索引仓库
>
> 在线浏览: **https://mcpplibs.github.io/mcpp-index/**

## 快速使用

```bash
mcpp add ftxui@6.1.9       # 添加依赖到 mcpp.toml
mcpp build                  # 自动拉取源码 + 构建
```

## 已收录的包

### mcpplibs 模块化库

| 包名 | 版本 | 简介 | 仓库 |
|------|------|------|------|
| `mcpplibs.cmdline` | 0.0.2 | 命令行解析框架 — `import mcpplibs.cmdline;` | [mcpplibs/cmdline](https://github.com/mcpplibs/cmdline) |
| `mcpplibs.tinyhttps` | 0.2.2 | 轻量 HTTP/HTTPS 客户端(SSE 流式) — `import mcpplibs.tinyhttps;` | [mcpplibs/tinyhttps](https://github.com/mcpplibs/tinyhttps) |
| `mcpplibs.llmapi` | 0.2.5 | 大语言模型 API 客户端(OpenAI/Anthropic 兼容) — `import mcpplibs.llmapi;` | [mcpplibs/llmapi](https://github.com/mcpplibs/llmapi) |
| `mcpplibs.capi.lua` | 0.0.3 | Lua 5.4 C API 的 C++23 模块封装 — `import mcpplibs.capi.lua;` | [mcpplibs/lua](https://github.com/mcpplibs/lua) |
| `mcpplibs.xpkg` | 0.0.40 | xpkg V1 规范的 C++23 参考实现 — `import mcpplibs.xpkg;` | [openxlings/libxpkg](https://github.com/openxlings/libxpkg) |
| `mcpplibs.templates` | 0.0.1 | 最小化模块库模板 — `import mcpplibs.templates;` | [mcpplibs/templates](https://github.com/mcpplibs/templates) |

### 独立模块化库

| 包名 | 版本 | 简介 | 仓库 |
|------|------|------|------|
| `imgui` | 0.0.1 | Dear ImGui C++23 模块封装 — `import imgui.core;` / `import imgui.backend.glfw_opengl3;` | [mcpplibs/imgui-m](https://github.com/mcpplibs/imgui-m) |

### 第三方 C/C++ 库

| 包名 | 版本 | 简介 |
|------|------|------|
| `ftxui` | 6.1.9 | C++ 函数式终端 UI 库(screen + dom + component) |
| `glfw` | 3.4 | GLFW 窗口与输入库(X11/null 后端源码构建) |
| `gtest` | 1.15.2 | Google Test 测试框架 |
| `imgui` | 1.92.8 | Dear ImGui immediate-mode GUI 核心源码 |
| `opengl` | 2026.05.31 | Khronos OpenGL API 头文件 |
| `khrplatform` | 2026.05.31 | Khronos KHR platform 头文件 |
| `xorgproto` | 2025.1 | X.Org protocol 头文件 |
| `xtrans` | 1.6.0 | X.Org transport support headers/source snippets |
| `xau` | 1.0.12 | X authorization runtime library(`libXau.so`) |
| `xdmcp` | 1.1.5 | X Display Manager Control Protocol runtime library(`libXdmcp.so`) |
| `xcb-proto` | 1.17.0 | XCB protocol XML definitions and generator metadata |
| `xcb` | 1.17.0 | X C Binding runtime library(`libxcb.so`) |
| `x11` | 1.8.13 | Xlib runtime library(`libX11.so`) and public headers |
| `xcursor` | 1.2.3 | Xcursor runtime library(`libXcursor.so`) and public headers |
| `xext` | 1.3.7 | Xext runtime library(`libXext.so`) and public headers |
| `xfixes` | 6.0.2 | Xfixes runtime library(`libXfixes.so`) and public headers |
| `xi` | 1.8.3 | XInput runtime library(`libXi.so`) and public headers |
| `xinerama` | 1.1.6 | Xinerama runtime library(`libXinerama.so`) and public headers |
| `xrandr` | 1.5.5 | Xrandr runtime library(`libXrandr.so`) and public headers |
| `xrender` | 0.9.12 | Xrender runtime library(`libXrender.so`) and public headers |
| `mbedtls` | 3.6.1 | TLS/加密库(纯 C) |
| `lua` | 5.4.7 | Lua 脚本语言(纯 C 嵌入式库) |
| `zlib` | 1.3.2 | DEFLATE 压缩库 |
| `bzip2` | 1.0.8 | bzip2 压缩库 |
| `lz4` | 1.10.0 | LZ4 压缩库 |
| `zstd` | 1.5.7 | Zstandard 压缩库 |
| `xz` | 5.8.3 | XZ Utils liblzma 压缩库 |
| `libarchive` | 3.8.7 | 多格式归档与压缩库 |

### 依赖关系链

```
mcpplibs.llmapi
  └── mcpplibs.tinyhttps
        └── mbedtls              ← mcpp 自动传递,无需手动声明

mcpplibs.xpkg
  └── mcpplibs.capi.lua
        └── lua                  ← 同上

imgui
  ├── compat.imgui
  ├── compat.glfw
  │     └── compat.opengl
  └── compat.opengl              ← 消费者只需要 import imgui.* 模块

libarchive
  ├── zlib
  ├── bzip2
  ├── lz4
  ├── zstd
  └── xz                         ← 压缩后端自动传递

glfw
  ├── opengl
  │     └── khrplatform           ← GLFW/glfw3.h 所需 OpenGL/KHR 头文件
  └── x11 / xcursor / xext / xfixes / xi
      / xinerama / xorgproto / xrandr / xrender
                                  ← GLFW Linux X11 后端所需 runtime/header 闭包

xau / xdmcp
  └── xorgproto                   ← X11 底层 runtime 库的协议头文件

xcb
  ├── xcb-proto                   ← hook 内生成 xcb 协议源文件
  ├── xau
  └── xdmcp

x11
  ├── xcb
  ├── xorgproto
  └── xtrans                      ← Xlib/XIM transport 源码片段
```

mcpp 0.0.3+ 的 transitive walker 自动沿链路传播头文件和依赖,消费者只需声明直接依赖。

> 当前 X11/XCB/Xau/Xdmcp 以及 GLFW 需要的 Xcursor/Xext/Xfixes/Xi/Xinerama/
> Xrandr/Xrender 都已按上游源码提供 runtime `.so`。`compat.glfw` 仍沿用
> GLFW 上游的 GLX/OpenGL 动态加载行为,包描述会声明需要 `dlopen` 的
> `libGLX.so.0`/`libGL.so.1`/`libGL.so` 以及 `opengl.glx.driver` 能力。
> 窗口运行时仍需要宿主环境提供可用的 X server/GLX/OpenGL 驱动。

### 本地 smoke 验证

```bash
MCPP=/path/to/mcpp tests/smoke_compat_core.sh
MCPP=/path/to/mcpp tests/smoke_compat_imgui.sh
MCPP=/path/to/mcpp tests/smoke_compat_archive.sh
MCPP=/path/to/mcpp tests/smoke_imgui_module.sh
```

该脚本会通过当前 checkout 作为本地 path index 创建临时 mcpp 项目,验证:

- `compat.gtest`/`compat.ftxui`/`compat.lua`/`compat.mbedtls` 能用上游
  `#include <...>` API 构建并运行最小用例
- `compat.opengl`/`compat.khrplatform` 能提供 GLFW/OpenGL 常见头文件闭包
- `compat.imgui@1.92.8` core 能构建并运行一个 headless ImGui frame
- `imgui@0.0.1` 模块包能通过 `[dependencies] imgui = "0.0.1"` 构建并运行
  `import imgui.core;` / `import imgui.backend.glfw_opengl3;` 最小用例
- `compat.glfw@3.4` 能构建、运行 `glfwInit()` smoke,并链接 X11 扩展 runtime `.so`
- `compat.xau@1.0.12`/`compat.xdmcp@1.1.5` 能构建、运行并链接 runtime `.so`
- `compat.xcb@1.17.0` 能构建、运行并链接 `libxcb.so`
- `compat.x11@1.8.13` 能构建、运行并链接 `libX11.so` → `libxcb.so`
- `compat.xcursor`/`compat.xext`/`compat.xfixes`/`compat.xi`/`compat.xinerama`/
  `compat.xrandr`/`compat.xrender` 能构建、运行并链接对应 `libX*.so`
- `compat.libarchive` 能连同 `zlib`/`bzip2`/`lz4`/`zstd`/`xz` 压缩后端构建并运行

有窗口的 ImGui + GLFW + OpenGL demo 单独放在可选 smoke 中:

```bash
MCPP=/path/to/mcpp tests/smoke_compat_imgui_window.sh
MCPP=/path/to/mcpp MCPP_INDEX_RUN_WINDOW_SMOKE=1 tests/smoke_compat_imgui_window.sh
```

默认只验证 demo 构建和 X11 runtime 链接闭包。显式设置
`MCPP_INDEX_RUN_WINDOW_SMOKE=1` 后才会运行隐藏窗口帧渲染,此时需要当前
`DISPLAY` 可用,并且宿主机提供 GLVND/GLX/OpenGL 驱动 runtime。脚本会把
宿主 GL runtime 和 compat X11 runtime 组装到临时 `LD_LIBRARY_PATH` 中,
避免系统 X11 库覆盖 mcpp 构建出的 `libX11.so`/`libxcb.so`。

## 包描述文件

每个包对应一个 `pkgs/<首字母>/<包名>.lua` 文件,遵循 [xpkg V1 规范](https://github.com/d2learn/xim-pkgindex/blob/main/docs/V1/xpackage-spec.md)。

### 两种形式

**Form A** — 上游自带 `mcpp.toml`,描述文件只声明元数据和下载地址:

```lua
package = {
    spec = "1",
    name = "mcpplibs.tinyhttps",
    xpm = {
        linux   = { ["0.2.2"] = { url = "...", sha256 = "..." } },
        macosx  = { ["0.2.2"] = { url = "...", sha256 = "..." } },
        windows = { ["0.2.2"] = { url = "...", sha256 = "..." } },
    },
}
```

**Form B** — 上游没有 `mcpp.toml`,在描述文件里内联构建信息:

```lua
package = {
    spec = "1",
    name = "ftxui",
    xpm = { ... },
    mcpp = {
        include_dirs = { "*/include", "*/src" },
        sources = {
            "*/src/ftxui/**/*.cpp",
            "!*/src/ftxui/**/*_test.cpp",      -- glob 排除(mcpp 0.0.4+)
            "!*/src/ftxui/**/*_fuzzer.cpp",
        },
        targets = { ["ftxui"] = { kind = "lib" } },
    },
}
```

### 获取方式

mcpp 初次运行时自动 clone 本仓库到 `~/.mcpp/registry/data/mcpp-index/`。后续更新:

```bash
mcpp search <keyword>    # 触发索引刷新 + 搜索
```

也可手动拉取:

```bash
cd ~/.mcpp/registry/data/mcpp-index && git pull
```

## 添加新包

1. Fork 本仓库
2. 在 `pkgs/<首字母>/` 下创建 `<包名>.lua`,参考现有文件([compat.mbedtls.lua](pkgs/c/compat.mbedtls.lua)、[compat.ftxui.lua](pkgs/c/compat.ftxui.lua))
3. 提交 PR — `validate` workflow 自动 lint,`deploy-site` 合入后自动发布到浏览站

详细格式说明见 [mcpp 扩展字段文档](https://github.com/mcpp-community/mcpp/blob/main/docs/04-schema-xpkg-extension.md)。

## 相关链接

| 项目 | 说明 |
|------|------|
| [mcpp](https://github.com/mcpp-community/mcpp) | 现代 C++23 构建 & 包管理工具 |
| [xlings](https://github.com/d2learn/xlings) | mcpp 底层的包安装引擎 + 沙箱环境 |
| [xpkg V1 spec](https://github.com/d2learn/xim-pkgindex/blob/main/docs/V1/xpackage-spec.md) | 包描述文件规范 |
| [mcpplibs](https://github.com/mcpplibs) | mcpp 生态的模块化 C++23 库集合 |
| [xim-pkgindex](https://github.com/d2learn/xim-pkgindex) | xlings 的通用包索引仓库 |

## 社区

- **Issues / 反馈**: [mcpp issues](https://github.com/mcpp-community/mcpp/issues) · [mcpp-index issues](https://github.com/mcpp-community/mcpp-index/issues)
- **讨论 / 论坛**: [d2learn 论坛](https://forum.d2learn.org)
- **mcpplibs 库贡献**: 各库仓库接受 PR,CI 使用 mcpp 构建验证

## License

包描述文件: CC0。各上游库保留其自身许可证。
