# mcpp-index

[English](README.md) | **简体中文**

> [`mcpp`](https://github.com/mcpp-community/mcpp) 构建工具的默认包索引。
> 在线浏览所有包:**https://mcpplibs.github.io/mcpp-index/**

收录 `mcpp` 可直接 `add` 的 C++23 包:`import` 即用的模块化库,以及以 `compat` 形态从上游源码构建的第三方 C/C++ 库。
每个包对应一个 `pkgs/<首字母>/<包名>.lua` 描述文件。

> **需要 mcpp 2026.9.18.3 或更高版本**([`index.toml`](index.toml) 的 `min_mcpp`)。更旧的引擎会静默错误构建
> `openkal-musl` 等 `[c-abi]` 包。升级:`xlings install mcpp --force`。

## 使用

```bash
mcpp add ftxui@6.1.9           # 添加依赖到 mcpp.toml
mcpp build                     # 自动拉取源码并构建,依赖沿链路自动传递

mcpp search <keyword>          # 搜索并刷新索引
mcpp self config --mirror CN   # 切换至国内镜像,默认使用 GLOBAL 上游源
```

## 包的种类

- **原生 mcpp 模块库**(Form A):上游自带 `mcpp.toml`,描述文件只声明元数据与下载地址。如 `mcpplibs.*`、
  `nlohmann.json`、`imgui`、`opencv`、`tensorvia-cpu` 等。
- **第三方 C/C++ 库**(`compat`,Form B):上游不支持 mcpp,描述文件内联构建信息。形态有 header-only、C/C++ 源码、
  C++23 module wrapper;可选组件经 `features` 门控;GitCode CN 镜像提供相同字节。

### 参考示例

每种常见形态一个描述符:

| 形态 | 示例 |
|------|------|
| 原生模块库(Form A) | [`mcpplibs.tinyhttps`](pkgs/t/tinyhttps.lua) · [`gzj-creator.galay`](pkgs/g/gzj-creator.galay.lua) |
| C 源码 + `features` | [`compat.cjson`](pkgs/c/compat.cjson.lua) |
| C++ 源码,多版本 | [`compat.yaml-cpp`](pkgs/c/compat.yaml-cpp.lua) |
| header-only | [`compat.gtl`](pkgs/c/compat.gtl.lua) |
| 生成 config 头 | [`compat.c-ares`](pkgs/c/compat.c-ares.lua) |
| C++23 module wrapper | [`nlohmann.json`](pkgs/n/nlohmann.json.lua) |
| 上游自带 C++23 module | [`khronos.vulkan-hpp`](pkgs/k/khronos.vulkan-hpp.lua) |
| 外部构建系统(`install()`) | [`compat.openssl`](pkgs/c/compat.openssl.lua) |

其余形态,以及每个描述符为何这样写,见 **[描述符示例总览(按形态)](docs/zh/descriptor-examples.md)**。

### 新增一个包

流程定义于 agent skill [`add-mcpp-index-package`](.agents/skills/add-mcpp-index-package/SKILL.md)。把下面的指令交给
agent(如 Claude Code)即可:

```text
参考本仓 skill `.agents/skills/add-mcpp-index-package`,将 <库名 / 仓库URL> @<版本> 收录进 mcpp-index:
判定形态;配置 CN 镜像(无 mcpp-res 权限时使用 plain-string 上游 url);编写 pkgs/<首字母>/<包名>.lua;
添加 tests/examples/<库>/ 测试工程并登记为 workspace 成员;使用与 CI 同版本的 mcpp 本地执行
`mcpp test -p <成员>` 进行验证;更新 README 与在线索引;提交 PR 并确认 CI 通过。
```

提交 PR 后,CI 执行 lint,并只测试依赖了被修改描述符的 workspace 成员;合并后,`deploy-site` 发布站点。

## 文档

- [库形态与描述符模板](docs/zh/package-types.md)
- [描述符示例总览(按形态)](docs/zh/descriptor-examples.md)
- [CN 镜像闭环](docs/zh/cn-mirror.md)
- [openkal 兼容性](docs/zh/openkal-compat.md):站点上的 `openkal-ecosystem` / `openkal-compat` 标签
- [仓库结构、schema 与 CI](docs/zh/repository-and-schema.md)
- 字段的权威判定是 `mcpp xpkg parse`(CI 用的就是它);语义见 mcpp 仓的
  [`docs/spec/`](https://github.com/mcpp-community/mcpp/tree/main/docs/spec)。

## 相关链接

| 项目 | 说明 |
|------|------|
| [mcpp](https://github.com/mcpp-community/mcpp) | 现代 C++23 构建与包管理工具 |
| [xlings](https://github.com/d2learn/xlings) | mcpp 底层的包安装引擎与沙箱环境 |
| [xpkg V1 spec](https://github.com/d2learn/xim-pkgindex/blob/main/docs/V1/xpackage-spec.md) | 包描述文件规范 |
| [mcpplibs](https://github.com/mcpplibs) | mcpp 生态的模块化 C++23 库集合 |
| [mcpp-res](https://gitcode.com/mcpp-res) | 包资源的 CN 镜像组织(gitcode) |

## 社区

[mcpp issues](https://github.com/mcpp-community/mcpp/issues) · [d2learn 论坛](https://forum.d2learn.org)

## License

包描述文件采用 CC0;各上游库保留其自身许可证。
