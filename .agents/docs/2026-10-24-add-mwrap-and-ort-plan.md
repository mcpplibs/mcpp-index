# mwrap category and ONNX Runtime SDK implementation

The new mwrap category is flat under pkgs/mwrap. Existing clients scan one category level and the publishing script copies pkgs unchanged; no staging conversion or mcpp engine change is required. Consumers live under tests/mwrap and participate in the same selection/shard/timing entry points as existing examples.

compat.onnxruntime owns the official MIT-licensed 1.25.1 CPU SDK, including exact platform checksums. The module wrapper remains in mcpplibs/onnxruntime-m and exposes upstream Ort/C names. The provider supports Linux glibc x86_64, macOS arm64 and Windows x86_64 MSVC ABI. Unsupported architectures/libcs fail explicitly. Linux runtime closure declares gcc-runtime and glibc; it never farms libc or an ELF loader from the host.

Local checks: strict descriptor parse, cross-package references, duplicate/platform version lint and shard inclusion passed. Isolated SDK installation and real inference/header coexistence passed with LLVM 23.1.3; GCC 16.1.0 also passed, followed by actual template creation/build/inference. Native wrapper CI pins SDK provider commit 3067e52abc0165b453ea3acac4022895ebf7d9bc.

The formal English/Chinese mwrap specification records upstream[.N] versions, modules versus API namespaces, macros, optional features and executable quickstart templates. The package skill links this common specification. Autoupdate is not enabled for the SDK yet: updating it requires changing archive directory names, API inventory and ABI verification, rather than only replacing a URL version.

Checkpoint state: SDK provider and category infrastructure first. The opencv/onnxruntime wrapper descriptors must be added only after immutable source archives and checksums are verified and install/template consumers execute through this index. No placeholder published versions, release tags or merges are performed here.

CI caught a semantic difference in migrating root [indices] to [workspace.indices]: the latter merges namespace entries into members, registering the same physical index twice for non-compat members and triggering xlings ambiguity. Keep the existing root [indices] replacement semantics deliberately; this is supported compatibility behavior in the pinned client. No engine patch or per-member mass rewrite is needed. Reproduction: graphics side-effects job 120643941884 failed before installing any graphics package.

The real wrapper archive de3a0a9 was downloaded twice and pinned as SHA256 24d4bc26d2f426e3643f21d289d92e7a23b3ba54524a099a1079c1c490915251. Its CPU inference and public SDK helper consumer passed through index installation. Testing the wrapper and compat SDK together confirmed both namespace-routing constraints on the current client; tests/prepare_mwrap_indices.py now provides unchanged namespace-scoped test views, while check_installed_template.py independently tests the complete unchanged published layout with no source pre-seeding or dependency rewriting.

The unchanged full-index installed-template flow passed in a fresh home: real wrapper/SDK archives and LLVM were installed, mcpp new rendered the default inference project, and its original dependency resolved and ran Identity inference. The updater audit now implements the documented immutable-commit exception rather than demanding a fake release template. All 14 updater adapter tests and the full real audit passed (85 automatic declarations, one manual snapshot), retaining historical-byte guards. Candidate selection/preparation also recognizes tests/mwrap and fully qualified dependency keys.

Cross-platform CI correction: namespace-view metadata is explicitly decoded as UTF-8 on Windows. The ecosystem Vulkan check also exposed two header/runtime adapter anchors defaulting to static while reachable from several shared images; their providers now default to shared form, with explicit packaging revision 1 on current entries and unchanged source URLs/hashes. The consumer can still choose linkage. Llama Vulkan CI pins this candidate index commit rather than requiring the PR to merge first.

## Existing-wrapper template archive checkpoint

- All six -m repositories now use concise root READMEs (normally <=100 lines per language), with detailed usage under docs/. The bilingual mwrap spec and authoring skill record the shared structure and the local aggregate resource limit.
- Added immutable candidate versions for FFmpeg 8.1.2.1, ImGui 1.92.8.1 and gRPC/runtime-plugin-rule 1.83.0.1. Published older version blocks are unchanged. Existing package/module identities remain compatible. ImGui and gRPC now declare tag-based automatic update URLs; coupled gRPC manifests are still version-checked by source CI.
- CPU/headless workspace consumers live in tests/mwrap/{ffmpeg-cpu,imgui-headless,grpc-cpu}/tests, so mcpp test executes their behavior checks rather than merely building an application. Windows gRPC explicitly remains unavailable with the declared OpenSSL provider.
- Each candidate's full-commit archive was downloaded twice with identical SHA256. Updated the unpublished ORT/llama candidates to include the reviewed README revisions. Archive references at this checkpoint:

