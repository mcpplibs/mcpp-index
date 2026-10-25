# 新增 compat.soci 收录(SOCI 4.1.4,C++ 源码 compat + 编入的 sqlite3 后端)

## 1. 来源与形态

- 收录 [SOCI/soci](https://github.com/SOCI/soci) **4.1.4**,为当前最新 tag(`git ls-remote --tags`
  里 `v4.1.4` 最大;注意 4.1.0 从未打 tag,该线自 `v4.1.1` 起连续),不在最新 tag 里挑旧线。
- 归档 `https://github.com/SOCI/soci/archive/refs/tags/v4.1.4.tar.gz`,**两次下载字节一致**,
  SHA-256 `144f017cccc2e2d806badb3313d6ab3c67a1925bccaa747a46fb3907108a615d`。解包顶层
  `soci-4.1.4/`。
- License **BSL-1.0**(`LICENSE_1_0.txt` = Boost Software License 1.0)。
- 布局:`include/soci/`(公开头,含每个后端一份 `soci/<backend>/soci-<backend>.h`)、
  `include/private/`(core 用裸名包含的私有头,如 `soci-case.h`)、`src/core/`(22 个 TU)、
  `src/backends/{sqlite3,mysql,odbc,postgresql,oracle,db2,firebird,empty}/`、
  `3rdparty/{sqlite3,fmt}`(**git submodule,归档内为空目录**)。
- 形态判定:**A(C++ 源码 compat)**。上游是 CMake 工程;本包把 `src/core/*.cpp`(22 TU,
  与 `add_library(soci_core …)` 列表逐项一致)与 `src/backends/sqlite3/*.cpp`(10 TU,与
  `soci_define_backend_target(... SOURCE_FILES ...)` 一致)编成**单一 lib 目标** `soci`。
  上游拆成 `soci_core` + `soci_sqlite3` 两个库,但 mcpp 的 `sources` 是每包一张表,且没有后端的
  core 连 `session` 都开不了 —— 拆开对消费者没有价值。
- 两个目录下**同名 TU 成对存在**(blob / error / session / statement),不构成冲突:mcpp 把
  wrap 内相对路径镜像进对象路径(`obj/compat_soci/soci-4.1.4/src/core/statement.o` 与
  `…/src/backends/sqlite3/statement.o`),已从本仓既有 `compat.sdl3` 的 `compile_commands.json`
  确认该布局,并在本地以同形路径分别编译过。
- 上游要求 C++14(`soci-platform.h` 有 `#if __cplusplus < 201402L #error`);本包按仓内惯例以
  **c++23** 编译,全 32 个 TU 在 clang 23.1.3 / MSVC ABI 下实测无警告级问题。

## 2. 依赖:三处上游"没有,必须补"

| 上游要什么 | 上游怎么给 | 本包怎么补 |
|---|---|---|
| sqlite3 客户端库 | `3rdparty/sqlite3` **子模块**(归档里没有) | `deps` 依赖边 → `compat.sqlite3` 3.45.3(与 `compat.sqlitecpp` 同构;两个消费者因此共用一份 amalgamation) |
| fmt | 系统 fmt,找不到就用 `3rdparty/fmt` 子模块(同样为空)的 **header-only** 目标 | `deps` → `compat.fmt` 12.2.0(编译库形态) |
| Boost | `find_package(Boost)`,找到才定义 `SOCI_USE_BOOST` | **不做依赖**:不加该宏时全部源码不碰 Boost(公开头里的 `<boost/…>` 全在 `SOCI_USE_BOOST` 之下) |

**fmt 为什么必须是"普通形态",而且这是实测而非推断。** SOCI 4.1 起 core 与 sqlite3 后端共
12 个 TU 无条件 `#include <fmt/format.h>`。最初按"取 `fmtlib.fmt` 的头 + `FMT_HEADER_ONLY`
编进自己的 TU"实现,`mcpp test -p soci` 一路走到**链接**才失败:

```
lld-link: error: duplicate symbol: public: static unsigned int __cdecl
  fmt::v12::detail::dragonbox::cache_accessor<double>::compute_mul(...)
>>> defined at fmt-12.2.0/include/fmt/format-inl.h:1113
>>>            obj/fmtlib_fmt/mcpp_generated/fmt_module.m.o
>>> defined at obj/compat_soci/soci-4.1.4/src/core/values.o
```

模块对象的 COMDAT 键与 header-only 的不相撞,MSVC ABI 下就是重复符号 —— 即"模块 lib 与
header-only 消费方不能同链"。换成**编译库形态的 fmt**(`src/format.cc` + `src/os.cc`,即
`compat.fmt`)后无需任何 define,链接干净。这条也是 `pkgs/f/fmtlib.fmt.lua` 注释里那句
"the header-based `compat.fmt` package"其实早该存在的直接原因;本次先把 `compat.fmt` 落地
(独立提交),再让本包依赖它。

