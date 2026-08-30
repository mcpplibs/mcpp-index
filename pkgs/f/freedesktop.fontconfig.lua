-- freedesktop.fontconfig — font discovery and matching.
--
-- `compat.freetype` rasterizes a glyph and `compat.harfbuzz` shapes a run, but
-- neither can answer "give me a sans-serif that has CJK". That is fontconfig,
-- and it is what every toolkit above this layer links: cairo and pango both
-- require it, and any program that names a font rather than a font FILE needs
-- it.
--
-- ─────────────────────────────────────────────────────────────────────────
-- EVERY GENERATED FILE IS PRODUCED BY build.mcpp — NO python, sh OR gperf
--
-- Upstream's meson emits SEVEN artifacts through python and gperf. All seven
-- are text transforms over files already in the tarball, so the fork's
-- `build.mcpp` — C++ that mcpp compiles and runs — does them:
--
--     fcstdint.h                  a copy
--     fcalias.h/fcaliastail.h     internal-alias headers (makealias.py)
--     fcftalias.h/…               the same over fcfreetype.h
--     fcobjshash.h                object-name lookup (cutout.py + gperf)
--     fclang.h                    281 .orth files -> charset bitmaps
--     fccase.h                    Unicode case folding
--     src/fontconfig.cppm         the C++23 module wrapper
--
-- THE TWO BIG ONES ARE VERIFIED BYTE-FOR-BYTE against upstream's own Python,
-- and the fork's CI re-runs those scripts and diffs on every push: `fclang.h`
-- is 4,897 lines, `fccase.h` is 368. A transliteration is only worth having if
-- something checks it against the original.
--
-- `fcobjshash.h` is a DECISION rather than a transliteration: upstream runs the
-- C preprocessor and gperf to build a perfect hash over 72 entries, and the one
-- consumer — `fcobjs.c` — calls `FcObjectTypeLookup(str, strlen(str))` and
-- reads a single field. A sorted table with a binary search has identical
-- semantics and removes both tools.
--
-- ─────────────────────────────────────────────────────────────────────────
-- THE RUNTIME PATHS ARE EMPTY, AND THAT IS THE USUAL DECISION
--
-- `FC_DEFAULT_FONTS`, `FC_FONTPATH`, `FC_CACHEDIR`, `CONFIGDIR` and
-- `FONTCONFIG_PATH` point into the build prefix upstream, which after
-- relocation is the HOST's fonts and the HOST's configuration — the same silent
-- host edge that gave Vulkan an llvmpipe device instead of the GPU.
--
-- fontconfig has the escape hatches that make empty workable: `FONTCONFIG_FILE`
-- (which config to read), `FONTCONFIG_PATH` (where configs live) and
-- `FONTCONFIG_SYSROOT` (a prefix over both), all read in fccfg.c. An ecosystem
-- that ships fonts declares them, exactly as xim:xkeyboard-config declares
-- XKB_CONFIG_ROOT — and until something does, `FcInit()` finds no fonts and
-- says so rather than rendering with the developer's.
--
-- ⚠ TWO FREETYPE PROBES ARE OFF, and this is worth knowing before someone
-- "fixes" them: `HAVE_FT_GET_BDF_PROPERTY` and `HAVE_FT_GET_PS_FONT_INFO` are
-- absent because `compat.freetype` does not build the BDF and Type1 modules.
-- Claiming them compiles cleanly and fails at LINK with eight undefined
-- references from fcfreetype.c. A probe answer has to describe THIS freetype,
-- not upstream freetype's default build.
package = {
    spec        = "1",
    namespace   = "freedesktop",
    name        = "fontconfig",
    description = "fontconfig 2.15.0 — font discovery and matching, every generated file produced by build.mcpp",
    licenses    = {"MIT"},
    repo        = "https://github.com/mcpplibs/fontconfig",
    type        = "package",

    xpm = {
        linux = {
            ["2.15.0"] = {
                url = {
                    GLOBAL = "https://github.com/mcpplibs/fontconfig/releases/download/v2.15.0/fontconfig-2.15.0-mcpp3.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/fontconfig/releases/download/2.15.0/fontconfig-2.15.0-mcpp3.tar.gz",
                },
                sha256 = "505938aeeafe92257ea2c08d0af0e091d25af3e8d872b0dc82478605cbf99233",
            },
        },
    },

    mcpp = "*/mcpp/fontconfig/mcpp.toml",
}
