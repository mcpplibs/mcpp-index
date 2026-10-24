# OpenCV WebP provider checkpoint

OpenCV 5.0.0 grfmt_webp.cpp uses encoding/decoding, animation, EXIF/XMP/ICC
containers and therefore requires both upstream WebP mux and demux implementations.
The existing compat.libwebp 1.5.0 source recipe retains ownership of this C library;
no second vendored implementation or module wrapper is introduced.

- `demux` adds src/demux/*.c; `mux` adds src/mux/*.c. Each is independent and additive.
- Default encode/decode/sharpyuv source selection, architecture gates and flags are unchanged.
- All three historical platform version/URL/hash blocks remain byte-identical.
- COPYING, PATENTS and AUTHORS are explicitly deployed under licenses/libwebp.
- The existing workspace consumer now requests both features. Its additional
  standalone test encodes two lossless animation frames, muxes an EXIF chunk,
  demuxes the metadata and checks decoded pixels and timestamps. Checks survive NDEBUG.

Linux verification uses mcpp 2026.10.24.1 and LLVM23.1.3. Strict fresh projects
passed both the original roundtrip and container test (1.28 seconds), then a
separate unchanged-default dependency passed the original test (1.72 seconds).
Actual compile_commands.json includes mux/demux only for the enabled variant.
Logs: /tmp/mwrap-webp-provider-variants-final.log. All work uses the shared
sixteen-core/32 GiB test slice with three build jobs and disk/memory guards.

The direct workspace-root strict command rejects its pre-existing deprecated
index inheritance; isolated projects use the byte-identical compat test view,
without editing the client or suppressing diagnostics. Normal workspace/native
CI remains required on this exact index head. OpenCV imgcodecs-webp integration,
its source matrix and actual archive/deployment consumer are separate gates.

## Archive and deployment acceptance

OpenCV source 16baa03ef4353188c816a6ff5962a5da53998814 was downloaded twice
with SHA256 556df2142b56cac8f635597bcec9bf32a45957cc0203cff0feb5cf9e256b09c1.
The new tests/mwrap/opencv-webp member consumes that actual source archive.
An isolated home with the complete unchanged publication index strictly built
and ran the consumer, then packed a release application and ran the relocated
bundle with an empty home and cleared library/runtime overrides. Lossless alpha
and transparent RGB, two-frame timing/loop count, XMP bytes and WEBP build
information checks passed. ELF dependencies resolve within the bundle. All
fourteen OpenCV/wrapper notices plus three libwebp notices match their original
source bytes. Log: /tmp/mwrap-webp-archive-deployment.log.

The deployment helper is also registered for native default-toolchain workspace
CI when opencv-webp is selected; ordinary member tests cover other compiler legs.
All seventeen pinned-updater regressions pass, and the full audit still covers
91 automatic declarations/two reviewed snapshots with historical versions intact.
The initial local unittest invocation lacked the workflow's pinned-updater
PYTHONPATH; the successful rerun uses /tmp/mwrap-updater-6c0bee/src.
Native CI results are required on the final source/index commits; these local
checks do not certify Windows/macOS/musl behavior by inference.

## Embedded notice supplement and updated archive

Candidate 019eaadb4c2212246cf20e29447bb1ef960333ba was independently downloaded
twice with SHA256 e265add2c6ed3aa9e6dba677a8731e8a385e5f8419093336a18fbdab54be5661.
It adds the SDK inline-helper/value-operator checkpoint and a deterministic
embedded source notice supplement. The original fourteen named OpenCV notices
remain; the additional supplement preserves source comment bytes and locations.
Both installed-template and WebP deployment helpers require that supplement.

The fresh-home archive test strictly built and ran the consumer (2m55s), packed
a release bundle (1m34s), and ran it after relocation with an empty HOME and
cleared runtime overrides. Image/animation/XMP checks and the bundled ELF loader
closure passed. All fifteen OpenCV plus three WebP notices match the installed
source bytes. Log: /tmp/mwrap-notices-archive-deployment.log. This local test used
the shared resource slice, three build jobs and the whole-host pressure guard.
Descriptor parsing, naming, version parity and duplicate-version checks pass.
Native CI still needs the new exact source and index heads; the previous OpenCV
16baa03 matrix completed all five jobs successfully.

## Namespace-isolated validation views

Validation run 40076826208 failed on Linux default, Linux LLVM and macOS shards:
both compat and mcpplibs.mwrap project aliases exposed complete indices, so
xlings rejected duplicate ORT/OpenCV candidates. The existing view preparer was
not registered in the workspace workflow. Validation now prepares namespace-only
views before consumers and replaces each owned scratch view in full, including
stale categories left by earlier complete-index copies. Publication paths and
descriptor bytes are unchanged; no client engine changes are required.

The regression fixture seeds a cross-namespace descriptor in an old category,
rebuilds twice and verifies unique candidates plus exact source bytes/provenance.
It passes and runs before preparation in CI. A separate actual consumer with a
fresh MCPP_HOME installed the immutable ORT wrapper, CPU SDK and LLVM23.1.3,
then passed inference and public_surface under strict mode (2 tests, 103.25s).
Log: /tmp/mwrap-disjoint-view-consumer.log. The test used the shared eight-core,
32 GiB resource slice, two build jobs and whole-host 80% pressure guard. Native
workspace CI on the new index commit remains required.

## Mixed workspace resolution correction

Run 40087278903 / Linux LLVM shard 0/6 still failed ORT/OpenCV ambiguity after
view preparation. The log confirms both preparations ran successfully before
libwebp and llama.cpp consumers; the later mwrap consumers nevertheless saw
cross-namespace candidates. The standalone fresh-home result above did not
cover this mixed workspace ordering.

A private-home fixture now reproduces the actual sequence: configure a legacy
compat.zlib 1.3.2 consumer against the complete project index, then resolve ORT
with the two namespace views. That second resolution fails with duplicate
candidates. Keeping the same warmed home/workspace and changing only the ORT
member to an explicit empty [indices] table succeeds: strict inference and
public_surface both run (19.97s). The fixture installs the complete unchanged
candidate layout into its built-in index; it does not edit the client engine
or a user-global registry. Log: /tmp/mwrap-mixed-workspace-index.log.

All ten mwrap workspace members now use that explicit empty table. CI installs
the complete candidate built-in index after its published refresh, and the local
member runner does the same for mwrap selections. An unset local MCPP_HOME
selects target/mwrap-test-home, with bootstrap before copying the candidate;
normal user's default home is not replaced. Static regression guards require
mwrap members to retain their explicit override. Namespace-view tooling remains
available to isolated single-project consumers, with its scope documented.
New exact-head native workspace validation remains required.

The first mixed fixture used [workspace.indices]. A second private-home fixture
now uses the same legacy root [indices] form as repository CI: the two-view
consumer again fails with ambiguous candidates, while its empty-table form
passes inference/public_surface (17.42s). This run keeps CI's non-strict entry
because the existing root form emits a deprecation warning; no diagnostic is
suppressed. Log: /tmp/mwrap-legacy-workspace-index.log. The strict modern-root
result above and this exact legacy-root result verify distinct configurations.
The bilingual specification and authoring skill now direct mwrap workspace
members to the single built-in candidate and reserve namespace views for
isolated projects. Skill validation and both index-view/member guards pass.

## OpenCV qualified-API archive checkpoint

The unpublished 5.0.0.1 candidate now pins OpenCV source commit
becda22229cb5ed43d7ce098291cf7a4e5f7d15b on all three descriptor platforms.
Two independent downloads agree on SHA256
67fdaec136e4acb4b0aa9d6a37c1c7952fa278180d82d6eab77dcac4211404ce.
The archive was compared with the source checkout, including all 2305 retained
upstream files and the new module/generator/Windows fixture changes. Historical
package identities, released archives and descriptors remain unchanged.

The indexed CPU consumer additionally checks the original cv::details FP state
API signatures, layout and RAII state restoration. This exercises qualified names
added in this source checkpoint rather than accepting only older image APIs.
The new descriptor passes the pinned resolver grammar, platform-version parity,
package-name/reserved-namespace checks, and both index-routing regressions.

A new independent-home archive acceptance has resolved this exact SHA and
rendered the unmodified default template. Strict build, run, relocated deployment
and notices/runtime-closure checks are still running at this checkpoint; rendering
alone is not deployment acceptance. Log:
/tmp/mwrap-becda22-template-deployment.log.

The six companion -m PRs retain green checks on their current heads (4 ORT,
8 llama.cpp, 2 FFmpeg, 6 gRPC, 4 ImGui, 3 Godot). OpenCV run 40098688445 on
becda22 is still running its five native jobs. Index 0861946 validation has
18 successful jobs and one running Linux workspace shard; its updater, site and
OpenKAL checks pass. This pin change requires its own exact-head index CI.
No source/index merge, release or tag is performed. Remaining OpenCV API/header
classification and native CI gates still prevent a full-support readiness claim.

## Final Mat conversion candidate archive

The candidate now pins c052ccf15de43689c23b70952bb3c0a63779f71f on Linux,
macOS and Windows, SHA256
e7016133547422085b293800d102becfa6c5fc8bd3d0fa9f3a36b88ccf227674.
Two independently downloaded archives are identical (14319338 bytes each).
All 3716 tracked archive files match the source checkout byte-for-byte,
including all 2305 retained SDK files. Source implementation checkpoint 93f2ce0
repairs original Mat operand conversions; c052ccf adds capability documentation.
The package remains an unpublished 5.0.0.1 candidate; historical descriptors
and published resources are unchanged.

The indexed CPU test now exercises typed-Mat addition, an exact original MatExpr
assignment function pointer and affine-expression values, alongside image,
scalar and FP contracts. Older cached candidates cannot satisfy these checks.
Actual archive acceptance renders/builds/runs the unmodified default template,
then copies this real consumer into a test in the same isolated home, reusing
the same verified installation without changing its manifest or application.
The consumer passes (2.46s). Release packing (4m41s), relocated isolated execution,
ELF closure and all fifteen byte-identical OpenCV/wrapper notices pass.
Log: /tmp/mwrap-c052ccf-template-api-deployment.log.

WebP acceptance additionally selects the archive root by its retained SDK
LICENSE instead of relying on the first core.cppm CDB entry: public and detail
producers share that basename. The final fresh-home WebP deployment/18-notice
check is running at /tmp/mwrap-c052ccf-webp-deployment.log; its result is not yet
claimed. Pinned resolver parse, platform version parity, package/reserved-name
checks, two routing regressions and seventeen updater tests pass. Final exact-head
index/native CI and the requirement-by-requirement release review remain open.
No merge, tag, release or mcpp engine change has been performed.
