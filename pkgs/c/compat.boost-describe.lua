-- Form B inline descriptor for Boost.Describe 1.92.0 — macro-based enum/class descriptions (feeds ContainerHash).
-- Part of the modular-boost header family; see compat.boost-config for the
-- family wiring and version-train policy. Header closure verified by grepping
-- every `<boost/...>` include across the include tree (both `#include` and
-- `# include` spellings) and cross-checked against this repo's CMakeLists
-- INTERFACE line:
--     describe -> mp11
-- Header-only, traditional `#include` consumption; no CN mirror yet; BSL-1.0.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "boost-describe",
    description = "Boost.Describe 1.92.0 — macro-based enum/class descriptions (feeds ContainerHash)",
    licenses    = {"BSL-1.0"},
    repo        = "https://github.com/boostorg/describe",
    type        = "package",

    xpm = {
        linux = {
            ["1.92.0"] = {
                url    = "https://github.com/boostorg/describe/archive/refs/tags/boost-1.92.0.tar.gz",
                sha256 = "4ef61ea2ca967b803e171f4756e03e201680d5dd19d014324f9a848e0d06863b",
            },
        },
        macosx = {
            ["1.92.0"] = {
                url    = "https://github.com/boostorg/describe/archive/refs/tags/boost-1.92.0.tar.gz",
                sha256 = "4ef61ea2ca967b803e171f4756e03e201680d5dd19d014324f9a848e0d06863b",
            },
        },
        windows = {
            ["1.92.0"] = {
                url    = "https://github.com/boostorg/describe/archive/refs/tags/boost-1.92.0.tar.gz",
                sha256 = "4ef61ea2ca967b803e171f4756e03e201680d5dd19d014324f9a848e0d06863b",
            },
        },
    },

    mcpp = {
        language     = "c++20",
        import_std   = false,
        include_dirs = { "*/include" },
        generated_files = {
            ["mcpp_generated/boost_describe_anchor.cpp"] = [==[
int mcpp_compat_boost_describe_anchor(void) { return 0; }
]==],
        },
        sources      = { "mcpp_generated/boost_describe_anchor.cpp" },
        targets      = { ["boost_describe"] = { kind = "lib" } },
        deps         = {
            ["compat.boost-mp11"] = "1.92.0",
        },
    },
}
