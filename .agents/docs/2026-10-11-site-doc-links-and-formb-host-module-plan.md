# 站点文档死链 + Form B 模块包无法被 build.mcpp 使用 —— 分析与优化方案

日期:2026-10-11 · 状态:实施中(见文末「落地」) · 涉及仓:mcpp-index / openxlings/xpkgindex / mcpp-community/mcpp

---

## Part 1 · 站点文档链接 404

### 1.1 现象与复现

`https://mcpp.index.xlings.org/zh/docs/contributing/descriptor-examples.md` → 404。

本地复现(与 `site-check.yml` 同参数)+ 对产物做内部链接检查:

```bash
xpkgindex generate . --output /tmp/site --offline
python3 check_links.py /tmp/site      # 遍历 html 的 href/src,校验目标文件存在
```

结果:**9 个页面、23 条坏链**,全部集中在 docs 页面(包页面无坏链):

| 页面 (en / zh / zh-Hant 同构) | 坏链 |
|---|---|
| `docs/contributing/` | `descriptor-examples.md`、`openkal-compat.md`、`repository-and-schema.md`(仅 zh)、`../.agents/skills/add-mcpp-index-package/SKILL.md`、`zh/` / `../` |
| `docs/package-types/` | `descriptor-examples.md`、`repository-and-schema.md#包身份namespace-name`(仅 zh) |
| `docs/repository-and-schema/` | `openkal-compat.md`、`zh/repository-and-schema.md`(语言切换行未被剥离) |

### 1.2 根因

**R1(xpkgindex,主因)** —— `xpkgindex/guides.py::_rewrite_links` 只把指向 **已注册 docs entry** 的相对链接改写为
`docs/<slug>/`;其余相对链接**原样输出**,在 `/docs/<slug>/` 下解析即 404。
其 docstring 写的是 *"Point relative markdown links at the rendered guide, **or at the repo**"*,
但 "or at the repo" 分支从未实现(本地 0.2.0 与上游 main HEAD 一致)。

**R2(mcpp-index 配置)** —— `.xpkgindex.json` 的 `docs.entries` 漏注册:
- `descriptor-examples.md`(en+zh 都存在)—— 用户报告的那条;
- `openkal-compat.md`(en+zh 都存在);
- `repository-and-schema` 已注册但**没挂 zh 翻译**(`docs/zh/repository-and-schema.md` 存在)→
  zh 页面指向它的链接不在映射表里、en 页面的 `[简体中文](zh/…)` 语言行也剥不掉。

**R3(文档链到了"非文档"文件)** —— 这类链接在 GitHub 上是对的,站点上没有对应页面:
- `../.agents/skills/…/SKILL.md`、`../README.md#reference-examples` → 仓库文件;
- `zh/`、`../` → 目录;
- `descriptor-examples.md` 内 38 条 `../pkgs/x/*.lua` → 实际上站点有对应包页 `packages/<id>/`。
  (该页一旦注册,这 38 条会立刻成为新坏链 —— 所以 R2 的修复要和 R1 的修复配套。)

**R4(无守卫)** —— `site-check.yml` 只校验构建无 warning + 几个落地页存在,不查内部链接,所以死链能一路合入。

**R5(低优先级)** —— `.xpkgindex.json` `base_url = https://mcpplibs.github.io/mcpp-index`,而站点实际服务在
`mcpp.index.xlings.org`;线上 `sitemap.xml` / feed 全是旧域名。

### 1.3 方案

| # | 位置 | 改动 | 解决 |
|---|---|---|---|
| F1 | mcpp-index `.xpkgindex.json` | `docs.entries` 新增 `descriptor-examples`、`openkal-compat`(均带 `translations.zh`);`repository-and-schema` 补 `translations.zh` 与 zh/zh-Hant 标题 | R2,用户报告的 URL 直接恢复 |
| F2 | xpkgindex `guides.py` | 实现 docstring 承诺的回退:未命中 slug 的相对链接 →<br>① `pkgs/**/<id>.lua` → 站内包页 `packages/<id>/`(用构建期已有的 path→package 映射)<br>② 仓库内其它文件 → `{links.github}/blob/<branch>/<path>`,目录 → `/tree/`<br>③ 指向 docs 目录本身(`zh/`、`../`)→ docs landing<br>④ 目标在仓库里不存在 → 发 `warning:`(site-check 的 "No warnings" 自动拦截) | R1、R3 |
| F3 | mcpp-index `site-check.yml` | 新增一步内部链接检查(上面的脚本放到 `tools/site/check_links.py`),坏链即失败 | R4 |
| F4 | mcpp-index `.xpkgindex.json` | `base_url` 改为 `https://mcpp.index.xlings.org`(需确认它就是规范域名) | R5 |

