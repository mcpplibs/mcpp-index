# 收录 [Boost::ext].UT(boost-ext.ut)2.3.1

> 日期:2026-08-02(2026-08-03 依 CI 与本地实测结论重写)
> 分支:`add-boost-ext-ut` / PR #142
> 仓库:[boost-ext/ut](https://github.com/boost-ext/ut)
> 背景:把 boost-ext 组织(**不是** boost 官方)的 UT 单头测试框架收录进 mcpp-index。
> 上游自带模块单元 `include/boost/ut.cppm`,宣告 `export module boost.ut;`。

## 1. 来源与形态判定

- 来源:**(a) 第三方上游库**。上游不提供 mcpp 支持,但 release tarball **自带**官方模块单元。
- 版本:`v2.3.1`(截至 2026-08-02 的最新 release tag)。
- License:Boost Software License 1.0,SPDX `BSL-1.0`。
- 布局:tarball 顶层 wrap 目录 `ut-2.3.1/`,模块单元 `include/boost/ut.cppm`,
  头文件 `include/boost/ut.hpp`(3378 行,`namespace boost::inline ext::ut::inline v2_3_1`)。
- 形态:**C++23 module(generated wrapper)**,与 `nlohmann.json` / `marzer.tomlplusplus` 同类。
  但与它们不同的是,本包的 wrapper 是上游 cppm 的**逐字复制**,只加一处 shim(见 §2)。

身份:`namespace = "boost-ext"`、`name = "ut"`。**不是** `boost`、**不是** `compat` ——
该项目并非 boost 官方库,不应占用 `compat` 习惯位置,也不应进 boost 命名空间。
mcpp 命名空间用 `-` 分层,避免与 `<ns>.<short>` 点号寻址约定碰撞。

## 2. 唯一的偏离:Clang-on-MSVC 的 `__argc` / `__argv`

`generated_files` 内嵌的 cppm 在上游 v2.3.1 `ut.cppm` 之上**只加一处**,不删任何一行,
连 `export import std;` 都原样保留:

```
ut.hpp:688:29: error: use of undeclared identifier '__argc'; did you mean 'largc'?
ut.hpp:689:63: error: use of undeclared identifier '__argv'; did you mean 'largv'?
```

`ut.hpp:687` 是 `#if defined(_MSC_VER)`,引用 MSVC 内建 `__argc` / `__argv`。
Clang 在 MSVC ABI 上设了 `_MSC_VER` 但不提供这两个内建 —— 上游相邻分支(行 291 / 311 / 1147)
已用 `&& !defined(__clang__)` 排除 clang,行 687 漏了同一守卫。属上游的 clang-on-windows 适配缺口。

这一条对本仓是必需的,因为本索引的 **Windows 默认工具链就是 LLVM/Clang + MSVC ABI**
(`.agents/docs/2026-07-19-full-platform-support-plan.md`:`llvm@20.1.7`,NOT mingw,NOT cl.exe),
CI 日志里也是 `Resolved llvm@20.1.7 → …/clang++.exe`。shim 用 `_MSC_VER && __clang__` 双重门控,
真 MSVC 永远不进入;`cfg::largc` / `cfg::largv` 在运行期由 `main()` 的 argv 重新赋值,替身值不会被读。

## 3. 曾经走过的弯路(留档,避免重走)

PR #142 的前 22 个 commit 里做过三处后来被**证伪并回退**的改动。记在这里,是因为它们的
"理由"看上去都很有说服力:

### 3.1 删 `export import std;` + 手写 24 个 GMF `#include`

**动机**:macOS 上 verbatim 模块在静态初始化期 SIGSEGV,lldb 停在 `ut.hpp:1620` 的
`std::cout.rdbuf()`,address `-0x18` 说明 `std::cout` 的 vptr 为零。当时判断是
`export import std;` 让模块持有自己那份 std 流实体,与 libc++ 库里的那份 ODR 分裂。

**证伪**:commit `3eff289`(已删 `export import std;`)在 mcpp 0.0.109 上,macOS 仍然
`ut ... FAIL (exit 139)`。后续的 `ios_base::Init` 强制构造(`fbf1ad0`)同样失败。
macOS 唯一转绿的变更是把 mcpp pin 提到 2026.8.3.1。

**真因**:mcpp-community/mcpp#336 —— Mach-O 没有按优先级排序的初始化段,libc++ 的
`<iostream>` 也不像 libstdc++ / MSVC STL 那样自带 `ios_base::Init` 守卫,于是归档成员的
初始化器跑到时流还是全零。**包侧无法修复**:`std::ios_base::Init` 在 libc++ 的 `<ios>` 里
只有前向声明。mcpp 2026.8.3.1 起生成一个极小 C 翻译单元排在链接行最前,由它先把流顶起来。

**副作用**:删掉 `export import std;` 之后,GCC 会爆出一连串 `-Wtemplate-body` 错误
(无修饰 `size_t`、`std::empty`、literal using 块),于是又被迫补 `using std::size_t;`
和 `cxxflags = { "-Wno-template-body" }`。**这些全部是自造的问题** —— 保留上游原样就没有。
本地实测(mcpp 2026.8.3.3 **与** 0.0.109,linux / gcc 16.1.0,冷跑):上游 cppm 逐字、
不加任何 `cxxflags`,`mcpp test -p boost-ext.ut` 通过,编译行里确认没有 `-Wno-template-body`。

### 3.2 追加上游 `master` 的显式模板实例化块

**动机**:当作 macOS SIGSEGV 的修复引进。

**证伪**:它在 `61b9441` 就已就位,macOS 仍 exit 139。它是上游为某个 Clang module linkage
gap 加的,且**不在任何 release tag 里**。既然不解决本仓遇到的问题,就不进信任路径。

### 3.3 `.github/workflows/diag-ut-macos.yml`

排 macOS 崩溃时的一次性诊断 workflow(lldb 反汇编 / `__init_offsets` 符号化 / relink 矩阵),
`on: push: branches: [add-boost-ext-ut]`。问题定位后已删除。

## 4. mcpp pin 与 index.toml floor

`MCPP_VERSION` 从 `0.0.109` 提到 `2026.8.3.3`,`index.toml` 的 `min_mcpp` / `latest_mcpp` 同步。

- 提 pin 是**必需**的:macOS 的崩溃修在 mcpp 侧(§3.1),包侧无解。
- floor 同步跟随 pin 是本仓一贯做法(见 #125 把 0.0.108 → 0.0.109)。这里尤其应该同步:
  低于 floor 的 macOS 消费者装上本包会**直接段错误且无任何诊断**,比 E0006 更糟。
- 取 `.3.3` 而非 `.3.1`:`.3.2` / `.3.3` 只有交叉编译相关修复(PE 产物命名、`-static`
  按主机而非目标判定),本 CI 矩阵不走那些路径,取最新一档零成本。

## 5. CI:`MCPP_BUILD_CACHE: local`

mcpp >= 2026.7.30.2 引入了全局包构建缓存。它在本仓的全量 workspace 下有 bug,
必须先绕开(已上报 **mcpp-community/mcpp#344**):

- mcpp#233 的 obj 路径消歧按**整个 build dir 内的 basename 冲突**触发,也就是按
  **消费方拉了哪些包**触发;而 cache key 只覆盖依赖包自身(v2026.7.30.2 的设计明确
  "不含 root 的身份与 flags")。
- `tests/examples/archive` 同时拉 zlib 与 bzip2(两者都有 `compress.c`)→ 触发消歧,
  写进缓存的是 `obj/compat_zlib/zlib-1.3.2/compress.o`;而只拉 zlib 的消费者
  (`libpng` / `freetype` / `eui-neo*` / `sdl2` / `vulkan`)按同一个 key 去要平的
  `obj/compress.o` → `ninja: error: … missing and no known rule to make it`。
- 本地在 2026.8.3.3 上**双向对称复现**(谁第二个跑谁挂),`--cache local` /
  `MCPP_BUILD_CACHE=local` 可绕过,且 `local` 仍然缓存 std BMI(贵的那份),只跳过包条目。

mcpp#344 修好后删掉这个 env 即可。

## 6. feature 评估

**不实现 feature**。ut 为纯头文件 + 单个模块单元,无"额外的可编译源码"可门控。
其可选行为(`BOOST_UT_CONFIG_*`)均为编译期 **define**,而 `features` 表当前仅能门控 `sources`。
与 Eigen 的 `EIGEN_MPL2_ONLY`、toml++ 的 `TOML_EXCEPTIONS` 属同类限制。

## 7. CN 镜像

未配置。无 `mcpp-res` 写权限,lint 允许 plain-string `url`(`tests/check_mirror_urls.lua`
对字符串形式直接放行),CN 用户回退至上游源,镜像由维护者后续补充。

## 8. 测试工程与验证

`tests/examples/boost-ext.ut/`,已登记进根 `mcpp.toml` 的 `[workspace].members`(按字母序)。
成员级 `[indices] boost-ext = { path = "../../.." }` 恰好一条 —— 它**替换**而非合并根级继承的
`compat` 表,把项目级 index repo 保持在一个。

断言覆盖 UDL 语法(`"..."_test = []{}`)与函数语法(`test("...") = []{}`)两路,通过
`expect()` 判定。测试 `main()` 返回 0 是安全的:ut 的 `~runner()`(ut.hpp:2032)在
`fails_` 非零时 `std::exit(-1)`,静态析构期生效,所以断言失败会让 `mcpp test` 非零退出。

| 检查 | 结果 |
|---|---|
| tarball sha256 二次核对 | ✅ `e51bf187…ea9b1` |
| `tests/check_package_name.lua` | ✅ pass |
| `tests/check_mirror_urls.lua` | ✅ pass |
| `tests/check_cross_package_refs.lua` | ✅ pass |
| 前导 v 版本号 lint | ✅ `"2.3.1"` 裸版本 |
| `mcpp test -p boost-ext.ut`(linux / gcc 16.1.0 / mcpp 2026.8.3.3,冷跑) | ✅ `all tests passed (3 asserts in 2 tests)` |
| macOS / Windows | 由 PR #142 的 CI 判定 |

冷验证前均已 `rm -rf tests/examples/boost-ext.ut/{target,.mcpp,mcpp.lock,compile_commands.json}`,
自干净状态走完「拉 tarball → 编译 wrapper → 编译/链接测试 → 运行」完整管线。

## 9. 演进条件

一旦 ut 发出 >2.3.1 的 release,且其 ut.hpp 在 687 行补上 `&& !defined(__clang__)` 守卫,
`generated_files` 整块即可删除,`sources` 切回 `*/include/boost/ut.cppm` 直接用上游文件。
