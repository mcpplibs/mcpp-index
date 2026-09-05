-- mcpp:plugins -- the build plugins the mcpp project maintains, one package,
-- each member selected by a feature.
--
--   [dependencies.mcpp]
--   plugins = { version = "0.1.0", features = ["rules-spirv"], host-module = true }
--
--   // build.mcpp
--   import mcpp;
--   import mcpp.rules.spirv;
--
-- Members of 0.1.0: `mcpp.rules.cuda` (feature `rules-cuda`, mcpp >= 2026.9.5.2)
-- and `mcpp.rules.spirv` (feature `rules-spirv`, mcpp >= 2026.9.5.3). The
-- engine compiles every module interface unit among a host-module package's
-- feature-resolved sources as a host module of its own (mcpp 2026.9.5.3+),
-- which is what lets one package carry the collection; a consumer on an older
-- mcpp sees the lib root alone and an unknown-module error on import.
--
-- The naming rule is the rule-package specification's I8: `mcpp.rules.<x>` for
-- rules, `mcpp.tools.<x>` for build-time utilities, and the `mcpp.` prefix
-- reserved for this package. `mcpplibs:rules-cuda@0.1.0` (pkgs/r/rules-cuda.lua)
-- stays in the index, superseded by this collection.
--
-- The descriptor points at the source archive of the tag, the shape `grpcgen`
-- established; the CN asset is the same bytes, so one sha256 names both.
package = {
    spec        = "1",
    namespace   = "mcpp",
    name        = "plugins",
    description = "Official mcpp build plugins: rule packages under mcpp.rules.*, build-time utilities under mcpp.tools.*, each member selected by a feature (host-module)",
    licenses    = {"Apache-2.0"},
    repo        = "https://github.com/mcpp-community/mcpp-plugins",
    type        = "package",

    xpm = {
        linux = {
            ["0.1.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mcpp-plugins/archive/refs/tags/v0.1.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mcpp-plugins/releases/download/0.1.0/mcpp-plugins-0.1.0.tar.gz",
                },
                sha256 = "adf1f9d6691a5d05a8a4a94e83c733ea39caee1510ce2c9af4cb23bebabea9f5",
            },
            ["latest"] = { ref = "0.1.0" },
        },
        macosx = {
            ["0.1.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mcpp-plugins/archive/refs/tags/v0.1.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mcpp-plugins/releases/download/0.1.0/mcpp-plugins-0.1.0.tar.gz",
                },
                sha256 = "adf1f9d6691a5d05a8a4a94e83c733ea39caee1510ce2c9af4cb23bebabea9f5",
            },
            ["latest"] = { ref = "0.1.0" },
        },
        windows = {
            ["0.1.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mcpp-plugins/archive/refs/tags/v0.1.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mcpp-plugins/releases/download/0.1.0/mcpp-plugins-0.1.0.tar.gz",
                },
                sha256 = "adf1f9d6691a5d05a8a4a94e83c733ea39caee1510ce2c9af4cb23bebabea9f5",
            },
            ["latest"] = { ref = "0.1.0" },
        },
    },

    -- The package's own manifest, at the archive root.
    mcpp = "*/mcpp.toml",
}