**顺序建议**:F1 先单独合(当前整页 404,注册后即便 pkgs 链接暂时坏也是净改善)→ F2 提上游 PR →
F2 发布后再上 F3(否则 F3 会被 38 条 `.lua` 链接卡死;或 F3 先上并带临时 allowlist)。F4 随 F1 一起。

**不建议**:把文档里的相对链接改成绝对 GitHub URL —— 治标、量大(~80 处),且丢掉 `.lua → 包页` 这种站内更好的落点。

---

## Part 2 · `marzer.tomlplusplus` 不能在 `build.mcpp` 中使用

### 2.1 结论

**是的,目前用不了**。普通 `[dependencies]` 消费正常;但作为 `build.mcpp` 的 host module
(`[build-dependencies] … host-module = true` 后 `import tomlplusplus;`)会失败,而且是**两层**问题,
"用 generated_files 生成 mcpp.toml 再补 lib.path" 的思路**不可行**(见 2.3)。

### 2.2 复现与根因(mcpp 2026.10.5.2 实测)

```toml
# mcpp.toml
[build-dependencies.marzer]
tomlplusplus = { version = "3.4.0", host-module = true }
```
```cpp
// build.mcpp
import std; import tomlplusplus;
int main() { auto t = toml::parse("x = 42\n");
             std::println("mcpp:cxxflag=-DTOML_X={}", t["x"].value_or(0)); }
```

**L1 —— 找不到 lib root**
```
error: host module 'tomlplusplus': no interface unit at <verdir>/src/tomlplusplus.cppm
       A package offering build rules must have a lib root (src/<name>.cppm or [lib] path).
```
- `features.cpp::host_module_units` → `resolve_lib_root_path`:只认 `manifest.lib.path`,否则约定 `src/<tail>.cppm`。
- Form B 词表 `kKnownXpkgKeys`(`modules/manifest/src/xpkg.cppm`)**没有 `lib` 键**,描述符无从指定。
- 我们的 cppm 生成在 `mcpp_generated/tomlplusplus.cppm` → 永远落空。

**L2 —— host module 编译不带包的 include_dirs**(把 cppm 挪到 `src/` 后暴露)
```
error: host module 'tomlplusplus' compile failed:
src/tomlplusplus.cppm:9:10: fatal error: toml++/toml.hpp: No such file or directory
```
- `host_module_compile.cppm::provide_host_module` 的 argv = `compiler std -fmodules -c <iface> + base + useFlags`,
  **不含提供方的 `include_dirs` / `defines` / `cxxflags`**,也不含其依赖的公开 include。
- 附带:host module 只编 interface 这一个 TU,提供方的实现单元(.cpp)不会进 build program 的链接(header-only 无影响)。

### 2.3 为什么 "generated_files → mcpp.toml + lib.path" 不行

1. 描述符有 `mcpp = { … }`(Form B)时,mcpp 用内联 manifest,**根本不读** verdir 里的 mcpp.toml
   (`graph_load.cpp`:只有描述符**没有** `mcpp` 字段时才 glob `mcpp.toml` / `*/mcpp.toml`)。
2. 反过来用 Form A 指针(`mcpp = "<path>/mcpp.toml"`),就没有 `generated_files` 可用(它是 Form B 专属键)。
3. 即便 lib.path 设上,L2 依旧失败。

### 2.4 影响面

索引内 **7 个用 `generated_files` 合成 cppm 的模块包全部命中 L1**:
`boost-ext.ut`、`chriskohlhoff.asio`、`fmtlib.fmt`、`marzer.tomlplusplus`、`mpusz.mp-units`、`neargye.magic_enum`、`nlohmann.json`;
指向上游 cppm(`*/…` glob 路径)的 Form B 模块包同样不在 `src/<name>.cppm`。GMF 里 `#include <…>` 依赖
`include_dirs` 的,修了 L1 还会命中 L2。即:**目前 Form B 模块包基本都不能当 host module**,不是 toml++ 个例。

