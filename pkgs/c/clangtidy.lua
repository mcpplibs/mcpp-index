-- clangtidy —— clang-tidy 收成一条可 import 的构建规则。
--
--   [build-dependencies]
--   clangtidy = { version = "0.1.0", host-module = true }
--   llvm      = { version = "...",   tools = ["clang-tidy"] }
--
--   // build.mcpp
--   import std;
--   import mcpp;
--   import clangtidy;
--   int main() {
--       std::vector<std::string> files{ "src/main.cpp" };
--       return clangtidy::check(files) ? 0 : 1;
--   }
--
-- 本生态自己写的 C++,不是上游任何东西,所以留在 `mcpplibs`。
--
-- ⚠️ 需要 mcpp >= 2026.8.29.1。在那之前,check 的**命令**必须自己创建满足这条边的
-- stamp,而 clang-tidy 成功时什么都不写 —— 于是每个消费者都要写同一个包装脚本,
-- 而 action 的 command 是 argv、不假设有 shell,那个包装器在 Windows 上写不出来。
-- 从那一版起 mcpp 在命令退 0 时写 stamp,这才让这个包成为可能,而不只是方便。
--
-- ⚠️ 装了旧 mcpp 也不会报错。少了 stamp,ninja 不会失败 —— 它只是每次构建都重跑那
-- 条边。检查看起来一直在通过,而它从未被满足。
--
-- 包名承重:mcpp < 2026.8.29.1 用依赖的裸 package.name 注册 host 模块,从那一版起
-- 用接口声明的那个名字。两者保持相等,是它在新旧引擎上都能被解析的原因。
package = {
    spec        = "1",
    namespace   = "mcpplibs",
    name        = "clangtidy",
    description = "clang-tidy as an importable mcpp build rule (role = check, host-module)",
    licenses    = {"Apache-2.0"},
    repo        = "https://github.com/mcpplibs/clangtidy",
    type        = "package",

    xpm = {
        linux = {
            ["0.1.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/clangtidy/archive/refs/tags/v0.1.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/clangtidy/releases/download/0.1.0/clangtidy-0.1.0.tar.gz",
                },
                sha256 = "5fc0ba747afef2f58748cff1be151902312131e04ec9312a475faf7bdda94be8",
            },
        },
        macosx = {
            ["0.1.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/clangtidy/archive/refs/tags/v0.1.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/clangtidy/releases/download/0.1.0/clangtidy-0.1.0.tar.gz",
                },
                sha256 = "5fc0ba747afef2f58748cff1be151902312131e04ec9312a475faf7bdda94be8",
            },
        },
        windows = {
            ["0.1.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/clangtidy/archive/refs/tags/v0.1.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/clangtidy/releases/download/0.1.0/clangtidy-0.1.0.tar.gz",
                },
                sha256 = "5fc0ba747afef2f58748cff1be151902312131e04ec9312a475faf7bdda94be8",
            },
        },
    },

    mcpp = "*/mcpp.toml",
}
