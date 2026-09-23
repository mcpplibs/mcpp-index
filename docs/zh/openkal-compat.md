# openkal 兼容性

[English](../openkal-compat.md) | **简体中文**

**读者:** 想知道某个包能否在 openkal 上工作的包作者或索引维护者,以及正在适配包的人。

**本文回答的问题:** 站点上的 `openkal` 标签是什么意思、如何测量,以及在 openkal 依赖图中构建失败的包如何由描述符适配。

## 1. 测量的对象

依赖图中含有 `openkal-llvm-runtime`(C++)或 `openkal-musl`(C)时,构建即选择了 openkal。此时依赖图提供四层,每层只保证自己那一层:

| 层 | 提供者 | 保证 |
| --- | --- | --- |
| `kernel-abi = openkal` | 规范,以及每个目标上的一个实现 | 每个 `kal_*` 操作在所有平台上行为一致 |
| `c-abi = musl` | `openkal-musl` | 一个 POSIX 形状的 C 环境;做不到的显式拒绝并列出 |
| `c++-abi = libc++` | `openkal-llvm-runtime` | 为该 C 库配置的 C++ 运行时 |
| 构建工具 | `mcpp` | 由依赖图提供的层完全由依赖图提供;不搜索宿主头文件 |

标签是对包的测试项目在该依赖图中的测量,不是声明。描述符中没有对应字段。

## 2. 标签

`tests/openkal/compat.py run` 复制 `tests/openkal/members.toml` 列出的每个成员,加入 `tests/openkal/pins.toml` 固定的运行时,用固定的工具链为每个固定的目标构建。结果按目标记录:

| 结果 | 含义 |
| --- | --- |
| `runs` | 成员的测试通过;非宿主目标经由固定的运行器执行(Windows 用 Wine) |
| `builds` | 成员构建成功,测试未运行或未通过;保留第一条诊断 |
| `fails` | 成员构建失败;保留第一条诊断 |

结果连同固定版本与日期写入 `.xpkgindex/openkal-compat.json`。一个包若被多个测试项目覆盖,站点对每个目标取其中最好的结果。`openkal` 分面有两个取值:

| 分面取值 | 归入的包 |
| --- | --- |
| `openkal-ecosystem` | 构成 openkal 的包:规范、各平台实现,以及直接建立在它之上的各层 |
| `openkal-compat` | 最好的目标记录为 `runs` 的包 |

最好的目标只记录为 `builds` 或 `fails` 的包不归入任何取值;它的页面仍按目标显示测量结果与第一条诊断。

成员是否自行选择平台依赖也会记录。自行选择平台依赖是允许的:openkal 上的包可以使用平台的系统接口,只要这些依赖来自依赖图。这一区分会显示出来,但不降低标签。

`tests/openkal/members.toml` 列出测量对象。`[excluded]` 列出在任何 openkal 依赖图中都无法构建的成员,并逐条写明原因;失败的成员照常测量并公布,不列入排除。

`[not-portable.<成员>]` 声明某个成员的**某一个目标**按构造无法构建,并写明理由。它存在是因为 `[excluded]` 是整成员级的,而有些成员两头都不是:`cmp-module` 在 `x86_64-windows-gnu` 上 runs,在 `x86_64-linux-gnu` 上建不起来——asio 的 `detail/config.hpp` 只要 `__linux__` 有定义就 include `<linux/version.h>`,而那行在所有 `ASIO_DISABLE_*` 守卫之外。整个排除掉这个成员,等于为了藏起一个真的结果而丢掉另一个同样真的结果。

**门槛是「没有任何清单键伸得进去」。** 上游源码在预处理期发问,算;本索引自己生成的配置头,不算,那属于配方。`curl` 的 `linux/tcp.h` 就是后者——`pkgs/c/compat.curl.lua` 在 `#if defined(__linux__)` 里写了 `#define HAVE_LINUX_TCP_H 1`,把一个关于内核的正确事实读成了关于「装了哪些 userspace 头」的断言。

**这个格子照常测量,而 `compat.py check` 在它构建成功时会红。** 一条凭一句话把格子移出统计的声明必须保持**可证伪**;没有任何东西能反驳的声明就是一张永久豁免。代价是一次在声明存在之前本来就要付的构建。

### curl 的两条失败是两个不同的真因

两条都是配方缺陷,而且不是同一个缺陷:

