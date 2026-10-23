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

## Index and verification

Descriptors live directly in `pkgs/mwrap/<qualified-name>.lua`; consumers live in
`tests/mwrap/<member>/`. Do not add an extra alphabetic directory level. The
existing client scans immediate subdirectories of `pkgs` by declared identity,
and publication copies `pkgs` unchanged: no staging path conversion is needed.
Register consumers as workspace members and cover them in selection/sharding,
lint, mirrors, search and the site. Traditional providers remain under compat.

Use the latest tested stable mcpp release, pinned consistently across manifests,
CI, examples and templates. Check current remote main before relying on source.
Run Linux tests locally and repeat release gates in CI; cover Windows/macOS in
native CI. Distinguish build-only checks from executed GUI, provider and hardware
tests. Validate cold index consumption and runtime deployment, including libraries
loaded dynamically rather than appearing on a link line.

Each repository's PR retains checkpoint commits. Record commands and actual
results, inspect the final dependency/ABI/API graph, and wait for every relevant
CI check before reporting merge/release readiness.
