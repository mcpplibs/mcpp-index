-- M6.x glob-aware Form B descriptor for Lua 5.4.
--
-- Pure-C library; relies on mcpp 0.0.2's C-language compile rule (`.c`
-- routed to `c_object` via the gcc/clang sibling driver). Builds the
-- 32 library translation units (CORE_O + LIB_O from upstream's
-- src/Makefile) into a single static archive `liblua.a`. The two
-- binary entry points (`src/lua.c` for the interpreter and
-- `src/luac.c` for the bytecode compiler) are intentionally excluded —
-- both define `int main()` and aren't part of the embeddable library.
-- Consumers `#include <lua.h>` and link against liblua.a.

package = {
    spec        = "1",
    namespace = "compat",
    name        = "compat.lua",
    description = "A powerful, efficient, lightweight, embeddable scripting language",
    licenses    = {"MIT"},
    repo        = "https://www.lua.org",
    type        = "package",

    xpm = {
        linux = {
            ["5.4.7"] = {
                url    = "https://github.com/xlings-res/lua/releases/download/5.4.7/lua-5.4.7.tar.gz",
                sha256 = "9fbf5e28ef86c69858f6d3d34eccc32e911c1a28b4120ff3e84aaa70cfbf1e30",
            },
        },
        macosx = {
            ["5.4.7"] = {
                url    = "https://github.com/xlings-res/lua/releases/download/5.4.7/lua-5.4.7.tar.gz",
                sha256 = "9fbf5e28ef86c69858f6d3d34eccc32e911c1a28b4120ff3e84aaa70cfbf1e30",
            },
        },
        windows = {
            ["5.4.7"] = {
                url    = "https://github.com/xlings-res/lua/releases/download/5.4.7/lua-5.4.7.tar.gz",
                sha256 = "9fbf5e28ef86c69858f6d3d34eccc32e911c1a28b4120ff3e84aaa70cfbf1e30",
            },
        },
    },

    -- Form B `mcpp` segment: paths are globs relative to the verdir
    -- (~/.mcpp/registry/data/xpkgs/<idx>-x-lua/<ver>/). The leading
    -- `*/` absorbs the upstream tarball's `lua-5.4.7/` wrap layer.
    mcpp = {
        language     = "c++23",                   -- top-level [package].standard knob; mcpp drives a c++23 toolchain even for pure-C deps.
        import_std   = false,                     -- pure C — no `import std;`.
        c_standard   = "c99",                     -- Lua's reference build is c99-clean; matches upstream src/Makefile.
        include_dirs = { "*/src", "mcpp_generated/include" }, -- public headers plus package-owned config.
        cflags       = { "-include mcpp_lua_platform_config.h" },
        generated_files = {
            ["mcpp_generated/include/mcpp_lua_platform_config.h"] = "#ifndef MCPP_LUA_PLATFORM_CONFIG_H\n#define MCPP_LUA_PLATFORM_CONFIG_H\n#if !defined(_WIN32) && !defined(LUA_USE_LINUX) && !defined(LUA_USE_MACOSX)\n#if defined(__APPLE__)\n#define LUA_USE_MACOSX\n#else\n#define LUA_USE_LINUX\n#endif\n#endif\n#endif\n",
        },
        sources = {
            "*/src/lapi.c",
            "*/src/lauxlib.c",
            "*/src/lbaselib.c",
            "*/src/lcode.c",
            "*/src/lcorolib.c",
            "*/src/lctype.c",
            "*/src/ldblib.c",
            "*/src/ldebug.c",
            "*/src/ldo.c",
            "*/src/ldump.c",
            "*/src/lfunc.c",
            "*/src/lgc.c",
            "*/src/linit.c",
            "*/src/liolib.c",
            "*/src/llex.c",
            "*/src/lmathlib.c",
            "*/src/lmem.c",
            "*/src/loadlib.c",
            "*/src/lobject.c",
            "*/src/lopcodes.c",
            "*/src/loslib.c",
            "*/src/lparser.c",
            "*/src/lstate.c",
            "*/src/lstring.c",
            "*/src/lstrlib.c",
            "*/src/ltable.c",
            "*/src/ltablib.c",
            "*/src/ltm.c",
            "*/src/lundump.c",
            "*/src/lutf8lib.c",
            "*/src/lvm.c",
            "*/src/lzio.c",
        },
        targets = { ["lua"] = { kind = "lib" } },
        deps    = { },
    },
}
