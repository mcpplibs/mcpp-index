# mcpp-index

[English](README.md) | **简体中文**

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

- **原生 mcpp 模块库**:以 C++23 模块发布、`import` 即用,包括 `mcpplibs.*`、`nlohmann.json`、`imgui`、`ffmpeg`、`opencv`,以及由
  用户基于 mcpp 开发并登记进索引的库(如 `tensorvia-cpu`)。其上游通常自带 `mcpp.toml`,描述文件(Form A)只声明
  元数据与下载地址。
- **第三方 C/C++ 库(`compat`)**:其上游不提供 mcpp 支持,描述文件(Form B)内联构建信息。该类库存在
  header-only、纯 C 源码、C++23 module wrapper 等形态,可选组件经 `features` 门控,并配备 GitCode CN 镜像。

### 参考示例

按常见形态各挑一个,建议先看这几个描述符:

| 形态 | 示例 | 看点 |
|------|------|------|
| 原生模块库(Form A) | [`mcpplibs.tinyhttps`](pkgs/t/tinyhttps.lua) · [`gzj-creator.galay`](pkgs/g/gzj-creator.galay.lua) | 上游自带 `mcpp.toml`;Galay 还展示了多模块包与按 feature 开启协议层 |
| C 源码 compat | [`compat.cjson`](pkgs/c/compat.cjson.lua) | 单个 `.c` 编成库;可选扩展由 `features` 门控 |
| header-only | [`compat.gtl`](pkgs/c/compat.gtl.lua) | 没有可编译内容 —— `include_dirs` 加一个 anchor TU |
| 全源码直编 + 生成 config | [`compat.c-ares`](pkgs/c/compat.c-ares.lua) | 把 configure 本该生成的 config 头快照进 `generated_files` |
| 多组件上游拍平进单个库 | [`compat.recastnavigation`](pkgs/c/compat.recastnavigation.lua) | Recast Navigation 1.6.0 —— 上游是五个互相依赖的 CMake target;这里把「人人都要用」的两个作为核心,其余三个做 `features`,全部编进同一个 lib。依赖边必须手工重建,这正是 `debug-utils` 带 `implies = { "tilecache" }` 的原因:上游无条件链接 DetourTileCache,没有这条 implication,只开调试绘制的消费者会在**链接期**撞上缺失的 `dtTileCache*` 符号。上游安装把头文件拍平进 `include/recastnavigation/`,同时把该目录**及其父目录**都放进 interface include path,于是对着真实安装 `#include <Recast.h>` 与 `#include <recastnavigation/Recast.h>` 都合法 —— 26 个生成的转发头把第二种拼写还给源码树构建。`RECASTNAVIGATION_DT_POLYREF64` 与 `RECASTNAVIGATION_DT_VIRTUAL_QUERYFILTER` 刻意**不**做成 feature:它们改变跨库边界类型的 ABI,而 feature 的 `defines` 只作用于本包自己的 TU |
| C++23 module wrapper | [`nlohmann.json`](pkgs/n/nlohmann.json.lua) | 一份生成的 `.cppm` 把 header-only 库变成 `import` 即用 |
| 外部构建系统 | [`compat.openssl`](pkgs/c/compat.openssl.lua) | `install()` 钩子驱动上游自己的 Perl Configure + Make |

完整目录 —— 本索引遇到过的全部形态,以及每个描述符背后的取舍(包括它刻意不做什么)——
见 **[描述符示例总览(按形态)](docs/zh/descriptor-examples.md)**。

### 新增一个包

完整流程定义于 agent skill [`add-mcpp-index-package`](.agents/skills/add-mcpp-index-package/SKILL.md)。可将下列
指令提供给 agent(如 Claude Code),由其调用该 skill 完成描述文件的编写与全流程:

```text
参考本仓 skill `.agents/skills/add-mcpp-index-package`,将 <库名 / 仓库URL> @<版本> 收录进 mcpp-index:
判定形态;配置 CN 镜像(无 mcpp-res 权限时使用 plain-string 上游 url);编写 pkgs/<首字母>/<包名>.lua;
添加 tests/examples/<库>/ 测试工程并登记为 workspace 成员;使用与 CI 同版本的 mcpp 本地执行
`mcpp test -p <成员>` 进行验证;更新 README 与在线索引;提交 PR 并确认 CI 通过。
```

细节文档位于 [`docs/zh/`](docs/zh/),供人工与 agent 共同使用(英文版位于 [`docs/`](docs/)):

- [库形态与描述符模板](docs/zh/package-types.md):各类形态的描述符模板与样例,以及最小工程的写法。
- [描述符示例总览(按形态)](docs/zh/descriptor-examples.md):索引里已有内容的完整目录,以及每个描述符为何这样写。
- [CN 镜像闭环](docs/zh/cn-mirror.md):`gtc` 与 gitcode 操作,以及无 `mcpp-res` 权限时的回退方案。
- [仓库结构与 schema 与 CI](docs/zh/repository-and-schema.md):字段速查、选跑机制与本地 lint。
- 字段的**权威判定**是 `mcpp xpkg parse`(CI 用的就是它:未知的 mcpp 段字段直接失败,而不是被静默忽略);
  语义与约束见 mcpp 仓的 [`docs/spec/`](https://github.com/mcpp-community/mcpp/tree/main/docs/spec)。

> 提交 PR 后,`validate` 自动执行 lint 并按改动库选跑对应 workspace 成员(整个测试面是一个 mcpp
> workspace,公开模块包 `imgui`/`ffmpeg`/`opencv`/`tinyhttps` 也是普通成员——`compat` 的重定向声明在
> workspace 根并由成员继承,消费其他命名空间的成员各自覆盖,零 shell 驱动);合并后,`deploy-site`
> 将其发布至在线浏览站。

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
