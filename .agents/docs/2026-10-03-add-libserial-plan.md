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
