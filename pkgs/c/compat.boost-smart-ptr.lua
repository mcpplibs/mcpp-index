-- Form B inline descriptor for Boost.SmartPtr 1.92.0 — shared/weak/scoped pointers plus boost/shared_ptr.hpp shims.
-- Part of the modular-boost header family; see compat.boost-config for the
-- family wiring and version-train policy. Header closure verified by grepping
-- every `<boost/...>` include across the include tree (both `#include` and
-- `# include` spellings) and cross-checked against this repo's CMakeLists
-- INTERFACE line:
--     smart_ptr -> assert, config, core, throw_exception
-- Header-only, traditional `#include` consumption; no CN mirror yet; BSL-1.0.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "boost-smart-ptr",
    description = "Boost.SmartPtr 1.92.0 — shared/weak/scoped pointers plus boost/shared_ptr.hpp shims",
    licenses    = {"BSL-1.0"},
    repo        = "https://github.com/boostorg/smart_ptr",
    type        = "package",

    xpm = {
        linux = {
            ["1.92.0"] = {
                url    = "https://github.com/boostorg/smart_ptr/archive/refs/tags/boost-1.92.0.tar.gz",
                sha256 = "49994bb3d97b81fc877df3ae04595d922857939f65fd568019e7a2053dee648f",
            },
        },
        macosx = {
            ["1.92.0"] = {
                url    = "https://github.com/boostorg/smart_ptr/archive/refs/tags/boost-1.92.0.tar.gz",
                sha256 = "49994bb3d97b81fc877df3ae04595d922857939f65fd568019e7a2053dee648f",
            },
        },
        windows = {
            ["1.92.0"] = {
                url    = "https://github.com/boostorg/smart_ptr/archive/refs/tags/boost-1.92.0.tar.gz",
                sha256 = "49994bb3d97b81fc877df3ae04595d922857939f65fd568019e7a2053dee648f",
            },
        },
    },

    mcpp = {
        language     = "c++20",
        import_std   = false,
        include_dirs = { "*/include" },
        generated_files = {
            ["mcpp_generated/boost_smart_ptr_anchor.cpp"] = [==[
int mcpp_compat_boost_smart_ptr_anchor(void) { return 0; }
]==],
        },
        sources      = { "mcpp_generated/boost_smart_ptr_anchor.cpp" },
        targets      = { ["boost_smart_ptr"] = { kind = "lib" } },
        deps         = {
            ["compat.boost-assert"] = "1.92.0",
            ["compat.boost-config"] = "1.92.0",
            ["compat.boost-core"] = "1.92.0",
            ["compat.boost-throw-exception"] = "1.92.0",
        },
    },
}
