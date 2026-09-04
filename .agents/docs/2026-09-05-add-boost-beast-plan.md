# 收录 compat.boost-beast 1.92.0（及 modular-boost 家族第二列车，共 25 个新包）

日期：2026-09-05。目标：把 Boost.Beast（HTTP/WebSocket）以 modular-boost 拆包
路线收进索引。参考既有案例 `compat.boost-uuid`（#244）。

## 形态判定

- 来源 (a) 第三方上游：boostorg/beast，tag `boost-1.92.0` —— 与家族现有五包
  （config/assert/throw-exception/type-traits/uuid）同一训练版本。上游 beast
  已发布 1.93 训练之前家族不能单独动版本（"整列车一起升级"策略），故全部
  新包钉 `boost-1.92.0`。
- Layout：`beast-boost-1.92.0/include/boost/beast.hpp` + `include/boost/beast/`，
  与家族一致的 `include_dirs = { "*/include" }` 模板。
- License BSL-1.0；header-only（CMake 目标是 INTERFACE；beast/zlib 是自带
  的 inflate/deflate 移植，不需要外部 zlib；`boost/beast.hpp` 聚合面不含
  ssl，`beast/ssl.hpp` 需要消费者自带 OpenSSL 依赖，本包不接线）。

## 为什么必须走 boost.asio，而不是现成的 chriskohlhoff.asio

Beast 1.92 上游**已移除** `BEAST_USE_STANDALONE_ASIO`：
`include/boost/beast/core/detail/config.hpp` 全树 grep 不到 "STANDALONE"，
`beast/core/error.hpp` 无条件把 `beast::error_code` 别名为
`boost::system::error_code`。所以独立 Asio 路线在 1.92 训练上不存在，
必须补 boost.asio 家族成员；boost.asio 自身是 header-only（superproject
不构建编译目标），闭包是 align/assert/config/system/throw_exception。

## 闭包（机械可复核）

对每个参与仓库的 include 树做全量 grep（两种拼写 `#include` 与 `# include`
都要抓：初版正则漏了带空格的 `# include <boost/mp11/algorithm.hpp>`，
差点少包 mp11），并与各仓 CMakeLists 的 INTERFACE 行交叉核对：

```
beast     -> asio, assert*, bind, config*, container, container_hash, core,
             endian, intrusive, logic, mp11, optional, smart_ptr,
             static_string, system, throw_exception*, type_index,
             type_traits*, winapi          （19 个，grep 与 CMake 完全一致）
asio      -> align, assert*, config*, system, throw_exception*
             （+ context、date_time：见下节，二者被 define 关闭）
align     -> assert*, config*, core
bind      -> config*, core
compat    -> assert*, config*, throw_exception*
container -> assert*, config*, intrusive, move
container_hash -> config*, describe, mp11
core      -> assert*, config*, throw_exception*
describe  -> mp11
endian    -> config*
intrusive -> assert*, config*, move
io        -> config*
logic     -> config*, core
move      -> config*
mp11 / predef / preprocessor -> （无）
optional  -> assert*, config*, core, throw_exception*, type_traits*
smart_ptr -> assert*, config*, core, throw_exception*
static_string -> assert*, config*, container-hash, core, throw_exception*, utility
system    -> assert*, compat, config*, mp11, throw_exception*, variant2, winapi
type_index -> config*, container-hash, throw_exception*
utility   -> assert*, config*, core, io, preprocessor, throw_exception*, type_traits*
variant2  -> assert*, config*, mp11
winapi    -> config*, predef
```

（`*` = 家族已有包。）单文件 shim 的归属以物理文件为准逐一核实：
`boost/get_pointer.hpp`、`boost/type.hpp`、`boost/is_placeholder.hpp`、
`boost/visit_each.hpp`、`boost/noncopyable.hpp` → core；`boost/none.hpp` →
optional；`boost/cerrno.hpp` → system；`boost/detail/{call_traits,
compressed_pair}.hpp` → utility；`boost/detail/winapi/*` → winapi；
`boost/version.hpp`、`boost/cstdint.hpp`、`boost/static_assert.hpp`、
`boost/detail/workaround.hpp` → config（家族既有声明）。
beast 的 `type_index` 只以单文件头 `<boost/type_index.hpp>` 进入——只按
目录 grep 会漏掉它；上游 CMakeLists 列的 type_index 反而因此是对的。
29 棵 include 树（25 新 + 4 既有 + beast）合计 2608 个文件，
**两两不相交**（脚本核验零重复路径），`*/include` 联合成一棵 `boost/`
树无碰撞。

## boost-asio 的两个 disable 宏（本 PR 唯一的 feature 用法）

