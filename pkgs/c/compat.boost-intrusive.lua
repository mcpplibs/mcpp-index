-- Form B inline descriptor for Boost.Intrusive 1.92.0 — intrusive list/set hooks (Beast buffers and http::fields).
-- Part of the modular-boost header family; see compat.boost-config for the
-- family wiring and version-train policy. Header closure verified by grepping
-- every `<boost/...>` include across the include tree (both `#include` and
-- `# include` spellings) and cross-checked against this repo's CMakeLists
-- INTERFACE line:
--     intrusive -> assert, config, move
-- Header-only, traditional `#include` consumption; no CN mirror yet; BSL-1.0.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "boost-intrusive",
    description = "Boost.Intrusive 1.92.0 — intrusive list/set hooks (Beast buffers and http::fields)",
    licenses    = {"BSL-1.0"},
    repo        = "https://github.com/boostorg/intrusive",
    type        = "package",

    xpm = {
        linux = {
            ["1.92.0"] = {
                url    = "https://github.com/boostorg/intrusive/archive/refs/tags/boost-1.92.0.tar.gz",
                sha256 = "1df09194b4e223cbc86616d6747f6df35d3bb2b24456a58e4fb5b8483ca37f26",
            },
        },
        macosx = {
            ["1.92.0"] = {
                url    = "https://github.com/boostorg/intrusive/archive/refs/tags/boost-1.92.0.tar.gz",
                sha256 = "1df09194b4e223cbc86616d6747f6df35d3bb2b24456a58e4fb5b8483ca37f26",
            },
        },
        windows = {
            ["1.92.0"] = {
                url    = "https://github.com/boostorg/intrusive/archive/refs/tags/boost-1.92.0.tar.gz",
                sha256 = "1df09194b4e223cbc86616d6747f6df35d3bb2b24456a58e4fb5b8483ca37f26",
            },
        },
    },

    mcpp = {
        language     = "c++20",
        import_std   = false,
        include_dirs = { "*/include" },
        generated_files = {
            ["mcpp_generated/boost_intrusive_anchor.cpp"] = [==[
int mcpp_compat_boost_intrusive_anchor(void) { return 0; }
]==],
        },
        sources      = { "mcpp_generated/boost_intrusive_anchor.cpp" },
        targets      = { ["boost_intrusive"] = { kind = "lib" } },
        deps         = {
            ["compat.boost-assert"] = "1.92.0",
            ["compat.boost-config"] = "1.92.0",
            ["compat.boost-move"] = "1.92.0",
        },
    },
}
