-- mcpp:plugins -- the build plugins the mcpp project maintains, one package,
-- each member selected by a feature.
--
--   [dependencies.mcpp]
--   plugins = { version = "0.15.1", features = ["rules-spirv"], host-module = true }
--
--   // build.mcpp
--   import mcpp;
--   import mcpp.rules.spirv;
--
-- 0.15.1 (same mcpp floor): a vcpkg installation waits for another one of
-- the same root (`--x-wait-for-lock`) instead of failing; two workspace
-- members installing one root ran at once and one failed under 0.15.0.
-- mcpp-community/mcpp-plugins#33.
--
-- 0.15.0 (same mcpp floor): features state mechanisms, and `build.mcpp` is
-- where a project configures them. `rules-qt-xim`, `rules-qt-xim-base` and
-- `rules-qt-xim-addons` are removed: `rules-qt` takes the SDK from
-- `options::root`, then `QT_ROOT_DIR`, then a Qt payload the project declares
-- in its own `[xlings]` table at the version it chooses, and the payload
-- carries its runtime closure (Linux: libdbus, xcb and the rest under the
-- xlings loader; Windows: the VC++ runtime). The deps members run the
-- installer itself -- `vcpkg install`, or `cmake -P` over a script they write
-- -- so the `mcpp-deps` tool is gone and an edge names no `tools`. On Linux
-- under a libc++ toolchain, ports and CMake subprojects build with mcpp's
-- clang; each vcpkg triplet is its own installation
-- (`<install root>/<triplet>/<triplet>`). docs/plugin-development.md states
-- the conventions. mcpp-community/mcpp-plugins#32.
--
-- 0.14.0 (same mcpp floor) places the files a program reads at run time
-- beside it, so `mcpp run` finds them and `mcpp pack` carries them: each file
-- is produced by an action that names it as an output and is then deployed.
-- `deps-archive` extracts a zip the project keeps (its central directory lists
-- the members while the build program runs; `cmake -E tar` from `xim:cmake`
-- extracts it); `deps-vcpkg` and `deps-cmake` take `options::deploy`, files of
-- the installed prefix; `rules-qt` takes `translations::qt_languages`, Qt's
-- own strings, which `lconvert` combines for the linked modules into
-- `qt_<language>.qm` as windeployqt does. `rules-qt-xim-base` declares
-- `xim:qt-base` -- qtbase, qttools, qttranslations and the QtQml library
-- lupdate loads -- about a third of `xim:qt`'s download.
-- mcpp-community/mcpp-plugins#31.
--
-- 0.13.1 (same mcpp floor): `rules-qt` runs `lupdate` as an action whose
-- output is the `.ts` file it rewrites. 0.13.0 declared the `.ts` file's
-- directory as a `prepare` output, which for a `.ts` kept in the package root
-- is the package's source directory. mcpp-community/mcpp-plugins#30.
--
-- 0.13.0 requires **mcpp 2026.9.26.2** for its new members and nothing newer
-- for the rest; they are selected by feature, so a project that selects none
-- of them compiles none of them. A fourth family, `deps-*`, states where a
-- library comes from, following mcpp's build-plugin specification (SPEC-007):
-- `deps-vcpkg` installs a `vcpkg.json` manifest and `deps-cmake` a CMake
-- subproject, each as a `prepare` action with an output directory whose
-- command is the package's own host tool (`tools = ["mcpp-deps"]`). The build
-- program states the prefix before anything is installed -- include
-- directory, libraries by full path, and the shared-library directory as a
-- runtime search directory -- so `mcpp emit build-database` plans a project
-- that has never been built, `mcpp run` and `mcpp pack` find the libraries,
-- and on Windows the engine places the DLLs beside the program. `deps-vcpkg`
-- declares `xim:vcpkg` (vcpkg-tool with the scripts released beside it; a
-- `builtin-baseline` manifest resolves through vcpkg's git registry cache);
-- `deps-cmake` declares `xim:cmake`. `rules-qt` runs moc, uic, rcc and
-- lrelease as actions and lupdate as a `prepare` action, links the Qt modules
-- by full path and deploys the plugin directories beside the program;
-- `rules-qt-xim` declares `xim:qt` 6.11.1 and `rules-qt-xim-addons` adds
-- `xim:qt-addons`. On Linux the rule serves QtCore programs, which state
-- `[build] cxx_runtime = "toolchain-coupled"` (mcpp-community/mcpp#704).
-- mcpp-community/mcpp-plugins#29.
--
-- 0.12.0 requires **mcpp 2026.9.16.1** for the members that read the resolved
-- graph, and nothing newer for the rest. A package states what it contributes
-- to an application in its own manifest -- `[package.metadata.dist-apk]`
-- (Android source roots, resources, assets, a manifest, jars and aars) and
-- `[package.metadata.dist-apple]` (an Info.plist fragment) -- and the root
-- build program reads them from the graph mcpp hands it, applying each package
-- above the packages it depends on, with the application's own options above
-- all of them. `options::graph_libraries` and `options::graph_info_plist` turn
-- the collection off. Under an older engine there is no graph, the variable is
-- absent, and a package is built without the contribution exactly as before.
--
-- `dist-apk` also follows the engine's strip decision from that release
-- (`MCPP_PACK_STRIP`, `MCPP_PACK_DEBUG_SYMBOLS_DIR`): a library the engine
-- staged is packed as staged, because the engine has already applied
-- `--no-strip` or `--debug-symbols` to it, and the member strips only what it
-- stages itself. `dist-apple` gains `options::omit_keys`, which leaves out a
-- key the member only defaults; `dist-web` gains `options::page`, which names
-- the page (`index.html` by default). `rules-swift` compiles a package's
-- `.swift` sources in one whole-module `swiftc` action on macOS, the iOS
-- simulator and the iOS device row, refusing every other row by name.
--
-- 0.11.1 (same mcpp floor): `dist-apk` strips each native library with the
-- build's own `llvm-strip --strip-unneeded` (`options::keep_debug_symbols`
-- keeps them as staged) and, when the manifest states
-- `android:extractNativeLibs="false"`, stores them uncompressed on a 16 KB
-- page, as the Android Gradle plugin packages them. `dist-appimage` takes an
-- SVG icon as well as a PNG. mcpp-community/mcpp-plugins#27.
--
-- 0.11.0 (same mcpp floor): `dist-apk` compiles Kotlin beside Java
-- (`options::kotlin_sources`; `xim:kotlin` comes with the `dist-apk-kotlin`
-- feature), links the R classes a project's code reads, and takes Android
-- libraries from source (`options::libraries`), local archives
-- (`options::aars`, `options::jars`) and Maven coordinates resolved into a lock
-- file by `xim:coursier` (the `dist-apk-maven` feature; only
-- `MCPP_DIST_APK_MAVEN=update` and `=fetch` reach the network). Library
-- manifests are merged by a stated subset, and `options::sign = false` writes
-- an unsigned package. `dist-apple` adds a project's Info.plist entries
-- (`options::info_plist`), embeds a provisioning profile on the iOS device row,
-- and runs a device bundle through `devicectl-run` (`xim:apple-device-tools`).
-- The Android build host is Linux: mcpp does not link an Android row on a
-- macOS host yet (mcpp#647). mcpp-community/mcpp-plugins#26.
--
-- 0.10.1 (same mcpp floor): `dist-wix` installs the staged tree, not the
-- program alone. The files `mcpp pack` stages beside the program -- deployed
-- data, resolved DLLs; for a PE program at the root of the tree -- are named
-- file by file in a `StagedFiles` component group the generated definition
-- references and a project's own `options::wxs` installs with
-- `<ComponentGroupRef Id="StagedFiles" />`; `options::inputs` and
-- `options::bundle_inputs` declare what a project's own definitions name
-- beyond that. mcpp-community/mcpp-plugins#25.
--
-- 0.10.0 requires **mcpp 2026.9.14.2**, the release that stages the native
-- closure of an Android or Mach-O program and names every library in the
-- stage manifest's `needs` lines (mcpp#634 A3), leaves an `@executable_path`
-- rpath as written, and reaches the runner named after `mcpp run --format`.
-- The plugin half of mcpp#634:
--
--   dist-apk     reads the staged closure (`lib/` for one `--target`,
--                `lib/<abi>/` for several) in place of its own `NEEDED` walk,
--                so a second pack keeps a dependency's library and one APK
--                carries every ABI the tree was packed for. A stage without
--                `needs` lines comes from an older engine and is refused
--                naming 2026.9.14.2. `--format aab` writes an App Bundle with
--                `xim:bundletool`.
--   dist-apple   places the staged dylibs in `Contents/Frameworks/`
--                (`Frameworks/` on iOS), links the program with the rpath that
--                finds them there, signs a macOS bundle without an identity ad
--                hoc (frameworks first), supplies the runner named `app` on
--                macOS (`xim:macapp-run`, installed for `mcpp run` only), and
--                gains `--format dmg`.
--   dist-wix     `--format setup`: a Burn bundle chaining the MSI, with the
--                stock bootstrapper application from `xim:wix` 5.0.2-1.
--   rules-metal  new. `.metal` shaders become Metal libraries through the
--                macOS host's Xcode toolchain, located rather than installed.
--
-- mcpp-community/mcpp-plugins#24.
--
-- 0.9.3 (same mcpp floor): `dist-apk` walks the app object's NEEDED at
-- command time and copies every graph-built shared library it finds beside
-- the object into `lib/<abi>/` -- the closure on this row is `not-walked`, so
-- a dependency declared `linkage = "shared"` (a framework's own `lib<fw>.so`)
-- never reached the archive before; and the manifest template gains
-- `{{version_name}}` / `{{version_code}}`. mcpp-community/mcpp-plugins#23.
--
-- 0.9.2 measures under **mcpp 2026.9.13.2**, the release that stages a Mach-O
-- program's tree before the closure walk (mcpp#630, item 3a): `dist-apple`
-- places the staged tree's deployed files at the bundle's resource
-- destination (`Contents/Resources/<to>/...` on macOS, the bundle root on
-- iOS) and the launcher alone in the executable directory. Its iOS fixture
-- declares `llvm.libcxx` and `llvm.compiler-rt-builtins` under
-- `cfg(os = "ios")`, which is what an application that imports `std` declares
-- on those rows from that release. mcpp-community/mcpp-plugins#22.
--
-- 0.9.1 (same mcpp floor as 0.9.0): `dist-apk` links a project's
-- `options::resources` positionally as the application's BASE resources --
-- 0.9.0 passed the compiled unit as `-R`, aapt2's overlay, which refuses every
-- resource the base does not already define, so a launcher icon, colour or
-- string could not be supplied at all. Its `xim:android-platform` pin moves
-- to 36-r2 (the recipe is in xim-pkgindex since openxlings/xim-pkgindex#834).
-- mcpp-community/mcpp-plugins#21.
--
-- 0.9.0 requires **mcpp 2026.9.13.1**. `dist-apk` takes a project manifest
-- template (`options::manifest_template`, six tokens, three required and
-- refused by name when absent) and `options::java_sources` as an array (one
-- `javac`, one `d8`); `dist-web` copies through the engine
-- (`${mcpp.self} stage --verify content --output <dst> <src>`), which is
-- what lets it run on a Windows host in place of the `cp` it used through
-- 0.8.0. Design record: mcpp `.agents/docs/2026-09-13-four-upstream-asks-from-a-ui-framework.md`.
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
-- 0.5.1 refuses overlapping roots, which 0.5.0's design record required and
-- 0.5.0 shipped without: a file reachable from two roots had two namespace
-- paths, and which one it got depended on the order of the list. It also stops
-- a single-file root from registering a re-run glob over the directory that
-- file happens to sit in.
--
-- 0.5.2 derives a namespace segment by path arithmetic rather than by string
-- surgery. The island fixture, run on Windows for the first time, put an entry
-- point in `app::kernels::_::image`: a root stated with forward slashes and a
-- directory iterator appending with the preferred separator left `\image`
-- rather than `image`, and the root directory became a segment. The shader lane
-- shares that function and had the same defect latent -- its Windows fixture
-- keeps every payload in one directory, so a segment was never derived there.
--
-- 0.6.0 adds a THIRD FAMILY, and the prefix is which of three questions a
-- member answers: `rules-*` how a translation unit is compiled, `tools-*` what
-- the build program does itself, `dist-*` what comes out of the LINK and in
-- what form a user installs it. A `dist-*` member compiles nothing and does
-- nothing while the build program runs: it consumes link outputs through a
-- `role = "artifact"` action, reached with `mcpp pack --format <name>`.
--
--   mcpp.dist.appimage `dist-appimage` >= 2026.9.11.1, Linux. Declares
--                                      `xim:appimagetool` on the `cfg(linux)`
--                                      axis and turns the tree `mcpp pack`
--                                      staged into one AppImage. The staged
--                                      bundle is already an AppDir bar three
--                                      files, so the member writes an
--                                      `AppRun`, a `.desktop` entry and an
--                                      icon into it and invokes one tool --
--                                      it never copies or re-lays-out a tree
--                                      that can be hundreds of megabytes.
--                                      `xim:appimagetool` carves its type-2
--                                      runtime stub out of itself, because
--                                      appimagetool otherwise downloads one on
--                                      every invocation and a build must not
--                                      reach the network
--   mcpp.dist.wix      `dist-wix`      >= 2026.9.11.1, Windows. The WiX 6 CLI
--                                      is a .NET tool and is not
--                                      redistributable through this ecosystem,
--                                      so it is LOCATED rather than installed
--                                      -- the `msvc@system` shape. It renders
--                                      a `.wxs` and passes the program in as a
--                                      preprocessor variable rather than
--                                      binding a directory: a bind path that
--                                      resolves to nothing produced a valid,
--                                      empty, 52 KB installer with no
--                                      diagnostic at all
--   mcpp.dist.apple    `dist-apple`    >= 2026.9.11.1, macOS. A `.app` bundle,
--                                      its `Info.plist`, and `codesign` only
--                                      when an identity is given -- a member
--                                      that signed by default would fail every
--                                      build on a machine with no identity in
--                                      its keychain. iOS is the same shape
--                                      plus a target row, which is a payload
--                                      rather than a redesign
--
-- 0.6.0 also adds `table()` to `mcpp.tools.embed`: N inputs, ONE header, ONE
-- table, where each row carries the input's key alongside its contents and the
-- consumer iterates. `file()` writes one header per input and `files()` writes
-- several; neither can express the shape a shader set wants. A duplicate key is
-- refused naming BOTH inputs, and the bytes are a numeric array rather than a
-- raw string literal, because a raw literal cannot carry arbitrary binary and
-- its delimiter is terminable by the input -- which is the defect in the CMake
-- code this shape replaces.
--
-- THE FLOOR IS STILL DOCUMENTATION AND NOT A GATE, unchanged from the note
-- below: nothing here records a per-package engine floor and the index-level
-- `min_mcpp` does not move for a package. What an older client gets is legible
-- at the point of use and is, for these three members, the best case of that
-- rule: `mcpp::provides_pack_format` does not exist in an older engine's
-- bundled `mcpp` module, so a consumer activating `dist-*` fails at the
-- build.mcpp COMPILE naming the missing function, rather than at a link or in
-- an artifact.
--
-- 0.7.0 is the release in which `mcpp.rules.slang` can say what a real Slang
-- project needs and could not before -- found by transcribing xrgui's shader
-- config (17 shaders, five common slangc flags, one shader with a flag of its
-- own, `.spv` files loaded at run time):
--
--   options::extra_args   slangc takes some two hundred options; the rule
--                         keeps the ones that decide WHAT is produced and
--                         passes the rest through verbatim, before `-o`
--   options::per_file     what one shader gets that the others do not. One
--                         `compile()` call writes one surface, so calling it
--                         twice rewrote the generated module with only the
--                         second call's shaders; a table keyed by the path
--                         the constrained glob names keeps the one call. A
--                         key naming no shader is REFUSED, listing the
--                         shaders seen
--   options::storage      the axis `rules-spirv` already had: header (embed,
--                         still the default), object, sidecar
--
-- and `profile_for` gains the Vulkan 1.4 row (SPIR-V 1.6). No engine floor
-- moves: everything is spelling inside the rule.
--
-- 0.7.1 changes no member's interface and records a compiler: under MSVC 14.52
-- (36629 and 36725, measured on xrgui's CI) a module whose BMI carries
-- `std::filesystem::path`'s iterator poisons every importer that touches
-- `path` again -- `filesystem(1572): error C2801: '_Path_iterator<...>::
-- operator ==' must be a non-static member`, the STL's own hidden friend.
-- Nothing in the package instantiates that iterator now: the lib root reads
-- paths apart as strings, and the members' relative-path arithmetic is one
-- string helper. Found by elimination in three probes; 0.7.0 is unusable on
-- that toolset for any consumer whose host modules touch a path.
--
-- 0.8.0 is the plugin half of mcpp#622 and needs mcpp 2026.9.12.3, the release
-- that carries the engine half: `kind = "app"`, `mcpp::deploy`, the `.js`
-- launcher and its staged stem family, `mcpp::min_platform_version()`,
-- `mcpp run --format`, and the build program's host compiler under a row's
-- pin. Four members change or appear:
--
--   dist-apk     new. An APK from an `app` target on `*-linux-android`:
--                aapt2 link, the native libraries (and `libc++_shared.so`
--                when the link NEEDs it), the deploy'd files under `assets/`,
--                zipalign, apksigner with `xim:android-debug-keystore`. Level 0
--                is `NativeActivity` with no Java; level 1 compiles a Java
--                host with javac and d8. Measured on the x86_64 emulator and on
--                an arm64 phone through `adb-run`: the program's line came back.
--   dist-web     new. The `.js`, `.wasm`, `.data` and deploy'd files of a
--                `wasm32-emscripten` program plus an `index.html`, as a static
--                directory. POSIX hosts.
--   dist-apple   the iOS row: a flat bundle, `MinimumOSVersion` from the
--                engine, no signing on the simulator, a terminal `bundle` step
--                so that `mcpp run --format app` has one operand. Measured on
--                macos-15: the simulator installed and launched it through
--                `simctl-run` 0.2.0.
--   dist-wix     locates WiX through `xim:wix` and nothing else; the earlier
--                PATH and MCPP_WIX tiers are gone.
--
-- The descriptor points at the source archive of the tag, as before; the CN
-- asset is the same bytes (compared byte for byte), so one sha256 names both.
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
            ["0.15.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mcpp-plugins/archive/refs/tags/v0.15.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mcpp-plugins/releases/download/0.15.1/mcpp-plugins-0.15.1.tar.gz",
                },
                sha256 = "7e91a1289e075bdd96bb5151f5c63fa3b12308b311e578ea639a447cc5a57160",
            },
            ["0.15.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mcpp-plugins/archive/refs/tags/v0.15.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mcpp-plugins/releases/download/0.15.0/mcpp-plugins-0.15.0.tar.gz",
                },
                sha256 = "2173fca40c72475fbb4682ff3dd97b5062d0895580e20f236f891eab59f5e2e5",
            },
            ["0.14.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mcpp-plugins/archive/refs/tags/v0.14.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mcpp-plugins/releases/download/0.14.0/mcpp-plugins-0.14.0.tar.gz",
                },
                sha256 = "fd5220adb891445d840d0963ba1f7347d2124f27ead0b14bb96db40719e37917",
            },
            ["0.13.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mcpp-plugins/archive/refs/tags/v0.13.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mcpp-plugins/releases/download/0.13.1/mcpp-plugins-0.13.1.tar.gz",
                },
                sha256 = "770741ae7cb83fb53d1d0623f4c709b386be8900135bf32ef29c8c446f72d9cd",
            },
            ["0.13.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mcpp-plugins/archive/refs/tags/v0.13.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mcpp-plugins/releases/download/0.13.0/mcpp-plugins-0.13.0.tar.gz",
                },
                sha256 = "297d28f9549ea3c6d86ab00109e0bf097ec72bf429a74c7f9030ab379a46d904",
            },
            ["0.12.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mcpp-plugins/archive/refs/tags/v0.12.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mcpp-plugins/releases/download/0.12.0/mcpp-plugins-0.12.0.tar.gz",
                },
                sha256 = "90a70689b090be7208c1f1f35487e148ed353a1bef0cec33d391bd46d67ba13f",
            },
            ["0.11.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mcpp-plugins/archive/refs/tags/v0.11.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mcpp-plugins/releases/download/0.11.1/mcpp-plugins-0.11.1.tar.gz",
                },
                sha256 = "8b6f009d747b90789e4d50adfcd45df64962d880c3f96387a1637c04c9239b67",
            },
            ["0.11.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mcpp-plugins/archive/refs/tags/v0.11.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mcpp-plugins/releases/download/0.11.0/mcpp-plugins-0.11.0.tar.gz",
                },
                sha256 = "bb58b43b7161bdc77e750124f9d676aad342a4f2299e4f165c508ffae6be5cd2",
            },
            ["0.10.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mcpp-plugins/archive/refs/tags/v0.10.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mcpp-plugins/releases/download/0.10.1/mcpp-plugins-0.10.1.tar.gz",
                },
                sha256 = "f5278f370e63179a32ffcef1145b90a7bbb3cac79c537eadc9014f6966ce2e01",
            },
            ["0.10.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mcpp-plugins/archive/refs/tags/v0.10.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mcpp-plugins/releases/download/0.10.0/mcpp-plugins-0.10.0.tar.gz",
                },
                sha256 = "b7cfa4b5d011d72cbd75fb96a459889a37a80e61dd903bf9142f582482d34a30",
            },
            ["0.9.3"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mcpp-plugins/archive/refs/tags/v0.9.3.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mcpp-plugins/releases/download/0.9.3/mcpp-plugins-0.9.3.tar.gz",
                },
                sha256 = "abdf812ce1d9d7777ab5a23284d5bcb33e0d6670dc0e93e4a4a04770157ce180",
            },
            ["0.9.2"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mcpp-plugins/archive/refs/tags/v0.9.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mcpp-plugins/releases/download/0.9.2/mcpp-plugins-0.9.2.tar.gz",
                },
                sha256 = "0c42984ec91b2e76cde72115ecf3d818ee48866141ae0a54037736b1a0c46def",
            },
            ["0.9.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mcpp-plugins/archive/refs/tags/v0.9.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mcpp-plugins/releases/download/0.9.1/mcpp-plugins-0.9.1.tar.gz",
                },
                sha256 = "de50556e8c3ea346298d2c3fd9ec2984c9ad3585118a38f0c4667b4b953554b0",
            },
            ["0.9.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mcpp-plugins/archive/refs/tags/v0.9.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mcpp-plugins/releases/download/0.9.0/mcpp-plugins-0.9.0.tar.gz",
                },
                sha256 = "9f7b17450dfd0a7683648945bbbd579a7fd1fc869b0d88dc36095d1d9eac7c60",
            },
            ["0.8.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mcpp-plugins/archive/refs/tags/v0.8.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mcpp-plugins/releases/download/0.8.0/mcpp-plugins-0.8.0.tar.gz",
                },
                sha256 = "088b500236d78ce7f4f88bc8e7c8f9bed00186be926896724c851ec9119946e7",
            },
            ["0.7.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mcpp-plugins/archive/refs/tags/v0.7.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mcpp-plugins/releases/download/0.7.1/mcpp-plugins-0.7.1.tar.gz",
                },
                sha256 = "a8d1b4dc8187c2b67a17d997245a4e4a3d52e26251f4c824fc5b951b58bbe293",
            },
            ["0.7.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mcpp-plugins/archive/refs/tags/v0.7.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mcpp-plugins/releases/download/0.7.0/mcpp-plugins-0.7.0.tar.gz",
                },
                sha256 = "165daa19feaae3823f2bc52551c0c4f7e04ab218abad8b6b930635e6d214340c",
            },
            ["0.6.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mcpp-plugins/archive/refs/tags/v0.6.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mcpp-plugins/releases/download/0.6.0/mcpp-plugins-0.6.0.tar.gz",
                },
                sha256 = "503594d5938a39709af98f606053b00caa275c5a9946c87e2ee98276c96aeb23",
            },
            ["0.5.2"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mcpp-plugins/archive/refs/tags/v0.5.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mcpp-plugins/releases/download/0.5.2/mcpp-plugins-0.5.2.tar.gz",
                },
                sha256 = "d73079f93378f2af6b6513eb6f751d8eace99936b61ff3f5ef786e16a49a8e2a",
            },
            ["0.5.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mcpp-plugins/archive/refs/tags/v0.5.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mcpp-plugins/releases/download/0.5.1/mcpp-plugins-0.5.1.tar.gz",
                },
                sha256 = "1be429b00faaf48afa6c607bdcb98f05b242fef297bd2c588f67fae98f0d83e1",
            },
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
            ["latest"] = { ref = "0.15.1" },
        },
        macosx = {
            ["0.15.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mcpp-plugins/archive/refs/tags/v0.15.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mcpp-plugins/releases/download/0.15.1/mcpp-plugins-0.15.1.tar.gz",
                },
                sha256 = "7e91a1289e075bdd96bb5151f5c63fa3b12308b311e578ea639a447cc5a57160",
            },
            ["0.15.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mcpp-plugins/archive/refs/tags/v0.15.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mcpp-plugins/releases/download/0.15.0/mcpp-plugins-0.15.0.tar.gz",
                },
                sha256 = "2173fca40c72475fbb4682ff3dd97b5062d0895580e20f236f891eab59f5e2e5",
            },
            ["0.14.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mcpp-plugins/archive/refs/tags/v0.14.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mcpp-plugins/releases/download/0.14.0/mcpp-plugins-0.14.0.tar.gz",
                },
                sha256 = "fd5220adb891445d840d0963ba1f7347d2124f27ead0b14bb96db40719e37917",
            },
            ["0.13.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mcpp-plugins/archive/refs/tags/v0.13.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mcpp-plugins/releases/download/0.13.1/mcpp-plugins-0.13.1.tar.gz",
                },
                sha256 = "770741ae7cb83fb53d1d0623f4c709b386be8900135bf32ef29c8c446f72d9cd",
            },
            ["0.13.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mcpp-plugins/archive/refs/tags/v0.13.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mcpp-plugins/releases/download/0.13.0/mcpp-plugins-0.13.0.tar.gz",
                },
                sha256 = "297d28f9549ea3c6d86ab00109e0bf097ec72bf429a74c7f9030ab379a46d904",
            },
            ["0.12.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mcpp-plugins/archive/refs/tags/v0.12.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mcpp-plugins/releases/download/0.12.0/mcpp-plugins-0.12.0.tar.gz",
                },
                sha256 = "90a70689b090be7208c1f1f35487e148ed353a1bef0cec33d391bd46d67ba13f",
            },
            ["0.11.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mcpp-plugins/archive/refs/tags/v0.11.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mcpp-plugins/releases/download/0.11.1/mcpp-plugins-0.11.1.tar.gz",
                },
                sha256 = "8b6f009d747b90789e4d50adfcd45df64962d880c3f96387a1637c04c9239b67",
            },
            ["0.11.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mcpp-plugins/archive/refs/tags/v0.11.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mcpp-plugins/releases/download/0.11.0/mcpp-plugins-0.11.0.tar.gz",
                },
                sha256 = "bb58b43b7161bdc77e750124f9d676aad342a4f2299e4f165c508ffae6be5cd2",
            },
            ["0.10.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mcpp-plugins/archive/refs/tags/v0.10.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mcpp-plugins/releases/download/0.10.1/mcpp-plugins-0.10.1.tar.gz",
                },
                sha256 = "f5278f370e63179a32ffcef1145b90a7bbb3cac79c537eadc9014f6966ce2e01",
            },
            ["0.10.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mcpp-plugins/archive/refs/tags/v0.10.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mcpp-plugins/releases/download/0.10.0/mcpp-plugins-0.10.0.tar.gz",
                },
                sha256 = "b7cfa4b5d011d72cbd75fb96a459889a37a80e61dd903bf9142f582482d34a30",
            },
            ["0.9.3"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mcpp-plugins/archive/refs/tags/v0.9.3.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mcpp-plugins/releases/download/0.9.3/mcpp-plugins-0.9.3.tar.gz",
                },
                sha256 = "abdf812ce1d9d7777ab5a23284d5bcb33e0d6670dc0e93e4a4a04770157ce180",
            },
            ["0.9.2"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mcpp-plugins/archive/refs/tags/v0.9.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mcpp-plugins/releases/download/0.9.2/mcpp-plugins-0.9.2.tar.gz",
                },
                sha256 = "0c42984ec91b2e76cde72115ecf3d818ee48866141ae0a54037736b1a0c46def",
            },
            ["0.9.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mcpp-plugins/archive/refs/tags/v0.9.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mcpp-plugins/releases/download/0.9.1/mcpp-plugins-0.9.1.tar.gz",
                },
                sha256 = "de50556e8c3ea346298d2c3fd9ec2984c9ad3585118a38f0c4667b4b953554b0",
            },
            ["0.9.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mcpp-plugins/archive/refs/tags/v0.9.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mcpp-plugins/releases/download/0.9.0/mcpp-plugins-0.9.0.tar.gz",
                },
                sha256 = "9f7b17450dfd0a7683648945bbbd579a7fd1fc869b0d88dc36095d1d9eac7c60",
            },
            ["0.8.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mcpp-plugins/archive/refs/tags/v0.8.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mcpp-plugins/releases/download/0.8.0/mcpp-plugins-0.8.0.tar.gz",
                },
                sha256 = "088b500236d78ce7f4f88bc8e7c8f9bed00186be926896724c851ec9119946e7",
            },
            ["0.7.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mcpp-plugins/archive/refs/tags/v0.7.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mcpp-plugins/releases/download/0.7.1/mcpp-plugins-0.7.1.tar.gz",
                },
                sha256 = "a8d1b4dc8187c2b67a17d997245a4e4a3d52e26251f4c824fc5b951b58bbe293",
            },
            ["0.7.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mcpp-plugins/archive/refs/tags/v0.7.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mcpp-plugins/releases/download/0.7.0/mcpp-plugins-0.7.0.tar.gz",
                },
                sha256 = "165daa19feaae3823f2bc52551c0c4f7e04ab218abad8b6b930635e6d214340c",
            },
            ["0.6.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mcpp-plugins/archive/refs/tags/v0.6.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mcpp-plugins/releases/download/0.6.0/mcpp-plugins-0.6.0.tar.gz",
                },
                sha256 = "503594d5938a39709af98f606053b00caa275c5a9946c87e2ee98276c96aeb23",
            },
            ["0.5.2"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mcpp-plugins/archive/refs/tags/v0.5.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mcpp-plugins/releases/download/0.5.2/mcpp-plugins-0.5.2.tar.gz",
                },
                sha256 = "d73079f93378f2af6b6513eb6f751d8eace99936b61ff3f5ef786e16a49a8e2a",
            },
            ["0.5.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mcpp-plugins/archive/refs/tags/v0.5.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mcpp-plugins/releases/download/0.5.1/mcpp-plugins-0.5.1.tar.gz",
                },
                sha256 = "1be429b00faaf48afa6c607bdcb98f05b242fef297bd2c588f67fae98f0d83e1",
            },
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
            ["latest"] = { ref = "0.15.1" },
        },
        windows = {
            ["0.15.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mcpp-plugins/archive/refs/tags/v0.15.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mcpp-plugins/releases/download/0.15.1/mcpp-plugins-0.15.1.tar.gz",
                },
                sha256 = "7e91a1289e075bdd96bb5151f5c63fa3b12308b311e578ea639a447cc5a57160",
            },
            ["0.15.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mcpp-plugins/archive/refs/tags/v0.15.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mcpp-plugins/releases/download/0.15.0/mcpp-plugins-0.15.0.tar.gz",
                },
                sha256 = "2173fca40c72475fbb4682ff3dd97b5062d0895580e20f236f891eab59f5e2e5",
            },
            ["0.14.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mcpp-plugins/archive/refs/tags/v0.14.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mcpp-plugins/releases/download/0.14.0/mcpp-plugins-0.14.0.tar.gz",
                },
                sha256 = "fd5220adb891445d840d0963ba1f7347d2124f27ead0b14bb96db40719e37917",
            },
            ["0.13.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mcpp-plugins/archive/refs/tags/v0.13.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mcpp-plugins/releases/download/0.13.1/mcpp-plugins-0.13.1.tar.gz",
                },
                sha256 = "770741ae7cb83fb53d1d0623f4c709b386be8900135bf32ef29c8c446f72d9cd",
            },
            ["0.13.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mcpp-plugins/archive/refs/tags/v0.13.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mcpp-plugins/releases/download/0.13.0/mcpp-plugins-0.13.0.tar.gz",
                },
                sha256 = "297d28f9549ea3c6d86ab00109e0bf097ec72bf429a74c7f9030ab379a46d904",
            },
            ["0.12.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mcpp-plugins/archive/refs/tags/v0.12.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mcpp-plugins/releases/download/0.12.0/mcpp-plugins-0.12.0.tar.gz",
                },
                sha256 = "90a70689b090be7208c1f1f35487e148ed353a1bef0cec33d391bd46d67ba13f",
            },
            ["0.11.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mcpp-plugins/archive/refs/tags/v0.11.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mcpp-plugins/releases/download/0.11.1/mcpp-plugins-0.11.1.tar.gz",
                },
                sha256 = "8b6f009d747b90789e4d50adfcd45df64962d880c3f96387a1637c04c9239b67",
            },
            ["0.11.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mcpp-plugins/archive/refs/tags/v0.11.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mcpp-plugins/releases/download/0.11.0/mcpp-plugins-0.11.0.tar.gz",
                },
                sha256 = "bb58b43b7161bdc77e750124f9d676aad342a4f2299e4f165c508ffae6be5cd2",
            },
            ["0.10.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mcpp-plugins/archive/refs/tags/v0.10.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mcpp-plugins/releases/download/0.10.1/mcpp-plugins-0.10.1.tar.gz",
                },
                sha256 = "f5278f370e63179a32ffcef1145b90a7bbb3cac79c537eadc9014f6966ce2e01",
            },
            ["0.10.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mcpp-plugins/archive/refs/tags/v0.10.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mcpp-plugins/releases/download/0.10.0/mcpp-plugins-0.10.0.tar.gz",
                },
                sha256 = "b7cfa4b5d011d72cbd75fb96a459889a37a80e61dd903bf9142f582482d34a30",
            },
            ["0.9.3"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mcpp-plugins/archive/refs/tags/v0.9.3.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mcpp-plugins/releases/download/0.9.3/mcpp-plugins-0.9.3.tar.gz",
                },
                sha256 = "abdf812ce1d9d7777ab5a23284d5bcb33e0d6670dc0e93e4a4a04770157ce180",
            },
            ["0.9.2"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mcpp-plugins/archive/refs/tags/v0.9.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mcpp-plugins/releases/download/0.9.2/mcpp-plugins-0.9.2.tar.gz",
                },
                sha256 = "0c42984ec91b2e76cde72115ecf3d818ee48866141ae0a54037736b1a0c46def",
            },
            ["0.9.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mcpp-plugins/archive/refs/tags/v0.9.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mcpp-plugins/releases/download/0.9.1/mcpp-plugins-0.9.1.tar.gz",
                },
                sha256 = "de50556e8c3ea346298d2c3fd9ec2984c9ad3585118a38f0c4667b4b953554b0",
            },
            ["0.9.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mcpp-plugins/archive/refs/tags/v0.9.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mcpp-plugins/releases/download/0.9.0/mcpp-plugins-0.9.0.tar.gz",
                },
                sha256 = "9f7b17450dfd0a7683648945bbbd579a7fd1fc869b0d88dc36095d1d9eac7c60",
            },
            ["0.8.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mcpp-plugins/archive/refs/tags/v0.8.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mcpp-plugins/releases/download/0.8.0/mcpp-plugins-0.8.0.tar.gz",
                },
                sha256 = "088b500236d78ce7f4f88bc8e7c8f9bed00186be926896724c851ec9119946e7",
            },
            ["0.7.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mcpp-plugins/archive/refs/tags/v0.7.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mcpp-plugins/releases/download/0.7.1/mcpp-plugins-0.7.1.tar.gz",
                },
                sha256 = "a8d1b4dc8187c2b67a17d997245a4e4a3d52e26251f4c824fc5b951b58bbe293",
            },
            ["0.7.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mcpp-plugins/archive/refs/tags/v0.7.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mcpp-plugins/releases/download/0.7.0/mcpp-plugins-0.7.0.tar.gz",
                },
                sha256 = "165daa19feaae3823f2bc52551c0c4f7e04ab218abad8b6b930635e6d214340c",
            },
            ["0.6.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mcpp-plugins/archive/refs/tags/v0.6.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mcpp-plugins/releases/download/0.6.0/mcpp-plugins-0.6.0.tar.gz",
                },
                sha256 = "503594d5938a39709af98f606053b00caa275c5a9946c87e2ee98276c96aeb23",
            },
            ["0.5.2"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mcpp-plugins/archive/refs/tags/v0.5.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mcpp-plugins/releases/download/0.5.2/mcpp-plugins-0.5.2.tar.gz",
                },
                sha256 = "d73079f93378f2af6b6513eb6f751d8eace99936b61ff3f5ef786e16a49a8e2a",
            },
            ["0.5.1"] = {
                url = {
                    GLOBAL = "https://github.com/mcpp-community/mcpp-plugins/archive/refs/tags/v0.5.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/mcpp-plugins/releases/download/0.5.1/mcpp-plugins-0.5.1.tar.gz",
                },
                sha256 = "1be429b00faaf48afa6c607bdcb98f05b242fef297bd2c588f67fae98f0d83e1",
            },
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
            ["latest"] = { ref = "0.15.1" },
        },
    },

    -- The package's own manifest, at the archive root.
    mcpp = "*/mcpp.toml",
}
