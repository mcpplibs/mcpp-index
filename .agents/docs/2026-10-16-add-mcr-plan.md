# 新增 mcr 收录(Form A,模块库)

## 1. 来源与形态

- 收录 [yizhinailong/mcr](https://github.com/yizhinailong/mcr) 0.1.5,即上游最新 tag
  `v0.1.5`(在此之前为 `v0.1.3`、`v0.1.4`)。
- 形态为 **A**:上游仓自带 `mcpp.toml`(`[lib] path = "src/mcr.cppm"`)与
  `build.mcpp`,是完整的 mcpp 工程,而不是需要本仓以 `compat` 形态适配的第三方库。
  因此描述符只登记身份与下载地址,构建交给上游 `mcpp.toml`
  (`mcpp = "*/mcpp.toml"`,`gzj-creator.galay` / `marzer.tomlplusplus` 同形);
  `mcpp xpkg parse` 也自报 `form A — no mcpp segment`。
- **GLOBAL 必须是 tag 归档而不是 release 资产**:GitHub API 列出 3 个 release
  (`v0.1.3/4/5`),`assets` 全为空 —— 上游的 `version-tag.yml` 只打 tag 并触发 CI,
  不做 `mcpp pack`、不发布 tarball。归档
  `https://github.com/yizhinailong/mcr/archive/refs/tags/v0.1.5.tar.gz`
  SHA-256 `bd55e9dc19b620d7dfb89d20fd4a6b1ab9cf947fe872dc536dee53b4e869f8f5`
  (248 803 字节),两次下载一致;顶层包装层为 `mcr-0.1.5/`,由前导 `*/` 吞掉。
- License MIT(`LICENSE` 首行 `MIT License` / `Copyright (c) 2026 yizhinailong`)。
- 上游依赖 `compat.curl` 8.21.0 与 `nlohmann.json` 3.12.0(见其 `mcpp.lock`),两者
  本仓都已在索引中;`compat.openssl` 3.5.1 亦已存在(仅 linux/macosx 需要)。

## 2. 描述符设计

- 身份 `yizhinailong:mcr`,文件 `pkgs/y/yizhinailong.mcr.lua` —— 目录取**完整包名**
  `yizhinailong.mcr` 的首字母(`compat.rapidcsv` → `pkgs/c/`、`nlohmann.json` →
  `pkgs/n/` 同理,`docs/repository-and-schema.md` §Repository layout 的规则)。
- **命名空间由来**:mcr 自己的 `mcpp.toml` 只写 `name = "mcr"`,不带命名空间;索引侧
  身份由描述符给,取仓主 `yizhinailong`。这与既有先例一致 ——
  `tensorvia-cpu` 的上游同样无命名空间,描述符补 `namespace = "aimol"`;
  `galay` 补 `gzj-creator`。消费侧因此写作
  `[dependencies.yizhinailong] mcr = "0.1.5"`。
- 三平台共用同一份源码归档(纯源码,无平台差异),`xpm` 的 linux/macosx/windows
  三个块 url 与 sha256 全等。
- **平台差异不内联进描述符**:mcr 自己的 manifest 已按平台分支
  (`[target.linux|macosx.dependencies.compat] openssl` +
  `defines = ["MCR_SSL_CTX_OPENSSL"]`,Windows 走 Schannel)。Form A 的要点正是
  这一决定仍归上游所有,描述符不重复表达,也就不会与上游漂移。
- **CN 镜像**:本次没有 `mcpp-res` 写权限,按 `docs/cn-mirror.md` 的回退路径写
  **纯字符串 url**(`gzj-creator.galay` 同形)。`tests/check_mirror_urls.lua` 明确
  「plain url: fine」,只对表形 url 校验 GLOBAL/CN 成对。日后补镜像只需把 `url`
  改写成 `{ GLOBAL = …, CN = … }`,sha256 不变。

## 3. Feature 评估

无。feature 机制只对 **Form B**(本仓内联构建)有意义 —— 它门控的是描述符 `mcpp`
段里的 `sources`。Form A 的可选组件由上游 manifest 自己的 `features` 表达,消费者
直接写 `features = [...]` 即可,本仓无需(也无法)再门控一层。

## 4. 测试与验证

`tests/examples/mcr` 是公开 Form A 消费测试。成员级 `[indices]` 只声明
`yizhinailong`(成员级表**替换**而非合并仓根的 `compat`,这是硬约束:两个项目级
index repo 会让每次查找歧义,mcpp#238),因此 mcr 自带的 `compat.*` 依赖故意从
**已发布的远端索引**解析,新命名空间才解析到本 checkout。

测试刻意**离线**:活体 HTTP 往返需要本地服务与 curl 运行时,不适合放进索引成员。
断言覆盖离线可观测的全部面:

- `mcr::VERSION` / `VERSION_MAJOR|MINOR|PATCH` —— 该模块由 mcr **自己的
  `build.mcpp`** 从 `mcpp.toml` 生成,断言它等于 `0.1.5` 即证明构建钩子确实跑过、
  且生成模块进了 lib 目标(这是本次最值得盯的一环,见下);
- `mcr::status` 的五个 `constexpr` 分类器(`static_assert`)+ 具名状态码常量;
- `mcr::Url` 与 `mcr::Header` 的大小写无关查找(`CaseInsensitiveCompare`);
- `mcr::JsonBody` 构造期取紧凑序列化、与原值往返相等;
- `mcr::Response::TryJson()` 在成功时给出值、在非法 JSON 时给出 `JsonError`,而
  `Json()` 对同一输入抛 `mcr::Json::exception`。

## 5. 注意事项与风险

- **`build.mcpp` 是本次唯一非平凡风险点**。上游的构建钩子 `import mcpp;`、调用
  `mcpp::manifest_dir()` / `mcpp::out_dir()` / `mcpp::generated()`,并生成
  `mcr_version.cppm`(其 global module fragment 里 `#include <curl/curlver.h>`),
  因此构建程序需要 host 侧 `mcpp` 模块可达。既有 Form A 案例
  (`galay` / `tinyhttps` / `tensorvia-cpu`)都没有 `build.mcpp`,本条无先例可依;
  测试里对 `mcr::VERSION` 的断言就是为它设的探针。
- **上游只对 Windows 有 CI**。mcr 的 README 与 `.github/workflows/windows-ci.yml`
  只覆盖 Windows(LLVM 22.1.8 + MSVC);linux/macosx 的 OpenSSL 路径由上游 manifest
  声明但未被上游验证。描述符按上游 manifest 的意图声明三平台,若 linux/macos 腿在
  CI 暴露问题,退路是像 `gzj-creator.galay` 那样先只声明已验证的平台。
- 上游 Windows 配置使用 Schannel,`compat.openssl` 无 Windows 构建 —— 这一点上游
  manifest 已经处理好,本仓无需介入。

### 验证结论

- `mcpp xpkg parse pkgs/y/yizhinailong.mcr.lua` → `parse OK`(三平台 0.1.5,
  mcpp 自报 `form A`)。
- 冷验证 `mcpp test -p mcr`(清掉 `tests/examples/mcr/{target,.mcpp}`)结果见 commit/PR
  描述;关键中间证据:本地索引能解析并下载 —— 日志出现
  `Workspace building member 'mcr-tests'` 与 `Downloading yizhinailong.mcr v0.1.5`。
- 本机缺 `lua5.4` 与 `bash`,`tests/check_*.lua` 与 `tests/run_members.sh` 无法本地
  复现,交由 CI 的 `lint` 与 `workspace` 覆盖;本地已按 `check_mirror_urls.lua` /
  `check_cross_package_refs.lua` 的规则逐条核对(纯字符串 url 合法、无 `pkginfo.*`
  跨包引用)。本机 mcpp 为 2026.10.11.1,新于 CI pin 的 2026.10.1.2,故本地跑绿
  不等于 CI 跑绿。
