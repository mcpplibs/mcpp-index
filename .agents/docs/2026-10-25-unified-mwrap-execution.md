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

At the initial implementation checkpoint no merge or release had occurred. Formal archive URLs and
verified byte-identical CN mirrors replace commit snapshots only after release.
Full current-head source/index CI, final ecosystem review, merge/tag consistency,
GitCode asset fetch and installed published-index templates remain required.


## README layout refinement and local installation evidence

The user refined the common opening: title, one-sentence introduction, one line
combining languages/upstream/Releases/mcpp/Index, badges, optional detailed
introduction, then Modules and the original quickstart section. Characteristics is omitted;
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


## Verified merge and publication checkpoint

ORT, llama.cpp, Godot, ImGui and FFmpeg have now passed their exact PR-head CI
and self-review and been squash merged. Their reviewed PR and squash trees are
compared before tagging; squash-commit workflows remain separate release gates.
OpenCV and gRPC still have active native CI at their frozen final PR heads.

ORT 1.25.1 is formally published as mwrap-1.25.1. The GitHub source asset was
downloaded twice, matched its published checksum, and matched every tracked
squash-commit file. Its public GitCode mirror was fetched and matched the same
SHA256, 75e35e39d45ae16462afce5c1a6bbacdd8e7bd8a23d4837f0308a4cdd989ceb0.
Formal resource replacement is batched after the seven library releases; the
current candidate index is not claimed to be published.

Same-version cache tests alternate old/new/old/new identities in a fresh private
home, building and running each consumer and checking lockfile namespace/version.
FFmpeg, OpenCV and ImGui pass all four alternations. The immutable legacy llama
b10069 archive fails LLVM23 compilation because its upstream header lacks getenv
and atoi declarations. This is recorded as a legacy build failure, not a passed
cache test; no historical archive or mcpp engine source is patched.

Machine evidence: /tmp/mwrap-unified-merged-libraries.json,
/tmp/mwrap-unified-tagged-libraries.json, /tmp/mwrap-unified-published-libraries.json,
/tmp/mwrap-same-version-cache-results.json,
/tmp/mwrap-more-cache-isolation-results.json.

## User licensing correction

The user added a common policy for all mwrap / xxx-m wrappers: Apache-2.0 wrapper
license, mcpp-community attribution, original upstream README/license documents
retained under upstream/. Automatic further tagging/publication has been stopped
while seven repositories and the normative docs/skill are brought into alignment.
ORT 1.25.1 has already been published; Godot 10.0.0-rc1 was tagged but its queued
release workflow was cancelled. Those existing tags/assets will not be rewritten.
Corrected versions use one wrapper revision suffix where a tag already exists.

The seven license corrections are pushed. ORT #2, llama.cpp #6, FFmpeg #9,
ImGui #14 and Godot #2 are follow-up PRs because their original identity PRs
were already merged before the new policy instruction. OpenCV #1 and gRPC #8
continue on their existing PRs. ORT now targets 1.25.1.1 and Godot 10.0.0-rc1.1,
without changing either upstream SDK version. All seven release guards verify
Apache-2.0, mcpp-community authors/NOTICE, pinned upstream document hashes and
explicit notice deployment. Negative local cases reject wrong wrapper license,
missing attribution, changed upstream bytes and missing NOTICE deployment.
Native CI and final archive/installed-consumer verification are still pending.

