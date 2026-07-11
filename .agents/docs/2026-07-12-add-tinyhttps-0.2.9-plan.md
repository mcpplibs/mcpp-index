# mcpplibs.tinyhttps 0.2.9 index update

## Scope

- Add upstream Form A module release `mcpplibs.tinyhttps@0.2.9` for Linux, macOS, and Windows.
- Mirror the immutable GitHub tag archive byte-for-byte to `mcpp-res/tinyhttps`.
- Add a three-platform module smoke example that compiles and runs exported request, proxy, response, and strict chunk-size APIs without external network access.

## Release and source evidence

- Upstream release: `https://github.com/mcpplibs/tinyhttps/releases/tag/0.2.9`
- Tag commit: `965d805050d02fd6ed244473a6a68b6ace4bf032`
- GLOBAL URL: `https://github.com/mcpplibs/tinyhttps/archive/refs/tags/0.2.9.tar.gz`
- CN URL: `https://gitcode.com/mcpp-res/tinyhttps/releases/download/0.2.9/tinyhttps-0.2.9.tar.gz`
- SHA256: `b17e0b15d2c205a2918708bcd3ac992384f1a38d03232c28f17190a1db081e54`

The GLOBAL archive was downloaded independently twice and both files had the recorded SHA256. The exact first download was uploaded through `gtc`; a fresh CN download returned HTTP 200 and was byte-identical to GLOBAL.

## Package shape and features

The upstream archive contains `mcpp.toml`, C++23 module sources, and its `compat.mbedtls` dependency, so the existing Form A descriptor remains appropriate and requires no inline `mcpp` recipe. Version 0.2.9 adds no index-level optional source component, so no feature gate is needed.

## Verification gates

- Lua syntax and mirror-table lint for all package descriptors.
- Resolver grammar parse with CI-pinned mcpp 0.0.87.
- `tests/smoke_tinyhttps_module.sh` with CI-pinned mcpp 0.0.87 and `MCPP_INDEX_MIRROR=GLOBAL`. The script reseeds only the checkout's `pkgs/` into the builtin `mcpplibs` index because builtin namespaces cannot be overridden by a workspace path index. Limiting the copy to package descriptors also avoids copying workspace build trees produced by an earlier CI step.
- CN HTTP 200 and byte-identical SHA256 verification.
- GitHub Actions Linux, macOS, and Windows workspace jobs run the tinyhttps smoke after the workspace suite, plus CN reachability.
