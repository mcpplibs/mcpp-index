-- Form B inline descriptor for CLI11 — a modern C++ command line parser.
--
-- CLI11 is a HEADER-ONLY library. All functionality is implemented in headers
-- under `include/CLI/`; there are no library sources to compile. Therefore the
-- package simply exports the `include/` directory and provides a tiny generated
-- translation unit so mcpp always has a buildable `lib` target.
--
-- Consumers simply write:
--
--     #include <CLI/CLI.hpp>
--
-- No additional configuration or features are required.

package = {
    spec        = "1",
    namespace   = "compat",
    name        = "CLI11",
    description = "Modern C++ command line parser (header-only)",
    licenses    = { "BSD-3-Clause" },
    repo        = "https://github.com/CLIUtils/CLI11",
    type        = "package",

    xpm = {
        linux = {
            ["2.7.2"] = {
                url = {
                    GLOBAL = "https://github.com/CLIUtils/CLI11/archive/refs/tags/v2.7.2.tar.gz",
                    CN = "https://github.com/CLIUtils/CLI11/archive/refs/tags/v2.7.2.tar.gz",
                },
                sha256 = "46eef3101da70852ec7af026e09d485ccee81813331c8c6052d39344443b83da",
            },
        },

        macosx = {
            ["2.7.2"] = {
                url = {
                    GLOBAL = "https://github.com/CLIUtils/CLI11/archive/refs/tags/v2.7.2.tar.gz",
                    CN = "https://github.com/CLIUtils/CLI11/archive/refs/tags/v2.7.2.tar.gz",
                },
                sha256 = "46eef3101da70852ec7af026e09d485ccee81813331c8c6052d39344443b83da",
            },
        },

        windows = {
            ["2.7.2"] = {
                url = {
                    GLOBAL = "https://github.com/CLIUtils/CLI11/archive/refs/tags/v2.7.2.tar.gz",
                    CN = "https://github.com/CLIUtils/CLI11/archive/refs/tags/v2.7.2.tar.gz",
                },
                sha256 = "46eef3101da70852ec7af026e09d485ccee81813331c8c6052d39344443b83da",
            },
        },
    },

    mcpp = {
        language   = "c++17",
        import_std = false,

        -- Upstream headers live in include/CLI/
        include_dirs = {
            "include",
        },

        -- Header-only anchor.
        generated_files = {
            ["mcpp_generated/cli11_anchor.cpp"] = [==[
int mcpp_compat_cli11_headers_anchor(void) {
    return 0;
}
]==],
        },

        sources = {
            "mcpp_generated/cli11_anchor.cpp",
        },

        targets = {
            ["CLI11"] = {
                kind = "lib",
            },
        },

        deps = {},
    },
}
