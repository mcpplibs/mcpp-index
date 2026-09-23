# CN 镜像闭环(gtc / gitcode / mcpp-res)

[English](../cn-mirror.md) | **简体中文**

为每个包配备国内下载镜像,可提升 `mcpp add/build` 在中国大陆的访问速度。其机制为:将 `xpm.<plat>.<ver>.url` 由
单一字符串改写为 `{ GLOBAL = "<上游>", CN = "<gitcode 镜像>" }`,解析优先级为 **GLOBAL 优先于 CN**(GLOBAL 仍为
默认,仅在其不可用时回退至 CN)。解析由 **xlings**(xim 引擎)完成,而非 mcpp 的 C++ parser,因此该机制由 spec
驱动并经由既有引擎生效。

- CN 布局:gitcode 组织 **`mcpp-res`**,每库一仓,资产挂载于按版本号打的 release 上。
- repo slug 取包名去除 `compat.` 或 `mcpplibs.` 前缀后的结果(`compat.eigen` 对应 `eigen`;`nlohmann` 类宜用
  `nlohmann-json` 以避免裸 `json` 的歧义)。
- CN 资产的公网 URL 约定为:
  `https://gitcode.com/mcpp-res/<slug>/releases/download/<ver>/<slug>-<ver>.<ext>`
- 库的维护者也可以在自己的 gitcode 账号下自行维护 CN 镜像
  (`https://gitcode.com/<owner>/<repo>/releases/download/<tag>/<file>`,如 `ZheFeng7110.boost`)。
  此时由维护者保证它与 GLOBAL 资产字节一致,即 `sha256` 相同。

## 无 `mcpp-res` 写权限时的回退

建立镜像需要 gitcode `mcpp-res` 组织的写权限(token)。在不具备该权限时,不应勉强构造镜像表:lint
(`check_mirror_urls.lua`)强制要求,一旦 `url` 写成表形式,其 `CN` 必须为 gitcode 的 release 资产
(`https://gitcode.com/<owner>/<repo>/releases/download/…`),
因此 `{ GLOBAL=上游, CN=上游 }` 会直接导致 lint 失败。正确的回退方式是采用纯字符串 url(仅填上游 release),
lint 对纯字符串 url 不施加镜像约束:

```lua
-- 回退:无 CN 镜像,GLOBAL 与 CN 均等价于上游 release(使用单一字符串即可)
["0.1.1"] = { url = "https://github.com/<owner>/<repo>/releases/download/v0.1.1/<repo>-0.1.1.tar.gz",
              sha256 = "…" },
```

- CN 用户将回退至上游源,访问较慢但功能不受影响。
- 既有先例:`pkgs/t/tensorvia-cpu.lua`(用户自有 mcpp 库,无 CN 镜像,三平台均使用上游单一字符串 url)。
- 后续在获得权限、或由维护者补充镜像后,可将该版本的 `url` 改写为 `{ GLOBAL=…, CN=… }` 表(sha256 保持不变)。

如需表达“GLOBAL 与 CN 均指向上游”,应采用上述单一字符串写法,而不应写成 `{ GLOBAL=x, CN=x }` 表(其无法通过
“CN 必须指向 gitcode”的 lint 检查)。

## gtc 工具

`gtc`(`tools/gtc`,亦位于 `~/.local/bin/gtc`,python 实现,基于 gitcode API v5)。Token 位于
`~/.config/gitcode-tool/config.json`,亦可经 `GITCODE_TOKEN` 或 `--token` 覆盖。当前登录用户为 `Sunrisepeak`。

```bash
gtc repo create  <owner>/<name> [--description …] [--private]   # owner==login 时走 /user/repos,否则走 /orgs/<owner>/repos;幂等(422 仅告警)
gtc repo push    <owner>/<name> <dir> [--branch main]
gtc release create  <owner>/<repo> --tag T [--name] [--body-file] [--target] [--prerelease]   # 幂等(tag 已存在则跳过)
gtc release upload  <owner>/<repo> --tag T <file…>              # 非幂等,上传前应先查询现有资产
gtc release publish <owner>/<repo> --tag T [--name] [--target] [--asset FILE]   # 等价于 create + upload
gtc pr create    <owner>/<repo> --title --head --base [--body-file]
```

`gtc` 不能创建 org;`mcpp-res` 已存在。如需新建 org,应调用 `POST /api/v5/orgs` 并同时提供 `name` 与 `path` 字段。

## 标准操作(以 slug=`eigen`、ver=`5.0.1` 为例)

```bash
# 0. 下载 GLOBAL 上游 tarball,计算 sha256(填入描述符三平台);重复计算两次以确认稳定
curl -L -fsS -o eigen-5.0.1.tar.gz "https://gitlab.com/libeigen/eigen/-/archive/5.0.1/eigen-5.0.1.tar.gz"
sha256sum eigen-5.0.1.tar.gz

# 1. 建仓(幂等)
gtc repo create mcpp-res/eigen --description "Eigen — CN mirror for mcpp-index"

# 2. 新仓尚无分支,须先推送一个 init commit,release 方可 target main
mkdir eigen-init && echo "# Eigen — CN mirror" > eigen-init/README.md
gtc repo push mcpp-res/eigen eigen-init --branch main

# 3. 发布 release 并上传资产(上传与 GLOBAL 相同的文件,以保证字节一致与 sha 相同)
gtc release publish mcpp-res/eigen --tag 5.0.1 --name "Eigen 5.0.1" --target main --asset eigen-5.0.1.tar.gz

# 4. 闭环校验:CN 返回 200,且与 GLOBAL 字节一致
CN="https://gitcode.com/mcpp-res/eigen/releases/download/5.0.1/eigen-5.0.1.tar.gz"
curl -fsSL -o cn.tar.gz -w 'CN http=%{http_code}\n' "$CN"
[ "$(sha256sum eigen-5.0.1.tar.gz|cut -d' ' -f1)" = "$(sha256sum cn.tar.gz|cut -d' ' -f1)" ] && echo "BYTE-IDENTICAL"
```

## 注意事项

- gitcode API 限流为 25 次/分钟/用户,调用间隔宜约 3.2 秒,遇 429 应退避重试。
- 同名 release 资产不可覆盖,误传后只能经网页删除,因此命名应一次确定(`<slug>-<ver>.<ext>`)。
- 新仓无分支:未先推送 init commit 时,release `--target main` 将失败。
- 内容过滤:部分库描述或仓名会被 gitcode 文本过滤拒绝,应改用中性措辞。
- 必须上传与 GLOBAL 相同的包:不应上传经改动的包,否则 CN 与 GLOBAL 不一致,且除 `mirror-cn-reachable` 外难以察觉。
- sha 漂移:GitLab 归档偶有重新打包导致 sha 变化,描述符的 sha 必须等于当前 GLOBAL 的实际字节(下载后即用,并重复
  计算两次)。
- xlings 按 sha256 全局去重:当 CN 与 GLOBAL 的 sha 相同时,本地“切换 CN 重新测试”会命中去重缓存,不会真正访问
  gitcode,因此校验 CN 应直接使用 `curl`(即上文第 4 步,亦为 CI `mirror-cn-reachable` 所执行)。

## CI 保障

`.github/workflows/validate.yml` 设有两道校验:

- `lint` 中的 `tests/check_mirror_urls.lua`:当 url 写成表时,GLOBAL 与 CN 均须存在,且 CN 必须指向 gitcode
  `mcpp-res` 镜像。
- `mirror-cn-reachable`:抽取全部 CN url 并逐个 `curl`,任一非 200 即失败。
