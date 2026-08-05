# 仓库结构、schema、CI 与关键文件

[English](../repository-and-schema.md) | **简体中文**

## 仓库布局

```
pkgs/<x>/<name>.lua          描述符。<x> 取完整包名首字母(compat.* → c,nlohmann.json → n,imgui → i)
mcpp.toml                    workspace 清单(members 列表)+ 根级 [indices] compat = { path = "." },
                             由成员继承(相对路径按 workspace 根解析,mcpp ≥ 0.0.97)
tests/examples/<member>/     每库测试工程(workspace 成员;<member> 为包名去前缀,模块包为
  mcpp.toml                  <name>-module)。消费 compat 的成员不写 [indices];消费其他
                             命名空间的成员写恰好一条(模块包用 default),该声明**替换**
                             根级表而非合并 —— 每个成员最多一个项目级索引 repo 是硬约束,
                             详见下文「索引重定向」。依赖按平台自门控
                             ([target.'cfg(...)'])
  tests/*.cpp                行为断言(独立 main,退出码非 0 即失败)
tests/check_mirror_urls.lua  lint:GLOBAL+CN 表完整性,以及 CN 指向 mcpp-res
tests/check_package_name.lua lint:身份形态(name 为单一原子段,层级归 namespace)
tests/list_cn_urls.lua       抽取 CN url,供 mirror-cn-reachable 使用
tests/run_members.sh         逐个运行 workspace 成员并计时。CI 与本地共用的入口,见下文「本地运行 workspace 成员」
tests/plan_shards.lua        依实测耗时将成员分配到各分片。由 `select` job 调用一次,`run_members.sh --shard`
                             亦调用同一脚本,故两处得到同一划分
tests/member-timings.tsv     plan_shards.lua 读取的逐成员实测墙钟。由 member-timings artifact 择时手工刷新,
                             而非每次运行自动回写
README.md                    索引说明与贡献入口(英文;中文版为 README.zh-CN.md)
.github/workflows/validate.yml   CI:lint / mirror-cn-reachable / select / workspace(全量时按平台分片)/ timings
.agents/docs/<date>-*.md     设计文档惯例
docs/                        贡献者参考文档(英文);docs/zh/ 为中文版(本目录)
tools/gtc                    gitcode CLI,见 cn-mirror.md
tools/compat-ffmpeg/ 等      compat 大包的描述符再生成流水线
.xpkgindex.json              站点配置(标题、链接、install 模板),通常无需改动
```

## 外部仓库与文档

- mcpp 本体:https://github.com/mcpp-community/mcpp(本地通常存在 clone:
  `/home/speak/workspace/github/mcpp-community/mcpp`)。`mcpp --version` 应与 CI 对齐;feature 与 glob 行为以
  `src/manifest.cppm`、`src/modgraph/scanner.cppm`、`src/build/prepare.cppm` 为准。
- xpkg 扩展 schema(权威):
  https://github.com/mcpp-community/mcpp/tree/main/docs/spec(对应本仓 `.xpkgindex.json` 的
  “mcpp ext” 链接)。V1 xpkg spec 见 `d2learn/xim-pkgindex` 的 `docs/V1/xpackage-spec.md`(url-template 约在第 172 行)。
- CN 镜像组织:gitcode `mcpp-res`。

## 描述符 schema 速查(Form B inline)

`package` 必填字段:`spec`、`namespace`、`name`、`description`、`licenses`、`repo`、`type="package"`、`xpm`、`mcpp`。

### 包身份:`(namespace, name)`

