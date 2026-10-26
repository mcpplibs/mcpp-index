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
        -- Whether the libc has arc4random_buf is a property of the sysroot,
        -- not of the platform: glibc declares it from 2.36 (the x86_64
        -- sysroot), an older glibc or musl does not (the aarch64 sysroot).
        -- Key.c either calls the libc's or defines its own over getentropy,
        -- so the choice is made where it can be seen — in config.h below,
        -- from the libc's own version macros. A fixed -DHAVE_ARC4RANDOM_BUF
        -- breaks the older sysroot (an implicit declaration); leaving it out
        -- breaks the newer one (Key.c's static definition conflicts).
        cflags       = {"-D_GNU_SOURCE", "-D_DEFAULT_SOURCE", "-DHAVE_CONFIG_H"},
        generated_files = {
            ["mcpp_generated/config.h"] = [[
/* compat.xdmcp: the one configure answer the sources depend on. */
#ifndef MCPP_XDMCP_CONFIG_H
#define MCPP_XDMCP_CONFIG_H
#if defined(__has_include)
#  if __has_include(<features.h>)
#    include <features.h>
#  endif
#endif
#if defined(__GLIBC__) && (__GLIBC__ > 2 || (__GLIBC__ == 2 && __GLIBC_MINOR__ >= 36))
#  define HAVE_ARC4RANDOM_BUF 1
#else
/* getentropy: glibc 2.25+, musl 1.1.20+. */
#  define HAVE_GETENTROPY 1
#  define HAVE_SYS_RANDOM_H 1
#endif
#endif
]],
        },
        include_dirs = {"mcpp_generated", "*/include", "*"},
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
