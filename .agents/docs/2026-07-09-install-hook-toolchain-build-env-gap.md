# install() hook 子进程继承不到工具链构建环境(源码构建包的生态缺口)

**日期**: 2026-07-09
**范围**: xlings/xim 的 `install()` xpkg hook 执行环境 × 生态工具链(`xim:gcc` / `xim:glibc` / `xim:linux-headers`)
**性质**: xlings 侧的生态能力缺口(根治点在 xlings/xim,不在下游 descriptor)
**触发用例**: `compat.opencv`(源码 CMake 构建)在 mcpp-index workspace CI 上的 `workspace(linux)` 失败
**状态**: opencv PR #67 已标记**待评估**(draft),阻塞在本缺口

---

## 文档族与职责边界

| # | 文档 | 定位 |
|---|---|---|
| ① | `2026-07-09-mcpp-builddep-loader-store-split-rootcause.md` | 原故障(cmake interpreter 悬空)根因总报告 |
| ② | mcpp `2026-07-09-project-index-scope-global-infra-fix.md` | 该故障**唯一必需修复**(mcpp 0.0.87,已发布) |
| ③ | xlings `2026-07-09-scope-consistency-installed-check-and-loader-resolution.md` | elfpatch additive 解析缺口(D1,**独立**、当前未被触发) |
| ④ | **本篇** | **install() hook 构建环境缺口**——②修好后 opencv 暴露出的**新**生态缺口,与 ①②③ 均不同 |

**与 ③(D1)的区别**:③ 是 **runtime** loader-provider 的**跨 store 解析**(elfpatch interpreter/rpath);本篇 ④ 是 **build-time** 的**编译/链接搜索路径**(startfile / 库 / 头文件)。两者都涉及 glibc,但一个在装完后跑,一个在 install() 里编。

---

## 0. 现象

`compat.opencv` 的 `install()` 用生态工具链(`xim:cmake` + `xim:gcc` + `xim:make`)从源码构建 OpenCV。开发主机上闭环通过;但 mcpp-index workspace CI 的 `workspace(linux)`(冷环境、无宿主 libc-dev)上,`install()` 的 CMake 构建**静默失败**,消费者最终报 `opencv2/core.hpp: No such file`。

xim 的 interface 模式**抑制了 install() 子进程的全部输出**(subprocess stdout + libxpkg `log.error`),故真因在 CI 上不可见——只能看到 `fetch 'compat.opencv@4.13.0' failed (exit 1)`。通过在 CI workflow 加**失败诊断步骤**(直接从 runner 磁盘 `cat` build log + 直跑 `xlings install cmake`)才拿到真相。

## 1. 真因:install() 子进程没有工具链的**构建期**环境

`xim:gcc` 的 specs(`xim-x-gcc/16.1.0/lib/gcc/.../specs`)只把 `xim:glibc` 接进了**运行期**:
- `-rpath <glibc>/lib64`、`-dynamic-linker <glibc>/lib64/ld-linux-x86-64.so.2`。

specs **没有**把 glibc 的**构建期**搜索路径写进去:
- 链接期 startfile / 库:`crt1.o`、`crti.o`、`crtn.o`、`libm`、`libc`(都在 `<glibc>/lib`);
- 编译期头文件:`stdlib.h`、`limits.h`(在 `<glibc>/include`),以及内核 uapi 头(在 `<xim:linux-headers>/include`)。

平时这些由 **mcpp 的构建流程**通过环境变量(`LIBRARY_PATH` / `CPATH`)提供给 gcc。但 `install()` hook 的子进程**不继承** mcpp 的构建环境,于是 gcc 在 install() 里既找不到 crt/库、也找不到系统头。

**为什么开发主机上没暴露**:主机装了 libc-dev,gcc 默认 startfile/include 前缀里有 `/usr/lib/.../crt1.o` + `/usr/include/stdlib.h`,**静默 fallback 到宿主** → 能编过,但**违反 host-free**、且用的是宿主 glibc 而非生态 glibc。极简 CI runner 没 libc-dev → 硬失败。这也是本地一直复现不出 CI 失败的根源。

**为什么 openblas 没踩坑**:`compat.openblas` 的 install() 只**编译 + 归档 `.a`**(`make libs`),从不**链接可执行文件**,所以永远不需要 crt1.o/libm;它对系统头的依赖也浅。opencv 的 CMake **编译器自检要链接一个测试 exe**,第一步就撞上 crt1.o 缺失。

## 2. CI 实证(逐层剥开)

install() 里临时逐个补齐,CI build log 逐层前进,坐实了缺口范围:

| 层 | 报错 | 缺的东西 |
|---|---|---|
| L1 | `cmake: cannot execute: required file not found` | 动态 xim:cmake 的 loader launcher(裸名 vs 绝对路径) |
| L2 | `ld: cannot find crt1.o / crti.o / -lm` | 链接期 `LIBRARY_PATH=<glibc>/lib` |
| L3 | `find_package called with invalid argument "OFF"` | OpenCV 撞见 xlings python3 shim(版本串空)→ `OPENCV_PYTHON_SKIP_DETECTION` |
| L4 | `fatal error: stdlib.h / limits.h: No such file` | 编译期 `CPATH=<glibc>/include:<linux-headers>/include` |