身份是二元组 —— **`namespace` 是点分层级路径,`name` 是单一原子段**。层级一律放 `namespace`(mcpp SPEC-001 §3.2,见 mcpp 仓的 [`docs/spec/package-identity.md`](https://github.com/mcpp-community/mcpp/blob/main/docs/spec/package-identity.md)):

```lua
namespace = "compat",        name = "zlib"      -- ✅
namespace = "mcpplibs.capi", name = "lua"       -- ✅ 多级命名空间
namespace = "mcpplibs",      name = "capi.lua"  -- ❌ 短名仍带点
```

最后一种被拒绝而非重新解读:`name` 里多出的点描述的是一个**没人声明过的命名空间**。mcpp 曾按最后一个点切分、静默造出 `(mcpplibs.capi, lua)`,0.0.106 起改为拒绝。

**兼容形态**:SPEC-001 之前发布的描述符把命名空间重复写在 `name` 里(`namespace="compat", name="compat.zlib"`),仍被接受 —— 前缀会先剥离再判定,wire key 是字面 `name`,两种写法都可安装。本仓已统一迁到短名形态。

**同短名不同命名空间可共存**:本仓现有三对 —— `compat:imgui` 与默认命名空间的 `imgui`、`compat:ffmpeg` 与 `ffmpeg`、`compat:lua` 与 `mcpplibs.capi:lua`。需要 xlings ≥ 0.4.69([xlings#381](https://github.com/openxlings/xlings/issues/381));`(namespace, name)` 唯一即可,`name` 本身不必唯一。

**文件名不参与解析**,可以任意。推荐 `<name>.lua` 或 `<namespace>.<name>.lua`(命中 mcpp 的快路径),但描述符按**声明的身份**被发现,叫别的名字也能解析。

`xpm.<linux|macosx|windows>.<裸版本>`:

- `url`:字符串,或 `{ GLOBAL=…, CN=… }` 表(本仓统一使用表形式)。
- `sha256`:必填,等于实际下载字节的摘要。

`mcpp`(常用键):

| 键 | 说明 |
|---|---|
| `language` | 通常为 `"c++23"` |
| `import_std` | 多数为 `false` |
| `c_standard` | C 源码:`"c99"` 或 `"c11"` |
| `modules` | module 库:`{ "x.y" }` |
| `include_dirs` | glob 列表,暴露给消费者的头目录 |
| `generated_files` | `{ ["相对路径"]="内容字符串" }`;mcpp ≥ 0.0.85 支持 Lua 长括号 `[==[…]==]` 多行字符串(推荐,可读可 review);转义单行串仍兼容 |
| `scan_overrides` | `{ ["glob"]={ provides={…}, imports={…} } }`;声明式扫描结果,命中文件跳过 M1 文本扫描(适用于带条件 import 守卫的上游模块单元,如 fmt 的 src/fmt.cc);构建期由编译器 P1689 输出自动对账,声明错误响亮失败(mcpp ≥ 0.0.85)|
| `sources` | glob 列表,编入 lib 的源码 |
| `cflags` / `cxxflags` / `ldflags` | 追加至对应规则 |
| `targets` | `{ ["name"]={ kind="lib"/"bin", main=…, soname=… } }` |
| `features` | `{ ["f"]={ sources={…}, defines={…}, deps={…}, implies={…}, requires={…} } }`;`defines` 只作用于**包自身**的 TU,消费端若要按 feature 分支须自行声明(见 `tests/examples/openssl`、`openblas` 的 `[target.'cfg(…)'.build] cxxflags`) |
| `deps` | `{ ["ns.name"]="ver" }`,扁平或点号式;feature 内同形 |

## 索引重定向(`[indices]`)

测试面要验证的是 **checkout 里的描述符**,而不是已发布的远程索引,这靠 `[indices]` 把命名空间重定向到本仓完成。

**根级继承**:workspace 根的 `mcpp.toml` 声明 `[indices] compat = { path = "." }`,相对路径按 **workspace 根**解析(mcpp ≥ 0.0.97,[mcpp#224](https://github.com/mcpp-community/mcpp/issues/224)),成员直接继承,不必各写一份 `path = "../../.."`。

**为什么只有一条,而且是 `compat`**:

- 索引表**按命名空间取键**。声明在一个没有任何依赖会请求的名字下,该索引根本不会被注册,解析会静默回落到已发布的远程索引 —— 此时被测的根本不是这个 checkout。
- 同一路径声明成多个命名空间确实都会注册,但会变成 N 个各自独立的项目 repo,之后任何查找都以 N 路歧义失败(物理上是同一个描述符;[mcpp#238](https://github.com/mcpp-community/mcpp/issues/238) / [xlings#374](https://github.com/openxlings/xlings/issues/374),在 xlings 0.4.69 后由静默 exit 1 变为响亮报错)。

所以根级只能承载一个命名空间,`compat` 是收益最大的那个(13 个成员 vs 其余合计 10 个)。

**成员级覆盖**:消费其他命名空间的成员自己声明 `[indices]`,该表**替换**继承来的根级表而非与之合并 —— 这正是每个成员只保留一个项目索引 repo 的机制。

**跨命名空间的取舍**:一个成员无法同时从本 checkout 解析两个命名空间。`tests/examples/asio-ssl` 有意利用了这一点:它不写成员级声明、继承根级 `compat`,于是 asio 本身走已发布的远程索引,而它的 `ssl` feature 依赖 `compat.openssl` 从本 checkout 解析 —— 这样**未合并的 compat 描述符可以通过一个已发布的消费者去验证**。反过来,本地 asio 描述符由 `tests/examples/asio-module` 覆盖。

**裸名依赖不适用**:重定向按**请求侧**的命名空间取键,而裸写的 `eigen = "5.0.1"` 是以默认命名空间发出的请求,即使最终落到 `compat` 描述符上,也会从远程索引解析。因此各成员一律使用限定写法;裸名解析本身由 mcpp 上游的 e2e 165 覆盖。

## index 版本契约(index.toml)

仓库根的 `index.toml` 声明 `[index] min_mcpp` —— 能解析本索引全部描述符的最老
mcpp 版本。契约随树旅行:`publish_mcpp_index.sh` 把它打进 artifact,git clone 与
`[indices] path =` 本地索引天然携带。mcpp ≥ 0.0.85 在打开索引树时检查,违反时报
`E0006` + 升级指引(调试逃生口 `MCPP_INDEX_FLOOR=ignore`)。

规则(由 lint 机械强制,非纪律):**floor 先行、新文法在后**——lint 用 CI pin 的
mcpp 跑 `xpkg parse`(strict:未知键即失败),所以需要更新文法/键的描述符在
`MCPP_VERSION` 与 `min_mcpp` 同步提升之前物理上合不进 main。本地复现:
`mcpp xpkg parse pkgs/<x>/<name>.lua`。

## CI 行为(validate.yml)

- 触发条件:PR(改动 `pkgs/**/*.lua`、`tests/**`、两份 README 之一、`mcpp.toml`、`index.toml` 或本 workflow)、
  push 至 main、nightly cron、手动触发。手动触发接受 `cache` 输入 —— `global`(默认)或 `local`。`local` 下
  每个成员均从零重建其全部依赖,从而把成员自身的开销与它从先前成员处继承到的部分隔离开;逐成员耗时应在此
  条件下比较,代价是显著更慢。
- `env.MCPP_VERSION` 为全部 job 使用的 mcpp 版本,本地验证应与之对齐。
- `lint`(始终运行):lua 语法 `loadfile(f,'t')`;须含 `spec=`/`name=`/`xpm=`;禁止前导 v 版本;执行
  `check_mirror_urls.lua`;执行 `check_package_name.lua`(身份形态,见上文「包身份」);再用 CI pin 的
  mcpp 对每个描述符跑 `mcpp xpkg parse`(strict,未知键即失败)。mcpp ≥ 0.0.106 的 `xpkg parse` 自身
  也强制身份形态,lua lint 因此是更早、更便宜的冗余闸门。
- `mirror-cn-reachable`(始终运行):逐个 `curl` CN url,均须返回 200。
- `select`:一次性决定整个计划,并以数据形式下发给各 runner。三个问题在此处而非各 runner 上回答 ——
  哪些成员要跑、每个平台分几片、哪些成员落在哪一片。
  - 选择性成员测试:PR 时由 `git diff` 将改动文件映射到受影响成员
    (`pkgs/<x>/<lib>.lua` → mcpp.toml 引用 `<lib>` 的成员;`tests/examples/<m>/**` → 成员 `<m>`)。
    可能影响全部成员的改动则选中整个 workspace:非 PR 事件、本 workflow 文件、workspace 清单的非成员
    部分、共享测试脚本。仅文档与仅 `tools/` 的改动不选中任何成员。
  - 分片仅用于全量运行,选择性运行为每平台一个 job。每平台的分片数取该平台**实测的 runner 并发度**
    (linux 3、macos 1、windows 2),而非取整数。墙钟为 `ceil(分片数 / 并发度) × 最慢分片`,故超出并发度
    的分片不减少任何工作量,却各自仍要付出 checkout、mcpp 下载与缓存恢复的固定开销;并发度为 1 时,
    对 macOS 分片严格慢于不分片。重新测量:
    `gh api repos/<owner>/<repo>/actions/runs/<id>/jobs --paginate --jq '[.jobs[]|select(.status=="in_progress")]|length'`
  - 分配本身由 `tests/plan_shards.lua` 给出:读取 `tests/member-timings.tsv`,按耗时降序依次放入当前负载
    最小的分片;负载接近时优先选择已含有共同依赖成员的分片 —— 分片之间不共享构建缓存,同一依赖落在两片
    上就要构建两次。无实测记录的成员按中位数计价,故新增成员既不被假定为零成本,也不被假定为极重。
    在真实 workspace 上与轮转法相比,linux 最慢分片由 4158s 降至 3706s,离散度由 47% 降至 15%。有一条
    任何划分都无法突破的下界:最慢的单个成员,`grpc-module` 为 1701s。
  - 规划在此 linux job 内进行,因为它需要 lua:windows 上既无 apt 亦无 brew,而 Homebrew 安装的是 `lua`
    而非 `lua5.4`。
- `workspace (<平台> <分片>/<总数>)`:整个测试面就是一个 mcpp workspace,**唯一的构建/运行通道**——
  没有任何 shell 驱动的例外(公开模块包 imgui/ffmpeg/opencv/tinyhttps 也是普通成员,经成员级
  `[indices] default = { path = "../../.." }` 从 checkout 解析,mcpp ≥ 0.0.97;消费 `compat` 的
  成员则继承根级声明,见上文「索引重定向」)。分片后缀仅在该平台确实被拆分时出现。
  - 成员经 `tests/run_members.sh` 运行,该脚本亦即本地入口。只存在于 CI 的耗时表无法在决定优化对象时被
    参考,而与 CI 不同的本地测量装置度量的是另一回事。
  - 包构建缓存取全局,即 mcpp 的默认值。该步骤此前设 `MCPP_BUILD_CACHE: local` 以规避 mcpp#344 —— 同一
    缓存条目可能持有两种对象布局;mcpp 2026.8.3.4 起缓存按包计键并纳入随消费方而变的布局,该理由已不成立。
    保留该旁路的代价是实际的:`local` 之下,59 个大量共享 abseil、protobuf、opencv 的成员会各自从零重建
    这些依赖,linux 全量运行达到 2h30m —— 超出超时上限,因而根本得不到结果。
  - `~/.mcpp/registry` 缓存携带工具链与已构建的 compat 包,重复运行增量很快。其 key 由独立步骤经
    `git ls-files -s` 就已跟踪的输入算出一次,而**不用** `hashFiles()`:后者按工作树 glob,而
    actions/cache 会在 post(save)步骤重新求值 key,届时 `tests/examples/*/target` 下的数 GB 构建产物
    也会被一并哈希 —— windows 上曾因此撞破 runner 的 120 秒模板求值上限。
  - 测试前刷新已发布索引。多数成员的全部依赖都从本 checkout 解析,但重定向了 `compat` 之外命名空间的成员
    会从已发布索引取其余部分,而该快照是所 pin 的 mcpp 发行版随附的那一份 —— 按构造即早于 main,且运行中
    没有任何其他环节会推进它。
- `timings`:将各分片的耗时 artifact 合并为每平台一份排名写入 run summary,并以 `member-timings` artifact
  发布合并后的表。否则分片会掩盖时间的去向 —— 每个 runner 只报告自己那一片。该表不自动提交:每次运行都
  改写自身的数字会让每份 diff 都充满噪声,并会悄悄吸收一次偶发的慢 runner。数字确实发生变化时,再据该
  artifact 刷新 `tests/member-timings.tsv`。

## 本地 lint 复现(等价于 CI lint job)

```bash
fail=0
for f in pkgs/*/*.lua; do
  lua5.4 -e "assert(loadfile('$f','t'))" >/dev/null 2>&1 || { echo "SYNTAX $f"; fail=1; }
  for n in 'spec *=' 'name *=' 'xpm *='; do grep -q "$n" "$f" || { echo "MISS $n $f"; fail=1; }; done
  grep -nqE '\["v[0-9]+|\["[^"]+"\][[:space:]]*=[[:space:]]*"v[0-9]+' "$f" && { echo "LEADING-V $f"; fail=1; }
  lua5.4 tests/check_mirror_urls.lua "$f" >/dev/null 2>&1 || { echo "MIRROR $f"; fail=1; }
  lua5.4 tests/check_package_name.lua "$f" || fail=1
done
[ $fail -eq 0 ] && echo "ALL LINT PASS"
```

## 本地运行 workspace 成员

`tests/run_members.sh` 即 CI 使用的入口,故本地运行度量的是同一对象、同一划分:

```bash
bash tests/run_members.sh --all                             # 全部成员
bash tests/run_members.sh opencv-module protobuf            # 指定成员
bash tests/run_members.sh --all --shard 1/3                 # 与 CI 的 linux 分片 1 完全一致
bash tests/run_members.sh --all --shard 0/2 --platform windows
bash tests/run_members.sh --all --cache local               # 绕过包构建缓存
```

分片下标自 0 起。`--shard` 委托给 `tests/plan_shards.lua`,即 `select` job 所调用的同一脚本,因此本地的第 N
片与 CI 的第 N 片持有相同成员;`PATH` 上没有 lua 时退回轮转法,并在输出中说明。`--platform` 选择读取
`tests/member-timings.tsv` 的哪一列,缺省为宿主平台。

`MCPP` 指定所用二进制(缺省为 `PATH` 上的 `mcpp`);`MCPP_TIMINGS` 指定追加 `<秒>\t<成员>\t<ok|FAIL>` 行的
文件。任一成员失败则退出码非零,而耗时表两种情况下均会打印 —— 值得诊断的运行恰恰就是耗时重要的那一次。

## 合并后

`publish-artifact.yml` 在合并至 `main` 后自动重新发布 mcpp-index artifact 并移动指针,无需发布新的 mcpp 版本。
在线浏览地址:https://mcpplibs.github.io/mcpp-index/

## 案例索引

| 形态 | 描述符 | example | 设计文档 / PR |
|---|---|---|---|
| C 源码 + feature | `pkgs/c/compat.cjson.lua`、`compat.gtest.lua` | `tests/examples/cjson/` | `.agents/docs/2026-06-27-add-cjson-and-nlohmann-json-plan.md` / #48 |
| C++23 module(generated wrapper) | `pkgs/n/nlohmann.json.lua` | `tests/examples/nlohmann.json/` | 同上 / #48 |
| header-only + source-gated feature | `pkgs/c/compat.eigen.lua` | `tests/examples/eigen/` | `.agents/docs/2026-06-28-add-eigen-plan.md` / #50 |
| header-only(纯头) | `pkgs/c/compat.opengl.lua`、`compat.khrplatform.lua` | — | `.agents/docs/2026-06-03-gl-runtime-packages-plan.md` |
| 外部构建系统(`install()` 驱动) | `pkgs/c/compat.openblas.lua`(Make)、`compat.openssl.lua`(Perl Configure + Make) | `tests/examples/openblas/`、`openssl/` | `docs/superpowers/specs/2026-07-26-openssl-asio-tls-design.md` / #124 |
| feature 拉起依赖(跨包) | `pkgs/c/chriskohlhoff.asio.lua` 的 `ssl` feature → `compat.openssl` | `tests/examples/asio-ssl/` | 同上 |
