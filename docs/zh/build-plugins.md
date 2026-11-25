# 构建插件：`<owner>.mplugin.<name>`

**构建插件**是模块由工程的 `build.mcpp` 导入的包（`host-module`）：代码生成器、工具封装、规则集。本页是它们的命名与布局规则；设计记录见
`.agents/docs/2026-11-21-mcpp-build-plugin-naming-plan.md`。

[English](../build-plugins.md)

## 一个名字，三种写法

构建插件的 id 是 `<owner>.mplugin.<name>`；模块名和 C++ 命名空间都是这个 id：

| 写法 | 形式 | 例子 |
|---|---|---|
| 包（namespace + name） | `<owner>.mplugin` + `<name>` | `mcpplibs.mplugin.slint` |
| 模块 | id；子模块 `<id>.<子名>` | `mcpplibs.mplugin.slint` |
| C++ 命名空间 | id，`.` 换成 `::` | `mcpplibs::mplugin::slint` |

```cpp
// build.mcpp
import mcpp;
import mcpplibs.mplugin.slint;
int main() {
    mcpplibs::mplugin::slint::options o;
    o.sources = {"ui/app.slint"};
    return mcpplibs::mplugin::slint::compile(o) ? 0 : 1;
}
```

`mplugin` 是种类段，如同 `mwrap` 之于封装包（`mcpplibs.mwrap.slint` 是封装包，`mcpplibs.mplugin.slint` 是它的构建插件）。命名空间是
`<owner>::mplugin::<name>`，不是 `<owner>::mcpp::<name>`，所以插件内部直接写 `mcpp::…` 调用引擎，不会被遮蔽。

规则：

1. `<owner>` 与 `<name>` 是小写标识符，`[a-z][a-z0-9_]*`：多词用 `_` 连接，不用 `-`（模块名需要标识符；`mcpplibs.mwrap.godot_cpp` 是同一条规则）。
2. `<owner>` 是维护者。`mcpplibs` 只给 mcpplibs 组织维护的包；其他人用自己的名字。
3. `<owner>` 不得是 `mcpp`，不得是 mcpp 项目的保留名（`core`、`plugins`、`deps`、`rules`、`dist`、`tools`、`platforms`），也不得是种类段（`mwrap`、
   `mplugin`）。官方新增一个包名即加入保留名，新增时须核对没有 owner 已用此名。
4. 主接口模块恰好是 id；包内其他模块都以 `<id>.` 开头。
5. 第一段是 `mcpp` 的包由 mcpp 项目维护，不属于这个形态（`mcpp.plugins`、`mcpp.platforms`）。
6. 与某个库绑定的规则，`<name>` 是库名（`slint`、`grpc`、`protobuf`），不加 `gen`、`-bind` 后缀；同一个库的多个规则是同一个包的函数。通用工具取工具名
   （`clangtidy`）。

## 规则放在哪里

| 类型 | 放在 | 工程怎么写 |
|---|---|---|
| 与某个库绑定 | 该库 `-m` 仓库的 `rules/` 子包；描述符写 `mcpp = "*/rules/mcpp.toml"`；封装包的根 manifest 有 `<id> = { path = "rules", host-module = true, reexport = true }` | 只依赖封装包 |
| 通用工具 | 自己的仓库 | `[build-dependencies] <id> = { version = "…", host-module = true }` |
| 引擎级、跨生态 | mcpp 项目的 `mcpp.plugins` | `mcpp.plugins` 的某个 feature |

规则包自己的依赖写在它的 `[dependencies]`（mcpp 2026.10.11.1 及以后）。认领文件扩展名的 feature 不经 `reexport` 传递，所以与库绑定的规则以 `options`
字段接收输入（`mcpplibs.mplugin.slint` 的 `options::sources`）。

## 索引布局

