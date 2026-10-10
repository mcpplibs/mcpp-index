# 收录 LibSerial 1.0.0(compat.libserial)

日期:2026-10-03 · 分支:`feat/add-libserial` · 状态:本地验证通过

## 1. 来源与形态判定

LibSerial 属于来源 (a):第三方上游库,上游不提供 mcpp 支持。

- 上游:<https://github.com/crayzeewulf/libserial>。
- 最新版本:`git ls-remote --tags` 里 v1 系列只有 **`v1.0.0`**;更早的 tag 是
  `libserial_0_5_0` / `libserial_0_6_0rc1..3` / `v0.6.0rc3` 这类 0.5/0.6 候选版,
  不收录。
- License:BSD-3-Clause(`LICENSE.txt`,版权归 LibSerial Development Team)。
- 源码布局:`libserial-1.0.0/` 包一层,库源码是 `src/SerialPort.cpp`、
  `src/SerialStream.cpp`、`src/SerialStreamBuf.cpp` 三个 TU,公开头在
  `src/libserial/`(`SerialPort.h`、`SerialStream.h`、`SerialStreamBuf.h`、
  `SerialPortConstants.h`)。无 configure 生成的配置头(CMake 只做选项开关),
  无 submodule、无必需生成步骤。

**形态 = A(C++ 源码 compat)**,与 compat.websocket / compat.yaml-cpp 同类:
把上游 CMake 的 `LIBSERIAL_SOURCES` 编成一个 lib,公开头经 `include_dirs` 暴露,
消费者写 `#include <libserial/SerialPort.h>`(上游 `install(DIRECTORY libserial
DESTINATION include)` 的布局)。

## 2. 版本与下载源

`sha256 = 063142d6bfe08898316e9a6055f2ddeedef56de06f7cfc8dcdfecc6efabf4bdd`(121235 字节,连算两次一致)。

GLOBAL 用 GitHub 的 tag 归档 `.../archive/refs/tags/v1.0.0.tar.gz`。

## 3. CN 镜像

当前环境没有 gitcode `mcpp-res` 写权限(`~/.config/gitcode-tool/config.json` 不存在、
`GITCODE_TOKEN` 未设置)。按 `docs/cn-mirror.md` 的回退方案,用**纯字符串 url** 指向
上游 release,lint 对纯字符串不做镜像约束;待拿到 mcpp-res 权限后再改写成
`{ GLOBAL, CN }` 表(sha256 不变)。先例:compat.libuv / compat.hiredis /
compat.websocket。

## 4. 平台判定:仅 linux

LibSerial 面向 POSIX:公开头 `SerialPortConstants.h` 顶部就是 `#include <termios.h>`,
实现 TU 一律触及 `<linux/serial.h>`、`<sys/ioctl.h>`、`<unistd.h>`,驱动的 ioctl
(`TIOCEXCL` / `TIOCMGET` / `FIONREAD` / `TIOCSSERIAL`)与 `struct serial_struct`
都是 Linux UAPI。上游 CMake/autotools 也只在 Linux 发行版上分发。

因此 `xpm` 只写 `linux` 一段,消费者用 `[target.'cfg(linux)'.dependencies]` 门控,
测试在非 Linux 上编成 no-op `main()` —— 与 compat.libaio 完全同形。单平台 `xpm`
不会触发 platform-version-parity(它只比较**都带版本**的平台)。

## 5. 一处消费者可见的头文件缺陷(用 generated_files 修复)

`src/libserial/SerialPortConstants.h` 声明 `using DataBuffer = std::vector<uint8_t>;`,
却既没 `#include <cstdint>` 也没 `#include <stdint.h>`。在 gcc 16.1.0 / libstdc++ 上它
**只是碰巧**能编 —— 靠其它 stdlib 头的传递包含;一个先打开 libserial 头的干净 TU 会报
`'uint8_t' was not declared in this scope`(已在 tarball 上复现)。

修法沿用 compat.yaml-cpp / compat.cpptrace / compat.catch2 的 shim 模式:
`generated_files` 里放一个同名路径 `mcpp_generated/libserial/SerialPortConstants.h`,
先 `#include <cstdint>` 再 `#include_next <libserial/SerialPortConstants.h>`;`include_dirs`
把 `mcpp_generated` 排在 `*/src` 之前,shim 命中在真头之前。包自身的三个 TU 与消费者
都经过它。

测试把 `#include <libserial/SerialPort.h>` 放在**整个文件的第一行**(上面不放任何
stdlib 头),使 shim 成为编译期断言:去掉 shim 该 TU 就编不过。

## 6. feature 评估:无

判据是「是否存在额外的、可门控的**可编译源码**」。LibSerial 没有:

- `test/` 是 GoogleTest 套件(自带 `main()`),mcpp 的 lib 目标对象全量入链,包里带
  `main()` 会与消费者冲突;
- `sip/` 是 Python SIP 绑定(需 sip/PythonLibs,非库的可选编译组件);
- `doxygen.conf.in` 只生成文档。

故 `features` 整个不声明。

## 7. 测试成员 `tests/examples/libserial`

