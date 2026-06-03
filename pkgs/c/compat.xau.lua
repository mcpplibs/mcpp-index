package = {
    spec        = "1",
    namespace   = "compat",
    name        = "compat.xau",
    description = "X authorization file management library",
    licenses    = {"MIT-Open-Group"},
    repo        = "https://gitlab.freedesktop.org/xorg/lib/libxau",
    type        = "package",

    xpm = {
        linux = {
            ["1.0.12"] = {
                url    = "https://xorg.freedesktop.org/releases/individual/lib/libXau-1.0.12.tar.gz",
                sha256 = "2402dd938da4d0a332349ab3d3586606175e19cb32cb9fe013c19f1dc922dcee",
            },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        c_standard   = "c11",
        cflags       = {"-D_GNU_SOURCE", "-D_DEFAULT_SOURCE"},
        include_dirs = {"*/include"},
        sources = {
            "*/AuDispose.c",
            "*/AuFileName.c",
            "*/AuGetAddr.c",
            "*/AuGetBest.c",
            "*/AuLock.c",
            "*/AuRead.c",
            "*/AuUnlock.c",
            "*/AuWrite.c",
        },
        targets = { ["Xau"] = { kind = "shared", soname = "libXau.so.6" } },
        deps = {
            ["compat.xorgproto"] = "2025.1",
        },
    },
}
