-- slintgen -- slint-compiler as an importable build rule (module mcpp.plugins.slint).
--
--   [build-dependencies]
--   mcpplibs.slintgen = { version = "1.19.0", features = ["slint"] }
--
--   // build.mcpp
--   import mcpp;
--   import mcpp.plugins.slint;
--   int main() { return mcpp::plugins::slint::compile({}) ? 0 : 1; }
--
-- The rule is this ecosystem's own C++ (not upstream's), so it stays in
-- `mcpplibs`; it ships in the rules/ directory of the slint-m archive, as
-- grpcgen ships in grpc-m's. The feature `slint` claims `.slint` as a source
-- the rule compiles; the project names it.
--
-- SPEC-007 R9.6 keeps `mcpp.plugins.*` for the mcpp namespace: the engine warns
-- once per build that this package provides the module. The name is the
-- maintainer's choice (mcpplibs/slint-m#1).
package = {
    spec        = "1",
    namespace   = "mcpplibs",
    name        = "slintgen",
    description = "slint-compiler as an importable mcpp build rule (host-module mcpp.plugins.slint)",
    licenses    = {"Apache-2.0"},
    repo        = "https://github.com/mcpplibs/slint-m",
    type        = "package",

    xpm = {
        linux = {
            ["1.19.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/slint-m/releases/download/mwrap-1.19.0/slint-m-1.19.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-slint/releases/download/1.19.0/slint-m-1.19.0.tar.gz",
                },
                sha256 = "f75b8fb3ce6e779a176fe47f4a8e07df8bec8713e2b1bde7f199e1400097ddd9",
            },
        },
        macosx = {
            ["1.19.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/slint-m/releases/download/mwrap-1.19.0/slint-m-1.19.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-slint/releases/download/1.19.0/slint-m-1.19.0.tar.gz",
                },
                sha256 = "f75b8fb3ce6e779a176fe47f4a8e07df8bec8713e2b1bde7f199e1400097ddd9",
            },
        },
        windows = {
            ["1.19.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/slint-m/releases/download/mwrap-1.19.0/slint-m-1.19.0.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-slint/releases/download/1.19.0/slint-m-1.19.0.tar.gz",
                },
                sha256 = "f75b8fb3ce6e779a176fe47f4a8e07df8bec8713e2b1bde7f199e1400097ddd9",
            },
        },
    },

    mcpp = "*/rules/mcpp.toml",
}
