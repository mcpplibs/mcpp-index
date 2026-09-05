-- Form B inline descriptor for Boost.IO 1.92.0 — stream flag helpers (ios_state, ostream_put) and boost/io_fwd.hpp.
-- Part of the modular-boost header family; see compat.boost-config for the
-- family wiring and version-train policy. Header closure verified by grepping
-- every `<boost/...>` include across the include tree (both `#include` and
-- `# include` spellings) and cross-checked against this repo's CMakeLists
-- INTERFACE line:
--     io -> config
-- Header-only, traditional `#include` consumption; no CN mirror yet; BSL-1.0.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "boost-io",
    description = "Boost.IO 1.92.0 — stream flag helpers (ios_state, ostream_put) and boost/io_fwd.hpp",
    licenses    = {"BSL-1.0"},
    repo        = "https://github.com/boostorg/io",
    type        = "package",

    xpm = {
        linux = {
            ["1.92.0"] = {
                url    = "https://github.com/boostorg/io/archive/refs/tags/boost-1.92.0.tar.gz",
                sha256 = "a42279650f8a79f93a24fbda0b968e519224efdff91e4177407a4ee8b9d9ee57",
            },
        },
        macosx = {
            ["1.92.0"] = {
                url    = "https://github.com/boostorg/io/archive/refs/tags/boost-1.92.0.tar.gz",
                sha256 = "a42279650f8a79f93a24fbda0b968e519224efdff91e4177407a4ee8b9d9ee57",
            },
        },
        windows = {
            ["1.92.0"] = {
                url    = "https://github.com/boostorg/io/archive/refs/tags/boost-1.92.0.tar.gz",
                sha256 = "a42279650f8a79f93a24fbda0b968e519224efdff91e4177407a4ee8b9d9ee57",
            },
        },
    },

    mcpp = {
        language     = "c++20",
        import_std   = false,
        include_dirs = { "*/include" },
        generated_files = {
            ["mcpp_generated/boost_io_anchor.cpp"] = [==[
int mcpp_compat_boost_io_anchor(void) { return 0; }
]==],
        },
        sources      = { "mcpp_generated/boost_io_anchor.cpp" },
        targets      = { ["boost_io"] = { kind = "lib" } },
        deps         = {
            ["compat.boost-config"] = "1.92.0",
        },
    },
}
