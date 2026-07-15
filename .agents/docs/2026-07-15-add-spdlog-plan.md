# 收录 spdlog 1.17.0 —— 形态判定、双模态与验证结论

日期:2026-07-15。对应描述符 `pkgs/c/compat.spdlog.lua`、示例 `tests/examples/spdlog/`。
CI 版本 mcpp 0.0.91,index floor `min_mcpp = 0.0.87`。

## 1. 来源与形态

- 来源:(a) 第三方上游库 —— spdlog(https://github.com/gabime/spdlog)上游不提供
  mcpp 支持,由本仓以 `compat` 形态适配。
- 最新 tag:`v1.17.0`(`git ls-remote --tags` 排序确认)。裸版本 `1.17.0`,
  下载 URL 保留上游 `.../v1.17.0.tar.gz` 拼写。
- License:MIT。
- sha256:`d8862955c6d74e5846b3f580b1605d2428b11d97a410d86e2fb13e857cd3a744`
  (下载后重复计算两次,稳定)。
- 源码布局:`include/spdlog/**`(全部头文件,含 `-inl.h` 实现单元与
  `fmt/bundled/` 内联版 {fmt})、`src/*.cpp`(7 个预编译库 TU)。
- 形态判定:**header-only + source-gated feature**,与 `compat.eigen` 同类。
  spdlog 是 DUAL-MODAL:
  - 默认(不定义宏)走 header-only:`common.h` 在未定义 `SPDLOG_COMPILED_LIB`
    时打开 `SPDLOG_HEADER_ONLY`,头文件末尾 `#include "*-inl.h"` 把实现内联。
    bundled fmt 以 `FMT_HEADER_ONLY` 使用,**整包自包含,无需外部 fmt 依赖**。
  - 预编译模态(定义 `SPDLOG_COMPILED_LIB`)改为编译 `src/*.cpp`;每个 src TU
    在缺少该宏时 `#error`。该宏是 **interface define**:必须同时到达库源与
    消费者头(否则消费者头走 inline,与 .a 符号重复/冲突)。

## 2. 描述符设计

header-only 骨架(`include_dirs = {"*/include"}` + anchor TU 提供可构建 lib
target),外加一个声明式 `compiled` feature:

```lua
features = {
    ["compiled"] = {
        sources = { "*/src/*.cpp" },
        defines = { "SPDLOG_COMPILED_LIB" },
    },
}
```

## 3. 关键实证:feature sources 在 `mcpp test` 下不编译(mcpp ≤0.0.93 的 bug,0.0.94 已修)

> **修订(2026-07-15)**:本节初版结论「mcpp 0.0.91 引擎不编译 feature 门控的
> sources」**是误判**,已由 mcpp#218 查清并修复。误判的成因值得记下来。

初版三重佐证如下:

| 实验 | feature | 现象 |
|---|---|---|
| spdlog | `compiled` | `src/*.cpp` 未编译 → 大量 `undefined reference` |
| compat.cjson | `utils` | `cJSON_Utils.c` 未编译 → `undefined reference to cJSONUtils_*` |
| compat.eigen | `eigen_blas` | `blas/*.cpp` 未编译 → `undefined reference to dgemm_` |

三例现象属实,但**三次都只走了 `mcpp test` 这一条路径**(本仓 CI 是 workspace/test
模型),于是把一个**只影响 test 模式**的 bug 误读成了「引擎不支持 feature sources」。

**真因**(`mcpp/src/build/prepare.cppm`):feature 源集解析(drop + add)**整段**被门在
`!includeDevDeps`,而 `mcpp test` 走 `includeDevDeps = true` → 激活 feature 的 sources
从不被加回构建图。叠加 xpkg 侧 `features.X.sources` 只落进 `featureSources`、**从不进
base `sources`** —— 于是「只在 features 下声明」的包:

| 路径 | 结果 |
|---|---|
| `mcpp build` | ✅ **一直是好的**,7 个 src TU 全进 build.ninja,二进制真跑 |
| `mcpp test` | ❌ `undefined reference` |

那段门的注释假设「descriptor 会把 `gtest_main.cc` 同时留在 base sources 里,故 test
模式不受影响」——**只对 gtest 成立**,是未被察觉的隐式耦合。`compat.eigen` 里
"linking feature-built dependency objects into test binaries is a follow-up" 的定性
同样是错的:**不是链接问题,是源集解析问题**。

**修复**:mcpp 0.0.94(#218)—— drop 仍只在 build 模式做(test 模式需保留完整源面供
dev-dep 轨 per-test main 检测剪枝),add 改为两模式都做 + 去重。

**采用方案**:描述符的 `compiled` feature 声明**本来就是对的,一行未改**;只把注释从
「引擎不支持」改为如实的「`mcpp test` 下需 ≥0.0.94」。CI pin 提到 0.0.94 后,
**两个模态都进 CI 断言**(`tests/examples/spdlog/` header-only +
`tests/examples/spdlog-compiled/` compiled)。

**教训**:诊断 feature 相关问题**必须 `build` / `test` 两条路径对比**,只测一条会把
路径 bug 误判成引擎能力缺失。

## 4. feature 评估:为何不为 tweakme 开关新增 feature

spdlog 的 `tweakme.h` 有大量编译期开关(`SPDLOG_USE_STD_FORMAT`、
`SPDLOG_NO_SOURCE_LOC`、`SPDLOG_CLOCK_COARSE`、`SPDLOG_ACTIVE_LEVEL=...` 等)。
经确认(mcpp `05-mcpp-toml.md`),消费者可在**自己的** `mcpp.toml` 直接注入,
无需包侧声明 feature:

```toml
[targets.my-app]
defines  = ["SPDLOG_USE_STD_FORMAT"]   # per-target,-D 随本 TU 编译
# 或 [build] cxxflags = ["-DSPDLOG_NO_SOURCE_LOC"]  # 整工程
```

作用域陷阱(官方明示):`defines`/`cxxflags` **只作用于该 target 自己的 entry,
不传播到共享/依赖代码**。对 spdlog:

- header-only 模态下 spdlog 全在头文件里,随消费者 TU 编译,消费者 `-D` 天然覆盖
  → 所有 tweakme 开关消费者自助即可,做成 feature 是冗余(且不如消费侧灵活,
  消费侧还能带值,如 `SPDLOG_ACTIVE_LEVEL=SPDLOG_LEVEL_INFO`)。
- 唯一"消费者 `-D` 够不着、必须包侧统一注入"的是 `SPDLOG_COMPILED_LIB`
  (要同时影响库源与消费者)——已由 `compiled` feature 承载(受 §3 限制)。

因此**不新增 tweakme feature**,避免过度设计。

## 5. CN 镜像:纯字符串回退

本环境无 gitcode token(`~/.config/gitcode-tool/config.json` 不存在,
`GITCODE_TOKEN` 未设),无法在 `mcpp-res` 上传资产。探查发现 `mcpp-res/spdlog`
仓库页面已存在(200)但为空壳(release 资产 403)。

按 `docs/cn-mirror.md` 回退方案:三平台 `url` 采用**纯字符串**(仅上游 GitHub
release),lint(`check_mirror_urls.lua`)对纯字符串 url 不施加镜像约束,
`mirror-cn-reachable` 也不会抽取到需 curl 的 CN url。CN 用户回退至上游源。
先例:`pkgs/t/tensorvia-cpu.lua`。后续获得权限或维护者补充镜像后,可将各
`url` 改写为 `{ GLOBAL, CN }` 表(sha256 不变)。

lint 只允许 `gitcode.com/mcpp-res/` 下的 CN url(信任边界 + 字节一致),任何
第三方域名在表形式下都过不了 lint,故无"其他可用 CN 镜像"。

## 6. 验证结论(mcpp 0.0.94,GLOBAL)

**两个模态都已 CI 断言**:

- `mcpp test -p spdlog` → header-only 默认模态,`test result ok. 1 passed`。
- `mcpp test -p spdlog-compiled` → compiled 模态,`test result ok. 1 passed`。
  `tests/examples/spdlog-compiled/tests/compiled_test.cpp` 静态断言
  `SPDLOG_COMPILED_LIB` 已定义且 `SPDLOG_HEADER_ONLY` 未定义(退化回 inline 路径
  会是**编译错误**而非静默通过),再跑与 header-only 同款的行为断言 —— 这些调用
  解析到 `default_logger_raw` / `log_msg` ctor / `logger::log_it_` / bundled fmt
  `vformat` 等**非 inline 符号**,正是 feature sources 没编译时链不上的那批。

以下为初版(0.0.91)记录,保留作历史:

- `mcpp xpkg parse pkgs/c/compat.spdlog.lua` → `parse OK`(strict floor/grammar)。
- workspace 成员 `mcpp test -p spdlog` → `test result ok. 1 passed`。
  示例 `tests/examples/spdlog/tests/log_test.cpp` 用 ostream sink 捕获日志,
  断言 `logger.info("hello {}={}", "answer", 42)` 与 `{:#x}` 的格式化输出
  (走 bundled fmt 头内联),`return ok ? 0 : 1`。
- 负向语义:header-only 默认构建 `build.ninja` 仅 `spdlog_anchor.o`
  (证明 src 未被默认编入);compiled 请求时消费者带 `-DSPDLOG_COMPILED_LIB`
  (证明 define 门控生效)。
- 本地 lint(等价 CI lint job)全量 `ALL LINT PASS`;spdlog 镜像 lint 单独 OK。

## 7. 落点与注意事项

- 描述符落点 `pkgs/c/compat.spdlog.lua`——目录取**完整包名首字母**
  (`compat.spdlog` → `c`,非短名 `s`)。初次误置 `pkgs/s/` 导致
  `not found in local index`,移至 `pkgs/c/` 后解决。
- 示例已登记进根 `mcpp.toml` 的 `[workspace].members`(否则
  `mcpp test --workspace` 不会跑到)。
- CI 已由早期 `detect`+`run_example.sh` 重构为 workspace 模式
  (`mcpp test --workspace`),示例采用 `tests/*.cpp` + 断言布局,而非
  `src/main.cpp`。