Windows Godot CI exposed Git autoCRLF rewriting the pinned upstream README.
The guard correctly rejected its changed bytes. All seven repositories now
set upstream/** -text -whitespace: original bytes and original whitespace are
preserved, rather than normalizing or weakening the document hash check.
A local checkout-index test with core.autocrlf=true passes the release guard
for all seven repositories. Exact-head native CI is restarted for the corrected
commits; the earlier failed run is retained as failure evidence.

All five old/new same-upstream-version cache pairs now pass four alternating
builds/runs with namespace/version lock checks: FFmpeg, OpenCV, ImGui, llama.cpp
(GCC16) and gRPC. The gRPC cold-home retry provisions regular managed tool
payloads instead of borrowing symlinks for tools whose installers record state.
Evidence: /tmp/mwrap-grpc-cache-isolation-cold-tools.log and
/tmp/mwrap-more-cache-isolation-results.json.

Index CI at 69a2a3a exposed an integration failure with newly advanced main
0292416: member_platforms still read only tests/examples, although direct_member
selected tests/mwrap/grpc-tools. Main was merged without dropping its new
OpenKAL entries or platform rules. Platform selection and preparation now share
a manifest lookup over both consumer directories; fully qualified runtime and
host-tool dependencies are recognized. Nineteen updater regression tests pass;
the actual corrected plan retains all eight gRPC host-tool build/run jobs,
including Linux default/LLVM, Windows and macOS, rather than silently skipping
them. Earlier failed CI is not counted as a pass.

## Final user version instruction

The user explicitly authorized overwriting problematic initial releases instead
of adding wrapper suffixes: all seven target versions equal upstream exactly.
ORT returns to 1.25.1 and Godot returns to 10.0.0-rc1. Earlier suffix decisions
above are historical and superseded. Publication automation is stopped until
corrected-commit gates and controlled replacement preflight are ready. Existing
first-release metadata/assets are recorded before replacement for traceability.

License deployment review also identified that the ORT SDK provider and wrapper
both targeted licenses/onnxruntime/LICENSE with different licenses. Wrapper
Apache-2.0 and NOTICE are moved into licenses/onnxruntime/wrapper; SDK MIT LICENSE
and ThirdPartyNotices retain their own destination. The release guard and actual
relocation acceptance verify these separate ownership paths.

## Godot stable upgrade requested by user

Switch the wrapper/provider target to 10.0.0 from upstream 10.0.0-stable, commit
507ed9d840c01a3c5b2a39af8bb4000bfac30bf5. Follow its declared default Godot 4.7
API (64-bit, single precision). Two independent upstream-only repacks match
SHA256 66aaafb642e7a390482dc381818640b1d0e583da2ef0cc9709214bcd13b68264.
Both public GLOBAL and CN SDK downloads match those bytes. Preserve the older
compat versions, add 10.0.0 and a real header consumer, regenerate the wrapper
from stable headers, and remove the obsolete linkage shim now fixed upstream.
Legacy shim regeneration remains byte-identical; current stable compilation
and new native CI remain required, not inferred from the old RC checks.

Stable Godot local acceptance now passes: GCC16 and LLVM23 each run all three
module/math/macro programs; a standalone original-header consumer passes; the
summator shared GDExtension builds against the matching Godot 4.7 API. Source
tests additionally instantiate the exported attributed template types via
sizeof, and call the upstream out-of-line float/double hashes. The generated
module reproduces exactly from the stable provider. Evidence:
/tmp/mwrap-godot-stable-local-verified.log,
/tmp/mwrap-godot-stable-local-results.json, /tmp/mwrap-godot-stable-sdk.json.

Initial private-home failures involved incomplete borrowed compiler sysroots,
not SDK build failures; complete managed Linux headers resolved them. The real
GCC compile then exposed new diagnostic/attribute macros being mistaken for
namespace declarations; parser regression and actual exported-type consumers
now pass. Source/archive pins use the corrected committed heads, and source
native CI is not substituted by old RC results.

ORT first-release overwrite acceptance has an actual previous 1.25.1 installed
in /tmp/mwrap-ort-overwrite-cache-check/home, with the original MIT root license
and old source digest. After the authorized replacement, the same home will
refresh and consume the corrected same-version source, checking its new license
and actual inference. No wrapper version suffix is introduced.

The corrected ORT 1.25.1 commit has also passed real indexed-archive installation,
Identity CPU inference, self-contained pack and isolated relocation. Acceptance
checks both original SDK MIT/ThirdPartyNotices and distinct wrapper Apache-2.0,
mcpp-community NOTICE and retained upstream documents byte-for-byte. Evidence:
/tmp/mwrap-ort-upstream-aligned-deployment.log (exit 0).

Godot native CI found an existing-home routing problem: copying a candidate
built-in index did not change xlings' previously published catalog routing.
The new SDK therefore appeared missing despite valid published source assets.
The source CI now explicitly routes compat through a test-only namespace view
of unchanged candidate descriptors for the root, extension and template. Final
installed-index tests still consume the original complete publication layout.
This changes no mcpp engine code or upstream implementation bytes.

ORT authorized first-release replacement is now published and publicly fetched
on both forges at version 1.25.1. New archive SHA256 is
bec1f319d9869624b0efeb20c0376c1e429b07f6652f65536f17fca722458d6e.
The recorded old GitHub release/tag and GitCode attachment were replaced only
after corrected squash-commit CI and full archive checks. No version suffix.

A real old-home test found that changing SHA alone leaves the installed source
usable. Packaging metadata revision=1/floor=1 makes the library build refresh
the actual old source; root Apache-2.0 and mcpp-community NOTICE were verified
after automatic download. Public identity, version and tag remain unchanged.
Evidence: /tmp/mwrap-ort-overwrite-cache-proof.json and
/tmp/mwrap-ort-overwrite-cache-configure.log and
/tmp/mwrap-ort-overwrite-cache-inference.log; the strict build and Identity CPU
inference completed successfully with the refreshed source.

Godot 10.0.0 stable source PR #2 passed all three exact-head native jobs and
self-review and was squash merged as d7be0cd9dc8224ec8313e540b515a5aacfc1cf83.
Its new main CI remains a distinct release gate. ImGui 1.92.8 and FFmpeg 8.1.2
formal GitHub/GitCode source assets are also publicly hash-verified.


The current index scan exposed numeric revision/floor metadata being rejected
by the updater's generic plain() conversion while classifying commit archives.
The audit now reads only literal URL nodes for this classification, retaining
historical-resource checks. Its real revision/floor fixture, all 19 updater
regressions and the full current-tree audit pass; the new remote scan passes.

Final public-index acceptance supports a shared dedicated fresh home for the
seven unchanged default scaffolds and optional WebP relocation. The WebP audit
also verifies wrapper NOTICE byte-for-byte. These are prepared checks, not a
claim that final public-index acceptance has already completed.

Completed task-owned architecture build outputs for OpenCV, gRPC and Godot were
removed after checking for active compiler/build processes and tracked files.
41 small build metadata files were preserved alongside all task logs; 8.7 GiB
was freed. Evidence: /tmp/mwrap-completed-architecture-build-cleanup.json and
/tmp/mwrap-completed-build-metadata.zip. No source or user cache was removed.


Godot stable main CI now passes all three native jobs. The formal
[mwrap-10.0.0 release](https://github.com/mcpplibs/godot-cpp-m/releases/tag/mwrap-10.0.0)
is published (draft=false, prerelease=false) at squash commit
`d7be0cd9dc8224ec8313e540b515a5aacfc1cf83`. GitHub and public GitCode
source downloads both match SHA256
`b5f6d13d018f2359913c6e6fba92e24810b1a1585f027547f4b20c5fd27eeec5`.
This proves the stable wrapper publication; public-index installation remains
part of the final index gate.


gRPC PR #8 passed all six current-head checks, including real Linux/macOS RPC
and advanced plan/submit examples, and was squash merged as
`b7a918ef931c270040d0db8ae36478b2d58f8a8a`. Review accepted the one harmless
empty line at the end of src/grpc.cppm; all other whitespace checks pass. The
source commit was kept unchanged so its completed native CI remains exact.
Its merge-commit CI and formal release are separate remaining gates.


All seven GitHub repository topic lists now include mcpp-community, verified
after mutation while preserving existing topics. README/manifest attribution
continues to use that same label. Evidence: /tmp/mwrap-community-topics-proof.json.


After merging newer index main ad0f019 locally, the earlier dc93f6b candidate
validate/OpenKAL runs (40150276669/40150276638) were intentionally canceled to
free queued Linux runners for exact merged-source CI. Their head/event/branch
were checked first. This is not a passing final-index gate: all workflows must
run again on the final formal-resource tree. The old observer ending on these
cancellations is expected, not a new product test failure. The updater run was
retained to finish its remaining host-tool candidates.


Prepublication updater run 40150276617 at dc93f6b completed successfully: all
12 actual candidate builds passed (four Godot stable SDK legs, eight gRPC host
tool legs). Evidence: /tmp/mwrap-prepublication-twelve-candidate-ci-proof.json.
This does not replace final formal-resource index CI.
