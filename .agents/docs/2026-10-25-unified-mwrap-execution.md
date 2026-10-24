# Unified mwrap first-release execution ledger

User authorized implementation, one PR per repository, complete CI/self-review,
squash merge, upstream-aligned releases, GitCode mirrors, final index merge and
real local consumption. The [approved plan](2026-10-25-mwrap-unified-identity-and-first-release-plan.md)
defines the migration; its earlier design-only wording records that prior phase.

## Implementation checkpoint

- Seven wrapper manifests use mcpplibs.mwrap; Godot uses godot_cpp. First package
  versions equal their pinned upstream versions. Original SDK sources stay intact.
- Five legacy module families and consumers move to complete module names.
  Common macro mappings live in each .macros namespace; preprocessing stays textual.
- Fourteen READMEs default to English plus Chinese, top links in both directions,
  retaining original primary section order and platform/API limits, below 100 lines.
- Seven flat pkgs/mwrap/<lib>.lua descriptors carry the full declared identity.
  Legacy wrapper descriptors and their old versions remain unchanged. The gRPC
  host plugin/rule retain independent 1.83.0.1 packaging revisions, appended without
  changing published version blocks; those are tools, not mwrap interfaces.
- Bilingual canonical specification, schema/type docs and existing authoring skill
  are synchronized. Future release tags use the independent mwrap-${version} stream.
- Local strict FFmpeg, ImGui and Godot behavior/macro tests pass. Llama's complete
  Python unit suite and real macro module consumer pass. Remaining native CI and
  final local installed-release checks are still gates, not assumed successful.
- New native CI exposed a CP1252 README decode failure on Windows. All seven release
  guards now read UTF-8 explicitly. A Clang failure from placing a new module import
  after declarations was fixed at the producer/root and in the Godot generator.
- Aggregate host CPU briefly reached 96% during gRPC local testing; the guard stopped
  the task and that run is not counted passing. Retry uses an 8-core aggregate quota,
  four compile jobs, MemoryHigh 28GiB / MemoryMax 32GiB and the host 80% guard.

## Evidence and open gates

Candidate heads: /tmp/mwrap-unified-candidate-heads.json.
Double-download and tracked-source equivalence: /tmp/mwrap-unified-archive-equivalence.json.
CI observer: /tmp/mwrap-unified-source-ci.json (read exact current heads, not old successes).
Local logs: /tmp/mwrap-unified-{ffmpeg,imgui,godot}-local*.log;
/tmp/mwrap-unified-llama-unit-final.log; /tmp/mwrap-unified-llama-local.log;
/tmp/mwrap-unified-grpc-local-retry.log.

No merge or release has occurred at this checkpoint. Formal archive URLs and
verified byte-identical CN mirrors replace commit snapshots only after release.
Full current-head source/index CI, final ecosystem review, merge/tag consistency,
GitCode asset fetch and installed published-index templates remain required.


## README layout refinement and local installation evidence

The user refined the common opening: title, one-sentence introduction, one line
combining languages/upstream/Releases/mcpp/Index, badges, optional detailed
introduction, then the original quickstart section. Characteristics is omitted;
actual mcpp manifest feature switches may use a concise table. The repetitive
fixed tool-version/index-publication paragraph is removed. Pages may be shorter
than the relaxed 100–150-line target. Canonical English/Chinese layout documents
are docs/mwrap-readme.md and docs/zh/mwrap-readme.md; the main spec and skill link
them. All fourteen pages follow this order and the release guard allows 150 lines.

Subsequent actual local results: OpenCV all-modules/software SIMD 38 programs
pass; gRPC two programs pass after the resource-safe retry; llama 117 unit tests
pass; ORT cold SDK installation, export audit and actual generated Identity model
inference pass. The complete unchanged candidate index with pkgs/mwrap/ffmpeg.lua
also creates the unmodified FFmpeg project from its real checksummed archive and
runs generated-media encode/decode (three frames). This is actual short-filename
index discovery, not only a descriptor parser result. Seven independent GitCode
mirror repositories are initialized; release assets are not uploaded yet.

README-only commits require new exact-head CI and archive pins. Earlier green
heads remain historical evidence; no merge or release is inferred from them.


Final opening refinement: the upstream link label is exactly Upstream. Modules
precedes Getting started/Quick start/Install, lists verified complete import
statements with descriptions, and ends with a More Modules API blockquote link.
All fourteen READMEs have been checked against actual module declarations and
local link destinations; usage documents no longer label modules with legacy
names. These documentation changes retain the tested implementation bodies.


## Official SDK CN mirror closure

The official ONNX Runtime 1.25.1 CPU SDK is mirrored at
https://gitcode.com/mcpp-res/onnxruntime-cpu-sdk/releases/tag/1.25.1 .
Linux x64, macOS arm64 and Windows x64 archives were downloaded twice from the
official release, matched their existing descriptor SHA256 values and retained
LICENSE/ThirdPartyNotices.txt. Each uploaded CN resource was then fetched publicly
and matched the same SHA256. The new SDK descriptor adds only the verified URL
mirror table; SDK bytes, versions, ABI guards and runtime deployment stay intact.
Evidence: /tmp/mwrap-ort-sdk-cn-records.json and /tmp/mwrap-mirror-ort-sdk.log.
