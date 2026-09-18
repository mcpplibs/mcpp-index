package = {
    spec        = "1",
    namespace   = "compat",
    name        = "zlib",
    description = "A compression library",
    licenses    = {"Zlib"},
    repo        = "https://github.com/madler/zlib",
    type        = "package",

    xpm = {
        linux = {
            ["1.3.2"] = {
                url    = {
                    GLOBAL = "https://github.com/madler/zlib/archive/refs/tags/v1.3.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/zlib/releases/download/1.3.2/zlib-1.3.2.tar.gz",
                },
                sha256 = "b99a0b86c0ba9360ec7e78c4f1e43b1cbdf1e6936c8fa0f6835c0cd694a495a1",
            },
        },
        macosx = {
            ["1.3.2"] = {
                url    = {
                    GLOBAL = "https://github.com/madler/zlib/archive/refs/tags/v1.3.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/zlib/releases/download/1.3.2/zlib-1.3.2.tar.gz",
                },
                sha256 = "b99a0b86c0ba9360ec7e78c4f1e43b1cbdf1e6936c8fa0f6835c0cd694a495a1",
            },
        },
        windows = {
            ["1.3.2"] = {
                url    = {
                    GLOBAL = "https://github.com/madler/zlib/archive/refs/tags/v1.3.2.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/zlib/releases/download/1.3.2/zlib-1.3.2.tar.gz",
                },
                sha256 = "b99a0b86c0ba9360ec7e78c4f1e43b1cbdf1e6936c8fa0f6835c0cd694a495a1",
            },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        c_standard   = "c11",
        include_dirs = {"*", "mcpp_generated/include"},
        -- GCC/Clang-only, safe unconditionally: the header's own guard
        -- (`#if !defined(_WIN32)`) is the real platform test, this placement
        -- is not. It used to sit only in the linux/macosx blocks below,
        -- because on native Windows _WIN32 is always true and the header
        -- defines nothing there -- and on Windows with musl as the C library
        -- (an openkal graph) _WIN32 used to be true too, so a `target_cfg`
        -- carried a hand-written `-U_WIN32 -include unistd.h` to reach the
        -- same POSIX-shaped compile that Linux and macOS already got from
        -- this same header. openkal-musl now declares `[c-abi] presents =
        -- "posix"` (design:
        -- openkal/.agents/docs/2026-09-18-openkal-c-environment-and-personalities-design.md
        -- §3.2), and mcpp realises that declaration for the whole target, so
        -- _WIN32 is simply absent there to begin with; this one line, applied
        -- everywhere, now reaches openkal-Windows exactly as it already
        -- reaches Linux and macOS, and the `target_cfg` is withdrawn rather
        -- than reproduced. zconf.h computes z_off_t and z_off64_t as `off_t`
        -- wherever this header's guard is open, `long long` where it is not.
        --
        -- This `cflags` is package-private: it reaches zlib's own
        -- translation units (gzlib.c, zutil.c, ...) but not a consumer
        -- compiling zlib.h (verified against tests/examples/zlib's
        -- compile_commands.json -- the flag is absent from tests/zlib.cpp's
        -- own command line). So the library computes z_off_t with
        -- Z_HAVE_UNISTD_H set (= off_t) while an openkal-Windows consumer,
        -- which never sees this header, computes it with Z_HAVE_UNISTD_H
        -- unset (= long long, zconf.h's own unconditional fallback). off_t
        -- and long long agree in size on every target this index measures --
        -- all of them LP64 (x86_64-linux-gnu, x86_64-windows-gnu; see
        -- tests/openkal/pins.toml and the platforms xpm above) -- which is
        -- why this is safe today rather than merely untested. This is not a
        -- new asymmetry introduced by hoisting the `-include`: the withdrawn
        -- `-include unistd.h` it replaced was package-private in exactly the
        -- same way, so the library and the consumer already reached z_off_t
        -- by two different routes before this change, and already agreed
        -- only because every measured target is LP64. This comment preserves
        -- that property, and the note about it, rather than introducing
        -- either. On an ILP32 target without _LARGEFILE64_SOURCE, off_t is
        -- 4 bytes and long long
        -- is 8: the two sides of this same split would disagree, silently,
        -- in the type gzseek/gztell pass across the package boundary. Rule 3
        -- of docs/openkal-compat.md is exactly this situation (a macro that
        -- changes a public header's declaration and cannot reach the
        -- consumer), and rule 4 is why tests/examples/zlib already asserts
        -- the agreement at run time via zlibCompileFlags() against the
        -- consumer's own sizeof(z_off_t) -- add an ILP32 target to this
        -- descriptor only once that assertion has actually been run there,
        -- not on the strength of this comment. gzopen_w stays declared for a
        -- consumer and is not defined: a call to it fails at the link rather
        -- than at run time.
        cflags = { "-include", "mcpp_zlib_config.h" },
        linux = {
            cflags = { "-D_GNU_SOURCE" },
        },
        generated_files = {
            ["mcpp_generated/include/mcpp_zlib_config.h"] = "#ifndef MCPP_ZLIB_CONFIG_H\n#define MCPP_ZLIB_CONFIG_H\n#if !defined(_WIN32)\n#define Z_HAVE_UNISTD_H 1\n#endif\n#endif\n",
        },
        sources = {
            "*/adler32.c",
            "*/compress.c",
            "*/crc32.c",
            "*/deflate.c",
            "*/gzclose.c",
            "*/gzlib.c",
            "*/gzread.c",
            "*/gzwrite.c",
            "*/inflate.c",
            "*/infback.c",
            "*/inftrees.c",
            "*/inffast.c",
            "*/trees.c",
            "*/uncompr.c",
            "*/zutil.c",
        },
        targets = { ["zlib"] = { kind = "lib" } },
        deps    = {},
    },
}
