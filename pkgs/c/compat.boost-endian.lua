-- Form B inline descriptor for Boost.Endian 1.92.0 — byte-order conversion (WebSocket framing).
-- Part of the modular-boost header family; see compat.boost-config for the
-- family wiring and version-train policy. Header closure verified by grepping
-- every `<boost/...>` include across the include tree (both `#include` and
-- `# include` spellings) and cross-checked against this repo's CMakeLists
-- INTERFACE line:
--     endian -> config
-- Header-only, traditional `#include` consumption; no CN mirror yet; BSL-1.0.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "boost-endian",
    description = "Boost.Endian 1.92.0 — byte-order conversion (WebSocket framing)",
    licenses    = {"BSL-1.0"},
    repo        = "https://github.com/boostorg/endian",
    type        = "package",

    xpm = {
        linux = {
            ["1.92.0"] = {
                url    = "https://github.com/boostorg/endian/archive/refs/tags/boost-1.92.0.tar.gz",
                sha256 = "5acc3f986b997db9927039e5a034ede1e923dc3576037e2c24b7363961931c03",
            },
        },
        macosx = {
            ["1.92.0"] = {
                url    = "https://github.com/boostorg/endian/archive/refs/tags/boost-1.92.0.tar.gz",
                sha256 = "5acc3f986b997db9927039e5a034ede1e923dc3576037e2c24b7363961931c03",
            },
        },
        windows = {
            ["1.92.0"] = {
                url    = "https://github.com/boostorg/endian/archive/refs/tags/boost-1.92.0.tar.gz",
                sha256 = "5acc3f986b997db9927039e5a034ede1e923dc3576037e2c24b7363961931c03",
            },
        },
    },

    mcpp = {
        language     = "c++20",
        import_std   = false,
        include_dirs = { "*/include" },
        generated_files = {
            ["mcpp_generated/boost_endian_anchor.cpp"] = [==[
int mcpp_compat_boost_endian_anchor(void) { return 0; }
]==],
        },
        sources      = { "mcpp_generated/boost_endian_anchor.cpp" },
        targets      = { ["boost_endian"] = { kind = "lib" } },
        deps         = {
            ["compat.boost-config"] = "1.92.0",
        },
    },
}
