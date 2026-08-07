# Quick start

**English** | [简体中文](zh/quick-start.md)

From nothing to a C++23 project that imports a library from this index. Six
commands, no build-system configuration.

## 1. Install mcpp

```bash
xlings install mcpp -y
```

<details>
<summary>Don't have xlings yet?</summary>

```bash
# Linux / macOS
curl -fsSL https://d2learn.org/xlings-install.sh | bash
```

```powershell
# Windows · PowerShell
irm https://d2learn.org/xlings-install.ps1.txt | iex
```

</details>

## 2. Create and run a project

```bash
mcpp new hello
cd hello
mcpp run
```

The first build fetches the toolchain, so it takes a while; later builds are
incremental. What the scaffold gives you:

```
hello/
├── mcpp.toml          ← project manifest
└── src/
    └── main.cpp       ← `import std;` works out of the box
```

## 3. Add a package from this index

```bash
mcpp add nlohmann.json@3.12.0
```

The name is the one shown on every package page — `namespace.name`. The
command writes the dependency into your `mcpp.toml`:

```toml
[dependencies.nlohmann]
json = "3.12.0"
```

## 4. Use it

`nlohmann.json` is exposed as a C++23 module, so there is no header to find
and no include path to configure:

```cpp
// src/main.cpp
import std;
import nlohmann.json;

int main() {
    nlohmann::json j = { {"answer", 42}, {"list", {1, 2, 3}} };
    std::println("{}", j.dump());
}
```

Every package page tells you which line to write: `import x;` for module
packages, `#include <x>` for the `compat.*` ports, and it is taken from this
repository's own tests — code CI compiles.

## 5. Run it again

```bash
mcpp run
```

That is the whole loop: `mcpp add` → `import` → `mcpp run`.

## Where to go next

**Using packages**

- [Package types](package-types.md) — the four library shapes in this index and
  what each one means for you as a consumer
- [CN mirror](cn-mirror.md) — how packages resolve from the GitCode mirror in
  mainland China

**Contributing a package**

- [Adding a package](README.md) — the end-to-end procedure
- [Repository & schema](repository-and-schema.md) — descriptor fields, CI
  behaviour, how to reproduce lint locally

**mcpp itself**

- [mcpp README](https://github.com/mcpp-community/mcpp) — build system,
  toolchain management, the full command set
- [mcpp.toml guide](https://github.com/mcpp-community/mcpp/blob/main/docs/05-mcpp-toml.md)
  — version constraints, git references, local paths