## 3. 描述符设计:三组 CMake PRIVATE 定义各自的落地方式

上游对 `soci_core` / `soci_sqlite3` 传了三组 PRIVATE 编译定义。mcpp 的 `cxxflags` 是**包私有**的
(只到本包 TU、不到编译 `soci.h` 的消费者 —— `compat.zlib` 的长注释里有实测记录),所以三组都不
存在外泄给消费者的问题;但它们**能不能穿过描述符**各不相同:

| 上游定义 | 为什么不能直写 | 本包做法 |
|---|---|---|
| `SOCI_SQLITE3_SOURCE` | 无引号,能直写 | `cxxflags` 里的普通 `-D`。**容易漏且一漏就全红**:`soci-sqlite3.h` 把 `#include <sqlite3.h>` 放在 `namespace sqlite_api` **内部**,且只在 `#ifdef SOCI_SQLITE3_SOURCE` 下才包含 —— 缺它时后端只剩两句前置声明,每个 `sqlite3_*` 调用都报 "use of undeclared identifier"。消费者走的恰是**不定义**的那条路(只含前置声明),所以这个宏必须止步于本包 |
| `SOCI_LIB_PREFIX` / `SOCI_LIB_SUFFIX` / `SOCI_DEBUG_POSTFIX` | **带引号的字符串宏**,引号穿不过 描述符 → mcpp → 编译器 argv 管道(`compat.unixodbc` 用 `LT_CONFIG_H` 撞过同一堵墙) | 强制包含的 shim 头 `mcpp_soci_defines.h`(`generated_files` + `cxxflags = {"-include", …}`),值按上游算法给(win `soci_*.dll` / mac `libsoci_*.dylib` / else `libsoci_*.so`,DEBUG_POSTFIX 空)。它们只用于给 dlopen 拼后端 DSO 名,而本包不产出任何后端 DSO —— 后端就编在同一个 lib 里 |
| `SOCI_HAVE_SQLITE3`(`soci-config.h`) | 这个头上游**不发布,是 CMake `file(GENERATE)` 出来的**,而 `soci/soci-platform.h` 无条件包含它 | `generated_files` 逐字节复刻 CMake 在"只开 sqlite3"时的输出(含其余七行被注释掉的 `/* #define SOCI_HAVE_* */`) |

其余两点:

- `include_dirs` 带 `*/include/private`:core 的 TU 以裸名包含私有头(`soci-case.h`、`soci-mutex.h` …),
  而 mcpp 没有"只给本包用"的 include 路径。消费者会看到该目录,但它惰性(私有头不自洽),
  这是不搬动上游头的代价。
- **CN 镜像**:无 `mcpp-res` 写权限,按 `docs/cn-mirror.md` 回退为**纯字符串 url**
  (`compat.nanodbc` / `compat.sqlite3` 同形);日后补镜像只需改写成 `{ GLOBAL, CN }`,sha256 不变。

## 4. Feature 评估:其余后端**不做** feature,理由是可依赖项不存在

SOCI 的可选组件就是"另外七个后端",且它们确实是"额外可编译源码"——教科书式的 sources-only
feature 候选。但仍然不做,原因是 feature 只能带**本包声明的 deps**,而这些后端的客户端库:

- `postgresql`(libpq)、`oracle`(OCI)、`db2`、`firebird`:**本索引里根本没有对应包**;
- `mysql`(`compat.libmysqlclient`)、`odbc`(`compat.unixodbc` / Windows SDK / macOS iODBC)虽有包,
  但 odbc 的驱动管理器**按平台来源完全不同**(linux 靠 `compat.unixodbc` 源码构建、windows/macOS 靠
  系统 SDK),而 feature 的 `deps` 没有平台门控 —— 声明了就会在另两个平台拉错东西。

所以本次只收"能真正交付"的那一个后端,并在描述符注释里写明:以后加后端是**一行 `sources` 加一行
`deps`**,不是重构。也没有把 core 单独做成 feature:没有后端的 core 连 `session` 都开不了,
门控它等于给消费者一个"编译得过、什么也干不了"的空挡。

## 5. 测试与验证

单成员 `tests/examples/soci`(`soci-tests`,依赖 `compat.soci = "4.1.4"`,按 `fmt`/`rapidcsv`
的写法重复单条 `[indices] compat = { path = "../../.." }` 并用限定写法请求)。测试选点围绕
"这个包独有的三处风险":

- `SOCI_VERSION == 400104` 与 `SOCI_LIB_VERSION == "4_1_4"` **精确断言**,证明编进来的头就是所 pin
  的那一版(与 `sqlite3` 成员断言 `sqlite3_libversion()` 同一手法)。
