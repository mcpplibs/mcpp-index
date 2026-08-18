-- compat.usockets — uSockets, the C eventing/networking layer under uWebSockets.
-- A consumer writes `#include <libusockets.h>`.
--
-- Shape A, plus two defines that are INTERFACE facts rather than private ones.
--
-- BACKEND: libuv, on every platform. uSockets 0.8.8 ships four event loops —
-- epoll/kqueue (POSIX only), GCD (macOS), libuv, and asio. Only libuv covers all
-- three platforms with ONE source list, and it is also the backend the ecosystem
-- has the most mileage on (it is what vcpkg's uwebsockets port selects). The
-- alternative — a per-platform backend — would make `us_loop_t` a different
-- struct per platform for no gain.
--
-- SSL: OFF. crypto/openssl.c and crypto/sni_tree.cpp are not compiled and
-- compat.openssl is not depended on, so the base package has ZERO external
-- dependencies beyond libuv. A TLS feature belongs here eventually; it is a
-- feature rather than a default because terminating TLS in-process is a choice,
-- and paying for OpenSSL when you have not made it is not.
--
-- ALSO OUT: quic.c (needs lsquic) and eventing/io_uring.c (Linux only, and a
-- second Linux backend would contradict the one-backend rule above).
--
-- WHY THE DEFINES REACH CONSUMERS. `libusockets.h` — the PUBLIC header — changes
-- the layout of `us_loop_t` under LIBUS_USE_LIBUV and gates its SSL declarations
-- on LIBUS_NO_SSL. A consumer that does not see the same pair gets a different
-- struct than the library was compiled with, and the mismatch surfaces as
-- corruption at run time rather than an error at build time. An index
-- descriptor's `cflags` reach only this package's own TUs, so a CONSUMER must
-- declare them too — uWebSockets does, and so must anything using uSockets
-- directly.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "usockets",
    description = "uSockets: eventing and networking layer under uWebSockets (libuv backend, no SSL)",
    licenses    = {"Apache-2.0"},
    repo        = "https://github.com/uNetworking/uSockets",
    type        = "package",

    xpm = {
        linux = {
            ["0.8.8"] = {
                url = {
                    GLOBAL = "https://github.com/uNetworking/uSockets/archive/refs/tags/v0.8.8.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/usockets/releases/download/0.8.8/usockets-0.8.8.tar.gz",
                },
                sha256 = "d14d2efe1df767dbebfb8d6f5b52aa952faf66b30c822fbe464debaa0c5c0b17",
            },
        },
        macosx = {
            ["0.8.8"] = {
                url = {
                    GLOBAL = "https://github.com/uNetworking/uSockets/archive/refs/tags/v0.8.8.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/usockets/releases/download/0.8.8/usockets-0.8.8.tar.gz",
                },
                sha256 = "d14d2efe1df767dbebfb8d6f5b52aa952faf66b30c822fbe464debaa0c5c0b17",
            },
        },
        windows = {
            ["0.8.8"] = {
                url = {
                    GLOBAL = "https://github.com/uNetworking/uSockets/archive/refs/tags/v0.8.8.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/usockets/releases/download/0.8.8/usockets-0.8.8.tar.gz",
                },
                sha256 = "d14d2efe1df767dbebfb8d6f5b52aa952faf66b30c822fbe464debaa0c5c0b17",
            },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        c_standard   = "c11",
        -- src/ carries the public <libusockets.h>; the internal headers are
        -- included flat from within it.
        include_dirs = { "*/src" },
        sources      = {
            "*/src/bsd.c",
            "*/src/context.c",
            "*/src/loop.c",
            "*/src/socket.c",
            "*/src/udp.c",
            "*/src/eventing/libuv.c",
        },
        cflags   = { "-DLIBUS_USE_LIBUV", "-DLIBUS_NO_SSL" },
        cxxflags = { "-DLIBUS_USE_LIBUV", "-DLIBUS_NO_SSL" },
        targets  = { ["uSockets"] = { kind = "lib" } },
        deps     = { ["compat.libuv"] = "1.48.0" },
        windows  = { ldflags = { "-lws2_32" } },
    },
}
