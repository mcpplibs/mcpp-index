-- freedesktop.libxkbcommon — libxkbcommon 1.13.2, keyboard handling.
--
-- A compositor gets keycodes from the kernel and has to turn them into keysyms
-- and text: which layout, which modifiers, which compose sequence. That is
-- libxkbcommon, and every Wayland compositor links it.
--
-- ─────────────────────────────────────────────────────────────────────────
-- SHAPE: a fork, for one generated file
--
-- The xkbcomp parser is bison's output from `src/xkbcomp/parser.y` — 3,960
-- lines — and upstream requires bison >= 3.6 at build time. That output is a
-- pure function of the .y file, so it is precomputable: the generator runs
-- once in [mcpplibs/libxkbcommon](https://github.com/mcpplibs/libxkbcommon),
-- the result is checked in, and that fork's CI regenerates and diffs. No bison
-- in a consumer's build.
--
-- The `-p _xkbcommon_` prefix the generator passes is load-bearing rather
-- than cosmetic: it renames every symbol bison emits. Without it this parser
-- would export bison's default names and collide with any other generated
-- parser in the same process.
--
-- ─────────────────────────────────────────────────────────────────────────
-- IT COMPILES KEYMAPS; IT CONTAINS NONE
--
-- The layouts are xkeyboard-config's, a separate dataset. `DFLT_XKB_CONFIG_ROOT`
-- in this build is EMPTY on purpose: `xkb_context_getenv(ctx,
-- "XKB_CONFIG_ROOT")` is consulted first (src/context.c:236) and upstream's
-- default points into the build prefix, which after relocation is the HOST's
-- dataset. Same stance as compat.libgbm with `GBM_BACKENDS_PATH` and
-- freedesktop.egl with `__EGL_VENDOR_LIBRARY_DIRS` — empty, so a missing
-- dataset says "no keymap found" rather than silently using the host's.
--
-- A consumer that only needs `xkb_keymap_new_from_string` — which is how a
-- compositor receives a client's keymap over the wire, and how this package's
-- test exercises the parser — needs no dataset at all.
package = {
    spec        = "1",
    namespace   = "freedesktop",
    name        = "libxkbcommon",
    description = "libxkbcommon 1.13.2 — keymap compilation and keyboard state, xkbcomp parser pre-generated",
    licenses    = {"MIT"},
    repo        = "https://github.com/mcpplibs/libxkbcommon",
    type        = "package",

    xpm = {
        linux = {
            ["1.13.2"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/libxkbcommon/archive/refs/tags/1.13.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/libxkbcommon/releases/download/1.13.2/libxkbcommon-1.13.2.tar.gz",
                },
                sha256 = "34f467ef6ec9926a27d174903080b9bde49e4563bf592a183c52eb7f41be93c8",
            },
        },
    },

    mcpp = "*/mcpp/xkbcommon/mcpp.toml",
}
