package = {
    spec        = "1",
    namespace   = "compat",
    name        = "compat.xdmcp",
    description = "X Display Manager Control Protocol library",
    licenses    = {"MIT-Open-Group"},
    repo        = "https://gitlab.freedesktop.org/xorg/lib/libxdmcp",
    type        = "package",

    xpm = {
        linux = {
            ["1.1.5"] = {
                url    = "https://xorg.freedesktop.org/releases/individual/lib/libXdmcp-1.1.5.tar.gz",
                sha256 = "31a7abc4f129dcf6f27ae912c3eedcb94d25ad2e8f317f69df6eda0bc4e4f2f3",
            },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        c_standard   = "c11",
        cflags       = {"-D_GNU_SOURCE", "-D_DEFAULT_SOURCE", "-DHAVE_ARC4RANDOM_BUF=1"},
        include_dirs = {"*/include", "*"},
        sources = {
            "*/Array.c",
            "*/Fill.c",
            "*/Flush.c",
            "*/Key.c",
            "*/Read.c",
            "*/Unwrap.c",
            "*/Wrap.c",
            "*/Write.c",
        },
        targets = { ["Xdmcp"] = { kind = "shared", soname = "libXdmcp.so.6" } },
        deps = {
            ["compat.xorgproto"] = "2025.1",
        },
    },
}