- 描述符是 `pkgs/mcpp/<完整 id>.lua`，一层平铺：官方的 `pkgs/mcpp/mcpp.plugins.lua`，插件的 `pkgs/mcpp/mcpplibs.mplugin.slint.lua`。这个目录放的是
  mcpp 自己加载的包；身份以描述符声明的为准（`namespace = "<owner>.mplugin"`、`name = "<name>"`），与 `pkgs/mwrap/` 相同。目录不说明包是什么：
  `mcpp.platforms` 是平台数据，不是插件。
- namespace 为 `<owner>.mplugin` 的描述符在 `pkgs/mcpp/`；`pkgs/mcpp/` 里文件的 namespace 是 `mcpp` 或 `<owner>.mplugin`（lint：
  `tests/check_mplugin_layout.lua`）。
- **构建插件与它的库分开测试。** 插件的成员只测 `build.mcpp` 能用它做什么（规则对一个小输入产出什么，生成的模块能否编译，改动的输入是否重新生成）；库本身的行为
  由封装包的成员与已安装模板检查来测。与库绑定的插件起初通过封装包的成员测（`tests/mwrap/…`）；独立的插件用 `tests/mcpp/<owner>-<name>/`。

## 版本

每个包有自己的版本线：首个版本是它所针对的上游版本，修订追加 `.N`，标签不移动。与库绑定的规则随封装包发布：描述符的行指向封装包的标签归档（同样的字节、同一个
sha256、GLOBAL 与 CN），规则自己的 `rules/mcpp.toml` 版本等于这一行，不必等于封装包的修订号（`mcpplibs.mplugin.slint@1.19.0` 在
`mcpplibs.mwrap.slint@1.19.0.3` 的归档里）。这样的描述符不写 `autoupdate`：它的行与封装包的行一起加入。

## 较早的包

本页之前发布的构建规则继续可用：`mcpplibs.slintgen`、`mcpplibs.grpcgen`、`mcpplibs.protogen`、`mcpplibs.clangtidy`、`mcpplibs.openkal-bind` 遵循较早的规则
（模块 `mcpp.<namespace>.<name>`，SPEC-007 §9），并不是错的。它们的描述符与归档保留；已发布的行不改。

- 一个包在下次需要新版本时迁到新形态：新 id 在 `pkgs/mcpp/` 发布，老描述符冻结（无 `autoupdate`，描述里写 `FROZEN: superseded by <id>`），不再有新版本。没有转发模块。
- id 就是身份，老 id 不能改用新的模块名：写着 `x = "1"` 的工程会在升级时被带到新的模块名。
- 写了老 id 的工程保留它的各个版本，改依赖名即可迁移。

| 老 id | 新 id | 迁移 |
|---|---|---|
| `mcpplibs.slintgen` | `mcpplibs.mplugin.slint` | 1.19.0 |
| `mcpplibs.grpcgen` | `mcpplibs.mplugin.grpc` | grpc-m 的下次发布 |
| `mcpplibs.protogen` | `mcpplibs.mplugin.protobuf` | protobuf-m 的下次发布 |
| `mcpplibs.clangtidy` | `mcpplibs.mplugin.clangtidy` | 它的下次发布 |
| `mcpplibs.openkal-bind` | `mcpplibs.mplugin.openkal_bind` | openkal 的下次发布 |

`mcpplibs.rules-cuda` 是指向 `mcpp.rules.cuda` 的占位包，保持原样。

## 检查

| 检查 | 位置 |
|---|---|
| namespace 不是 `mcpp.` 的保留第二段；owner 不是 `mcpp`、保留名或种类段 | `tests/check_reserved_namespace.lua` |
| 布局：`<owner>.mplugin` ↔ `pkgs/mcpp/`；owner 与 name 是标识符 | `tests/check_mplugin_layout.lua` |
| 成员构建不打印引擎对保留模块名的警告 | `tests/run_members.sh` |
| 模块就是包 id | 规则自己仓库的 CI（索引读不到归档里的源码） |

构建插件在构建机器上运行代码：按“会执行代码的包”评审。`mplugin` 不表示已审计；owner 是谁、模仿 `mcpplibs` 的名字，由评审判断。