boost.asio 对 boost.context（spawn 栈ful 协程）与 boost.date_time（
deadline_timer）是**编译器版本级自动探测**：clang/gcc ≥ C++11 就打开
`BOOST_ASIO_HAS_BOOST_CONTEXT_FIBER`；`boost/version.hpp ≥ 1.33` 就打开
`..._DATE_TIME`。而 Boost.Context 是**编译期（含汇编）库**，一旦放任探测，
asio/impl/spawn.hpp 会 include `<boost/context/fiber.hpp>`，家族的
header-only 性质就保不住。两个都有上游认可的关闭开关：

```
BOOST_ASIO_DISABLE_BOOST_CONTEXT_FIBER
BOOST_ASIO_DISABLE_BOOST_DATE_TIME
```

二者经 compat.boost-asio 的 `default` → `asio-config` feature 的
`defines` 传播（先例：chriskohlhoff.asio 的 separate-compilation、
compat.curl 的 staticlib）。compat.boost-beast 的 default feature
**原样重述**这些宏：feature defines 对直接消费者传播是已验证行为，
隔着中间包（beast）向消费者的传播没有现成先例，重述一遍保证 beast 消费者
的每个 TU 看到一致配置；两侧同值，幂等无 ODR 风险。
关闭后 beast 不用 spawn/deadline_timer，无能力损失。

第三个宏 `BOOST_ASIO_HAS_THREADS`：workspace 的 llvm-on-Windows 工具链
（clang → x86_64-pc-windows-msvc）不定义 `_MT`/`_REENTRANT`，boost::config
也给不出 `BOOST_HAS_THREADS`，asio 的探测（detail/config.hpp 1169-1190 行）
会静默选中 null_thread；且该宏参与 `BOOST_ASIO_VERSION_TAG`（符号级别名），
跨 TU 必须一致——所以必须作为 feature define 传播而不是 cflag。这是 CI
windows 腿上 boost-asio 成员首跑 crash（exit 0xC0000409）后的修正，
与 chriskohlhoff.asio 钉 `ASIO_HAS_THREADS` 完全同构。

## 命名

包名一律 kebab：`boost-container-hash`、`boost-smart-ptr`、
`boost-type-index`、`boost-static-string`（家族先例 type-traits/
throw-exception）；仓库 URL 与注释中保留上游仓原名 `container_hash` 等。
目录按完整包名首字母，`compat.*` 全部落 `pkgs/c/`。

## CN 镜像

按家族先例（#244、boost-ext.ut）暂不建：全部采用纯字符串
`url = "<GLOBAL>"`，lint 允许，CN 用户回退上游源，由维护者后续补 gitcode。
24 个新 tarball 的 sha256 各计算两次确认稳定；既有四包的钉定哈希与本次
上游下载逐一相符（互证 GitHub archive 稳定性）。

## 消费与测试

- `tests/examples/boost-beast/`：`#include <boost/beast.hpp>` 聚合头把
  core/http/websocket/zlib 编进同一 TU；断言 HTTP 请求解析、响应序列化
  （response_serializer）+ 回读往返、畸形输入报错、自带 zlib 压缩/解压
  往返、multi_buffer/flat_buffer 与 static_string。
- `tests/examples/boost-asio/`：直接消费者路径，验证 feature 宏传播到
  消费 TU；真实跑 `steady_timer` + `io_context::run`、post/defer、
  co_spawn/awaitable、tcp endpoint。`#include <boost/asio.hpp>` 单体头
  顺带验证 disable 宏守卫下单体 include 可用。
- 两成员只消费 `compat` 命名空间，继承根 workspace 的 `[indices]`
  重定向，不声明自己的 indices。
- 正向验证在 CI（linux/macos/windows 三平台）；无 feature 需要负向验证
  （无源码门控），disable 宏的"负向"体现在：闭包树里根本没有
  `boost/context`、`boost/date_time` 头文件可解析（机械核验过）。

## 结果

- 本地：`mcpp test -p boost-asio`、`mcpp test -p boost-beast` 通过
  （mcpp 2026.8.27.2，冷启动），lint（lua 语法、必填字段、裸版本、
  name 单段、镜像表、`mcpp xpkg parse` 全描述符）通过。
- CI：lint / mirror-cn-reachable / workspace 选择性成员测试全绿后合并。

## 备注 / 后续

- 升级到 1.93 训练时需整列车一起动（29 个包）。
- 消费者要 beast::ssl 时：加 `compat.openssl` 并确保 OpenSSL 头在 include
  路径——本包未为 ssl 接线（boost.asio 的 ssl 头在包里，能编译的先决
  条件是消费者带 OpenSSL）。
- 若未来某消费者需要 spawn()/deadline_timer：需要收录 Boost.Context
  （含汇编编译）或 Boost.Date_Time（闭包巨大），届时再评估拆包成本。