### 2.5 方案

**方案 B(推荐,根治,改 mcpp)**
- B1 lib root 推导:Form B 且 `lib.path` 为空、约定路径不存在时,从已列出的 `sources` 中取声明了 `modules[0]`
  (或与包名同名)的 interface unit 作为 lib root。无需新语法,索引零改动,7 个包一起受益。
  (备选:Form B 词表加 `lib = "<path>"` 键 —— 需要升 `min_mcpp` 并逐包改描述符,不如推导。)
- B2 host module 编译继承提供方的编译输入:`include_dirs`(含 `_after`)、`defines`、`cxxflags`、
  其依赖的公开 include;这些同时进入 host-module 缓存 key(`common_inputs`)。
- B3(可选)提供方的非 interface 源一并编成 host-module 对象并链接进 build program。
- 索引侧配套:新增成员 `tests/examples/build-mcpp-host-module`(build.mcpp `import tomlplusplus;` + `nlohmann.json`
  断言注入的宏),锁住行为;`index.toml` 的 `min_mcpp` 随 CI pin 一起抬。

**方案 A(索引侧临时绕过,已实测通过,仅在有人急用时采用)**
```lua
generated_files = {
    ["src/tomlplusplus.cppm"] = [==[        -- 放到约定 lib root,解决 L1
module;
#define TOML_UNDEF_MACROS 0
#if __has_include(<toml++/toml.hpp>)
#include <toml++/toml.hpp>
#else  // host-module 编译拿不到 include_dirs(L2),按相对路径兜底
#include "../tomlplusplus-3.4.0/include/toml++/toml.hpp"
#endif
...]==],
},
sources = { "src/tomlplusplus.cppm" },
```
实测:上面的 build.mcpp 成功运行,主程序打印 `42`;现有成员 `tests/examples/marzer.tomlplusplus` 仍 `1 passed`。
代价:wrap 目录名 `tomlplusplus-3.4.0` 写死在 cppm 里(GLOBAL 与 CN 两个 tarball 实测同名),每次升版本要跟着改;
偏离了"cppm 与上游逐字一致"的原则;只救 toml++ 一个包。B 落地后应回退。

**建议**:走 B(给 mcpp 提 issue/PR,B1+B2 一起),A 不默认合入。

---

### 2.6 讨论记录(2026-10-11 Review 后)

Review 结论:Part 1 顺序认可、`mcpp.index.xlings.org` 为规范域名;xpkgindex 直接提 PR 联调;
**lib root 是导出面的显式控制,不做推导**(B1 的"推导"选项作废)。

**Q:为什么普通依赖 OK,build-dependencies(host-module)不行?**

两条路径是**两套独立实现**,对"包导出什么、在什么上下文里编"的回答不同:

| | 普通 `[dependencies]` | `host-module = true` |
|---|---|---|
| 实现位置 | 完整构建图(modgraph 扫描 → ninja) | `build_program` 内的迷你编译器(`features.cpp::host_module_units` + `host_module_compile.cppm`) |
| 导出面 | 扫描 `sources`,每个 `export module X` 单元都可 import;Form B `modules = {…}` → `modules.exports_` 做声明校验 | lib root(`[lib] path` / `src/<name>.cppm`)**必须存在**(硬错误),再加 `sources` 中其余 interface 单元;不读 `exports_` |
| lib root 缺失 | 仅 warning(影响的是 `mcpp pack`,不影响消费) | `no interface unit at …` 直接失败 |
| 编译上下文 | 提供方自己的 `include_dirs` / `defines` / `cxxflags` / 依赖的公开 include | 单元**单独编译**:只有 build.mcpp 的 `base` + std/mcpp/其他 host module 的 BMI |

host-module 路径是为**规则包**(`mcpp.plugins`、`grpcgen`:纯模块、只 import std/mcpp)设计的,文档原话
"units are otherwise compiled alone, so they import std, mcpp and nothing else"。它从没覆盖
"在 build.mcpp 里用一个**普通第三方库**"这个场景 —— 这才是缺口本身。Cargo 的对应物是 build-dependencies
作为完整 crate 为 host 编译,而不是只编一个入口文件。

