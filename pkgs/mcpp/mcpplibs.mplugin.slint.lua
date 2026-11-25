-- mcpplibs.mplugin.slint -- slint-compiler as an importable build plugin.
--
-- A build plugin is `<owner>.mplugin.<name>`; its module and its C++ namespace are
-- that id (docs/build-plugins.md):
--
--   package    mcpplibs.mplugin.slint
--   module     mcpplibs.mplugin.slint
--   namespace  mcpplibs::mplugin::slint
--
-- Most projects never name it: mcpplibs.mwrap.slint re-exports it, so
--
--   [dependencies]
--   mcpplibs.mwrap.slint = "1.19.0.3"
--
--   // build.mcpp
--   import mcpp;
--   import mcpplibs.mplugin.slint;
--   int main() {
--       mcpplibs::mplugin::slint::options o;
--       o.sources = {"ui/app.slint"};
--       return mcpplibs::mplugin::slint::compile(o) ? 0 : 1;
--   }
--
-- A project without the wrapper writes `mcpplibs.mplugin.slint = { version =
-- "1.19.0", host-module = true }` under [build-dependencies] and depends on
-- compat.slint for the SDK.
--
-- The package's version is the Slint it drives; its archive is the one of the
-- wrapper's tag (slint-m mwrap-1.19.0.3: same bytes, same sha256, GLOBAL and
-- CN), `rules/` of it. The rows are added with the wrapper's, so there is no
-- autoupdate here. It replaces mcpplibs.slintgen (frozen, pkgs/s/slintgen.lua).
package = {
    spec        = "1",
    namespace   = "mcpplibs.mplugin",
    name        = "slint",
    description = "slint-compiler as an importable mcpp build plugin (host-module mcpplibs.mplugin.slint)",
    licenses    = {"Apache-2.0"},
    repo        = "https://github.com/mcpplibs/slint-m",
    type        = "package",

    xpm = {
        linux = {
            ["1.19.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/slint-m/releases/download/mwrap-1.19.0.3/slint-m-1.19.0.3.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-slint/releases/download/1.19.0.3/slint-m-1.19.0.3.tar.gz",
                },
                sha256 = "d4e409ad021215cccedf45d3d66932b82fabcd07627c5d6ce6961a4ef88a384b",
            },
        },
        macosx = {
            ["1.19.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/slint-m/releases/download/mwrap-1.19.0.3/slint-m-1.19.0.3.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-slint/releases/download/1.19.0.3/slint-m-1.19.0.3.tar.gz",
                },
                sha256 = "d4e409ad021215cccedf45d3d66932b82fabcd07627c5d6ce6961a4ef88a384b",
            },
        },
        windows = {
            ["1.19.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/slint-m/releases/download/mwrap-1.19.0.3/slint-m-1.19.0.3.tar.gz",
                    CN = "https://gitcode.com/mcpp-res/mwrap-slint/releases/download/1.19.0.3/slint-m-1.19.0.3.tar.gz",
                },
                sha256 = "d4e409ad021215cccedf45d3d66932b82fabcd07627c5d6ce6961a4ef88a384b",
            },
        },
    },

    mcpp = "*/rules/mcpp.toml",
}
