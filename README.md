# mcpp-index

> [`mcpp`](https://github.com/mcpp-community/mcpp) 构建工具的默认包索引仓库。
> 在线浏览所有包:**https://mcpplibs.github.io/mcpp-index/**

本仓收录可被 `mcpp` 直接 `add` 的 C++23 包,既包含 `import` 即用的模块化库,也包含以 `compat` 形态从上游源码或
头文件构建的第三方 C/C++ 库。每个包对应一个 `pkgs/<首字母>/<包名>.lua` 描述文件。

## 使用

```bash
mcpp add ftxui@6.1.9            # 添加依赖到 mcpp.toml
mcpp build                     # 自动拉取源码并构建,依赖沿链路自动传递

mcpp search <keyword>          # 搜索并刷新索引
mcpp self config --mirror CN   # 切换至国内镜像,默认使用 GLOBAL 上游源
```

完整包列表见 **[在线索引站](https://mcpplibs.github.io/mcpp-index/)**。

## 包生态与贡献

本仓收录两类包:

- **原生 mcpp 模块库**:以 C++23 模块发布、`import` 即用,包括 `mcpplibs.*`、`nlohmann.json`、`imgui`、`ffmpeg`,以及由
  用户基于 mcpp 开发并登记进索引的库(如 `tensorvia-cpu`)。其上游通常自带 `mcpp.toml`,描述文件(Form A)只声明
  元数据与下载地址。
- **第三方 C/C++ 库(`compat`)**:其上游不提供 mcpp 支持,描述文件(Form B)内联构建信息。该类库存在
  header-only、纯 C 源码、C++23 module wrapper 等形态,可选组件经 `features` 门控,并配备 GitCode CN 镜像。

### 参考示例(`.lua` 描述符)

| 形态 | 示例 |
|------|------|
| 原生模块库(Form A) | [`mcpplibs.xpkg`](pkgs/x/xpkg.lua) · [`mcpplibs.tinyhttps`](pkgs/t/tinyhttps.lua) · [`tensorvia-cpu`](pkgs/t/tensorvia-cpu.lua) · [`ffmpeg`](pkgs/f/ffmpeg.lua)(模块层,源码经 `compat.ffmpeg` 直编) |
| C 源码 compat(含 `features`) | [`compat.cjson`](pkgs/c/compat.cjson.lua) · [`compat.zlib`](pkgs/c/compat.zlib.lua) |
| header-only(含 `features`) | [`compat.eigen`](pkgs/c/compat.eigen.lua) |
| 外部构建系统(`install()` 从源码构建) | [`compat.openblas`](pkgs/c/compat.openblas.lua)(Make) · [`compat.opencv`](pkgs/c/compat.opencv.lua)(CMake) |
| 全源码直编(config 快照 + 源列表,零外部构建系统) | [`compat.ffmpeg`](pkgs/c/compat.ffmpeg.lua)(2281 TU 含 NASM 汇编) |
| C++23 module wrapper | [`nlohmann.json`](pkgs/n/nlohmann.json.lua) · [`marzer.tomlplusplus`](pkgs/m/marzer.tomlplusplus.lua) |

### 新增一个包

完整流程定义于 agent skill [`add-mcpp-index-package`](.agents/skills/add-mcpp-index-package/SKILL.md)。可将下列
指令提供给 agent(如 Claude Code),由其调用该 skill 完成描述文件的编写与全流程:

```text
参考本仓 skill `.agents/skills/add-mcpp-index-package`,将 <库名 / 仓库URL> @<版本> 收录进 mcpp-index:
判定形态;配置 CN 镜像(无 mcpp-res 权限时使用 plain-string 上游 url);编写 pkgs/<首字母>/<包名>.lua;
添加 tests/examples/<库>/ 最小工程;使用与 CI 同版本的 mcpp 本地执行 `mcpp build && run` 进行验证;
更新 README 与在线索引;提交 PR 并确认 CI 通过。
```

细节文档位于 [`docs/`](docs/),供人工与 agent 共同使用:

- [库形态与描述符模板](docs/package-types.md):C 源码、header-only、模块、外部 Form-A 四类模板与样例。
- [CN 镜像闭环](docs/cn-mirror.md):`gtc` 与 gitcode 操作,以及无 `mcpp-res` 权限时的回退方案。
- [仓库结构与 schema 与 CI](docs/repository-and-schema.md):字段速查、选跑机制与本地 lint。
- 字段规范见 [mcpp 扩展字段文档](https://github.com/mcpp-community/mcpp/blob/main/docs/04-schema-xpkg-extension.md)。

> 提交 PR 后,`validate` 自动执行 lint 并按改动库选跑示例;合并后,`deploy-site` 将其发布至在线浏览站。

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