L1/L2/L4 都是**同一个缺口的不同面**:install() 子进程缺工具链的构建期环境。(L3 是 OpenCV × CMake4 的独立小问题,已用官方开关解决。)

## 3. 为什么"在 descriptor 里各自硬接"是错的层级

opencv PR 上现存的 `LIBRARY_PATH`/`CPATH` + `pkginfo.install_dir("xim:glibc","2.39")` + 显式声明 `xim:glibc@2.39`/`xim:linux-headers@5.11.1` 是**临时探路**,**不作为最终方案**,因为:

1. **脆弱**:硬编码 glibc 2.39 / linux-headers 5.11.1 版本,工具链一升级就失效。
2. **重复**:每个源码构建包(未来的 ffmpeg / boost / …)都要各自重接一遍同样的环境。
3. **层级错**:"gcc 该怎么找到它自己工具链的 glibc" 是**工具链/安装器**的职责,不是每个下游包的职责。

## 4. 根治设计(xlings/xim 侧)

**install() hook 的子进程,应当在一个已经具备完整工具链构建期环境的 shell 里运行。** 具体二选一(或组合):

- **方案 A(推荐)——安装器注入构建环境**:xim 在执行 install() hook 时,依据当前 default toolchain(gcc + 其 runtime dep 链上的 glibc、linux-headers)导出 `LIBRARY_PATH` / `CPATH`(或 `C_INCLUDE_PATH`+`CPLUS_INCLUDE_PATH`),使 hook 内 bare `gcc`/`cmake` 天然 host-free。信息来源:resolver 的 plan 已知每个 node 的 effective store(与 ③ D1 的"effective_install_dir"同源,可复用)。
- **方案 B——把构建期路径也写进 gcc specs**:让 `xim-x-gcc-specs-config` 生成的 specs 除了 rpath/dynamic-linker,再补 startfile prefix(`<glibc>/lib`)与 `-isystem <glibc>/include`、`-isystem <linux-headers>/include`。好处是对**任何**调用方(不止 install())都生效;代价是 specs 更重、且路径同样要在装 glibc 时确定。

无论哪个,目标一致:**任意生态工具(mcpp 构建 / install() hook / 用户直调 gcc)在 host-free 环境下都能编译+链接,不 fallback 到宿主。** descriptor 侧则**零环境接线**。

### 实现落点(已核对源码)

核对 `xim-x-gcc-specs-config/0.0.1/gcc-specs-config.lua`(115 行):它只做**运行期**注入 —— 取 gcc `-dumpspecs`,替换 `*link:` 的 dynamic-linker、追加 `-rpath/-rpath-link <default_libdir>`,回写 specs。**完全没碰构建期**(startfile 前缀 / `-L` / header `-isystem`),坐实缺口。两条实现路径的精确落点:

- **方案 A(推荐,更聚焦)——xlings 在执行 install() hook 时导出构建环境。** 落点在 xlings 执行 xpkg `install()` 的地方(`xpkg-executor` / `installer.cppm` 的 hook 调用),依据当前 default toolchain 的 gcc→(glibc、linux-headers)runtime dep 链,导出 `LIBRARY_PATH=<glibc>/lib`、`CPATH=<glibc>/include:<linux-headers>/include`(路径由 resolver plan 的 effective store 给出,与 ③ D1 的 `effective_install_dir` 同源可复用)。只影响 install() hook,不改工具链本身,风险面最小。
- **方案 B——扩 specs 生成器。** 需给 `gcc-specs-config.lua` **增加入参**(glibc include 目录 + linux-headers include 目录 —— 目前它只拿到 `default_libdir`),并在 specs 里补:`*startfile_prefix_spec:` = `<glibc>/lib`(找 crt1.o/crti.o/crtn.o)、`*link:` 追加 `-L<glibc>/lib`(找 -lm/-lc)、`*cpp:` 追加 `-isystem <glibc>/include -isystem <linux-headers>/include`(找系统头)。好处是对任何 gcc 调用方都生效;代价是跨"生成器 + 其调用者(装 glibc 时传 include 路径)"两处联动,且改动作用于**整个生态的 gcc**。

> 评估:A 更聚焦、可验证成本低(改 install() 执行环境即可,不动工具链);B 更彻底但联动面大、且触及官方 index 的 gcc 行为。二者都需 xlings/xim 侧的 C++/Lua 改动 + 其自身 build/验证闭环,**属 maintainer 协作项,不宜由下游会话半实现且无法完整验证地推进**。本文即为该实现提供 ready 的设计与落点。

## 5. 落地关系

- **不阻塞 mcpp 0.0.87**(②,已发布)、**不阻塞 D1/#354**(③,独立,当前 HOLD)。
- **阻塞 opencv 及未来源码构建包**的 host-free 闭环 → opencv PR #67 待评估,等本缺口在 xlings/xim 侧补齐后回来**删掉 descriptor 里的临时环境接线**再合入。
- CI 侧 opencv workspace 的临时诊断步骤(mcpp-index `.github/workflows/validate.yml`,commit `450acbb`)在 opencv 落地前应移除。
