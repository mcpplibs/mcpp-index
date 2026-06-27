# 新增 cJSON + nlohmann/json 收录 + 按改动库选跑 CI 方案

**日期**: 2026-06-27
**本仓**: `mcpp-community/mcpp-index`(github 别名 `mcpplibs/mcpp-index`)
**目标**:
1. 收录 [`DaveGamble/cJSON`](https://github.com/DaveGamble/cJSON) —— **全兼容(compat)源码构建**,参照 `compat.gtest`。文件名 `pkgs/c/compat.cjson.lua`。
2. 收录 [`nlohmann/json`](https://github.com/nlohmann/json) —— 以 **模块化** 形态暴露 `import nlohmann.json;`(ns=`nlohmann`,name=`json`)。文件名 `pkgs/n/nlohmann.json.lua`。
3. 两者都补 **GitCode CN 镜像**(`gitcode.com/mcpp-res/...`),用本仓 `tools/gtc` 推送。
4. CI 不再每次全量跑 smoke,而是 **只跑本次改动到的库**;并在 `tests/` 下给每个库放一个最小工程示例。

---

## 0. 关键前置结论(必须先对齐)

> ✅ **nlohmann/json 官方已写好 module 接口单元 `src/modules/json.cppm`,内容 `export module nlohmann.json;`。**
> 但它 **只在 `develop` 分支,尚未进任何已发布 tag**:`v3.12.0` 与 `v3.11.3` 取 `src/modules/json.cppm`
> 均 404(该文件是 3.12.0 发布后才加入 develop 的;文件头虽写 "version 3.12.0",tag 里并不含它)。
> 结论:**已发布的 v3.12.0 源码包里没有 `.cppm`**,但官方已给出 **权威 wrapper 内容**(见 §3,可逐字复用)。

**决策(用户已定,§7 Q1)**:走 **方案 A —— mcpp `generated_files` 合成 module wrapper**,
基底头用已发布的 `v3.12.0`(可复现的 release tag),wrapper 内容 **逐字采用上游官方 `json.cppm`**
(不再自己猜符号清单)。待 nlohmann 下一个 release(>3.12.0)正式带上 `src/modules/json.cppm` 后,
可平滑切成"直接把上游 `.cppm` 列进 `sources`"、删掉 generated 块(见 §3.3 演进路径)。

| 库 | 形态 | 最新 tag | 收录版本 | 语言 | 模块来源 |
|---|---|---|---|---|---|
| cJSON | 纯 C 源码 | `v1.7.19` | `1.7.19` | C(C89/C99) | 否(compat 头+源) |
| nlohmann/json | header-only C++(release 无 .cppm) | `v3.12.0` | `3.12.0` | C++ | **generated wrapper(逐字复用上游官方 json.cppm)** |

---

## 1. cJSON —— `pkgs/c/compat.cjson.lua`(全兼容,参照 gtest/zlib)

cJSON 与 zlib 同类:**纯 C、源码极少**(根目录 `cJSON.c` / `cJSON.h`,可选 `cJSON_Utils.c` / `cJSON_Utils.h`)。
直接 Form B inline descriptor,源码编译成 lib,用户 `#include <cJSON.h>`。

### 1.1 上游布局(v1.7.19 根目录,无子目录)
```
cJSON.c  cJSON.h  cJSON_Utils.c  cJSON_Utils.h  CMakeLists.txt  ...
```
GitHub tarball 会套一层 `cJSON-1.7.19/` → glob 用 `*/` 吸收。

### 1.2 descriptor 草案
```lua
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "compat.cjson",
    description = "Ultralightweight JSON parser in ANSI C",
    licenses    = {"MIT"},
    repo        = "https://github.com/DaveGamble/cJSON",
    type        = "package",

    xpm = {  -- linux/macosx/windows 三平台同 url+sha256(纯源码,平台无关)
        linux   = { ["1.7.19"] = { url = { GLOBAL = "https://github.com/DaveGamble/cJSON/archive/refs/tags/v1.7.19.tar.gz",
                                            CN     = "https://gitcode.com/mcpp-res/cjson/releases/download/1.7.19/cjson-1.7.19.tar.gz" },
                                   sha256 = "<TODO 实现期算>" } },
        macosx  = { ["1.7.19"] = { ... 同上 ... } },
        windows = { ["1.7.19"] = { ... 同上 ... } },
    },

    mcpp = {
        language   = "c++23",   -- 与 gtest/zlib 对齐;实际 C 源由 c_standard 控制
        import_std = false,
        c_standard = "c99",
        include_dirs = { "*" },          -- 暴露 cJSON.h / cJSON_Utils.h
        sources    = { "*/cJSON.c" },    -- 核心始终编入
        targets    = { ["cjson"] = { kind = "lib" } },
        -- cJSON_Utils 是可选扩展(JSON Pointer / Patch / merge),仿 gtest 的 main 特性门控,
        -- 默认不编;features = ["utils"] 时才加入。
        features   = {
            ["utils"] = { sources = { "*/cJSON_Utils.c" } },
        },
        deps       = {},
    },
}
```

### 1.3 要点
- **CJSON_PUBLIC / __declspec**:静态库默认不定义 `CJSON_EXPORT_SYMBOLS`/`CJSON_IMPORT_SYMBOLS`,`CJSON_PUBLIC` 退化为裸函数,无需特殊 cflags。Windows 下保持静态即可,**不要**定义 `CJSON_API_VISIBILITY`。
- `cJSON_Utils.c` `#include "cJSON_Utils.h"`(同目录),`include_dirs = {"*"}` 已覆盖。
- 与 gtest 一样:核心源进 `sources`(老 mcpp 无 `features` 也不回归);`utils` 走 feature 门控,语义干净。

---

## 2. CN 镜像(gtc)—— cJSON

参照发布闭环(`release-publish-pipeline` 笔记)+ 既有 compat 的 CN 命名:
`https://gitcode.com/mcpp-res/<repo>/releases/download/<ver>/<repo>-<ver>.tar.gz`。

cJSON 取 repo 名 `cjson`(短名,与 gtest/zlib/imgui 风格一致):
```bash
# 1. 下上游 tarball,重命名为镜像约定名
curl -L -o cjson-1.7.19.tar.gz \
  https://github.com/DaveGamble/cJSON/archive/refs/tags/v1.7.19.tar.gz
sha256sum cjson-1.7.19.tar.gz            # → 填入 descriptor 三平台 sha256

# 2. 用本仓 vendored tools/gtc 在 mcpp-res 下建仓 + 发 release 资产
tools/gtc repo create mcpp-res/cjson --public            # 若不存在
tools/gtc release create mcpp-res/cjson 1.7.19 \
  --asset cjson-1.7.19.tar.gz
# 3. 校验 CN url 200(validate.yml 的 mirror-cn-reachable 会再兜一遍)
curl -fsSL -o /dev/null -w '%{http_code}\n' \
  https://gitcode.com/mcpp-res/cjson/releases/download/1.7.19/cjson-1.7.19.tar.gz
```
> gtc 子命令以本仓 `tools/gtc --help` 实际签名为准(上方为示意);GITCODE_TOKEN 走本地环境。
> 注意笔记里的坑:gitcode release **同名资产不可覆盖**,误传需网页删;故命名一次定死。

---

## 3. nlohmann/json —— `pkgs/n/nlohmann.json.lua`(模块化暴露,方案 A 已定)

目标:用户 `mcpp add nlohmann.json@3.12.0` 后写 `import nlohmann.json;` 即可用 `nlohmann::json`。
已发布的 v3.12.0 源码包不含 `.cppm`(§0),故用 mcpp `generated_files` 合成 module wrapper;
**wrapper 内容逐字采用上游官方 `src/modules/json.cppm`**(已抓取,见 §3.1),不自己猜符号。

### 3.0 决策:import 默认开启(无 opt-in)
- **import 是默认且唯一主入口**:生成的 `nlohmann.json.cppm` 始终编进 `sources`,
  `mcpp add nlohmann.json@3.12.0` 后开箱 `import nlohmann.json;`,**不走 feature 门控、不要求用户 `#include`**。
- **header 作为副产物仍可用**:`include_dirs = {"*/single_include"}` 让 `#include <nlohmann/json.hpp>`
  也能用(wrapper 内部本就 include 它),但不是用户需关心的入口。
- **为何用 generated 而非把 json.cppm 塞进镜像包(GLOBAL/CN 一致性)**:已发布 v3.12.0 tarball 不含
  `src/modules/json.cppm`(只在 develop)。GLOBAL 用 github 原版包、CN 是其镜像,两端必须对应**同一个上游包**。
  `generated_files` 在两端同一个 stock v3.12.0 包上**本地生成** `.cppm`,天然两端一致;若改成"把 json.cppm
  塞进 CN 镜像包"会令 CN ≠ GLOBAL,破坏一致性、且 `mirror-cn-reachable` 之外无人察觉。故默认 import = generated。

### 3.1 上游官方 wrapper(逐字复用,develop @ `src/modules/json.cppm`)
要点(我方 `generated_files` 必须 1:1 还原,含两处别人容易漏的细节):
- `module;` 全局片段里 `#include <nlohmann/json.hpp>`,然后 `export module nlohmann.json;`。
- 用 `NLOHMANN_JSON_NAMESPACE_BEGIN/END` 宏(不是裸 `namespace nlohmann`)包裹一组 `export using`:
  `adl_serializer / basic_json / json / json_pointer / ordered_json / ordered_map / to_string`。
- `inline namespace literals { inline namespace json_literals { ... } }` 重导出
  `operator""_json` 与 `operator""_json_pointer`。
- **MSVC #3970 workaround**:额外 `export` `detail::json_sax_dom_callback_parser` 与 `detail::unknown_size`
  ——漏了在 MSVC 上编不过。这正是"逐字复用上游"的价值。

### 3.2 descriptor 草案(方案 A)
```lua
package = {
    spec        = "1",
    namespace   = "nlohmann",
    name        = "nlohmann.json",
    description = "JSON for Modern C++, exposed as C++23 module nlohmann.json",
    licenses    = {"MIT"},
    repo        = "https://github.com/nlohmann/json",
    type        = "package",

    xpm = { linux/macosx/windows = { ["3.12.0"] = {
        url = { GLOBAL = "https://github.com/nlohmann/json/archive/refs/tags/v3.12.0.tar.gz",
                CN     = "https://gitcode.com/mcpp-res/nlohmann-json/releases/download/3.12.0/nlohmann-json-3.12.0.tar.gz" },
        sha256 = "<TODO 实现期算>" } } },

    mcpp = {
        schema       = "0.1",
        language     = "c++23",
        import_std   = false,            -- wrapper 全局片段含上游头;开 import std 易冲突,先关
        modules      = { "nlohmann.json" },
        include_dirs = { "*/single_include" },   -- 提供 <nlohmann/json.hpp>
        generated_files = {
            -- 内容 = 上游官方 json.cppm 逐字(此处用 Lua 长串 [[ ... ]] 嵌入完整文件,含 #3970 detail 导出)
            ["mcpp_generated/nlohmann.json.cppm"] = [[<上游 src/modules/json.cppm 全文>]],
        },
        sources      = { "mcpp_generated/nlohmann.json.cppm" },
        targets      = { ["nlohmann_json"] = { kind = "lib" } },
        deps         = {},
    },
}
```

**落地期必测(R1,唯一硬风险)**:mcpp 能否把 `generated_files` 产出的 `.cppm` 当 module 接口单元
参与 BMI 扫描 + 编译并导出?zlib 先例只生成 **头**(被 `-include`),未验证生成 **module 单元**。
- R1 成立 → 方案 A 收工。
- R1 不成立 → 回退 §3.3 的"直接消费上游 .cppm"路径(pin 一个含该文件的 develop 提交 tarball),
  或新建 `mcpplibs/json-m`(独立模块仓,imgui-m 同款 Form A)。该回退在 Q2 已获用户授权。

### 3.3 演进路径(上游 release 带上 .cppm 后)
当 nlohmann 下个 release(>3.12.0)正式包含 `src/modules/json.cppm`:
descriptor 改为 `sources = {"*/src/modules/json.cppm"}` + `include_dirs = {"*/single_include"}`,
**删除 `generated_files` 整块**,直接消费上游官方单元。语义最干净、零自维护内容。

### 3.4 nlohmann CN 镜像(gtc)
repo 名取 `nlohmann-json`(避免裸 `json` 歧义):
```bash
curl -L -o nlohmann-json-3.12.0.tar.gz \
  https://github.com/nlohmann/json/archive/refs/tags/v3.12.0.tar.gz
tools/gtc repo create mcpp-res/nlohmann-json --public
tools/gtc release create mcpp-res/nlohmann-json 3.12.0 --asset nlohmann-json-3.12.0.tar.gz
```

---

## 4. CI 改造:按改动库选跑 + tests/ 每库最小工程

### 4.1 现状痛点
`.github/workflows/validate.yml` 的 `smoke-linux` / `smoke-portable` 把
core/imgui/archive/imgui_window/imgui_module **全量串跑**(每 job `timeout 1800`×5)。
改一个无关库也全跑,慢且浪费。

### 4.2 目标结构:`tests/examples/<pkg>/`
每个库一个**最小可构建工程**(自带 `mcpp.toml` + 一个源文件),目录名 = 包短名:
```
tests/
  examples/
    cjson/          mcpp.toml  src/main.c      (cJSON 解析往返断言)
    nlohmann.json/  mcpp.toml  src/main.cpp    (import nlohmann.json; 往返断言)
    gtest/          ...        (逐步把现有 smoke 拆成单库工程,迁移式,不强制一次到位)
  run_example.sh    <pkg>      # 通用 runner:套本地 path index + mcpp build + mcpp run
  smoke_compat_*.sh           # 保留(全量回归,可改为 nightly/手动触发)
```
- `run_example.sh <pkg>`:复刻 `smoke_compat_core.sh` 的 **本地 path index 装配**(link xpkgs、
  指 `[indices].compat = { path = ROOT }`),进 `tests/examples/<pkg>` 执行 `mcpp build && mcpp run`。
- 各工程 `mcpp.toml` 的 `[indices].compat = { path = "../../.." }` 指回仓根。

### 4.3 选跑机制:改动 → 受影响库 → matrix
方案(GitHub Actions,二选一):
- **(推荐)`dorny/paths-filter`** 或 `git diff --name-only origin/${{ github.base_ref }}...HEAD`
  取改动的 `pkgs/*/*.lua`,用**文件名 → 包短名**映射(`compat.cjson.lua`→`cjson`,
  `nlohmann.json.lua`→`nlohmann.json`)生成 job matrix,只对存在 `tests/examples/<pkg>/` 的库跑。
- 改到 `tests/run_example.sh` / `validate.yml` / 公共脚手架 → **全量跑**(安全网)。
- 无任何 `pkgs/**` 改动(纯 README/docs)→ 跳过 smoke,只跑 lint。

伪代码(新增 job,替换现 smoke-linux 全量段):
```yaml
detect:
  outputs: { pkgs: ${{ steps.f.outputs.pkgs }} }
  steps:
    - uses: actions/checkout@v4  # fetch-depth: 0
    - id: f
      run: |
        base="origin/${{ github.base_ref || 'main' }}"
        changed=$(git diff --name-only "$base"...HEAD -- 'pkgs/*/*.lua')
        # 公共脚手架变更 → 全量
        if git diff --name-only "$base"...HEAD | grep -qE '^(tests/run_example\.sh|\.github/workflows/validate\.yml)$'; then
          ls -d tests/examples/*/ | xargs -n1 basename | jq -R . | jq -sc . ; exit
        fi
        # 否则按改动文件映射到 examples 目录
        for f in $changed; do
          base_pkg=$(basename "$f" .lua); base_pkg=${base_pkg#compat.}
          [ -d "tests/examples/$base_pkg" ] && echo "$base_pkg"
        done | sort -u | jq -R . | jq -sc .
smoke:
  needs: detect
  if: needs.detect.outputs.pkgs != '[]'
  strategy: { matrix: { pkg: ${{ fromJson(needs.detect.outputs.pkgs) }} } }
  steps: [ ... 下 mcpp ... , run: bash tests/run_example.sh "${{ matrix.pkg }}" ]
```
- `lint` / `mirror-cn-reachable` 始终跑(便宜,且对全量 `pkgs/*.lua` 校验,不受选跑影响)。
- `smoke-portable`(mac/win)同改造或暂保留:本期可先只对 **新增的 cjson + nlohmann.json** 接入选跑,
  存量库 examples 渐进迁移,避免一次重写所有 smoke。

### 4.4 兼容与迁移
- 现有 `smoke_compat_*.sh` **不删**,降级为「全量回归」:`workflow_dispatch` + nightly `schedule` 触发,
  PR 路径只走选跑 examples。保证大改/脚手架变更仍有全覆盖兜底。

---

## 5. 改动文件清单

| 文件 | 动作 |
|---|---|
| `pkgs/c/compat.cjson.lua` | 新增(§1) |
| `pkgs/n/nlohmann.json.lua` | 新增(§3,方案 A;`pkgs/n/` 为新目录) |
| `tests/examples/cjson/{mcpp.toml,src/main.c}` | 新增最小工程 |
| `tests/examples/nlohmann.json/{mcpp.toml,src/main.cpp}` | 新增最小工程 |
| `tests/run_example.sh` | 新增通用 runner |
| `.github/workflows/validate.yml` | 改:detect+matrix 选跑;全量降级 nightly |
| `README.md` | 「第三方 C/C++ 库」表加 cjson;模块库区加 `nlohmann.json` |
| CN 镜像 | `mcpp-res/cjson` + `mcpp-res/nlohmann-json` 两个 gitcode release(gtc) |

---

## 6. 落地步骤(顺序)

1. **gtc 镜像**:下两个上游 tarball → 算 sha256 → gtc 建仓发 release → 记录 sha256。
2. **写 descriptor**:`compat.cjson.lua`(填 sha256)、`nlohmann.json.lua`(方案 A)。
3. **本地验证 R1**:对 nlohmann 跑一次 `mcpp build`,确认 generated `.cppm` 作为 module 源可编;
   失败 → 切方案 C(或回报用户)。
4. **最小工程 + runner**:`tests/examples/{cjson,nlohmann.json}` + `run_example.sh`,本地 `mcpp run` 绿。
5. **CI 改造**:validate.yml detect+matrix;本地用 `act` 或开 PR 实测「只跑改动库」。
6. **README** 更新;开 PR(标题示意:`feat(pkgs): add cJSON (compat) + nlohmann.json (module) + per-pkg CI`)。
7. PR 合并后,`publish-artifact.yml` 自动重发 mcpp-index artifact + 移指针(无需发 mcpp 版本)。

---

## 7. 开放问题

- **Q1 ✅ 已定**:`import nlohmann.json;` 走 **方案 A(mcpp `generated_files` 合成 wrapper)**,
  wrapper 内容逐字复用上游官方 `src/modules/json.cppm`(§3.1)。
- **Q2 ✅ 已授权回退**:方案 A 依赖 R1(generated `.cppm` 可当 module 源,§3.2)。本地实测若不成立,
  回退「直接消费上游 .cppm(pin develop 提交)」或新建 `mcpplibs/json-m`(§3.3);不降级成非模块。
- **Q3**(待确认默认):CN 镜像 repo 命名 `mcpp-res/cjson` 与 `mcpp-res/nlohmann-json`(后者避免裸 `json`)。
  无异议即采用。
- **Q4**(待确认默认):CI 选跑本期范围 —— 只对**新增两库**接入 examples 选跑、存量库渐进迁移(推荐),
  还是一次性把 imgui/core 等所有 smoke 都拆成 examples。默认走渐进。
- **Q5**(待确认默认):cJSON 的 `cJSON_Utils` 用 feature `utils` 门控(默认不编)。无异议即采用。

---

## 8. 实现记录 + CI 排查(2026-06-27 落地)

落地结果:cjson + nlohmann.json 两包均已实测可用(真实 mcpp 管线:CN 镜像拉取 → 生成 → 编译 → 运行),
PR #48。两处与「升级到最新 mcpp 0.0.67」相关的 CI 排查:

### 8.1 R1 结论(generated `.cppm` 作 module 源)— 成立
本地 mcpp 0.0.66 实测:`generated_files` 生成的 `nlohmann.json.cppm` 被当作 module 接口单元正常
编译,`import nlohmann.json;` 开箱可用(`nlohmann::json` / `ordered_json` / `_json` UDL 全 OK)。
**关键坑**:`mcpp` 段解析器不支持 Lua 长括号 `[[...]]`(`publisher.cppm:76` 明示),必须用
双引号字符串 + `\n`/`\"` 转义(同 zlib);否则 `error: malformed mcpp segment`。
**消费侧坑**:`import nlohmann.json;` 不要和文本 `#include <string>` 混用(GCC modules 冲突),
应配 `import std;`;UDL 需 `using namespace nlohmann::literals;`。

### 8.2 旧 smoke 在 0.0.67 暴露的两处「与本 PR 无关」的历史漂移
升级 CI mcpp `0.0.46 → 0.0.67`(新 example job 需要)后,旧全量 smoke 暴露两处既有问题:

1. **gtest `undefined symbol: main`(已修)**:`smoke_compat_{core,portable}.sh` 用 gtest `TEST()` 但
   不自带 `main()`,依赖 `gtest_main`。#168 把 `gtest_main.cc` 收进 `main` feature;0.0.67 **遵守**
   门控(默认不链)→ 无 main;0.0.46 **忽略** feature 总是链入,故旧版「假绿」。
   **修复**:依赖声明改 `gtest = { version = "1.15.2", features = ["main"] }`(本地 0.0.66 实测全绿)。

2. **glfw `abi:glibc` 在 clang/libc++ 下误报(mcpp core bug,已在 0.0.68 修复并回收)**:
   CI 报 `ABI mismatch: compat.glfw requires abi=glibc but resolved clang 20.1.7 (libc++)`。
   **真正肇事**是 `smoke_imgui_module.sh`(**显式 pin `llvm@20.1.7`**,非 imgui_window、非"工具链误解析")——
   其传递依赖 glfw 声明 `abi:glibc`。**根因**:mcpp `prepare.cppm` 的 `abi:` 门控把 **libc ABI** 与
   **C++ 标准库**混为一谈(`stdlibId=="libc++"` 抢占了 glibc),而 clang+libc++ 的三元组是 `*-linux-gnu`,
   libc 仍是 glibc → 把 glibc 的 C 库误判不兼容。检查随 0.0.54 引入,故 CI 旧 pin 0.0.46 不报、0.0.67 报。
   **修复**:mcpp **0.0.68**(#178)把 ABI 建成维度模型(libc / cxxstdlib 等正交,未声明即 don't-care);
   分析+设计见 mcpp 仓 `.agents/docs/2026-06-27-glfw-abi-glibc-vs-libcxx-conflation-analysis.md`、
   `2026-06-27-abi-compat-model-single-pr-design.md`。
   **回收**:本 PR 把 CI 升到 `0.0.68` 并将 GL window + imgui-module 两 smoke 从 nightly 移回阻塞 `smoke-full-linux`
   (本地 0.0.68 实测 `imgui-module-smoke` 在 llvm 下 `Dear ImGui 1.92.8 module package ok`)。

### 8.3 CI 选跑实测(PR #48)
detect 正确产出 `examples=["cjson","nlohmann.json"]`;`smoke-examples (cjson)`/`(nlohmann.json)`
两个 matrix job 在干净 runner + 0.0.67 全绿(独立复现 R1);`mirror-cn-reachable` 覆盖两条新 CN url(200);
gtest 修复后 `smoke-macos`/`smoke-windows`/full-linux(core/imgui/archive)在 0.0.67 全绿。