- `select sqlite_version()` 必须返回真实版本号 —— 只有 `compat.sqlite3` 的 amalgamation 被真正链接
  才可能(上游那份在归档里是空的子模块)。
- 后端以 `soci::sqlite3` **工厂对象**取得,而非 `session("sqlite3", …)`:后者会走 SOCI 的动态后端
  加载器去 dlopen 一个本包**故意不产出**的 `libsoci_sqlite3.so`。
- NULL 用 `soci::indicator` 断言(`i_null` vs `i_ok`),这条只有 core 与后端协同才成立;
  事务覆盖显式 `rollback()`、**出作用域未 commit 自动回滚**、以及 `commit()` 三条路径;
  错误路径断言 `sqlite3_soci_error` 的 `get_backend_name() == "sqlite3"`、后端错误码非 0、
  消息含表名,以及 `get_error_category() == constraint_violation`(主键冲突那条)。

验证结论(本机 win32,`mcpp 2026.10.11.1`,工具链 `llvm@23.1.3` + MSVC 14.44.35207,
target `x86_64-pc-windows-msvc`):

- `mcpp xpkg parse pkgs/c/compat.soci.lua` → `parse OK`(2 sources / 3 include_dirs /
  2 generated / 1 target)。
- `mcpp test -p soci`(清掉成员 `target/`、`.mcpp/` 后的冷验证)→
  `soci_test ... ok (0.49s)` / `test result ok. 1 passed; 0 failed; finished in 23.52s
  (build 14.30s + run 0.49s)`。日志里 `Cached compat.sqlite3 v3.45.3 (index compat, 1 unit)`、
  `Cached compat.fmt v12.2.0 (index compat, 2 units)` —— 两个依赖都由**本 checkout 的 compat 索引**
  解析(`index compat`),不是远端已发布索引。
- 消费侧命令行的三条旁证(取自本次构建重新生成的仓根 `compile_commands.json`):
  1. **没有 `-DNDEBUG`** → 文件里那批 `assert` 是活的,不是空测试(结尾另有一条 `return count == 4 ? 0 : 1`
     作双保险);
  2. **没有 `-DSOCI_SQLITE3_SOURCE`** → 包私有定义确实没外泄,消费者拿到的是"只含前置声明"的
     正确消费模式;
  3. `-I …/compat-x-fmt/12.2.0/fmt-12.2.0/include` 与 `-I …/compat-x-sqlite3/3.45.3/sqlite-amalgamation-3450300`
     都在消费侧命令行上 → 依赖接口(`compat.fmt` 的头、`compat.sqlite3` 的头)按预期传播。
- 版本差异说明:CI pin 为 **2026.10.1.2**,本机为 **2026.10.11.1**(win32 主机跑不了 pinned 的
  linux 二进制)。本地结论只覆盖 windows 腿;linux/macOS 由 CI 裁决。
- 本机无 `lua5.4` 与 `bash` → `tests/check_*.lua` 与 `tests/run_members.sh` 无法本地复现,交 CI 的
  `lint` 与 `workspace` 覆盖。已按脚本逐条人工核对本描述符:纯字符串 url 免 `check_mirror_urls`
  的表校验(`type(u) == "string"` 直接 return)、`name = "soci"` 为单一原子段、`namespace = "compat"`
  非保留首段、三平台版本键齐平(仅 `4.1.4`)、无重复版本键、无 `install()` 跨包引用。

## 6. 注意事项

- 根 `mcpp.toml` 本次只动 `[workspace].members`(加一行 `tests/examples/soci`)。**没有**顺带把根
  `[indices]` 改写成 `[workspace.indices]`(同 `compat.fmt` 那一份的理由:新写法要求
  mcpp ≥ 2026.10.10.1,而 `index.toml` 的 `min_mcpp` 与 CI pin 都要一起抬)。
- 后端以工厂对象取得这件事**必须写进给用户的说明**里:`session("sqlite3", …)` 在静态编入后端时
  会去 dlopen 不存在的 DSO。描述符注释与测试注释都点明了。
- 动态加载路径虽然惰性(本包不产出后端 DSO),但 `backend-loader.cpp` 仍会被编译并链接 dlfcn;
  linux 上由 libc 提供 `dlopen`(glibc ≥ 2.34 已并入 libc),本包**未**声明 `-ldl` —— CI 的 linux 腿
  会裁决这一点。
- 合并后 `publish-artifact.yml` 自动重发索引 artifact;CN 镜像补传是独立动作。
- 后续可做(不在本 PR 范围):`compat.fmt` 若被重切成 header-only,本包需同步加回
  `-DFMT_HEADER_ONLY=1`(描述符注释里已写明);新增其它后端时记得它们的客户端库得先有索引包。