依赖按 `[target.'cfg(linux)'.dependencies.compat]` 门控,非 Linux 编成 no-op。断言跑在
真实 **openpty()** 对上(构建机没有 `/dev/ttyUSB0`;纯链接测试即使 termios 全错也会绿):

1. `NotOpen` 契约:关闭状态下 `Write`/`GetBaudRate` 抛 `NotOpen`;
2. `Open`/`IsOpen`,二次 `Open` 抛 `AlreadyOpen`;
3. 打开默认值:`BAUD_115200`、`CHAR_SIZE_8`、`PARITY_NONE`、`STOP_BITS_1`;
4. `Set/Get` 往返:**只断言 pty 真正承载的属性**(波特率、停止位、流控)。CS7/偶校验
   不断言 —— pty 的行规程不保存这些位,写了也读回 CS8/NONE(实测),那是 pty 的性质、
   不是 LibSerial 的,所以只钉可观测的部分;
5. TX:`SerialPort::Write` → 主机 `read` 收到 `"hello\n"`;
6. RX:主机 `write` `"ping\n"` → `IsDataAvailable` + `ReadByte` + `ReadLine` 拼出 `"ing\n"`;
7. `SerialStream`:用**另一对** pty(复用同一对会在二次 Open 时抛 `OpenFailed`,那是上游
   Open 路径的行为)验证 iostream 写路径 `stream << "xyz"`,主机读到 `"xyz"`。

**故意不测 SerialStream 的读路径**:上游 `SerialStreamBuf::showmanyc()` 置了 putback
标志却没存下它读到的那个字节,于是 `rdbuf()->in_avail()` 后接流式提取会吐出乱码首字节,
而安静 pty 上 `stream >> x` 会阻塞(实测)。这是 `SerialStreamBuf` 的上游缺陷,不在本
描述符能修的范围内,故测试只钉能工作的那一半。

## 8. 验证结论(与 CI 同版本 mcpp)

- `mcpp xpkg parse pkgs/c/compat.libserial.lua` → `parse OK`。
- 冷跑(先删 `target/` 与 `.mcpp/`)`mcpp test -p libserial` → `test result ok`。
- 六个本地 lint(syntax / mirror-urls / package-name / platform-parity /
  duplicate-versions / cross-package-refs)全部通过。
- 负向验证:把 TX 断言改成必失败,`mcpp test` 报 `FAIL`/非零退出,证明断言确实生效。

## 9. 注意事项

- 上游公开头对 `<cstdint>` 的隐式依赖是本包必须带 shim 的唯一原因;若未来上游补上该
  包含,shim 仍是无害的(重复包含 <cstdint> 与 include_next 都安全)。
- `include_dirs` 用 `*/src`(上游安装根),该目录下只有 `libserial/` 一个子目录,不会
  遮蔽任何系统头。

## 10. 维护者追加(2026-10-11):llvm 腿失败与 CN 镜像

**现象**:PR CI 的 `workspace (linux llvm 0/4)` 失败(`red members name their issues` 随之失败,
它要求红成员登记 issue),gcc / macOS / Windows 全绿。

**根因**:`src/libserial/SerialPort.h` 的公开模板 `call_with_retry` 写的是
`typename std::result_of<Fn(Args...)>::type`。`std::result_of` 在 C++17 弃用、C++20 移除:
libstdc++ 仍保留(仅弃用告警),libc++ 在 C++20 及以上直接删掉,于是三个 TU 全部报
`no type named 'result_of' in namespace 'std'`。它在公开头里,消费者 TU 同样会坏。上游 master
仍是这个写法。

**为什么不用别的办法**:
- shim(`#include_next`)只能在头文件前后加东西,改不了头文件内部的模板;
- `_LIBCPP_ENABLE_CXX20_REMOVED_TYPE_TRAITS`(libc++ 22/23 仍认)必须在每个 TU 的第一个
  libc++ 头之前定义;描述符的 `defines` 到不了消费者,shim 也无法保证顺序;
- 降低语言标准同样到不了消费者 TU。

**做法**:`install()` 在解包树上把两处改写为等价的 `std::invoke_result_t<Fn, Args...>`
(对它实际被调用的函数指针 + 退化实参,两者结果相同),并在 `#include <memory>` 后补
`<type_traits>`;每处断言匹配次数(2 / 1),上游一变就让安装失败而不是悄悄跳过。
随后按 `compat.ftxui` / `taskflow.taskflow` 的方式把包装层移进安装目录,`*/src` glob 不变。
工作区 `.mcpp/` 不在 CI 缓存里,故无需 `revision`。

**CN 镜像**:建 `mcpp-res/libserial`,release `1.0.0` 上传与 GLOBAL 同一个 tarball,
`curl` 回环 200 且逐字节一致;`url` 改为 `{ GLOBAL, CN }`。

**验证**:`mcpp test -p tests/examples/libserial` 在 gcc 16.1.0、llvm 22.1.8、llvm 23.1.3 下
均 `1 passed`(llvm 用 `--cache off` 确认 compat.libserial 由 clang 重新编译)。

**另**:原分支合并 main 时把 CHANGELOG 中 `openkal-llvm-runtime 0.15.4` 与
`openkal-linux 0.16.1 / openkal-musl 0.20.1` 两条误删,已按 main 恢复。
