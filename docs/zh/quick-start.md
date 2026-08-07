# 快速开始

[English](../quick-start.md) | **简体中文**

从零到一个 import 本索引库的 C++23 项目。六条命令,不用配任何构建系统。

## 1. 安装 mcpp

```bash
xlings install mcpp -y
```

<details>
<summary>还没有 xlings?</summary>

```bash
# Linux / macOS
curl -fsSL https://d2learn.org/xlings-install.sh | bash
```

```powershell
# Windows · PowerShell
irm https://d2learn.org/xlings-install.ps1.txt | iex
```

</details>

## 2. 创建并运行项目

```bash
mcpp new hello
cd hello
mcpp run
```

首次构建会拉取工具链,耗时较长;之后都是增量构建。脚手架生成的结构:

```
hello/
├── mcpp.toml          ← 项目清单
└── src/
    └── main.cpp       ← `import std;` 开箱可用
```

## 3. 从本索引添加一个库

```bash
mcpp add nlohmann.json@3.12.0
```

这个名字就是每个包页面上显示的那个 —— `namespace.name`。命令会把依赖写进
`mcpp.toml`:

```toml
[dependencies.nlohmann]
json = "3.12.0"
```

## 4. 使用它

`nlohmann.json` 以 C++23 模块暴露,不需要找头文件,也不用配 include 路径:

```cpp
// src/main.cpp
import std;
import nlohmann.json;

int main() {
    nlohmann::json j = { {"answer", 42}, {"list", {1, 2, 3}} };
    std::println("{}", j.dump());
}
```

每个包页面都会告诉你该写哪一行:模块包是 `import x;`,`compat.*` 移植层是
`#include <x>`。这些行取自本仓自己的测试代码 —— CI 编译过的。

## 5. 再运行一次

```bash
mcpp run
```

整个循环就是这样:`mcpp add` → `import` → `mcpp run`。

## 接下来

**使用包**

- [四种库形态](package-types.md) —— 本索引中的四类库,以及它们对使用者各意味着什么
- [CN 镜像](cn-mirror.md) —— 国内如何从 GitCode 镜像解析包

**贡献一个包**

- [新增一个包](README.md) —— 端到端流程
- [仓库结构与 schema](../repository-and-schema.md) —— 描述符字段、CI 行为、本地复现 lint

**mcpp 本身**

- [mcpp README](https://github.com/mcpp-community/mcpp) —— 构建系统、工具链管理、完整命令集
- [mcpp.toml 指南](https://github.com/mcpp-community/mcpp/blob/main/docs/05-mcpp-toml.md)
  —— 版本约束、git 引用、本地路径