实测对照(同一个 Form A 包:`mcpp.toml` 含 `[lib] path` + `[build] include_dirs`,path 依赖):
- `[dependencies]` + `src/main.cpp` 里 `import tomlplusplus;` → 运行输出 `42` ✅
- `[build-dependencies] host-module = true` + build.mcpp 里 `import tomlplusplus;` →
  `toml++/toml.hpp: No such file or directory` ❌(L1 已过,卡 L2)

**Q:再生成一个 mcpp.toml,用 Form A 指针 `mcpp = "<path>/mcpp.toml"` 指过去,是否可行?**

不可行,两层原因:
1. **生成不出来**:指针形式下描述符没有 `mcpp = { … }` 表,也就没有 `generated_files`(它只存在于 Form B 表里);
   mcpp.toml 必须在 xlings 安装完就已在 payload 中 —— 只能重打 tarball(破坏"上游官方源、信任链无 fork",
   且 GLOBAL/CN 两份源会分叉)或写 install hook(把构建配置藏进安装副作用)。
   另外 Form B 表存在时 mcpp 不读 verdir 里的 mcpp.toml(`graph_load.cpp`),两者无法共存。
2. **生成出来也没用**:上面的实测已经是"有一个带 `[lib] path` 的真实 mcpp.toml"的情形,仍然卡在 L2。
   mcpp.toml 只能解决 L1,而 L1 用 Form B 加一个 `lib` 键就能显式解决,不必换形态。

**修订后的方案 B(mcpp 侧)**
- **B2(核心,先做)**:host-module 编译使用提供方自己的编译上下文 —— `include_dirs`(含 `_after`)、`defines`、
  `cxxflags`、依赖的公开 include —— 并纳入 host-module 缓存 key。本质是让 host-module 复用普通依赖的
  per-package 编译输入,只把工具链/标准换成 host 的。
- **B1'(显式,不推导)**:Form B 词表新增 `lib = "<path>"`,1:1 映射 `manifest.lib.path`
  (例:`lib = "mcpp_generated/tomlplusplus.cppm"`)。lib root 仍由作者显式控制导出面。
  需随 CI pin 抬 `min_mcpp`,再逐包给 7 个 generated-cppm 包补 `lib`。
- **B3(可选)**:提供方的非 interface 源编成 host 对象并链接进 build program(非 header-only 库需要)。
- 索引侧:B1'+B2 发布后新增 `tests/examples/build-mcpp-host-module` 成员锁行为。

### 2.7 讨论记录(第二轮)