| 目标 | 首条诊断 | 真因 |
| --- | --- | --- |
| `x86_64-linux-gnu` | `lib/setopt.c:31: 'linux/tcp.h' file not found` | `#if defined(__linux__)` 里写死了 `#define HAVE_LINUX_TCP_H 1`。内核**确实**是 Linux,谓词没错;错的是把它读成「glibc 的 userspace 头都装好了」。诚实的判据是 `__has_include(<linux/tcp.h>)`。同一个块里还有 `HAVE_GLIBC_STRERROR_R`,在 musl 上它是假的。 |
| `x86_64-windows-gnu` | `curl_setup.h:591: "too small curl_off_t"` | 配方的 `windows` 分支**有意**不定义 `HAVE_CONFIG_H`,好让 `curl_setup.h` 去取仓库里checked-in 的 `lib/config-win32.h`,并链 `-lws2_32` 走 Schannel。而在 openkal 上,那个目标呈现的是 POSIX 且是 **LP64**,`config-win32.h` 写的是 LLP64 与 Win32 API。 |

**第二条才是有意思的那条:配方按「平台」分支,而问题问的是「C 环境」。** 在 openkal 于 Windows 上呈现 POSIX 之前,这两者在本索引的每一个目标上都同答案。mcpp 有那个真正被问的谓词——`cfg(c-abi = "musl")`(mcpp docs/22「按解析出的目标侧适配」)。在那里改选生成的 POSIX 配置而不是 checked-in 的 Win32 配置,就是它的形状;它还需要本索引的 OpenSSL 跑在同一个环境上,所以比第一条大,不与它合并。

## 3. 何时运行

`.github/workflows/openkal-compat.yml` 每周运行、可手动触发,测量全部列出的成员。对 PR,openkal 家族或 `tests/openkal` 变化时测量全部成员,否则测量依赖了被修改描述符的成员。除非启用下文的比较,它不阻止合并。

它有意安装宿主的 Windows 交叉头文件。若构建触及宿主头文件,结果会因其存在而改变;结果不变即说明依赖图是封闭的。

工作流还会把新的测量与已发布的文件比较(`compat.py check`),报告每个在某目标上标签降低的成员。仓库变量 `OPENKAL_RATCHET` 为 `on` 时,这一比较成为 PR 的必需检查;在每周测量连续两周稳定之后启用。

## 4. 适配一个包

在 openkal 依赖图中失败的包遇到的是其中某一层。以下规则决定适配放在哪里。

1. **按造成差异的那一层适配。** 缺少头文件或 C 运行时函数(`io.h`、`_lseeki64`、`TargetConditionals.h`、`winsock2.h`)是 C 库层的性质,用 `c-abi` 选择:

   ```lua
   target_cfg = {
       ["cfg(all(windows, c-abi = \"musl\"))"] = { cflags = { ... } },
   },
   ```

   缺少设施(`epoll`、信号处理器)是 openkal 的性质。优先使用包自身选择其他机制的特性(例如基于 `select` 的 reactor);描述符必须自动选择时,使用 `cfg(all(kernel-abi = "openkal", c-abi = "musl"))`。源码中不应判断自己是否构建在 openkal 上。

2. **不取消定义平台宏。** `_WIN32` 与 `__APPLE__` 由目标三元组定义,且为真。应改写包自己的判断条件,按以下优先顺序:包已支持的配置宏(`Z_HAVE_UNISTD_H`、`HAVE_*`);生成的配置头(`generated_files`);补丁。仅当结果不进入任何公共头时,才允许在私有翻译单元中例外,并由描述符在旁注明原因。

3. **公共头只有一种读法。** 改变公共头声明内容的宏必须同时作用于包与其消费者;做不到时,由测试成员断言两侧一致(规则 4)。

4. **跨越边界检查变化了的配置。** 在 openkal 依赖图中配置不同的包,其测试成员要用已编译的包自己报告的布局,对照消费者计算出的布局。`tests/examples/zlib` 以 `zlibCompileFlags()` 对照 `sizeof(z_off_t)`。

5. **每个镜像只有一个 C 运行时和一个 C++ 运行时。** 依赖平台的包可以调用只传递句柄与值的平台系统接口。按平台 C 运行时编译的静态库,以及由该运行时拥有的对象跨越边界(`FILE*`、由另一运行时释放的内存、`errno`),均不受支持,此类包不在 openkal 上测量。平台库在其自行创建的线程上发起的回调没有 C 库状态,不得依赖它。

## 5. 复现一次测量

```bash
python3 tests/openkal/compat.py run --member cjson --target x86_64-linux-gnu --out /tmp/r.json
python3 tests/openkal/compat.py check --results /tmp/r.json --baseline .xpkgindex/openkal-compat.json
```

成员被复制到未纳入版本管理的 `tests/openkal-work/`,运行结束后删除该目录。
