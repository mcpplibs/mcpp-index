# mwrap category and ONNX Runtime SDK implementation

The new mwrap category is flat under pkgs/mwrap. Existing clients scan one category level and the publishing script copies pkgs unchanged; no staging conversion or mcpp engine change is required. Consumers live under tests/mwrap and participate in the same selection/shard/timing entry points as existing examples.

compat.onnxruntime owns the official MIT-licensed 1.25.1 CPU SDK, including exact platform checksums. The module wrapper remains in mcpplibs/onnxruntime-m and exposes upstream Ort/C names. The provider supports Linux glibc x86_64, macOS arm64 and Windows x86_64 MSVC ABI. Unsupported architectures/libcs fail explicitly. Linux runtime closure declares gcc-runtime and glibc; it never farms libc or an ELF loader from the host.

Local checks: strict descriptor parse, cross-package references, duplicate/platform version lint and shard inclusion passed. Isolated SDK installation and real inference/header coexistence passed with LLVM 23.1.3; GCC 16.1.0 also passed, followed by actual template creation/build/inference. Native wrapper CI pins SDK provider commit 3067e52abc0165b453ea3acac4022895ebf7d9bc.

The formal English/Chinese mwrap specification records upstream[.N] versions, modules versus API namespaces, macros, optional features and executable quickstart templates. The package skill links this common specification. Autoupdate is not enabled for the SDK yet: updating it requires changing archive directory names, API inventory and ABI verification, rather than only replacing a URL version.

Checkpoint state: SDK provider and category infrastructure first. The opencv/onnxruntime wrapper descriptors must be added only after immutable source archives and checksums are verified and install/template consumers execute through this index. No placeholder published versions, release tags or merges are performed here.

CI caught a semantic difference in migrating root [indices] to [workspace.indices]: the latter merges namespace entries into members, registering the same physical index twice for non-compat members and triggering xlings ambiguity. Keep the existing root [indices] replacement semantics deliberately; this is supported compatibility behavior in the pinned client. No engine patch or per-member mass rewrite is needed. Reproduction: graphics side-effects job 120643941884 failed before installing any graphics package.
