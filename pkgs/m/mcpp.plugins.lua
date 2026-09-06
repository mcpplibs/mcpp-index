-- mcpp:plugins -- the build plugins the mcpp project maintains, one package,
-- each member selected by a feature.
--
--   [dependencies.mcpp]
--   plugins = { version = "0.2.1", features = ["rules-spirv"], host-module = true }
--
--   // build.mcpp
--   import mcpp;
--   import mcpp.rules.spirv;
--
-- Members of 0.2.1, with the mcpp release each relies on:
--
--   mcpp.rules.cuda   `rules-cuda`   >= 2026.9.5.2
--   mcpp.rules.spirv  `rules-spirv`  >= 2026.9.5.3; since 0.2.0 it drives glslc
--                                    as well as glslang, because `xim:shaderc`
--                                    publishes one -- the route this rule's own
--                                    source used to call "a claim rather than a
--                                    feature"
--   mcpp.tools.embed  `tools-embed`  >= 2026.9.5.4, whose fast path compares a
--                                    declared file input; without it an edit to
--                                    the embedded data does not reach the binary
--   mcpp.rules.hip    `rules-hip`    >= 2026.9.5.2. HIP on the NVIDIA platform
--                                    is a header layer over the CUDA runtime,
--                                    so the compiler is the project's own clang
--                                    and `xim:hip-nvidia` carries no binaries
--   mcpp.rules.sycl   `rules-sycl`   >= 2026.9.6.1, the release whose
--                                    device-source table carries `.sycl`. Needs
--                                    `compat:sycl-runtime` so the artifact can
--                                    reach `libsycl.so.9` at run time. Since
--                                    0.2.1 it also names the C library: the
--                                    device compiler is a second compiler and
--                                    does not inherit the toolchain the engine
--                                    configured, so without `-isystem` pointing
--                                    at `xim:glibc` and `xim:linux-headers` it
--                                    reads the host's `/usr/include`. The rule
--                                    requires both declarations and refuses
--                                    naming them when they are absent; both are
--                                    unpinned, because the C library version is
--                                    the runtime binding's choice and differs
--                                    between a developer machine and a runner
--
-- The floor recorded for this package is the HIGHEST of those, so it is the
-- collection's floor rather than any one feature's: a project on 2026.9.5.4
-- that wants only `rules-cuda` is refused by it. Splitting the package per
-- member is the alternative and is not taken, because one host-module package
-- is what makes the collection a collection. The
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
            ["0.2.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mcpp-plugins/archive/refs/tags/v0.2.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mcpp-plugins/releases/download/0.2.1/mcpp-plugins-0.2.1.tar.gz",
                },
                sha256 = "86dcc5975f7fb17910182bc890536fa2685ef2ca947a405969bd9c74e49a48fe",
            },
            ["0.2.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mcpp-plugins/archive/refs/tags/v0.2.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mcpp-plugins/releases/download/0.2.0/mcpp-plugins-0.2.0.tar.gz",
                },
                sha256 = "b5ee0cf41f156a3a327c665a84cc60769864f171f20965568255147f06fd4ca2",
            },
            ["0.1.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mcpp-plugins/archive/refs/tags/v0.1.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mcpp-plugins/releases/download/0.1.1/mcpp-plugins-0.1.1.tar.gz",
                },
                sha256 = "f2c82e72094b64dddb4edee75173851691e52de9680cd2d07bee5b557d805949",
            },
            ["0.1.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mcpp-plugins/archive/refs/tags/v0.1.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mcpp-plugins/releases/download/0.1.0/mcpp-plugins-0.1.0.tar.gz",
                },
                sha256 = "adf1f9d6691a5d05a8a4a94e83c733ea39caee1510ce2c9af4cb23bebabea9f5",
            },
            ["latest"] = { ref = "0.2.1" },
        },
        macosx = {
            ["0.2.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mcpp-plugins/archive/refs/tags/v0.2.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mcpp-plugins/releases/download/0.2.1/mcpp-plugins-0.2.1.tar.gz",
                },
                sha256 = "86dcc5975f7fb17910182bc890536fa2685ef2ca947a405969bd9c74e49a48fe",
            },
            ["0.2.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mcpp-plugins/archive/refs/tags/v0.2.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mcpp-plugins/releases/download/0.2.0/mcpp-plugins-0.2.0.tar.gz",
                },
                sha256 = "b5ee0cf41f156a3a327c665a84cc60769864f171f20965568255147f06fd4ca2",
            },
            ["0.1.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mcpp-plugins/archive/refs/tags/v0.1.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mcpp-plugins/releases/download/0.1.1/mcpp-plugins-0.1.1.tar.gz",
                },
                sha256 = "f2c82e72094b64dddb4edee75173851691e52de9680cd2d07bee5b557d805949",
            },
            ["0.1.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mcpp-plugins/archive/refs/tags/v0.1.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mcpp-plugins/releases/download/0.1.0/mcpp-plugins-0.1.0.tar.gz",
                },
                sha256 = "adf1f9d6691a5d05a8a4a94e83c733ea39caee1510ce2c9af4cb23bebabea9f5",
            },
            ["latest"] = { ref = "0.2.1" },
        },
        windows = {
            ["0.2.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mcpp-plugins/archive/refs/tags/v0.2.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mcpp-plugins/releases/download/0.2.1/mcpp-plugins-0.2.1.tar.gz",
                },
                sha256 = "86dcc5975f7fb17910182bc890536fa2685ef2ca947a405969bd9c74e49a48fe",
            },
            ["0.2.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mcpp-plugins/archive/refs/tags/v0.2.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mcpp-plugins/releases/download/0.2.0/mcpp-plugins-0.2.0.tar.gz",
                },
                sha256 = "b5ee0cf41f156a3a327c665a84cc60769864f171f20965568255147f06fd4ca2",
            },
            ["0.1.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mcpp-plugins/archive/refs/tags/v0.1.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mcpp-plugins/releases/download/0.1.1/mcpp-plugins-0.1.1.tar.gz",
                },
                sha256 = "f2c82e72094b64dddb4edee75173851691e52de9680cd2d07bee5b557d805949",
            },
            ["0.1.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mcpp-plugins/archive/refs/tags/v0.1.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mcpp-plugins/releases/download/0.1.0/mcpp-plugins-0.1.0.tar.gz",
                },
                sha256 = "adf1f9d6691a5d05a8a4a94e83c733ea39caee1510ce2c9af4cb23bebabea9f5",
            },
            ["latest"] = { ref = "0.2.1" },
        },
    },

    -- The package's own manifest, at the archive root.
    mcpp = "*/mcpp.toml",
}
