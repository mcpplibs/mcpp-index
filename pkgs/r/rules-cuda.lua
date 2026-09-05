-- rules-cuda —— 把「怎么编一个 CUDA 设备翻译单元」收成一条可 import 的构建规则。
--
--   [dependencies.mcpplibs]
--   rules-cuda = { version = "0.1.0", host-module = true }
--
--   // build.mcpp
--   import mcpp;
--   import mcpplibs.rules.cuda;
--   int main() { return mcpplibs::rules::cuda::compile({}) ? 0 : 1; }
--
-- 这是本生态**自己写的** C++,不是上游任何东西,所以留在 `mcpplibs`。
--
-- ⭐ 一个仓库都不用新建,与 `grpcgen` 同形:描述符指向 mcpp 自己的**源码
-- tarball** 的一个子路径。规则包与它所讲的协议(构建程序协议 v7)由同一次发布
-- 产出,指向同一份 tarball 因而不是权宜之计,而是让两者不可能错配。
--
-- 规则包提供的是**拼法**,引擎提供的是**图**:`-gencode` / `--cuda-gpu-arch` 的
-- 拼装、`sm_XX` 的覆盖判定、宿主编译器上界的读取、驱动版本的探测,全部在这里;
-- 加速器轴、设备源清单、动作边、下界比较在引擎里,且引擎不认识 "cuda" 这个词。
--
-- 需要 mcpp >= 2026.9.5.2:`mcpp::fact` / `mcpp::floor` / `mcpp::device_sources`
-- / `mcpp::toolchain_sysroot` 在此之前都不存在。
package = {
    spec        = "1",
    namespace   = "mcpplibs",
    name        = "rules-cuda",
    description = "Compile CUDA device translation units as an importable mcpp build rule (host-module)",
    licenses    = {"Apache-2.0"},
    repo        = "https://github.com/mcpp-community/mcpp",
    type        = "package",

    xpm = {
        linux = {
            ["0.1.0"] = {
                url    = "https://github.com/mcpp-community/mcpp/archive/refs/tags/v2026.9.5.2.tar.gz",
                sha256 = "3f75ad445478ee4d4e9c38e3ee00cc9522b01218154b1d6b0811107ff82088bd",
            },
            ["latest"] = { ref = "0.1.0" },
        },
        macosx = {
            ["0.1.0"] = {
                url    = "https://github.com/mcpp-community/mcpp/archive/refs/tags/v2026.9.5.2.tar.gz",
                sha256 = "3f75ad445478ee4d4e9c38e3ee00cc9522b01218154b1d6b0811107ff82088bd",
            },
            ["latest"] = { ref = "0.1.0" },
        },
        windows = {
            ["0.1.0"] = {
                url    = "https://github.com/mcpp-community/mcpp/archive/refs/tags/v2026.9.5.2.tar.gz",
                sha256 = "3f75ad445478ee4d4e9c38e3ee00cc9522b01218154b1d6b0811107ff82088bd",
            },
            ["latest"] = { ref = "0.1.0" },
        },
    },

    -- The rule's own manifest, inside the release tarball.
    mcpp = "*/examples/09-cuda-kernel/rules-cuda/mcpp.toml",
}
