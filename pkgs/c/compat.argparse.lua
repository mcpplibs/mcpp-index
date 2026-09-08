-- compat.argparse — p-ranav/argparse, a single-header command line parser.
--
-- Shape B: one header at `include/argparse/argparse.hpp`, so `include_dirs` is
-- `*/include` and consumers write `#include <argparse/argparse.hpp>`.
--
-- The index's third answer to argument parsing, and they are not
-- interchangeable: `compat.CLI11` is the large one (subcommands, config files,
-- validators), `mcpplibs.cmdline` is the mcpp-native module, and this one is
-- the small header that models an argument as a typed `add_argument(...)`
-- chain and throws on a bad command line. A project already using it does not
-- want to be told to rewrite its `main`.
--
-- Needs C++17; `language = "c++23"` here is the index's usual setting for a
-- compat entry and does not force anything on a consumer's own dialect.
--
-- CN mirror: `gitcode.com/mcpp-res/argparse`, the upstream tarball re-hosted
-- BYTE-IDENTICALLY (verified: the mirror's sha256 equals the one declared
-- here, which is what lets one `sha256` serve both arms). GLOBAL stays the
-- default; CN is the fallback `mcpp self config --mirror CN` selects.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "argparse",
    description = "argparse — header-only argument parser for modern C++",
    licenses    = {"MIT"},
    repo        = "https://github.com/p-ranav/argparse",
    type        = "package",

    xpm = {
        linux = {
            ["3.2"] = {
                url    = {
                    GLOBAL = "https://github.com/p-ranav/argparse/archive/refs/tags/v3.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/argparse/releases/download/3.2/argparse-3.2.tar.gz",
                },
                sha256 = "9dcb3d8ce0a41b2a48ac8baa54b51a9f1b6a2c52dd374e28cc713bab0568ec98",
            },
        },
        macosx = {
            ["3.2"] = {
                url    = {
                    GLOBAL = "https://github.com/p-ranav/argparse/archive/refs/tags/v3.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/argparse/releases/download/3.2/argparse-3.2.tar.gz",
                },
                sha256 = "9dcb3d8ce0a41b2a48ac8baa54b51a9f1b6a2c52dd374e28cc713bab0568ec98",
            },
        },
        windows = {
            ["3.2"] = {
                url    = {
                    GLOBAL = "https://github.com/p-ranav/argparse/archive/refs/tags/v3.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/argparse/releases/download/3.2/argparse-3.2.tar.gz",
                },
                sha256 = "9dcb3d8ce0a41b2a48ac8baa54b51a9f1b6a2c52dd374e28cc713bab0568ec98",
            },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        c_standard   = "c11",
        include_dirs = { "*/include" },
        generated_files = {
            ["mcpp_generated/argparse_anchor.c"] =
                "int mcpp_compat_argparse_anchor(void) { return 0; }\n",
        },
        sources      = { "mcpp_generated/argparse_anchor.c" },
        targets      = { ["argparse"] = { kind = "lib" } },
        deps         = { },
    },
}
