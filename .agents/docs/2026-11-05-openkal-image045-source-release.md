# 运行器 0.4.5 源码族登记

日期：2026-11-05。关联 mcpp-community/mcpp#885 与 openkal-image#25。

openkal-ld、openkal-run、openkal-tools、openkal-bind 同属一个上游源码归档；四份
描述符保留各自身份，新增同版 0.4.5，不复制内联配方或改写已发布条目。四份源
manifest 同为 0.4.5，run 的 Linux 条件依赖为已公开的 openkal-linux 0.24.2。
未增加 feature 或改变目标适用性。

GitHub 与 GitCode 的归档同为 185730 字节，SHA256 为
`8ab1b47375a08908fb391e33aa5b92d90808531a9aec500de56ff54f46142f98`。
标签位于合入提交 `e2cc112196760d7878d9dd00f1b777993782032b`。上游最终提交
`d7af0ff3bc076582862d8c85aa8df5aeabde468d` 的 CI 41969694650 五项成功，覆盖
两架构映像和四宿主原生运行，包括 okprof 环境与子进程状态控制。

两个测试成员从 0.4.3 更新到 0.4.5。以已发布 mcpp 2026.11.3.1、隔离 MCPP_HOME
及 checkout 索引运行 openkal-tools-tests 和 openkal-bind-tests，各 1 项通过。
后者实际调用映像的 twice(21) 和带回调的 twice_apply(plus_one, 20)，均为 42。
它们覆盖新工具族的构建时消费和新运行库的目标侧消费，不以旧版本缓存的执行
代替新源码构建。

本次登记源码包。hosted 预编译工具仍需与 Linux 0.24.2 一致的正式版本组；最终
引擎生产者及服务器联合 UX 门槛继续独立验收。已有 0.4.4 的 Windows 映射尾部
修正保留，0.4.5 同时包含 okprof 正确传递环境值与空值、覆盖配置和子进程退出
状态的修正。
