# Register aimol.tensorvia 0.3.0

Date: 2026-11-13.

Register the multi-backend Tensorvia library (`aimol.tensorvia`, Form A: the
release tarball carries its own `mcpp.toml`, emitted by `mcpp emit xpkg` from
that manifest) and retire the CPU-only split `aimol.tensorvia-cpu`: the
upstream maintainer confirms it is unused, so its descriptor is removed in the
same change and the live documents that cited it as the plain-string-url
precedent (docs/zh/cn-mirror.md, both descriptor-examples pages, the spdlog
descriptor's comment, the add-mcpp-index-package skill, the site plugin's two
comments, and the now-unreachable Tensorvia-cpu cache entries) now cite
`pkgs/t/tensorvia.lua` — the English cn-mirror page and the plugin/cache edits
were found by a final sweep after the descriptor was removed. Historical plan
documents keep their point-in-time mentions.

Form and source: C++23 module library (`import tensorvia;`), CPU backend on by
default; vulkan/cuda/sycl are features gated on the accelerator axis, so this
index entry serves the CPU artifact a consumer gets without `--accel`. The
vulkan lane's `xim:shaderc` sits on the package's own target axis and is
deliberately NOT promoted to the descriptor: a CPU consumer must not download a
shader compiler, and the package's own build program already warns and names
the payload when a vulkan accelerator is selected.

The `mcpp` pointer is the literal `mcpp.toml`: the release asset is built by
`git archive`, so there is no `<repo>-<tag>/` wrap layer for a `*/` glob to
absorb (precedent: `pkgs/g/gcc.libstdcxx.lua`). The test member declares its
own `[indices] aimol = { path = "../../.." }`; a member-level table replaces
the root's `compat` alias, which cannot resolve `aimol.*` (same shape as
`tests/examples/taskflow-module`).

The descriptor carries no "AUTO-GENERATED / do not edit by hand" banner: `name`,
`maintainers` and the `mcpp` pointer are hand edits, so the file presents itself
as hand-maintained, the same treatment `pkgs/h/huxerui.huxerui.lua` documents.

Version 0.3.0 is the `v0.3.0` tag of Aimol-l/Tensorvia, archived with
`git archive` (`.vscode/` excluded via `.gitattributes` export-ignore). All
three platform blocks name the same tarball, SHA256
d01e36f09db56cea1470425dbb0e0bbeb9d9bb9cee184b1c6d3d51760518fb1f, computed
twice and stable. The CPU lane is portable C++23 + OpenMP; the device lanes
are Linux-only and feature-gated, so no per-platform split is needed. CN
mirror: plain upstream release URL, the simplified path
`pkgs/c/compat.spdlog.lua` documents; this descriptor is itself the
mcpp-native precedent now.

Feature evaluation: the three device features exist in the shipped manifest
and select themselves via the consumer's `--accel`; nothing here registers
feature-deps, because a CPU consumer installs none of the device payloads and
the negative path is the default. The test member asserts that default: it
depends on `aimol.tensorvia` with no features, imports the module, runs CPU
ops and reads back scalars, and exits non-zero on any mismatch.

Autoupdate: registered as `tag = "v${version}"` with the tarball URL pattern
above, matching the upstream's actual tagging.

Validation: `lua5.4` syntax, `check_mirror_urls`, `check_package_name`,
`check_reserved_namespace` and strict `mcpp xpkg parse` pass locally on
mcpp 2026.11.7.2; `bash tests/run_members.sh tensorvia` downloads the published
release, builds the module and passes the smoke assertions: `test result ok.
1 passed; 0 failed` in 20.32s (build 13.36s + run 0.01s).
