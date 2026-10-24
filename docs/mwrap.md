# Module wrappers: mcpplibs.mwrap

`mcpplibs.mwrap` contains C++ module interfaces for existing C and C++ header
libraries. Native module projects remain directly under their own namespace.
A wrapper changes how a library is imported while preserving its upstream
public names, namespaces, type identities, overloads and behavior.

[简体中文](zh/mwrap.md)

## Names and ownership

| Artifact | Convention | Example |
|---|---|---|
| Repository | `<upstream-name>-m` | `mcpplibs/opencv-m` |
| Package namespace | `mcpplibs.mwrap` | same for C and C++ wrappers |
| Package short name | upstream library name, one atomic segment | `opencv` |
| Root module | complete package identity | `mcpplibs.mwrap.opencv` |
| Submodule | upstream module grouping | `mcpplibs.mwrap.opencv.core` |
| Public API | original upstream spelling | `cv::Mat`, `Ort::Session` |
| Macro mapping module | `<root>.macros` | `mcpplibs.mwrap.opencv.macros` |

Do not add `-m` to package/module names or relocate ordinary upstream entities
into a new C++ namespace. Preserve legacy published package identities and bytes;
publish a new mwrap identity rather than rewriting old releases.

Use `compat.<library>` for an independently reusable traditional implementation.
A wrapper should depend on it when its configuration and ABI are sufficient.
Complex implementations may instead vendor pinned sources under `upstream/`.
Each implementation has one owner in a program: do not link both a vendored copy
and a compat copy of the same library.

## Repository layout

```text
<library>-m/
  mcpp.toml
  build.mcpp                 # only when generation/adaptation needs it
  .xlings.json               # exact tested mcpp release
  upstream/                  # source pins, checksums, licenses; sources if vendored
  patches/                   # minimal reproducible patches and their reasons
  port/                      # compatibility implementation, headers and config templates
  src/<library>.cppm         # public lib root
  src/macros.cppm
  generated/                 # reproducible stable outputs, if needed
  templates/<name>/          # mcpp quickstart templates
  tests/                     # API, behavior, header/module and installed consumers
  tools/                     # upstream import, generation and auditing
```

Separate upstream code from wrapper and platform adaptations. Record source
URL, tag/commit, SHA256, pruning and licenses. Keep feature/target-specific
generated files in the build output directory, so concurrent configurations
cannot overwrite shared source files. Build-time downloads belong to package
providers, not module compilation or an undeclared build script.

## Versions

Package versions follow the upstream version, with at most one numeric wrapper
revision appended: `5.0.0`, `5.0.0.1`, `5.0.0.2`. A new upstream `5.0.1` starts
again at `5.0.1`. Revisions start at **1**: never publish both `5.0.0` and
`5.0.0.0`, which compare equally. Do not use an unrelated wrapper `0.x` version
or change the upstream patch number to describe a wrapper fix.

The first release of a new mwrap identity uses the upstream version without a
wrapper suffix. Existing legacy package identities keep their published bytes.
Use the independent repository tag series `mwrap-${version}` (for example,
`mwrap-8.1.2`); it does not alter the package version. Never move an existing tag.
Select this exact tag series in automatic updates rather than GitHub latest.

Record upstream identity separately in `[package.metadata.mwrap]` and source
pins. A wrapper revision does not excuse undocumented breaking interface changes.
Non-numeric/prerelease upstream schemes need an explicit mapping preserving
their meaning. Build metadata (`+...`) is not a sortable wrapper revision.

## Public interfaces and macros

Prefer exporting the upstream entities with `export using`. Each entity has one
export owner; the root re-exports the enabled public module closure. Audit public
C/C++ headers, including templates and overloads. Language-binding annotations
alone are not a complete C++ API inventory. Record unsupported/internal-linkage
adaptations and test their semantics instead of silently pruning failed exports.

