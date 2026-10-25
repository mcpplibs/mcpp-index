# mcpp-index

[English](README.md) · [简体中文](README.zh-CN.md)

The default package index for [mcpp](https://github.com/mcpp-community/mcpp):
C++ modules and third-party C/C++ libraries built from source.

[Browse packages](https://mcpplibs.github.io/mcpp-index/) · [Quick start](docs/quick-start.md)

## Usage

```sh
mcpp search <keyword>
mcpp add ftxui@6.1.9
mcpp build
```

Use `mcpp self config --mirror CN` to select the CN mirror.
The minimum supported mcpp version is recorded in [index.toml](index.toml).

## Contributing

Follow the [package contribution guide](docs/README.md) or the
[agent skill](.agents/skills/add-mcpp-index-package/SKILL.md).
Each package has a Lua descriptor and a consumer test. Eligible GitHub packages
use [automatic updates](docs/automatic-updates.md): daily checks open version PRs
for review while preserving existing versions.

- [Package types and templates](docs/package-types.md)
- [Descriptor examples](docs/descriptor-examples.md)
- [CN mirrors](docs/cn-mirror.md)
- [Repository, schema and CI](docs/repository-and-schema.md)
- [openkal compatibility](docs/openkal-compat.md)

## License

Package descriptors are CC0. Upstream libraries retain their own licenses.
