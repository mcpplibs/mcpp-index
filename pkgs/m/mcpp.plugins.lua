-- mcpp:plugins -- the build plugins the mcpp project maintains, one package,
-- each member selected by a feature.
--
--   [dependencies.mcpp]
--   plugins = { version = "0.5.0", features = ["rules-spirv"], host-module = true }
--
--   // build.mcpp
--   import mcpp;
--   import mcpp.rules.spirv;
--
-- 0.3.0 is the release in which an embedded payload is reached by IMPORTING a
-- module rather than by including a header whose name the rule chose. It also
-- adds two members and the two declarations that let a rule package introduce a
-- device language on its own. It requires **mcpp 2026.9.7.1**, which is where
-- those declarations are read.
--
--   mcpp.rules.slang  `rules-slang`  >= 2026.9.7.1. Slang is a language rather
--                                    than a second driver for GLSL -- its own
--                                    module system, generics, and targets
--                                    beyond SPIR-V -- so it has its own rule
--                                    and its own extension. `.slang` is NOT in
--                                    the engine's built-in table: this feature
--                                    declares `device_extensions = [".slang"]`
--                                    and `rule_module = "mcpp.rules.slang"`,
--                                    and the engine routes it from there. That
--                                    is the criterion for the whole
--                                    arrangement -- a new device language costs
--                                    no engine release
--   mcpp.tools.island `tools-island` >= 2026.9.7.1. Generates the `extern "C"`
--                                    boundary a device island is reached
--                                    across: the header its compiler reads and
--                                    the module the C++ side imports, from
--                                    declarations marked where they are
--                                    defined. Handed both halves of a seam, it
--                                    refuses two that declare one name
--                                    differently -- the only check available at
--                                    a boundary where C linkage does not mangle
--                                    and the two halves never meet at the link
--
-- Every rule that generates a consumer-facing declaration now chooses a module
-- interface or a header from `[language] modules`, which the engine reports; and
-- a project that declares its rules needs no `build.mcpp` at all, because mcpp
-- writes the program those declarations describe.
--
-- Members of 0.3.0, with the mcpp release each relies on:
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
-- 0.2.6 fixes a generated artifact that could not be included on its own, and
-- the shape of the defect is worth the paragraph. `mcpp.rules.spirv` chooses
-- between two shader compilers, and the whole premise of that choice is that
-- they produce an EQUIVALENT header. glslc emits an initialiser list, so the
-- rule already wrote the declaration around it -- and wrote `#pragma once` and
-- `#include <cstdint>` while it was there. glslang emits a complete C
-- declaration, so the rule wrote nothing, and that file named `uint32_t` while
-- including nothing:
--
--   tri_vert.h:3:7: error: 'uint32_t' does not name a type
--
-- Every consumer that worked had put a Vulkan header in front of it, so an
-- incomplete header read as a working one for as long as nobody included it
-- first. A sandbox on a clean machine is what found it. Both routes now
-- produce the same two files: `<base>.inc` from the compiler, `<base>.h` from
-- the rule. An existing build directory upgrades in place -- measured.
--
-- It also gives the "every rule compiles for this host" fixture its own
-- denominator: that fixture asserts EVERY rule, and "every" was a list it
-- carried, so a seventh member would have been covered by a step whose name
-- said it already was. The list is now compared against the package's own
-- `[features]` before the build.
--
-- The exact `xim:shaderc` pin described below is unchanged in this release: it
-- reverts to `>=2026.3` once an mcpp carrying the cmd-escaping fix is
-- published.
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
-- 0.4.0 moves the shared floor to 2026.9.8.1, and it is the COLLECTION's rather
-- than any member's. The package now divides into two units by what each may
-- import: `src/plugins.cppm` carries the generator and imports only `std`, so
-- the same code compiles into `mcpp-embed`; `src/declare.cppm` carries the
-- build-program half. Before 2026.9.8.1 a package's host modules were ordered
-- by PATH, so `rules/` was compiled before `src/` and importing the second unit
-- failed with "failed to read compiled module".
--
-- WHY THE SPLIT EXISTS. Under `storage::object` the generated assembly names
-- each payload in `.incbin`, and the object it produces IS those bytes -- while
-- the assembly's own text does not change when they do. Generated at plan time
-- it was assembled once, and every later payload change was a green build over
-- stale bytes; measured against 0.3.0 in a sandbox, from these very packages.
-- So the generation is an ACTION now, its command is `mcpp-embed`, and the
-- payloads are its declared inputs. That is the ordinary graph primitive and
-- needed no new engine channel. A consumer asks for the tool on the same edge
-- as the rules -- `tools = ["mcpp-embed"]` -- and only for that storage; the
-- default `header` storage builds no program.
--
-- 0.4.0 also passes a depfile from all six rules, so a shader or kernel that
-- `#include`s another file rebuilds when that file changes. Each spelling was
-- measured against the tool rather than read from its help text.
--
-- BREAKING: `surface::options` gained `target_os` and `has_gas_assembler` and
-- stopped reading its environment, which is why this is 0.4.0 and not 0.3.1.
--
-- The floor before it was the HIGHEST of the per-member ones, and from 0.3.0
-- every member shared one:
-- 2026.9.7.1 -- the release that reads `device_extensions` and `rule_module`,
-- reports `[language] modules` and the package's own name to a build program,
-- and writes the build program a declared rule set describes. A client below it
-- does not see a degraded surface, it sees the rules never route: the file falls
-- through to the ordinary source scan and mcpp says it has no role for the
-- extension. It is DOCUMENTATION rather than a gate -- nothing in this
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
-- 0.5.0 gives an island's entry points the module's own namespace. `docs/42`
-- states one rule for both lanes -- the module name and the namespace are one
-- identifier path -- and the shader lane followed it while `mcpp.tools.island`
-- did not: every entry point was emitted at global scope, so `import
-- app.kernels` bought a file name and nothing else. A root's directories now
-- extend the namespace exactly as a payload tree's do.
--
-- The API says roots rather than files. `options::roots` names the directories
-- implementations live under and `options::layout_root` names the one whose
-- structure decides where entry points live; every other root only has to
-- define the same names. `options::strip_prefix` emits a short spelling beside
-- the authored name, which stays canonical because it is the symbol.
--
-- It is BREAKING for a consumer of `tools-island`: a qualified name replaces a
-- global one. Every published consumer pins an exact version, so moving
-- `latest` breaks none of them, and the three examples in mcpp that use the
-- generator move to 0.5.0 in the same batch.
--
-- The floor does not move. 0.5.0 changes what the package generates, not what
-- it asks the engine for, so it stays at mcpp 2026.9.8.1.
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
            ["0.5.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mcpp-plugins/archive/refs/tags/v0.5.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mcpp-plugins/releases/download/0.5.0/mcpp-plugins-0.5.0.tar.gz",
                },
                sha256 = "ec11aa99e84d8d003afff9d93a9e76d8b84926ab2586058ee5d51344559777b9",
            },
            ["0.4.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mcpp-plugins/archive/refs/tags/v0.4.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mcpp-plugins/releases/download/0.4.0/mcpp-plugins-0.4.0.tar.gz",
                },
                sha256 = "85a137482baf8890d474e58a051ff8d7e9559d696e3a0c7a17909efd922f33ce",
            },
            ["0.3.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mcpp-plugins/archive/refs/tags/v0.3.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mcpp-plugins/releases/download/0.3.0/mcpp-plugins-0.3.0.tar.gz",
                },
                sha256 = "c4ce00e2b79c43ee4a08a8876a8ab7113f41081895a6036dfede6aa7719d731b",
            },
            ["0.2.6"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mcpp-plugins/archive/refs/tags/v0.2.6.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mcpp-plugins/releases/download/0.2.6/mcpp-plugins-0.2.6.tar.gz",
                },
                sha256 = "5bbeb6b8058afba98c60d5611bf183294546109c7a3044de79623e37f7425c9c",
            },
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
            ["latest"] = { ref = "0.5.0" },
        },
        macosx = {
            ["0.5.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mcpp-plugins/archive/refs/tags/v0.5.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mcpp-plugins/releases/download/0.5.0/mcpp-plugins-0.5.0.tar.gz",
                },
                sha256 = "ec11aa99e84d8d003afff9d93a9e76d8b84926ab2586058ee5d51344559777b9",
            },
            ["0.4.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mcpp-plugins/archive/refs/tags/v0.4.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mcpp-plugins/releases/download/0.4.0/mcpp-plugins-0.4.0.tar.gz",
                },
                sha256 = "85a137482baf8890d474e58a051ff8d7e9559d696e3a0c7a17909efd922f33ce",
            },
            ["0.3.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mcpp-plugins/archive/refs/tags/v0.3.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mcpp-plugins/releases/download/0.3.0/mcpp-plugins-0.3.0.tar.gz",
                },
                sha256 = "c4ce00e2b79c43ee4a08a8876a8ab7113f41081895a6036dfede6aa7719d731b",
            },
            ["0.2.6"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mcpp-plugins/archive/refs/tags/v0.2.6.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mcpp-plugins/releases/download/0.2.6/mcpp-plugins-0.2.6.tar.gz",
                },
                sha256 = "5bbeb6b8058afba98c60d5611bf183294546109c7a3044de79623e37f7425c9c",
            },
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
            ["latest"] = { ref = "0.5.0" },
        },
        windows = {
            ["0.5.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mcpp-plugins/archive/refs/tags/v0.5.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mcpp-plugins/releases/download/0.5.0/mcpp-plugins-0.5.0.tar.gz",
                },
                sha256 = "ec11aa99e84d8d003afff9d93a9e76d8b84926ab2586058ee5d51344559777b9",
            },
            ["0.4.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mcpp-plugins/archive/refs/tags/v0.4.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mcpp-plugins/releases/download/0.4.0/mcpp-plugins-0.4.0.tar.gz",
                },
                sha256 = "85a137482baf8890d474e58a051ff8d7e9559d696e3a0c7a17909efd922f33ce",
            },
            ["0.3.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mcpp-plugins/archive/refs/tags/v0.3.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mcpp-plugins/releases/download/0.3.0/mcpp-plugins-0.3.0.tar.gz",
                },
                sha256 = "c4ce00e2b79c43ee4a08a8876a8ab7113f41081895a6036dfede6aa7719d731b",
            },
            ["0.2.6"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mcpp-plugins/archive/refs/tags/v0.2.6.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mcpp-plugins/releases/download/0.2.6/mcpp-plugins-0.2.6.tar.gz",
                },
                sha256 = "5bbeb6b8058afba98c60d5611bf183294546109c7a3044de79623e37f7425c9c",
            },
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
            ["latest"] = { ref = "0.5.0" },
        },
    },

    -- The package's own manifest, at the archive root.
    mcpp = "*/mcpp.toml",
}