Named modules cannot export preprocessing macros. A `.macros` module may map
object constants to `inline constexpr` and suitable computation macros to
functions. Put these additions in
`mcpplibs::mwrap::<library>::macros`, retaining the original macro name.
Token concatenation, stringification, conditional compilation and control-flow
macros stay in `<mwrap/<library>/macros.hpp>`, included before imports.
Preserve argument evaluation and call-site behavior; an assertion macro is not
automatically equivalent to a function. Active macros expand even in qualified
names, so test and document raw-header versus mapped-constant usage.

## Features

Use lowercase kebab-case and recognizable upstream vocabulary:

- Modules: `dnn`, `highgui`, `stitching`.
- Implementations: `<module>-<backend>`, such as `highgui-gtk3`,
  `videoio-ffmpeg`, `dnn-onnxruntime`.
- Formats: `imgcodecs-png`, `imgcodecs-tiff`.
- Cross-module dependencies: `opencl`, `tbb`, `lapack`.
- Extras: `contrib-<upstream-module>`.
- A module-only aggregate: `all-modules`; explicitly state its expansion.

Features are additive and unify across dependency edges. Use `implies`,
dependency feature forwarding, `[feature-deps.<feature>]` and target conditions.
Consumers may use `default-features = false` on a dependency edge. Explicit
features still activate, and another edge may request defaults again. Keep
heavyweight or replaceable providers behind named features. A module API and its runtime backend are different
capabilities. Reject unavailable targets and incompatible provider combinations
explicitly; do not silently skip a requested backend.

Capabilities select and validate providers; they do **not** remove another
provider's object files from the link. Avoid duplicate implementations before
they enter the graph. Record ABI, runtime, CPU baseline and SDK constraints.

## README style

Every `<library>-m` repository has an English `README.md` and a Chinese
`README.zh.md`, linked to each other at the top. Both normally stay within
100 lines. Add the missing translation when modernizing a wrapper.

Preserve the existing section hierarchy, order, useful badges and language
navigation, then shorten the prose. Translate headings while preserving their
meaning. A shared style does not require replacing every library's layout.
Keep quickstart commands, dependency/import examples, versions, platform
conditions and support limits equivalent in both languages. Move long examples,
architecture and full matrices into docs and link them from the original section.
Do not meet the target with long lines or missing prerequisites.

## Every -m package ships a runnable template

At least one default `templates/<name>/template.toml` and project skeleton is
required. A default template runs without a GPU, camera, desktop session or a
separate model/data download. Advanced templates may declare those requirements.

```sh
mcpp new vision --template mcpplibs.mwrap.opencv@5.0.0
mcpp new --list-templates mcpplibs.mwrap.opencv@5.0.0
mcpp new viewer --template mcpplibs.mwrap.opencv@5.0.0:window
```

Templates are data, without execution hooks. With the pinned current mcpp,
`{{self.name}}` is the **qualified package selector**, not merely its short name:

```toml
[dependencies]
"{{self.name}}" = { version = "{{self.version}}", features = ["imgproc", "imgcodecs-png"] }
```

Quote the selector as one key; do not place it under another namespace table.
Declare required features explicitly and keep the library version tied to
`{{self.version}}`. Test actual `mcpp new`, then build and run the generated
project. A source candidate may use an isolated preseeded installed-package
fixture, but must verify the rendered identity/version before applying local
dependency overrides. Also test the release archive includes the templates.

## Local test resource budget

Local tests must collectively stay below **80%** of the machine's effective CPU
and memory resources, accounting for affinity and container/cgroup limits.
Reserve additional desktop headroom by default. This covers concurrent tests,
dependency builds, code generation, compilers and AST subprocesses together.

Check load and available memory before heavy work, limit build jobs and concurrent
heavy tasks, and monitor usage. A task-specific cgroup/systemd slice can enforce
aggregate limits on Linux; MCPP_JOBS controls build concurrency. Reduce this
task's concurrency near the budget, without stopping unrelated user processes
or dropping validation gates.

## Index and verification

