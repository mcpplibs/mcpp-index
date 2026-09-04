-- Form B inline descriptor for Boost.ContainerHash 1.92.0 — hash_value and hash range combinators.
-- Part of the modular-boost header family; see compat.boost-config for the
-- family wiring and version-train policy. Header closure verified by grepping
-- every `<boost/...>` include across the include tree (both `#include` and
-- `# include` spellings) and cross-checked against this repo's CMakeLists
-- INTERFACE line:
--     container_hash -> config, describe, mp11
-- Header-only, traditional `#include` consumption; no CN mirror yet; BSL-1.0.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "boost-container-hash",
    description = "Boost.ContainerHash 1.92.0 — hash_value and hash range combinators",
    licenses    = {"BSL-1.0"},
    repo        = "https://github.com/boostorg/container_hash",
    type        = "package",

    xpm = {
        linux = {
            ["1.92.0"] = {
                url    = "https://github.com/boostorg/container_hash/archive/refs/tags/boost-1.92.0.tar.gz",
                sha256 = "f88aabbbc2f163db5eea65662b26e5af2bde0a0bff065c645b7347ed6a71a566",
            },
        },
        macosx = {
            ["1.92.0"] = {
                url    = "https://github.com/boostorg/container_hash/archive/refs/tags/boost-1.92.0.tar.gz",
                sha256 = "f88aabbbc2f163db5eea65662b26e5af2bde0a0bff065c645b7347ed6a71a566",
            },
        },
        windows = {
            ["1.92.0"] = {
                url    = "https://github.com/boostorg/container_hash/archive/refs/tags/boost-1.92.0.tar.gz",
                sha256 = "f88aabbbc2f163db5eea65662b26e5af2bde0a0bff065c645b7347ed6a71a566",
            },
        },
    },

    mcpp = {
        language     = "c++20",
        import_std   = false,
        include_dirs = { "*/include" },
        generated_files = {
            ["mcpp_generated/boost_container_hash_anchor.cpp"] = [==[
int mcpp_compat_boost_container_hash_anchor(void) { return 0; }
]==],
        },
        sources      = { "mcpp_generated/boost_container_hash_anchor.cpp" },
        targets      = { ["boost_container_hash"] = { kind = "lib" } },
        deps         = {
            ["compat.boost-config"] = "1.92.0",
            ["compat.boost-describe"] = "1.92.0",
            ["compat.boost-mp11"] = "1.92.0",
        },
    },
}