Review 结论:mcpp 侧涉及一般 deps 与 build deps 的规范/架构设计,**不改 mcpp 代码**,只提详细 issue
(已提交:[mcpp-community/mcpp#797](https://github.com/mcpp-community/mcpp/issues/797))。2.6 中的 B2/B1'/B3 降级为 issue 里的候选方向。

**Q:toml++ 用 Form A `mcpp = "*/mcpp.toml"`,由 install hook 生成 mcpp.toml,可行吗?**

**可行,已实测**。2.6 中"生成不出来"的判断不成立:索引里已有 install hook 写文件的先例
(`compat.libffi`、`compat.cu*` 用 `io.writefile`),payload 里的 mcpp.toml 可以由 hook 产出。
但要点在于:**让它跑通的是相对 include,不是 Form A**。

实验描述符(`mcpp xpkg parse` → `form A … parse OK`):
```lua
mcpp = "*/mcpp.toml",          -- `*` 吸收 tomlplusplus-<v>/ 包装层
...
function install()
    -- 解包到 install_dir/tomlplusplus-<v>/,写入:
    --   mcpp.toml                       [lib] path = "src/modules/tomlplusplus.cppm"
    --                                   [build] include_dirs = ["include"]
    --   src/modules/tomlplusplus.cppm   上游 master 的同一路径;GMF 用 "../../include/toml++/toml.hpp"
end
```

| 用法 | `#include "../../include/toml++/toml.hpp"` | `#include <toml++/toml.hpp>`(上游原样) |
|---|---|---|
| build.mcpp host-module | ✅ 打印 42 | ❌ `toml++/toml.hpp: No such file`(L2) |
| 普通依赖(`tests/examples/marzer.tomlplusplus`) | ✅ 1 passed | ✅ |

结论:Form A 用显式的 `[lib] path` 解决了 L1,符合"lib root 显式控制导出面"。L2 只能靠相对 include 绕过,
直到 mcpp 侧给出设计。

**Form A + hook vs Form B + `src/` 路径(2.5 方案 A)**

| | Form A + install hook | Form B,生成到 `src/tomlplusplus.cppm` |
|---|---|---|
| lib root | `[lib] path` 显式 | 依赖约定路径,碰巧命中 |
| 相对 include | `../../include/…`,与版本无关(`*/mcpp.toml` 吸收包装层) | `../tomlplusplus-3.4.0/include/…`,版本写死 |
| 与上游演进 | cppm 已位于上游 master 路径 `src/modules/`;上游发版后删掉 hook 中写 cppm 的那步即可 | 需改路径与 sources |
| 静态校验 | `mcpp xpkg parse` 只看到 form A,mcpp.toml 内容在 Lua 字符串里,CI lint 校验不到 | lint 可完整校验 |
| 安装语义 | 构建配置变成安装副作用;hook 接管解包;改描述符要升 `revision` 触发重装 | mcpp 在构建期物化 generated_files |
| 一致性 | mcpp.toml 里的 version 与描述符重复(可用 `pkginfo.version()` 模板化) | 单一来源 |

建议:若 toml++ 需要先在 build.mcpp 中可用,走 **Form A + install hook**(导出面显式、版本无关、贴近上游);
用 `install()`,不用 `config()`(payload 内容属于安装,`config` 管环境注册)。
相对 include 在注释和 issue 中标为临时措施,mcpp 侧定案后恢复 `<toml++/toml.hpp>`。其余 6 个包暂不跟进。

## 落地(2026-10-11)

| 项 | 位置 | 内容 |
|---|---|---|
| mcpp issue | [mcpp#797](https://github.com/mcpp-community/mcpp/issues/797) | 一般 deps 与 build deps(host-module)在导出面与编译上下文上的分歧;设计问题 6 条,不预设实现。追加评论:同一包同时写在 `[dependencies]` 与 `[build-dependencies]`(host-module)时,合并后的边带 `hostModule`,被 build-time-only 剪枝误判为 target 不可达,项目侧 BMI 丢失 |
| xpkgindex | [openxlings/xpkgindex#10](https://github.com/openxlings/xpkgindex/pull/10) | F2:未命中的相对链接 → 包页 / 目录 README 的 guide / `{github}/blob\|tree/HEAD/…` / 不存在则 warning;另修译文 guide 链接以 `depth=3` 跳回默认语言的问题 |
| mcpp-index 站点 | `.xpkgindex.json` | F1 注册 `descriptor-examples`、`openkal-compat`(含 zh);`repository-and-schema` 挂 zh 译文;F4 `base_url` → `https://mcpp.index.xlings.org` |
| mcpp-index CI | `site-check.yml` + `tools/site/check_links.py` | F3 产物内部链接检查;xpkgindex **临时 pin** 到 #10 分支联调,#10 合入后改回默认分支 |
| toml++ | `pkgs/m/marzer.tomlplusplus.lua` | Form A + `install()` 写 `mcpp.toml`(`[lib] path`)与 `src/modules/tomlplusplus.cppm`(相对 include,mcpp#797);各平台 `revision = 1` 迫使旧 Form B payload 重装(实测迁移通过) |
| 测试 | `tests/examples/marzer.tomlplusplus-build-mcpp` | build.mcpp `import tomlplusplus;` 解析 `build-config.toml` → define → 断言;与项目侧测试分成两个成员(规避上面的双角色 bug) |

已知限制:`revision` 自 mcpp 2026.9.27.1 生效,而 `min_mcpp = 2026.9.18.3`;在两者之间的 mcpp 上,
若本机缓存着旧 Form B payload,会报 `mcpp pointer '*/mcpp.toml' did not match`,清掉该 payload 即可。