Descriptors live directly in `pkgs/mwrap/<lib>.lua`; consumers live in
`tests/mwrap/<member>/`. Do not add an extra alphabetic directory level. The
existing client scans immediate subdirectories of `pkgs` by declared identity,
and publication copies `pkgs` unchanged: no staging path conversion is needed.
The category already identifies wrappers: use short filenames such as
`pkgs/mwrap/ffmpeg.lua`, while declaring `namespace = "mcpplibs.mwrap"` and
`name = "ffmpeg"`. Filenames do not define identity. Dependencies, template
selectors and module imports display the complete `mcpplibs.mwrap.ffmpeg`.
`mwrap.ffmpeg` is a different namespace, not a supported abbreviation.
Godot uses `mcpplibs.mwrap.godot_cpp`; the repository remains godot-cpp-m.

Register consumers as workspace members and cover them in selection/sharding,
lint, mirrors, search and the site. Traditional providers remain under compat.

Use the latest tested stable mcpp release, pinned consistently across manifests,
CI, examples and templates. Check current remote main before relying on source.
Run Linux tests locally and repeat release gates in CI; cover Windows/macOS in
native CI. Distinguish build-only checks from executed GUI, provider and hardware
tests. Validate cold index consumption and runtime deployment, including libraries
loaded dynamically rather than appearing on a link line.
When a runtime SDK ships LICENSE and third-party notices, declare their deployment
alongside the runtime files. Verify those bytes in a relocated consumer bundle;
automatic license discovery may copy LICENSE while omitting additional notices.
Use `runtime.deploy` for explicit relative destinations without changing the engine.
Vendored static implementations need this too: shared-library discovery does not
find their notices. Preserve retained license/copyright files under distinct source
paths so unrelated LICENSE basenames cannot overwrite one another.

Each repository's PR retains checkpoint commits. Record commands and actual
results, inspect the final dependency/ABI/API graph, and wait for every relevant
CI check before reporting merge/release readiness.

## Candidate index tests across namespaces

The pinned client can report duplicate candidates when a workspace mixes full project indices and namespace views. Mwrap workspace members retain an explicit empty `[indices]` table. `tests/run_members.sh` prepares one complete unchanged built-in candidate index before their tests; an unset MCPP_HOME uses the task-owned target/mwrap-test-home. CI prepares that candidate after refreshing the published registry. Keep the legacy workspace redirect semantics; `[workspace.indices]` merges entries and is not a mechanical spelling replacement.

Namespace views created by tests/prepare_mwrap_indices.py remain available for isolated single-project consumers. Their descriptors preserve source bytes and SHA256 provenance. A standalone success does not certify a mixed workspace sequence. Views are ignored outputs, not a publication format.

Normal installed consumers are tested independently by tests/mwrap/check_installed_template.py: it copies the complete pkgs/index.toml publication layout into one isolated built-in index, downloads the real checksummed source archive, runs mcpp new and builds/runs the generated manifest without a path substitution. The Git and published pkgs/mwrap directory layout remains identical.

Coupled runtime/plugin/build-module consumers may require several candidate namespaces at once. Use `python3 tests/prepare_builtin_index.py --home <isolated-test-home>` to install the complete unchanged candidate layout as the test home's single built-in index; the member uses an empty `[indices]` table to override legacy workspace redirects. Updater candidate CI uses this mode too. Do not register the same full checkout through multiple project aliases. This is test-home preparation only: no publication staging, path conversion or mcpp engine change is required.

For Linux consumers loading a C++ SDK through a C API, verify the C++ runtime contract as well as successful calls. The OpenCV/ORT integration exposed uncaught typed exceptions when a static runtime was embedded alongside the shared SDK runtime; `cxx_runtime = "toolchain-coupled"` fixed the same test. Templates must encode the verified contract and exercise a typed error path.

Generated files are build inputs. Preserve their timestamps when content is unchanged, including manifests, module facades and configuration headers; touching an unchanged common header can rebuild the entire vendored implementation. Verify both byte idempotence and incremental behavior.
