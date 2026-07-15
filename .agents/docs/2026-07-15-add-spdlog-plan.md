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

## 3. 关键实证:mcpp 0.0.91 不编译 feature 门控的 sources

投入前用 mcpp 0.0.91(与 CI 对齐)实测,发现一个**引擎级限制**,并三重佐证:

| 实验 | feature | 现象 |
|---|---|---|
| spdlog(独立工程) | `compiled` | `src/*.cpp` 未编译 → 大量 `undefined reference` |
| compat.cjson(独立工程) | `utils` | `cJSON_Utils.c` 未编译 → `undefined reference to cJSONUtils_*` |
| compat.eigen(workspace 示例) | `eigen_blas` | `blas/*.cpp` 未编译 → `undefined reference to dgemm_` |

三例的 `build.ninja` 均只含核心 sources/anchor 的 `.o`,feature 的 sources
一个都没进构建。

**结论**:mcpp 0.0.91 中,依赖包被激活 feature 的 `sources` **不会被编译链接**;
只有包的顶层 `sources` 与 feature 的 `defines` 生效。这正是 `compat.eigen` 的
`dense.cpp` 注释所记的 follow-up——"linking feature-built dependency objects
into test binaries is a follow-up"。

**已验证生效的部分**:feature 的 `defines` 确实作为 interface define 传播到消费者
——`features=["compiled"]` 时消费者 TU 的编译行带上了 `-DSPDLOG_COMPILED_LIB`
(`build.ninja` 实证)。所以 spdlog `compiled` 今天的表现是:宏到达消费者,但
`src/*.cpp` 未编译,非 inline 符号无法链接。

**采用方案(与 eigen_blas 对齐)**:描述符保留 `compiled` feature 声明正确意图,
注释如实标注引擎限制;待 mcpp 支持"编译并链接 feature sources"后无需改描述符即可
生效。CI 只断言 header-only 模态。

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

## 6. 验证结论(mcpp 0.0.91,GLOBAL)

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
