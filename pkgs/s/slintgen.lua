-- slintgen -- slint-compiler as an importable build rule.
--
-- FROZEN: superseded by mcpplibs.mplugin.slint (pkgs/mcpp/, docs/build-plugins.md).
-- This package keeps 1.19.0.1 and 1.19.0.2 as published and gets no more versions.
--
-- One name in three spellings, as mcpplibs.openkal-bind is (SPEC-007 R9.6, a
-- third-party plugin's `mcpp.<namespace>.<name>`):
--
--   package    mcpplibs.slintgen
--   module     mcpp.mcpplibs.slintgen
--   namespace  mcpp::mcpplibs::slintgen
--
-- Most projects never name it: mcpplibs.mwrap.slint re-exports it, so
--
--   [dependencies]
--   mcpplibs.mwrap.slint = "1.19.0.2"
--
--   // build.mcpp
--   import mcpp;
--   import mcpp.mcpplibs.slintgen;
--   int main() {
--       mcpp::mcpplibs::slintgen::options o;
--       o.sources = {"ui/app.slint"};
--       return mcpp::mcpplibs::slintgen::compile(o) ? 0 : 1;
--   }
--
-- A project without the wrapper writes `mcpplibs.slintgen = { version =
-- "1.19.0.2", host-module = true }` under [build-dependencies] and depends on
-- compat.slint for the SDK.
--
-- The rule is this ecosystem's own C++ (not upstream's), so it stays in
-- `mcpplibs`; it ships in the rules/ directory of the slint-m archive, as
-- grpcgen ships in grpc-m's.
--
-- 1.19.0 and 1.19.0.1: the module was `mcpp.plugins.slint` (never indexed) and
-- `slint.mcpp.plugins` with a feature that claimed `.slint`; 1.19.0.2 is the
-- name above and no feature. 1.19.0.1 keeps its published bytes.
package = {
    spec        = "1",
    namespace   = "mcpplibs",
    name        = "slintgen",
    description = "FROZEN: superseded by mcpplibs.mplugin.slint. slint-compiler as an importable mcpp build rule (host-module mcpp.mcpplibs.slintgen)",
    licenses    = {"Apache-2.0"},
    repo        = "https://github.com/mcpplibs/slint-m",
    type        = "package",

    xpm = {
        linux = {
            ["1.19.0.2"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/slint-m/releases/download/mwrap-1.19.0.2/slint-m-1.19.0.2.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-slint/releases/download/1.19.0.2/slint-m-1.19.0.2.tar.gz",
                },
                sha256 = "95021ff52af53930f2b9306f5612f421e9f79741d7465ec3d586e7eb1948c62d",
            },
            ["1.19.0.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/slint-m/releases/download/mwrap-1.19.0.1/slint-m-1.19.0.1.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-slint/releases/download/1.19.0.1/slint-m-1.19.0.1.tar.gz",
                },
                sha256 = "ed0da17d0e0394eba430b0e877c270251710885024f35cbb2ec1e7a71c0b7ee2",
            },
        },
        macosx = {
            ["1.19.0.2"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/slint-m/releases/download/mwrap-1.19.0.2/slint-m-1.19.0.2.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-slint/releases/download/1.19.0.2/slint-m-1.19.0.2.tar.gz",
                },
                sha256 = "95021ff52af53930f2b9306f5612f421e9f79741d7465ec3d586e7eb1948c62d",
            },
            ["1.19.0.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/slint-m/releases/download/mwrap-1.19.0.1/slint-m-1.19.0.1.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-slint/releases/download/1.19.0.1/slint-m-1.19.0.1.tar.gz",
                },
                sha256 = "ed0da17d0e0394eba430b0e877c270251710885024f35cbb2ec1e7a71c0b7ee2",
            },
        },
        windows = {
            ["1.19.0.2"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/slint-m/releases/download/mwrap-1.19.0.2/slint-m-1.19.0.2.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-slint/releases/download/1.19.0.2/slint-m-1.19.0.2.tar.gz",
                },
                sha256 = "95021ff52af53930f2b9306f5612f421e9f79741d7465ec3d586e7eb1948c62d",
            },
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
