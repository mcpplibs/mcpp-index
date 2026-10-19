# mcpp-index

[English](README.md) · [简体中文](README.zh-CN.md)

[mcpp](https://github.com/mcpp-community/mcpp) 的默认包索引，
收录 C++ 模块库和从源码构建的第三方 C/C++ 库。

[浏览包](https://mcpplibs.github.io/mcpp-index/) · [快速开始](docs/zh/quick-start.md)

## 使用

```sh
mcpp search <keyword>
mcpp add ftxui@6.1.9
mcpp build
```

使用 `mcpp self config --mirror CN` 切换国内镜像。
最低 mcpp 版本见 [index.toml](index.toml)。

## 贡献

参考[包贡献指南](docs/zh/README.md)或
[agent skill](.agents/skills/add-mcpp-index-package/SKILL.md)。
每个包包含 Lua 描述符和消费测试。符合条件的 GitHub 包接入
[自动更新](docs/zh/automatic-updates.md)：每日检查新版本并创建 PR，
保留已有版本，由维护者 review 后合并。

- [包形态与模板](docs/zh/package-types.md)
- [描述符示例](docs/zh/descriptor-examples.md)
- [国内镜像](docs/zh/cn-mirror.md)
- [仓库、schema 与 CI](docs/zh/repository-and-schema.md)
- [openkal 兼容性](docs/zh/openkal-compat.md)

## License

包描述符采用 CC0；上游库保留各自的许可证。
