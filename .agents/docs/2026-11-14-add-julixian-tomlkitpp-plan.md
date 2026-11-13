# Add `julixian.tomlkitpp` (v1.0.0)

## 1. Source & Package Shape

- **Upstream Repository**: `https://github.com/julixian/tomlkitpp`
- **Package Identity**: `namespace = "julixian"`, `name = "tomlkitpp"` (`pkgs/j/julixian.tomlkitpp.lua`)
- **Version & Tag**: `1.0.0` (`v1.0.0`, SHA256 `b011a2a7a177e3256c2c2d469b65c0a8a85dd8017956092168f0394cc61c49a1`, verified across repeated downloads)
- **License**: `Apache-2.0`
- **Shape**: **Form A** native `mcpp` C++23 module library (`export module tomlkitpp;`).
  - Upstream ships a `[workspace]` manifest at the repository root (`mcpp.toml`) covering both the library (`tomlkitpp/`) and the `toml-test` compliance adapter (`tools/toml-test-adapter/`).
  - The self-contained library package manifest lives at `tomlkitpp/mcpp.toml`, referenced via `mcpp = "*/tomlkitpp/mcpp.toml"`.

## 2. Mirror & Autoupdate

- **CN Mirror**: Author submission without `gitcode.com/mcpp-res` write access; uses plain-string upstream GitHub archive URL per `docs/cn-mirror.md` fallback rules.
- **Autoupdate**: Configured `extensions.autoupdate` with `tag = "v${version}"` and `url = "https://github.com/julixian/tomlkitpp/archive/refs/tags/${tag}.tar.gz"`.

## 3. Feature Assessment

- Pure C++23 standard library module library (`import std;`), cross-platform across Linux, macOS, and Windows with zero external dependencies and no optional compiled components; no `features` gating required.

## 4. Consumer Smoke Test

- Added workspace member `tests/examples/julixian.tomlkitpp` exercising `import tomlkitpp;`, TOML v1.1.0 parsing (optional seconds, `\xHH` escapes, multiline/trailing-comma inline tables), multidimensional subscript edits, and comment/radix-preserving serialization round-trip.
