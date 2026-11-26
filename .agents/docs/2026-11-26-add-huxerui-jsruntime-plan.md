# Add `huxerui.jsruntime` 0.1.1

- **Package**: `huxerui.jsruntime` `0.1.1` (Form A native `mcpp` C++23 module package)
- **Upstream**: `https://github.com/HuxerUI/Lib-JSRuntime` (`v0.1.1`)
- **Modules**: `huxerui.jsruntime`, `huxerui.jsruntime.quickjs`
- **Dependencies**: `huxerui.huxerui = "0.5.5"` (QuickJS C11 engine and JS `runtime.js` bridge are vendored/embedded in `Lib-JSRuntime`; prebuilt `esbuild` binaries were decoupled in `v0.1.1` and fetched/verified by CMake on demand only when bundling `.tsx` inputs, shrinking the source archive from 87.63 MiB to ~0.64 MiB)
- **Licenses**: `MIT`, `Unicode-3.0` (`LICENSE`, `quickjs/third_party/quickjs/LICENSE`, `quickjs/third_party/quickjs/libunicode-table.h`)
- **Verification**:
  - `mcpp xpkg parse pkgs/h/huxerui.jsruntime.lua` (`form A`)
  - Lua lint checks across `tests/check_*.lua`
  - Cold `bash tests/run_members.sh huxerui-jsruntime` on Linux (`mcpp test -p huxerui-jsruntime`)