- onnxruntime-m: `576c780bfcbd792c7f4194942c90324f183a48aa`, SHA256 `3654811f65b98ade75b5e46fe59a0c4479d815aa7fa9aceff9f9cc3fffd8ddc1`.
- llama.cpp-m: `5028a1aa4f741db4dbd86d6ebd1928ef21027147`, SHA256 `9b21c35c17e801ceee1165960eefbf7280ad50e14aaf3ea5603fbf2c4ab911de`.
- imgui-m: `ffebf83be99ba0eec2677cc197dea3316a72b501`, SHA256 `9aab8af876c6c9eaed887b0d84bf3bb733db1d28613cbd5083845d83f675a92f`.
- grpc-m: `839b61e94fff14892a1dfb2c211a4a8e66342239`, SHA256 `b16dffb45c6f4b09de49a5229f2ec7db98bcfb5609447271d85db8387aeabdd4`.
- ffmpeg-m: `1e8bce6ee12c50e43058245df42515ffbabfc78f`, SHA256 `595b5bcca166583dd082ae911f7e9ed279a3e8899e9564f0901e084737c89ab2`.

Local evidence: OpenCV LLVM/GCC all-module strict tests each pass fourteen binaries; the GCC ORT adapter fix also passes actual CPU-profile inference. FFmpeg's managed-NASM default template strictly builds and decodes three generated frames. The full index audit covers 90 automatic declarations plus one manual snapshot and preserves all historical version blocks; fourteen updater regressions and changed-descriptor all-platform grammar/name/syntax checks pass.

The new complete-index ImGui archive/template check is running in a fresh MCPP_HOME. Final fresh-archive checks for changed source revisions, the new workspace test entries and native CI are not yet complete. gRPC's cold installed-template check has its own Linux/macOS jobs with a 210-minute limit; it does not consume a workspace shard's existing 90-minute allowance. No release readiness is inferred from source CI or archive checksums alone.

Local heavy commands run serially in mwrap-tests.slice with CPUQuota=1600%, MemoryHigh=28 GiB, MemoryMax=32 GiB, TasksMax=512, taskset 0-15 and MCPP_JOBS=6 on this 32-logical-CPU/62-GiB host. Check current available resources and disk before each check; retain at least 6 GiB free during builds. No engine change, merge or tag is included.

## Candidate scanner and host-tool consumer correction

The b22a9a8 candidate scan stopped with `no candidate consumer: grpc:grpc-plugin`. Added a dedicated grpc-tools consumer for the indexed plugin and grpcgen host module; it resolves both exact 1.83.0.1 archives through separate unchanged namespace views, builds the host binary and verifies its path plus the rule's generation metadata. This is host-tool build/availability coverage, including planned native Windows checks, not a Windows runtime/codegen support claim. Actual service generation/RPC remains covered by the default gRPC templates on supported Linux/macOS targets.

The scanner now finds normal and build dependencies inside target tables, and prefers dedicated tests/mwrap consumers over older platform-gated examples. Two regressions cover these boundaries, including build-dependency version replacement. All sixteen updater tests pass; an actual full candidate-matrix reproduction produces 23 build/run jobs and selects grpc-cpu, grpc-tools, imgui-headless, ffmpeg-cpu and llamacpp-cpu as intended. The full audit still preserves historical versions and reports 90 automatic descriptors plus one manual snapshot.

Local strict actual index tests now pass all four new members: ffmpeg-cpu (real 16x16 frame), imgui-headless (positive draw vertices), grpc-cpu (status/credentials) and grpc-tools (built host plugin plus imported rule). A fresh complete-index ImGui archive/default-template installation also passes with positive draw data and no display. These results supplement the source/template CI; all new native matrix jobs remain required before release readiness.

## Complete-index fixture, seven-wrapper and OpenCV archive checkpoint

The ba9a72e native candidate jobs exposed two real test-fixture problems: preparing only the namespace under test hid coupled unpublished plugin/rule versions, and registering full candidate views through multiple project aliases caused ambiguous candidates in fresh CI. The new prepare_builtin_index.py installs the complete unchanged pkgs/index.toml layout into one isolated test home's built-in index. Updater candidate preparation uses it for all namespaces; grpc-tools uses an empty member [indices] table to override the legacy workspace redirect. Publication layout remains unchanged, with no staging/path conversion or engine change.

A fresh standalone strict plugin/rule consumer passed in 201.08 seconds and its lock proves both exact 1.83.0.1 identities. A separate fresh actual workspace grpc-tools invocation passed its host-binary behavior in 184.46 seconds; workspace lock verification proves both identities too. The existing workspace-root [indices] deprecation remains a documented baseline, so the actual workspace command follows CI's non-strict mode; standalone candidate consumers stay strict. The first workspace diagnostic harness looked for a member lock instead of the root lock after the successful test; postprocessing was corrected and the root lock was independently verified. The grpc-cpu consumer now includes the standard string header explicitly after GCC CI exposed missing string comparison declarations. All seventeen updater regressions pass.

