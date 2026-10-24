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
