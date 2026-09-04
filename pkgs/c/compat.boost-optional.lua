-- Form B inline descriptor for Boost.Optional 1.92.0 — optional values (Beast buffers_prefix uses in_place_init).
-- Part of the modular-boost header family; see compat.boost-config for the
-- family wiring and version-train policy. Header closure verified by grepping
-- every `<boost/...>` include across the include tree (both `#include` and
-- `# include` spellings) and cross-checked against this repo's CMakeLists
-- INTERFACE line:
--     optional -> assert, config, core, throw_exception, type_traits
-- Header-only, traditional `#include` consumption; no CN mirror yet; BSL-1.0.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "boost-optional",
    description = "Boost.Optional 1.92.0 — optional values (Beast buffers_prefix uses in_place_init)",
    licenses    = {"BSL-1.0"},
    repo        = "https://github.com/boostorg/optional",
    type        = "package",

    xpm = {
        linux = {
            ["1.92.0"] = {
                url    = "https://github.com/boostorg/optional/archive/refs/tags/boost-1.92.0.tar.gz",
                sha256 = "6d914b02c45cea2294768c151589f5855e33d11d3491c613cee3382e27963a96",
            },
        },
        macosx = {
            ["1.92.0"] = {
                url    = "https://github.com/boostorg/optional/archive/refs/tags/boost-1.92.0.tar.gz",
                sha256 = "6d914b02c45cea2294768c151589f5855e33d11d3491c613cee3382e27963a96",
            },
        },
        windows = {
            ["1.92.0"] = {
                url    = "https://github.com/boostorg/optional/archive/refs/tags/boost-1.92.0.tar.gz",
                sha256 = "6d914b02c45cea2294768c151589f5855e33d11d3491c613cee3382e27963a96",
            },
        },
    },

    mcpp = {
        language     = "c++20",
        import_std   = false,
        include_dirs = { "*/include" },
        generated_files = {
            ["mcpp_generated/boost_optional_anchor.cpp"] = [==[
int mcpp_compat_boost_optional_anchor(void) { return 0; }
]==],
        },
        sources      = { "mcpp_generated/boost_optional_anchor.cpp" },
        targets      = { ["boost_optional"] = { kind = "lib" } },
        deps         = {
            ["compat.boost-assert"] = "1.92.0",
            ["compat.boost-config"] = "1.92.0",
            ["compat.boost-core"] = "1.92.0",
            ["compat.boost-throw-exception"] = "1.92.0",
            ["compat.boost-type-traits"] = "1.92.0",
        },
    },
}
