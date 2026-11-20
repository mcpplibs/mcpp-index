-- slintgen -- slint-compiler as an importable build rule (module slint.mcpp.plugins).
--
--   [build-dependencies]
--   mcpplibs.slintgen = { version = "1.19.0.1", features = ["slint"] }
--
--   // build.mcpp
--   import mcpp;
--   import slint.mcpp.plugins;
--   int main() { return mcpp::plugins::slint::compile({}) ? 0 : 1; }
--
-- The rule is this ecosystem's own C++ (not upstream's), so it stays in
-- `mcpplibs`; it ships in the rules/ directory of the slint-m archive, as
-- grpcgen ships in grpc-m's. The feature `slint` claims `.slint` as a source
-- the rule compiles; the project names it.
--
-- The module is named under the library's name, not `mcpp.plugins.*`: SPEC-007
-- R9.6 keeps that for the mcpp namespace and the index admits no package that
-- provides such a module (tests/run_members.sh). 1.19.0.1 is the wrapper
-- revision that renamed it; mwrap-1.19.0 was tagged and never indexed.
package = {
    spec        = "1",
    namespace   = "mcpplibs",
    name        = "slintgen",
    description = "slint-compiler as an importable mcpp build rule (host-module slint.mcpp.plugins)",
    licenses    = {"Apache-2.0"},
    repo        = "https://github.com/mcpplibs/slint-m",
    type        = "package",

    xpm = {
        linux = {
            ["1.19.0.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/slint-m/releases/download/mwrap-1.19.0.1/slint-m-1.19.0.1.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-slint/releases/download/1.19.0.1/slint-m-1.19.0.1.tar.gz",
                },
                sha256 = "ed0da17d0e0394eba430b0e877c270251710885024f35cbb2ec1e7a71c0b7ee2",
            },
        },
        macosx = {
            ["1.19.0.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/slint-m/releases/download/mwrap-1.19.0.1/slint-m-1.19.0.1.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-slint/releases/download/1.19.0.1/slint-m-1.19.0.1.tar.gz",
                },
                sha256 = "ed0da17d0e0394eba430b0e877c270251710885024f35cbb2ec1e7a71c0b7ee2",
            },
        },
        windows = {
            ["1.19.0.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/slint-m/releases/download/mwrap-1.19.0.1/slint-m-1.19.0.1.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-slint/releases/download/1.19.0.1/slint-m-1.19.0.1.tar.gz",
                },
                sha256 = "ed0da17d0e0394eba430b0e877c270251710885024f35cbb2ec1e7a71c0b7ee2",
            },
        },
    },

    mcpp = "*/rules/mcpp.toml",
}
