# 新增 magic_enum 收录方案

**日期**: 2026-07-29
**本仓**: `mcpp-community/mcpp-index`(github 别名 `mcpplibs/mcpp-index`)
**目标**:
1. 收录 [`Neargye/magic_enum`](https://github.com/Neargye/magic_enum) —— 以 **模块化** 形态暴露 `import magic_enum;`(ns=`neargye`,name=`magic_enum`)。文件名 `pkgs/n/neargye.magic_enum.lua`。
2. 由于没有 `mcpp-res` 写权限，暂不建立 CN 镜像，使用纯字符串形式的上游 URL。
3. 添加 `tests/examples/magic_enum/` 测试工程并登记为 workspace 成员。

---

## 0. 关键前置结论

> ✅ **magic_enum 官方已写好 C++20 模块接口单元 `module/magic_enum.cppm`，内容 `export module magic_enum;`。**
> 该文件包含在 v0.9.8 发布的 tarball 中，因此可以直接使用 `sources = { "module/magic_enum.cppm" }`，无需生成 wrapper。

**决策**:走 **直接使用上游 `.cppm` 文件** 路径，而非 `generated_files`。这比 nlohmann.json 和 marzer.tomlplusplus 更简单，因为上游已经在发布版本中包含了模块文件。

**模块扫描器处理**:上游 `module/magic_enum.cppm` 包含条件预处理器块（`#if __has_include(<fmt/format.h>)`），mcpp 的 M1 模块扫描器不允许此类条件块。使用 `scan_overrides` 绕过扫描器限制，直接指定模块提供关系。

| 库 | 形态 | 最新 tag | 收录版本 | 语言 | 模块来源 |
|---|---|---|---|---|---|
| magic_enum | header-only C++ + C++23 module | `v0.9.8` | `0.9.8` | C++23 | **直接使用上游 `module/magic_enum.cppm`** |

---

## 1. magic_enum —— `pkgs/n/neargye.magic_enum.lua`(C++23 模块)

magic_enum 是一个 header-only C++17 库，提供枚举的静态反射。它同时提供了 C++20 模块接口单元，可以直接暴露为 `import magic_enum;`。

### 1.1 上游布局(v0.9.8 根目录)
```
include/
  magic_enum/
    magic_enum.hpp
    magic_enum_all.hpp
    magic_enum_containers.hpp
    magic_enum_flags.hpp
    magic_enum_format.hpp
    magic_enum_fuse.hpp
    magic_enum_iostream.hpp
    magic_enum_switch.hpp
    magic_enum_utility.hpp
module/
  magic_enum.cppm
example/
test/
...
```

GitHub tarball 无额外顶层目录，文件直接位于根目录。

### 1.2 最终 descriptor
```lua
package = {
    spec        = "1",
    namespace   = "neargye",
    name        = "magic_enum",
    description = "Header-only C++17 library for static reflection of enums, exposed as C++23 module magic_enum",
    licenses    = {"MIT"},
    repo        = "https://github.com/Neargye/magic_enum",
    type        = "package",

    xpm = {
        linux = {
            ["0.9.8"] = {
                url    = "https://github.com/Neargye/magic_enum/releases/download/v0.9.8/magic_enum-v0.9.8.tar.gz",
                sha256 = "88709dc8a9697168a75e039470d73ed0cffbc17567976eb5e096f946a2c0d521",
            },
        },
        macosx = {
            ["0.9.8"] = {
                url    = "https://github.com/Neargye/magic_enum/releases/download/v0.9.8/magic_enum-v0.9.8.tar.gz",
                sha256 = "88709dc8a9697168a75e039470d73ed0cffbc17567976eb5e096f946a2c0d521",
            },
        },
        windows = {
            ["0.9.8"] = {
                url    = "https://github.com/Neargye/magic_enum/releases/download/v0.9.8/magic_enum-v0.9.8.tar.gz",
                sha256 = "88709dc8a9697168a75e039470d73ed0cffbc17567976eb5e096f946a2c0d521",
            },
        },
    },

    mcpp = {
        schema       = "0.1",
        sources      = { "module/magic_enum.cppm" },
        import_std   = false,
        scan_overrides = {
            ["module/magic_enum.cppm"] = { provides = { "magic_enum" } }
        },
        modules      = { "magic_enum" },
        include_dirs = { "include" },
        targets      = { ["magic_enum"] = { kind = "lib" } },
        deps         = { },
    },
}
```

### 1.3 技术亮点
- **`scan_overrides`**:绕过 mcpp M1 模块扫描器对条件预处理器块的限制，直接指定模块提供关系。
- **直接使用上游 `.cppm`**:无需 `generated_files`，减少维护负担，保持与上游同步。
- **纯字符串 URL**:由于无 `mcpp-res` 写权限，符合 lint 规则的回退方案。

### 1.4 镜像
由于没有 `mcpp-res` 写权限，使用纯字符串形式的上游 URL。CN 用户将回退至上游源。后续由维护者补充 CN 镜像。

### 1.5 测试工程
- 位置: `tests/examples/magic_enum/`
- 依赖: `neargye.magic_enum = "0.9.8"`
- 测试内容: `enum_name`、`enum_cast`、`enum_values` 等基本功能

---

## 2. 验证结果

1. **本地 lint**: `mcpp xpkg parse pkgs/n/neargye.magic_enum.lua` 解析成功。
2. **本地测试**: `mcpp test -p magic_enum` 测试通过。
3. **提交**: 已提交变更但未推送。

---

## 3. 注意事项

- **命名空间**: 使用 `neargye` 而非 `compat`，因为这是 C++23 模块库，遵循 nlohmann.json、marzer.tomlplusplus 的命名模式。
- **语言版本**: mcpp 自动检测，无需显式指定。
- **模块文件**: 直接使用上游的 `module/magic_enum.cppm`，通过 `scan_overrides` 绕过扫描器限制。
- **include_dirs**: 设置为 `{ "include" }`，因为 tarball 无顶层目录。
- **无 CN 镜像**: 使用纯字符串 URL，符合 lint 规则。

---

## 4. 文件清单

1. `pkgs/n/neargye.magic_enum.lua` — 包描述符
2. `tests/examples/magic_enum/mcpp.toml` — 测试工程配置
3. `tests/examples/magic_enum/tests/reflection.cpp` — 测试代码
4. `mcpp.toml` — 更新 workspace members
5. `README.md` — 更新包列表
6. `.agents/docs/2026-07-29-add-magic_enum-plan.md` — 本文档