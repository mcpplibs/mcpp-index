package = {
    spec        = "1",
    namespace   = "compat",
    name        = "xdmcp",
    description = "X Display Manager Control Protocol library",
    licenses    = {"MIT-Open-Group"},
    repo        = "https://gitlab.freedesktop.org/xorg/lib/libxdmcp",
    type        = "package",

    xpm = {
        linux = {
            ["1.1.5"] = {
                url    = {
                    GLOBAL = "https://xorg.freedesktop.org/releases/individual/lib/libXdmcp-1.1.5.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/xdmcp/releases/download/1.1.5/xdmcp-1.1.5.tar.gz",
                },
                sha256 = "31a7abc4f129dcf6f27ae912c3eedcb94d25ad2e8f317f69df6eda0bc4e4f2f3",
            },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        c_standard   = "c11",
        -- Key.c emulates arc4random_buf with getentropy (glibc 2.25+) when the
        -- libc has no arc4random_buf of its own. Declaring HAVE_ARC4RANDOM_BUF
        -- instead assumed glibc 2.36+, which an older sysroot (aarch64) lacks:
        -- an implicit declaration, an error under C11.
        cflags       = {"-D_GNU_SOURCE", "-D_DEFAULT_SOURCE", "-DHAVE_GETENTROPY=1", "-DHAVE_SYS_RANDOM_H=1"},
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
