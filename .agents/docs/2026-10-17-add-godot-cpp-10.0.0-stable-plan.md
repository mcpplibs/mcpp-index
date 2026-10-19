# godot-cpp 走向多 API:repack.sh 支持 10.0.0-stable(4.7),并修两处不可复现

日期:2026-10-17 · 承接 [2026-08-04-add-godot-cpp-10.0.0-rc1.md](2026-08-04-add-godot-cpp-10.0.0-rc1.md)(4.6,PR #145)与
[2026-08-04-add-godot-cpp-plan.md](2026-08-04-add-godot-cpp-plan.md)(4.5.0,PR #143)

## 1. 上游变动:一个 tag 不再等于一个引擎

`10.0.0-stable`(2026-09-15)的 `gdextension/` **不再有单一的 `extension_api.json`**,改为每个引擎小版本一份:

```
gdextension/extension_api-4-3.json  …  extension_api-4-7.json   gdextension_interface.json
```

选哪份由构建方决定,上游自己三个入口是一致的:scons `api_version=`(`Makefile` 与 `test/SConstruct` 都是 `4.7`)、
cmake `GODOTCPP_DEFAULT_API_VERSION`(`CMakeLists.txt` = `"4.7"`)、`tools/godotcpp.py::supported_api_versions`
(`4.3 … 4.7`)。即 **10.0.0-stable 默认 = Godot 4.7**,同仓的 4.3–4.6 JSON 是给仍要老引擎的消费者的。

| 索引版本 | 上游 tag | 绑定引擎 |
|---|---|---|
| `4.5.0` | `godot-4.5-stable` | Godot 4.5 |
| `10.0.0-rc1` | `10.0.0-rc1` | Godot 4.6 |
| `10.0.0-stable` | `10.0.0-stable` | **Godot 4.7** |

因此「索引版本 → 引擎」这层映射在 10.x 里不能再靠 tag 名推断,得看生成时喂了哪份 API JSON(`repack.sh` 现在会打印)。

## 2. repack.sh:三处修改

### (a) 选 API JSON(否则 4.7 根本造不出来)

旧脚本硬编码 `gdextension/extension_api.json`,在 10.0.0-stable 上直接 `FileNotFoundError`。现在按**这个 tag 自己的
声明**解析,而不是按 tag 名或硬编码版本:

1. 存在 `gdextension/extension_api.json` → 用它(4.5.0 / 10.0.0-rc1 行为逐字节不变);
2. 否则取 `extension_api-<maj>-<min>.json`:显式 `ENGINE_API` 参数优先(给「同 tag 要烤老引擎」留出口),
   其次解析 `CMakeLists.txt` 的 `GODOTCPP_DEFAULT_API_VERSION`(即上游默认),最后回退到最高版本。

`generate_bindings()` 仍走原入口:无 build profile 时它等价于上游 scons 路径(`generate_trimmed_api("")` 原样返回
api,`generate_template_get_node` 默认 True),不引入第二条生成链路。hooks 保持不传(上游默认 None)。

### (b) 校验步骤被 locale 左右(中英文机器行为不同)

「上游树未被改动」的判定解析的是 `diff` 的 `Only in <dir>: gen` 文本。中文 locale 下这行是
`只在 <dir> 中存在:gen`,过滤不掉 → **任何归档都被判为「上游文件被改动」并拒绝**,与内容无关。改为 `LC_ALL=C diff`,
让被解析的语言固定,而不是去匹配一个翻译。

### (c) 归档哈希取决于打包者的 umask(不可复现)

`gen/` 是本脚本**现场生成**的,其权限位来自本进程 umask(`0o777&~umask` 目录 / `0o666&~umask` 文件),并原样进包:

| | 上游文件(`tar -x` 解包) | `gen/`(生成) | 结果 |
|---|---|---|---|
| 旧脚本 + umask 022 | 755/644(被 umask 削掉) | 755/644 | sha 与已发布不符 |
| 旧脚本 + umask 002 | 775/664 | 775/664 | 恰好是已发布的那份 |
| **本 PR** | 775/664(`tar -xzpf` 保留上游模式) | 775/664(`umask 002`) | 与已发布一致,且与打包者 umask 无关 |

即:同一份内容,umask 不同 → sha 不同。已发布的两个归档是 **002** 的写法,把 umask 与 `-p` 都钉死,既让它们可复现,
也不再让「谁能复现」取决于谁的 shell 配置。**不改变已发布归档的字节**,故索引里现有 sha 无需改动。

## 3. 验证(本机实测)

```bash
tools/godot-cpp/repack.sh godot-4.5-stable 4.5.0            /tmp/out
tools/godot-cpp/repack.sh 10.0.0-rc1       10.0.0-rc1        /tmp/out
tools/godot-cpp/repack.sh 10.0.0-stable    10.0.0-stable    /tmp/out
tools/godot-cpp/repack.sh 10.0.0-stable    10.0.0-stable    /tmp/out2   # 确定性
```

| tag | 产出 sha256 | 与索引已记录对比 |
|---|---|---|
| `godot-4.5-stable` | `b0c36e77f02c4181352cdd7547b209b93a833be1ad6197f8c650d92987221a00` | **一致**(未改字节) |
| `10.0.0-rc1` | `aaafbf50d4b8469d610fdb2eb76c6f58d758dbabbc6b013f60464d99b20ceb6e` | **一致**(未改字节) |
| `10.0.0-stable` | `66aaafb642e7a390482dc381818640b1d0e583da2ef0cc9709214bcd13b68264` | 新增,两次独立运行一致 |

新归档的绑定目标经包内文件核对:`gen/include/godot_cpp/core/version.hpp` = `4.7.0 stable`;生成 1052 个类头
(对比 rc1 的 ~1022 TU),上游树逐文件字节一致(`gen/` 是唯一新增)。

## 4. 本 PR 不含的部分(需要维护者权限)

索引版本条目只有在**归档可下载**之后才成立,CI 会真的去装它,所以下列步骤不在本 PR,交由维护者在合适时机补:

1. **发布归档**:把 `godot-cpp-10.0.0-stable.tar.gz` 发到 `github.com/xlings-res/godot-cpp`(GLOBAL)与
   `gitcode.com/mcpp-res/godot-cpp`(CN),tag `10.0.0-stable`——本仓贡献者对该组织无写权限。
2. **模块包 tag**:`mcpplibs/godot-cpp-m` 目前有 `v4.5.0` / `v10.0.0-rc1`,需要 `v10.0.0-stable`
   (bump 自身 version 与 `compat.godot-cpp` 依赖,并对 4.7 头文件复核 `hashfuncs.hpp` shim)。
3. 之后才能落 `pkgs/c/compat.godot-cpp.lua` + `pkgs/g/godotengine.godot-cpp-m.lua` 的 `10.0.0-stable` 条目、
   `tests/examples/godot-cpp-v10-stable` 成员与 README 两表——这三样在归档与 tag 就位后是一次纯登记改动。

## 5. 为什么值得进(消费者视角)

消费侧(如 [mcpp-kaki](https://github.com/farna/mcpp-kaki))现在的组合是「Godot 4.7.2 引擎 + 4.6 绑定」,靠
`.gdextension` 的 `compatibility_minimum` 向上兼容跑着,但拿不到 4.7 新增 API、且 ABI 布局漂移只能运行期暴露。
有了 4.7 绑定,版本两边才能真正对齐。
