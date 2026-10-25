# 新增 GSL 收录（compat，install() 构建）

## 1. 来源与形态

- 收录 GNU Scientific Library 2.8，官方站点列出的当前稳定版本。
- 采用 GNU 源码归档 `gsl-2.8.tar.gz`，SHA-256 为
  `6a99eeed15632c6354895b1dd542ed5a855c0f15d9ad1326c6fe2b2c9e423190`。
- GSL 2.8 是 autotools 工程：`configure` 生成 `config.h`，顶层构建再通过 libtool
  组合 `libgsl.a` 和 `libgslcblas.a`。其源码树包含大量相互依赖的子库和测试源，不能用
  一个宽泛的 `sources` glob 安全表达生产库边界。
- 描述符因此采用与 `compat.openblas`/`compat.openssl` 相同的 `install()` 触发方式：
  构建期运行上游 `configure`、`make`、`make install`，然后由 hook 写入 anchor TU。

## 2. 描述符设计

- 身份为 `compat:gsl`，文件为 `pkgs/c/compat.gsl.lua`。
- Linux 使用官方源码包和 `xim:make@latest`，macOS 使用系统自带的 GNU Make；
  关闭 shared、启用 static，产物安装到包的 `include/` 与 `lib/`。
- hook 显式使用 `CFLAGS=-std=c11`。GSL 2.8 的 configure 探测包含旧式 C
  兼容性代码，在 GCC 16 的默认 C23 模式下会被拒绝；固定到 C11 同时符合
  GSL 的 ANSI C 构建要求，并保持 Linux CI 与本地工具链一致。
- Linux hook 显式选择 `/usr/bin/gcc`，而不是 PATH 中可能由 xlings 注入的
  payload compiler。GSL configure 会编译并运行 ABI 探测程序，宿主编译器
  保证这些探测程序能在 CI runner 上执行。
- 消费侧公开 `include/gsl/*.h`，链接顺序为 `libgsl`、`libgslcblas`、`libm`。
- GSL 自带 CBLAS 随包默认提供，不再声明或隐式绑定 `compat.openblas`，避免 BLAS ABI
  和符号来源不明确。
- Windows 暂不声明 xpm 版本：官方 2.8 归档没有原生 MSVC 构建路径，当前 index 也不
  应凭空引入未经验证的预编译库。测试工程在非 Unix 平台编译 no-op。

## 3. Feature 评估

GSL 的各数值领域在上游构建中共同链接到 `libgsl`，不是可以由 mcpp `features`
（只能可靠门控源码列表）独立切分的消费者组件，因此本版本不增加 feature。CBLAS
同样作为完整 GSL 的默认组成部分。

## 4. 测试与验证目标

`tests/examples/gsl` 覆盖：

- Bessel 特殊函数；
- 自适应积分；
- CBLAS `ddot` 的链接和结果。

验证包括描述符 lint、`mcpp xpkg parse`、`mcpp test -p gsl`，以及一次清理缓存后的
冷构建，确认头文件和两个静态归档来自该包而不是宿主系统。
