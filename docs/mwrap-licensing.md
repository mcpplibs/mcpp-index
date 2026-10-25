# Licensing for mwrap / xxx-m repositories

This policy applies to wrappers for existing C/C++ header libraries, including
thin `compat.*` consumers and repositories with vendored upstream sources.

- The wrapper defaults to **Apache-2.0**. Root `LICENSE` contains the standard
  Apache License 2.0 text; root `NOTICE` identifies `mcpp-community` contributors
  and states the scope of wrapper contributions.
- Use `mcpp-community` as the wrapper author/attribution label. This does not
  change repository organization, package namespace or import identity:
  `mcpplibs.mwrap.<lib>` remains the public module/package identity.
- GitHub repositories include the `mcpp-community` topic, preserving any existing
  topics; README attribution and manifest authors use the same community label.
- Keep the original upstream README, LICENSE/COPYING and applicable NOTICE or
  third-party notices in `upstream/<lib>/`, preserving their bytes and authors.
  Record their pinned source and checksums. Provider-based wrappers keep these
  documents even when the implementation is supplied separately by `compat.*`.
- Root README describes the wrapper; it links the upstream project and retained
  upstream documents. Its license link/badge describes Apache-2.0 for the wrapper,
  with an explicit note that upstream components retain their own licenses.
- `mcpp.toml` and the new wrapper descriptor declare Apache-2.0. Do not change a
  `compat.*` provider's license to match its wrapper. FFmpeg remains under the
  selected LGPL/GPL configuration; MIT upstream components remain MIT.
- Preserve inherited wrapper copyright/license notices when adopting the new
  wrapper policy; identify retained legacy material separately from upstream.
- Source releases include root LICENSE/NOTICE and upstream documents. Binary
  bundles retain all required upstream/dependency notices, in distinct paths;
  moving documents to upstream must not make deployment drop them.
- Existing tags, releases, URLs and hashes remain immutable. Corrections after
  publication use the next single wrapper revision suffix and fresh validation.

Root Apache-2.0 does not replace upstream licensing or claim upstream copyright.
See the [Apache license application instructions](https://www.apache.org/licenses/LICENSE-2.0#apply).

For byte-pinned upstream documents, disable Git newline conversion with
`upstream/** -text` in `.gitattributes`; verify checkout hashes on Windows too.

For this initial mwrap publication, the user explicitly authorized replacing
the problematic first-release tags/assets instead of adding wrapper revisions.
All seven package versions therefore equal upstream versions. Replacement is
performed only after the corrected commit passes its gates; all download
regions, checksums and installed-consumer checks must be synchronized.

An authorized same-version replacement must also refresh incorrect installed
payloads. Use the index packaging `revision` (and `floor` when the old payload
is unusable); these are metadata integers, not package-version suffixes. Verify
a real old-home build refresh and runtime result before declaring migration complete.
