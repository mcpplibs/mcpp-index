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
        -- wherever this header's guard is open (LP64 on openkal-Windows, so
        -- still 8 bytes); tests/examples/zlib asserts the library and its
        -- consumer agree on that width via zlibCompileFlags(), not a fixed
        -- type. gzopen_w stays declared for a consumer and is not defined: a
        -- call to it fails at the link rather than at run time.
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
