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
        -- Both of these are GCC/Clang-only and used to be unconditional.
        -- `-include` is the worse of the two on MSVC: cl does not reject it, it
        -- warns (`D9002 ignoring unknown option`) and carries on, so the config
        -- header was silently never included. The header only defines anything
        -- when _WIN32 is absent, so Windows needs neither.
        linux = {
            cflags = { "-D_GNU_SOURCE", "-include", "mcpp_zlib_config.h" },
        },
        macosx = {
            cflags = { "-include", "mcpp_zlib_config.h" },
        },
        -- Windows with musl as the C library (an openkal graph). The triple
        -- defines _WIN32, and zlib reads _WIN32 as "the Windows C runtime is
        -- present" (<io.h>, _lseeki64, _wopen), which is false here. The flag is
        -- confined to zlib's own translation units and reaches no public
        -- header in a way that changes a declaration: zconf.h computes z_off_t
        -- and z_off64_t as `long long` on both sides, because Z_HAVE_UNISTD_H
        -- is deliberately not defined (unistd.h is included directly instead).
        -- tests/examples/zlib asserts that agreement with zlibCompileFlags().
        -- gzopen_w stays declared for a consumer and is not defined: a call to
        -- it fails at the link rather than at run time.
        target_cfg = {
            ["cfg(all(windows, c-abi = \"musl\"))"] = {
                cflags = { "-U_WIN32", "-include", "unistd.h" },
            },
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
