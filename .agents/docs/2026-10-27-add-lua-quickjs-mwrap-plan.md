# Add mcpplibs.mwrap.lua (lua-m 5.4.7) and mcpplibs.mwrap.quickjs_ng (quickjs-ng-m 0.17.0)

## Form

- Lua: third-party upstream [lua.org](https://www.lua.org), release 5.4.7, MIT. The tarball
  (`9fbf5e28…cfbf1e30`) is the one compat.lua 5.4.7 already pins.
- QuickJS-ng: third-party upstream [quickjs-ng/quickjs](https://github.com/quickjs-ng/quickjs), tag `v0.17.0`,
  MIT. The tarball (`559bc4c4…5687d9`) is the one compat.quickjs-ng 0.17.0 already pins.
- Form A external mwrap module repositories: [mcpplibs/lua-m](https://github.com/mcpplibs/lua-m) (package
  `mcpplibs.mwrap.lua`) and [mcpplibs/quickjs-ng-m](https://github.com/mcpplibs/quickjs-ng-m) (package
  `mcpplibs.mwrap.quickjs_ng`, one atomic segment, as godot-cpp-m is `godot_cpp`). Versions are the upstream
  ones (first release of each identity, no revision suffix); tag series `mwrap-${version}`.
- Implementation ownership: the libraries are compat.lua's and compat.quickjs-ng's (their configuration and ABI
  are sufficient). Neither wrapper vendors upstream code; each retains upstream's README and license under
  `upstream/` with checksums in `upstream/documents.json`. No implementation is linked twice.

## Modules

### mcpplibs.mwrap.lua

- `mcpplibs.mwrap.lua`: every function (`LUA_API`, `LUALIB_API`, `LUAMOD_API`), type and `lua_ident` of
  `<lua.h>`, `<lauxlib.h>` and `<lualib.h>` (171 declarations) by `export using` over `lua.hpp`.
- `mcpplibs.mwrap.lua.macros`: 135 macros in `mcpplibs::mwrap::lua::macros`. Constants are `inline constexpr`,
  including the luaconf.h limits public macros are made of. Function-like macros are functions that evaluate
  their arguments as the macro does. `lua_pushliteral` and `luaL_newlib` are templates over an array.
- Stay macros, in `<mwrap/lua/macros.hpp>` (= `lua.hpp`): `luaL_argcheck`, `luaL_argexpected` and `luaL_opt`
  (lazily evaluated arguments), `luaL_intop` (a pasted operator), and the standalone interpreter's
  `lua_write*`. Not mapped: the include guards and the `LUA_COMPAT_APIINTCASTS` aliases this build does not
  define.

### mcpplibs.mwrap.quickjs_ng

- `mcpplibs.mwrap.quickjs_ng`: every type, enumerator of a named enum and function of `<quickjs.h>` (45, 33
  and 264), generated from the pinned header by `tools/gen_exports.py`.
- The 27 public `static inline` functions (`JS_NewInt32`, `JS_IsException`, `JS_ToCString`, `JS_NewCFunction`
  …) have internal linkage and cannot be exported. They are adapted under their names and signatures in
  `mcpplibs::mwrap::quickjs_ng`, each defined out of line by calling upstream's own inline body.
- `mcpplibs.mwrap.quickjs_ng.macros`: 130 macros. Constants are `inline constexpr` of each macro's type. The
  `JS_TAG_*` enumerators of the header's unnamed (TU-local) enum are constants. The value representation is
  constexpr: `JS_UNDEFINED` and friends are `constexpr JSValue`, while the header's are calls in C++. The
  `JS_*_DEF` initialisers are constexpr functions, so property tables stay constant-initialised.
- Stay macros, in `<mwrap/quickjs_ng/macros.hpp>`: `JS_CFUNC_SPECIAL_DEF` (token pasting) and
  `JS_FreeValues` / `JS_FreeAtoms` (each freed before the next argument is evaluated). The struct
  representation of `JSValue` (64-bit targets) is the one supported; the NaN-boxed one is refused at compile
  time.

Each repository's `tools/check_exports.py` parses the pinned headers and fails when a declaration is not
exported or a macro is neither mapped nor listed with its reason. Both were negative-checked by removing an
export and a mapping.

## Verification

Wrapper CI (Linux GCC 16.1 and LLVM 23.1.3, macOS LLVM, Windows LLVM, all required): build, gtest suites (the
API through the module, the macro constants, the header mixed with the import), the export audit, and
upstream's own tests through an example written against the module:

- lua-m: `lua-5.4.7-tests` (the portable user tests, `lua -e"_U=true" all.lua`) on `examples/lua`, a standalone
  interpreter: "final OK". The interpreter is built optimised, as upstream's is: an unoptimised build
  overflowed Windows' 1 MB stack in the stack-overflow tests.
- quickjs-ng-m: the release's `tests/*.js` on `examples/qjs` (file imports, import attributes, print/gc), each
  test's frontmatter honoured as `run-test262` does: 77 pass. Left out are the 9 that `tests.conf` excludes
  and the 10 that import quickjs-libc, which compat.quickjs-ng does not build. On Windows the host links an
  8 MB stack, as upstream links its programs (the 1 MB default equals the JS stack limit).

The templates jobs scaffold each default `script` template as an installed package and run it.

Here, with the CI-pinned mcpp 2026.10.26.1 and `MCPP_INDEX_MIRROR=GLOBAL`:

- `bash tests/run_members.sh lua-embed quickjs-embed`: the real release archives through the candidate index.
  The consumers call C functions and closures from the scripts, read errors, and use userdata, classes and
  property tables: `test result ok`.
- `python3 tests/mwrap/check_installed_template.py --package mcpplibs.mwrap.lua@5.4.7` (and `quickjs_ng@0.17.0`):
  "Verified real indexed archive installation and unmodified template consumer".

## Mirror and updates

No `mcpp-res` access in this change, so the descriptors use the GitHub release URLs as plain strings (CN users
fall back to them); a maintainer can add the GitCode mirror with identical bytes. `extensions.autoupdate`
follows each repository's own `mwrap-${version}` tags.

## Motivation

openmui's script bindings (openmui.lang.lua, openmui.lang.js) embed Lua and QuickJS-ng. Through these modules,
their sources import the engines instead of including C headers in native units.
