package = {
    spec        = "1",
    namespace   = "compat",
    name        = "compat.zlib",
    description = "A compression library",
    licenses    = {"Zlib"},
    repo        = "https://github.com/madler/zlib",
    type        = "package",

    xpm = {
        linux = {
            ["v1.3.2"] = {
                url    = "https://github.com/madler/zlib/archive/refs/tags/v1.3.2.tar.gz",
                sha256 = "b99a0b86c0ba9360ec7e78c4f1e43b1cbdf1e6936c8fa0f6835c0cd694a495a1",
            },
        },
        macosx = {
            ["v1.3.2"] = {
                url    = "https://github.com/madler/zlib/archive/refs/tags/v1.3.2.tar.gz",
                sha256 = "b99a0b86c0ba9360ec7e78c4f1e43b1cbdf1e6936c8fa0f6835c0cd694a495a1",
            },
        },
        windows = {
            ["v1.3.2"] = {
                url    = "https://github.com/madler/zlib/archive/refs/tags/v1.3.2.tar.gz",
                sha256 = "b99a0b86c0ba9360ec7e78c4f1e43b1cbdf1e6936c8fa0f6835c0cd694a495a1",
            },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        c_standard   = "c11",
        include_dirs = {"*", "mcpp_generated/include"},
        cflags       = { "-D_GNU_SOURCE", "-include mcpp_zlib_config.h" },
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
