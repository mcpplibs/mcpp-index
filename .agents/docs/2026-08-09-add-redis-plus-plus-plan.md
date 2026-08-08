# 新增 redis-plus-plus + hiredis 收录(compat 源码形态,双包)

**日期**: 2026-08-09
**本仓**: `mcpplibs/mcpp-index`
**目标**:
1. 收录 [`sewenew/redis-plus-plus`](https://github.com/sewenew/redis-plus-plus) **1.3.13** —— C++ Redis 客户端(同步 API),
   文件 `pkgs/c/compat.redis-plus-plus.lua`。
2. 收录其依赖 [`redis/hiredis`](https://github.com/redis/hiredis) **1.2.0** —— C 客户端,文件 `pkgs/c/compat.hiredis.lua`。
3. 形态:两者均为 **Form A 源码 compat**;redis-plus-plus 额外带一个 Shape-E 特征
   (`hiredis_features.h` 用 `generated_files` 快照)。
4. `tests/examples/redis-plus-plus/` 最小工程:离线迷你 RESP server 断言 PING/SET 全链路。

版本选型原则:**不追最新,选经典、泛用、下游依赖面最广的稳定版**。后续再按 xpm 追加多版本。

---

## 1. 版本选型(经典优先)

| 包 | 选定 | 依据 |
|---|---|---|
| hiredis | **1.2.0**(2023-06) | Debian 12 / Ubuntu 24.04 稳定版即 1.2.0;vcpkg 长期默认;conan 收录;含 `redisEnableKeepAliveWithInterval` |
| redis-plus-plus | **1.3.13**(2024-10) | 2025 快速迭代前的长期稳定版,vcpkg/conan 长期默认;API 与最新 1.3.15 一致;源码结构与 1.3.15 **逐字节一致**(`.cpp` 集合 diff 为空) |

SHA-256(均两次独立下载一致,无归档漂移):
- hiredis 1.2.0:`82ad632d31ee05da13b537c124f819eb88e18851d9cb0c30ae0552084811588c`
- redis-plus-plus 1.3.13:`678a61898ed72f0c692102c7ce103a1bcae1e6ff85a4ad03e6002c1ba8fe1e08`

## 2. 形态判定

- **hiredis → Form A(C 源码 compat)**:7 个 `.c`(上游 CMake `hiredis_sources` 原样)、头平铺、C99、无生成文件。
  唯一特殊点:上游安装布局是 `<inc>/hiredis/hiredis.h`,tarball 却是平铺 → 用 `generated_files` 写两个
  **薄包装头**(`mcpp_generated/include/hiredis/hiredis.h` = `#include <hiredis.h>`),先例:compat.opengl 的
  `GL/gl.h`、compat.glx-headers 的 `X11/Xpoll.h`。必须是**尖括号**形式(跳过包装头自身目录,落到真实头);
  `"..."` 形式会在包装目录里自包含。
- **redis-plus-plus → Form A(C++ 源码 compat)+ Shape-E 特征**:17 个同步 TU(上游 CMake 核心清单 +
  `patterns/redlock.cpp`);`async_*.cpp`/`event_loop.cpp`/`tls/…` 不编。CMake 唯一会生成的头
  `hiredis_features.h`(从 `.h.in` configure_file 产出,`connection.h` 会包含)用 `generated_files` 快照:
  ```lua
  ["mcpp_generated/sw/redis++/hiredis_features.h"] = "#define REDIS_PLUS_PLUS_HAS_redisEnableKeepAliveWithInterval\n"
  ```
  既非 header-only(需编译),也无 `.cppm`(非 Form C),上游无 mcpp 描述符(非 Form D)。

include 布局(镜像上游 target_include_directories):
- hiredis:`{ "*", "mcpp_generated/include" }`
- redis-plus-plus:`{ "*/src", "*/src/sw/redis++/cxx17", "*/src/sw/redis++/no_tls", "mcpp_generated" }`

## 3. 多版本友好性(已跨分水岭落地)

- hiredis 全部 1.x(1.2.0/1.3.0/1.4.1 已核实)源列表与布局一致 → 加版本 = xpm 加一行,`mcpp` 块不动。
- redis-plus-plus **1.3.6+** 源列表与结构一致(1.3.13 vs 1.3.15 diff 为空)→ 加 1.3.14/1.3.15 = xpm 加一行。
- **1.3.6 之前是分水岭,现已用「并集源列表」支持**:1.3.3 的同步核心是 15 个 TU(有 `shards.cpp`,缺
  `redis_uri.cpp` 与 `patterns/redlock.cpp`),且无 `hiredis_features.h`(生成的快照头只是不被包含)、
  `no_tls/tls.h` 是平铺的(`#include "tls.h"`,经 `*/src/sw/redis++/no_tls` include dir 命中)。因为 1.3.3 的
  TU 是 1.3.13 17-TU 列表的**严格子集**,同一份 `sources` 对两个版本都成立:1.3.3 上恰好两个 glob 零命中
  (警告而非错误)—— 与 compat.catch2 的「不相交并集」同款前提,这里更简单。复核新版本时须重查该子集关系
  (长期解:per-version build blocks,mcpp-community/mcpp#290)。

## 4. feature 评估

- **tls**:需 hiredis_ssl(`ssl.c`)+ OpenSSL;`compat.openssl` 仅 linux/macos,且 openssl 是 install()-驱动。
  v1 不做,留后续(可做成 hiredis `ssl` feature + redis-plus-plus `tls` feature)。
- **async**:需 libuv,索引中无此包,需先加 `compat.libuv`。v1 不做。
- **coro**:依赖 async。v1 不做。
- 负向口径:不启用时 async/tls 符号应缺失(链接期 undefined reference)。

## 5. CN 镜像

本机无 `gtc`、无 `mcpp-res` 写权限 → 按 docs/cn-mirror.md 回退,**url 用纯字符串上游 GitHub release**
(先例:compat.spdlog、tensorvia-cpu)。后续由维护者补 `{ GLOBAL, CN }` 表(sha 不变)。

## 6. 验证结论(已实测)

- 本地 `mcpp test -p redis-plus-plus`(1.3.13)与 `mcpp test -p redis-plus-plus-v133`(1.3.3)
  (2026.8.8.4 与 CI 钉版 2026.8.8.2 各跑一遍,后者冷沙箱):
  均为 `test result ok. 1 passed; 0 failed`,测试输出 `OK: PING -> PONG, SET -> OK` —— 同一描述符、同一测试,
  两个分水岭两侧的版本都构建、链接、运行通过。
- 独立 clang++ 冒烟(-std=c++17 与 c++23):17/17 TU 编译通过;静态链接 hiredis 后,
  离线 ping 连接被拒场景抛 `sw::redis::IoError`(完整覆盖 URI 解析 → hiredis 连接 → 错误映射)。
- lint 全绿:`mcpp xpkg parse`(本地与钉版)、`check_mirror_urls.lua`、`check_package_name.lua`、
  `check_cross_package_refs.lua`、`check_platform_version_parity.lua`。

## 7. 注意事项 / 风险

- Windows 腿本机无法实证:`-DNOMINMAX`(redis-plus-plus,上游 CMake 同款)、
  `-D_CRT_SECURE_NO_WARNINGS -DWIN32_LEAN_AND_MEAN -lws2_32 -lcrypt32`(hiredis,上游 CMake 同款)按先例写入,
  待 CI 三平台验证;测试用与 websocket 成员相同的跨平台 socket 抽象。
- 测试自建迷你 RESP server(PING→+PONG、SET→+OK),无需 redis-server 进程、无网络依赖;
  带 5s 接收超时防 CI 挂起。
- 纯字符串 url 的 GLOBAL 拉取在 CI 冷缓存下需要 GitHub 可达(与 spdlog 等成员相同条件)。
- 加 1.3.3 后,消费者侧有两个成员:`redis-plus-plus`(钉 1.3.13)与 `redis-plus-plus-v133`(钉 1.3.3),
  各自覆盖分水岭一侧;1.3.3 构建会产生两个零命中 glob 警告(预期,catch2 v2 同款)。
- **CI 修复(PR #188 实测)**:linux-default(gcc/vendored libstdc++)腿报
  `'uint16_t' does not name a type` —— 1.3.3 的 `utils.h` 用 `uint16_t` 却未包含 `<cstdint>`
  (1.3.6+ 才补)。包级 `cxxflags = { "-include", "cstdint" }` 修复包自身,v133 成员
  `[build] cxxflags` 修复测试 TU(先包含 redis++.h);对 1.3.13 无害。
