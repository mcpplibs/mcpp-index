-- compat.doctest — the doctest single-header test framework.
--
-- The index's fourth test framework, alongside `compat.catch2`, `compat.gtest`
-- and `boost-ext.ut`. It earns the entry by being the one whose whole selling
-- point is compile cost: doctest is designed to be included in EVERY
-- translation unit of a project so tests sit next to the code they test, which
-- is a shape the other three cannot take.
--
-- Shape B at its simplest. The header is `doctest/doctest.h` at the tarball
-- root, so `include_dirs` is `*` and consumers write
-- `#include <doctest/doctest.h>` — upstream's own spelling.
--
-- NO SEPARATE `main` PACKAGE, and that is a real difference from catch2. This
-- index carries `compat.catch2` and `compat.catch2-main` as two entries
-- because Catch2 v3's `main` is a compiled library. doctest's is a macro:
-- exactly one TU defines `DOCTEST_CONFIG_IMPLEMENT_WITH_MAIN` before the
-- include and gets `main` for free, so there is nothing to compile and nothing
-- to link. The test member demonstrates that spelling.
--
-- The 55 `.cpp` in the tarball are upstream's own tests, examples and the
-- `parts/` split-header build; no glob here reaches them.
--
-- CN mirror: `gitcode.com/mcpp-res/doctest`, the upstream tarball re-hosted
-- BYTE-IDENTICALLY (verified: the mirror's sha256 equals the one declared
-- here, which is what lets one `sha256` serve both arms). GLOBAL stays the
-- default; CN is the fallback `mcpp self config --mirror CN` selects.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "doctest",
    description = "doctest — the fastest feature-rich C++ single-header testing framework",
    licenses    = {"MIT"},
    repo        = "https://github.com/doctest/doctest",
    type        = "package",

    xpm = {
        linux = {
            ["2.4.12"] = {
                url    = {
                    GLOBAL = "https://github.com/doctest/doctest/archive/refs/tags/v2.4.12.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/doctest/releases/download/2.4.12/doctest-2.4.12.tar.gz",
                },
                sha256 = "73381c7aa4dee704bd935609668cf41880ea7f19fa0504a200e13b74999c2d70",
            },
        },
        macosx = {
            ["2.4.12"] = {
                url    = {
                    GLOBAL = "https://github.com/doctest/doctest/archive/refs/tags/v2.4.12.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/doctest/releases/download/2.4.12/doctest-2.4.12.tar.gz",
                },
                sha256 = "73381c7aa4dee704bd935609668cf41880ea7f19fa0504a200e13b74999c2d70",
            },
        },
        windows = {
            ["2.4.12"] = {
                url    = {
                    GLOBAL = "https://github.com/doctest/doctest/archive/refs/tags/v2.4.12.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/doctest/releases/download/2.4.12/doctest-2.4.12.tar.gz",
                },
                sha256 = "73381c7aa4dee704bd935609668cf41880ea7f19fa0504a200e13b74999c2d70",
            },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        c_standard   = "c11",
        include_dirs = { "*" },
        generated_files = {
            ["mcpp_generated/doctest_anchor.c"] =
                "int mcpp_compat_doctest_anchor(void) { return 0; }\n",
        },
        sources      = { "mcpp_generated/doctest_anchor.c" },
        targets      = { ["doctest"] = { kind = "lib" } },
        deps         = { },
    },
}
