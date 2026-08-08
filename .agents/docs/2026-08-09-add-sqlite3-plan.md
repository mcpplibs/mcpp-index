# 新增 SQLite 收录(compat.sqlite3,C 源码 compat)

**日期**: 2026-08-09
**本仓**: `mcpplibs/mcpp-index`
**参考**: PR #48(cJSON compat)、#50(eigen);skill [`add-mcpp-index-package`](../skills/add-mcpp-index-package/SKILL.md)
**目标**: 收录 SQLite 引擎本体为 `compat.sqlite3`(C 源码 compat 形态),版本 **3.45.3**,用户
`#include <sqlite3.h>` 开箱即用;最小示例 `tests/examples/sqlite3/` 走完整冷验证。

---

## 1. 版本选择:3.45.3(部署最广,而非最新)

用户要求"选最广泛使用的版本,不追求最新"。调研结论:3.45.x 是当前部署面最广的版本线。

| 平台 | SQLite 版本 |
|---|---|
| Ubuntu 24.04 LTS(支持至 2029+) | 3.45.1(安全更新在 3.45.x 线内) |
| CPython 3.11 / 3.12 / 3.13 官方安装器 | 3.45.1 / 3.45.3 / 3.45.3 |
| Debian 13(trixie)/ Debian 12(bookworm) | 3.46.1 / 3.40.1(3.45 处于两者交集) |
| Android 15+ / iOS 18+ 时代生态 | 3.45+ 被普遍视为兼容基准 |

- **3.45.3** = 3.45.x 线最后一个维护版(含该线安全/稳定性修复),API 与 Ubuntu 24.04 LTS 的 3.45.1 一致,更成熟。
- 未选最新 3.53.4:新版本线部署面尚未铺开,收录后对消费侧无兼容收益。
- 后续可加新版本线:xpm 加行即可,mcpp 块不变。

## 2. 上游布局与哈希(已实测)

- GLOBAL:`https://sqlite.org/2024/sqlite-amalgamation-3450300.zip`(HEAD 200 已验证;3.45.1/3.45.2/3.45.3
  均存在,年路径为发布年)。
- sha256(两次计算一致):`ea170e73e447703e8359308ca2e4366a3ae0c4304a8665896f068c736781c651`。
- zip 单层 wrap `sqlite-amalgamation-3450300/`,内含 `sqlite3.c`(9.0 MB)、`shell.c`、`sqlite3.h`、
  `sqlite3ext.h`。glob `*` 吸收 wrap 层。
- 许可:Public Domain(SPDX 无标准 id,采用 `LicenseRef-Public-Domain` 惯例)。

## 3. 形态判定:形态 A(C 源码 compat),无 feature

- 只编 `sqlite3.c` 进 lib;`shell.c`(交互式 CLI)不编 —— 它依赖 editline/readline。
- `include_dirs = {"*"}` 暴露 `sqlite3.h` / `sqlite3ext.h`。
- amalgamation 开箱即编,无需任何 define/config;`c_standard = c11`(与 compat.cjson 对齐)。
- **无可门控组件**:amalgamation 是单一 TU,可选功能全部由编译期 define 控制(如
  `SQLITE_OMIT_*` / `SQLITE_ENABLE_*`),而当前 mcpp feature 表只能门控 sources、不能携带 define → 不实现
  feature(同 compat.eigen 对 define 类开关的结论)。
- **无 CN 镜像**:sqlite.org 是 amalgamation 的唯一权威来源(GitHub `sqlite/sqlite` 镜像仓**不含**生成的
  `sqlite3.c`,raw 404 实测);无 `mcpp-res` 写权限 → 采用纯字符串 url 回退(先例:compat.hiredis /
  compat.spdlog / compat.redis-plus-plus)。

## 4. 描述符与消费者示例

- `pkgs/c/compat.sqlite3.lua`:三平台同 url+sha;`sources = {"*/sqlite3.c"}`;target `sqlite3`(kind lib)。
- `tests/examples/sqlite3/`:`mcpp.toml` 依赖 `compat.sqlite3 = "3.45.3"`;`tests/sqlite3_test.cpp` 断言
  `sqlite3_libversion() == "3.45.3"`,并走 `sqlite3_open(:memory:) → sqlite3_exec 建表/插入 → 预编译语句查询`
  全链路。
- 根 `mcpp.toml` `[workspace] members` 登记 `tests/examples/sqlite3`(CI 的成员选择与 `--all` 都读它)。

