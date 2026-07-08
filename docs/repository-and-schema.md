# 仓库结构、schema、CI 与关键文件

## 仓库布局

```
pkgs/<x>/<name>.lua          描述符。<x> 取完整包名首字母(compat.* → c,nlohmann.json → n,imgui → i)
tests/examples/<short>/      每库最小工程(<short> 为包名去除 compat./mcpplibs. 前缀后的结果)
  mcpp.toml                  [indices].compat = { path = "../../.." }
  src/main.{cpp,c}
tests/run_example.sh <short> 通用 runner:rm -rf target .mcpp,继而 mcpp build 与 mcpp run
tests/smoke_compat_*.sh      旧全量 smoke,已降级为 nightly/dispatch 保障
tests/check_mirror_urls.lua  lint:GLOBAL+CN 表完整性,以及 CN 指向 mcpp-res
tests/list_cn_urls.lua       抽取 CN url,供 mirror-cn-reachable 使用
README.md                    索引说明与贡献入口
.github/workflows/validate.yml   CI:lint / mirror-cn-reachable / detect / smoke-examples / smoke-full-linux / smoke-portable
.agents/docs/<date>-*.md     设计文档惯例
docs/                        贡献者参考文档(本目录)
tools/gtc                    gitcode CLI,见 cn-mirror.md
.xpkgindex.json              站点配置(标题、链接、install 模板),通常无需改动
```

## 外部仓库与文档

- mcpp 本体:https://github.com/mcpp-community/mcpp(本地通常存在 clone:
  `/home/speak/workspace/github/mcpp-community/mcpp`)。`mcpp --version` 应与 CI 对齐;feature 与 glob 行为以
  `src/manifest.cppm`、`src/modgraph/scanner.cppm`、`src/build/prepare.cppm` 为准。
- xpkg 扩展 schema(权威):
  https://github.com/mcpp-community/mcpp/blob/main/docs/04-schema-xpkg-extension.md(对应本仓 `.xpkgindex.json` 的
  “mcpp ext” 链接)。V1 xpkg spec 见 `d2learn/xim-pkgindex` 的 `docs/V1/xpackage-spec.md`(url-template 约在第 172 行)。
- CN 镜像组织:gitcode `mcpp-res`。

## 描述符 schema 速查(Form B inline)

`package` 必填字段:`spec`、`namespace`、`name`、`description`、`licenses`、`repo`、`type="package"`、`xpm`、`mcpp`。

`xpm.<linux|macosx|windows>.<裸版本>`:

- `url`:字符串,或 `{ GLOBAL=…, CN=… }` 表(本仓统一使用表形式)。
- `sha256`:必填,等于实际下载字节的摘要。

`mcpp`(常用键):

| 键 | 说明 |
|---|---|
| `language` | 通常为 `"c++23"` |
| `import_std` | 多数为 `false` |
| `c_standard` | C 源码:`"c99"` 或 `"c11"` |
| `modules` | module 库:`{ "x.y" }` |
| `include_dirs` | glob 列表,暴露给消费者的头目录 |
| `generated_files` | `{ ["相对路径"]="内容字符串" }`;mcpp ≥ 0.0.85 支持 Lua 长括号 `[==[…]==]` 多行字符串(推荐,可读可 review);转义单行串仍兼容 |
| `scan_overrides` | `{ ["glob"]={ provides={…}, imports={…} } }`;声明式扫描结果,命中文件跳过 M1 文本扫描(适用于带条件 import 守卫的上游模块单元,如 fmt 的 src/fmt.cc);构建期由编译器 P1689 输出自动对账,声明错误响亮失败(mcpp ≥ 0.0.85)|
| `sources` | glob 列表,编入 lib 的源码 |
| `cflags` / `cxxflags` / `ldflags` | 追加至对应规则 |
| `targets` | `{ ["name"]={ kind="lib"/"bin", main=…, soname=… } }` |
| `features` | `{ ["f"]={ sources={…} } }`,仅识别 sources |
| `deps` | `{ ["ns.name"]="ver" }`,扁平或点号式 |

## index 版本契约(index.toml)

