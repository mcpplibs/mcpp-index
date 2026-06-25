-- M6.x glob-aware Form B descriptor for gtest.
-- All paths inside `mcpp = {}` are GLOBS relative to the verdir
-- (~/.mcpp/registry/data/xpkgs/<idx>-x-gtest/<ver>/).  `*` matches any
-- single path segment (so it absorbs the GitHub `<repo>-<tag>/` wrap).

package = {
    spec        = "1",
    namespace = "compat",
    name        = "compat.gtest",
    description = "Google's C++ test framework",
    licenses    = {"BSD-3-Clause"},
    repo        = "https://github.com/google/googletest",
    type        = "package",

    xpm = {
        linux = {
            ["1.15.2"] = {
                url    = {
                    GLOBAL = "https://github.com/google/googletest/archive/refs/tags/v1.15.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/gtest/releases/download/1.15.2/gtest-1.15.2.tar.gz",
                },
                sha256 = "7b42b4d6ed48810c5362c265a17faebe90dc2373c885e5216439d37927f02926",
            },
        },
        macosx = {
            ["1.15.2"] = {
                url    = {
                    GLOBAL = "https://github.com/google/googletest/archive/refs/tags/v1.15.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/gtest/releases/download/1.15.2/gtest-1.15.2.tar.gz",
                },
                sha256 = "7b42b4d6ed48810c5362c265a17faebe90dc2373c885e5216439d37927f02926",
            },
        },
        windows = {
            ["1.15.2"] = {
                url    = {
                    GLOBAL = "https://github.com/google/googletest/archive/refs/tags/v1.15.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/gtest/releases/download/1.15.2/gtest-1.15.2.tar.gz",
                },
                sha256 = "7b42b4d6ed48810c5362c265a17faebe90dc2373c885e5216439d37927f02926",
            },
        },
    },

    mcpp = {
        language     = "c++23",
        sources      = {
            "*/googletest/src/gtest-all.cc",
            "*/googletest/src/gtest_main.cc",
        },
        include_dirs = {
            "*/googletest/include",
            "*/googletest",
        },
        targets      = { ["gtest"] = { kind = "lib" } },
        -- gtest_main.cc provides its own main(); it must NOT be linked by
        -- default (it would collide with a binary's own main, e.g. an app via
        -- `mcpp add gtest` + `mcpp build`, or a test that writes its own main).
        -- It is listed BOTH in `sources` (so OLD mcpp, which ignores `features`,
        -- keeps today's behavior — no regression) AND here under the `main`
        -- feature: NEW mcpp treats a feature-listed source as gated → excluded
        -- by default, included only when `features = ["main"]` is requested on
        -- the gtest dependency. See
        -- mcpp .agents/docs/2026-06-25-gtest-main-feature-and-add-dev-design.md.
        features     = {
            ["main"] = { sources = { "*/googletest/src/gtest_main.cc" } },
        },
        deps         = { },
    },
}
