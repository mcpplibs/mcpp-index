---
name: add-mcpp-index-package
description: Use when adding a new third-party library/package to the mcpp-index repo — writing a descriptor, registering and running consumers, and opening a green PR. Includes traditional compat packages and mcpplibs.mwrap module adapters, source/runtime feature dependencies, runnable project templates, mirrors, and local plus CI verification.
---

# 向 mcpp-index 新增一个库(标准作业流程)

本文件定义将上游库收录进 [`mcpp-index`](https://github.com/mcpplibs/mcpp-index) 的标准流程。其产出包括:一个
`pkgs/<x>/<name>.lua` 描述符、可用时的 GitCode CN 镜像、一个位于 `tests/examples/` 的最小工程、适用时的自动更新声明,
以及一份设计文档。完整流程为:本地验证通过,提交 PR,CI 全部通过,由维护者合并。合并后,`publish-artifact.yml`
将自动重新发布 index artifact。

可直接参考的既有案例如下:

- `.agents/docs/2026-06-27-add-cjson-and-nlohmann-json-plan.md`(C 源码 compat 与模块库)。
- `.agents/docs/2026-06-28-add-eigen-plan.md`(header-only 库及 source-gated `blas` feature)。
- 既有 PR:#48(cjson 与 nlohmann.json)、#50(eigen)。

配套参考文档位于仓库 `docs/` 目录(英文为默认版本,中文版在 `docs/zh/`,内容对等),供人工与 agent 共同使用,
可按需查阅(下列链接指向中文版):

- [mwrap 规范](../../../docs/zh/mwrap.md) —— 为传统头文件库增加模块入口时读取；涵盖命名、上游版本尾号、目录、宏、feature 与必须运行的快捷模板。
- [docs/zh/package-types.md](../../../docs/zh/package-types.md) —— 四种库形态的描述符模板与样例路径。
- [docs/zh/cn-mirror.md](../../../docs/zh/cn-mirror.md) —— CN 镜像闭环,含无 `mcpp-res` 权限时的回退方案。
- [docs/zh/automatic-updates.md](../../../docs/zh/automatic-updates.md) —— 自动更新适用条件、声明、每日 bot PR 和候选 CI。
- [docs/zh/repository-and-schema.md](../../../docs/zh/repository-and-schema.md) —— 仓库结构、schema、CI 行为、关键文件与注意事项。

## 适用范围

本流程适用于将一个新库(或库的新版本)加入 mcpp-index。被收录的库有两种来源,均适用本流程:

- **(a) 第三方上游库**:其上游自身不提供 mcpp 支持(如 cJSON、Eigen、nlohmann),由本仓以 `compat` 形态适配。
- **(b) 基于 mcpp 开发的库**:其上游已是 mcpp 工程(自带 `mcpp.toml`,可由 `mcpp emit xpkg` 产出描述符,且具备自有
  release),仅需登记进索引(如 `mcpplibs.*`、`tensorvia-cpu`)。此类库通常采用 **Form A**,描述符只声明元数据与
  下载地址,无需内联构建信息。

本流程不适用于修改 mcpp 本体、修改 xlings 引擎或纯文档变更,上述内容不在本仓范围内。

## 总流程(十二步)

各步骤应按顺序执行,每一步的细节见对应参考文档。建议以 todo 跟踪进度。

1. **调研来源与形态**(决定模板,为最关键步骤)。
   - 首先判定来源:属于 (a) 第三方上游库,还是 (b) 基于 mcpp 开发的库。
     - 对 (b),形态已确定(Form A 模块库),版本与 release 由上游提供,因此本步骤较为简单:可直接采用上游
       `mcpp emit xpkg` 的描述符,或参照 `pkgs/t/tensorvia-cpu.lua` 编写;工作重心在镜像、登记与验证。
     - 对 (a),需按下文判定形态。
   - 确定上游仓库与**最新 tag/版本**(`git ls-remote --tags <repo>` 配合 `sort -V | tail`;须注意大版本跳跃,
     如 Eigen 由 3.4 跃迁至 5.x)。
   - 确认 License 与源码布局:下载 tarball,以 `tar -tzf` 查看顶层 wrap 目录与子目录,据此判定其属于
     **纯头文件 / C 源码 / 自带 `.cppm` 模块 / 含可选组件(可实现 feature)** 中的何种形态。
   - 计算 `sha256sum`,并**重复计算两次以确认稳定**。GitLab 等部分归档源会重新打包,导致 sha 漂移,进而使 CI
     经 GLOBAL 拉取时校验失败。
2. **确定形态并选择模板**:详见 [docs/zh/package-types.md](../../../docs/zh/package-types.md)。四类形态为:C 源码 compat、
   header-only、C++23 module(generated wrapper)、外部 Form-A 模块仓。
3. **建立 CN 镜像**:使用 `gtc` 在 gitcode `mcpp-res` 组织下建仓并发布 release,上传**与 GLOBAL 相同的 tarball**,
   以保证字节一致(sha 相同)。**在不具备 `mcpp-res` 写权限时**,不应构造镜像表,而应使用纯字符串形式
   `url = "<GLOBAL 上游 release>"`(lint 允许此形式,CN 用户将回退至上游源),镜像由维护者后续补充。详见
   [docs/zh/cn-mirror.md](../../../docs/zh/cn-mirror.md)。
4. **编写描述符**：传统包使用 `pkgs/<x>/<name>.lua`，`mcpplibs.mwrap` 包使用 `pkgs/mwrap/<完整包身份>.lua`。
   - 目录 `<x>` **取完整包名首字母**(`compat.eigen` 对应 `pkgs/c/`,`nlohmann.json` 对应 `pkgs/n/`),
     而非短名。mwrap 是明确的分类例外，文件平铺于 pkgs/mwrap；当前客户端 fallback 按声明身份扫描一级分类目录，不要求目录名为单字母。不增加 pkgs/mwrap/o 等额外层级，也不转换发布路径。
   - `xpm` 须覆盖三平台(linux/macosx/windows),每个版本包含 `url = { GLOBAL=…, CN=… }` 与 `sha256`。
   - 版本号采用**裸版本**(如 `"1.2.3"`),不含前导 `v`;下载 URL 中可保留上游的 `…/v1.2.3.tar.gz` 形式。
5. **识别可门控组件并实现 feature**（见下文）。核对 pinned mcpp 的 sources、defines、flags、implies、依赖转发和 feature-deps；不要沿用 0.0.68 的 sources-only 限制。
6. **编写测试工程(workspace 成员)**：mwrap 使用 `tests/mwrap/<member>/`，传统包使用 `tests/examples/<short>/`(`short` 为包名去除 `compat.`/`mcpplibs.`
   前缀后的结果;公开模块包用 `<name>-module`),并把它加进仓根 `mcpp.toml` 的 `[workspace].members`。
   - 包含 `mcpp.toml` 与 `tests/*.cpp`,后者须包含**可失败的有效断言**(`return ok ? 0 : 1`)。
   - 普通成员用一条 `[indices] <ns> = { path = "../../.." }` 将所消费命名空间重定向到 checkout。
     不把同一个完整索引路径注册成多个 namespace：当前 xlings 会将同一实体报为歧义。
     mwrap wrapper + compat SDK 的组合测试先运行 `python3 tests/prepare_mwrap_indices.py`，
     再将两条 namespace 路由指向 `tests/mwrap/.indices/<namespace>` 中字节不变的测试视图。
     `tests/run_members.sh` 自动准备这些视图；它们不提交、不发布，也不改变 pkgs/mwrap 的正式布局。
     正常发布布局另由 `tests/mwrap/check_installed_template.py` 在独立 MCPP_HOME 中使用单一完整索引验收。
   - 非全平台包按 `[target.'cfg(...)'.dependencies]` 门控依赖,测试源码在被门控掉的平台上
     编译为 no-op `main`(`#ifdef __linux__ … #else int main(){return 0;} #endif` 模式)。
   - 如需测试 feature,依赖采用长式声明 `name = { version = "…", features = ["…"] }`。
7. **本地验证**(使用与 CI 相同版本的 mcpp,详见下文“本地验证”)。必须实际执行 `mcpp test -p <member>` 并通过。
8. **接入自动更新**：按下节检查适用条件；符合条件的包必须添加 `extensions.autoupdate` 并验证。普通包 PR 不修改两份根 README，也不为新包修改站点配置；站点会自动发现描述符。
9. **撰写设计文档** `.agents/docs/<YYYY-MM-DD>-add-<lib>-plan.md`,记录形态判定、镜像、feature 评估、验证结论
   与注意事项。
10. **本地 lint**:在本地复现 `validate.yml` 的 lint 检查(语法、必填字段、无前导 v、镜像表校验)。详见
    [docs/zh/repository-and-schema.md](../../../docs/zh/repository-and-schema.md)。
11. **提交变更**:由 `main` 切出新分支,依次 commit、push、开 PR(不应直接推送 `main`)。PR 描述应载明形态、镜像、
    feature 与验证结论。
12. **确认 CI 通过**:`workspace (linux|macos|windows)` 的选择性成员测试应仅选中本库对应成员并通过
    (日志中 `selected members: <member>`),`lint`(含 `mcpp xpkg parse`)与 `mirror-cn-reachable`
    覆盖新增描述符与 CN url。合并由维护者执行。

## 自动更新与 PR 范围

- 对公共 GitHub release/数字 tag、稳定下载模板、无需改变构建配方的包，主动添加
  `package.extensions.autoupdate = { tag = "v${version}", url = "https://github.com/acme/foo/archive/refs/tags/${tag}.tar.gz" }`。
  实际 tag 不带 `v` 时使用 `${version}`；按真实上游规则填写，不照抄示例。
- 共享 URL 或按平台映射均可。新版本可以直接使用 GitHub，不要求自动 mirror；不要声明尚不存在的 CN 模板。
- commit 快照、独立源码/包版本映射、非 GitHub 来源、需要改配方的升级不强行接入；在 PR 中说明原因。
- 使用 workflow 固定的工具提交运行 `inspect --package <namespace:name>` 和
  `check --package <namespace:name> --output plan.json`；确实存在候选时，在干净 worktree 中 `apply` 并检查补丁。
  新增版本必须有真实构建、运行、锁文件验证；不能只用仍依赖旧版本的测试证明升级成功。
- 现有版本、URL、镜像、SHA256 和注释均保留；不迁移旧内联条目。相同新资源可以前置定义一次并由平台引用。
- 每日默认分支 Action 由 `github-actions[bot]` 开 PR，并显式 dispatch 候选、消费者、站点和 openkal CI。
  它不审批、不自动合并；普通 PR 和更新分支不会创建更多 PR。
- **一般包 PR 不改 README**：不要追加 “Additional example / 新增示例”、包列表、更新记录或 agent 提示词。
  用户明确要求整理文档或说明确有变化时才改入口文档。新增包通常也不改 `.xpkgindex.json`。
- 详细字段、例外和认证机制见 [自动更新文档](../../../docs/zh/automatic-updates.md)。

## feature 与模板

当前 manifest feature 支持 sources、defines、flags、implies、forward、requires/provides；可选依赖写在
`[feature-deps.<feature>]`，不将 deps 当成 manifest feature table 的有效成员。索引内联描述符的同类依赖
仍使用其 Lua schema 的 deps 字段。以 CI 固定 mcpp 的 parser 为准，先运行 `mcpp xpkg parse`。

feature 只增加能力，依赖图请求取并集。依赖声明支持 `default-features = false`；显式 features 仍激活，
其他边的默认请求不会被取消。根项目没有 `--no-default-features` CLI。可选大依赖使用命名 feature 门控。
后端命名沿用上游模块和正式供应者名，如 highgui-gtk3、videoio-ffmpeg、dnn-onnxruntime。
capability 选择不会自动移除别的 provider 对象，不能用它掩盖两份同符号运行库。

须验证启用后的真实行为，以及不启用时不编译/获取可选依赖。只看到符号常量或配置名称不证明后端可用。
Linux 本地执行；Windows/macOS 用原生 CI，缺少真实设备时明确报告 build-only/未执行项。

每个新建或重构的 -m 库至少提供一个默认 mcpp 快捷模板。实际执行 `mcpp new --template <完整包身份>@<版本>`，
再 build/run 生成工程。当前 `{{self.name}}` 是完整包选择器，应写 `"{{self.name}}"` 为单个依赖 key，
不能再放到另一层 namespace 表中；版本用 self.version，所需 feature 显式声明。
未发布候选可用隔离的已安装包 fixture，但必须先检查渲染身份和版本，再施加本地依赖覆盖。
参见 [mwrap 规范](../../../docs/zh/mwrap.md)。

## 本地验证(与 CI 同版本)

CI 所用 mcpp 版本由 `.github/workflows/validate.yml` 的 `env.MCPP_VERSION` 指定。本地验证应使用同一版本,而非本地
恰好安装的其它版本。

```bash
MV=$(grep -oP 'MCPP_VERSION:\s*"\K[0-9.]+' .github/workflows/validate.yml)
curl -L -fsS -o mcpp.tgz "https://github.com/mcpp-community/mcpp/releases/download/v$MV/mcpp-$MV-linux-x86_64.tar.gz"
tar -xzf mcpp.tgz
root="$PWD/mcpp-$MV-linux-x86_64"
mkdir -p ~/.mcpp/registry && cp -a "$root/registry/." ~/.mcpp/registry/
export MCPP="$root/bin/mcpp"
export MCPP_VENDORED_XLINGS="$root/registry/bin/xlings"
export MCPP_INDEX_MIRROR=GLOBAL          # CI 使用 GLOBAL;CN 由 mirror-cn-reachable 单独校验
rm -rf "tests/examples/<member>/target" "tests/examples/<member>/.mcpp"   # 冷验证:自干净状态走完整管线
"$MCPP" test -p <member>
```

- 输出末尾应为 `test result ok`(测试二进制退出码非 0 即失败)。
- 如需查看头文件或源码,解包结果位于 `tests/examples/<member>/.mcpp/.xlings/data/xpkgs/<idx>-x-<name>/<ver>/<wrap>/`。

## 常见错误与规避

| 错误做法 | 正确做法 |
|----------|----------|
| 将 mwrap 也强制放到首字母桶，或增加 pkgs/mwrap/o 层级 | mwrap 平铺于 pkgs/mwrap；传统包仍按完整包名首字母分桶 |
| 版本写作 `"v1.2.3"` | 采用裸版本 `"1.2.3"`,lint 会拦截前导 v |
| CN 镜像上传经改动的包(与 GLOBAL 不一致) | 上传与 GLOBAL 相同的 tarball,sha 一致,以维持 GLOBAL/CN 一致性 |
| 仅执行 `mcpp build` 而不 `run`,或示例缺少有效断言 | 实际运行,并以 `return ok ? 0 : 1` 断言 |
| 声称实现了 feature 却未做负向验证 | 验证默认构建确实不含该组件 |
| 未对齐 CI 的 mcpp 版本,本地通过而 CI 失败 | 读取 `MCPP_VERSION` 并使用同一版本 |
| 直接推送 `main` | 切出分支并提交 PR |
| 构建插件把模块命名为 `mcpp.rules.*`、`mcpp.plugins.*` 等保留名,或把命名空间取作 `rules`、`tools` 等 | 模块命名为 `mcpp.<自身命名空间>.*`;保留第二段属于 mcpp 项目(docs/zh/package-types.md §I),成员构建出现引擎的保留名警告即失败 |

完成前应遵循 `verification-before-completion`:在声明“通过/完成”之前,须给出真实命令输出作为证据。
