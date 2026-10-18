# 新增 rapidcsv 收录（compat，单头文件）

## 1. 来源与形态

- 收录 [d99kris/rapidcsv](https://github.com/d99kris/rapidcsv) 9.07，即上游最新 tag
  `v9.07`（2026-08-15 发布）。上游版本号是 `9.07`/`8.99`/`8.92` 这种两位形式，
  描述符里写裸值 `"9.07"`（lint 禁止前导 `v`，仓内已有 `compat.gsl` `"2.8"`、
  `compat.pcre2` `"10.44"` 先例）。
- 归档 `https://github.com/d99kris/rapidcsv/archive/refs/tags/v9.07.tar.gz`
  （v9.07 的 release 没有 asset），SHA-256 为
  `442c1d60080171fcd621d0578eb9dc03ad77781b1f4e35e7f6cd6271e4c3072e`，
  两次下载一致。解包顶层为 `rapidcsv-9.07/`。
- License 为 BSD-3-Clause（GitHub API 的 `license.spdx_id`；网络多处材料写成
  MIT，以仓库 LICENSE 为准）。
- 形态 B（header-only）：整个解析器就是 **一个** `src/rapidcsv.h`（68 635 字节，
  C++11+）。上游 CMake target 是 INTERFACE-only，mcpp 需要一个可构建的 lib，
  因此按 `compat.etl` / `compat.eigen` 的手法生成一个 anchor TU。

## 2. 描述符设计

- 身份 `compat:rapidcsv`，文件 `pkgs/c/compat.rapidcsv.lua`——目录取**完整包名**
  `compat.rapidcsv` 的首字母，不是短名首字母。
- `include_dirs = {"*/src"}`，**不是 `{"*"}`**：头文件在 `src/` 下，前导 `*`
  只负责吞掉归档的 `rapidcsv-9.07/` 包装层。这一处写错很隐蔽——anchor 照样编过，
  只有消费者 `#include <rapidcsv.h>` 时才炸，所以本例由**消费测试**而不是
  `mcpp build` 兜底。
- 头文件包无平台差异，三平台共用同一个 url 与 sha256。
- **CN 镜像**：本次没有 `mcpp-res` 写权限（无 `GITCODE_TOKEN`，也没有
  `~/.config/gitcode-tool/config.json`），按 `docs/cn-mirror.md` 的回退路径写
  **纯字符串 url**（`compat.etl` / `compat.pybind11` / `compat.gsl` 同形）。
  日后补镜像只需把 `url` 改写成 `{ GLOBAL = …, CN = … }`，sha256 不变。

## 3. Feature 评估

无。库本身就是那一个头文件，`examples/`、`tests/`、`doc/` 里的东西不属于库；
而 header-only 的可选部分即使存在也无法门控（include 根是共享的，见
`docs/package-types.md`）。`Document` / `GetCell` / `GetColumn` 都是模板或
inline 定义，没有可编译的可选源。

## 4. 测试与验证

`tests/examples/rapidcsv` 用 `std::istringstream` 喂 CSV（不碰文件、不联网），断言：

- 表头列名与行列计数（`GetColumnName` / `GetRowCount` / `GetColumnCount`）；
- 按列名 + 行号取单元格、按索引取单元格（`LabelParams(0, -1)` 下不能走行名重载）；
- 取整列 `GetColumn<T>` 的元素与顺序；
- 带引号且内含逗号的字段解析成一个单元格（`pAutoQuote = true` 的实质断言）。

验证结论：

- `mcpp xpkg parse pkgs/c/compat.rapidcsv.lua` → `parse OK`。
- 清缓存后 `mcpp test -p rapidcsv` → `test result ok. 1 passed; 0 failed`。
- 构建缓存 `entry.json` 的输入留痕：`index = "compat"`、
  `name = "compat.rapidcsv"`，且 `include_dirs` 的 `decl:*/src` 解析成
  `<pkg>/rapidcsv-9.07/src`——同时证明 glob 映射正确、且解析用的是本 checkout
  的描述符而不是远端已发布索引。
- 本机缺 `lua5.4` 与 `bash`，`tests/check_*.lua` 与 `tests/run_members.sh`
  无法本地复现，交由 CI 的 `lint` 与 `workspace` 覆盖。
