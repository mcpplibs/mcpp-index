# xpkgindex 通用化 + 包索引站整站重做 设计文档

- 日期:2026-08-06
- 涉及仓库:`openxlings/xpkgindex`(框架)、`mcpplibs/mcpp-index`(消费方 + mcpp 插件)
- 关联 issue:[mcpplibs/mcpp-index#170](https://github.com/mcpplibs/mcpp-index/issues/170) 包名与官网不符
- 线上站点:https://mcpplibs.github.io/mcpp-index/

---

## 1. 背景与已证实的问题

`xpkgindex` 是一个 Python 静态站生成器(jinja2 渲染 + lupa 沙箱执行 `.lua` 描述符),
`mcpp-index` 的 `deploy-site.yml` 通过 `pip install git+…` 拉取它并生成 GitHub Pages 站点。

以下问题均已在**线上 `packages.json` 与本地全量解析**上核实,不是推测。

### 1.1 namespace 全链路缺失(#170 的根因)

解析器已读到 `namespace`(`lua_parser.py` 把它写进 `Package.namespace`),但生成端全程只用 `pkg.name`:

| 位置 | 现状 | 后果 |
|---|---|---|
| `generator.py` `_make_install_command` / `_package_to_json_dict` | `template.format(name=pkg.name)` | `mcpp add json@3.12.0`(应为 `nlohmann.json`)—— #170 |
| `generator.py` 详情页写盘 | `_safe_filename(pkg.name)` | 页面路径按短名 |
| `templates/index.html` | 卡片标题与链接用短名 | 列表出现同名卡片 |

**页面覆盖是比 #170 更严重的后果。** 线上 `packages.json` 81 条中存在 5 组短名冲突:

```
ffmpeg × 3   (compat.ffmpeg / ffmpeg.ffmpeg / mcpplibs.ffmpeg)
imgui  × 3   (compat.imgui / ocornut.imgui / mcpplibs.imgui)
llamacpp × 2 (mcpplibs.llamacpp / ggml-org.llamacpp)
lua    × 2   (compat.lua / mcpplibs.capi.lua)
opencv × 2   (mcpplibs.opencv / opencv.opencv)
```

10 个包塌缩成 5 个 HTML 文件,后写入者覆盖先写入者,**另外 5 个包的详情页在线上不存在**,而首页仍然渲染
出指向同一 URL 的重复卡片。

### 1.2 详情页展示的是 xim 的字段模型,mcpp 的信息几乎没读

对 81 个描述符做全量解析后的字段覆盖率:

| 站点当前渲染的字段 | mcpp-index 覆盖率 |
|---|---|
| `categories` / `keywords` / `authors` / `homepage` / `docs` / `programs` / `archs` / `xvm_enable` | **0%** |
| `status` | 0%(页面上的 `dev` 全部是 model 默认值) |
| `licenses` | 99% |

| 描述符中真实存在、站点 **完全不展示** 的 | 覆盖率 |
|---|---|
| `mcpp` 扩展块 | 65/81(80%) |
| `mcpp.targets` / `sources` / `language` / `import_std` / `include_dirs` | 78% / 77% / 75% / 75% / 73% |
| `mcpp.deps` | 26%(21 个包) |
| `mcpp.features` | 14% |
| `mcpp.modules` | 9%(7 个包) |
| 每版本 `url` 的 `GLOBAL`/`CN` 双镜像 | 271 / 323 条 |
| 每版本 `sha256` | 323 / 323(100%) |

> 计数口径:323 是 **version × platform** 条目数;去重后为 **119 个(包, 版本)对**。
> 首页统计必须用 119,用 323 会把版本数虚报近 3 倍。

直接后果:

- 详情页的 Metadata 区块对 mcpp 的包基本为空,且硬渲染一行 **"XVM Managed: No"**(xim 概念,对 mcpp 无意义)。
- 首页分类过滤条永远不渲染,hero 显示 **"0 categories"**。
- **依赖区块对 26% 的包漏报**:解析器只读 `xpm.<platform>.deps`(全仓仅 5 处),而 21 个包的依赖声明在 `mcpp.deps`。
- C++ 用户最需要的信息(**这个包怎么接进我的代码**)一条都看不到。

### 1.3 安装命令推荐了错误的路径

`.xpkgindex.json` 现有:

```json
"install_commands": {
  "unix":    "curl -fsSL https://github.com/mcpp-community/mcpp/releases/latest/download/install.sh | bash",
  "windows": "iwr https://github.com/mcpp-community/mcpp/releases/latest/download/install.sh -useb | bash"
}
```

mcpp README 的权威写法是 **`xlings install mcpp -y` 为主**,裸脚本收进 `<details>`。且 Windows 那条是把
shell 脚本灌进 PowerShell,不可用(正确为 `irm https://d2learn.org/xlings-install.ps1.txt | iex`)。
配置里的 `mcpp-community/mcpp-index` 链接则已陈旧(GitHub 会重定向到 `mcpplibs/mcpp-index`,不是坏链但应更新)。

### 1.4 没有任何增长/活动/贡献者信息

站点不呈现索引的演进。而这些数据**已经存在于 git 历史中**,只是没被用:`pkgs/` 有 134 个提交、
从 2026-05-01 的 2 个包长到 2026-08-06 的 81 个包。

### 1.5 框架不通用

核心 model 里的 `xvm_enable` / `programs` / `archs` 是 xim 生态字段,而 mcpp 的语义无处安放。
框架与生态耦合,谁都服务不好。

---

## 2. 目标 / 非目标

### 目标

1. 修复 namespace 全链路(命令、URL、显示、搜索、去重),并让同类错误**在构建期报错而不是静默覆盖**。
2. 把 `xpkgindex` 改造成**通用静态包索引框架 + 生态插件**,核心不认识任何具体生态。
3. 整站重做:视觉基调 B3(代码优先)、首页三段式、详情页两栏。
4. 呈现索引演进:增长曲线、history line、贡献者(三类)。
5. 按**未来自建服务器**的形态定型数据契约与 URL,避免二次搬迁。
6. 贡献指南进站,且不与仓库现有文档分叉。

### 非目标

- 不引入 Node 构建工具链(Astro/Vite 等)。
- 本轮不做服务端;只保证契约与路由形态可被服务端原样接管。
- 不做用户账号、下载统计、评论等需要后端状态的功能。
- 不重写 lua 描述符格式,不改 `pkgs/**` 的 schema。

---

## 3. 架构

### 3.1 分层

```
描述符源 (.lua)  ──►  Reader  ──►  Model  ──►  序列化 (index.json)  ──►  Render (HTML)
                        │            │              ▲                        ▲
                        └── Plugin ──┴──────────────┘                        │
                            (identity / extensions / facets / blocks)  ──────┘
```

**四层单向依赖。** `index.json` 是层与层之间的正式契约,也是未来服务端 API 的响应体形态:
静态站是它的第一个消费者,不是唯一消费者。

### 3.2 核心 / 插件边界

| 归属 | 内容 |
|---|---|
| **核心**(与生态无关) | 描述符发现与读取(内置 xpkg-lua reader)· 身份/slug/URL 生成 · 版本-平台-镜像-校验和模型 · 搜索索引 · git 派生数据(增长曲线 / history line / 贡献者)· GitHub 补全与缓存 · guides(markdown 渲染)· 设计系统与深浅主题 · SEO/sitemap/feed · `index.json` 契约 · 插件加载与失败降级 |
| **插件**(生态特有) | 扩展块解析(`mcpp = {}`)· 仓库级配置(`mcpp.toml` / `index.toml`)· 规范名与安装命令拼法 · 分面轴 · 详情页 Block · 外部补全 · 关联用例代码 |

**对称性约束:** 如果 mcpp 的语义靠插件,xim 的语义也必须靠插件。核心现有的
`xvm_enable` / `programs` / `archs` 迁入 `xim` 插件。核心不得再出现任何生态专有字段。

### 3.3 URL 形态(现在就按服务端定型)

| 页面 | URL |
|---|---|
| 首页 | `/` |
| 包详情 | `/packages/<namespace>.<name>/` |
| 统计 | `/stats/` |
| 贡献者 | `/contributors/` |
| 指南 | `/guides/<slug>/`(多语言:`/guides/<slug>/zh/`) |
| 关于 | `/about/` |
| 数据 | `/index.json`、`/packages/<namespace>.<name>/index.json` |

不带 `.html` 扩展名(Pages 上落成目录 + `index.html`)。详情页本轮是**单页两栏**,但目录形态保证
将来加 `/versions/`、`/build/` 子页不破坏既有链接。

---

## 4. 核心框架规格

### 4.1 身份模型(修复 #170)

```python
@dataclass(frozen=True)
class Identity:
    namespace: str          # "nlohmann"、"" 表示无
    name: str               # "json"
    id: str                 # "nlohmann.json"  —— 规范 ID,namespace 为空时等于 name
    slug: str               # URL 片段,默认等于 id
    display: tuple[str,str] # ("nlohmann.", "json") 供模板弱化前缀渲染
```

- 默认策略:`id = f"{namespace}.{name}" if namespace else name`。
- 插件可通过 `identity()` 钩子覆盖(mcpp 插件确认此拼法;xim 插件返回 `None` 沿用默认,因为
  `xim-pkgindex` 24 个包**零个**带 namespace,行为不变)。
- 安装命令模板可用占位符:`{id}`、`{namespace}`、`{name}`、`{version}`。
  mcpp-index 配置为 `mcpp add {id}@{version}`。

**唯一性断言(硬失败):** 序列化前校验所有 `slug` 唯一。冲突时构建**报错退出**并列出冲突包与源文件路径。
1.1 那类静默覆盖不允许再次发生。

### 4.2 `index.json` 契约

```jsonc
{
  "schema": 1,
  "site": { "title": "…", "description": "…", "generated_at": "2026-08-06T…Z", "commit": "312e8b0" },
  "index": { "spec": "1", "min_client": "2026.8.3.3" },   // 由插件的 on_index 填充
  "facets": [ { "key": "surface", "label": "接入方式",
                "values": [ {"key":"module","label":"import","count":7}, … ] } ],
  "packages": [
    {
      "id": "nlohmann.json", "namespace": "nlohmann", "name": "json", "slug": "nlohmann.json",
      "description": "…", "licenses": ["MIT"], "repo": "https://github.com/nlohmann/json",
      "type": "package",
      "install": "mcpp add nlohmann.json@3.12.0",
      "latest": "3.12.0",
      "platforms": {
        "linux":  { "versions": ["3.12.0"], "latest": "3.12.0" }, …
      },
      "versions": [
        { "version": "3.12.0", "platforms": ["linux","windows","macosx"],
          "urls": { "GLOBAL": "https://github.com/…", "CN": "https://gitcode.com/…" },
          "sha256": "4b92eb0c…" }
      ],
      "deps": ["compat.zlib"], "required_by": ["mcpplibs.llmapi"],
      "people": { "upstream": {…}, "descriptor": [ {…} ] },
      "history": [ { "date": "2026-06-27", "kind": "added", "by": "sunrisepeak" } ],
      "facets": { "surface": "module" },
      "extensions": { "mcpp": { … } },      // 插件产出,原样透出
      "blocks": [ { "plugin":"mcpp", "kind":"code", "title":"用法", … } ]
    }
  ]
}
```

单包 JSON 与 `packages[]` 的元素同构,便于服务端逐包返回。
**向后兼容:** 保留 `/packages.json` 作为 schema 0 的别名产物一个发布周期,并在 About 页标注弃用。

### 4.3 插件系统

**加载。** `.xpkgindex.json`:

```json
"plugins": ["./.xpkgindex/plugins/mcpp.py"]
```

- 仓内 Python 文件为主(零发布流程,跟描述符一起演进)。
- 同时支持 pip `entry_points` 组 `xpkgindex.plugins`,供通用插件分发。
- 信任模型不变:构建本来就在索引仓自己的 workflow 里执行仓内的 `.lua` 描述符。

**钩子(API v1,六个)。**

```python
class Plugin:
    api_version = 1
    name = "mcpp"

    def on_index(self, ctx: IndexContext) -> None: ...
        # 仓库级:读 index.toml / mcpp.toml,写 ctx.index_meta

    def identity(self, raw: dict, path: str) -> Identity | None: ...
        # 规范 ID / slug / 安装命令片段;返回 None 表示沿用核心默认

    def on_package(self, draft: PackageDraft, raw: dict) -> None: ...
        # 写 draft.extensions["mcpp"]、draft.facets、draft.deps

    def facets(self) -> list[Facet]: ...
        # 声明分面轴及其取值标签(供列表页与搜索)

    def detail_blocks(self, pkg: Package) -> list[Block]: ...
        # 详情页结构化区块

    def enrich_remote(self, pkgs: list[Package], http: HttpCache) -> None: ...
        # 构建期外部补全;必须可跳过、可缓存
```

**Block 模型(插件不写 HTML)。**

```python
Block = {
  "kind": "kv" | "code" | "table" | "list" | "graph" | "callout",
  "title": str, "collapsed": bool, "data": {...},
  "template": str | None,   # 逃生舱:插件自带 Jinja 片段的相对路径
  "styles":   str | None,   # 逃生舱:scoped CSS
}
```

默认走核心的设计系统统一渲染,保证跨索引站视觉一致,且 Block 原样进 JSON;
**逃生舱必须显式声明** `template` / `styles`,核心以 `data-plugin="<name>"` 作用域包裹注入的 CSS,
避免污染全局。

**失败降级。** 插件任一钩子抛异常:记录 warning、跳过该插件此次产出、构建继续。
唯一例外是 `identity()` 返回重复 slug —— 走 4.1 的硬失败。
`api_version` 不匹配时拒绝加载并 warning。

### 4.4 git 派生数据

一次 `git log --reverse --name-status --find-renames --date=iso -- <pkgs_dir>` 遍历,回放 `A/D/R` 维护活跃集合,同时产出三样东西:

1. **增长曲线** —— 每日活跃包数时间序列。
2. **history line** —— 全局活动流与每包历史(added / bumped / removed)。
3. **贡献者** —— 每个描述符的作者集合与首次提交人。

**必须回放 A/D/R,不能只数 A。** 已验证:朴素累加 `--diff-filter=A` 得 86,实际 81 —— 差的 5 个来自删除与重命名。

**自校验断言:** 时间序列终值必须等于解析出的包数;不等则构建失败并打印差异清单。

**CI 要求:** `actions/checkout` 需 `fetch-depth: 0`。浅克隆时降级(跳过曲线与历史,warning),不使构建失败。

**身份归并。** git 里 `SPeak <speakshen@163.com>` / `sunrisepeak <speakshen@163.com>` /
`sunrisepeak <x.d2learn.org@gmail.com>` 是同一人(10 个 git 身份 → 约 8 人)。归并顺序:

1. GitHub commits API 的 `author.login`(权威,同时给头像);
2. `<id>+<login>@users.noreply.github.com` 邮箱解析(134 个提交中 13 个可解析);
3. 配置文件 `.xpkgindex/identities.json` 手工映射(兜底);
4. 都失败则按 `name <email>` 原样保留。

### 4.5 GitHub 补全

- 输入:每个包的 `repo` 字段(**100% 覆盖**)+ 配置的 ecosystem 仓库清单。
- **并非全部在 GitHub**:81 个包的 repo 分布为 GitHub 61、`gitlab.freedesktop.org` 15(X11 那批)、
  `gitlab.com` 1、`sourceware.org` 1。补全按主机分派,非 GitHub 主机当前不拉取(仅显示链接与 owner 名),
  不得静默把它们当作"无上游信息"。GitLab 主机日后可加同形接口。
- 拉取:上游 owner/org、头像、描述、star、主语言、topics、license、contributors。
- 用途:补 0% 覆盖的元数据(topics → 分类候选、description → 卡片补充),以及"上游致谢"段。
- **描述符里手写的字段永远优先**,拉取结果只填空。
- 结果写入**可提交的缓存文件** `.xpkgindex/cache/github.json`(带 `fetched_at` 与 ETag)。
- 无 token / 限流 / 离线:使用旧缓存,warning,不失败。缓存缺失则该区块不渲染。

### 4.6 guides(贡献指南页)

配置声明 markdown 源,核心渲染成站内页:

```json
"guides": {
  "nav_label": "贡献",
  "entries": [
    { "slug": "contributing",  "title": "如何新增一个包", "path": "docs/README.md",
      "translations": { "zh": "docs/zh/README.md" } },
    { "slug": "package-types", "title": "四种库形态",     "path": "docs/package-types.md",
      "translations": { "zh": "docs/zh/package-types.md" } },
    { "slug": "cn-mirror",     "title": "CN 镜像闭环",     "path": "docs/cn-mirror.md",
      "translations": { "zh": "docs/zh/cn-mirror.md" } },
    { "slug": "repository-and-schema", "title": "仓库结构与 schema", "path": "docs/repository-and-schema.md",
      "translations": { "zh": "docs/zh/repository-and-schema.md" } }
  ]
}
```

- **单一真源:** 渲染仓库既有文档,不在站点另写一份,避免分叉。mcpp-index 已有完整双语文档集。
- 渲染:标题锚点 + 右侧目录 + 代码块高亮 + 语言切换 + 相对链接改写(指向站内 guide 或 GitHub)。
- 入口:主导航、贡献者页顶部、包详情页"描述符源码"旁的"照着加一个包"。
- Markdown 依赖:`markdown-it-py`(纯 Python,无 Node)。

### 4.7 搜索

- 构建期产出精简索引(id / name / namespace / description / facets / 关键词),挂在 `/search-index.json`。
- 客户端:前缀 + 子串 + namespace 感知匹配(搜 `json` 必须命中 `nlohmann.json`;搜 `nlohmann` 列出其全部包)。
- 无 JS 时:列表页仍是完整静态 HTML,分面退化为普通链接页(`/?surface=module` 形态由构建期生成静态页)。
- 服务端化时,同一份查询接口换成 API,前端不改。

### 4.8 设计系统与主题

- CSS 自定义属性 token 化:颜色 / 间距 / 字号 / 圆角 / 边框 / 阴影,一处定义。
- 深浅双主题:`prefers-color-scheme` + 手动切换(`data-theme`),两个方向都要显式覆盖。
- 语义色(接入方式轴):`module`=紫、`header`=石墨、`tool`=琥珀。色不是唯一信息载体,同时带文字标签。
- 主题可由配置覆盖强调色。

### 4.9 SEO / 分发

- 每页 `<title>` / `description` / OG / Twitter card。
- `/sitemap.xml`、`/feed.xml`(新增包与版本更新的 Atom 流)。
- 旧 URL 兼容见 §7。

---

## 5. mcpp 插件规格

位置:`mcpp-index/.xpkgindex/plugins/mcpp.py`。

| 钩子 | 行为 |
|---|---|
| `on_index` | 读 `index.toml` → `spec` / `min_mcpp` / `latest_mcpp`;读根 `mcpp.toml` → workspace 成员清单,建立"包 → 用例工程"索引 |
| `identity` | `id = namespace + "." + name`;安装命令 `mcpp add {id}@{version}` |
| `on_package` | 解析 `mcpp` 字段。**注意它有两种形态**:table(Form B 内联,63 个)或 string(Form A,值是归档内 `mcpp.toml` 的 glob,如 `*/plugin/mcpp.toml`,2 个)。提取 modules / targets / sources / include_dirs / language / import_std / c_standard / features / generated_files / deps。合并 `mcpp.deps` 与 `xpm.<platform>.deps` 两处依赖来源(修复 1.2 的漏报) |
| `facets` | `surface` 轴:`module`(有 `modules`,7)/ `tool`(target kind 含 bin,或无 mcpp 块的工具环境包,18)/ `header`(有 include_dirs 无 modules,53)/ `other`(3)。`namespace` 轴(16 个,compat 56 / mcpplibs 10) |
| `detail_blocks` | ① 接入方式与接口代码(`import X;` / `#include <X>` / `$ tool`)② 用法示例(见下)③ 构建语义 kv ④ features 表 ⑤ sources / include_dirs / generated_files(默认折叠)⑥ 镜像与 sha256 ⑦ min mcpp 兼容性 |
| `enrich_remote` | 不使用(上游补全由核心统一做) |

**用法示例来源(本设计的关键增量):** 仓库自带 64 个 CI 跑绿的用例工程
(`tests/examples/*/`,各有 `mcpp.toml` + `tests/*.cpp`)。通过用例工程 `mcpp.toml` 的
`[dependencies.<ns>]` 反查回包,**36/81 个包能直接关联到至少一个用例**(其余多为 X11/GL 类传递依赖,
本就无独立用例)。详情页展示的是仓库里真在跑的代码,不是编造的片段:

```cpp
// tests/examples/nlohmann.json/tests/roundtrip.cpp
import std;
import nlohmann.json;
```

有用例的包在列表行与详情页标 `✓ 用例`。

---

## 6. xim 插件规格

位置:`xpkgindex` 仓内置示例插件(或 `xim-pkgindex` 自带)。

- 迁移核心现有的 `xvm_enable` / `programs` / `archs`,渲染为 kv Block。
- `identity` 返回 `None`(xim 包无 namespace,行为与今天一致)。
- 安装命令模板保持 `xlings install {name}@{version}`。
- 验收:`xim-pkgindex` 的 24 个包生成结果与重构前**逐字节等价**(golden 对比)。

---

## 7. 页面规格

### 7.1 首页(三段式)

```
[ nav: packages · stats · contributors · 贡献 · about · 搜索 ]
─────────────────────────────────────────────────────────────
段一 hero    统计(81 packages / 16 namespaces / 119 versions / 36 有用例)
             安装块(见 7.5)
─────────────────────────────────────────────────────────────
段二 脉搏带  [ 增长曲线 ]      [ history line ]
             贡献者头像带 → /contributors/
─────────────────────────────────────────────────────────────
段三 列表    分面:接入方式(import 7 / #include 53 / tool 18)× namespace(compat 56 …)
             B3 代码优先行(见 7.2)
```

窄屏:脉搏带上下堆叠。

### 7.2 列表行(B3 代码优先)

```
┌──────────────────────────────────────────────────────────┐
│ // nlohmann.json 3.12.0 — JSON for Modern C++            │  ← 注释行:包名/版本/描述
│ import nlohmann.json;                                    │  ← 主体:真正能写的那行代码
│ ─────────────────────────────────────────────────────    │
│ mcpp add nlohmann.json@3.12.0    MIT · 3 平台 · ✓ 用例   │  ← 脚:安装命令 + 事实
└──────────────────────────────────────────────────────────┘
```

三档接入方式对应三种主体行:`import X;` / `#include <X>` / `$ tool`,左侧语义色。
**B3 的已知代价是对新人不友好**(描述退为注释),缓解手段:注释行完整给出包名 + 版本 + 描述,
分面条常驻,搜索框在导航常驻。

### 7.3 详情页(两栏)

| 主栏(叙事) | 侧栏(速查) |
|---|---|
| 标题 `nlohmann.` + `json` + 接入方式徽章 | 最新版本 |
| 接口代码 + `mcpp add …` | License |
| 用法示例(✓ CI 绿) | 平台 |
| 构建语义 Block(mcpp 插件) | 依赖 / 被依赖 |
| 版本 × 平台 × 镜像 × sha256 | min mcpp |
| | 人:上游 / 描述符维护者 |
| | 链接:GitHub · `.lua` 源码 · 用例工程 |
| | 该包 history |

多版本包(grpc / opencv):版本表默认显示最近 5 个 + "展开全部";
`sources` / `include_dirs` / `generated_files` 默认折叠。窄屏侧栏折到底部。

### 7.4 stats / contributors

- `/stats/`:大图增长曲线(包数 / 版本条目数 / 命名空间数)+ 完整 history line + 按 namespace 的构成。
- `/contributors/` 三段(均为**核心能力**,不属于任何插件):
  1. **索引贡献者** —— 谁写了 `pkgs/` 里的描述符。归并后约 8 人,含提交数、贡献包数、参与的包。
  2. **上游致谢** —— 文案定稿:
     > **上游致谢**
     > 这些库由上游的作者与团队写就,索引只是把它们接入 mcpp。
     > 81 个包 ← 41 个上游项目
     >
     > 点开看这个上游项目在索引里被打成了哪几个包。

     计数口径:按 `repo` 的 owner 去重得 45 个,减去本生态自有的 4 个
     (`mcpplibs` 14 包 / `mcpp-community` / `openxlings` / `Sunrisepeak` 2 包)得 41。
     自有 owner 归入"生态贡献者"段,不进致谢段,避免自我致谢。该分界由配置的 `ecosystem.owners` 决定。
  3. **生态贡献者(并集)** —— 跨仓去重合并,仓库清单来自配置 `ecosystem`
     (`openxlings/xlings` 599★ / `mcpp-community/mcpp` 91★ / `mcpplibs/mcpp-index` / `mcpplibs/*`),
     每人标出参与了哪几个仓。

### 7.5 安装块(渐进披露)

主命令 + 折叠区,与 mcpp README 严格一致:

```
安装 mcpp
┌────────────────────────────────────────┐
│ xlings install mcpp -y          [copy] │   ← 主路径
└────────────────────────────────────────┘
▸ 还没有 xlings?
   Linux / macOS   curl -fsSL https://d2learn.org/xlings-install.sh | bash
   Windows · PS    irm https://d2learn.org/xlings-install.ps1.txt | iex
```

配置形态(通用):

```json
"install": {
  "primary": { "label": "安装 mcpp", "command": "xlings install mcpp -y" },
  "fallback": {
    "summary": "还没有 xlings?",
    "commands": [
      { "os": "Linux / macOS",   "command": "curl -fsSL https://d2learn.org/xlings-install.sh | bash" },
      { "os": "Windows · PowerShell", "command": "irm https://d2learn.org/xlings-install.ps1.txt | iex" }
    ]
  }
}
```

### 7.6 旧 URL 兼容

现有 `packages/<short>.html` 已被外部引用。为每个旧短名生成 `meta refresh` + `<link rel=canonical>` 的
alias 页,指向新 URL;短名冲突时(imgui / ffmpeg / lua / opencv / llamacpp)alias 页改为
**消歧页**,列出该短名下的全部包。alias 不进 sitemap。

---

## 8. mcpp-index 侧改动

1. `.xpkgindex.json` 重写:`plugins`、`install`(7.5)、`guides`(4.6)、`ecosystem`、修正陈旧链接。
2. 新增 `.xpkgindex/plugins/mcpp.py`(§5)。
3. `deploy-site.yml`:`fetch-depth: 0`;传入 `GITHUB_TOKEN` 供补全;缓存文件回写策略(拉取失败不中断)。
4. `.gitignore`:忽略 `.superpowers/`。
5. 描述符**不改**。0% 覆盖的元数据由构建期补全(§4.5),手写字段永远优先。

---

## 9. 错误处理与降级矩阵

| 情况 | 行为 |
|---|---|
| slug 冲突 | **构建失败**,列出冲突包与路径 |
| 曲线终值 ≠ 包数 | **构建失败**,打印差异清单 |
| 描述符解析失败 | warning + 跳过该包(现状保持),并在构建摘要中汇总条数 |
| 插件加载失败 / 钩子抛异常 | warning + 跳过该插件产出,构建继续 |
| 插件 `api_version` 不匹配 | 拒绝加载 + warning |
| GitHub 无 token / 限流 / 离线 | 用旧缓存;无缓存则不渲染相关区块;不失败 |
| 浅克隆(无完整 git 历史) | 跳过曲线 / history / 贡献者,warning;不失败 |
| guide markdown 缺失 | 跳过该条目 + warning |

原则:**数据正确性问题硬失败,外部依赖问题软降级。**

---

## 10. 测试策略

`xpkgindex` 当前**零测试**,这正是 1.1 的 bug 能活到线上的原因。

1. **身份单测**:`(namespace, name)` → `id` / `slug` / 安装命令,覆盖有无 namespace、多段 namespace(`mcpplibs.capi`)。
2. **唯一性回归**:构造 `compat.imgui` / `ocornut.imgui` / `mcpplibs.imgui` 三包,断言生成三个不同页面。
3. **曲线自校验**:合成 git 历史(含删除与重命名),断言终值等于包数。
4. **插件契约**:假插件覆盖全部六个钩子;抛异常的插件不使构建失败。
5. **golden 站点**:对 `xim-pkgindex` 24 个包生成结果做黄金文件对比(§6 等价性)。
6. **降级路径**:无 token、浅克隆、缺 guide 各跑一次,断言产物仍完整。
7. **契约快照**:`index.json` schema 快照测试,字段增删必须显式改基线。

---

## 11. 分期

| 阶段 | 内容 | 产出 |
|---|---|---|
| **P1 修正性** | 身份模型 + 唯一性断言 + `mcpp.deps` 合并 + 安装块修正 + 旧 URL alias + 上述 1/2 号测试 | **#170 关闭**,5 个丢失的详情页回来 |
| **P2 框架化** | 四层拆分 + `index.json` 契约 + 插件系统 + mcpp/xim 插件 + golden 测试 | 通用框架成型,生态字段全部出核心 |
| **P3 站点重做** | 设计系统 + 首页三段式 + B3 列表 + 两栏详情 + 搜索 + SEO | 视觉与信息架构落地 |
| **P4 演进数据** | git 派生数据 + GitHub 补全 + stats / contributors / guides 页 | 曲线、history line、三类贡献者、指南页 |

P1 可独立发布,不必等待后续阶段。

---

## 12. 风险与未决

| 项 | 说明 | 处置 |
|---|---|---|
| B3 对新人不友好 | 描述退为注释行 | 7.2 的缓解手段;上线后观察,必要时给列表加"详细/紧凑"切换 |
| GitHub API 限流 | 未认证 60 次/时 | CI 用 `GITHUB_TOKEN`;缓存可提交;软降级 |
| `fetch-depth: 0` 成本 | 全量历史克隆 | 当前仓体量可忽略;历史增大后可改用 `--filter=blob:none` |
| 上游 owner ≠ 真实作者 | 镜像仓 / 组织仓 | 文案已按"作者与团队"表述;支持描述符手工覆盖 |
| 页面数增长 | alias + guides 多语言 | 远低于 Pages 1 GB 限制 |
| 插件逃生舱滥用 | 各站视觉分叉 | 逃生舱须显式声明;CSS 作用域隔离;文档中标注为例外路径 |

---

## 13. 设计决策记录

| 决策 | 选择 | 理由 |
|---|---|---|
| 构建架构 | Python 单仓静态多页 | Pages 无服务端/无重写规则;SPA 深链对爬虫与分享不可见;避免双工具链 |
| 演进路径 | 数据即 API + 服务端形态 URL | 未来自建服务器时零改链接、前端不重写 |
| 缺失元数据 | 构建期 GitHub 补全 + 描述符可覆盖 | `repo` 100% 覆盖;不必人工回填 81 个描述符 |
| 插件能力 | 结构化 Block + 显式模板逃生舱 | 视觉一致性默认成立,极端定制仍有出口 |
| 视觉基调 | B3 代码优先 | 与"模块/接入方式"主题一致;仓库自带真实用例可支撑 |
| 首页布局 | C 三段式 | 曲线与 history line 都有足够宽度可读 |
| 详情页 | B 两栏 | 事实速查恒定位置;单页保持可加子页 |
| 上游段文案 | 致谢型 | 归属清晰:库属于上游,索引只做接入 |
