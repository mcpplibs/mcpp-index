# Add libxpkg 0.0.44 to mcpp-index

**Date**: 2026-07-12

**Package**: `mcpplibs.xpkg`

**Upstream release**: `openxlings/libxpkg` `v0.0.44`

**Upstream commit**: `343a1fd9a697ba868af209b43862899b05a580c8`

## Package shape

libxpkg is an external Form-A C++23 module repository. The release contains its
own `mcpp.toml`; the index descriptor therefore remains a resource pointer and
does not duplicate upstream build metadata. Version 0.0.44 exports the existing
`mcpplibs.xpkg` module surface and adds the resource-normalization work required
by xlings.

No feature is added: this is a version registration for an upstream module
package, not a source-gated optional component.

## Resources and mirrors

All three platforms use the same GitHub tag archive and SHA256:

- GLOBAL: `https://github.com/openxlings/libxpkg/archive/refs/tags/v0.0.44.tar.gz`
- CN: `https://gitcode.com/mcpp-res/xpkg/releases/download/0.0.44/xpkg-0.0.44.tar.gz`
- SHA256: `152a27425ba418312182bddb316c8c5bc636bbd8a37faf30e75390dc844e2e95`

The GLOBAL archive was downloaded independently twice. The CN release asset was
uploaded from those exact bytes and then downloaded publicly: HTTP 200, equal
size (127252 bytes), equal SHA256, and byte-identical by `cmp`.

Version 0.0.43 is intentionally not registered. The ecosystem integration uses
the final 0.0.44 release, which includes the target-platform context required by
the xpkg normalization boundary.

## Example decision

No new workspace example is committed for this version-only update. `mcpplibs`
is mcpp's default remote index name: the resolver can see an unpublished version
through `[indices].mcpplibs.path`, but the fetch subprocess asks xlings for the
same named registry and resolves the already-published remote tree. Giving the
path index a different alias cannot find a descriptor whose declared namespace
is `mcpplibs`. This is the same default-index local-override class that keeps the
public `imgui` module outside the workspace in `validate.yml`.

A local experiment reached this boundary after resolving the toolchain and then
failed at `fetch 'mcpplibs.xpkg@0.0.44'`; therefore it is not presented as an
end-to-end pass. Adding a git dependency would only test upstream and would not
exercise this descriptor, so it would be misleading. The existing full
workspace remains the regression gate; the new descriptor is covered directly
by strict parsing, mirror validation, and resource byte verification.

## Verification plan

1. Parse `pkgs/x/xpkg.lua` with Lua and CI-pinned mcpp 0.0.87.
2. Run the repository mirror lint and confirm the new CN URL is reachable.
3. Run the repository's existing `mcpp test --workspace` CI matrix to prove the
   version addition does not regress current consumers.
4. Open a PR and require all validation jobs to pass before merge.
