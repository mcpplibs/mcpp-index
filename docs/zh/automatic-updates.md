# 自动更新

[English](../automatic-updates.md) · [简体中文](automatic-updates.md)

[openxlings/xpkgindex-update](https://github.com/openxlings/xpkgindex-update)
每天 02:17 UTC（日本时间 11:17）检查已声明的包；GitHub 的定时任务可能延迟。
在默认分支手动运行[同一 workflow](../../.github/workflows/xpkgindex-update.yml)
也会执行完整更新流程，可用 `package` 输入限定一个 `namespace:name`。

workflow 下载新版本资源、计算 SHA256，每轮最多由 `github-actions[bot]` 创建三个新 PR，
随后显式触发各 PR 分支上的候选、消费者、站点和 openkal 检查。
候选测试必须真实构建、运行新版本并核对锁文件；普通消费测试同时覆盖其原来选择的版本。
升级失败会保留为 PR CI 的失败结果，交由维护者处理；不会自动合并。

## 为包声明自动更新

新增或维护包时，满足以下条件就应添加 `package.extensions.autoupdate`：

- 公共 GitHub release 或数字 tag 能确定包版本。
- 下载 URL 有稳定模板，已声明平台的资源均存在。
- 更新版本不需要修改构建配方、hook 或依赖策略。

```lua
extensions = {
    autoupdate = {
        tag = "v${version}",
        url = "https://github.com/acme/foo/archive/refs/tags/${tag}.tar.gz",
    },
},
```

`tag` 必须且只能包含一个 `${version}`。URL 可使用 `${tag}`、`${version}`、
`${version:dash}`，可全平台共用，也可按平台声明。
仅当 GLOBAL/CN 资源均已存在且字节一致时，才能声明镜像模板；工具不创建镜像。
即使历史版本有镜像，新版本也可以只声明 GitHub 来源。
URL 不能识别 GitHub 仓库时，回退使用 `package.repo`。

commit 快照、独立的源码/包版本映射、预发布版本、非 GitHub 来源，以及需要修改配方的升级，
应保留手工维护，在 PR 中说明原因，不要猜测更新规则。当前 xim adapter 不推进 `latest.ref`。

## 验证声明

使用 workflow 固定的已 review 工具提交（Python 3.11+）：

```sh
python -m xpkgindex_update inspect --package compat:foo
python -m xpkgindex_update check --package compat:foo --output plan.json
# 如发现新版本，在干净 worktree 中查看补丁：
python -m xpkgindex_update apply --plan plan.json --package compat:foo
```

`check` 必须能解析声明并给出真实上游结果；已经最新时保留该结果，不虚构候选版本。
新增版本须通过候选构建、运行和锁文件检查。上游未来改变 API 或源码布局时，仍可能需要人工适配。

只追加新版本；历史定义、URL、mirror、哈希与注释保留原样。
全平台资源相同时，新 URL/SHA256 前置定义一次，由各平台引用；不同资源分别保留。

## workflow 与认证

扫描和构建 job 只有读取权限。只有默认分支的 `propose` job 获取
`contents: write`、`pull-requests: write`、`actions: write`，
使用固定 CLI 消费原始扫描 artifact，不依赖本地用户 token 或长期 secret。
组织和仓库须允许 GitHub Actions 创建 PR。GitHub 的对应开关也允许审批，
但此 workflow 不会审批或合并 PR。

根据 [GitHub 的触发规则](https://docs.github.com/en/actions/how-tos/write-workflows/choose-when-workflows-run/trigger-a-workflow)，
`GITHUB_TOKEN` 无法提供无人值守的普通 PR 事件 CI，因此提 PR 后显式 dispatch 各 workflow。
消费者和 openkal 的 dispatch 会校验 PR 已打开、属于本仓 bot、head SHA 完全一致、
目标为默认分支且只修改一个描述符，再选择受影响成员。
不带 `update_pr` 的普通手动消费者验证仍为全量回归。

每包最多保留一个打开的更新 PR；已有人工 PR 修改同一描述符时，也不重复提案，继续使用普通 PR CI。
已关闭的候选不会重新打开。
下一轮能为已有 bot PR 补齐未成功发出的 CI dispatch，不重复提 PR；已有运行（包括失败）不会被静默重跑。
[中央配置](../../.github/xpkgindex-update.yml) 的 `max_prs` 限制每轮新 PR 数量。
更新分支上的 CI 不会递归创建 PR。

暂时保留 `wellwei/libmysqlclient` 源故障豁免：扫描错误仍记录，受影响消费者标为
**NOT TESTED**，不计为成功构建。

## 普通包 PR 的范围

一般只改描述符、消费测试和必要的 workspace 登记，符合条件就补上自动更新声明；
不适用时在 PR 中说明。站点会从描述符发现包，普通包 PR 不向两份根 README 追加包介绍、
示例或更新记录，也不修改站点配置。只有文档整理或用户明确要求时才调整 README。
