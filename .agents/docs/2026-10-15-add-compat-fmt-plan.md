# 新增 compat.fmt 收录(header 形态,非模块)

## 1. 来源与形态

- 收录 [fmtlib/fmt](https://github.com/fmtlib/fmt) **12.2.0**,为当前最新 tag
  (`api.github.com/repos/fmtlib/fmt/tags` 首条;上游 tag 不带 release asset,release 页面也无归档附件)。
- 归档 `https://github.com/fmtlib/fmt/archive/refs/tags/12.2.0.tar.gz`,**两次下载字节一致**,
  SHA-256 `8b852bb5aa6e7d8564f9e81394055395dd1d1936d38dfd3a17792a02bebd7af0` —— 与仓内
  `pkgs/f/fmtlib.fmt.lua` 早已登记的散列**逐位相同**,互为印证。解包顶层为 `fmt-12.2.0/`。
- License **MIT**。
- 布局:`include/fmt/`(16 个头)、`src/{format.cc, os.cc, fmt.cc, fmt-c.cc}`。
- 本次与仓内已有 **`fmtlib.fmt`(模块形态)** 的分工:后者用 `generated_files` 重写上游的
  `src/fmt.cc`,让消费者写 `import fmt;`;本包收的是**同一个 release 的头文件形态**,消费者写
  `#include <fmt/format.h>` 并链接。两份描述符的注释互相指认(fmtlib.fmt 的头注释早就自称是
  「the module sibling of the header-based `compat.fmt` package」,而 `compat.fmt` 此前并不存在)。
  分成两个身份是有意的:想要 `#include` 的工程不该被塞一个自己从不 `import` 的模块 BMI。
- 形态判定:**编译库**(上游自带实现的非模块形态,不是纯头)。上游 CMake 的默认构建就是我们要的
  —— `add_library(fmt src/format.cc)` 加 `FMT_OS` 默认 ON 时的 `target_sources(fmt PRIVATE
  src/os.cc)`;`src/fmt.cc` 是模块 unit(`export module fmt;`),归 `fmtlib.fmt`,不取。

## 2. 描述符设计

- 身份 `compat:fmt`,文件 `pkgs/c/compat.fmt.lua` —— 目录取**完整包名** `compat.fmt` 的首字母。
- `include_dirs = {"*/include"}`,前导 `*` 只负责吞掉 `fmt-12.2.0/` 包装层。写成 `{"*"}` 的隐蔽之处
  与 `compat.rapidcsv` 同形:本包照编不误,只有消费者 `#include <fmt/…>` 时才炸,所以由消费测试兜底。
- `sources = {"*/src/format.cc", "*/src/os.cc"}`;`targets = { ["fmt"] = { kind = "lib" } }`;
  `import_std = false`(非模块);无 `generated_files`(上游 `src/` 里就有实现)。
- `c_standard = "c11"`:`fmt-c.h` 的 C 面用 `_Generic` 与复合字面量,是 C11。本包 TU 全是 C++,
  该键对本包无副作用(`compat.richdem` 同形先例)。
- **不声明任何 define**,三条理由都实测过:
  - `FMT_OS` 在 12.2.0 的**头文件里已不再被读取**(仅 `src/fmt.cc` 用到),所以 os.cc 无条件编入
    即与「FMT_OS=ON」等价,两侧都不需要宏。
  - `FMT_SHARED` / `FMT_LIB_EXPORT` 只在 Win32 且非 header-only 时决定 dllexport/dllimport 词法;
    本目标是静态库,两个都不定义才是正确分支(与 `compat.concurrentqueue` 需要
    `MOODYCAMEL_STATIC` 的情形不同:fmt 的头不自带 dllimport 默认)。
  - `/utf-8` 属**消费侧**:上游为 MSVC 标记 PUBLIC 的唯一来源是 `chrono.h:581` 的
    `detail::use_utf8 ? "µs" : "us"`,而本包三个 TU 与它们包含的全部头(`base.h`、
    `format.h`、`format-inl.h`)实测**非 ASCII 字节数为 0**(逐字节统计)。源码字符集对本库
    无影响,而 `cflags`/`cxxflags` 只作用于本包 TU,替消费侧表达不了 —— 故不声明,只写进注释,
    并由「成员不测 chrono」把这条边界钉住(测它等于在断言本机工具链,而不是断言这个包)。
- **CN 镜像**:本次无 `mcpp-res` 写权限(无 `GITCODE_TOKEN`,也无
  `~/.config/gitcode-tool/config.json`),按 `docs/cn-mirror.md` 的回退路径写**纯字符串 url**
  (`compat.rapidcsv` / `pybind11` / `etl` 同形)。日后补镜像只需改写成 `{ GLOBAL = …, CN = … }`,
  sha256 不变(镜像按原样重托管 tag 归档)。

## 3. Feature 评估

- `c-api`:上游把 C API 做成**另一个**库(`add_library(fmt-c STATIC src/fmt-c.cc)`,头
  `include/fmt/fmt-c.h`),即「额外的可编译源码」—— 正是 sources-only feature 表能门控的东西
  (`compat.concurrentqueue` 的 `c-api`、`compat.cjson` 的 `utils` 先例),默认 OFF:只要 C++ 头的
  消费者不付这个 TU。请求方式 `fmt = { version = "12.2.0", features = ["c-api"] }`,编入同一 lib 目标。
- 不做 feature 的两样,及理由:
  - `fmt-header-only` 是上游 define-only 的 INTERFACE target(`FMT_HEADER_ONLY=1`),feature 表
    当前只门控 sources、不带 define,表达不了;
  - `FMT_OS` 不再是源码开关(见 §2),把它做成 feature 只会把「编不编 os.cc」伪装成一个不存在的
    可选项。
- **负向验证(实测,非推断)**:把 `tests/examples/fmt-c/mcpp.toml` 的依赖临时改回
  `fmt = "12.2.0"`(去掉 `features`),同一成员立刻失败,且失败在**链接期**:

  ```
  c_api ... FAIL (compile, 0.23s)
  failed: bin/fmt-c-tests/c_api.exe
  lld-link: error: undefined symbol: fmt_vformat
  lld-link: error: undefined symbol: fmt_vprint
  ```

  `fmt_arg` 的构造器是头里的 `static inline`,所以未解析符号只可能来自 `fmt-c.cc`;反向证据是
  包构建的 unit 计数:**带 feature 报 3 units,不带报 2 units**。验证后已还原。

## 4. 测试与验证

两个成员,按「一个 feature 一个成员」的既有分工(gmp-gmpxx / concurrentqueue-c-api 同形):

- `tests/examples/fmt`(`fmt-tests`,核心 lib):
  - `tests/format.cpp`:`fmt::format` 的多组结果、**运行时格式串**的 `fmt::vformat`、`
    format_to` 返回迭代器再续写。`vformat` 与那些显式实例化只在 `format-inl.h` 里定义、
    只有 `src/format.cc` 编成库里的一份 —— 若这个包没有把 format.cc 放进链接,本例根本不链接。
  - `tests/os.cpp`:`fmt::getpagesize()`(纯函数,零 I/O,`os.cc:361` 定义)是「os.cc 真被链接」
    的最省证据;再用 `fmt::pipe` 做一次 write→read 往返断言内容,不落任何文件、不联网
    (`compat.rapidcsv` 的原则)。
  - 不测 `fmt/chrono.h`,理由见 §2 的 `/utf-8` 一条。
- `tests/examples/fmt-c`(`fmt-c-tests`,`features = ["c-api"]`):`tests/c_api.cpp` 走
  `extern "C"` 面调用 `fmt_vformat` / `fmt_vprint`,断言输出、截断契约(`vformat_to_n`:返回值是
  本应写出的长度,缓冲区不补 NUL)与错误契约(未知 `fmt_type`、超过 16 槽的实参个数均返回
  `fmt_error_invalid_arg`)。**用 C++ 而不是 C 调用**是有意的:头里那套 `FMT_MAKE_ARG` 宏只在
  `#ifndef __cplusplus` 下存在,且要求 MSVC 的 `/Zc:preprocessor`(头里直接 `#error`)——那是描述符
  表达不了的消费侧编译开关,而门控的论点两条路一样成立。
- 两个成员都按 `rapidcsv` 的写法重复了单条 `[indices] compat = { path = "../../.." }`,并用限定写法
  `[dependencies.compat] fmt`(裸名请求会在默认命名空间解析,落回远端已发布索引)。

验证结论(本机 win32,`mcpp 2026.10.11.1`):

- `mcpp xpkg parse pkgs/c/compat.fmt.lua` → `parse OK`。
- `mcpp test -p fmt` → `test result ok. 2 passed; 0 failed`。
- `mcpp test -p fmt-c` → `test result ok. 1 passed; 0 failed`。
- 留痕:`.mcpp/.xlings/data/xpkgs/compat-x-fmt/12.2.0/` 下的 **`.xpkg.lua` 快照就是本 checkout
  这份描述符**(带 `["c-api"]` 表与注释原文),`fmt-12.2.0/include` 正是 `*/include` 展开的
  落点 —— 同时证明 glob 映射正确、且解析用的是本 checkout 而非远端已发布索引。
- 版本差异说明:CI pin 为 **2026.10.1.2**,本机为 **2026.10.11.1**(win32 主机跑不了 pinned 的
  linux 二进制)。本地结论只覆盖 windows 腿;linux/macOS 由 CI 裁决。
- 本机无 `lua5.4` 与 `bash` → `tests/check_*.lua` 与 `tests/run_members.sh` 无法本地复现,交 CI 的
  `lint` 与 `workspace` 覆盖(与 `2026-10-15-add-rapidcsv-plan.md` 同一处境)。

## 5. 注意事项

- 根 `mcpp.toml` 本次只动了 `[workspace].members`(加两行)。**没有**顺带把根 `[indices]` 改写成
  `[workspace.indices]`:新写法要求 mcpp ≥ 2026.10.10.1,而 `index.toml` 的 `min_mcpp` 是
  2026.9.18.3、CI pin 是 2026.10.1.2,两者要一起抬,属于另一件事。本地每次 `mcpp test` 都会打印那条
  弃用警告,是既有状态,不是本次引入的。
- 消费侧在 MSVC 上若要格式化非 ASCII 字面量(尤其经 `fmt/chrono.h`),需自行传 `/utf-8`;本包无法
  替其表达,已在描述符注释里写明。
- 合并后 `publish-artifact.yml` 自动重发索引 artifact;CN 镜像补传是独立动作。
