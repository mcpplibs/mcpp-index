package = {
    spec        = "1",
    namespace   = "compat",
    name        = "xorgproto",
    description = "X.Org protocol headers for X11-based compat packages",
    licenses    = {},
    repo        = "https://gitlab.freedesktop.org/xorg/proto/xorgproto",
    type        = "package",

    xpm = {
        linux = {
            ["2025.1"] = {
                url    = {
                    GLOBAL = "https://xorg.freedesktop.org/releases/individual/proto/xorgproto-2025.1.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/xorgproto/releases/download/2025.1/xorgproto-2025.1.tar.gz",
                },
                sha256 = "d6f89f65bafb8c9b735e0515882b8a1511e8e864dde5e9513e191629369f2256",
            },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        c_standard   = "c11",
        include_dirs = {"*/include", "mcpp_generated/include"},
        generated_files = {
            ["mcpp_generated/include/X11/Xpoll.h"] = "#ifndef _XPOLL_H_\n#define _XPOLL_H_\n#if !defined(WIN32) || defined(__CYGWIN__)\n#include <poll.h>\n#include <sys/select.h>\n#define Select(n,r,w,e,t) select(n,(fd_set*)r,(fd_set*)w,(fd_set*)e,(struct timeval*)t)\n#else\n#include <X11/Xwinsock.h>\n#endif\n#endif\n",
            ["mcpp_generated/xorgproto_empty.c"] = "int mcpp_compat_xorgproto_headers_anchor(void) { return 0; }\n",
        },
        sources = {"mcpp_generated/xorgproto_empty.c"},
        targets = { ["xorgproto"] = { kind = "lib" } },
        deps    = {},
    },
}
