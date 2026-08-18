-- compat.uwebsockets — uWebSockets, a header-only C++ HTTP/WebSocket server.
-- A consumer writes `#include <App.h>`.
--
-- Shape B (header-only + anchor TU): the whole library is templates over
-- uSockets' C types, so the package is an include root, a trivial anchor so
-- there is a buildable lib target, and the dependency edge that actually
-- matters.
--
-- THE DEFINES ARE THE POINT. uWS's templates instantiate over `us_loop_t` and
-- friends, so it has to see the SAME backend/SSL shape uSockets was compiled
-- with — LIBUS_USE_LIBUV and LIBUS_NO_SSL — or the struct layouts disagree
-- silently. UWS_NO_ZLIB additionally turns off per-message-deflate, which is
-- what keeps this package free of a zlib dependency; negotiation then simply
-- offers no compression extension, which is the conservative default.
--
-- As with compat.usockets, an index descriptor's `cflags` reach only the
-- package's own TUs — and this package has exactly one, an anchor. So a
-- CONSUMER must declare all three itself. That is not a workaround: uWS is
-- header-only, so the consumer's TU is where it is actually compiled.
--
-- INCLUDE LAYOUT. Upstream keeps its headers flat in `src/` and includes them as
-- <App.h>. Distributions that install them under `uwebsockets/` (vcpkg does)
-- make consumers write `<uwebsockets/App.h>`; exposing `*/src` here is the
-- upstream spelling.
package = {
    spec        = "1",
    namespace   = "compat",
    name        = "uwebsockets",
    description = "uWebSockets: header-only HTTP/WebSocket server (libuv backend, no SSL, no zlib)",
    licenses    = {"Apache-2.0"},
    repo        = "https://github.com/uNetworking/uWebSockets",
    type        = "package",

    xpm = {
        linux = {
            ["20.79.0"] = {
                url = {
                    GLOBAL = "https://github.com/uNetworking/uWebSockets/archive/refs/tags/v20.79.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/uwebsockets/releases/download/20.79.0/uwebsockets-20.79.0.tar.gz",
                },
                sha256 = "d255491a19c26b3f1593c686d4c07d7d2cebe1ba68d42caad87c068cfed0bf84",
            },
        },
        macosx = {
            ["20.79.0"] = {
                url = {
                    GLOBAL = "https://github.com/uNetworking/uWebSockets/archive/refs/tags/v20.79.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/uwebsockets/releases/download/20.79.0/uwebsockets-20.79.0.tar.gz",
                },
                sha256 = "d255491a19c26b3f1593c686d4c07d7d2cebe1ba68d42caad87c068cfed0bf84",
            },
        },
        windows = {
            ["20.79.0"] = {
                url = {
                    GLOBAL = "https://github.com/uNetworking/uWebSockets/archive/refs/tags/v20.79.0.tar.gz",
                    CN     = "https://gitcode.com/mcpp-res/uwebsockets/releases/download/20.79.0/uwebsockets-20.79.0.tar.gz",
                },
                sha256 = "d255491a19c26b3f1593c686d4c07d7d2cebe1ba68d42caad87c068cfed0bf84",
            },
        },
    },

    mcpp = {
        language     = "c++23",
        import_std   = false,
        c_standard   = "c11",
        include_dirs = { "*/src" },
        generated_files = {
            ["mcpp_generated/uws_anchor.c"] = "int mcpp_compat_uwebsockets_anchor(void) { return 0; }\n",
        },
        sources  = { "mcpp_generated/uws_anchor.c" },
        cxxflags = { "-DLIBUS_USE_LIBUV", "-DLIBUS_NO_SSL", "-DUWS_NO_ZLIB" },
        targets  = { ["uWebSockets"] = { kind = "lib" } },
        deps     = { ["compat.usockets"] = "0.8.8" },
    },
}
