# mwrap / xxx-m 仓库许可规范

本规范适用于传统 C/C++ 头文件库的模块封装，包括仅依赖 `compat.*` 的薄封装和 vendor 上游源码的仓库。

- **封装层默认 Apache-2.0**。顶层 `LICENSE` 放标准 Apache License 2.0 全文，
  顶层 `NOTICE` 标明 `mcpp-community` contributors 以及封装贡献的适用范围。
- 封装作者/归属标签统一 `mcpp-community`。这不改变仓库组织、包 namespace 或模块身份：
  对外仍是 `mcpplibs.mwrap.<lib>`。
- 上游原始 README、LICENSE/COPYING 及适用的 NOTICE、第三方通知放在 `upstream/<lib>/`，
  保留原始字节、作者与版权声明，记录固定来源和校验值。使用 `compat.*` 供应源码也保留这些上游文档。
- 顶层 README 介绍封装，链接上游项目和保留文档；许可证链接/badge 表示封装 Apache-2.0，
  同时明确上游组件维持各自许可证。
- `mcpp.toml` 和新封装索引描述符声明 Apache-2.0；不将 `compat.*` 的上游许可证统一改掉。
  FFmpeg 仍受所选 LGPL/GPL 配置约束；MIT 上游继续 MIT。
- 改用封装规范时保留继承的封装版权/许可通知，历史封装材料与上游材料分别标识。
- 源码发布包含顶层 LICENSE/NOTICE 和上游文档；二进制部署继续携带全部必需通知并保留独立路径，
  不因文件移动到 upstream 而漏掉通知。
- 已有 tag、release、URL 和 hash 不覆盖；发布后的更正追加单个封装修订尾号并重新验证。

顶层 Apache-2.0 不替代上游许可，也不将上游版权归给封装作者。
参考 [Apache 官方应用说明](https://www.apache.org/licenses/LICENSE-2.0#apply)。

上游文档固定字节校验时，用 `.gitattributes` 的 `upstream/** -text` 禁用 Git 换行转换，
同时验证 Windows checkout 的文档 hash。

本轮首次发布中，用户已明确授权覆盖有问题的首发 tag/资产，不追加修订尾号，
七库版本均直接等于上游版本。更正提交通过门槛后再替换，同步全部下载区域、
校验值和真实安装验收；不沿用旧版本已验证的结论。

授权同版本覆盖时，也要刷新错误的已安装载荷：使用索引内部 `revision`，必要时设置
最低可用 `floor`。它们不进入 package version，不改变依赖命令和 tag；必须实测
已有旧缓存的构建刷新及运行结果，不能仅凭新 hash 宣告迁移成功。