## 5. 本地验证(mcpp 2026.8.8.2,与 CI 同版)

- 环境:`MCPP`/`MCPP_HOME`/`MCPP_VENDORED_XLINGS` 指向 `mcpp-2026.8.8.2-macosx-arm64` 解包根,
  `MCPP_INDEX_MIRROR=GLOBAL`;`~/.mcpp/registry` 复制 release 自带 registry。
- 结果(`$MCPP test -p sqlite3`,冷状态,自动装 llvm@20.1.7 工具链):
  `sqlite3_test ... ok (0.27s)` / `test result ok. 1 passed; 0 failed; finished in 104.29s`。
- 包从 sqlite.org 下载、`sqlite3.c` 编译、链接、运行断言全部通过。

## 6. lint(复现 validate.yml)

- lua 语法 `loadfile(...,'t')` OK;`spec/name/xpm` 必填字段齐全;无前导 v。
- `check_mirror_urls.lua` OK(纯字符串 url 不施加镜像约束)。
- `check_package_name.lua` OK;全仓 `check_cross_package_refs.lua` OK。

## 7. 后续可选项(不在本 PR 范围)

- **C++ 封装层**(SQLiteCpp / sqlite_orm):用户已评估 —— 非必要,引擎先行;若后续做,sqlite_orm 为
  header-only 且提供 MIT 双许可,适合独立 PR。
- **CN 镜像**:获得 `mcpp-res` 写权限后,可将 url 改写为 `{ GLOBAL=…, CN=… }` 表(sha256 不变)。
- **新版本线**:3.46+/3.50+/3.53+ 作为新 xpm 行追加。

## 8. 多版本支持方案(后续可实施,难度低)

SQLite amalgamation 布局几十年来恒定(每版均为 `sqlite3.c` / `sqlite3.h` / `sqlite3ext.h` / `shell.c`,
同一个 wrap 层),因此**一个 `mcpp` 块通吃所有版本**:`sources` / `include_dirs` / `c_standard` 不变,
加版本 = 三平台各加一行 `xpm` 条目。对比本仓难例(`compat.catch2` v2/v3 形态切换、`compat.redis-plus-plus`
subset/superset 源码并集),SQLite 属最简单一档。

### 8.1 URL 数字编码与年路径(唯一需要小心的点)

版本号 → 数字编码 = 大版本 1 位 + 次版本 2 位 + 补丁 2 位;URL 带**发布年**路径。已实测:

| 版本 | URL | 备注 |
|---|---|---|
| 3.45.3 | `https://sqlite.org/2024/sqlite-amalgamation-3450300.zip` | 本 PR 收录 |
| 3.46.1 | `https://sqlite.org/2024/sqlite-amalgamation-3460100.zip` | 3.46 → `34601` |
| 3.50.0 | `https://sqlite.org/2025/sqlite-amalgamation-3500000.zip` | 3.50 → `35000`,勿写成 `350` |
| 3.53.4 | `https://sqlite.org/2026/sqlite-amalgamation-3530400.zip` | 年路径随发布年变 |

### 8.2 加一版的操作步骤

1. 下载对应 zip,`tar -tzf` 确认布局仍为四件套(应无变化)。
2. `sha256sum` 计算两次确认稳定。
3. 描述符三平台各加一个 `["x.y.z"] = { url=…, sha256=… }` 行(mcpp 块不动)。
4. 新成员 `tests/examples/sqlite3-<ver>/`(或复用既有成员改 pin)做冷验证。

### 8.3 测试与 CI 覆盖策略

- **每版本一个成员、断言各自 pin 的版本**(先例:`tests/examples/redis-plus-plus` 与
  `redis-plus-plus-v133` 各 pin 一版),不放松 `sqlite3_libversion()` 断言 —— 否则「解析到的确为所 pin
  版本」的证明被削弱。
- CI 成员选择规则为「描述符变更 → 选中所有 mcpp.toml 引用 `sqlite3` 的成员」,故新增第二成员后,改描述符
  时两个版本都会被 CI 覆盖。
- SQLite API 纯增量、文件格式兼容,同一行为测试跨版本通常直接通过;各成员的意义在于证明该版本
  编译+链接+行为均正常。

### 8.4 何时加

- 用户侧出现对更新版本线的需求(如新 feature / 新文件格式扩展)时按上述步骤追加;
- 加 CN 镜像(获得 `mcpp-res` 写权限)与加新版本相互独立,互不阻塞。
