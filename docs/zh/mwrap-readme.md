# mwrap / xxx-m README 布局规范

[English](../mwrap-readme.md)

本规范适用于以 `<upstream>-m` 仓库维护的模块封装。
包身份、版本与实现归属遵循 [mwrap 规范](mwrap.md)。

## 语言与页首

- `README.md` 默认英文，必须提供简体中文 `README.zh.md`。
- 将语言切换、具体上游仓库、Releases、mcpp、Index **合并到同一行导航**；上游入口统一写为 `[Upstream](https://github.com/owner/repo)`，不显示 `Upstream: owner/repo`。
- 项目名后只保留**一句话介绍**。较详细的能力/架构介绍放在 **badges 下方、Modules 与 Getting started 前方**，
  不再增加 Characteristics / 核心特性标题。
- 保留原有且有用的少量徽章和导航；CI/release 链接指向封装仓库，许可证必须准确，
  不以徽章暗示尚未支持的功能。

页首顺序固定如下，详细介绍可省略：

```text
# 项目名
> 一句话介绍。
English · 简体中文 · [Upstream](upstream-url) · Releases · mcpp · Index
[badges]
可选的详细介绍，不增加 Characteristics 标题。
## Modules
- `import mcpplibs.mwrap.library;`: 核心 API
- `import mcpplibs.mwrap.library.macros;`: 宏映射
> More Modules API -> [模块与 API](docs/usage.md)
## Getting started
```

快速开始标题保留各项目对应的原名称，例如 Quick start、Install、Add The Package。
导航按要求写在一行；普通正文不应因此压成超长行。

## 内容与顺序

页首之后保留各项目有用的原栏目层级与顺序，统一风格不等于整页替换成同一组标题。
翻译标题时保持语义对应。新 README 可以以下顺序起步，按库的实际用途调整：

1. 标题、一句话介绍、单行导航、badges；可选详细介绍位于 badges 之后，接着先 Modules 再快速开始。
2. Modules 放在 Getting started 前，根模块和少量核心模块逐行列出：
   每项用完整 import 代码、冒号与用途说明；模块必须真实声明，必要时注明 feature 条件。
   下方统一使用引用链接 `> More Modules API -> [模块与 API](docs/usage.md)`。
3. 使用实际默认 `mcpp new` 模板快速开始；必要时补已有项目的依赖与 import 示例。
   mcpp feature 开关可在后续栏目用简洁表格说明。
4. 在原栏目保留示例、重要平台/运行前提、详细文档和许可证入口。

不添加重复的 `Use mcpp <版本>. The new mwrap identity becomes installable after index publication.`
统一提示段。精确工具版本放在 `.xlings.json`、CI 与详细使用/构建说明中；
只有执行命令确实需要时，才在对应栏目简述必要的工具、SDK、桌面或设备前提。
候选状态放在 release/PR 文档中；具体示例尚不可用时，仍要在会误导用户的位置明确说明。

## mcpp feature 与示例

这里专指 mcpp 清单的 `[features]` / `[feature-deps.*]` 开关，不是一般功能介绍。
优先使用“精确 feature 名称 + 用途”的简洁表格，默认值和模块/后端边界用一句话说明：

| Feature | 用途 |
|---|---|
| `all-modules` | 主模块接口集合，外部后端仍显式选择 |
| `highgui-native` | 已记录的 GTK3 / Win32 / Cocoa 映射 |
| `dnn-onnxruntime` | 支持目标上的 ORT CPU 集成 |

没有可选 feature 的库不强造 Features 栏目。完整矩阵、依赖图、供应者设置与排错移到 docs，
从对应栏目链接；未实现的 feature 不出现在已支持表格中。

依赖、模板命令与 import 显示完整 `mcpplibs.mwrap.<lib>`，普通 API 保留上游名字。
示例版本必须与实际发布一致。默认模板无需用户额外提供模型或媒体资产即可运行；
可选模板的桌面、SDK 和设备条件要清楚，最小例子也应使用真实库能力。

## 长度与双语核对

每种语言通常控制在约 **100–150 行以内**，更短也可以，不为凑 100 行填充内容。
不删除前提、不压成超长行、不用大段折叠隐藏内容；发布检查可以对超过 150 行的页面提示修订。

中英文版本、命令、feature、平台限制和相关链接保持一致，无需行数机械相等。
单独验证翻译后的标题锚点与双向链接。
原本中文为主的默认页改为英文默认，同时在 `README.zh.md` 保留对应中文内容及有用布局。
