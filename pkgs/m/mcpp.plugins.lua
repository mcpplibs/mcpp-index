-- mcpp:plugins -- the build plugins the mcpp project maintains, one package,
-- each member selected by a feature.
--
--   [dependencies.mcpp]
--   plugins = { version = "0.2.5", features = ["rules-spirv"], host-module = true }
--
--   // build.mcpp
--   import mcpp;
--   import mcpp.rules.spirv;
--
-- Members of 0.2.5, with the mcpp release each relies on:
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
-- 0.2.5 is the release in which the collection stopped being a Linux
-- collection. Three things changed and none of them is a new member.
--
-- ONE SHADER COMPILER PER PLATFORM. `xim:glslang` is published for Linux
-- alone, so `rules-spirv` reached one platform even though the Vulkan and
-- OpenGL libraries in the index reach three -- the gap sat in the middle
-- layer, where a developer on Windows could link Vulkan, open a window and
-- draw a triangle provided they brought their own shader compiler, which is
-- the one thing a build system is for. macOS and Windows now take
-- `xim:shaderc`, and the rule CHOOSES between the two, so cross-platform
-- parity is provided by the rule's ability to choose rather than by
-- publishing one compiler three times.
--
-- CUDA AND SYCL ON WINDOWS. NVIDIA and Intel both publish Windows assets for
-- the components these rules drive, so this was recipe work rather than
-- packaging work: `xim:cuda-nvcc`, `xim:cuda-cudart`, `xim:cuda-cccl`,
-- `xim:libcurand` and `xim:dpcpp` gained Windows sections in xim-pkgindex,
-- and the rules gained the host-dependent halves that go with them -- the
-- `.exe` suffix, `lib/x64`, and the decision that on Windows the CUDA rule
-- takes its clang route whatever the project's compiler is, because the nvcc
-- route needs MSVC's cl.exe located by asking the machine about its Visual
-- Studio installation.
--
-- AND EVERY RULE IS NOW COMPILED FOR EVERY PLATFORM. Each consumer in that
-- repository drives one rule end to end and therefore needs that rule's
-- payload, and payloads are published for one, two or three platforms -- so
-- the half of a rule written for a host was exactly the half that host never
-- compiled. A fixture that names no accelerator (every rule returns
-- immediately, nothing is downloaded) now compiles all six modules on Linux,
-- macOS and Windows. It found three defects on its first run, one per host
-- difference, none of them visible to a Linux build.
--
-- ONE DECLARATION IN THIS RELEASE IS AN EXACT VERSION WHERE THE SHAPE
-- WOULD BE A FLOOR. `xim:shaderc` is pinned rather than floored on macOS and
-- Windows because mcpp 2026.9.6.6 cannot pass a `>` through a Windows command
-- line: the JSON provisioning argument is escaped for the child's argv parser
-- and cmd.exe reads the `>` in `>=2026.3` as a redirection, answering `The
-- filename, directory name, or volume label syntax is incorrect.` An exact
-- version is a legitimate declaration -- mcpp reads it as a CHOICE, so a
-- project pinning a different one still wins -- and it reverts to a floor once
-- a released engine escapes that argument.
--
-- 0.2.4 moves every member's floor to the same release, 2026.9.6.6, and the
-- reason is one change in the engine rather than five in the rules: a payload
-- a DEPENDENCY declared is now both installed and ANSWERABLE. Before it,
-- `mcpp::xpkg_dir` compared the whole version position against a directory
-- name, so a rule could declare `>=8.5.0`, have it installed, and still be told
-- nothing was there -- which is why every project using a rule repeated that
-- rule's own package list.
--
-- So each rule now declares the payloads it drives, under the feature that
-- selects it and the accelerator it serves:
--
--   [target.'cfg(accelerator = "cuda")'.feature-xlings.rules-cuda]
--   "xim:cuda-nvcc" = "12.9.86"
--
-- Two gates, and both must open before a byte is downloaded: the feature says
-- whether the rule is wanted, the selector says whether this build compiles for
-- the device. A consumer writes the dependency edge and nothing else.
--
-- The SHAPE of each default is a judgement about coupling rather than a style.
-- An exact version where the payload's version is coupled to something the rule
-- cannot see -- a CUDA runtime must not be newer than the driver it will meet,
-- and the 12.9 line reaches every driver from r525 where 13.x raises that to
-- r580. A floor (`>=`) where no such coupling exists: glslang, dpcpp, the CANN
-- toolkit. mcpp reads the difference: a bare version is a CHOICE, so a project
-- pinning a different one wins and the override is reported; a `>=` is a
-- REQUIREMENT, so a project pinning below it is refused naming both sides.
-- Either way one version is installed.
--
-- NOT declared by the rules: anything the produced PROGRAM chooses to run on. A
-- Vulkan ICD is a device, and a rule declaring one would force a software
-- renderer onto consumers that have a GPU. The runtime adapters
-- (`compat:cuda-runtime`, `compat:sycl-runtime`, `compat:vulkan-runtime`) stay
-- in the project for that reason and for a structural one: this package is
-- reached through a `[build-dependencies]` edge, so its own `[dependencies]`
-- deliberately do not reach the consumer's target.
--
-- 0.2.3 adds `mcpp.rules.ascendc`, the first member for a vendor this
-- collection had not built for, and it carries the collection's new floor:
-- 2026.9.6.5. Two things in that release are load-bearing for it -- `.asc` in
-- the device-source table, and `mcpp::link_flag`, without which the rule
-- cannot emit the `-Wl,-rpath-link` that GNU ld needs to resolve the CANN
-- libraries' own DT_NEEDED entries (`-L` does not serve that purpose, and the
-- link fails on `memset_s` and `CheckLogLevel`, symbols of libraries nobody
-- named).
--
-- The rule compiles with BiSheng in MIXED mode rather than `--cce-aicore-only`,
-- so what comes out is a host object carrying the device binary and a
-- host-callable launcher -- an object the ordinary link takes, with no
-- registration file and no device-link step. Verified on a machine with no
-- Ascend hardware: the kernel compiles and the artifact links, and only
-- `libascend_hal.so`, which belongs to the DRIVER, is missing.
--
-- 0.2.2 changes every rule at once and changes none of the floors. Each rule
-- now takes only the device sources whose EXTENSION it claims -- `.cu`,
-- `.hip`, `.sycl`, the shader stages -- instead of the whole of
-- `mcpp::device_sources()`, which is the package's set and not one rule's
-- share of it. Taking all of it is right for exactly as long as a build has one
-- rule in it; with two, measured, the CUDA rule compiled a `.comp` AS CUDA and
-- produced an object while the shader rule failed on the `.cu`. A rule whose
-- backend the build does not name now also returns without complaint, which is
-- what lets a build program call every rule it imports unconditionally.
--
-- No floor moves, because none of that needs a newer engine. mcpp 2026.9.6.5
-- adds the engine's half -- a device source that reached no action is refused,
-- naming the file -- but a rule package does not require it to work.
--
-- The floor is the HIGHEST of those, and from 0.2.4 every member shares one:
-- 2026.9.6.6. It is DOCUMENTATION rather than a gate -- nothing in this
-- descriptor or in the package's manifest records a per-package engine floor,
-- and the index-level `min_mcpp` is deliberately not raised for a package
-- (raising it would make the whole index unreadable to clients stopped below
-- it). What an older client gets instead is legible at the point of use: on
-- 2026.9.6.5 the rule's payload table is folded and installed and `xpkg_dir`
-- cannot answer a range, so the rule reports its toolkit as absent and names
-- the floor; at or below 2026.9.6.4 the `cfg(accelerator = ...)` selector on a
-- tool table is refused outright, naming the tool and the predicate. Splitting the package per
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
            ["0.2.5"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mcpp-plugins/archive/refs/tags/v0.2.5.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mcpp-plugins/releases/download/0.2.5/mcpp-plugins-0.2.5.tar.gz",
                },
                sha256 = "e720350af4bc9ae05e43da8f55651ae1f9e87de88749070546a86441ae459df8",
            },
            ["0.2.4"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mcpp-plugins/archive/refs/tags/v0.2.4.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mcpp-plugins/releases/download/0.2.4/mcpp-plugins-0.2.4.tar.gz",
                },
                sha256 = "abcf165e49e631f380141ea66e32f7a9d4cc6179d1f0f984eed906b7924d9b66",
            },
            ["0.2.3"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mcpp-plugins/archive/refs/tags/v0.2.3.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mcpp-plugins/releases/download/0.2.3/mcpp-plugins-0.2.3.tar.gz",
                },
                sha256 = "6dbbf8444ffce33ec9d54db536de9b70382272a29eb76ae51cfa12cbf2500fec",
            },
            ["0.2.2"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mcpp-plugins/archive/refs/tags/v0.2.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mcpp-plugins/releases/download/0.2.2/mcpp-plugins-0.2.2.tar.gz",
                },
                sha256 = "7cffa97b13f2eda3cdb8474f13fc257f01cd56d5bdc4f7cf31a0cd25e10b9844",
            },
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
            ["latest"] = { ref = "0.2.5" },
        },
        macosx = {
            ["0.2.5"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mcpp-plugins/archive/refs/tags/v0.2.5.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mcpp-plugins/releases/download/0.2.5/mcpp-plugins-0.2.5.tar.gz",
                },
                sha256 = "e720350af4bc9ae05e43da8f55651ae1f9e87de88749070546a86441ae459df8",
            },
            ["0.2.4"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mcpp-plugins/archive/refs/tags/v0.2.4.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mcpp-plugins/releases/download/0.2.4/mcpp-plugins-0.2.4.tar.gz",
                },
                sha256 = "abcf165e49e631f380141ea66e32f7a9d4cc6179d1f0f984eed906b7924d9b66",
            },
            ["0.2.3"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mcpp-plugins/archive/refs/tags/v0.2.3.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mcpp-plugins/releases/download/0.2.3/mcpp-plugins-0.2.3.tar.gz",
                },
                sha256 = "6dbbf8444ffce33ec9d54db536de9b70382272a29eb76ae51cfa12cbf2500fec",
            },
            ["0.2.2"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mcpp-plugins/archive/refs/tags/v0.2.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mcpp-plugins/releases/download/0.2.2/mcpp-plugins-0.2.2.tar.gz",
                },
                sha256 = "7cffa97b13f2eda3cdb8474f13fc257f01cd56d5bdc4f7cf31a0cd25e10b9844",
            },
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
            ["latest"] = { ref = "0.2.5" },
        },
        windows = {
            ["0.2.5"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mcpp-plugins/archive/refs/tags/v0.2.5.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mcpp-plugins/releases/download/0.2.5/mcpp-plugins-0.2.5.tar.gz",
                },
                sha256 = "e720350af4bc9ae05e43da8f55651ae1f9e87de88749070546a86441ae459df8",
            },
            ["0.2.4"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mcpp-plugins/archive/refs/tags/v0.2.4.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mcpp-plugins/releases/download/0.2.4/mcpp-plugins-0.2.4.tar.gz",
                },
                sha256 = "abcf165e49e631f380141ea66e32f7a9d4cc6179d1f0f984eed906b7924d9b66",
            },
            ["0.2.3"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mcpp-plugins/archive/refs/tags/v0.2.3.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mcpp-plugins/releases/download/0.2.3/mcpp-plugins-0.2.3.tar.gz",
                },
                sha256 = "6dbbf8444ffce33ec9d54db536de9b70382272a29eb76ae51cfa12cbf2500fec",
            },
            ["0.2.2"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mcpp-plugins/archive/refs/tags/v0.2.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mcpp-plugins/releases/download/0.2.2/mcpp-plugins-0.2.2.tar.gz",
                },
                sha256 = "7cffa97b13f2eda3cdb8474f13fc257f01cd56d5bdc4f7cf31a0cd25e10b9844",
            },
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
            ["latest"] = { ref = "0.2.5" },
        },
    },

    -- The package's own manifest, at the archive root.
    mcpp = "*/mcpp.toml",
}