仓库根的 `index.toml` 声明 `[index] min_mcpp` —— 能解析本索引全部描述符的最老
mcpp 版本。契约随树旅行:`publish_mcpp_index.sh` 把它打进 artifact,git clone 与
`[indices] path =` 本地索引天然携带。mcpp ≥ 0.0.85 在打开索引树时检查,违反时报
`E0006` + 升级指引(调试逃生口 `MCPP_INDEX_FLOOR=ignore`)。

规则(由 lint 机械强制,非纪律):**floor 先行、新文法在后**——lint 用 CI pin 的
mcpp 跑 `xpkg parse`(strict:未知键即失败),所以需要更新文法/键的描述符在
`MCPP_VERSION` 与 `min_mcpp` 同步提升之前物理上合不进 main。本地复现:
`mcpp xpkg parse pkgs/<x>/<name>.lua`。

## CI 行为(validate.yml)

- 触发条件:PR(改动 `pkgs/**/*.lua`、`tests/**`、`README.md` 或本 workflow)、push 至 main、nightly cron、手动触发。
- `env.MCPP_VERSION` 为全部 job 使用的 mcpp 版本,本地验证应与之对齐。
- `lint`(始终运行):lua 语法 `loadfile(f,'t')`;须含 `spec=`/`name=`/`xpm=`;禁止前导 v 版本;执行
  `check_mirror_urls.lua`。
- `mirror-cn-reachable`(始终运行):逐个 `curl` CN url,均须返回 200。
- `detect`:PR 时由 `git diff` 取改动的 `pkgs/*/*.lua`,对 basename 去除 `compat.`,若存在
  `tests/examples/<short>/` 则仅运行该示例;改动 scaffolding/CI 或无对应 example 时,执行全量回归。
- `smoke-examples (<short>)`:在干净 runner 上运行 `run_example.sh`,`MCPP_INDEX_MIRROR=GLOBAL`。
- `smoke-full-linux` 与 `smoke-portable`(mac/win):全量回归,仅在 push、nightly、dispatch 或脚手架变更时运行;
  常规单库 PR 应显示 `skipping`。

## 本地 lint 复现(等价于 CI lint job)

```bash
fail=0
for f in pkgs/*/*.lua; do
  lua5.4 -e "assert(loadfile('$f','t'))" >/dev/null 2>&1 || { echo "SYNTAX $f"; fail=1; }
  for n in 'spec *=' 'name *=' 'xpm *='; do grep -q "$n" "$f" || { echo "MISS $n $f"; fail=1; }; done
  grep -nqE '\["v[0-9]+|\["[^"]+"\][[:space:]]*=[[:space:]]*"v[0-9]+' "$f" && { echo "LEADING-V $f"; fail=1; }
  lua5.4 tests/check_mirror_urls.lua "$f" >/dev/null 2>&1 || { echo "MIRROR $f"; fail=1; }
done
[ $fail -eq 0 ] && echo "ALL LINT PASS"
```

## 合并后

`publish-artifact.yml` 在合并至 `main` 后自动重新发布 mcpp-index artifact 并移动指针,无需发布新的 mcpp 版本。
在线浏览地址:https://mcpplibs.github.io/mcpp-index/

## 案例索引

| 形态 | 描述符 | example | 设计文档 / PR |
|---|---|---|---|
| C 源码 + feature | `pkgs/c/compat.cjson.lua`、`compat.gtest.lua` | `tests/examples/cjson/` | `.agents/docs/2026-06-27-add-cjson-and-nlohmann-json-plan.md` / #48 |
| C++23 module(generated wrapper) | `pkgs/n/nlohmann.json.lua` | `tests/examples/nlohmann.json/` | 同上 / #48 |
| header-only + source-gated feature | `pkgs/c/compat.eigen.lua` | `tests/examples/eigen/` | `.agents/docs/2026-06-28-add-eigen-plan.md` / #50 |
| header-only(纯头) | `pkgs/c/compat.opengl.lua`、`compat.khrplatform.lua` | — | `.agents/docs/2026-06-03-gl-runtime-packages-plan.md` |