The organization audit includes seven -m repositories: Godot was omitted from the initial six-repository inventory. Godot 10.0.0-rc1.1 is now indexed with a standalone math behavior consumer and an actual installed-template CI check. Its source head 40f72d5 has Linux/macOS/Windows CI green, including the explicit one-symbol Windows extension export check; actual loading by a Godot process remains separate scope. All seven root READMEs are 42–52 lines per language, with details under docs/.

Added the new canonical mcpplibs.mwrap.opencv@5.0.0.1 descriptor under pkgs/mwrap and its tests/mwrap/opencv-cpu consumer. The first immutable 52f4c8f archive passed a real strict installed image/scalar consumer in 67.22 seconds: exact grayscale pixels, PNG/JPEG roundtrips, saturation/rounding and generic min/max/makePtr. The actual default image template also installed and built strictly in a fresh home. Its release packaging audit then correctly failed because the old source manifest deployed no OpenCV license tree. Source checkpoint 5da7fc8 now explicitly deploys all fourteen retained wrapper/upstream license/copyright files with original paths. The installed-template helper checks each byte and executes the relocated application with a clean HOME/runtime environment, verifies its 64x64 PNG and, on Linux, confirms loader dependencies stay inside the bundle. The fixed archive/deployment rerun is in progress and is a native CI gate; no release readiness is claimed yet.

The gRPC native source workflow completed its advanced program but failed a stale unscoped generated-source assertion. New source 0d11b22 checks common/types.pb.cc beside the real mock output, finds the actual generation graph by its edge rather than filesystem order, and removes the expired pre-cache-fix local-cache workaround. A local LLVM advanced generation/RPC rerun passed in 3m40s and all generated outputs/edge metadata were checked; latest native source CI is running.

Each candidate below was downloaded twice with matching SHA256. Existing published archive versions are unchanged. The full audit reports 91 automatic declarations and two reviewed immutable snapshots; the five current new/updated archive descriptors pass resolver grammar and name/namespace/mirror/version checks. No merge, tag or release has been performed.

| Repository | Exact source | SHA256 |
|---|---|---|
| opencv-m | `5da7fc8abedc700ce1ed91a1f57067ad552c74fc` | `5b26b4150610a25f69947e570bb6eed5d832b276d79d5e04af5fdc5842f5279c` |
| onnxruntime-m | `576c780bfcbd792c7f4194942c90324f183a48aa` | `3654811f65b98ade75b5e46fe59a0c4479d815aa7fa9aceff9f9cc3fffd8ddc1` |
| llama.cpp-m | `5028a1aa4f741db4dbd86d6ebd1928ef21027147` | `9b21c35c17e801ceee1165960eefbf7280ad50e14aaf3ea5603fbf2c4ab911de` |
| ffmpeg-m | `1e8bce6ee12c50e43058245df42515ffbabfc78f` | `595b5bcca166583dd082ae911f7e9ed279a3e8899e9564f0901e084737c89ab2` |
| grpc-m | `0d11b22399875f2847f04609fd4fccb50fda5410` | `8a4ff91f60ac6c58e3bdb9d18f67617865f948343afff9e94b855cf82612251a` |
| imgui-m | `ffebf83be99ba0eec2677cc197dea3316a72b501` | `9aab8af876c6c9eaed887b0d84bf3bb733db1d28613cbd5083845d83f675a92f` |
| godot-cpp-m | `40f72d5533a9bc29b17e62ae8a6c84b3dc593071` | `79f15b4f70b0ef07e8b751c928f9e3fd7a6b32703f09b177ad02cdfd676a7f33` |

## Refresh ordering and final archive evidence

On 815c647, updater candidate jobs for FFmpeg/llama failed because the workflow prepared the candidate and then ran mcpp index update, replacing it with the published snapshot. This is a fixture ordering bug, not missing package support. An actual pinned-client reproduction installed the candidate first, refreshed, and then correctly failed to resolve 8.1.2.1 against the published 8.1.2 entry. Preparing the complete candidate after refresh restored real archive/template lookup. The workflow now reapplies the fixture after registry setup/index refresh; no engine or low-level registry configuration changes are needed. All seventeen updater regressions still pass.

The final OpenCV 5da7fc8 archive passed strict GCC 16.1.0 image/scalar consumption in a new home (152.96 seconds). Its actual fresh default template built strictly, packed in release/self-contained mode and ran after relocation with clean HOME/runtime paths. All fourteen wrapper/upstream notices matched their installed source bytes; the relocated application generated a valid 64x64 PNG and the Linux loader resolved every file-backed dependency within the bundle. The previous 52f4c8f package was independently shown to lack that license tree, so the new deployment gate detects the real packaging regression.

The final Godot 40f72d5 archive/default math template also passed strict fresh-home LLVM build and execution (3m29s build); it printed vector length five and cross product (0,0,1). Source native CI was already green on all three targets. Current OpenCV/gRPC/index native heads remain under validation. No merge, tag or release is included.
